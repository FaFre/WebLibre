/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'dart:collection';

class LRUCache<K, V> {
  int _capacity;
  final LinkedHashMap<K, V> _cache;
  final void Function(V)? _onEvict;

  LRUCache(
    this._capacity, {
    bool Function(K, K)? equals,
    int Function(K)? hashCode,
    bool Function(dynamic)? isValidKey,
    void Function(V)? onEvict,
  }) : _onEvict = onEvict,
       _cache = LinkedHashMap<K, V>(
         equals: equals,
         hashCode: hashCode,
         isValidKey: isValidKey,
       );

  void resize(int capacity) {
    if (_capacity > capacity) {
      _cache.keys.take(_capacity - capacity).forEach((key) {
        final evicted = _cache.remove(key);
        if (evicted != null) {
          _onEvict?.call(evicted);
        }
      });
    }

    _capacity = capacity;
  }

  bool contains(K key) {
    return _cache.containsKey(key);
  }

  V? get(K key) {
    final value = _cache.remove(key); // Temporarily remove the item.

    if (value != null) {
      _cache[key] =
          value; // Re-inserting the item makes it the most-recently used.
    }

    return value;
  }

  V set(K key, V value) {
    V? evicted;

    if (_cache.containsKey(key)) {
      evicted = _cache.remove(key); // Remove the existing item before updating.
    } else if (_cache.length == _capacity) {
      evicted = _cache.remove(
        _cache.keys.first,
      ); // Explicitly remove the least recently used item if at capacity.
    }

    if (evicted != null) {
      _onEvict?.call(evicted);
    }

    return _cache[key] = value; // Inserting or updating the item.
  }

  /// Clears all entries from the cache, calling onEvict for each entry.
  void clear() {
    if (_onEvict != null) {
      for (final value in _cache.values) {
        _onEvict(value);
      }
    }
    _cache.clear();
  }

  /// Removes an entry by key, calling onEvict if it existed.
  V? remove(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _onEvict?.call(value);
    }
    return value;
  }
}
