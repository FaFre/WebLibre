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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_source_policy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/auto_suggest_text_field.dart';
import 'package:weblibre/presentation/widgets/qr_scanner_button.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class SearchField extends HookConsumerWidget {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final Widget? label;
  final bool autofocus;
  final void Function(String)? onSubmitted;
  final bool showSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool unfocusOnTapOutside;
  final GlobalKey? textFieldKey;
  final Widget? hint;
  final bool privateMode;

  final BangData? activeBang;
  final bool showBangIcon;

  /// Whether [activeBang] was explicitly chosen for this search — a provider
  /// chip or an inline `!bang` — rather than being the standing default.
  ///
  /// Picking a provider states the intent to *search* with it, so the inline
  /// URL completion is neither shown nor taken on enter: the field must never
  /// display a completion that submitting would ignore, and enter must never
  /// ignore the provider the user just picked.
  final bool explicitBangSelected;

  /// Overrides the clear (`x`) button behaviour. When null, the button just
  /// clears the text. When provided, the callback decides what to do (e.g.
  /// restore a previous value first, then clear on the next press).
  final VoidCallback? onClearPressed;

  const SearchField({
    super.key,
    required this.textEditingController,
    required this.onSubmitted,
    required this.activeBang,
    required this.showSuggestions,
    required this.label,
    this.focusNode,
    this.maxLines = 1,
    this.minLines = 1,
    this.unfocusOnTapOutside = true,
    this.showBangIcon = true,
    this.explicitBangSelected = false,
    this.autofocus = false,
    this.textFieldKey,
    this.hint,
    this.onClearPressed,
    this.privateMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptSuggestionOnSubmit = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.acceptSuggestionOnSubmit,
      ),
    );

    final hasText = useListenableSelector(
      textEditingController,
      () => textEditingController.text.isNotEmpty,
    );

    final safeFocusNode = focusNode ?? useFocusNode();

    // The latest completion, with whether saved history was allowed to supply
    // it. Kept even when it can no longer be shown, so nothing has to be
    // cleared in reaction to a policy change.
    final completion = useState<({String text, bool usedHistory})?>(null);
    final lastText = useRef<String>(textEditingController.text);

    // A completion that may have come from saved history is hidden whenever
    // history is off limits. The check is made here, at build time, rather
    // than when the lookup finishes: switching to a private tab must hide one
    // already on screen, and one still in flight that lands after the switch.
    final savedHistoryAllowed = ref.watch(
      searchSourcePolicyProvider(
        privateMode: privateMode,
      ).select((policy) => policy.savedHistory),
    );
    // While the keyboard is away with the field still focused — a drag on the
    // list below, or back — the completion is held back rather than shown.
    // Otherwise the tap that brings the keyboard back would land on a
    // completion the user is no longer looking at and take it. It returns with
    // the keyboard — where the cursor allows, see [cursorAtEnd].
    //
    // Watched through the metrics rather than MediaQuery, which would rebuild
    // the field on every frame of the keyboard's slide. A hardware keyboard
    // never reports an inset, so it never holds one back — but one connected
    // while the on-screen keyboard is up makes that keyboard go away for good.
    // A key pressed on it is how the user says they are typing again, so it
    // releases the completion; with the on-screen keyboard down there is no
    // other source of key events. A floating on-screen keyboard reports no
    // inset either and sends no key events, so text it commits releases the
    // completion too — see [userInputFormatter].
    final view = View.of(context);
    final keyboardShown = useRef(view.viewInsets.bottom > 0);
    final keyboardAway = useState(false);
    useEffect(() {
      final observer = _MetricsObserver(() {
        final shown = view.viewInsets.bottom > 0;
        if (keyboardShown.value && !shown && safeFocusNode.hasFocus) {
          keyboardAway.value = true;
        } else if (!keyboardShown.value && shown && keyboardAway.value) {
          keyboardAway.value = false;
        }
        keyboardShown.value = shown;
      });
      bool onHardwareKey(KeyEvent event) {
        if (event is KeyDownEvent &&
            keyboardAway.value &&
            safeFocusNode.hasFocus) {
          keyboardAway.value = false;
        }
        return false;
      }

      WidgetsBinding.instance.addObserver(observer);
      HardwareKeyboard.instance.addHandler(onHardwareKey);
      return () {
        WidgetsBinding.instance.removeObserver(observer);
        HardwareKeyboard.instance.removeHandler(onHardwareKey);
      };
    }, [view, safeFocusNode, textEditingController]);

    // A completion continues the typed text from its end, so it is shown — and
    // taken on enter — only while the cursor is there. A cursor moved into the
    // text (arrow keys, the selection handles, the tap that brought the
    // keyboard back) holds it back until the cursor returns, so enter always
    // submits what the field visibly says. No cursor placed yet counts as the
    // end: setting the text programmatically leaves the selection invalid.
    final cursorAtEnd = useListenableSelector(textEditingController, () {
      final selection = textEditingController.selection;
      return !selection.isValid ||
          (selection.isCollapsed &&
              selection.baseOffset == textEditingController.text.length);
    });

    // Input formatters run only for text the user enters — the IME, a paste —
    // never for text set on the controller, which is how a suggestion row or
    // the clipboard prompt fills the field while the keyboard is away. So only
    // real typing ends the hold-back, and the race it guards stays closed.
    final userInputFormatter = useMemoized(
      () => _UserTextInputFormatter(() => keyboardAway.value = false),
    );

    final suggestion = switch (completion.value) {
      _ when explicitBangSelected || keyboardAway.value || !cursorAtEnd => null,
      (:final text, :final usedHistory)
          when !usedHistory || savedHistoryAllowed =>
        text,
      _ => null,
    };

    if (showSuggestions) {
      useOnListenableChangeSelector(
        textEditingController,
        () => textEditingController.text,
        () async {
          final text = textEditingController.text;
          if (text.isEmpty) {
            completion.value = null;
          } else {
            final isDeleting = text.length < lastText.value.length;

            if (isDeleting) {
              completion.value = null;
            } else {
              final includeHistory = ref
                  .read(searchSourcePolicyProvider(privateMode: privateMode))
                  .savedHistory;

              final result = await ref
                  .read(engineSuggestionsProvider.notifier)
                  .getAutocompleteSuggestion(
                    text,
                    includeHistory: includeHistory,
                  );

              // Lookups finish out of order; one for text the user has since
              // typed past must not replace the newer completion.
              if (context.mounted && textEditingController.text == text) {
                completion.value = result == null
                    ? null
                    : (text: result, usedHistory: includeHistory);
              }
            }
          }

          lastText.value = text;
        },
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: AutoSuggestTextField(
        controller: textEditingController,
        suggestion: suggestion,
        acceptSuggestionOnSubmit: acceptSuggestionOnSubmit,
        enableSuggestions: true,
        autocorrect: false,
        enableIMEPersonalizedLearning: !privateMode,
        focusNode: safeFocusNode,
        maxLines: maxLines,
        textFieldKey: textFieldKey,
        keyboardType: TextInputType.webSearch,
        textInputAction: (maxLines == null || maxLines! > 1)
            ? TextInputAction.done
            : TextInputAction.send,
        minLines: minLines,
        autofocus: autofocus,
        inputFormatters: [userInputFormatter],
        onSuggestionDismiss: () {
          completion.value = null;
        },
        onSuggestionAccept: () {
          final accepted = suggestion;
          if (accepted == null) return;

          unawaited(HapticFeedback.lightImpact());

          textEditingController.text = accepted;
          textEditingController.selection = TextSelection.collapsed(
            offset: accepted.length,
          );

          completion.value = null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 12),
          prefixIcon: (showBangIcon && activeBang != null)
              ? Padding(
                  padding: const EdgeInsetsDirectional.all(12.0),
                  child: UrlIcon([activeBang!.getDefaultUrl()], iconSize: 24.0),
                )
              : null,
          label: label,
          hint: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIconConstraints: const BoxConstraints(minHeight: 48),
          suffixIcon: hasText
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: IconButton(
                    onPressed: () {
                      if (onClearPressed != null) {
                        onClearPressed!();
                      } else {
                        textEditingController.clear();
                      }
                    },
                    icon: const Icon(Icons.clear),
                  ),
                )
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrScannerButton(
                        onScanResult: (scanResult) {
                          if (scanResult?.code != null) {
                            textEditingController.text = scanResult!.code!;
                          }
                        },
                      ),
                      SpeechToTextButton(
                        onTextReceived: (data) {
                          textEditingController.text = data;
                        },
                      ),
                    ],
                  ),
                ),
        ),
        onTapOutside: unfocusOnTapOutside
            ? (event) {
                safeFocusNode.unfocus();
              }
            : null,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

/// Bridges [WidgetsBindingObserver.didChangeMetrics] to a plain callback.
class _MetricsObserver extends WidgetsBindingObserver {
  final VoidCallback onChanged;

  _MetricsObserver(this.onChanged);

  @override
  void didChangeMetrics() => onChanged();
}

/// Reports text the user entered, without changing it.
class _UserTextInputFormatter extends TextInputFormatter {
  final VoidCallback onInput;

  _UserTextInputFormatter(this.onInput);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text != oldValue.text) onInput();
    return newValue;
  }
}
