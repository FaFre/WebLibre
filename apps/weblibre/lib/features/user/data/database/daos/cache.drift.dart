// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $CacheDaoMixin on i0.DatabaseAccessor<i1.UserDatabase> {
  CacheDaoManager get managers => CacheDaoManager(this);
}

class CacheDaoManager {
  final $CacheDaoMixin _db;
  CacheDaoManager(this._db);
}
