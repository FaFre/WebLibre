import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/profile.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class ProfileListScreen extends HookConsumerWidget {
  const ProfileListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(profileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        skipLoadingOnReload: true,
        data: (profiles) => ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            final isSelected = filesystem.selectedProfile == profile.uuidValue;

            return ListTile(
              enabled: !isSelected,
              leading: const Icon(Icons.person),
              title: Text(profile.name),
              subtitle: isSelected ? const Text('Active') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await EditProfileRoute(
                  profile: jsonEncode(profile.toJson()),
                ).push(context);
              },
            );
          },
        ),
        error: (error, stackTrace) => Center(
          child: FailureWidget(
            title: 'Failed to load Profiles',
            exception: error,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await CreateProfileRoute().push(context);
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
