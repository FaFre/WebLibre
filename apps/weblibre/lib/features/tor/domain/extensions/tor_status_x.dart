import 'package:flutter_tor/flutter_tor.dart';
import 'package:riverpod/riverpod.dart';

enum TorPhase { stopped, bootstrapping, ready, degraded }

extension TorStatusX on TorStatus {
  TorPhase get phase {
    if (!isRunning) {
      return bootstrapProgress > 0 ? TorPhase.bootstrapping : TorPhase.stopped;
    }
    if (bootstrapProgress < 100) {
      return TorPhase.bootstrapping;
    }
    return socksPort != null ? TorPhase.ready : TorPhase.degraded;
  }

  bool get isReady => phase == TorPhase.ready;
  bool get isBusy => phase == TorPhase.bootstrapping;
  bool get isStopped => phase == TorPhase.stopped;
  int? get usableSocksPort => isReady ? socksPort : null;
}

extension TorAsyncStatusX on AsyncValue<TorStatus> {
  TorPhase get phase {
    if (isLoading && !hasValue) return TorPhase.bootstrapping;
    return value?.phase ?? TorPhase.stopped;
  }

  bool get isReady => !isLoading && (value?.isReady ?? false);
  bool get isBusy => isLoading || (value?.isBusy ?? false);
  bool get isStopped => !isLoading && (value?.isStopped ?? true);
  int? get usableSocksPort => isReady ? value?.socksPort : null;
}
