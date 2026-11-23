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
package eu.weblibre.flutter_mozilla_components.push

import android.app.Activity
import android.content.Context
import org.ironfoxoss.unifiedpush.DistributorManager
import org.ironfoxoss.unifiedpush.PushScope

/**
 * The connector calls [org.ironfoxoss.unifiedpush.UnifiedPushFeature] makes for
 * Gecko's subscribe and unsubscribe, moved onto the receiver's executor so they
 * run between broadcasts rather than beside one.
 *
 * Queued, never awaited: the feature calls them from `Push`'s dispatcher, which
 * the receiver's executor may itself be waiting for. Each call is one task, in
 * the order the feature made them. Nothing the feature does reads a result.
 */
internal class ExclusiveDistributorManager(
    private val delegate: DistributorManager,
) : DistributorManager {
    override fun registerScope(context: Context, scope: PushScope, appServerKey: String?) =
        UnifiedPushReceiver.submitExclusive { delegate.registerScope(context, scope, appServerKey) }

    override fun unregisterScope(context: Context, scope: PushScope) =
        UnifiedPushReceiver.submitExclusive { delegate.unregisterScope(context, scope) }

    override fun registerDefaultRegistration(context: Context) =
        UnifiedPushReceiver.submitExclusive { delegate.registerDefaultRegistration(context) }

    override fun removeCurrentDistributor(context: Context) =
        UnifiedPushReceiver.submitExclusive { delegate.removeCurrentDistributor(context) }

    // A status getter that changes connector state, and nothing of ours asks
    // the feature for it: `Push.status()` reads it on the executor itself.
    override fun isAvailable(context: Context): Boolean =
        throw UnsupportedOperationException("Read the distributor through Push.status()")

    // The connector's picker saves the choice through the Activity's context,
    // outside the profile, where no profile ever reads it. WebLibre's picker
    // is in Dart and saves through `Push.setDistributor`.
    override fun useDefaultDistributor(activity: Activity, callback: (Boolean) -> Unit) =
        throw UnsupportedOperationException("Choose the distributor through Push.setDistributor")

    override fun pickDistributor(activity: Activity, callback: (Boolean) -> Unit) =
        throw UnsupportedOperationException("Choose the distributor through Push.setDistributor")
}
