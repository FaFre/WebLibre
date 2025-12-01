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
import 'package:pigeon/pigeon.dart';

class Intent {
  final String? fromPackageName;
  final String? action;
  final String? data;
  final List<String> categories;
  final String? mimeType;
  final Map<String, Object?> extra;

  Intent({
    required this.fromPackageName,
    required this.action,
    required this.data,
    required this.categories,
    required this.mimeType,
    required this.extra,
  });
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/intent.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/simple_intent_receiver/pigeons/Intent.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.simple_intent_receiver.pigeons',
    ),
    dartPackageName: 'simple_intent_receiver',
  ),
)
@FlutterApi()
abstract class IntentEvents {
  void onIntentReceived(int timestamp, Intent intent);
}
