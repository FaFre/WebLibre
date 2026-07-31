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
import 'dart:ui';

/// What makes one decoded image the *same* image as another.
///
/// Deliberately a record rather than a single combined `int`: [digest] is a
/// 64-bit content hash, and folding it together with the decode options via
/// `Object.hash` would truncate the whole thing to 30 bits (Dart caps hash
/// codes at `0x3fffffff`) and leave the result standing in as the identity
/// with no exact comparison behind it. As a record, hash codes only pick the
/// bucket and structural `==` decides equality, so the full digest and the
/// exact options both count.
typedef ImageIdentity = ({
  int digest,
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling,
});

/// A wrapper around [Image] that compares by a precomputed [ImageIdentity].
///
/// Instances are deduped via the decoder's LRU, so the same `EquatableImage`
/// may be shared across many holders (multiple tabs of the same site, the icon
/// cache, widget closures). To make that safe, the underlying `ui.Image` is
/// disposed via a [Finalizer] when this wrapper becomes unreachable — never on
/// cache eviction or state transitions, where another holder might still be
/// using it.
class EquatableImage {
  static final Finalizer<Image> _finalizer = Finalizer<Image>(
    (image) => image.dispose(),
  );

  Image? _value;
  final ImageIdentity _identity;
  bool _isDisposed = false;

  EquatableImage(Image value, {required ImageIdentity identity})
    : _value = value,
      _identity = identity {
    _finalizer.attach(this, value, detach: this);
  }

  /// The underlying ui.Image. Returns null if explicitly disposed.
  Image? get value => _isDisposed ? null : _value;

  /// Whether this image has been explicitly disposed.
  bool get isDisposed => _isDisposed;

  /// Explicitly release the underlying GPU resource now.
  ///
  /// Optional — if not called, the resource is freed when this wrapper is
  /// garbage collected. Only call this when you are certain no other holder
  /// still references the image; otherwise prefer to drop your reference
  /// and let GC handle it.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _finalizer.detach(this);
    _value?.dispose();
    _value = null;
  }

  @override
  int get hashCode => _identity.hashCode;

  @override
  bool operator ==(Object other) {
    return other is EquatableImage && other._identity == _identity;
  }
}
