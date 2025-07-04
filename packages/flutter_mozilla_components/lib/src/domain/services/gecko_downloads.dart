/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoDownloadsApi();

class GeckoDownloadsService {
  final GeckoDownloadsApi _api;

  GeckoDownloadsService({GeckoDownloadsApi? api}) : _api = api ?? _apiInstance;

  Future<void> copyInternetResource(
    String tabId, {
    required Uri url,
    Uri? referrerUrl,
    String? contentType,

    bool isPrivate = false,
  }) {
    return _api.copyInternetResource(
      tabId,
      ShareInternetResourceState(
        url: url.toString(),
        referrerUrl: referrerUrl?.toString(),
        private: isPrivate,
        contentType: contentType,
      ),
    );
  }

  Future<void> shareInternetResource(
    String tabId, {
    required Uri url,
    Uri? referrerUrl,
    String? contentType,

    bool isPrivate = false,
  }) {
    return _api.shareInternetResource(
      tabId,
      ShareInternetResourceState(
        url: url.toString(),
        referrerUrl: referrerUrl?.toString(),
        private: isPrivate,
        contentType: contentType,
      ),
    );
  }

  Future<void> requestDownload(
    String tabId, {
    required Uri url,
    String? fileName,
    bool? openInApp,
    bool? skipConfirmation,
    Uri? referrerUrl,
    bool isPrivate = false,
  }) {
    return _api.requestDownload(
      tabId,
      DownloadState(
        url: url.toString(),
        fileName: fileName,
        openInApp: openInApp,
        skipConfirmation: skipConfirmation,
        referrerUrl: referrerUrl?.toString(),
        private: isPrivate,
      ),
    );
  }
}
