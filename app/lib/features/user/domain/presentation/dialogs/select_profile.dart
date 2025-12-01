import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/utils/exit_app.dart';

class SelectProfileDialog extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(profileRepositoryProvider);

    return AlertDialog(
      title: const Text('Manage Users'),
      scrollable: true,
      content: usersAsync.when(
        skipLoadingOnReload: true,
        data: (profiles) => Column(
          children: profiles.map((profile) {
            final isSelected = filesystem.selectedProfile == profile.uuidValue;

            return ListTile(
              key: ValueKey(profile.id),
              enabled: !isSelected,
              leading: const Icon(Icons.person),
              title: Text(profile.name),
              subtitle: isSelected ? const Text('Active') : null,
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    icon: const Icon(Icons.warning),
                    title: const Text('Switch User'),
                    content: Text(
                      "Switching to User '${profile.name}' will require a restart of the Browser",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pop(true);
                        },
                        child: const Text('Switch Profile'),
                      ),
                    ],
                  ),
                );

                if (result == true) {
                  await ref
                      .read(profileRepositoryProvider.notifier)
                      .switchProfile(profile.id);
                  await exitApp(ref.container);
                }
              },
            );
          }).toList(),
        ),
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed to load Profiles',
            exception: error,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () async {
            await ProfileListRoute().push(context);
          },
        ),
      ],
    );
  }
}
