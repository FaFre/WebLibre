// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/popular_sites/data/database/database.dart'
    as i1;

mixin $SiteDaoMixin on i0.DatabaseAccessor<i1.SitesDatabase> {
  SiteDaoManager get managers => SiteDaoManager(this);
}

class SiteDaoManager {
  final $SiteDaoMixin _db;
  SiteDaoManager(this._db);
}
