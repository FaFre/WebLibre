/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/startup/models/json_read.dart';

/// The bundled components, in display order (plan 4.1). One definition for
/// the About dialog, the build manifest and release metadata. [name] is the
/// stable identifier in the build manifest and the catalogue.
enum ComponentId {
  gecko('Gecko'),
  androidComponents('Android Components'),
  applicationServices('Application Services'),
  tor(torBrand),
  snowflake('Snowflake'),
  lyrebird('Lyrebird'),
  singbox('sing-box');

  const ComponentId(this.productName);

  /// Product name, never translated.
  final String productName;
}

sealed class ComponentIdentity with FastEquatable {
  ComponentIdentity();
}

final class ComponentKnown extends ComponentIdentity {
  ComponentKnown(this.version, {this.buildId, this.revision});

  final String version;
  final String? buildId;
  final String? revision;

  @override
  List<Object?> get hashParameters => [version, buildId, revision];

  @override
  String toString() => buildId == null ? version : '$version ($buildId)';
}

/// The build or the metadata could not say. Never shown as a version.
final class ComponentUnknown extends ComponentIdentity {
  ComponentUnknown();

  @override
  List<Object?> get hashParameters => [runtimeType];
}

final class ComponentNotBundled extends ComponentIdentity {
  ComponentNotBundled();

  @override
  List<Object?> get hashParameters => [runtimeType];
}

/// Parses the shared `{status, version, buildId, revision}` shape. Anything
/// malformed is unknown.
ComponentIdentity componentIdentityFromJson(Object? json) {
  if (json is! Map) return ComponentUnknown();
  final status = json['status'];
  // Catalogue entries may omit `status`: a version means known.
  if (status == 'notBundled') return ComponentNotBundled();
  if (status != null && status != 'known') return ComponentUnknown();
  final version = stringOrNull(json['version']);
  if (version == null) return ComponentUnknown();
  return ComponentKnown(
    version,
    buildId: stringOrNull(json['buildId']),
    revision: stringOrNull(json['revision']),
  );
}
