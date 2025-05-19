import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/animate_gradient_shader.dart';

class ReaderButton extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final readerChanging = ref.watch(readerableScreenControllerProvider);

    final enableReadability = ref.watch(
      generalSettingsRepositoryProvider.select(
        (value) => value.enableReadability,
      ),
    );

    final enforceReadability = ref.watch(
      generalSettingsRepositoryProvider.select(
        (value) => value.enforceReadability,
      ),
    );

    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );

    final icon =
        readerabilityState.active
            ? Icon(
              MdiIcons.bookOpen,
              color: Theme.of(context).colorScheme.primary,
            )
            : Icon(
              MdiIcons.bookOpenOutline,
              color: Theme.of(context).colorScheme.onSurface,
            );

    return Visibility(
      visible:
          (readerabilityState.readerable &&
              (enableReadability || readerabilityState.active)) ||
          (enforceReadability && enableReadability),
      child: readerChanging.when(
        skipLoadingOnReload: true,
        data:
            (_) => InkWell(
              onTap:
                  readerChanging.isLoading
                      ? null
                      : () async {
                        await ref
                            .read(readerableScreenControllerProvider.notifier)
                            .toggleReaderView(!readerabilityState.active);
                      },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 8.0,
                ),
                child: icon,
              ),
            ),
        error: (error, stackTrace) => SizedBox.shrink(),
        loading:
            () => AnimateGradientShader(
              duration: const Duration(milliseconds: 500),
              primaryEnd: Alignment.bottomLeft,
              secondaryEnd: Alignment.topRight,
              primaryColors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
              secondaryColors: [
                colorScheme.secondary,
                colorScheme.secondaryContainer,
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 8.0,
                ),
                child: icon,
              ),
            ),
      ),
    );
  }
}
