import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/settings/presentation/widgets/hardening_group_icon.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class WebEngineHardeningGroupScreen extends HookConsumerWidget {
  final String groupName;

  const WebEngineHardeningGroupScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(
      preferenceSettingsGroupRepositoryProvider(
        PreferencePartition.user,
        groupName,
      ),
    );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: settings.when(
        data: (group) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                      value: group.isActive,
                      title: Text(
                        groupName,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      subtitle: group.description.mapNotNull(
                        (description) => Text(
                          description,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      onChanged: (value) async {
                        final notifier = ref.read(
                          preferenceSettingsGroupRepositoryProvider(
                            PreferencePartition.user,
                            groupName,
                          ).notifier,
                        );

                        if (value) {
                          await notifier.apply();
                        } else {
                          await notifier.reset();
                        }
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: group.settings.entries.map((setting) {
                    return Row(
                      children: [
                        if (!setting.value.shouldBeDefault ||
                            !setting.value.isActive)
                          Expanded(
                            child: SwitchListTile(
                              value: setting.value.isActive,
                              title: Text(setting.value.title ?? setting.key),
                              subtitle: setting.value.description.mapNotNull(
                                (description) => Text(description),
                              ),
                              secondary: HardeningGroupIcon(
                                isActive: setting.value.isActive,
                              ),
                              onChanged: (value) async {
                                final notifier = ref.read(
                                  preferenceSettingsGroupRepositoryProvider(
                                    PreferencePartition.user,
                                    groupName,
                                  ).notifier,
                                );

                                if (value) {
                                  await notifier.apply(filter: [setting.key]);
                                } else {
                                  await notifier.reset(filter: [setting.key]);
                                }
                              },
                            ),
                          )
                        else
                          Expanded(
                            child: ListTile(
                              title: Text(setting.value.title ?? setting.key),
                              subtitle: setting.value.description.mapNotNull(
                                (description) => Text(description),
                              ),
                              leading: HardeningGroupIcon(
                                isActive: setting.value.isActive,
                              ),
                              trailing: const Padding(
                                padding: EdgeInsets.only(right: 18.0),
                                child: Icon(Icons.check),
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => FailureWidget(
          title: 'Could not load preference settings',
          exception: error,
          onRetry: () => ref.refresh(
            preferenceSettingsGroupRepositoryProvider(
              PreferencePartition.user,
              groupName,
            ),
          ),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
