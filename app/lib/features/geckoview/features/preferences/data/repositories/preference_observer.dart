import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';

part 'preference_observer.g.dart';

@Riverpod()
class PreferenceChangeListener extends _$PreferenceChangeListener {
  @override
  Stream<GeckoPref> build() async* {
    final events = ref.watch(eventServiceProvider);

    await GeckoPrefService().startObserveChanges();

    ref.onDispose(() async {
      await GeckoPrefService().stopObserveChanges();
    });

    yield* events.prefUpdateEvent;
  }
}

@Riverpod()
class PreferenceFixator extends _$PreferenceFixator {
  Future<void> register(String name, Object value) async {
    state = {...state}
      ..update(
        name,
        (_) => value,
        ifAbsent: () {
          unawaited(GeckoPrefService().registerPrefForObservation(name));
          return value;
        },
      );

    await GeckoPrefService().applyPrefs({name: value});
  }

  Future<void> unregister(String name) async {
    await GeckoPrefService().unregisterPrefForObservation(name);
    state = {...state}..remove(name);
  }

  @override
  Map<String, Object> build() {
    ref.listen(preferenceChangeListenerProvider, (previous, next) async {
      if (next.hasValue) {
        final setting = stateOrNull?[next.value!.name];
        if (setting != null && next.value?.value != setting) {
          await GeckoPrefService().applyPrefs({next.value!.name: setting});
        }
      }
    });

    return {};
  }
}

// @Riverpod()
// class PreferenceObserver extends _$PreferenceObserver {
//   @override
//   Stream<GeckoPref> build(String pref) {
//     final updateStream = ref
//         .watch(preferenceChangeListenerProvider)
//         .where((x) => x.name == pref);

//     unawaited(GeckoPrefService().registerPrefForObservation(pref));

//     ref.onDispose(() async {
//       await GeckoPrefService().unregisterPrefForObservation(pref);
//     });

//     return GeckoPrefService()
//         .getPrefs([pref])
//         .asStream()
//         .map((value) => value.values.first)
//         .concatWith([updateStream]);
//   }
// }
