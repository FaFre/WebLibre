import 'package:flutter_test/flutter_test.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

Intent _intent({
  String? action,
  String? data,
  Map<String, Object?> extra = const {},
}) => Intent(action: action, data: data, categories: const [], extra: extra);

void main() {
  group('isOpenableLaunch', () {
    test('a link, a share, a text selection and a web search may open', () {
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.VIEW',
            data: 'https://example.com',
          ),
        ),
        isTrue,
      );
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.SEND',
            extra: {'android.intent.extra.TEXT': 'shared text'},
          ),
        ),
        isTrue,
      );
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.PROCESS_TEXT',
            extra: {'android.intent.extra.PROCESS_TEXT': 'selected'},
          ),
        ),
        isTrue,
      );
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.WEB_SEARCH',
            extra: {'query': 'search'},
          ),
        ),
        isTrue,
      );
    });

    test('a launch with nothing to open does not', () {
      // Opening the app from the launcher: there is no link to wait for, and
      // covering home here would delay every ordinary start.
      expect(
        isOpenableLaunch(_intent(action: 'android.intent.action.MAIN')),
        isFalse,
      );
      expect(
        isOpenableLaunch(_intent(action: 'android.intent.action.VIEW')),
        isFalse,
      );
      expect(
        isOpenableLaunch(_intent(action: 'android.intent.action.SEND')),
        isFalse,
      );
    });

    test('extras of the wrong type are nothing to open, not a crash', () {
      // Startup classifies launches before its UI mounts, so a throw here kept
      // the app on the loading screen. Extras are whatever the sender put in.
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.WEB_SEARCH',
            extra: {'query': 42},
          ),
        ),
        isFalse,
      );
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.PROCESS_TEXT',
            extra: {'android.intent.extra.PROCESS_TEXT': true},
          ),
        ),
        isFalse,
      );
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.SEND',
            extra: {
              'android.intent.extra.STREAM': 7,
              'android.intent.extra.TEXT': 'shared text',
            },
          ),
        ),
        isTrue,
        reason: 'a stream of the wrong type falls back to the text',
      );
    });

    test('an account callback belongs to its own consumer', () {
      expect(
        isOpenableLaunch(
          _intent(
            action: 'android.intent.action.VIEW',
            data: 'weblibre://account/callback?code=abc&state=xyz',
          ),
        ),
        isFalse,
      );
    });
  });
}
