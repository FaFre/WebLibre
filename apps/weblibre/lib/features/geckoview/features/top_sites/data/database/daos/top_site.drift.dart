// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/database.dart'
    as i1;

mixin $TopSiteDaoMixin on i0.DatabaseAccessor<i1.TopSiteDatabase> {
  TopSiteDaoManager get managers => TopSiteDaoManager(this);
}

class TopSiteDaoManager {
  final $TopSiteDaoMixin _db;
  TopSiteDaoManager(this._db);
}
