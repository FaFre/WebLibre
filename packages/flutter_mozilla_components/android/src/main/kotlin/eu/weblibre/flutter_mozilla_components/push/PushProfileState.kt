/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.push

import android.content.Context
import android.content.SharedPreferences
import org.ironfoxoss.unifiedpush.PushError
import org.ironfoxoss.unifiedpush.SubscriptionsDB
import org.unifiedpush.android.connector.data.PushEndpoint

internal object PushProfileState {
    private const val PREFS_NAME = "weblibre_push"
    const val KEY_SELECTED_DISTRIBUTOR = "selected_distributor"
    private const val KEY_LAST_ERROR = "last_error"
    private const val KEY_LAST_ERROR_SCOPE = "last_error_scope"
    private const val KEY_LAST_ERROR_TYPE = "last_error_type"

    fun lastError(context: Context): String? = prefs(context).getString(KEY_LAST_ERROR, null)

    fun recordTemporaryUnavailable(context: Context, scope: String) {
        recordError(
            context,
            scope,
            "temporary_unavailable",
            "Push service is temporarily unavailable",
        )
    }

    fun recordError(context: Context, scope: String, type: String, message: String) {
        prefs(context).edit()
            .putString(KEY_LAST_ERROR, message)
            .putString(KEY_LAST_ERROR_SCOPE, scope)
            .putString(KEY_LAST_ERROR_TYPE, type)
            .commit()
    }

    fun clearError(context: Context, scope: String? = null) {
        val prefs = prefs(context)
        if (scope != null && prefs.getString(KEY_LAST_ERROR_SCOPE, null) != scope) return
        prefs.edit()
            .remove(KEY_LAST_ERROR)
            .remove(KEY_LAST_ERROR_SCOPE)
            .remove(KEY_LAST_ERROR_TYPE)
            .commit()
    }

    fun updateEndpoint(context: Context, scope: String, endpoint: PushEndpoint): Boolean {
        val keys = endpoint.pubKeySet ?: return false
        SubscriptionsDB(context).use { db ->
            db.updateEndpoint(scope, endpoint.url, keys.pubKey, keys.auth)
        }
        clearError(context, scope)
        return true
    }

    fun removeEndpoint(context: Context, scope: String) {
        SubscriptionsDB(context).use { it.removeEndpoint(scope) }
        clearError(context, scope)
    }

    fun errorType(error: PushError): String = when (error) {
        is PushError.DB -> "database"
        is PushError.Network -> "network"
        is PushError.Registration -> "registration"
        is PushError.ServiceUnavailable -> "service_unavailable"
    }

    fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
