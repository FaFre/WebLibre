import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/utils/form_validators.dart';

class DohSettingsScreen extends HookConsumerWidget {
  const DohSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final dohSettings = ref.watch(
      engineSettingsWithDefaultsProvider.select((value) => value.dohSettings),
    );

    final customProviderController = useTextEditingController(
      text: BuiltInDohProviders.isBuiltin(dohSettings.dohProviderUrl)
          ? null
          : dohSettings.dohProviderUrl,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('DNS over HTTPS')),
      body: SafeArea(
        child: ListView(
          children: [
            const ListTile(
              leading: Icon(MdiIcons.dns),
              title: Text('Protection Level'),
              subtitle: Text(
                'Domain Name System (DNS) over HTTPS sends your request for a domain name through an encrypted connection, providing a secure DNS and making it harder for others to see which web site you’re about to access.',
              ),
            ),
            RadioGroup(
              groupValue: dohSettings.dohSettingsMode,
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.dohSettingsMode(value),
                      );
                }
              },
              child: const Column(
                children: [
                  RadioListTile.adaptive(
                    value: DohSettingsMode.geckoDefault,
                    title: Text('Default Protection'),
                    subtitle: Text('DoH used only when default DNS fails'),
                  ),
                  RadioListTile.adaptive(
                    value: DohSettingsMode.increased,
                    title: Text('Increased Protection'),
                    subtitle: Text('DoH preferred, default DNS as fallback'),
                  ),
                  RadioListTile.adaptive(
                    value: DohSettingsMode.max,
                    title: Text('Max Protection'),
                    subtitle: Text('DoH only, no fallback'),
                  ),
                  RadioListTile.adaptive(
                    value: DohSettingsMode.off,
                    title: Text('Off'),
                    subtitle: Text('Use your default DNS resolver'),
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(MdiIcons.routerNetwork),
              title: Text('DoH Provider'),
            ),
            RadioGroup(
              groupValue: dohSettings.dohProviderUrl,
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.dohProviderUrl(value),
                      );
                }
              },
              child: Column(
                children: BuiltInDohProviders.values
                    .map(
                      (provider) => RadioListTile.adaptive(
                        value: provider.url,
                        title: Text(provider.name),
                        subtitle: Text(provider.url),
                      ),
                    )
                    .toList(),
              ),
            ),
            RadioGroup(
              groupValue: !BuiltInDohProviders.isBuiltin(
                dohSettings.dohProviderUrl,
              ),
              onChanged: (value) {},
              child: RadioListTile(
                value: true,
                enabled: false,
                title: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: customProviderController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      label: Text('Custom Resolver URL'),
                      hintText: 'https://example.com/dns-query',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (value) {
                      return validateUrl(
                        value,
                        onlyHttpProtocol: true,
                        eagerParsing: false,
                      );
                    },
                    onSaved: (newProvider) async {
                      if (newProvider != null) {
                        await ref
                            .read(saveEngineSettingsControllerProvider.notifier)
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .dohProviderUrl(newProvider),
                            );
                      }
                    },
                    onFieldSubmitted: (_) {
                      if (formKey.currentState?.validate() == true) {
                        formKey.currentState?.save();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
