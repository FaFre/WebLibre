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

import 'package:flutter/widgets.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

typedef PermissionDescription = ({String text, bool technical});

PermissionDescription describePermission(BuildContext context, String raw) {
  final l10n = AppLocalizations.of(context);

  String? mapped;
  switch (raw) {
    case 'bookmarks':
      mapped = l10n.addons_permissionBookmarks;
    case 'browserSettings':
      mapped = l10n.addons_permissionBrowserSettings;
    case 'browsingData':
      mapped = l10n.addons_permissionBrowsingData;
    case 'clipboardRead':
      mapped = l10n.addons_permissionClipboardRead;
    case 'clipboardWrite':
      mapped = l10n.addons_permissionClipboardWrite;
    case 'contextualIdentities':
      mapped = l10n.addons_permissionContextualIdentities;
    case 'cookies':
      mapped = l10n.addons_permissionCookies;
    case 'downloads':
      mapped = l10n.addons_permissionDownloads;
    case 'downloads.open':
      mapped = l10n.addons_permissionDownloadsOpen;
    case 'find':
      mapped = l10n.addons_permissionFind;
    case 'geolocation':
      mapped = l10n.addons_permissionGeolocation;
    case 'history':
      mapped = l10n.addons_permissionHistory;
    case 'management':
      mapped = l10n.addons_permissionManagement;
    case 'nativeMessaging':
      mapped = l10n.addons_permissionNativeMessaging;
    case 'notifications':
      mapped = l10n.addons_permissionNotifications;
    case 'pkcs11':
      mapped = l10n.addons_permissionPkcs11;
    case 'privacy':
      mapped = l10n.addons_permissionPrivacy;
    case 'proxy':
      mapped = l10n.addons_permissionProxy;
    case 'sessions':
      mapped = l10n.addons_permissionSessions;
    case 'tabs':
      mapped = l10n.addons_permissionTabs;
    case 'tabHide':
      mapped = l10n.addons_permissionTabHide;
    case 'topSites':
      mapped = l10n.addons_permissionTopSites;
    case 'webNavigation':
      mapped = l10n.addons_permissionWebNavigation;
    case '<all_urls>':
      mapped = l10n.addons_permissionAllUrls;
  }
  if (mapped != null) return (text: mapped, technical: false);
  if (raw.startsWith('http') ||
      raw.contains('://') ||
      raw.contains('*') ||
      raw.startsWith('file:')) {
    return (text: l10n.addons_permissionAccessDataFor(raw), technical: false);
  }
  return (text: raw, technical: true);
}
