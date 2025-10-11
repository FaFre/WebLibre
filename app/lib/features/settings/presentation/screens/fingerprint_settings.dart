import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/services/fingerprinting.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class FingerprintSettingsScreen extends HookConsumerWidget {
  const FingerprintSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetsAsync = ref.watch(fingerprintTargetsProvider);
    final settingsAsync = ref.watch(fingerprintOverrideSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Protection'),
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                onPressed: () {
                  controller.open();
                },
                icon: const Icon(Icons.more_vert),
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.restore),
                child: const Text('Load Defaults'),
                onPressed: () async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .fingerprintingProtectionOverrides(
                              FingerprintOverrides.defaults().toString(),
                            ),
                      );
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.restore),
                child: const Text('Load Hardened Defaults'),
                onPressed: () async {
                  await ref
                      .read(saveEngineSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .fingerprintingProtectionOverrides(
                              FingerprintOverrides.hardenedDefaults()
                                  .toString(),
                            ),
                      );
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: settingsAsync.when(
          data: (result) {
            return result.fold(
              (overrides) {
                return targetsAsync.when(
                  data: (targets) {
                    return ListView.builder(
                      itemCount: targets.length,
                      itemBuilder: (context, index) {
                        final target = targets[index];
                        final state = overrides.targets[target.name];

                        return CheckboxListTile.adaptive(
                          value:
                              (overrides.allTargets == true &&
                                  state != false) ||
                              state == true,
                          onChanged: (value) async {
                            if (value != null) {
                              final newOverrides = overrides
                                  .copyWithTarget(target.name, value)
                                  .toString();

                              await ref
                                  .read(
                                    saveEngineSettingsControllerProvider
                                        .notifier,
                                  )
                                  .save(
                                    (currentSettings) => currentSettings
                                        .copyWith
                                        .fingerprintingProtectionOverrides(
                                          newOverrides,
                                        ),
                                  );
                            }
                          },
                          title: Text(target.name),
                          subtitle: target.description.mapNotNull(
                            (desc) => Text(desc),
                          ),
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) {
                    return Center(
                      child: FailureWidget(
                        exception: error,
                        onRetry: () {
                          ref.invalidate(fingerprintTargetsProvider);
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                );
              },
              onFailure: (errorMessage) {
                return Center(
                  child: FailureWidget(
                    title: errorMessage.message,
                    exception: errorMessage.details,
                    onRetry: () {
                      ref.invalidate(fingerprintOverrideSettingsProvider);
                    },
                  ),
                );
              },
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: FailureWidget(
                exception: error,
                onRetry: () {
                  ref.invalidate(fingerprintOverrideSettingsProvider);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
