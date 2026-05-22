// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $SearchTokensDaoMixin on i0.DatabaseAccessor<i1.UserDatabase> {
  SearchTokensDaoManager get managers => SearchTokensDaoManager(this);
}

class SearchTokensDaoManager {
  final $SearchTokensDaoMixin _db;
  SearchTokensDaoManager(this._db);
}
