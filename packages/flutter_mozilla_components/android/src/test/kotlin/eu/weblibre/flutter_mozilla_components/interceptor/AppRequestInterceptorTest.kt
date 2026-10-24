/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.interceptor

import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.applinks.WebLibreAppLinksInterceptor
import eu.weblibre.flutter_mozilla_components.components.Core
import eu.weblibre.flutter_mozilla_components.components.Services
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.request.RequestInterceptor
import mozilla.components.feature.accounts.FirefoxAccountsAuthFeature
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

/**
 * The engine tells the interceptor whether a load targets a new window only through the 9-argument
 * overload (the WebLibre AC patch). Whether a link's in-browser answer opens a new tab or replaces
 * the opener's page hangs on that flag reaching the app-link tail.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AppRequestInterceptorTest {
    private val engineSession = mock(EngineSession::class.java)
    private val appLinks = mock(WebLibreAppLinksInterceptor::class.java)
    private lateinit var interceptor: AppRequestInterceptor

    @Before
    fun setUp() {
        // Plain mocks, not deep stubs: those would try to mock the BrowserStore, which AC forbids.
        val core = mock(Core::class.java)
        `when`(core.store).thenReturn(BrowserStore(BrowserState()))
        // No FxA sign-in in flight: the accounts interceptor answers nothing.
        val accountsAuthFeature = mock(FirefoxAccountsAuthFeature::class.java)
        `when`(accountsAuthFeature.interceptor).thenReturn(object : RequestInterceptor {})
        val services = mock(Services::class.java)
        `when`(services.accountsAuthFeature).thenReturn(accountsAuthFeature)
        val components = mock(Components::class.java)
        `when`(components.core).thenReturn(core)
        `when`(components.services).thenReturn(services)

        interceptor = AppRequestInterceptor(
            RuntimeEnvironment.getApplication(),
            componentsProvider = { components },
            appLinksProvider = { appLinks },
        )
    }

    @Test
    fun aNewWindowLoadReachesTheAppLinkTailAsOne() {
        load(isNewWindowRequest = true)

        verify(appLinks).onLoadRequest(
            engineSession, URL, LAST_URL, true, false, false, false, true,
        )
    }

    @Test
    fun aLoadInPlaceReachesTheAppLinkTailAsOne() {
        load(isNewWindowRequest = false)

        verify(appLinks).onLoadRequest(
            engineSession, URL, LAST_URL, true, false, false, false, false,
        )
    }

    @Test
    fun theOverloadWithoutATargetLoadsInPlace() {
        interceptor.onLoadRequest(
            engineSession,
            URL,
            LAST_URL,
            hasUserGesture = true,
            isSameDomain = false,
            isRedirect = false,
            isDirectNavigation = false,
            isSubframeRequest = false,
        )

        verify(appLinks).onLoadRequest(
            engineSession, URL, LAST_URL, true, false, false, false, false,
        )
    }

    private fun load(isNewWindowRequest: Boolean) {
        interceptor.onLoadRequest(
            engineSession,
            URL,
            LAST_URL,
            hasUserGesture = true,
            isSameDomain = false,
            isRedirect = false,
            isDirectNavigation = false,
            isSubframeRequest = false,
            isNewWindowRequest = isNewWindowRequest,
        )
    }

    private companion object {
        const val URL = "https://app.example/watch"
        const val LAST_URL = "https://source.example/page"
    }
}
