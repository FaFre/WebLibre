// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'small_web_session_controller.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SmallWebSessionStateCWProxy {
  SmallWebSessionState sourceKind(SmallWebSourceKind sourceKind);

  SmallWebSessionState mode(KagiSmallWebMode? mode);

  SmallWebSessionState currentCategory(String? currentCategory);

  SmallWebSessionState currentItemId(String? currentItemId);

  SmallWebSessionState currentItemUrl(Uri? currentItemUrl);

  SmallWebSessionState currentConsoleUrl(Uri? currentConsoleUrl);

  SmallWebSessionState infoMessage(String? infoMessage);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SmallWebSessionState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SmallWebSessionState(...).copyWith(id: 12, name: "My name")
  /// ```
  SmallWebSessionState call({
    SmallWebSourceKind sourceKind,
    KagiSmallWebMode? mode,
    String? currentCategory,
    String? currentItemId,
    Uri? currentItemUrl,
    Uri? currentConsoleUrl,
    String? infoMessage,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSmallWebSessionState.copyWith(...)` or call `instanceOfSmallWebSessionState.copyWith.fieldName(value)` for a single field.
class _$SmallWebSessionStateCWProxyImpl
    implements _$SmallWebSessionStateCWProxy {
  const _$SmallWebSessionStateCWProxyImpl(this._value);

  final SmallWebSessionState _value;

  @override
  SmallWebSessionState sourceKind(SmallWebSourceKind sourceKind) =>
      call(sourceKind: sourceKind);

  @override
  SmallWebSessionState mode(KagiSmallWebMode? mode) => call(mode: mode);

  @override
  SmallWebSessionState currentCategory(String? currentCategory) =>
      call(currentCategory: currentCategory);

  @override
  SmallWebSessionState currentItemId(String? currentItemId) =>
      call(currentItemId: currentItemId);

  @override
  SmallWebSessionState currentItemUrl(Uri? currentItemUrl) =>
      call(currentItemUrl: currentItemUrl);

  @override
  SmallWebSessionState currentConsoleUrl(Uri? currentConsoleUrl) =>
      call(currentConsoleUrl: currentConsoleUrl);

  @override
  SmallWebSessionState infoMessage(String? infoMessage) =>
      call(infoMessage: infoMessage);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SmallWebSessionState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SmallWebSessionState(...).copyWith(id: 12, name: "My name")
  /// ```
  SmallWebSessionState call({
    Object? sourceKind = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
    Object? currentCategory = const $CopyWithPlaceholder(),
    Object? currentItemId = const $CopyWithPlaceholder(),
    Object? currentItemUrl = const $CopyWithPlaceholder(),
    Object? currentConsoleUrl = const $CopyWithPlaceholder(),
    Object? infoMessage = const $CopyWithPlaceholder(),
  }) {
    return SmallWebSessionState(
      sourceKind:
          sourceKind == const $CopyWithPlaceholder() || sourceKind == null
          ? _value.sourceKind
          // ignore: cast_nullable_to_non_nullable
          : sourceKind as SmallWebSourceKind,
      mode: mode == const $CopyWithPlaceholder()
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as KagiSmallWebMode?,
      currentCategory: currentCategory == const $CopyWithPlaceholder()
          ? _value.currentCategory
          // ignore: cast_nullable_to_non_nullable
          : currentCategory as String?,
      currentItemId: currentItemId == const $CopyWithPlaceholder()
          ? _value.currentItemId
          // ignore: cast_nullable_to_non_nullable
          : currentItemId as String?,
      currentItemUrl: currentItemUrl == const $CopyWithPlaceholder()
          ? _value.currentItemUrl
          // ignore: cast_nullable_to_non_nullable
          : currentItemUrl as Uri?,
      currentConsoleUrl: currentConsoleUrl == const $CopyWithPlaceholder()
          ? _value.currentConsoleUrl
          // ignore: cast_nullable_to_non_nullable
          : currentConsoleUrl as Uri?,
      infoMessage: infoMessage == const $CopyWithPlaceholder()
          ? _value.infoMessage
          // ignore: cast_nullable_to_non_nullable
          : infoMessage as String?,
    );
  }
}

extension $SmallWebSessionStateCopyWith on SmallWebSessionState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSmallWebSessionState.copyWith(...)` or `instanceOfSmallWebSessionState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SmallWebSessionStateCWProxy get copyWith =>
      _$SmallWebSessionStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SmallWebSessionState _$SmallWebSessionStateFromJson(
  Map<String, dynamic> json,
) => SmallWebSessionState(
  sourceKind:
      $enumDecodeNullable(_$SmallWebSourceKindEnumMap, json['sourceKind']) ??
      SmallWebSourceKind.kagi,
  mode: $enumDecodeNullable(_$KagiSmallWebModeEnumMap, json['mode']),
  currentCategory: json['currentCategory'] as String?,
  currentItemId: json['currentItemId'] as String?,
  currentItemUrl: json['currentItemUrl'] == null
      ? null
      : Uri.parse(json['currentItemUrl'] as String),
  currentConsoleUrl: json['currentConsoleUrl'] == null
      ? null
      : Uri.parse(json['currentConsoleUrl'] as String),
);

Map<String, dynamic> _$SmallWebSessionStateToJson(
  SmallWebSessionState instance,
) => <String, dynamic>{
  'sourceKind': _$SmallWebSourceKindEnumMap[instance.sourceKind]!,
  'mode': _$KagiSmallWebModeEnumMap[instance.mode],
  'currentCategory': instance.currentCategory,
  'currentItemId': instance.currentItemId,
  'currentItemUrl': instance.currentItemUrl?.toString(),
  'currentConsoleUrl': instance.currentConsoleUrl?.toString(),
};

const _$SmallWebSourceKindEnumMap = {
  SmallWebSourceKind.kagi: 'kagi',
  SmallWebSourceKind.wander: 'wander',
};

const _$KagiSmallWebModeEnumMap = {
  KagiSmallWebMode.web: 'web',
  KagiSmallWebMode.appreciated: 'appreciated',
  KagiSmallWebMode.videos: 'videos',
  KagiSmallWebMode.code: 'code',
  KagiSmallWebMode.comics: 'comics',
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SmallWebSessionController)
final smallWebSessionControllerProvider = SmallWebSessionControllerProvider._();

final class SmallWebSessionControllerProvider
    extends
        $NotifierProvider<
          SmallWebSessionController,
          AsyncValue<SmallWebSessionState>
        > {
  SmallWebSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smallWebSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smallWebSessionControllerHash();

  @$internal
  @override
  SmallWebSessionController create() => SmallWebSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SmallWebSessionState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SmallWebSessionState>>(
        value,
      ),
    );
  }
}

String _$smallWebSessionControllerHash() =>
    r'90680807b38de577e3322941b47792952d66428a';

abstract class _$SmallWebSessionController
    extends $Notifier<AsyncValue<SmallWebSessionState>> {
  AsyncValue<SmallWebSessionState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<SmallWebSessionState>,
              AsyncValue<SmallWebSessionState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SmallWebSessionState>,
                AsyncValue<SmallWebSessionState>
              >,
              AsyncValue<SmallWebSessionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
