/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:pigeon/pigeon.dart';

/// Result of importing a Chrome extension.
class ChromeExtensionImportResult {
  ChromeExtensionImportResult({
    required this.success,
    this.extensionId,
    this.error,
  });

  final bool success;
  final String? extensionId;
  final String? error;
}

/// Information about an installed extension.
class InstalledExtension {
  InstalledExtension({
    required this.id,
    required this.name,
    required this.version,
    required this.enabled,
    required this.permissions,
  });

  final String id;
  final String name;
  final String version;
  final bool enabled;
  final List<String> permissions;
}

/// Update information for an extension.
class ExtensionUpdate {
  ExtensionUpdate({
    required this.available,
    this.availableVersion,
    this.changelog,
  });

  final bool available;
  final String? availableVersion;
  final String? changelog;
}

/// Host API for Chrome extension management.
@HostApi()
abstract class ChromeExtensionImportApi {
  /// Import a Chrome extension from CRX bytes.
  ///
  /// [requestedPermissions] is used to show a permission preview before import.
  ChromeExtensionImportResult importCrx(
    List<int> crxBytes,
    List<String> requestedPermissions,
  );

  /// List all installed Chrome extensions.
  List<InstalledExtension> listExtensions();

  /// Enable or disable an extension.
  void toggleExtension(String extensionId, bool enabled);

  /// Uninstall an extension.
  bool uninstallExtension(String extensionId);

  /// Check if an extension has an update available.
  ExtensionUpdate checkForUpdate(String extensionId);
}
