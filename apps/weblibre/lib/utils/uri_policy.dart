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

class Scheme {
  final String name;
  final bool requiresAuthority;
  const Scheme(this.name, {this.requiresAuthority = false});
}

const kSchemeHttp = Scheme('http', requiresAuthority: true);
const kSchemeHttps = Scheme('https', requiresAuthority: true);
const kSchemeFtp = Scheme('ftp', requiresAuthority: true);
const kSchemeFile = Scheme('file');
const kSchemeContent = Scheme('content', requiresAuthority: true);
const kSchemeAbout = Scheme('about');
const kSchemeMozExtension = Scheme('moz-extension', requiresAuthority: true);

const allSupportedSchemes = [
  kSchemeHttp,
  kSchemeHttps,
  kSchemeFtp,
  kSchemeFile,
  kSchemeContent,
  kSchemeAbout,
  kSchemeMozExtension,
];

const httpOnlySchemes = [kSchemeHttp, kSchemeHttps];

bool schemeRequiresAuthority(String scheme) {
  return allSupportedSchemes.any(
    (s) => s.name == scheme && s.requiresAuthority,
  );
}

enum SchemePolicy {
  addressBarTyped,
  strictHttpOnly,
  sharedIntent,
  internalIntent,
}

extension SchemePolicyX on SchemePolicy {
  List<Scheme> get _schemes => switch (this) {
    SchemePolicy.addressBarTyped => allSupportedSchemes,
    SchemePolicy.strictHttpOnly => httpOnlySchemes,
    SchemePolicy.sharedIntent => httpOnlySchemes,
    SchemePolicy.internalIntent => allSupportedSchemes,
  };

  Set<String> get allowedSchemes => _schemes.map((s) => s.name).toSet();

  bool allows(String scheme) {
    return allowedSchemes.contains(scheme.toLowerCase());
  }
}
