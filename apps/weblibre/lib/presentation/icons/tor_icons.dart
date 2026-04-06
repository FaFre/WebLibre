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
import 'package:flutter/widgets.dart';

abstract class TorIcons {
  static const String _fontFamily = 'TorIcons';

  static const IconData authority = IconData(0xf101, fontFamily: _fontFamily);
  static const IconData badexit = IconData(0xf102, fontFamily: _fontFamily);
  static const IconData bridge = IconData(0xf103, fontFamily: _fontFamily);
  static const IconData country = IconData(0xf104, fontFamily: _fontFamily);
  static const IconData directory = IconData(0xf105, fontFamily: _fontFamily);
  static const IconData exit = IconData(0xf106, fontFamily: _fontFamily);
  static const IconData experimental = IconData(
    0xf107,
    fontFamily: _fontFamily,
  );
  static const IconData fallbackdir = IconData(0xf108, fontFamily: _fontFamily);
  static const IconData fast = IconData(0xf109, fontFamily: _fontFamily);
  static const IconData fingerprint = IconData(0xf10a, fontFamily: _fontFamily);
  static const IconData guard = IconData(0xf10b, fontFamily: _fontFamily);
  static const IconData hibernating = IconData(0xf10c, fontFamily: _fontFamily);
  static const IconData hsdir = IconData(0xf10d, fontFamily: _fontFamily);
  static const IconData ipv4 = IconData(0xf10e, fontFamily: _fontFamily);
  static const IconData ipv6exit = IconData(0xf10f, fontFamily: _fontFamily);
  static const IconData ipv6 = IconData(0xf110, fontFamily: _fontFamily);
  static const IconData noedconsensus = IconData(
    0xf111,
    fontFamily: _fontFamily,
  );
  static const IconData notrecommended = IconData(
    0xf112,
    fontFamily: _fontFamily,
  );
  static const IconData onionAlt = IconData(0xf113, fontFamily: _fontFamily);
  static const IconData onion = IconData(0xf114, fontFamily: _fontFamily);
  static const IconData outdated = IconData(0xf115, fontFamily: _fontFamily);
  static const IconData reachableipv4 = IconData(
    0xf116,
    fontFamily: _fontFamily,
  );
  static const IconData reachableipv6 = IconData(
    0xf117,
    fontFamily: _fontFamily,
  );
  static const IconData relay = IconData(0xf118, fontFamily: _fontFamily);
  static const IconData running = IconData(0xf119, fontFamily: _fontFamily);
  static const IconData stable = IconData(0xf11a, fontFamily: _fontFamily);
  static const IconData tshirt = IconData(0xf11b, fontFamily: _fontFamily);
  static const IconData unmeasured = IconData(0xf11c, fontFamily: _fontFamily);
  static const IconData unreachableipv4 = IconData(
    0xf11d,
    fontFamily: _fontFamily,
  );
  static const IconData unreachableipv6 = IconData(
    0xf11e,
    fontFamily: _fontFamily,
  );
  static const IconData v2dir = IconData(0xf11f, fontFamily: _fontFamily);
  static const IconData valid = IconData(0xf120, fontFamily: _fontFamily);

  static const List<IconData> values = [
    authority,
    badexit,
    bridge,
    country,
    directory,
    exit,
    experimental,
    fallbackdir,
    fast,
    fingerprint,
    guard,
    hibernating,
    hsdir,
    ipv4,
    ipv6exit,
    ipv6,
    noedconsensus,
    notrecommended,
    onionAlt,
    onion,
    outdated,
    reachableipv4,
    reachableipv6,
    relay,
    running,
    stable,
    tshirt,
    unmeasured,
    unreachableipv4,
    unreachableipv6,
    v2dir,
    valid,
  ];
}
