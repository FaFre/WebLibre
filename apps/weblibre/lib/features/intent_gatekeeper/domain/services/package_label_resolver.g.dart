// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_label_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(packageLabel)
final packageLabelProvider = PackageLabelFamily._();

final class PackageLabelProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  PackageLabelProvider._({
    required PackageLabelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'packageLabelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$packageLabelHash();

  @override
  String toString() {
    return r'packageLabelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return packageLabel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PackageLabelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$packageLabelHash() => r'14f966e502c5dde332cc42d52727ab111bf6a2b2';

final class PackageLabelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  PackageLabelFamily._()
    : super(
        retry: null,
        name: r'packageLabelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PackageLabelProvider call(String packageName) =>
      PackageLabelProvider._(argument: packageName, from: this);

  @override
  String toString() => r'packageLabelProvider';
}
