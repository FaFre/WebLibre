package eu.weblibre.flutter_mozilla_components.activities

import mozilla.components.concept.sync.AccountObserver
import mozilla.components.concept.sync.AuthType
import mozilla.components.concept.sync.OAuthAccount
import eu.weblibre.flutter_mozilla_components.GlobalComponents

class AuthCustomTabActivity : ExternalAppBrowserActivity() {
    private val accountStateObserver = object : AccountObserver {
        override fun onAuthenticated(account: OAuthAccount, authType: AuthType) {
            finish()
        }
    }

    override fun onResume() {
        super.onResume()
        GlobalComponents.components
            ?.backgroundServices
            ?.accountManager
            ?.register(accountStateObserver, this, true)
    }

    override fun onDestroy() {
        GlobalComponents.components
            ?.backgroundServices
            ?.accountManager
            ?.unregister(accountStateObserver)
        super.onDestroy()
    }
}
