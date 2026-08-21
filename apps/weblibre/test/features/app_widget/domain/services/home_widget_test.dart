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
 */
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/features/app_widget/domain/services/home_widget.dart';
import 'package:weblibre/features/share_intent/domain/services/brokered_intents.dart';

Intent intentWith({String? action, String? data}) => Intent(
  fromPackageName: null,
  action: action,
  data: data,
  categories: const [],
  mimeType: null,
  extra: const {},
);

void main() {
  group('widget launches held by the broker', () {
    test('a queued widget tap still opens search', () {
      // The case §7.1 asks for: the user taps the widget while the profile
      // picker is up. The plugin sends it to a Dart side with no listeners, so
      // the broker holds it — and this is what turns it back into a launch.
      final launch = widgetLaunchFrom(
        intentWith(action: homeWidgetLaunchAction, data: 'widget://search'),
      );

      expect(launch?.tool, 'search');
    });

    test('survives the round trip through the broker', () {
      // Not just the shape: the record the native side hands back has to still
      // produce a widget launch after being written to a file and read again.
      final replayed = brokeredIntentFrom(
        StartupIntentRecord(
          id: 'entry-1',
          sequence: 1,
          action: homeWidgetLaunchAction,
          dataUri: 'widget://search',
          mimeType: null,
          categories: const [],
          extras: const {},
          trustedProfileId: null,
        ),
      );

      expect(widgetLaunchFrom(replayed)?.tool, 'search');
    });

    test('an ordinary launch is not a widget launch', () {
      // Otherwise every queued deep link would also open the search widget.
      expect(
        widgetLaunchFrom(
          intentWith(
            action: 'android.intent.action.VIEW',
            data: 'https://example.org',
          ),
        ),
        isNull,
      );
    });

    test('a widget action with no target is refused', () {
      expect(
        widgetLaunchFrom(intentWith(action: homeWidgetLaunchAction)),
        isNull,
      );
      expect(
        widgetLaunchFrom(
          intentWith(action: homeWidgetLaunchAction, data: 'widget://'),
        ),
        isNull,
      );
    });

    test('the tool comes from the host, not the path', () {
      expect(
        widgetLaunchFrom(
          intentWith(action: homeWidgetLaunchAction, data: 'widget://search/x'),
        )?.tool,
        'search',
      );
    });
  });
}
