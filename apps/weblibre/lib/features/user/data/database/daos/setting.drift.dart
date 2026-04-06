// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $SettingDaoMixin on i0.DatabaseAccessor<i1.UserDatabase> {
  SettingDaoManager get managers => SettingDaoManager(this);
}

class SettingDaoManager {
  final $SettingDaoMixin _db;
  SettingDaoManager(this._db);
}
