import 'dart:ui' as ui;

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/bangs/presentation/widgets/site_search.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';
import 'package:lensai/features/chat/features/chat_store/domain/repositories/chat_metadata.dart';
import 'package:lensai/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/widgets/browser_modules/address_with_suggestions_field.dart';
import 'package:lensai/features/user/domain/providers.dart';
import 'package:lensai/presentation/widgets/failure_widget.dart';
import 'package:lensai/presentation/widgets/website_title_tile.dart';
import 'package:lensai/utils/ui_helper.dart' as ui_helper;

import 'package:share_plus/share_plus.dart';

class WebPageDialog extends HookConsumerWidget {
  final Uri url;
  final WebPageInfo? precachedInfo;

  const WebPageDialog({required this.url, this.precachedInfo, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(incognitoModeEnabledProvider);

    final availableBangsAsync = ref.watch(
      bangListProvider(domain: url.host, orderMostFrequentFirst: true),
    );

    final availableBangCount = availableBangsAsync.valueOrNull?.length;

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 64.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
              child: WebsiteTitleTile(url, precachedInfo: precachedInfo),
            ),
            SizedBox(
              //We need this to stretch the dialog, then padding from dialog is applied
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AddressWithSuggestionsField(
                  url: url,
                  incognitoEnabled: incognitoEnabled,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(),
            Flexible(
              child: FadingScroll(
                fadingSize: 25,
                builder: (context, controller) {
                  return SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: availableBangsAsync.when(
                            data: (availableBangs) {
                              if (availableBangs.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return SiteSearch(
                                domain: url.host,
                                availableBangs: availableBangs,
                                searchInNewTab: false,
                              );
                            },
                            error:
                                (error, stackTrace) => FailureWidget(
                                  title: 'Could not load bangs',
                                  exception: error,
                                ),
                            loading:
                                () => SiteSearch(
                                  domain: url.host,
                                  availableBangs: [
                                    BangData(
                                      websiteName: 'websiteName',
                                      domain: 'domain',
                                      trigger: 'trigger',
                                      urlTemplate: 'urlTemplate',
                                    ),
                                  ],
                                ),
                          ),
                        ),
                        if (availableBangsAsync.isLoading ||
                            availableBangCount == null ||
                            availableBangCount > 0)
                          const Divider(),
                        ListTile(
                          leading: const Icon(MdiIcons.contentCopy),
                          title: const Text('Copy address'),
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: url.toString()),
                            );
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                        ListTile(
                          onTap: () async {
                            await ui_helper.launchUrlFeedback(context, url);
                          },
                          leading: const Icon(Icons.open_in_browser),
                          title: const Text('Launch External'),
                        ),
                        ListTile(
                          leading: const Icon(MdiIcons.tabPlus),
                          title: const Text('Clone tab'),
                          onTap: () async {
                            await ref
                                .read(tabRepositoryProvider.notifier)
                                .addTab(url: url);

                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.share),
                          title: const Text('Share link'),
                          onTap: () async {
                            await Share.shareUri(url);

                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.mobile_screen_share),
                          title: const Text('Share screenshot'),
                          onTap: () async {
                            final screenshot =
                                await ref
                                    .read(selectedTabSessionNotifierProvider)
                                    .requestScreenshot();

                            if (screenshot != null) {
                              ui.decodeImageFromList(screenshot, (
                                result,
                              ) async {
                                final png = await result.toByteData(
                                  format: ui.ImageByteFormat.png,
                                );

                                if (png != null) {
                                  final file = XFile.fromData(
                                    png.buffer.asUint8List(),
                                    mimeType: 'image/png',
                                  );

                                  await Share.shareXFiles([
                                    file,
                                  ], subject: precachedInfo?.title);
                                }
                              });
                            }

                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(MdiIcons.brain),
                          title: const Text('QA Chat'),
                          onTap: () async {
                            final selectedTabId =
                                ref.read(selectedTabStateProvider)?.id;

                            if (selectedTabId != null) {
                              final updateResult = await ref
                                  .read(
                                    chatMetadataRepositoryProvider(
                                      selectedTabId,
                                    ).notifier,
                                  )
                                  .updateMetadata(
                                    ChatMetadata(mainDocumentId: selectedTabId),
                                  );

                              updateResult.onSuccess((_) {
                                ref
                                    .read(
                                      bottomSheetControllerProvider.notifier,
                                    )
                                    .show(
                                      TabQaChatSheet(chatId: selectedTabId),
                                    );
                              });
                            }

                            if (context.mounted) {
                              context.pop();
                            }
                          },
                        ),
                        // ListTile(
                        //   leading: Icon(MdiIcons.text),
                        //   title: const Text('Summarize'),
                        //   onTap: () async {
                        //     final summarizerUrl = uri_builder.summarizerUri(
                        //       document: SharedUrl(url),
                        //       mode: SummarizerMode.keyMoments,
                        //     );

                        //     await ref
                        //         .read(tabRepositoryProvider.notifier)
                        //         .addTab(url: summarizerUrl);

                        //     if (context.mounted) {
                        //       context.pop();
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
