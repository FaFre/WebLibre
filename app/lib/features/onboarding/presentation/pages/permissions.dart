import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/onboarding/presentation/pages/abstract/i_form_page.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';

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

    return Form(
      key: formKey,
      child: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Text('Permissions', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 24),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: const Text('WebLibre requires following permissions'),
          // ),
          // const SizedBox(height: 24),
          Skeletonizer(
            enabled: !notificationPermissionEnabled.hasData,
            child: FormField(
              initialValue: true,
              onSaved: (newValue) async {
                if (newValue == true) {
                  await Permission.notification.request();
                }
              },
              builder: (field) => SwitchListTile(
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
        ],
      ),
    );
  }
}
