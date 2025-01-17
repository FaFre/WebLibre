import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

const String _libName = 'vec0';

class Sqlite3Vec {
  static void ensureExtensionLoaded() {
    final libPath = switch (Platform.operatingSystem) {
      //'macos' || 'ios' => DynamicLibrary.open('$_libName.framework/$_libName'),
      'android' || 'linux' => DynamicLibrary.open('lib$_libName.so'),
      //'windows' => DynamicLibrary.open('$_libName.dll'),
      _ => throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}',
        ),
    };

    sqlite3.ensureExtensionLoaded(
      SqliteExtension.inLibrary(libPath, 'sqlite3_vec_init'),
    );
  }
}
