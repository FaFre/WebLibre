// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/small_web/data/database/database.dart' as i1;

mixin $WanderConsoleDaoMixin on i0.DatabaseAccessor<i1.SmallWebDatabase> {
  WanderConsoleDaoManager get managers => WanderConsoleDaoManager(this);
}

class WanderConsoleDaoManager {
  final $WanderConsoleDaoMixin _db;
  WanderConsoleDaoManager(this._db);
}
