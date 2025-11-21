import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_details.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class UserBangs extends HookConsumerWidget {
  static const _userGroupFilter = [BangGroup.user];

  const UserBangs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bangsAsync = ref.watch(bangListProvider(groups: _userGroupFilter));

    return Scaffold(
      appBar: AppBar(title: const Text('User Bangs')),
      body: bangsAsync.when(
        data: (bangs) {
          return ListView.builder(
            itemCount: bangs.length,
            itemBuilder: (context, index) {
              final bang = bangs[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await ref
                            .read(bangDataRepositoryProvider.notifier)
                            .deleteBang(BangGroup.user, bang.trigger);
                      },
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onErrorContainer,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: BangDetails(
                  bang,
                  onTap: () async {
                    await EditUserBangRoute(
                      initialBang: jsonEncode(bang.toJson()),
                    ).push(context);
                  },
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(
          child: FailureWidget(title: 'Failed to load Bangs', exception: error),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await const NewUserBangRoute().push(context);
        },
      ),
    );
  }
}
