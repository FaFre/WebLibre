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
import 'package:uuid/uuid_value.dart';

/// Secure storage is one store for the whole app, shared by every profile.
///
/// Nothing in `flutter_secure_storage` is profile-aware — the Android backend
/// keeps a single set of records per *application*. So a key written by one
/// profile is readable, overwritable and deletable by every other one, and a
/// deleted profile's credentials simply stay behind. The only thing that can
/// carry ownership is the key itself.
///
/// Every profile-owned record therefore ends in `@p:<canonical uuid>`. The
/// separator is chosen so it cannot occur inside a UUID and does not appear in
/// any base key this app uses, which is what makes [profileOfKey] able to answer
/// "who owns this" by inspection — the property backup, restore and delete all
/// depend on.
const secureKeyProfileSeparator = '@p:';

/// Where a record whose owner cannot be determined is parked.
///
/// Used by the one-time migration for credentials that predate profile
/// qualification. It is deliberately not a profile: attaching a credential to a
/// profile that may not own it is the same mistake as storing another profile's
/// push message under whichever profile won startup.
const secureKeyUnattributedSuffix = '@unattributed';

/// The storage key for [base] owned by [profileId].
String profileScopedSecureKey(String base, String profileId) =>
    '$base$secureKeyProfileSeparator${_canonical(profileId)}';

/// The owning profile of [key], or null when it names no profile.
///
/// Null covers both an unqualified legacy key and a parked one, and callers must
/// treat those as "not mine" rather than "mine by default".
String? profileOfSecureKey(String key) {
  final index = key.lastIndexOf(secureKeyProfileSeparator);
  if (index < 0) return null;

  final candidate = key.substring(index + secureKeyProfileSeparator.length);
  try {
    return UuidValue.withValidation(candidate.toLowerCase()).uuid;
  } catch (_) {
    // A key that merely happens to contain the separator is not ownership.
    return null;
  }
}

/// The base key of [key], with any profile qualification removed.
String baseOfSecureKey(String key) {
  if (profileOfSecureKey(key) == null) return key;
  return key.substring(0, key.lastIndexOf(secureKeyProfileSeparator));
}

/// Whether [key] belongs to [profileId].
bool secureKeyBelongsTo(String key, String profileId) =>
    profileOfSecureKey(key) == _canonical(profileId);

String _canonical(String profileId) =>
    UuidValue.withValidation(profileId.toLowerCase()).uuid;
