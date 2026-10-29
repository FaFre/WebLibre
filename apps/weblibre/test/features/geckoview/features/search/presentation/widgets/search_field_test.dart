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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
///
/// The lookups list is shared, so every instance Riverpod builds after an
/// auto-dispose reports into the same record.
class _ControlledEngine extends EngineSuggestions {
  final List<({String query, bool includeHistory, Completer<String?> answer})>
  lookups;

  _ControlledEngine([
    List<({String query, bool includeHistory, Completer<String?> answer})>?
    lookups,
  ]) : lookups = lookups ?? [];

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
  Future<void> pumpHarness(
    WidgetTester tester, {
    required bool privateMode,
    bool explicitBangSelected = false,
    void Function(String)? onSubmitted,
  }) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          engineSuggestionsProvider.overrideWith(
            () => _ControlledEngine(engine.lookups),
          ),
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
              onSubmitted: onSubmitted ?? (_) {},
              activeBang: null,
              showSuggestions: true,
              label: const Text('Search'),
              privateMode: privateMode,
              explicitBangSelected: explicitBangSelected,
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

  testWidgets('enter takes the completion when no provider is picked', (
    tester,
  ) async {
    final submitted = <String>[];
    await pumpHarness(tester, privateMode: false, onSubmitted: submitted.add);

    controller.text = 'git';
    await tester.pump();
    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);

    await tester.showKeyboard(find.byType(TextFormField));
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(submitted, ['github.com']);
  });

  testWidgets('a picked provider hides the completion and enter searches', (
    tester,
  ) async {
    final submitted = <String>[];
    await pumpHarness(
      tester,
      privateMode: false,
      explicitBangSelected: true,
      onSubmitted: submitted.add,
    );

    controller.text = 'git';
    await tester.pump();
    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);

    expect(ghost('hub.com'), findsNothing);

    await tester.showKeyboard(find.byType(TextFormField));
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(submitted, ['git']);
  });

  group('tapping a field that shows a completion', () {
    /// Types `git`, lands `github.com` and returns the real field's editable.
    Future<RenderEditable> showCompletion(WidgetTester tester) async {
      await pumpHarness(tester, privateMode: false);

      controller.text = 'git';
      await tester.pump();
      engine.lookups.single.answer.complete('github.com');
      await landLookup(tester);
      expect(ghost('hub.com'), findsOneWidget);

      RenderEditable? find_(RenderObject node) {
        if (node is RenderEditable) return node;
        RenderEditable? found;
        node.visitChildren((child) => found ??= find_(child));
        return found;
      }

      return find_(tester.renderObject(find.byType(TextFormField)))!;
    }

    /// [dx] logical pixels past the caret at [offset], on the text's line.
    Offset besideCaret(RenderEditable editable, int offset, double dx) {
      final caret = editable.getLocalRectForCaret(TextPosition(offset: offset));
      return editable.localToGlobal(Offset(caret.left + dx, caret.center.dy));
    }

    testWidgets('on the completion takes it', (tester) async {
      final editable = await showCompletion(tester);

      await tester.tapAt(besideCaret(editable, 3, 24));
      await tester.pump();

      expect(controller.text, 'github.com');
      expect(controller.selection, const TextSelection.collapsed(offset: 10));
    });

    testWidgets('inside the typed text places the cursor and drops it', (
      tester,
    ) async {
      final editable = await showCompletion(tester);

      await tester.tapAt(besideCaret(editable, 1, 1));
      await tester.pump();

      expect(controller.text, 'git');
      expect(controller.selection.baseOffset, lessThan(3));
      expect(ghost('hub.com'), findsNothing);
    });

    testWidgets('at the end of the typed text leaves it alone', (tester) async {
      final editable = await showCompletion(tester);

      await tester.tapAt(besideCaret(editable, 3, 2));
      await tester.pump();

      expect(controller.text, 'git');
      expect(ghost('hub.com'), findsOneWidget);
    });
  });

  group('the keyboard going away while the field keeps focus', () {
    Future<void> showWithKeyboard(WidgetTester tester) async {
      addTearDown(tester.view.reset);
      await pumpHarness(tester, privateMode: false);

      await tester.showKeyboard(find.byType(TextFormField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pump();

      controller.text = 'git';
      await tester.pump();
      engine.lookups.single.answer.complete('github.com');
      await landLookup(tester);
      expect(ghost('hub.com'), findsOneWidget);

      // A drag on the list, or back: the keyboard hides, focus stays.
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump();
    }

    testWidgets('holds the completion back', (tester) async {
      await showWithKeyboard(tester);

      expect(controller.text, 'git');
      expect(ghost('hub.com'), findsNothing);
    });

    testWidgets('brings it back with the keyboard', (tester) async {
      await showWithKeyboard(tester);

      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pump();

      expect(ghost('hub.com'), findsOneWidget);
      // Nothing was typed: no new lookup was needed.
      expect(engine.lookups, hasLength(1));
    });

    testWidgets('holds it back if the cursor came back inside the typed text', (
      tester,
    ) async {
      await showWithKeyboard(tester);

      controller.selection = const TextSelection.collapsed(offset: 1);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pump();

      expect(ghost('hub.com'), findsNothing);
    });
  });

  testWidgets('a hardware keyboard connected while the on-screen one was up '
      'releases the completion once it is used', (tester) async {
    addTearDown(tester.view.reset);
    await pumpHarness(tester, privateMode: false);

    await tester.showKeyboard(find.byType(TextFormField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    await tester.pump();

    controller.text = 'git';
    await tester.pump();
    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);

    // Connecting it takes the on-screen keyboard away, and it never returns.
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
    expect(ghost('hub.com'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(ghost('hub.com'), findsOneWidget);
  });

  testWidgets('a hardware key press with the cursor inside the typed text '
      'does not bring the completion back', (tester) async {
    final submitted = <String>[];
    addTearDown(tester.view.reset);
    await pumpHarness(tester, privateMode: false, onSubmitted: submitted.add);

    await tester.showKeyboard(find.byType(TextFormField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    await tester.pump();

    controller.text = 'git';
    await tester.pump();
    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();

    // The cursor moved into the text while the completion was held back.
    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();

    expect(ghost('hub.com'), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(submitted, ['git']);
  });

  testWidgets('moving the cursor into the text holds the completion back '
      'until it returns to the end', (tester) async {
    final submitted = <String>[];
    await pumpHarness(tester, privateMode: false, onSubmitted: submitted.add);
    await tester.showKeyboard(find.byType(TextFormField));

    controller.text = 'git';
    await tester.pump();
    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);
    expect(ghost('hub.com'), findsOneWidget);

    controller.selection = const TextSelection.collapsed(offset: 1);
    await tester.pump();
    expect(ghost('hub.com'), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(submitted, ['git']);

    controller.selection = const TextSelection.collapsed(offset: 3);
    await tester.pump();
    expect(ghost('hub.com'), findsOneWidget);
  });

  group('after the keyboard went away with the field focused', () {
    Future<void> hideKeyboard(WidgetTester tester) async {
      addTearDown(tester.view.reset);
      await pumpHarness(tester, privateMode: false);

      await tester.showKeyboard(find.byType(TextFormField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pump();

      // Docked → floating: the inset drops to zero and stays there.
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pump();
    }

    testWidgets('typing on a floating keyboard shows completions again', (
      tester,
    ) async {
      await hideKeyboard(tester);

      // Text the IME commits, with no key events and no inset.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'git',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      await tester.pump();
      engine.lookups.last.answer.complete('github.com');
      await landLookup(tester);

      expect(ghost('hub.com'), findsOneWidget);
    });

    testWidgets('text set on the controller keeps the completion held back', (
      tester,
    ) async {
      await hideKeyboard(tester);

      // A suggestion row or the clipboard prompt filling the field: the tap
      // that brings the keyboard back must still have nothing to take.
      controller.text = 'git';
      await tester.pump();
      engine.lookups.last.answer.complete('github.com');
      await landLookup(tester);

      expect(ghost('hub.com'), findsNothing);
    });
  });

  testWidgets('a field that never had an on-screen keyboard keeps its '
      'completion', (tester) async {
    // A hardware keyboard reports no inset at all.
    await pumpHarness(tester, privateMode: false);
    await tester.showKeyboard(find.byType(TextFormField));

    controller.text = 'git';
    await tester.pump();
    engine.lookups.single.answer.complete('github.com');
    await landLookup(tester);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();

    expect(ghost('hub.com'), findsOneWidget);
  });
}
