import 'package:drift/drift.dart';
import 'package:weblibre/features/user/data/database/database.dart';

part 'onboarding.g.dart';

@DriftAccessor()
class OnboardingDao extends DatabaseAccessor<UserDatabase>
    with _$OnboardingDaoMixin {
  OnboardingDao(super.attachedDatabase);

  SingleOrNullSelectable<int?> getLastRevision() {
    final maxRevision = db.onboarding.revision.max();

    final query = selectOnly(db.onboarding)..addColumns([maxRevision]);

    return query.map((row) => row.read(maxRevision));
  }

  Future<void> pushRevision(int revision, DateTime completionDate) {
    return db.onboarding.insertOne(
      OnboardingCompanion.insert(
        revision: revision,
        completionDate: completionDate,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
