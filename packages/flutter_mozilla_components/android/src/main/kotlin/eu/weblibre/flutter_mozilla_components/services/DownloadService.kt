/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.downloads.AbstractFetchDownloadService
import mozilla.components.feature.downloads.DateTimeProvider
import mozilla.components.feature.downloads.DownloadEstimator
import mozilla.components.feature.downloads.FileSizeFormatter
import mozilla.components.support.base.android.NotificationsDelegate

class DownloadService : AbstractFetchDownloadService() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override val httpClient by lazy { components.core.client }
    override val store: BrowserStore by lazy { components.core.store }
    override val notificationsDelegate: NotificationsDelegate by lazy { components.notificationsDelegate }
    override val dateTimeProvider: DateTimeProvider by lazy { components.dateTimeProvider }
    override val fileSizeFormatter: FileSizeFormatter by lazy { components.fileSizeFormatter }
    //override val downloadEstimator: DownloadEstimator by lazy { components.downloadEstimator }
}