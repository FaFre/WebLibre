/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Context
import androidx.core.app.NotificationManagerCompat
import eu.weblibre.flutter_mozilla_components.components.Core
import eu.weblibre.flutter_mozilla_components.components.BackgroundServices
import eu.weblibre.flutter_mozilla_components.components.Events
import eu.weblibre.flutter_mozilla_components.components.Features
import eu.weblibre.flutter_mozilla_components.components.Search
import eu.weblibre.flutter_mozilla_components.components.Services
import eu.weblibre.flutter_mozilla_components.components.UseCases
import eu.weblibre.flutter_mozilla_components.pigeons.AddonCollection
import eu.weblibre.flutter_mozilla_components.pigeons.BrowserExtensionEvents
import eu.weblibre.flutter_mozilla_components.pigeons.ContentBlocking
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAddonEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoSyncStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTabContentEvents
import eu.weblibre.flutter_mozilla_components.pigeons.ReaderViewController
import mozilla.components.concept.engine.EngineView
import mozilla.components.concept.engine.selection.SelectionActionDelegate
import mozilla.components.feature.downloads.DateTimeProvider
import mozilla.components.feature.downloads.DefaultDateTimeProvider
import mozilla.components.feature.downloads.DefaultFileSizeFormatter
import mozilla.components.feature.downloads.DownloadEstimator
import mozilla.components.feature.downloads.FileSizeFormatter
import mozilla.components.support.base.android.NotificationsDelegate
import mozilla.components.support.base.log.Log

class Components(val profileApplicationContext: ProfileContext,
                 val flutterEvents: GeckoStateEvents,
                 val readerViewController: ReaderViewController,
                 val selectionAction: SelectionActionDelegate,
                 val logLevel: Log.Priority,
                 val contentBlocking: ContentBlocking,
                 val addonCollection: AddonCollection?,
                 val fxaServerOverride: String?,
                 val syncTokenServerOverride: String?,
                 val addonEvents: GeckoAddonEvents,
                 private val tabContentEvents: GeckoTabContentEvents,
                 private val extensionEvents: BrowserExtensionEvents,
                 private val syncStateEvents: GeckoSyncStateEvents?,
) {
    val core by lazy { Core(profileApplicationContext, this, flutterEvents, extensionEvents) }
    val backgroundServices by lazy {
        BackgroundServices(
            context = profileApplicationContext,
            browserStore = lazy { core.store },
            historyStorage = core.lazyHistoryStorage,
            bookmarkStorage = core.lazyBookmarksStorage,
            remoteTabsStorage = core.lazyRemoteTabsStorage,
            fxaServerOverride = fxaServerOverride,
            syncTokenServerOverride = syncTokenServerOverride,
            syncStateEvents = syncStateEvents,
        )
    }
    val events by lazy { Events(flutterEvents) }
    val useCases by lazy { UseCases(profileApplicationContext, core.engine, core.store, core.webAppShortcutManager) }
    val services by lazy {
        Services(
            profileApplicationContext,
            core.store,
            useCases.tabsUseCases,
            backgroundServices.accountManager,
            core.engine,
            backgroundServices.serverConfig,
        )
    }
    val features by lazy { Features(core.engine, core.store, addonEvents, tabContentEvents) }
    val search by lazy { Search(profileApplicationContext, core, useCases) }

    var mainBrowserEngineView: EngineView? = null
    var externalAppEngineView: EngineView? = null

    var activeEngineView: EngineView? = null
    
    var engineReportedInitialized = false

    private val notificationManagerCompat = NotificationManagerCompat.from(profileApplicationContext)
    val notificationsDelegate: NotificationsDelegate by lazy {
        NotificationsDelegate(
            notificationManagerCompat,
        )
    }

    val fileSizeFormatter: FileSizeFormatter by lazy { DefaultFileSizeFormatter(profileApplicationContext) }

    val dateTimeProvider: DateTimeProvider by lazy { DefaultDateTimeProvider() }

    val downloadEstimator: DownloadEstimator by lazy { DownloadEstimator(dateTimeProvider = dateTimeProvider) }
}
