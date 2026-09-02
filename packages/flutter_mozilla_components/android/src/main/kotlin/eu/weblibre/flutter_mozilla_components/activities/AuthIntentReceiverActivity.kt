package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import mozilla.components.feature.customtabs.CustomTabIntentProcessor
import mozilla.components.feature.intent.ext.getSessionId
import eu.weblibre.flutter_mozilla_components.GlobalComponents

class AuthIntentReceiverActivity : Activity() {
    companion object {
        private const val TAG = "AuthIntentReceiver"
        private const val PRIVATE_BROWSING_MODE = "private_browsing_mode"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sourceIntent = intent?.let { Intent(it) } ?: Intent()

        // Stamp the caller before CustomTabIntentProcessor builds the session source, so the
        // app-links authentication carve-out can recognise a sign-in callback for this tab.
        addExternalCallerInformation(sourceIntent)

        // FxA callbacks belong to a profile that is already signed in, so this is
        // never a place to *choose* one. Without a committed profile — during
        // selection, maintenance, or a restart — the only safe answer is to refuse
        // and let the user retry from the browser.
        if (GlobalComponents.components == null && !GlobalComponents.ensureExternalComponents(applicationContext)) {
            finish()
            return
        }

        val components = GlobalComponents.components
        if (components == null) {
            finish()
            return
        }

        val processed = CustomTabIntentProcessor(
            components.useCases.customTabsUseCases.add,
            resources,
            isPrivate = sourceIntent.getBooleanExtra(PRIVATE_BROWSING_MODE, false),
        ).process(sourceIntent)

        if (processed) {
            val sessionId = sourceIntent.getSessionId() ?: components.core.store.state.customTabs.lastOrNull()?.id
            if (sessionId != null) {
                val authIntent = ExternalAppBrowserActivity
                    .createIntent(
                        context = this,
                        customTabSessionId = sessionId,
                        isPrivate = sourceIntent.getBooleanExtra(PRIVATE_BROWSING_MODE, false),
                    )
                    .setClassName(this, AuthCustomTabActivity::class.java.name)
                startActivity(authIntent)
            } else {
                Log.w(TAG, "Auth intent processed but no custom tab session id found")
            }
        } else {
            Log.w(TAG, "Auth custom tab intent was not processed")
        }

        finish()
    }
}
