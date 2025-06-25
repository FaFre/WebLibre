import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class BangChips extends HookConsumerWidget {
  final bool displayMenu;

  final BangData? activeBang;
  final void Function(BangData)? onSelected;
  final void Function(BangData)? onDeleted;

  final TextEditingController? searchTextController;

  const BangChips({
    required this.activeBang,
    required this.onSelected,
    required this.onDeleted,
    this.searchTextController,
    this.displayMenu = true,
  });

  static Future<bool?> resetBangDialog(
    BuildContext context,
    String triggerName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset usage frequency of $triggerName?'),
        content: const Text('This will remove the Bang from quick select.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableBangs = ref.watch(seamlessBangProvider);

    useListenableCallback(searchTextController, () {
      ref
          .read(seamlessBangProvider.notifier)
          .search(searchTextController!.text);
    });

    return availableBangs.when(
      skipLoadingOnReload: true,
      data: (availableBangs) {
        return SizedBox(
          height: 48,
          child: Row(
            children: [
              if (activeBang != null || availableBangs.isNotEmpty)
                Expanded(
                  child: SelectableChips(
                    itemId: (bang) => bang.trigger,
                    itemAvatar: (bang) =>
                        UrlIcon([bang.getTemplateUrl('')], iconSize: 20),
                    itemLabel: (bang) => Text(bang.websiteName),
                    itemTooltip: (bang) => bang.trigger,
                    availableItems: availableBangs,
                    selectedItem: activeBang,
                    onSelected: onSelected,
                    onDeleted: onDeleted,
                  ),
                )
              else
                Visibility(
                  visible: displayMenu,
                  child: Expanded(
                    child: Text(
                      "Press '>' to search Bangs.",
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              if (displayMenu)
                IconButton(
                  onPressed: () async {
                    final searchText = searchTextController?.text.trim();

                    final trigger = await BangSearchRoute(
                      searchText: (searchText.isEmpty)
                          ? BangSearchRoute.emptySearchText
                          : searchText!,
                    ).push<String?>(context);

                    if (trigger != null) {
                      ref
                          .read(selectedBangTriggerProvider().notifier)
                          .setTrigger(trigger);
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
