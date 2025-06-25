import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class DefaultSearchSelector extends HookConsumerWidget {
  const DefaultSearchSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBang = ref.watch(defaultSearchBangDataProvider).valueOrNull;
    final availableBangs = ref.watch(frequentBangListProvider);

    Future<void> updateSearchProvider(String trigger) async {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.defaultSearchProvider(trigger),
          );
    }

    return availableBangs.when(
      skipLoadingOnReload: true,
      data: (availableBangs) {
        return SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: SelectableChips(
                  itemId: (bang) => bang.trigger,
                  itemAvatar: (bang) =>
                      UrlIcon([bang.getTemplateUrl('')], iconSize: 20),
                  itemLabel: (bang) => Text(bang.websiteName),
                  itemTooltip: (bang) => bang.trigger,
                  availableItems: availableBangs,
                  selectedItem: activeBang,
                  onSelected: (bang) async {
                    await updateSearchProvider(bang.trigger);
                  },
                ),
              ),
              IconButton(
                onPressed: () async {
                  final trigger = await const BangSearchRoute().push<String?>(
                    context,
                  );

                  if (trigger != null) {
                    await updateSearchProvider(trigger);
                  }
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox(height: 48, width: double.infinity),
    );
  }
}
