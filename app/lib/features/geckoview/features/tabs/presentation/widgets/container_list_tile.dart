import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

class ContainerListTile extends HookWidget {
  final ContainerData container;
  final bool isSelected;

  const ContainerListTile(
    this.container, {
    required this.isSelected,
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
        onTap: () async {
          await ContainerEditRoute(container).push(context);
        },
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
