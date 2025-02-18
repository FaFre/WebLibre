import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';

class ContainerListTile extends HookWidget {
  final ContainerData container;
  final bool isSelected;

  final void Function()? onTap;

  const ContainerListTile(
    this.container, {
    required this.isSelected,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        selected: isSelected,
        leading: CircleAvatar(backgroundColor: container.color),
        title: Text(container.name ?? 'New Container'),
        trailing: IconButton(
          onPressed: () async {
            await context.push(ContainerEditRoute().location, extra: container);
          },
          icon: const Icon(Icons.chevron_right),
        ),
        onTap: onTap,
      ),
    );
  }
}
