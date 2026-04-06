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
const barewordConcat = ' ';

sealed class Bareword {
  final String word;

  @override
  int get hashCode => word.hashCode;

  Bareword(String word) : word = word.replaceAll('"', '""');

  @override
  bool operator ==(Object other) {
    if (other is Bareword) {
      return word == other.word;
    }

    return false;
  }

  JoinedBareword join(Bareword other) {
    return JoinedBareword(other.word, this);
  }
}

final class SimpleBareword extends Bareword {
  SimpleBareword(super.word);

  @override
  String toString() => word;
}

final class EnclosedBareword extends Bareword {
  EnclosedBareword(super.word);

  @override
  String toString() {
    return '"$word"';
  }
}

final class JoinedBareword extends Bareword {
  final Bareword parent;

  JoinedBareword(super.bareword, this.parent);

  bool hasDependency(Bareword other) {
    if (parent is JoinedBareword) {
      return (parent as JoinedBareword).hasDependency(other);
    } else {
      return parent == other;
    }
  }

  Iterable<Bareword> get dependencies {
    final depencies = <Bareword>[parent];
    while (depencies.last is JoinedBareword) {
      depencies.add((depencies.last as JoinedBareword).parent);
    }

    return depencies.reversed;
  }

  @override
  String toString() {
    final deps = dependencies
        .map((bareword) => bareword.toString())
        .join(barewordConcat);
    return '"$deps$barewordConcat$word"';
  }
}
