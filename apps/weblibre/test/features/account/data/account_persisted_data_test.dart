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
 */
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/features/account/data/models/account_persisted_data.dart';

void main() {
  test('core names the in-flight sign-in field the same way the model does', () {
    // `SecureStorageParticipant` strips this field on the way into an archive
    // and cannot import the account model to ask what it is called — `core` may
    // not reach into a feature. So the name is duplicated, and this is what says
    // the two halves still agree. Renaming the field without renaming the
    // constant would silently start archiving in-flight sign-ins again.
    final json = AccountPersistedData(pendingCodeVerifier: 'v').toJson();

    expect(json[accountPendingCodeVerifierField], 'v');
  });
}
