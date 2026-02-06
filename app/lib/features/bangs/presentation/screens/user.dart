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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
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
        skipLoadingOnReload: true,
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
                            .deleteBang(
                              BangKey(
                                group: BangGroup.user,
                                trigger: bang.trigger,
                              ),
                            );
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
