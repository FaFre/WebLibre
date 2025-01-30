import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:lensai/features/settings/presentation/widgets/hardening_group_icon.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class BrowserHardeningGroupScreen extends HookConsumerWidget {
  final String groupName;

  const BrowserHardeningGroupScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(preferenceSettingsGroupRepositoryProvider(groupName));

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
                      subtitle: (group.description != null)
                          ? Text(
                              group.description!,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                      onChanged: (value) async {
                        final notifier = ref.read(
                          preferenceSettingsGroupRepositoryProvider(groupName)
                              .notifier,
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
                  children: group.settings.entries.map(
                    (setting) {
                      return Row(
                        children: [
                          if (!setting.value.shouldBeDefault ||
                              !setting.value.isActive)
                            Expanded(
                              child: SwitchListTile(
                                value: setting.value.isActive,
                                title: Text(setting.value.title),
                                subtitle: (setting.value.description != null)
                                    ? Text(setting.value.description!)
                                    : null,
                                secondary: HardeningGroupIcon(
                                  isActive: setting.value.isActive,
                                ),
                                onChanged: (value) async {
                                  final notifier = ref.read(
                                    preferenceSettingsGroupRepositoryProvider(
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
                                title: Text(setting.value.title),
                                subtitle: (setting.value.description != null)
                                    ? Text(setting.value.description!)
                                    : null,
                                leading: HardeningGroupIcon(
                                  isActive: setting.value.isActive,
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(right: 18.0),
                                  child: const Icon(Icons.check),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) => FailureWidget(
          title: 'Could not load preference settings',
          exception: error,
          onRetry: () =>
              ref.refresh(preferenceSettingsGroupRepositoryProvider(groupName)),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
