// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/user/data/database/database.dart' as i1;

mixin $ProxyProfileDaoMixin on i0.DatabaseAccessor<i1.UserDatabase> {
  ProxyProfileDaoManager get managers => ProxyProfileDaoManager(this);
}

class ProxyProfileDaoManager {
  final $ProxyProfileDaoMixin _db;
  ProxyProfileDaoManager(this._db);
}
