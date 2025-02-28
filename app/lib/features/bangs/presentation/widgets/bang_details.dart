import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/presentation/widgets/url_icon.dart';

class BangDetails extends HookConsumerWidget {
  final BangData bangData;
  final void Function()? onTap;

  const BangDetails(this.bangData, {this.onTap, super.key});

  String? _categoryString(BangData bang) {
    if (bang.category == null) {
      return null;
    } else if (bang.subCategory == null) {
      return bang.category;
    } else {
      return '${bang.category} / ${bang.subCategory}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrlIcon(bangData.getUrl(''), iconSize: 34.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bangData.websiteName.trim(),
                          style: theme.textTheme.titleMedium,
                        ),
                        if (bangData.category != null)
                          Text(
                            _categoryString(bangData)!,
                            style: theme.textTheme.titleSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonalIcon(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      final url = Uri.parse(bangData.getUrl('').origin);

                      await ref
                          .read(tabRepositoryProvider.notifier)
                          .addTab(url: url);

                      if (context.mounted) {
                        context.go(BrowserRoute().location);
                      }
                    },
                    label: Text(bangData.domain),
                    icon: const Icon(Icons.open_in_new),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '!${bangData.trigger}',
                      style: theme.textTheme.titleSmall,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
