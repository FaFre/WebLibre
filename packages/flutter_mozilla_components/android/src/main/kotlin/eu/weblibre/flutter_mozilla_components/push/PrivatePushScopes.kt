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

/**
 * Private browsing gets no push.
 *
 * A subscription would outlive the private session: GeckoView's push service
 * ignores Gecko's clearing of private data (its `clearForDomain` and
 * `clearForPrincipal` answer without doing anything). Its row and keys would
 * stay on disk and its registration at the distributor, renewed on every start,
 * and the site would get the same endpoint back in the next private session,
 * which links the two.
 *
 * Gecko already refuses a private subscription while
 * `dom.webnotifications.privateBrowsing.enabled` is off (the engine baseline in
 * `settings.json`). The web push delegate refuses one regardless of that pref,
 * the renewal never registers one, and each start removes any that a build
 * without this check created ([PrivateSubscriptionCleanup]).
 */
internal object PrivatePushScopes {
    private const val PRIVATE_BROWSING_ID = "privateBrowsingId"

    /**
     * Whether [scope] belongs to private browsing.
     *
     * GeckoView appends the origin attributes to every scope as a suffix
     * (`^name=value&…`, see [PushContextGate]), which names `privateBrowsingId`
     * only when it is not 0. GeckoView's only public reader of that suffix,
     * `StorageController.sessionContextIdFromOriginSuffix`, returns the session
     * context and nothing else, so this reads the suffix the same way for the
     * other attribute.
     *
     * The scope is the only thing GeckoView hands over: no private flag
     * reaches the delegate. A scope with no attributes has no suffix, and a
     * caret in its query is kept, so a regular scope `…/sw/?x^privateBrowsingId=1`
     * reads as private. It is the very string the private scope of `…/sw/?x`
     * is, which GeckoView keys one subscription by for both. Only the site
     * that registers such a scope can make one, and it loses push only for
     * itself: refused, the safe way for a key that may be private.
     */
    fun isPrivate(scope: String): Boolean {
        val caret = scope.lastIndexOf('^')
        if (caret < 0) return false
        return scope.substring(caret + 1).split('&').any { param ->
            val equals = param.indexOf('=')
            equals >= 0 &&
                param.substring(0, equals) == PRIVATE_BROWSING_ID &&
                param.substring(equals + 1).let { it.isNotEmpty() && it != "0" }
        }
    }
}
