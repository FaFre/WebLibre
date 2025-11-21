import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';

class BangMenuScreen extends HookConsumerWidget {
  const BangMenuScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bangs')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(MdiIcons.accountAlert),
            title: const Text('Manage User Bangs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await const UserBangsRoute().push(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Bangs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await const BangSearchRoute().push(context);
            },
          ),
          ListTile(
            leading: const Icon(MdiIcons.fileTree),
            title: const Text('Browse Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await const BangCategoriesRoute().push(context);
            },
          ),
        ],
      ),
    );
  }
}
