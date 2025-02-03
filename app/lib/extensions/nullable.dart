extension NullableX<T> on T? {
  @pragma('vm:prefer-inline')
  R? mapNotNull<R>(R? Function(T) callback) {
    // ignore: null_check_on_nullable_type_parameter
    return (this != null) ? callback(this!) : null;
  }
}
