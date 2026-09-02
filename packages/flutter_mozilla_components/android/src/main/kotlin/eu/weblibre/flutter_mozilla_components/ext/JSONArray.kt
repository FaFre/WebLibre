/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ext

import org.json.JSONArray

/**
 * The strings in this array, in order, with an absent array read as empty.
 *
 * Every caller here is reading a JSON document that was written by our own Dart
 * or JS half, so a non-string element is a bug rather than input to defend
 * against — but an *empty* one is routine (an empty relation is what an explicit
 * direct connection looks like), and is deliberately kept out so a relation of
 * blank ids cannot read as a relation of real ones.
 */
internal fun JSONArray?.toStringList(): List<String> {
    val array = this ?: return emptyList()

    return buildList {
        for (index in 0 until array.length()) {
            array.optString(index).takeIf { it.isNotEmpty() }?.let(::add)
        }
    }
}

/** [toStringList] as a set, keeping first-seen order. */
internal fun JSONArray?.toStringSet(): Set<String> = toStringList().toSet()
