/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.PrefManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefValue
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.support.ktx.android.org.json.toList
import org.json.JSONObject
import org.json.JSONArray

class GeckoPrefApiImpl : GeckoPrefApi {
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
        PrefManagerFeature.scheduleRequest("getPrefList", Unit, object : ResultConsumer<JSONObject> {
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
        callback: (Result<Map<String, GeckoPrefValue>>) -> Unit
    ) {
        components.core.engine.getBrowserPrefs(
            preferenceFilter, onSuccess = {
                callback(
                    Result.success(
                        it.associate {
                            it.pref to GeckoPrefValue(
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
        callback: (Result<Map<String, GeckoPrefValue>>) -> Unit
    ) {
        var fault: Boolean = false;

        for (pref in prefs) {
            when (pref.value) {
                is String -> components.core.engine.setBrowserPref(
                    pref.key,
                    pref.value as String,
                    Branch.USER,
                    onSuccess = {},
                    onError = {
                        callback(Result.failure(Exception("${it.message} ${it.cause}")))
                        fault = true
                    }
                )

                is Boolean -> components.core.engine.setBrowserPref(
                    pref.key,
                    pref.value as Boolean,
                    Branch.USER,
                    onSuccess = {},
                    onError = {
                        callback(Result.failure(Exception("${it.message} ${it.cause}")))
                        fault = true
                    }
                )

                is Long -> components.core.engine.setBrowserPref(
                    pref.key,
                    (pref.value as Long).toInt(),
                    Branch.USER,
                    onSuccess = {},
                    onError = {
                        callback(Result.failure(Exception("${it.message} ${it.cause}")))
                        fault = true
                    }
                )

                else -> {
                    callback(Result.failure(Exception("Unsupported value type: ${pref.value::class.simpleName}")))
                    fault = true
                }
            }

            if (fault) {
                return;
            }
        }

        getPrefs(
            prefs.keys.toList(),
            callback = callback
        )
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override fun resetPrefs(preferenceNames: List<String>, callback: (Result<Unit>) -> Unit) {
        var fault: Boolean = false;

        for (pref in preferenceNames) {
            components.core.engine.clearBrowserUserPref(
                pref = pref,
                onSuccess = {},
                onError = {
                    callback(Result.failure(Exception("${it.message} ${it.cause}")))
                    fault = true
                }
            )

            if (fault) {
                return;
            }
        }
    }
}