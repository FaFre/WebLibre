extension UniqueItems<T> on Iterable<T> {
  Iterable<T> findDuplicates() sync* {
    final seen = <T>{};

    for (final item in this) {
      if (seen.contains(item)) {
        yield item;
      } else {
        seen.add(item);
      }
    }
  }
}
