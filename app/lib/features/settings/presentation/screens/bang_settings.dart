import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_group_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';

class BangSettingsScreen extends HookConsumerWidget {
  const BangSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bang Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: [
              CustomListTile(
                title: 'Bang Frequencies',
                subtitle: 'Tracked usage for Bang recommendations',
                suffix: FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(bangDataRepositoryProvider.notifier)
                        .resetFrequencies();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                ),
              ),
              const SettingSubSection(name: 'Repositories'),
              const BangGroupListTile(
                group: BangGroup.general,
                title: 'General Bangs',
                subtitle: 'Sync on demand from GitHub',
              ),
              const BangGroupListTile(
                group: BangGroup.assistant,
                title: 'Assistant Bangs',
                subtitle: 'Sync on-demand from GitHub',
              ),
              const BangGroupListTile(
                group: BangGroup.kagi,
                title: 'Kagi Bangs',
                subtitle: 'Sync on-demand from GitHub',
              ),
              const BangGroupListTile(
                group: BangGroup.custom,
                title: 'WebLibre Bangs',
                subtitle: 'Sync on-demand from GitHub',
              ),
            ],
          );
        },
      ),
    );
  }
}
