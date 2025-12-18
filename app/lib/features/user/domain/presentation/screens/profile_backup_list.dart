import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/services/user_backup.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

final _filenamePattern = RegExp(
  r'^backup_(?<profile>.+?)_(?<timestamp>\d{4}-\d{2}-\d{2}_\d{6})\.weblibre$',
);

class ProfileBackupListScreen extends HookConsumerWidget {
  const ProfileBackupListScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupListAsync = ref.watch(backupListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backups')),
      body: backupListAsync.when(
        data: (backupList) {
          return ListView.builder(
            itemCount: backupList.length,
            itemBuilder: (context, index) {
              final file = backupList[index];
              final match = _filenamePattern.firstMatch(p.basename(file.path));

              if (match != null) {
                final profileName = match.group(1)!;
                final datePart = match.group(2)!;

                // Reparse into DateTime
                final dateTime = UserBackupService.dateFormatter.decode(
                  datePart,
                );

                return ListTile(
                  key: ValueKey(file.path),
                  title: Text(profileName),
                  subtitle: Text(
                    ref
                        .read(formatProvider.notifier)
                        .fullDateTimeWithTimezone(dateTime),
                  ),
                  onTap: () async {
                    await RestoreProfileRoute(
                      backupFilePath: file.path,
                    ).push(context);
                  },
                );
              } else {
                return ListTile(
                  key: ValueKey(file.path),
                  title: Text(p.basename(file.path)),
                  onTap: () async {
                    await RestoreProfileRoute(
                      backupFilePath: file.path,
                    ).push(context);
                  },
                );
              }
            },
          );
        },
        error: (error, stackTrace) => FailureWidget(
          title: 'Failed to get backups',
          exception: error,
          onRetry: () {
            ref.invalidate(backupListProvider);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
