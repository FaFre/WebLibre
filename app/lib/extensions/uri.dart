extension UriX on Uri {
  Uri get base => Uri.parse('$scheme://$authority');
}
