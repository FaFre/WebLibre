package eu.weblibre.flutter_mozilla_components.activities

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import eu.weblibre.flutter_mozilla_components.GlobalComponents

class NotificationActivity: AppCompatActivity() {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        components.notificationsDelegate.bindToActivity(this)

        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        components.notificationsDelegate.unBindActivity(this)
    }
}