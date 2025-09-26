// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tor/generated_bindings.dart' as rust;

DynamicLibrary load(String name) {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$name.so');
  } else if (Platform.isIOS || Platform.isMacOS) {
    return DynamicLibrary.open('$name.framework/$name');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('$name.dll');
  } else {
    throw NotSupportedPlatform('${Platform.operatingSystem} is not supported!');
  }
}

class CouldntBootstrapDirectory implements Exception {
  String? rustError;

  CouldntBootstrapDirectory({this.rustError});
}

class NotSupportedPlatform implements Exception {
  String reason;

  NotSupportedPlatform(this.reason);
}

class ClientNotActive implements Exception {}

class Tor {
  static const String libName = "tor";
  static late DynamicLibrary _lib;

  Pointer<Void> _clientPtr = nullptr;
  Pointer<Void> _proxyPtr = nullptr;

  /// Flag to indicate that Tor client and proxy have started. Traffic is routed through the proxy only if it is also [enabled].
  bool get started => _proxyPort > -1;

  bool get hasClient => _clientPtr != nullptr;

  /// Flag to indicate that traffic should flow through the proxy.
  bool _enabled = false;

  /// Getter for the enabled flag.
  bool get enabled => _enabled;

  /// Flag to indicate that a Tor circuit is thought to have been established
  /// (true means that Tor has bootstrapped).
  bool get bootstrapped => _bootstrapped;

  /// Getter for the bootstrapped flag.
  bool _bootstrapped = false;

  /// A stream of Tor events.
  ///
  /// This stream broadcast just the port for now (-1 if circuit not established or proxy not enabled)
  final StreamController events = StreamController.broadcast();

  /// Getter for the proxy port.
  ///
  /// Returns -1 if Tor is not enabled or if the circuit is not established.
  ///
  /// Returns the proxy port if Tor is enabled and the circuit is established.
  ///
  /// This is the port that should be used for all requests.
  int get port {
    if (!_enabled) {
      return -1;
    }
    return _proxyPort;
  }

  /// The proxy port.
  int _proxyPort = -1;

  /// Singleton instance of the Tor class.
  static final Tor _instance = Tor._internal();

  /// Getter for the singleton instance of the Tor class.
  static Tor get instance => _instance;

  /// Initialize the Tor ffi lib instance if it hasn't already been set. Nothing
  /// changes if _tor is already been set.
  ///
  /// Returns a Future that completes when the Tor service has started.
  ///
  /// Throws an exception if the Tor service fails to start.
  static Tor init({bool enabled = true}) {
    final singleton = Tor._instance;
    singleton._enabled = enabled;
    return singleton;
  }

  /// Private constructor for the Tor class.
  Tor._internal() {
    _lib = load(libName);

    if (kDebugMode) {
      print("Instance of Tor created!");
    }
  }

  void broadcastState() {
    events.add(port);
  }

  Future<int> _getRandomUnusedPort({List<int> excluded = const []}) async {
    final random = Random.secure();
    int potentialPort = 0;

    retry:
    while (potentialPort <= 0 || excluded.contains(potentialPort)) {
      potentialPort = random.nextInt(65535);
      try {
        final socket = await ServerSocket.bind("0.0.0.0", potentialPort);
        await socket.close();
        return potentialPort;
      } catch (_) {
        continue retry;
      }
    }

    return -1;
  }

  /// Start the Tor service.
  ///
  /// This will start the Tor service and establish a Tor circuit.
  ///
  /// Throws an exception if the Tor service fails to start.
  ///
  /// Returns a Future that completes when the Tor service has started.
  Future<void> start({
    int? obfs4Port,
    int? snowflakePort,
    String? bridgeLines,
  }) async {
    broadcastState();

    // Set the state and cache directories.
    final Directory appSupportDir = await getApplicationSupportDirectory();
    final stateDir = await Directory(
      '${appSupportDir.path}/tor_state',
    ).create();
    final cacheDir = await Directory(
      '${appSupportDir.path}/tor_cache',
    ).create();

    // Generate a random port.
    final newPort = await _getRandomUnusedPort();

    // Start the Tor service in an isolate.
    final tor = await Isolate.run(() {
      // Load the Tor library.
      final lib = rust.NativeLibrary(load(libName));

      // Start the Tor service.
      final tor = lib.tor_start(
        newPort,
        stateDir.path.toNativeUtf8() as Pointer<Char>,
        cacheDir.path.toNativeUtf8() as Pointer<Char>,
        obfs4Port ?? -1,
        snowflakePort ?? -1,
        bridgeLines?.toNativeUtf8() as Pointer<Char>? ?? nullptr,
      );

      // Throw an exception if the Tor service fails to start.
      if (tor.client == nullptr) {
        throwRustException(lib);
      }

      return tor;
    });

    // Set the client pointer and started flag.
    _clientPtr = Pointer.fromAddress(tor.client.address);
    _proxyPtr = Pointer.fromAddress(tor.proxy.address);

    // Bootstrap the Tor service.
    bootstrap();

    // Set the proxy port.
    _proxyPort = newPort;
    broadcastState();
  }

  Future<void> reconfigure({
    int? obfs4Port,
    int? snowflakePort,
    String? bridgeLines,
  }) async {
    final lib = rust.NativeLibrary(_lib);

    // Set the state and cache directories.
    final Directory appSupportDir = await getApplicationSupportDirectory();
    final stateDir = await Directory(
      '${appSupportDir.path}/tor_state',
    ).create();
    final cacheDir = await Directory(
      '${appSupportDir.path}/tor_cache',
    ).create();

    final reconfigured = lib.tor_reconfigure(
      _clientPtr,
      stateDir.path.toNativeUtf8() as Pointer<Char>,
      cacheDir.path.toNativeUtf8() as Pointer<Char>,
      obfs4Port ?? -1,
      snowflakePort ?? -1,
      bridgeLines?.toNativeUtf8() as Pointer<Char>? ?? nullptr,
    );

    if (!reconfigured) {
      throwRustException(lib);
    }
  }

  /// Bootstrap the Tor service.
  ///
  /// This will bootstrap the Tor service and establish a Tor circuit.  This
  /// function should only be called after the Tor service has been started.
  ///
  /// This function will block until the Tor service has bootstrapped.
  ///
  /// Throws an exception if the Tor service fails to bootstrap.
  ///
  /// Returns void.
  void bootstrap() {
    // Load the Tor library.
    final lib = rust.NativeLibrary(_lib);

    // Bootstrap the Tor service.
    _bootstrapped = lib.tor_client_bootstrap(_clientPtr);

    // Throw an exception if the Tor service fails to bootstrap.
    if (!bootstrapped) {
      throwRustException(lib);
    }
  }

  /// Prevent traffic flowing through the proxy
  void disable() {
    stop();

    _enabled = false;
    broadcastState();
  }

  /// Stops the proxy
  void stop() {
    final lib = rust.NativeLibrary(_lib);
    if (_proxyPtr != nullptr) {
      lib.tor_proxy_stop(_proxyPtr);
      _proxyPtr = nullptr;

      _bootstrapped = false;
      _proxyPort = -1;

      broadcastState();
    }
  }

  void setClientDormant(bool dormant) {
    if (_clientPtr == nullptr || !started || !bootstrapped) {
      throw ClientNotActive();
    }

    final lib = rust.NativeLibrary(_lib);
    lib.tor_client_set_dormant(_clientPtr, dormant);
  }

  Future<void> isReady() async {
    return await Future.doWhile(
      () => Future.delayed(const Duration(seconds: 1)).then((_) {
        // We are waiting and making absolutely no request unless:
        // Tor is disabled
        if (!enabled) {
          return false;
        }

        // ...or Tor circuit is established
        if (bootstrapped) {
          return false;
        }

        // This way we avoid making clearnet req's while Tor is initialising
        return true;
      }),
    );
  }

  static void throwRustException(rust.NativeLibrary lib) {
    final String rustError = lib
        .tor_last_error_message()
        .cast<Utf8>()
        .toDartString();

    throw _getRustException(rustError);
  }

  static Exception _getRustException(String rustError) {
    if (rustError.contains('Unable to bootstrap a working directory')) {
      return CouldntBootstrapDirectory(rustError: rustError);
    } else {
      return Exception(rustError);
    }
  }

  void hello() {
    rust.NativeLibrary(_lib).tor_hello();
  }
}
