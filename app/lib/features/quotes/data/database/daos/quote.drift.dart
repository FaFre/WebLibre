// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/quotes/data/database/database.dart' as i1;

mixin $QuoteDaoMixin on i0.DatabaseAccessor<i1.QuotesDatabase> {
  QuoteDaoManager get managers => QuoteDaoManager(this);
}

class QuoteDaoManager {
  final $QuoteDaoMixin _db;
  QuoteDaoManager(this._db);
}
