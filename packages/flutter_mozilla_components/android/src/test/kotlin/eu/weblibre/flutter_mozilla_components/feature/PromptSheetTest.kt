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
package eu.weblibre.flutter_mozilla_components.feature

import android.app.Dialog
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.Outline
import android.graphics.Rect
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.Button
import android.widget.FrameLayout
import androidx.core.content.res.use
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.DialogFragment
import androidx.fragment.app.FragmentActivity
import com.google.android.material.color.MaterialColors
import eu.weblibre.flutter_mozilla_components.addons.WebExtensionPromptHost
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue
import mozilla.components.feature.addons.ui.AddonDialogFragment
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.android.controller.ActivityController
import org.robolectric.annotation.Config

class PromptSheetTestActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(com.google.android.material.R.style.Theme_Material3_Light_NoActionBar)
        super.onCreate(savedInstanceState)
        PromptSheet.install(supportFragmentManager)
    }
}

/**
 * A window that leaves the styling to [WebExtensionPromptHost], as the
 * browser's windows do.
 */
class PromptSheetTestHostedActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(com.google.android.material.R.style.Theme_Material3_Light_NoActionBar)
        super.onCreate(savedInstanceState)
    }
}

/**
 * Laid out as Mozilla's prompts are: a plain dialog at the bottom at full
 * width, its surfaces painted with the window background, a footer of its own
 * among them, and a button.
 */
class PromptSheetTestPrompt : AddonDialogFragment() {
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val context = requireContext()
        val windowBackground = context.obtainStyledAttributes(intArrayOf(android.R.attr.windowBackground))
            .use { it.getDrawable(0) }
        val root = FrameLayout(context).apply {
            id = ROOT_ID
            background = windowBackground
        }
        root.addView(
            FrameLayout(context).apply {
                id = FOOTER_ID
                background = context.obtainStyledAttributes(intArrayOf(android.R.attr.windowBackground))
                    .use { it.getDrawable(0) }
                addView(Button(context).apply { id = BUTTON_ID })
            },
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 200, Gravity.BOTTOM),
        )

        return Dialog(context).apply {
            requestWindowFeature(Window.FEATURE_NO_TITLE)
            setContentView(root)
            window?.apply {
                setGravity(Gravity.BOTTOM)
                setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
                setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            }
        }
    }

    companion object {
        const val ROOT_ID = 1
        const val FOOTER_ID = 2
        const val BUTTON_ID = 3
    }
}

/** A prompt with Mozilla's own extension permissions layout. */
class PromptSheetTestPermissionsPrompt : AddonDialogFragment() {
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val context = requireContext()
        return Dialog(context).apply {
            requestWindowFeature(Window.FEATURE_NO_TITLE)
            setContentView(
                LayoutInflater.from(context).inflate(
                    mozilla.components.feature.addons.R.layout.mozac_feature_addons_fragment_dialog_addon_permissions,
                    null,
                ),
            )
        }
    }
}

/** Not a prompt. */
class PromptSheetTestOtherDialog : DialogFragment() {
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog =
        Dialog(requireContext()).apply {
            setContentView(FrameLayout(requireContext()).apply { id = PromptSheetTestPrompt.ROOT_ID })
        }
}

/** Mozilla's download and extension prompts, shown as M3 bottom sheets (#651). */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [33])
class PromptSheetTest {
    private val activities = mutableListOf<ActivityController<out FragmentActivity>>()

    /** Run once the activities are gone. */
    private val afterActivities = mutableListOf<() -> Unit>()

    @After
    fun tearDown() {
        // Takes the dialogs down with it.
        activities.forEach { it.pause().stop().destroy() }
        afterActivities.forEach { it() }
    }

    private fun show(fragment: DialogFragment): Dialog {
        val controller = Robolectric.buildActivity(PromptSheetTestActivity::class.java).setup()
        activities += controller
        fragment.showNow(controller.get().supportFragmentManager, "prompt")
        shadowOf(Looper.getMainLooper()).idle()
        return fragment.requireDialog()
    }

    private val Dialog.root: View
        get() = findViewById(PromptSheetTestPrompt.ROOT_ID)

    private fun sheetColor(dialog: Dialog) = sheetColor(dialog.root)

    private fun sheetColor(view: View) = MaterialColors.getColor(
        view,
        com.google.android.material.R.attr.colorSurfaceContainerLow,
    )

    private fun View.color() = (background as ColorDrawable).color

    private fun dispatch(view: View, type: Int, insets: Insets) {
        ViewCompat.dispatchApplyWindowInsets(
            view,
            WindowInsetsCompat.Builder().setInsets(type, insets).build(),
        )
    }

    @Test
    fun `paints the prompt in the sheet color`() {
        val dialog = show(PromptSheetTestPrompt())

        assertEquals(sheetColor(dialog), dialog.root.color())
        assertEquals(sheetColor(dialog), dialog.findViewById<View>(PromptSheetTestPrompt.FOOTER_ID).color())
        // A button keeps its own background.
        assertTrue(dialog.findViewById<View>(PromptSheetTestPrompt.BUTTON_ID).background !is ColorDrawable)
    }

    @Test
    fun `paints the surfaces of Mozilla's own layout in the sheet color`() {
        // Its surfaces lie inside the sheet, where only what paints the window
        // background takes the sheet's color. Fails when an Android Components
        // upgrade paints them some other way.
        val dialog = show(PromptSheetTestPermissionsPrompt())
        val content = dialog.findViewById<View>(mozilla.components.feature.addons.R.id.icon).parent as View
        val footer = dialog.findViewById<View>(mozilla.components.feature.addons.R.id.deny_button).parent as View

        assertEquals(sheetColor(content), content.color())
        assertEquals(sheetColor(footer), footer.color())
    }

    @Test
    fun `rounds only its top corners`() {
        val dialog = show(PromptSheetTestPrompt())
        val root = dialog.root
        root.layout(0, 0, 300, 400)

        val outline = Outline()
        root.outlineProvider.getOutline(root, outline)
        val rect = Rect()
        outline.getRect(rect)

        assertTrue(root.clipToOutline)
        assertEquals(28f * root.resources.displayMetrics.density, outline.radius)
        assertEquals(0, rect.top)
        // Its bottom corners lie below the view.
        assertTrue(rect.bottom >= 400 + outline.radius)
    }

    @Test
    fun `lays its window out behind the system bars`() {
        val window = show(PromptSheetTestPrompt()).window!!

        assertEquals(0, window.attributes.fitInsetsTypes)
        assertEquals(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, window.attributes.gravity)
        assertEquals(false, window.isNavigationBarContrastEnforced)
    }

    @Test
    fun `keeps its content clear of the navigation bar and the keyboard`() {
        val dialog = show(PromptSheetTestPrompt())
        val root = dialog.root

        // Through the window's decor, which a floating window's would take the
        // bars' insets from.
        dispatch(dialog.window!!.decorView, WindowInsetsCompat.Type.navigationBars(), Insets.of(0, 0, 0, 48))
        assertEquals(48, root.paddingBottom)

        dispatch(dialog.window!!.decorView, WindowInsetsCompat.Type.ime(), Insets.of(0, 0, 0, 300))
        assertEquals(300, root.paddingBottom)
    }

    @Test
    fun `drops its corners under the status bar`() {
        val dialog = show(PromptSheetTestPrompt())
        val root = dialog.root
        root.layout(0, 0, 300, 400)

        dispatch(dialog.window!!.decorView, WindowInsetsCompat.Type.statusBars(), Insets.of(0, 24, 0, 0))

        val outline = Outline()
        root.outlineProvider.getOutline(root, outline)
        assertEquals(24, root.paddingTop)
        assertEquals(0f, outline.radius)
    }

    @Test
    @Config(qualifiers = "w900dp-h400dp")
    fun `is at most 640dp wide`() {
        val window = show(PromptSheetTestPrompt()).window!!

        assertEquals((640 * window.context.resources.displayMetrics.density).toInt(), window.attributes.width)
    }

    @Test
    fun `spans a phone's width`() {
        val window = show(PromptSheetTestPrompt()).window!!

        assertEquals(ViewGroup.LayoutParams.MATCH_PARENT, window.attributes.width)
    }

    @Test
    fun `caps its width anew once the window grows`() {
        val dialog = show(PromptSheetTestPrompt())
        val window = dialog.window!!

        RuntimeEnvironment.setQualifiers("w900dp-h400dp")
        val resources = dialog.root.resources
        @Suppress("DEPRECATION")
        resources.updateConfiguration(
            Configuration(resources.configuration).apply {
                screenWidthDp = 900
                screenHeightDp = 400
            },
            resources.displayMetrics,
        )
        window.decorView.viewTreeObserver.dispatchOnGlobalLayout()

        assertEquals((640 * resources.displayMetrics.density).toInt(), window.attributes.width)
    }

    @Test
    @Config(sdk = [28], qualifiers = "w900dp-h400dp")
    fun `before Android 11, is at most 640dp wide too`() {
        val window = show(PromptSheetTestPrompt()).window!!

        assertEquals((640 * window.context.resources.displayMetrics.density).toInt(), window.attributes.width)
    }

    @Test
    fun `styles an extension prompt restored with its window`() {
        val application = RuntimeEnvironment.getApplication()
        application.registerActivityLifecycleCallbacks(WebExtensionPromptHost)
        // Once the host has seen the window go.
        afterActivities += { application.unregisterActivityLifecycleCallbacks(WebExtensionPromptHost) }
        val controller = Robolectric.buildActivity(PromptSheetTestHostedActivity::class.java).setup()
        activities += controller
        PromptSheetTestPrompt().showNow(controller.get().supportFragmentManager, "prompt")

        // Restored, and started, before the new window resumes.
        controller.recreate()
        shadowOf(Looper.getMainLooper()).idle()

        val restored = controller.get().supportFragmentManager.findFragmentByTag("prompt") as DialogFragment
        val dialog = restored.requireDialog()
        assertTrue(dialog.root.clipToOutline)
        assertEquals(sheetColor(dialog), dialog.root.color())
    }

    @Test
    fun `leaves other dialogs alone`() {
        val dialog = show(PromptSheetTestOtherDialog())

        assertEquals(false, dialog.root.clipToOutline)
        assertNotEquals(0, dialog.window!!.attributes.fitInsetsTypes)
    }

    @Test
    @Config(sdk = [28])
    fun `before Android 11, takes the shape but stays above the navigation bar`() {
        val dialog = show(PromptSheetTestPrompt())

        assertEquals(sheetColor(dialog), dialog.root.color())
        assertTrue(dialog.root.clipToOutline)
        // The system keeps it clear of the bars, so nothing pads it.
        dispatch(dialog.root, WindowInsetsCompat.Type.navigationBars(), Insets.of(0, 0, 0, 48))
        assertEquals(0, dialog.root.paddingBottom)
    }
}
