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
package eu.weblibre.locale_resolver

import eu.weblibre.locale_resolver.pigeons.LocaleResolver
import eu.weblibre.locale_resolver.pigeons.LocalizedResult
import java.util.Locale

class LocaleResolverImpl : LocaleResolver {
    override fun resolve(languageTag: String, targetLangouageTag: String): LocalizedResult {
        val deviceLocale = Locale.forLanguageTag(targetLangouageTag)
        val targetLocale = Locale.forLanguageTag(languageTag)

        val languageName = targetLocale.getDisplayLanguage(deviceLocale)
        val countryName = targetLocale.getDisplayCountry(deviceLocale)

        return LocalizedResult(
            languageName,
            countryName.ifBlank { null }
        )
    }
}