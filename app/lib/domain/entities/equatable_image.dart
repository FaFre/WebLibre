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
import 'dart:ui';

class EquatableImage {
  Image? _value;
  final int _imageHash;
  bool _isDisposed = false;

  EquatableImage(Image value, {required int hash})
    : _value = value,
      _imageHash = hash;

  /// The underlying ui.Image. Returns null if disposed.
  Image? get value => _isDisposed ? null : _value;

  /// Whether this image has been disposed.
  bool get isDisposed => _isDisposed;

  /// Disposes the underlying ui.Image to free GPU memory.
  /// This is safe to call multiple times.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    // Delay disposal to allow widgets to finish rendering
    Future.delayed(const Duration(seconds: 3), () {
      _value?.dispose();
      _value = null;
    });
  }

  @override
  int get hashCode => _imageHash.hashCode;

  @override
  bool operator ==(Object other) {
    return other is EquatableImage && other._imageHash == _imageHash;
  }
}
