// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart'
    as i1;

mixin $VisitContainerDaoMixin on i0.DatabaseAccessor<i1.TabDatabase> {
  VisitContainerDaoManager get managers => VisitContainerDaoManager(this);
}

class VisitContainerDaoManager {
  final $VisitContainerDaoMixin _db;
  VisitContainerDaoManager(this._db);
}
