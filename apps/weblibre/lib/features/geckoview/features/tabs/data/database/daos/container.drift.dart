// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart'
    as i1;

mixin $ContainerDaoMixin on i0.DatabaseAccessor<i1.TabDatabase> {
  ContainerDaoManager get managers => ContainerDaoManager(this);
}

class ContainerDaoManager {
  final $ContainerDaoMixin _db;
  ContainerDaoManager(this._db);
}
