/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre.
 */

/// Represents an installed Chrome extension.
class InstalledExtension {
  final String id;
  final String name;
  final String version;
  final bool enabled;
  final List<String> permissions;

  InstalledExtension({
    required this.id,
    required this.name,
    required this.version,
    required this.enabled,
    required this.permissions,
  });

  factory InstalledExtension.fromJson(Map<String, dynamic> json) {
    return InstalledExtension(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      enabled: json['enabled'] as bool,
      permissions: (json['permissions'] as List)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'enabled': enabled,
      'permissions': permissions,
    };
  }
}
