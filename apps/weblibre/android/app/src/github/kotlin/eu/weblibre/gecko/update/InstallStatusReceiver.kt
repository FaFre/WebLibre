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
package eu.weblibre.gecko.update

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build

/**
 * Receives the status of our install sessions (plan 7.5). Not exported: only
 * the explicit [android.app.PendingIntent] created by [SessionInstaller]
 * reaches it, and every callback is correlated with the journal's session ID
 * and nonce before it changes anything.
 */
class InstallStatusReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) return
        val sessionId = intent.getIntExtra(PackageInstaller.EXTRA_SESSION_ID, -1)
        if (sessionId < 0) return

        val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
        val confirmation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_INTENT)
        }

        SessionInstaller.shared(context).onStatus(
            sessionId = sessionId,
            nonce = intent.getStringExtra(EXTRA_NONCE),
            status = status,
            legacyStatus = if (intent.hasExtra(EXTRA_LEGACY_STATUS)) intent.getIntExtra(EXTRA_LEGACY_STATUS, 0) else null,
            message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE),
            confirmation = confirmation,
        )
    }

    companion object {
        const val ACTION = "eu.weblibre.gecko.update.INSTALL_STATUS"
        const val EXTRA_NONCE = "eu.weblibre.gecko.update.NONCE"

        /**
         * `PackageInstaller.EXTRA_LEGACY_STATUS`, a `@SystemApi` constant the
         * public SDK doesn't expose: the internal `INSTALL_FAILED_*` code
         * behind [PackageInstaller.EXTRA_STATUS], which tells a declined
         * confirmation from a verifier's rejection (both `STATUS_FAILURE_ABORTED`).
         */
        const val EXTRA_LEGACY_STATUS = "android.content.pm.extra.LEGACY_STATUS"
    }
}
