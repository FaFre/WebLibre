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