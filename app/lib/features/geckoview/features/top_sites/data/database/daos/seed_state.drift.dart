// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/top_sites/data/database/database.dart'
    as i1;

mixin $TopSiteSeedStateDaoMixin on i0.DatabaseAccessor<i1.TopSiteDatabase> {
  TopSiteSeedStateDaoManager get managers => TopSiteSeedStateDaoManager(this);
}

class TopSiteSeedStateDaoManager {
  final $TopSiteSeedStateDaoMixin _db;
  TopSiteSeedStateDaoManager(this._db);
}
