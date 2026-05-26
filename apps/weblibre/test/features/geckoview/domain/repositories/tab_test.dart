import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

void main() {
  group('resolveAssignedContainerForTabOpen', () {
    final selectedContainer = _container('selected', 'selected-context');
    final siteAssignedContainer = _container('assigned', 'assigned-context');

    test('prefers the site-assigned container for useSelected', () {
      final resolved = resolveAssignedContainerForTabOpen(
        containerSelection: const TabContainerSelection.useSelected(),
        requestedContainer: selectedContainer,
        siteAssignedContainer: siteAssignedContainer,
      );

      expect(resolved, siteAssignedContainer);
    });

    test(
      'falls back to the requested container when no site assignment exists',
      () {
        final resolved = resolveAssignedContainerForTabOpen(
          containerSelection: const TabContainerSelection.useSelected(),
          requestedContainer: selectedContainer,
          siteAssignedContainer: null,
        );

        expect(resolved, selectedContainer);
      },
    );

    test('preserves an explicit specific container selection', () {
      final explicitContainer = _container('explicit', 'explicit-context');

      final resolved = resolveAssignedContainerForTabOpen(
        containerSelection: TabContainerSelection.specific(explicitContainer),
        requestedContainer: explicitContainer,
        siteAssignedContainer: siteAssignedContainer,
      );

      expect(resolved, explicitContainer);
    });

    test('preserves an explicit unassigned selection', () {
      final resolved = resolveAssignedContainerForTabOpen(
        containerSelection: const TabContainerSelection.unassigned(),
        requestedContainer: null,
        siteAssignedContainer: siteAssignedContainer,
      );

      expect(resolved, isNull);
    });
  });
}

ContainerData _container(String id, String contextId) {
  return ContainerData(
    id: id,
    name: id,
    color: Colors.blue,
    orderKey: id,
    metadata: ContainerMetadata.withDefaults(contextualIdentity: contextId),
  );
}
