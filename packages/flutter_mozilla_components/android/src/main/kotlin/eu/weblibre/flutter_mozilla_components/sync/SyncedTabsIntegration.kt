package eu.weblibre.flutter_mozilla_components.sync

import mozilla.components.concept.sync.AccountObserver
import mozilla.components.concept.sync.AuthType
import mozilla.components.concept.sync.OAuthAccount
import mozilla.components.feature.syncedtabs.storage.SyncedTabsStorage
import mozilla.components.service.fxa.manager.FxaAccountManager

/**
 * Starts and stops SyncedTabsStorage based on the authentication state.
 *
 * [syncedTabsStorage] is a provider rather than an instance because this is
 * constructed from inside the `accountManager` lazy initializer, and the storage's
 * own initializer reads that same account manager. Resolving it eagerly would
 * re-enter a `lazy` that is still running.
 */
class SyncedTabsIntegration(
    private val accountManager: FxaAccountManager,
    private val syncedTabsStorage: () -> SyncedTabsStorage,
) {
    fun launch() {
        accountManager.register(SyncedTabsAccountObserver(syncedTabsStorage))

        if (accountManager.authenticatedAccount() != null) {
            syncedTabsStorage().start()
        }
    }
}

internal class SyncedTabsAccountObserver(
    private val syncedTabsStorage: () -> SyncedTabsStorage,
) : AccountObserver {
    override fun onAuthenticated(account: OAuthAccount, authType: AuthType) {
        syncedTabsStorage().start()
    }

    override fun onLoggedOut() {
        syncedTabsStorage().stop()
    }
}
