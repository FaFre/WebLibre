/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

class TurndownResults {
  final String plain;
  final String? markdown;

  TurndownResults({required this.plain, required String markdown})
    : markdown = (plain != markdown) ? markdown : null;
}
