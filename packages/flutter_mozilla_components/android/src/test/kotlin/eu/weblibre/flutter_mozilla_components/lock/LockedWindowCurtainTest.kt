/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
package eu.weblibre.flutter_mozilla_components.lock

import android.app.Dialog
import android.content.ContextWrapper
import android.os.Bundle
import android.os.Looper
import android.view.View
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.android.controller.ActivityController
import org.robolectric.annotation.Config

/** Restorable, so it comes back with a recreated activity. */
class CurtainTestDialog : DialogFragment()

/** A dialog that belongs to the lock itself, as the pre-28 device prompt does. */
class CurtainExemptDialog : DialogFragment()

/** Hosts a dialog of its own in its child fragment manager. */
class CurtainTestHost : Fragment()

/**
 * A window with a curtain, set up in `onCreate` as `ExternalAppBrowserActivity`
 * does, so dialogs restored by `super.onCreate` start under it.
 */
class CurtainTestActivity : FragmentActivity(), ProfileLockedWindow {
    internal lateinit var curtain: LockedWindowCurtain

    override val isProfileLocked: Boolean
        get() = curtain.isLocked

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        curtain = LockedWindowCurtain(supportFragmentManager) { it is CurtainExemptDialog }
        if (lockOnCreate) curtain.lock()
    }

    override fun coverWhileLocked(dialog: Dialog) = curtain.cover(dialog)

    companion object {
        var lockOnCreate = false
    }
}

/**
 * The dialogs of a locked Custom Tab or PWA window: windows of their own, so
 * the lock panel cannot cover them, and the curtain hides them instead.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class LockedWindowCurtainTest {
    private val controller: ActivityController<CurtainTestActivity> =
        Robolectric.buildActivity(CurtainTestActivity::class.java).setup()

    private val activity get() = controller.get()

    @After
    fun tearDown() {
        CurtainTestActivity.lockOnCreate = false
    }

    private fun showDialog(
        dialog: DialogFragment = CurtainTestDialog(),
        tag: String = "dialog",
    ): DialogFragment {
        dialog.show(activity.supportFragmentManager, tag)
        settle()
        return dialog
    }

    private fun settle() {
        activity.supportFragmentManager.executePendingTransactions()
        shadowOf(Looper.getMainLooper()).idle()
    }

    private val DialogFragment.isOnScreen: Boolean
        get() = assertNotNull(dialog).isOnScreen

    /**
     * Whether the dialog's window is on screen. Not `Dialog.isShowing`, which
     * on older releases (this runs on 28) only follows `show` and `dismiss`,
     * and stays true for a hidden dialog.
     */
    private val Dialog.isOnScreen: Boolean
        get() = isShowing && window?.decorView?.visibility == View.VISIBLE

    @Test
    fun aDialogUpWhenTheLockComesUpIsHiddenAndBackAfter() {
        val dialog = showDialog()
        assertTrue(dialog.isOnScreen)

        activity.curtain.lock()
        assertFalse(dialog.isOnScreen)

        activity.curtain.unlock()
        assertTrue(dialog.isOnScreen)
    }

    @Test
    fun aDialogRaisedWhileLockedStaysHiddenUntilUnlocked() {
        activity.curtain.lock()

        val dialog = showDialog()
        assertFalse(dialog.isOnScreen)

        activity.curtain.unlock()
        assertTrue(dialog.isOnScreen)
    }

    @Test
    fun aDialogOfANestedFragmentIsCovered() {
        val host = CurtainTestHost()
        activity.supportFragmentManager.beginTransaction().add(host, "host").commitNow()
        val existing = CurtainTestDialog()
        existing.show(host.childFragmentManager, "existing")
        host.childFragmentManager.executePendingTransactions()

        activity.curtain.lock()
        assertFalse(existing.isOnScreen)

        val raised = CurtainTestDialog()
        raised.show(host.childFragmentManager, "raised")
        host.childFragmentManager.executePendingTransactions()
        assertFalse(raised.isOnScreen)

        activity.curtain.unlock()
        assertTrue(existing.isOnScreen)
        assertTrue(raised.isOnScreen)
    }

    @Test
    fun comingBackToTheFrontWhileLockedDoesNotShowIt() {
        val dialog = showDialog()
        activity.curtain.lock()

        // `DialogFragment.onStart` shows the dialog again.
        controller.pause().stop().start().resume()
        settle()
        assertFalse(dialog.isOnScreen)

        activity.curtain.unlock()
        assertTrue(dialog.isOnScreen)
    }

    @Test
    fun aDialogRestoredWithTheWindowStaysHidden() {
        showDialog()
        activity.curtain.lock()

        CurtainTestActivity.lockOnCreate = true
        controller.recreate()
        settle()

        val restored = activity.supportFragmentManager.findFragmentByTag("dialog") as DialogFragment
        assertFalse(restored.isOnScreen)

        activity.curtain.unlock()
        assertTrue(restored.isOnScreen)
    }

    @Test
    fun theLocksOwnPromptIsLeftAlone() {
        activity.curtain.lock()

        val prompt = showDialog(CurtainExemptDialog(), "prompt")
        assertTrue(prompt.isOnScreen)
    }

    @Test
    fun aDismissedDialogIsNotBroughtBack() {
        val dialog = showDialog()
        activity.curtain.lock()

        dialog.dismiss()
        settle()

        activity.curtain.unlock()
        assertFalse(dialog.dialog?.isOnScreen == true)
    }

    @Test
    fun aPlainDialogIsCoveredOnceHandedIn() {
        val dialog = Dialog(activity)
        dialog.show()
        activity.curtain.cover(dialog)

        activity.curtain.lock()
        assertFalse(dialog.isOnScreen)

        activity.curtain.unlock()
        assertTrue(dialog.isOnScreen)
    }

    @Test
    fun aPlainDialogShownWhileLockedIsHidden() {
        activity.curtain.lock()

        // Through the window's context, as the prompt features build theirs.
        val dialog = Dialog(ContextWrapper(activity))
        dialog.show()
        dialog.coverWhileWindowLocked()
        assertFalse(dialog.isOnScreen)

        // Within the same frame, before the dialog was ever laid out: as a
        // prompt raised in `onStart` and unlocked in `onResume`.
        activity.curtain.unlock()
        assertTrue(dialog.isOnScreen)
    }

    @Test
    fun aPlainDialogDismissedWhileHiddenStaysGone() {
        val dialog = Dialog(activity)
        dialog.show()
        activity.curtain.cover(dialog)
        activity.curtain.lock()

        // Its owner settled it meanwhile, e.g. an app-link prompt that expired.
        dialog.dismiss()
        settle()

        activity.curtain.unlock()
        assertFalse(dialog.isOnScreen)
    }
}
