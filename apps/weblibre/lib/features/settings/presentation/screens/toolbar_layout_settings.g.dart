// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_layout_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ToolbarLayoutEditorViewStateCWProxy {
  ToolbarLayoutEditorViewState device(PreviewDevice device);

  ToolbarLayoutEditorViewState sampleState(PreviewSampleState sampleState);

  ToolbarLayoutEditorViewState mode(PreviewMode mode);

  ToolbarLayoutEditorViewState selectedPart(LayoutPart? selectedPart);

  ToolbarLayoutEditorViewState revealEditor(({LayoutPart part})? revealEditor);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ToolbarLayoutEditorViewState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ToolbarLayoutEditorViewState(...).copyWith(id: 12, name: "My name")
  /// ```
  ToolbarLayoutEditorViewState call({
    PreviewDevice device,
    PreviewSampleState sampleState,
    PreviewMode mode,
    LayoutPart? selectedPart,
    ({LayoutPart part})? revealEditor,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfToolbarLayoutEditorViewState.copyWith(...)` or call `instanceOfToolbarLayoutEditorViewState.copyWith.fieldName(value)` for a single field.
class _$ToolbarLayoutEditorViewStateCWProxyImpl
    implements _$ToolbarLayoutEditorViewStateCWProxy {
  const _$ToolbarLayoutEditorViewStateCWProxyImpl(this._value);

  final ToolbarLayoutEditorViewState _value;

  @override
  ToolbarLayoutEditorViewState device(PreviewDevice device) =>
      call(device: device);

  @override
  ToolbarLayoutEditorViewState sampleState(PreviewSampleState sampleState) =>
      call(sampleState: sampleState);

  @override
  ToolbarLayoutEditorViewState mode(PreviewMode mode) => call(mode: mode);

  @override
  ToolbarLayoutEditorViewState selectedPart(LayoutPart? selectedPart) =>
      call(selectedPart: selectedPart);

  @override
  ToolbarLayoutEditorViewState revealEditor(
    ({LayoutPart part})? revealEditor,
  ) => call(revealEditor: revealEditor);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `ToolbarLayoutEditorViewState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// ToolbarLayoutEditorViewState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  ToolbarLayoutEditorViewState call({
    Object? device = const $CopyWithPlaceholder(),
    Object? sampleState = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? selectedPart = const $CopyWithPlaceholder(),
    Object? revealEditor = const $CopyWithPlaceholder(),
  }) {
    return ToolbarLayoutEditorViewState(
      device: device == const $CopyWithPlaceholder() || device == null
          ? _value.device
          // ignore: cast_nullable_to_non_nullable
          : device as PreviewDevice,
      sampleState:
          sampleState == const $CopyWithPlaceholder() || sampleState == null
          ? _value.sampleState
          // ignore: cast_nullable_to_non_nullable
          : sampleState as PreviewSampleState,
      mode: mode == const $CopyWithPlaceholder() || mode == null
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as PreviewMode,
      selectedPart: selectedPart == const $CopyWithPlaceholder()
          ? _value.selectedPart
          // ignore: cast_nullable_to_non_nullable
          : selectedPart as LayoutPart?,
      revealEditor: revealEditor == const $CopyWithPlaceholder()
          ? _value.revealEditor
          // ignore: cast_nullable_to_non_nullable
          : revealEditor as ({LayoutPart part})?,
    );
  }
}

extension $ToolbarLayoutEditorViewStateCopyWith
    on ToolbarLayoutEditorViewState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfToolbarLayoutEditorViewState.copyWith(...)` or `instanceOfToolbarLayoutEditorViewState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ToolbarLayoutEditorViewStateCWProxy get copyWith =>
      _$ToolbarLayoutEditorViewStateCWProxyImpl(this);
}
