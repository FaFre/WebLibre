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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'tab_close_lock.g.dart';

/// The tabs' close lock: every close, every tab lock change and every
/// container deletion holds it (`TabRepository`, `TabLocks`,
/// `ContainerDeletion`), so no close can fall between a lock's two writes,
/// and a close's preflight cannot disagree with native's removal.
///
/// Not reentrant: a method documented as running under it does not take it
/// itself, and asserts that it is held.
@Riverpod(keepAlive: true)
Lock tabCloseLock(Ref ref) => Lock();
