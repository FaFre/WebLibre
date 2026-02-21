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
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sourceIntent = intent?.let { Intent(it) } ?: Intent()

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
            isPrivate = false,
        ).process(sourceIntent)

        if (processed) {
            val sessionId = sourceIntent.getSessionId() ?: components.core.store.state.customTabs.lastOrNull()?.id
            if (sessionId != null) {
                val authIntent = ExternalAppBrowserActivity
                    .createIntent(this, sessionId)
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
