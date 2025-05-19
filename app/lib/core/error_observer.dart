import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/logger.dart';

class ErrorObserver extends ProviderObserver {
  const ErrorObserver();

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger.e('Provider $provider threw $error at $stackTrace');
  }
}
