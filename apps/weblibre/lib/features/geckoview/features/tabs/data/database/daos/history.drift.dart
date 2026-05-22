// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart'
    as i1;

mixin $HistoryDaoMixin on i0.DatabaseAccessor<i1.TabDatabase> {
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final $HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
}
