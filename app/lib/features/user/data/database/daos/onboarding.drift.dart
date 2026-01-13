// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $OnboardingDaoMixin on i0.DatabaseAccessor<i1.UserDatabase> {
  OnboardingDaoManager get managers => OnboardingDaoManager(this);
}

class OnboardingDaoManager {
  final $OnboardingDaoMixin _db;
  OnboardingDaoManager(this._db);
}
