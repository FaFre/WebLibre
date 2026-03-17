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
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/onboarding/presentation/pages/abstract/i_form_page.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

class PermissionsPage extends HookConsumerWidget implements IFormPage {
  @override
  final GlobalKey<FormState> formKey;

  const PermissionsPage({super.key, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final notificationPermissionEnabled = useCachedFuture(
      () => Permission.notification.isGranted,
    );

    final isDefaultBrowser = useCachedFuture(
      () => GeckoBrowserService().isDefaultBrowser(),
    );

    final isCurrentDefaultBrowser = isDefaultBrowser.data == true;

    return BrowserPage(
      child: BrowserPageContent(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Permissions',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              Skeletonizer(
                enabled: !notificationPermissionEnabled.hasData,
                child: FormField(
                  initialValue: true,
                  onSaved: (newValue) async {
                    if (newValue == true &&
                        notificationPermissionEnabled.data != true) {
                      await Permission.notification.request();
                    }
                  },
                  builder: (field) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: field.value ?? true,
                    title: const Text('Notifications'),
                    subtitle: const Text(
                      'Required to inform about download status',
                    ),
                    onChanged: (notificationPermissionEnabled.data == true)
                        ? null
                        : (value) {
                            field.didChange(value);
                          },
                  ),
                ),
              ),
              Skeletonizer(
                enabled: !isDefaultBrowser.hasData,
                child: FormField(
                  key: ValueKey(isDefaultBrowser.data),
                  initialValue: isCurrentDefaultBrowser,
                  onSaved: (newValue) async {
                    if (newValue == true && isDefaultBrowser.data == false) {
                      await GeckoBrowserService().requestDefaultBrowser();
                    }
                  },
                  builder: (field) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: field.value ?? isCurrentDefaultBrowser,
                    title: const Text('Default Browser'),
                    subtitle: const Text(
                      'Set WebLibre as your default browser',
                    ),
                    onChanged: isCurrentDefaultBrowser
                        ? null
                        : (value) {
                            field.didChange(value);
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
