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
import 'package:hooks_riverpod/misc.dart' show ProviderListenable;

/// Reads a provider once; satisfied by both `WidgetRef.read` and `Ref.read`.
///
/// Helpers that widgets and services alike call take this, or a [WidgetRef]
/// when only widgets do. Never `ProviderScope.containerOf(context)`: it
/// returns the container of whichever scope is nearest, which is how the
/// onboarding's draft container ended up shared across routes.
typedef ProviderRead = T Function<T>(ProviderListenable<T> provider);
