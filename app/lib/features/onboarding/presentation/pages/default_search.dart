import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

const defaultBangs = ['ddg', 'brave', 'startpage', 'qwant'];

class DefaultSearchPage extends HookConsumerWidget {
  const DefaultSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangs = ref.watch(bangListProvider(triggers: defaultBangs));

    final activeBang = ref.watch(defaultSearchBangDataProvider).valueOrNull;

    Future<void> updateSearchProvider(String trigger) async {
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(
            (currentSettings) =>
                currentSettings.copyWith.defaultSearchProvider(trigger),
          );
    }

    return bangs.when(
      skipLoadingOnReload: true,
      data: (availableBangs) {
        return ListView(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Default Search:'),
                  if (activeBang != null)
                    FilterChip(
                      showCheckmark: false,
                      label: Text(activeBang.websiteName),
                      avatar: UrlIcon([
                        activeBang.getTemplateUrl(''),
                      ], iconSize: 20),
                      selected: true,
                      onSelected: (value) {},
                    ),
                ],
              ),
            ),
            const Divider(),
            Wrap(
              spacing: 8.0,
              children: [
                ...availableBangs.map(
                  (bang) => FilterChip(
                    showCheckmark: false,
                    label: Text(bang.websiteName),
                    avatar: UrlIcon([bang.getTemplateUrl('')], iconSize: 20),
                    selected: activeBang?.trigger == bang.trigger,
                    onSelected: (selected) async {
                      if (selected) {
                        await updateSearchProvider(bang.trigger);
                      }
                    },
                  ),
                ),
                ActionChip(
                  label: const Text('Search more'),
                  avatar: const Icon(Icons.search),
                  onPressed: () async {
                    final trigger = await const BangSearchRoute().push<String?>(
                      context,
                    );

                    if (trigger != null) {
                      await updateSearchProvider(trigger);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox(height: 48, width: double.infinity),
    );
  }
}
