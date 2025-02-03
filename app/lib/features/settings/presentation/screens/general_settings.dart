import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/settings/presentation/controllers/save_settings.dart';
import 'package:lensai/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:lensai/features/user/data/models/general_settings.dart';
import 'package:lensai/features/user/domain/providers.dart';
import 'package:lensai/features/user/domain/repositories/cache.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';

class GeneralSettingsScreen extends HookConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final generalSettings = ref.watch(generalSettingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('Theme'),
                      leading: Icon(Icons.palette),
                      contentPadding: EdgeInsets.zero,
                    ),
                    Center(
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {generalSettings.themeMode},
                        onSelectionChanged: (value) async {
                          await ref
                              .read(saveGeneralSettingsControllerProvider
                                  .notifier)
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .themeMode(value.first),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile.adaptive(
                title: const Text('Enable Reader Mode'),
                subtitle: const Text(
                  'Optional browser app bar tool that extracts and simplifies web pages for improved readability by removing ads, sidebars, and other non-essential elements.',
                ),
                secondary: const Icon(MdiIcons.bookOpen),
                value: generalSettings.enableReadability,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.enableReadability(value),
                      );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final size = ref.watch(
                    iconCacheSizeMegabytesProvider.select(
                      (value) => value.valueOrNull,
                    ),
                  );

                  return CustomListTile(
                    title: 'Icon Cache',
                    subtitle: 'Stored favicons',
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.image,
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DefaultTextStyle(
                        style: GoogleFonts.robotoMono(
                          textStyle: DefaultTextStyle.of(context).style,
                        ),
                        child: Table(
                          columnWidths: const {0: FixedColumnWidth(100)},
                          children: [
                            TableRow(
                              children: [
                                const Text('Size'),
                                Text('${size?.toStringAsFixed(2) ?? 0} MB'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    suffix: FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(cacheRepositoryProvider.notifier)
                            .clearCache();
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Clear'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
