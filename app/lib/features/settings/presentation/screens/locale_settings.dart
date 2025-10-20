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
  const LocaleSettingsScreen();

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
