import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useListenableCallback(Listenable? listenable, void Function() callback,
    [List<Object?>? keys]) {
  useEffect(
    () {
      listenable?.addListener(callback);
      return () => listenable?.removeListener(callback);
    },
    keys ?? [listenable],
  );
}
