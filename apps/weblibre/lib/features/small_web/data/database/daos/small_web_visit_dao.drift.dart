// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/small_web/data/database/database.dart' as i1;

mixin $SmallWebVisitDaoMixin on i0.DatabaseAccessor<i1.SmallWebDatabase> {
  SmallWebVisitDaoManager get managers => SmallWebVisitDaoManager(this);
}

class SmallWebVisitDaoManager {
  final $SmallWebVisitDaoMixin _db;
  SmallWebVisitDaoManager(this._db);
}
