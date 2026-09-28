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
import 'package:weblibre/features/geckoview/features/browser/features/menu/domain/entities/menu_layout.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display labels for [MenuSectionType].
extension MenuSectionTypeL10n on MenuSectionType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      MenuSectionType.quickToggles => l10n.menu_sectionQuickToggles,
      MenuSectionType.pageActions => l10n.menu_sectionPageActions,
      MenuSectionType.extensions => l10n.menu_sectionExtensions,
      MenuSectionType.tabActions => l10n.menu_sectionTabActions,
      MenuSectionType.quickLinks => l10n.menu_sectionQuickLinks,
      MenuSectionType.connection => l10n.menu_sectionConnection,
      MenuSectionType.profile => l10n.menu_sectionProfile,
      MenuSectionType.about => l10n.menu_sectionAbout,
    };
  }
}

/// Display labels + descriptions for [MenuItemType].
extension MenuItemTypeL10n on MenuItemType {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      MenuItemType.desktopMode => l10n.menu_itemDesktopMode,
      MenuItemType.readerMode => l10n.menu_itemReaderMode,
      MenuItemType.gestures => l10n.menu_itemGestures,
      MenuItemType.addBookmark => l10n.menu_itemAddBookmark,
      MenuItemType.findInPage => l10n.menu_itemFindInPage,
      MenuItemType.translatePage => l10n.menu_itemTranslatePage,
      MenuItemType.addToHomeScreen => l10n.menu_itemAddToHomeScreen,
      MenuItemType.openInApp => l10n.menu_itemOpenInApp,
      MenuItemType.containers => l10n.menu_itemContainers,
      MenuItemType.manageContainers => l10n.menu_itemManageContainers,
      MenuItemType.assignContainer => l10n.menu_itemAssignContainer,
      MenuItemType.assignUrlToContainer => l10n.menu_itemAssignUrlToContainer,
      MenuItemType.unassignUrlFromContainer =>
        l10n.menu_itemUnassignUrlFromContainer,
      MenuItemType.unassignContainer => l10n.menu_itemUnassignContainer,
      MenuItemType.share => l10n.menu_itemShare,
      MenuItemType.copyAddress => l10n.menu_itemCopyAddress,
      MenuItemType.shareScreenshot => l10n.menu_itemShareScreenshot,
      MenuItemType.shareLink => l10n.menu_itemShareLink,
      MenuItemType.sendToDevice => l10n.menu_itemSendToDevice,
      MenuItemType.showQrCode => l10n.menu_itemShowQrCode,
      MenuItemType.moreDisclosure => l10n.menu_itemMoreDisclosure,
      MenuItemType.cloneTab => l10n.menu_itemCloneTab,
      MenuItemType.cloneRegularTab => l10n.menu_itemCloneRegularTab,
      MenuItemType.clonePrivateTab => l10n.menu_itemClonePrivateTab,
      MenuItemType.cloneIsolatedTab => l10n.menu_itemCloneIsolatedTab,
      MenuItemType.export => l10n.menu_itemExport,
      MenuItemType.copyAsMarkdown => l10n.menu_itemCopyAsMarkdown,
      MenuItemType.exportAsMarkdown => l10n.menu_itemExportAsMarkdown,
      MenuItemType.exportAsPdf => l10n.menu_itemExportAsPdf,
      MenuItemType.exportAsPng => l10n.menu_itemExportAsPng,
      MenuItemType.printPage => l10n.menu_itemPrintPage,
      MenuItemType.pinTopSite => l10n.menu_itemPinTopSite,
      MenuItemType.fetchFeeds => l10n.menu_itemFetchFeeds,
      MenuItemType.history => l10n.menu_itemHistory,
      MenuItemType.bookmarks => l10n.menu_itemBookmarks,
      MenuItemType.downloads => l10n.menu_itemDownloads,
      MenuItemType.bangs => l10n.menu_itemBangs,
      MenuItemType.feeds => l10n.menu_itemFeeds,
      MenuItemType.smallWeb => l10n.menu_itemSmallWeb,
      MenuItemType.clearData => l10n.menu_itemClearData,
      MenuItemType.profileSwitch => l10n.menu_itemProfileSwitch,
      MenuItemType.syncNow => l10n.menu_itemSyncNow,
      MenuItemType.appSettings => l10n.menu_itemAppSettings,
      MenuItemType.quitBrowser => l10n.menu_itemQuitBrowser,
      MenuItemType.about => l10n.menu_itemAbout,
    };
  }

  /// Shown under the label while arranging, for rows whose behaviour is not
  /// obvious from the name alone.
  String? description(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      MenuItemType.moreDisclosure => l10n.menu_itemMoreDisclosureDescription,
      MenuItemType.sendToDevice => l10n.menu_itemSendToDeviceDescription,
      _ => null,
    };
  }
}
