import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/setting_groups_serializer.dart';
import 'package:weblibre/features/settings/presentation/widgets/hardening_group_icon.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class WebEngineHardeningScreen extends HookConsumerWidget {
  const WebEngineHardeningScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceGroups = ref.watch(
      unifiedPreferenceSettingsRepositoryProvider(PreferencePartition.user),
    );

    final allGroupsActive = useMemoized(
      () =>
          preferenceGroups.valueOrNull?.values.every(
            (element) => element.isActiveOrOptional,
          ) ??
          false,
      [EquatableValue(preferenceGroups.valueOrNull)],
    );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Web Engine Hardening')),
      body: preferenceGroups.when(
        skipLoadingOnReload: true,
        data: (data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                      value: allGroupsActive,
                      title: Text(
                        'Complete Hardening',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      onChanged: (value) async {
                        final notifier = ref.read(
                          unifiedPreferenceSettingsRepositoryProvider(
                            PreferencePartition.user,
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
                  children: data.entries.map((group) {
                    return Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(group.key),
                            subtitle: group.value.description.mapNotNull(
                              (description) => Text(description),
                            ),
                            leading: Badge(
                              isLabelVisible: group.value.hasInactiveOptional,
                              child: HardeningGroupIcon(
                                isActive: group.value.isActiveOrOptional,
                                isPartlyActive: group.value.isPartlyActive,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await WebEngineHardeningGroupRoute(
                                group: group.key,
                              ).push(context);
                            },
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
            unifiedPreferenceSettingsRepositoryProvider(
              PreferencePartition.user,
            ),
          ),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
