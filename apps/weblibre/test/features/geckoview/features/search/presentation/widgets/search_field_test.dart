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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/search/domain/entities/search_source_policy.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_source_policy.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Answers each completion lookup only when the test says so, and records
/// whether the lookup was allowed to use saved history.
class _ControlledEngine extends EngineSuggestions {
  final lookups =
      <({String query, bool includeHistory, Completer<String?> answer})>[];

  @override
  Stream<List<GeckoSuggestion>> build() => const Stream.empty();

  @override
  Future<String?> getAutocompleteSuggestion(
    String query, {
    bool includeHistory = true,
  }) {
    final answer = Completer<String?>();
    lookups.add((query: query, includeHistory: includeHistory, answer: answer));
    return answer.future;
  }
}

void main() {
  late _ControlledEngine engine;
  late TextEditingController controller;

  setUp(() {
    engine = _ControlledEngine();
    // Never empty, so the field shows its clear button rather than the QR and
    // speech buttons, which talk to platform channels.
    controller = TextEditingController(text: 'gi');
  });

  tearDown(() => controller.dispose());

  // The scope is built inside `pumpWidget` rather than returned from a helper:
  // a `ProviderScope` handed to it directly is the root one, and only a nested
  // scope has to declare `dependencies`. Pumping it again with a different
  // mode keeps the same element, so the field keeps its state.
  Future<void> pumpHarness(WidgetTester tester, {required bool privateMode}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          engineSuggestionsProvider.overrideWith(() => engine),
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults(),
          ),
          searchSourcePolicyProvider(privateMode: false).overrideWithValue(
            SearchSourcePolicy(remoteSuggestions: true, savedHistory: true),
          ),
          searchSourcePolicyProvider(privateMode: true).overrideWithValue(
            SearchSourcePolicy(remoteSuggestions: false, savedHistory: false),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SearchField(
              textEditingController: controller,
              onSubmitted: (_) {},
              activeBang: null,
              showSuggestions: true,
              label: const Text('Search'),
              privateMode: privateMode,
            ),
          ),
        ),
      ),
    );
  }

  /// Lets a completed lookup reach the field: one pump resumes the awaiting
  /// listener, the next builds what it stored.
  Future<void> landLookup(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  Finder ghost(String rest) => find.textContaining(rest, findRichText: true);

  testWidgets('a history completion on screen hides when the search turns '
      'private', (tester) async {
    await pumpHarness(tester, privateMode: false);

    controller.text = 'git';
    await tester.pump();
    expect(engine.lookups.single.includeHistory, isTrue);

    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);
    expect(ghost('hub.com'), findsOneWidget);

    // Same ProviderScope and element: only the mode flips.
    await pumpHarness(tester, privateMode: true);

    expect(tester.takeException(), isNull);
    expect(ghost('hub.com'), findsNothing);
  });

  testWidgets('a history lookup that lands after the switch stays hidden', (
    tester,
  ) async {
    await pumpHarness(tester, privateMode: false);

    controller.text = 'git';
    await tester.pump();
    final pending = engine.lookups.single;
    expect(pending.includeHistory, isTrue);

    await pumpHarness(tester, privateMode: true);
    pending.answer.complete('github.com');
    await landLookup(tester);

    expect(tester.takeException(), isNull);
    expect(ghost('hub.com'), findsNothing);
  });

  testWidgets('a private lookup made without history is shown', (tester) async {
    await pumpHarness(tester, privateMode: true);

    controller.text = 'git';
    await tester.pump();
    final lookup = engine.lookups.single;
    expect(lookup.includeHistory, isFalse);

    // A bookmark or popular-site completion.
    lookup.answer.complete('github.com');
    await landLookup(tester);

    expect(ghost('hub.com'), findsOneWidget);
  });
}
