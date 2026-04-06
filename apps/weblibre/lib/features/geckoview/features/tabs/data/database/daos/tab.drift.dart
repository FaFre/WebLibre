// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart'
    as i1;

mixin $TabDaoMixin on i0.DatabaseAccessor<i1.TabDatabase> {
  TabDaoManager get managers => TabDaoManager(this);
}

class TabDaoManager {
  final $TabDaoMixin _db;
  TabDaoManager(this._db);
}
