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
import 'package:country_flags/country_flags.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/locale.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/domain/repositories/locale_resolver.dart';
import 'package:weblibre/extensions/locale.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

class LocaleSettingsScreen extends HookConsumerWidget {
  const LocaleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final systemLocales = useMemoized(
      () => WidgetsBinding.instance.platformDispatcher.locales
          .map((locale) => locale.toIntlLocale())
          .toList(),
    );

    final userLocales = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (settings) => EquatableValue(
          settings.locales.map(Locale.tryParse).nonNulls.toSet(),
        ),
      ),
    );

    final availableLocales = {
      ...systemLocales,
      ...userLocales.value,
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
    };

    final customLocaleController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Browser Languages')),
      body: SafeArea(
        child: ListView(
          children: [
            ...availableLocales.map((locale) {
              return CheckboxListTile.adaptive(
                value: userLocales.value.contains(locale),
                onChanged: (value) async {
                  if (value != null) {
                    await ref
                        .read(saveEngineSettingsControllerProvider.notifier)
                        .save(
                          (currentSettings) => currentSettings.copyWith.locales(
                            value
                                ? {
                                    ...currentSettings.locales,
                                    locale.toLanguageTag(),
                                  }.toList()
                                : ([
                                    ...currentSettings.locales,
                                  ]..remove(locale.toLanguageTag())).toList(),
                          ),
                        );
                  }
                },
                title: Consumer(
                  builder: (context, ref, child) {
                    final resolvedAsync = ref.watch(
                      resolveLocaleProvider(locale),
                    );

                    return Text(
                      resolvedAsync.maybeWhen(
                        data: (data) =>
                            data.mapNotNull(
                              (data) =>
                                  '${data.languageName} ${data.countryName.mapNotNull((country) => '($country)') ?? ''}'
                                      .trim(),
                            ) ??
                            locale.toLanguageTag(),
                        orElse: () => locale.toLanguageTag(),
                      ),
                    );
                  },
                ),
                subtitle: Text(locale.toLanguageTag()),
                secondary: CountryFlag.fromLanguageCode(
                  locale.languageCode,
                  theme: const ImageTheme(shape: RoundedRectangle(8.0)),
                ),
              );
            }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 20),
              child: Form(
                key: formKey,
                child: TextFormField(
                  controller: customLocaleController,
                  decoration: InputDecoration(
                    label: const Text('Custom Locale'),
                    hint: const Text('en-US'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() == true) {
                          formKey.currentState?.save();
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && Locale.tryParse(value) == null) {
                      return 'Invalid locale identifier';
                    }

                    return null;
                  },
                  onSaved: (newValue) async {
                    if (newValue != null) {
                      await ref
                          .read(saveEngineSettingsControllerProvider.notifier)
                          .save(
                            (currentSettings) =>
                                currentSettings.copyWith.locales(
                                  {
                                    ...currentSettings.locales,
                                    Locale.parse(newValue).toLanguageTag(),
                                  }.toList(),
                                ),
                          );

                      customLocaleController.clear();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
