abstract interface class IQueryBuilder {
  int get ftsTokenLimit;
  int get ftsMinTokenLength;

  String buildFtsQuery(String input);
  String buildLikeQuery(String input);
}
