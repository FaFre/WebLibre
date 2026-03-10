// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/database.dart'
    as i1;

mixin $HiddenTopSiteDaoMixin on i0.DatabaseAccessor<i1.TopSiteDatabase> {
  HiddenTopSiteDaoManager get managers => HiddenTopSiteDaoManager(this);
}

class HiddenTopSiteDaoManager {
  final $HiddenTopSiteDaoMixin _db;
  HiddenTopSiteDaoManager(this._db);
}
