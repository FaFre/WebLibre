// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart'
    as i1;

mixin $CaptureTabDaoMixin on i0.DatabaseAccessor<i1.TabDatabase> {
  CaptureTabDaoManager get managers => CaptureTabDaoManager(this);
}

class CaptureTabDaoManager {
  final $CaptureTabDaoMixin _db;
  CaptureTabDaoManager(this._db);
}
