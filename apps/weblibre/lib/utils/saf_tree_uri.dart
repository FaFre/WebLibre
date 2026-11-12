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
import 'package:saf_util/saf_util.dart';

/// Reads a folder name out of a SAF tree URI, for the moment before the
/// document provider has answered — and for when it never does.
///
/// A tree URI ends in the provider's own document id, conventionally
/// `volume:relative/path`, so the path inside the volume is shown
/// (`primary:Documents/Backups` reads `Documents/Backups`). Anything else is
/// shown whole rather than guessed at. Works on both forms a folder is known
/// by: `…/tree/<id>` and the picker's `…/tree/<id>/document/<id>`, which
/// ends in the folder's own id.
String describeSafTreeUri(String uri) {
  final documentId = Uri.decodeComponent(uri.split('/').last);
  final separator = documentId.indexOf(':');

  if (separator < 0 || separator == documentId.length - 1) {
    return documentId;
  }

  return documentId.substring(separator + 1);
}

/// The tree URI a picked folder is addressed by.
///
/// `saf_util` takes the persisted grant on the tree URI the system returned, but
/// hands back `DocumentFile.fromTreeUri(...).uri` — the same folder in its
/// *document* form, `…/tree/<id>/document/<id>`. Nothing downstream accepts that
/// form: the grant list is keyed on the tree URI, and Mozilla's writer compares
/// `directoryPath` against it by exact equality before writing. Saving the
/// picker's URI verbatim therefore stored a folder that matched no grant, so
/// every download quietly went to the public Downloads folder instead.
///
/// Nothing is lost: the picker's document id is always the tree's own.
String normalizeSafTreeUri(String uri) {
  final tree = uri.indexOf('/tree/');
  if (tree < 0) {
    return uri;
  }

  final document = uri.indexOf('/document/', tree);

  return document < 0 ? uri : uri.substring(0, document);
}

/// Opens the system folder picker for a folder the app keeps writing into.
///
/// Returns the folder by the tree URI its persisted grant is recorded under
/// (see [normalizeSafTreeUri]) together with its name, or null when the picker
/// was cancelled.
Future<({Uri tree, String name})?> pickWritableSafFolder() async {
  final picked = await SafUtil().pickDirectory(
    writePermission: true,
    persistablePermission: true,
  );
  if (picked == null) return null;

  return (tree: Uri.parse(normalizeSafTreeUri(picked.uri)), name: picked.name);
}
