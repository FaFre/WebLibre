/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _api = GeckoAppLinksApi();

/// Service for detecting and launching external applications that can handle URLs.
///
/// This service wraps Mozilla Android Components' AppLinksUseCases to allow
/// checking if native apps can handle URLs and launching them directly.
/// This matches the behavior in Firefox/Fenix for "Open in App" functionality.
class GeckoAppLinksService {
  /// Checks if an external application is available to handle the given URL.
  ///
  /// This method uses mozilla-components AppLinksUseCases to determine if
  /// a native app can handle the URL (e.g., YouTube app for youtube.com links).
  ///
  /// @param url The URL to check.
  /// @return true if an external app is available, false otherwise.
  Future<bool> hasExternalApp(Uri url) {
    return _api.hasExternalApp(url.toString());
  }

  /// Opens the URL in an external application if available.
  ///
  /// This method will:
  /// 1. Check if an external app can handle the URL
  /// 2. If available, launch the app directly with Intent.FLAG_ACTIVITY_NEW_TASK
  /// 3. Return true if successfully launched, false otherwise
  ///
  /// @param url The URL to open in external app.
  /// @return true if URL was opened in external app, false if no app available.
  Future<bool> openAppLink(Uri url) {
    return _api.openAppLink(url.toString());
  }
}
