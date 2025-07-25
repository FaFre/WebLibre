import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'onboarding.g.dart';

@Riverpod(keepAlive: true)
class OnboardingRepository extends _$OnboardingRepository {
  static const targetRevision = 2;

  Future<int?> getCurrentRevision() {
    return ref
        .read(userDatabaseProvider)
        .onboardingDao
        .getLastRevision()
        .getSingleOrNull();
  }

  Future<void> pushRevision(int revision) {
    return ref
        .read(userDatabaseProvider)
        .onboardingDao
        .pushRevision(revision, DateTime.now());
  }

  Future<bool> isOutdated() async {
    final current = await getCurrentRevision();
    return current != targetRevision;
  }

  @override
  void build() {
    return;
  }
}
