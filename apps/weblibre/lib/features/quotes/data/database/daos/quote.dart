/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:drift/drift.dart';
import 'package:weblibre/features/quotes/data/database/daos/quote.drift.dart';
import 'package:weblibre/features/quotes/data/database/database.dart';
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart';

@DriftAccessor()
class QuoteDao extends DatabaseAccessor<QuotesDatabase> with $QuoteDaoMixin {
  QuoteDao(super.db);

  SingleOrNullSelectable<Quote> getRandomQuote() {
    final statement = select(db.quotes)
      ..orderBy([(t) => OrderingTerm.random()])
      ..limit(1);

    return statement;
  }
}
