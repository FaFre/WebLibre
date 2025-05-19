package eu.weblibre.flutter_mozilla_components.ext

import android.content.Context
import androidx.annotation.StringRes

fun Context.getPreferenceKey(@StringRes resourceId: Int): String =
    resources.getString(resourceId)