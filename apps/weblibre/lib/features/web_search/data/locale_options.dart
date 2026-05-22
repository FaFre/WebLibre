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
library;

/// Curated picker options for the web-search language and country selectors.
///
/// Codes intersect what Brave (`search_lang`/`country`) and Mojeek
/// (`lb`/`rb`) accept; English display names so the menu doesn't need a
/// per-locale translation pass. The protocol carries just the primary
/// ISO 639-1 / ISO 3166-1 alpha-2 codes — region qualifiers (`en-gb`,
/// `pt-br`, etc.) are reconstructed server-side from the language+country
/// pair.

class LanguageOption {
  final String code; // ISO 639-1
  final String name; // English display name
  const LanguageOption(this.code, this.name);
}

class CountryOption {
  final String code; // ISO 3166-1 alpha-2 (uppercase)
  final String name; // English display name
  const CountryOption(this.code, this.name);
}

const supportedLanguages = <LanguageOption>[
  LanguageOption('ar', 'Arabic'),
  LanguageOption('bg', 'Bulgarian'),
  LanguageOption('bn', 'Bengali'),
  LanguageOption('ca', 'Catalan'),
  LanguageOption('cs', 'Czech'),
  LanguageOption('da', 'Danish'),
  LanguageOption('de', 'German'),
  LanguageOption('el', 'Greek'),
  LanguageOption('en', 'English'),
  LanguageOption('es', 'Spanish'),
  LanguageOption('et', 'Estonian'),
  LanguageOption('eu', 'Basque'),
  LanguageOption('fi', 'Finnish'),
  LanguageOption('fr', 'French'),
  LanguageOption('gl', 'Galician'),
  LanguageOption('gu', 'Gujarati'),
  LanguageOption('he', 'Hebrew'),
  LanguageOption('hi', 'Hindi'),
  LanguageOption('hr', 'Croatian'),
  LanguageOption('hu', 'Hungarian'),
  LanguageOption('id', 'Indonesian'),
  LanguageOption('is', 'Icelandic'),
  LanguageOption('it', 'Italian'),
  LanguageOption('ja', 'Japanese'),
  LanguageOption('kn', 'Kannada'),
  LanguageOption('ko', 'Korean'),
  LanguageOption('lt', 'Lithuanian'),
  LanguageOption('lv', 'Latvian'),
  LanguageOption('ml', 'Malayalam'),
  LanguageOption('mr', 'Marathi'),
  LanguageOption('ms', 'Malay'),
  LanguageOption('nb', 'Norwegian'),
  LanguageOption('nl', 'Dutch'),
  LanguageOption('pa', 'Punjabi'),
  LanguageOption('pl', 'Polish'),
  LanguageOption('pt', 'Portuguese'),
  LanguageOption('ro', 'Romanian'),
  LanguageOption('ru', 'Russian'),
  LanguageOption('sk', 'Slovak'),
  LanguageOption('sl', 'Slovenian'),
  LanguageOption('sr', 'Serbian'),
  LanguageOption('sv', 'Swedish'),
  LanguageOption('ta', 'Tamil'),
  LanguageOption('te', 'Telugu'),
  LanguageOption('th', 'Thai'),
  LanguageOption('tr', 'Turkish'),
  LanguageOption('uk', 'Ukrainian'),
  LanguageOption('vi', 'Vietnamese'),
  LanguageOption('zh', 'Chinese'),
];

const supportedCountries = <CountryOption>[
  CountryOption('AR', 'Argentina'),
  CountryOption('AT', 'Austria'),
  CountryOption('AU', 'Australia'),
  CountryOption('BE', 'Belgium'),
  CountryOption('BR', 'Brazil'),
  CountryOption('CA', 'Canada'),
  CountryOption('CH', 'Switzerland'),
  CountryOption('CL', 'Chile'),
  CountryOption('CN', 'China'),
  CountryOption('DE', 'Germany'),
  CountryOption('DK', 'Denmark'),
  CountryOption('ES', 'Spain'),
  CountryOption('FI', 'Finland'),
  CountryOption('FR', 'France'),
  CountryOption('GB', 'United Kingdom'),
  CountryOption('GR', 'Greece'),
  CountryOption('HK', 'Hong Kong'),
  CountryOption('ID', 'Indonesia'),
  CountryOption('IN', 'India'),
  CountryOption('IT', 'Italy'),
  CountryOption('JP', 'Japan'),
  CountryOption('KR', 'South Korea'),
  CountryOption('MX', 'Mexico'),
  CountryOption('MY', 'Malaysia'),
  CountryOption('NL', 'Netherlands'),
  CountryOption('NO', 'Norway'),
  CountryOption('NZ', 'New Zealand'),
  CountryOption('PH', 'Philippines'),
  CountryOption('PL', 'Poland'),
  CountryOption('PT', 'Portugal'),
  CountryOption('RU', 'Russia'),
  CountryOption('SA', 'Saudi Arabia'),
  CountryOption('SE', 'Sweden'),
  CountryOption('TR', 'Turkey'),
  CountryOption('TW', 'Taiwan'),
  CountryOption('US', 'United States'),
  CountryOption('ZA', 'South Africa'),
];

LanguageOption? findLanguage(String? code) {
  if (code == null) return null;
  final lower = code.toLowerCase();
  for (final l in supportedLanguages) {
    if (l.code == lower) return l;
  }
  return null;
}

CountryOption? findCountry(String? code) {
  if (code == null) return null;
  final upper = code.toUpperCase();
  for (final c in supportedCountries) {
    if (c.code == upper) return c;
  }
  return null;
}
