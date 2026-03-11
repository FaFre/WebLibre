/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.feature.PrefManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPref
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.concept.engine.preferences.BrowserPrefObserverDelegate
import mozilla.components.concept.engine.preferences.BrowserPreference
import mozilla.components.support.ktx.android.org.json.toList
import org.json.JSONObject
import org.json.JSONArray

class GeckoPrefApiImpl : GeckoPrefApi, BrowserPrefObserverDelegate {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private fun List<String>?.toJson(): JSONArray {
        return JSONArray().apply {
            this@toJson?.forEach { put(it) }
        }
    }

    fun JSONObject.toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = this.keys()

        while (keys.hasNext()) {
            val key = keys.next()
            when (val value = this.get(key)) {
                is JSONObject -> map[key] = value.toMap()
//                is JSONArray -> map[key] = value.toList()
//                JSONObject.NULL -> map[key] = null
                else -> map[key] = value
            }
        }

        return map
    }

    override fun getPrefList(callback: (Result<List<String>>) -> Unit) {
        PrefManagerFeature.scheduleRequest(
            "getPrefList",
            Unit,
            object : ResultConsumer<JSONObject> {
                override fun success(result: JSONObject) {
                    callback(Result.success(result.getJSONArray("result").toList()))
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
                }
            })
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override fun getPrefs(
        preferenceFilter: List<String>,
        callback: (Result<Map<String, GeckoPref>>) -> Unit
    ) {
        components.core.engine.getBrowserPrefs(
            preferenceFilter, onSuccess = {
                callback(
                    Result.success(
                        it.associate {
                            it.pref to GeckoPref(
                                name = it.pref,
                                value = it.value,
                                defaultValue = it.defaultValue,
                                userValue = it.userValue,
                                hasUserChangedValue = it.hasUserChangedValue,
                            )
                        })
                )
            },
            onError = {
                callback(Result.failure(Exception("${it.message} ${it.cause}")))
            }
        )
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override fun applyPrefs(
        prefs: Map<String, Any>,
        callback: (Result<Map<String, GeckoPref>>) -> Unit
    ) {
        if (prefs.isEmpty()) {
            callback(Result.success(emptyMap()))
            return
        }

        val entries = prefs.entries.toList()

        fun applyNext(index: Int) {
            if (index >= entries.size) {
                getPrefs(prefs.keys.toList(), callback = callback)
                return
            }

            val pref = entries[index]

            fun onSuccess() = applyNext(index + 1)
            fun onError(e: Exception) = callback(Result.failure(e))

            when (pref.value) {
                is String -> components.core.engine.setBrowserPref(
                    pref.key,
                    pref.value as String,
                    Branch.USER,
                    onSuccess = { onSuccess() },
                    onError = { onError(Exception("${it.message} ${it.cause}")) }
                )

                is Boolean -> components.core.engine.setBrowserPref(
                    pref.key,
                    pref.value as Boolean,
                    Branch.USER,
                    onSuccess = { onSuccess() },
                    onError = { onError(Exception("${it.message} ${it.cause}")) }
                )

                is Long -> components.core.engine.setBrowserPref(
                    pref.key,
                    (pref.value as Long).toInt(),
                    Branch.USER,
                    onSuccess = { onSuccess() },
                    onError = { onError(Exception("${it.message} ${it.cause}")) }
                )

                else -> {
                    onError(Exception("Unsupported value type: ${pref.value::class.simpleName}"))
                }
            }
        }

        applyNext(0)
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override fun resetPrefs(preferenceNames: List<String>, callback: (Result<Unit>) -> Unit) {
        if (preferenceNames.isEmpty()) {
            callback(Result.success(Unit))
            return
        }

        fun resetNext(index: Int) {
            if (index >= preferenceNames.size) {
                callback(Result.success(Unit))
                return
            }

            components.core.engine.clearBrowserUserPref(
                pref = preferenceNames[index],
                onSuccess = { resetNext(index + 1) },
                onError = {
                    callback(Result.failure(Exception("${it.message} ${it.cause}")))
                }
            )
        }

        resetNext(0)
    }

    override fun startObserveChanges() {
        components.core.engine.registerPrefObserverDelegate(this);
    }

    override fun stopObserveChanges() {
        components.core.engine.unregisterPrefObserverDelegate();
    }

    override fun registerPrefForObservation(name: String, callback: (Result<Unit>) -> Unit) {
        components.core.engine.registerPrefForObservation(
            name,
            onSuccess = {
                callback(Result.success(Unit))
            },
            onError = {
                callback(Result.failure(Exception("${it.message} ${it.cause}")))
            })
    }

    override fun unregisterPrefForObservation(name: String, callback: (Result<Unit>) -> Unit) {
        components.core.engine.unregisterPrefForObservation(
            name,
            onSuccess = {
                callback(Result.success(Unit))
            },
            onError = {
                callback(Result.failure(Exception("${it.message} ${it.cause}")))
            })
    }

    override fun onPreferenceChange(observedPreference: BrowserPreference<*>) {
        components.flutterEvents.onPreferenceChange(
            EventSequence.next(), GeckoPref(
                name = observedPreference.pref,
                value = observedPreference.value,
                defaultValue = observedPreference.defaultValue,
                userValue = observedPreference.userValue,
                hasUserChangedValue = observedPreference.hasUserChangedValue,
            )
        ) { _ -> }
    }
}