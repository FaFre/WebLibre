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

import java.security.MessageDigest
import org.ironfoxoss.unifiedpush.AutoPushSubscription
import org.ironfoxoss.unifiedpush.SubscriptionsDB

/**
 * Names what a subscription row says to a site: its endpoint and keys.
 *
 * `PushOutbox` keeps it beside a pending change so that only a handoff of that
 * same state can clear it. A hash, so the outbox never holds an endpoint or a key.
 */
internal object SubscriptionVersion {
    /** A row with no endpoint: nothing a site could still push to. */
    const val NONE = "none"

    fun of(endpoint: String?, publicKey: String?, authKey: String?): String {
        if (endpoint == null) return NONE
        val digest = MessageDigest.getInstance("SHA-256")
            .digest("$endpoint\u0000${publicKey.orEmpty()}\u0000${authKey.orEmpty()}".toByteArray())
        return digest.toHexString()
    }

    fun of(row: SubscriptionsDB.Subscription?): String =
        of(row?.endpoint, row?.publicKey, row?.authKey)

    fun of(subscription: AutoPushSubscription): String =
        of(subscription.endpoint, subscription.publicKey, subscription.authKey)
}
