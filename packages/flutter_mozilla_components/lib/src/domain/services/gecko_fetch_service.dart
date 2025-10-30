import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoFetchApi();

class GeckoFetchService {
  final GeckoFetchApi _api;

  GeckoFetchService({GeckoFetchApi? api}) : _api = api ?? _apiInstance;

  Future<GeckoFetchResponse> fetch({
    required Uri url,
    GeckoFetchMethod method = GeckoFetchMethod.get,
    List<GeckoHeader> headers = const [],
    Duration? connectTimeout,
    Duration? readTimeout,
    String? body,
    GeckoFetchRedircet redirect = GeckoFetchRedircet.follow,
    GeckoFetchCookiePolicy cookiePolicy = GeckoFetchCookiePolicy.include,
    bool useCaches = true,
    bool private = false,
    bool useOhttp = false,
    String? referrerUrl,
    bool conservative = false,
  }) {
    return _api.fetch(
      GeckoFetchRequest(
        url: url.toString(),
        method: method,
        headers: headers,
        connectTimeoutMillis: connectTimeout?.inMilliseconds,
        readTimeoutMillis: readTimeout?.inMilliseconds,
        body: body,
        redirect: redirect,
        cookiePolicy: cookiePolicy,
        useCaches: useCaches,
        private: private,
        useOhttp: useOhttp,
        referrerUrl: referrerUrl,
        conservative: conservative,
      ),
    );
  }
}
