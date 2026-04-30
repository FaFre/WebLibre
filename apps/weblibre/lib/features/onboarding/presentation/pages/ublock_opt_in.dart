/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/onboarding/presentation/pages/abstract/i_form_page.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';
import 'package:weblibre/features/user/data/providers/ublock_assets.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

class UBlockOptInPage extends HookConsumerWidget implements IFormPage {
  @override
  final GlobalKey<FormState> formKey;

  const UBlockOptInPage({super.key, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final installUBlock = useState(true);

    return BrowserPage(
      child: BrowserPageContent(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              SvgPicture.asset('assets/images/ublock.svg'),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'uBlock Origin',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              const MarkdownBody(
                data: '''
uBlock Origin (uBO) is a CPU and memory-efficient **wide-spectrum content blocker** by **Raymond Hill** and available as a browser extensions for WebLibre.

It blocks ads, trackers, coin miners, popups, annoying anti-blockers, malware sites, etc., by default using **EasyList, EasyPrivacy, Peter Lowe's Blocklist, Online Malicious URL Blocklist, and uBO filter lists**.

There are many other lists available to block even more.
                ''',
              ),
              const SizedBox(height: 24),
              FormField(
                initialValue: true,
                onSaved: (newValue) {
                  installUBlock.value = newValue ?? false;
                  if (newValue == true) {
                    unawaited(
                      ref
                          .read(browserAddonServiceProvider.notifier)
                          .install('uBlock0@raymondhill.net'),
                    );
                  }
                },
                builder: (field) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: field.value ?? false,
                  title: const Text('Install uBlock Origin Extension'),
                  onChanged: (value) {
                    field.didChange(value);
                    installUBlock.value = value;
                  },
                ),
              ),
              FormField(
                initialValue: true,
                onSaved: (newValue) {
                  if (newValue != true || !installUBlock.value) return;

                  Future<void> applyOptimizedDefaults() async {
                    try {
                      final registry = await ref.read(
                        ublockAssetsRegistryProvider.future,
                      );
                      final optimized =
                          UBlockFilterListSettings.optimizedDefaults(registry);
                      await ref
                          .read(engineSettingsRepositoryProvider.notifier)
                          .updateSettings(
                            (current) => current.copyWith
                                .ublockFilterListSettings(optimized),
                          );
                    } catch (e, s) {
                      logger.w(
                        'Failed applying optimized uBlock defaults during onboarding',
                        error: e,
                        stackTrace: s,
                      );
                    }
                  }

                  unawaited(applyOptimizedDefaults());
                },
                builder: (field) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: field.value ?? false,
                  title: const Text('Apply optimized defaults'),
                  subtitle: const Text(
                    'Enable WebLibre hardening filter lists.',
                  ),
                  onChanged: installUBlock.value
                      ? (value) {
                          field.didChange(value);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
