/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPref
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.ExperimentalAndroidComponentsApi
import mozilla.components.concept.engine.preferences.Branch
import mozilla.components.concept.engine.preferences.BrowserPrefObserverDelegate
import mozilla.components.concept.engine.preferences.BrowserPreference
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class GeckoPrefApiImpl : GeckoPrefApi, BrowserPrefObserverDelegate {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override suspend fun getPrefs(preferenceFilter: List<String>): Map<String, GeckoPref> =
        suspendCancellableCoroutine { continuation ->
            components.core.engine.getBrowserPrefs(
                preferenceFilter, onSuccess = { prefs ->
                    continuation.resume(
                        prefs.associate {
                            it.pref to GeckoPref(
                                name = it.pref,
                                value = it.value,
                                defaultValue = it.defaultValue,
                                userValue = it.userValue,
                                hasUserChangedValue = it.hasUserChangedValue,
                            )
                        })
                },
                onError = {
                    continuation.resumeWithException(Exception("${it.message} ${it.cause}"))
                }
            )
        }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override suspend fun applyPrefs(prefs: Map<String, Any>): Map<String, GeckoPref> {
        if (prefs.isEmpty()) {
            return emptyMap()
        }

        for ((name, value) in prefs) {
            setPref(name, value)
        }

        return getPrefs(prefs.keys.toList())
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    private suspend fun setPref(name: String, value: Any) {
        suspendCancellableCoroutine<Unit> { continuation ->
            val onSuccess = { continuation.resume(Unit) }
            val onError = { e: Throwable ->
                continuation.resumeWithException(Exception("${e.message} ${e.cause}"))
            }

            when (value) {
                is String -> components.core.engine.setBrowserPref(
                    name,
                    value,
                    Branch.USER,
                    onSuccess = onSuccess,
                    onError = onError
                )

                is Boolean -> components.core.engine.setBrowserPref(
                    name,
                    value,
                    Branch.USER,
                    onSuccess = onSuccess,
                    onError = onError
                )

                is Long -> components.core.engine.setBrowserPref(
                    name,
                    value.toInt(),
                    Branch.USER,
                    onSuccess = onSuccess,
                    onError = onError
                )

                else -> {
                    continuation.resumeWithException(
                        Exception("Unsupported value type: ${value::class.simpleName}")
                    )
                }
            }
        }
    }

    @OptIn(ExperimentalAndroidComponentsApi::class)
    override suspend fun resetPrefs(preferenceNames: List<String>) {
        for (pref in preferenceNames) {
            suspendCancellableCoroutine<Unit> { continuation ->
                components.core.engine.clearBrowserUserPref(
                    pref = pref,
                    onSuccess = { continuation.resume(Unit) },
                    onError = {
                        continuation.resumeWithException(Exception("${it.message} ${it.cause}"))
                    }
                )
            }
        }
    }

    override fun startObserveChanges() {
        components.core.engine.registerPrefObserverDelegate(this);
    }

    override fun stopObserveChanges() {
        components.core.engine.unregisterPrefObserverDelegate();
    }

    override suspend fun registerPrefForObservation(name: String) {
        suspendCancellableCoroutine<Unit> { continuation ->
            components.core.engine.registerPrefForObservation(
                name,
                onSuccess = {
                    continuation.resume(Unit)
                },
                onError = {
                    continuation.resumeWithException(Exception("${it.message} ${it.cause}"))
                })
        }
    }

    override suspend fun unregisterPrefForObservation(name: String) {
        suspendCancellableCoroutine<Unit> { continuation ->
            components.core.engine.unregisterPrefForObservation(
                name,
                onSuccess = {
                    continuation.resume(Unit)
                },
                onError = {
                    continuation.resumeWithException(Exception("${it.message} ${it.cause}"))
                })
        }
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
