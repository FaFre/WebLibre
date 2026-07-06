// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $QuickSwitcherButtonConfigDaoMixin
    on i0.DatabaseAccessor<i1.UserDatabase> {
  QuickSwitcherButtonConfigDaoManager get managers =>
      QuickSwitcherButtonConfigDaoManager(this);
}

class QuickSwitcherButtonConfigDaoManager {
  final $QuickSwitcherButtonConfigDaoMixin _db;
  QuickSwitcherButtonConfigDaoManager(this._db);
}
