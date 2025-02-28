extension NullableX<T extends Object?> on T? {
  @pragma('vm:prefer-inline')
  R? mapNotNull<R>(R? Function(T) callback) {
    // We can simplify this by using the null-aware operator
    return this != null ? callback(this as T) : null;
  }
}

extension NullableStringX on String? {
  @pragma('vm:prefer-inline')
  String? get whenNotEmpty => (this?.isNotEmpty ?? false) ? this : null;

  @pragma('vm:prefer-inline')
  bool get isNotEmpty => this?.isNotEmpty ?? false;

  @pragma('vm:prefer-inline')
  bool get isEmpty => this?.isEmpty ?? true;
}

extension NullableIterable on Iterable? {
  @pragma('vm:prefer-inline')
  bool get isNotEmpty => this?.isNotEmpty ?? false;

  @pragma('vm:prefer-inline')
  bool get isEmpty => this?.isEmpty ?? true;
}
