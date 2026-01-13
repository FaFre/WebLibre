// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/bangs/data/database/database.dart' as i1;

mixin $BangDaoMixin on i0.DatabaseAccessor<i1.BangDatabase> {
  BangDaoManager get managers => BangDaoManager(this);
}

class BangDaoManager {
  final $BangDaoMixin _db;
  BangDaoManager(this._db);
}
