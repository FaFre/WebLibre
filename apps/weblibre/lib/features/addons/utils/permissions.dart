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

typedef PermissionDescription = ({String text, bool technical});

PermissionDescription describePermission(String raw) {
  String? mapped;
  switch (raw) {
    case 'bookmarks':
      mapped = 'Read and modify bookmarks';
    case 'browserSettings':
      mapped = 'Read and modify browser settings';
    case 'browsingData':
      mapped = 'Clear recent browsing history, cookies, and related data';
    case 'clipboardRead':
      mapped = 'Read data you copy and paste';
    case 'clipboardWrite':
      mapped = 'Input data to the clipboard';
    case 'contextualIdentities':
      mapped = 'Access and modify container tabs';
    case 'cookies':
      mapped = 'Access cookies for visited sites';
    case 'downloads':
      mapped = 'Download files and read/modify download history';
    case 'downloads.open':
      mapped = 'Open files downloaded to your computer';
    case 'find':
      mapped = 'Read the text of all open tabs';
    case 'geolocation':
      mapped = 'Access your location';
    case 'history':
      mapped = 'Access browsing history';
    case 'management':
      mapped = 'Monitor extension usage and manage themes';
    case 'nativeMessaging':
      mapped = 'Exchange messages with programs other than the browser';
    case 'notifications':
      mapped = 'Display notifications';
    case 'pkcs11':
      mapped = 'Provide cryptographic authentication services';
    case 'privacy':
      mapped = 'Read and modify privacy settings';
    case 'proxy':
      mapped = 'Control browser proxy settings';
    case 'sessions':
      mapped = 'Access recently closed tabs';
    case 'tabs':
      mapped = 'Access browser tabs';
    case 'tabHide':
      mapped = 'Hide and show browser tabs';
    case 'topSites':
      mapped = 'Access browsing history';
    case 'webNavigation':
      mapped = 'Access browser activity during navigation';
    case '<all_urls>':
      mapped = 'Access your data for all websites';
  }
  if (mapped != null) return (text: mapped, technical: false);
  if (raw.startsWith('http') ||
      raw.contains('://') ||
      raw.contains('*') ||
      raw.startsWith('file:')) {
    return (text: 'Access your data for $raw', technical: false);
  }
  return (text: raw, technical: true);
}
