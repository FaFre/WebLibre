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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/extensions/locale.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/web_search/data/locale_options.dart';
import 'package:weblibre/features/web_search/domain/providers/localized_locale_options.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final fg = isHighlighted
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: isHighlighted
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isHighlighted ? fg : colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down_rounded, size: 18, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool isHighlighted;

  const _MenuRow({
    required this.label,
    this.subtitle,
    required this.isSelected,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelColor = isHighlighted ? colorScheme.primary : null;
    return Row(
      children: [
        Expanded(
          child: subtitle != null
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: labelColor,
                          fontWeight: isSelected || isHighlighted
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      TextSpan(
                        text: '  $subtitle',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: labelColor,
                    fontWeight: isSelected || isHighlighted
                        ? FontWeight.bold
                        : null,
                  ),
                ),
        ),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.check_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

/// The device's own locale, which the search "device default" choices describe.
///
/// Not `Localizations.localeOf`: that is the app's UI locale, which follows the
/// in-app language override and is narrowed to the languages WebLibre ships.
Locale _deviceLocale(BuildContext context) =>
    View.of(context).platformDispatcher.locale;

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deviceLanguage = _deviceLocale(context).languageCode;
    final options =
        ref
            .watch(
              localizedLanguageOptionsProvider(
                Localizations.localeOf(context).toIntlLocale(),
              ),
            )
            .value ??
        supportedLanguages;

    final selected = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.language),
    );

    final isHighlighted = selected != null && selected != deviceLanguage;

    LanguageOption? find(String? code) => options.firstWhereOrNull(
      (option) => option.code == code?.toLowerCase(),
    );

    final selectedOption = find(selected);
    final label = selected == null
        ? l10n.webSearch_languageAuto
        : (selectedOption?.name ?? selected);

    final defaultOption = find(deviceLanguage);
    final others = [
      for (final l in options)
        if (l.code != defaultOption?.code) l,
    ]..sort((a, b) => a.name.compareTo(b.name));

    return MenuAnchor(
      builder: (context, controller, _) => _FilterPill(
        icon: Icons.translate_rounded,
        label: label,
        isHighlighted: isHighlighted,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setLanguage(null);
          },
          child: _MenuRow(
            label: l10n.webSearch_languageAutoDeviceDefault,
            subtitle: defaultOption?.code ?? deviceLanguage,
            isSelected: selected == null,
          ),
        ),
        const Divider(),
        for (final option in others)
          MenuItemButton(
            onPressed: () {
              ref
                  .read(webSearchSettingsControllerProvider.notifier)
                  .setLanguage(option.code);
            },
            child: _MenuRow(
              label: option.name,
              subtitle: option.code,
              isSelected: selected == option.code,
            ),
          ),
      ],
    );
  }
}

class CountrySelector extends ConsumerWidget {
  const CountrySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deviceCountry = _deviceLocale(context).countryCode;
    final options =
        ref
            .watch(
              localizedCountryOptionsProvider(
                Localizations.localeOf(context).toIntlLocale(),
              ),
            )
            .value ??
        supportedCountries;

    final selected = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.region),
    );

    final isHighlighted = selected != null && selected != deviceCountry;

    CountryOption? find(String? code) => options.firstWhereOrNull(
      (option) => option.code == code?.toUpperCase(),
    );

    final selectedOption = find(selected);
    final label = selected == null
        ? l10n.webSearch_countryAny
        : (selectedOption?.name ?? selected);

    final defaultOption = find(deviceCountry);

    final others = [
      for (final c in options)
        if (c.code != defaultOption?.code) c,
    ]..sort((a, b) => a.name.compareTo(b.name));

    return MenuAnchor(
      builder: (context, controller, _) => _FilterPill(
        icon: Icons.public_rounded,
        label: label,
        isHighlighted: isHighlighted,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setRegion(null);
          },
          child: _MenuRow(
            label: l10n.webSearch_countryAnyRegion,
            isSelected: selected == null,
          ),
        ),
        if (defaultOption != null) ...[
          const Divider(),
          MenuItemButton(
            onPressed: () {
              ref
                  .read(webSearchSettingsControllerProvider.notifier)
                  .setRegion(defaultOption.code);
            },
            child: _MenuRow(
              label: l10n.webSearch_countryDeviceDefault(defaultOption.name),
              subtitle: defaultOption.code,
              isSelected: selected == defaultOption.code,
            ),
          ),
        ],
        const Divider(),
        for (final option in others)
          MenuItemButton(
            onPressed: () {
              ref
                  .read(webSearchSettingsControllerProvider.notifier)
                  .setRegion(option.code);
            },
            child: _MenuRow(
              label: option.name,
              subtitle: option.code,
              isSelected: selected == option.code,
            ),
          ),
      ],
    );
  }
}

class SafeSearchSelector extends ConsumerWidget {
  const SafeSearchSelector({super.key});

  String _label(AppLocalizations l10n, SafeSearch? value) => switch (value) {
    null => l10n.webSearch_safeSearchPillDefault,
    SafeSearch.none => l10n.webSearch_safeSearchPillOff,
    SafeSearch.moderate => l10n.webSearch_safeSearchPillModerate,
    SafeSearch.strict => l10n.webSearch_safeSearchPillStrict,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.safeSearch),
    );

    final isHighlighted = selected != null;

    return MenuAnchor(
      builder: (context, controller, _) => _FilterPill(
        icon: Icons.shield_moon_outlined,
        label: _label(l10n, selected),
        isHighlighted: isHighlighted,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setSafeSearch(null);
          },
          child: _MenuRow(
            label: l10n.webSearch_safeSearchMenuDefault,
            isSelected: selected == null,
          ),
        ),
        const Divider(),
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setSafeSearch(SafeSearch.none);
          },
          child: _MenuRow(
            label: l10n.webSearch_safeSearchMenuOff,
            isSelected: selected == SafeSearch.none,
            isHighlighted: true,
          ),
        ),
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setSafeSearch(SafeSearch.moderate);
          },
          child: _MenuRow(
            label: l10n.webSearch_safeSearchMenuModerate,
            isSelected: selected == SafeSearch.moderate,
          ),
        ),
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setSafeSearch(SafeSearch.strict);
          },
          child: _MenuRow(
            label: l10n.webSearch_safeSearchMenuStrict,
            isSelected: selected == SafeSearch.strict,
            isHighlighted: true,
          ),
        ),
      ],
    );
  }
}

class FreshnessSelector extends ConsumerWidget {
  const FreshnessSelector({super.key});

  String _label(AppLocalizations l10n, TimeRange? value) => switch (value) {
    null => l10n.webSearch_freshnessAnyTime,
    TimeRange.day => l10n.webSearch_freshnessPastDay,
    TimeRange.week => l10n.webSearch_freshnessPastWeek,
    TimeRange.month => l10n.webSearch_freshnessPastMonth,
    TimeRange.year => l10n.webSearch_freshnessPastYear,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.timeRange),
    );

    final isHighlighted = selected != null;

    return MenuAnchor(
      builder: (context, controller, _) => _FilterPill(
        icon: Icons.schedule_rounded,
        label: _label(l10n, selected),
        isHighlighted: isHighlighted,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            ref
                .read(webSearchSettingsControllerProvider.notifier)
                .setTimeRange(null);
          },
          child: _MenuRow(
            label: l10n.webSearch_freshnessAnyTime,
            isSelected: selected == null,
          ),
        ),
        const Divider(),
        for (final value in TimeRange.values)
          MenuItemButton(
            onPressed: () {
              ref
                  .read(webSearchSettingsControllerProvider.notifier)
                  .setTimeRange(value);
            },
            child: _MenuRow(
              label: _label(l10n, value),
              isSelected: selected == value,
            ),
          ),
      ],
    );
  }
}
