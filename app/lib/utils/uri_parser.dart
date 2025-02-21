final _domainRegex = RegExp(r'\.[a-zA-Z]{2,}$');
const _supportedSchemes = {'https', 'http', 'ftp', 'file', 'content', 'about'};

Uri? tryParseUrl(String? input, {bool eagerParsing = false}) {
  if (input != null) {
    var uri = Uri.tryParse(input);
    if (uri != null) {
      if (uri.authority.isEmpty && eagerParsing) {
        if (uri.pathSegments.isNotEmpty) {
          if (_domainRegex.hasMatch(uri.pathSegments.first)) {
            uri = Uri.tryParse('https://$input');
          }
        }
      }

      if (uri != null) {
        if (uri.isScheme('about')) {
          return uri;
        }

        if (uri.authority.isNotEmpty) {
          if (_supportedSchemes.contains(uri.scheme) || !uri.hasScheme) {
            return uri;
          }
        }
      }
    }
  }
  return null;
}
