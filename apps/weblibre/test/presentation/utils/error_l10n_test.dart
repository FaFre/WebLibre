import 'dart:io';
import 'dart:ui';

import 'package:exceptions/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/error_l10n.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  ErrorMessage httpError() => handleHttpError(
    const SocketException('connection refused by 10.0.0.1'),
    StackTrace.empty,
  );

  const genericError = ErrorMessage(
    source: 'BangSync',
    message: 'Failed to sync Bangs (general)',
  );

  group('describeError', () {
    test('translates an HTTP failure instead of its diagnostic text', () {
      expect(
        describeError(l10n, httpError()),
        l10n.httpErrorHandler_socketError,
      );
    });

    test('unwraps a ResultException around an HTTP failure', () {
      expect(
        describeError(l10n, ResultException(httpError())),
        l10n.httpErrorHandler_socketError,
      );
    });

    test('shows the message of any other ErrorMessage', () {
      expect(describeError(l10n, genericError), genericError.message);
    });

    test('unwraps a ResultException around any other ErrorMessage', () {
      expect(
        describeError(l10n, const ResultException(genericError)),
        genericError.message,
      );
    });

    test('falls back to a generic sentence for an empty message', () {
      const empty = ErrorMessage(source: 'x', message: '  ');

      expect(describeError(l10n, empty), l10n.failureWidget_unknownError);
      expect(
        describeError(l10n, const ResultException(empty)),
        l10n.failureWidget_unknownError,
      );
    });

    test('passes plain strings through', () {
      expect(describeError(l10n, 'Already localized'), 'Already localized');
    });

    test('names other objects by type, not by their toString', () {
      expect(describeError(l10n, StateError('token=secret')), 'StateError');
    });
  });
}
