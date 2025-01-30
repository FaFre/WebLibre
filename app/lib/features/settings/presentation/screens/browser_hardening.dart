import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/geckoview/features/preferences/data/repositories/preference_settings.dart';
import 'package:lensai/features/settings/presentation/widgets/hardening_group_icon.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';

class BrowserHardeningScreen extends HookConsumerWidget {
  const BrowserHardeningScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceGroups =
        ref.watch(preferenceSettingsGeneralRepositoryProvider);

    final allGroupsActive = useMemoized(
      () =>
          preferenceGroups.valueOrNull?.values.every(
            (element) => element.isActive,
          ) ??
          false,
      [EquatableCollection(preferenceGroups.valueOrNull, immutable: true)],
    );

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Browser Hardening')),
      body: preferenceGroups.when(
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
                          preferenceSettingsGeneralRepositoryProvider.notifier,
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
                  children: data.entries.map(
                    (group) {
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(group.key),
                              subtitle: (group.value.description != null)
                                  ? Text(group.value.description!)
                                  : null,
                              leading: HardeningGroupIcon(
                                isActive: group.value.isActive,
                                isPartlyActive: group.value.isPartlyActive,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await context.push(
                                  BrowserHardeningGroupRoute(
                                    group: group.key,
                                  ).location,
                                );
                              },
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
              ref.refresh(preferenceSettingsGeneralRepositoryProvider),
        ),
        loading: () => const SizedBox.shrink(),
      ),
    );
  }
}
