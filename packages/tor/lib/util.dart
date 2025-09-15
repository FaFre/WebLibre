// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: MIT

import 'package:tor/generated_bindings.dart' as rust;
import 'package:tor/tor.dart';

int getNofileLimit() {
  return rust.NativeLibrary(load(Tor.libName)).tor_get_nofile_limit();
}

int setNofileLimit(int limit) {
  return rust.NativeLibrary(load(Tor.libName)).tor_set_nofile_limit(limit);
}
