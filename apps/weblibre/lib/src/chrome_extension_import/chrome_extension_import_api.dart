/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre.
 */

import 'dart:async';
import 'package:flutter/services.dart';
import 'installed_extension.dart';

/// Chrome extension import API binding.
class ChromeExtensionImportApi {
  static const MethodChannel _channel =
      MethodChannel('eu.weblibre.flutter_mozilla_components/chrome_extension_import');

  /// Import a Chrome extension from CRX bytes.
  static Future<ChromeExtensionImportResult> importCrx(
    List<int> crxBytes,
    List<String> permissions,
  ) async {
    try {
      final result = await _channel.invokeMethod('importCrx', {
        'crxBytes': crxBytes,
        'permissions': permissions,
      });

      if (result == null) {
        return ChromeExtensionImportResult(
          success: false,
          error: 'Unexpected null result from native layer',
        );
      }

      return ChromeExtensionImportResult(
        success: result['success'] as bool? ?? false,
        extensionId: result['extensionId'] as String?,
        error: result['error'] as String?,
      );
    } on PlatformException catch (e) {
      return ChromeExtensionImportResult(
        success: false,
        error: e.message ?? 'Import failed: ${e.code}',
      );
    }
  }

  /// List all installed Chrome extensions.
  static Future<List<InstalledExtension>> listExtensions() async {
    try {
      final result = await _channel.invokeMethod('listExtensions');
      if (result == null) return [];

      return (result as List).map((item) {
        return InstalledExtension.fromJson(item as Map<String, dynamic>);
      }).toList();
    } on PlatformException catch (e) {
      debugPrint('Failed to list extensions: $e');
      return [];
    }
  }

  /// Toggle extension enabled state.
  static Future<void> toggleExtension(String extensionId, bool enabled) async {
    try {
      await _channel.invokeMethod('toggleExtension', {
        'extensionId': extensionId,
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to toggle extension: $e');
    }
  }

  /// Uninstall an extension.
  static Future<bool> uninstallExtension(String extensionId) async {
    try {
      final result = await _channel.invokeMethod('uninstallExtension', {
        'extensionId': extensionId,
      });
      return result as bool? ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to uninstall extension: $e');
      return false;
    }
  }

  /// Check for extension update.
  static Future<ExtensionUpdate> checkForUpdate(String extensionId) async {
    try {
      final result = await _channel.invokeMethod('checkForUpdate', {
        'extensionId': extensionId,
      });
      if (result == null) return ExtensionUpdate(available: false);

      return ExtensionUpdate(
        available: result['available'] as bool? ?? false,
        availableVersion: result['availableVersion'] as String?,
        changelog: result['changelog'] as String?,
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to check for update: $e');
      return ExtensionUpdate(available: false);
    }
  }
}

/// Result of importing a Chrome extension.
class ChromeExtensionImportResult {
  final bool success;
  final String? extensionId;
  final String? error;

  ChromeExtensionImportResult({
    required this.success,
    this.extensionId,
    this.error,
  });
}

/// Update information for an extension.
class ExtensionUpdate {
  final bool available;
  final String? availableVersion;
  final String? changelog;

  ExtensionUpdate({
    required this.available,
    this.availableVersion,
    this.changelog,
  });
}
