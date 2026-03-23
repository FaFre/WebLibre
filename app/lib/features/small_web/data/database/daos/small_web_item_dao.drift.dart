// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/small_web/data/database/database.dart' as i1;

mixin $SmallWebItemDaoMixin on i0.DatabaseAccessor<i1.SmallWebDatabase> {
  SmallWebItemDaoManager get managers => SmallWebItemDaoManager(this);
}

class SmallWebItemDaoManager {
  final $SmallWebItemDaoMixin _db;
  SmallWebItemDaoManager(this._db);
}
