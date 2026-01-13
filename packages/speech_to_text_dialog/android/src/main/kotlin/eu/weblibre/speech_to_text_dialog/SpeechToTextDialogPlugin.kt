/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
package eu.weblibre.speech_to_text_dialog

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.speech.RecognizerIntent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry
import eu.weblibre.speech_to_text_dialog.pigeons.SpeechToTextApi as PigeonSpeechToTextApi
import eu.weblibre.speech_to_text_dialog.pigeons.SpeechToTextEvents
import java.util.Locale

/// Plugin implementation for speech recognition dialog.
///
/// This plugin integrates Android's RecognizerIntent to provide
/// speech-to-text functionality to Flutter apps.
class SpeechToTextDialogPlugin : FlutterPlugin, ActivityAware,
    PluginRegistry.ActivityResultListener {

    companion object {
        private const val REQ_CODE_SPEECH_INPUT = 120752
    }

    private var activity: Activity? = null
    private var speechApiHost: SpeechApiHost? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        speechApiHost = SpeechApiHost(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        speechApiHost?.release()
        speechApiHost = null
    }

    override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQ_CODE_SPEECH_INPUT) {
            speechApiHost?.handleActivityResult(resultCode, data)
            return true
        }
        return false
    }

    /// Show the speech recognition dialog.
    ///
    /// @param locale The locale string (e.g., "en-US", "de-DE") or null for device default.
    /// @return true if the dialog was shown successfully, false otherwise.
    fun showSpeechDialog(locale: String?): Boolean {
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE,
                locale?.let { Locale(it) } ?: Locale.getDefault()
            )
            putExtra(RecognizerIntent.EXTRA_PROMPT, "Speak")
        }

        return try {
            activity?.startActivityForResult(intent, REQ_CODE_SPEECH_INPUT)
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }
}

/// Host API implementation that handles Flutter-to-Android calls.
class SpeechApiHost(
    private val messenger: BinaryMessenger,
    private val plugin: SpeechToTextDialogPlugin
) {
    private val events: SpeechToTextEvents = SpeechToTextEvents(messenger)

    init {
        // Set up the API handler
        PigeonSpeechToTextApi.setUp(messenger, object : PigeonSpeechToTextApi {
            override fun showDialog(locale: String?): Boolean {
                return plugin.showSpeechDialog(locale)
            }
        })
    }

    /// Handle the result from the speech recognition activity.
    fun handleActivityResult(resultCode: Int, data: Intent?) {
        sendResult(resultCode, data)
    }

    private fun sendResult(resultCode: Int, data: Intent?) {
        val text = if (resultCode == Activity.RESULT_OK && data != null) {
            val result = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            if (!result.isNullOrEmpty()) {
                result[0]
            } else {
                ""
            }
        } else {
            // User cancelled or recognition failed
            ""
        }

        events.onTextReceived(text) { }
    }

    fun release() {
        PigeonSpeechToTextApi.setUp(messenger, null)
    }
}
