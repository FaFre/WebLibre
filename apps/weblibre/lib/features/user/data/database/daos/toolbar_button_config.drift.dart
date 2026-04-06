// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $ToolbarButtonConfigDaoMixin on i0.DatabaseAccessor<i1.UserDatabase> {
  ToolbarButtonConfigDaoManager get managers =>
      ToolbarButtonConfigDaoManager(this);
}

class ToolbarButtonConfigDaoManager {
  final $ToolbarButtonConfigDaoMixin _db;
  ToolbarButtonConfigDaoManager(this._db);
}
