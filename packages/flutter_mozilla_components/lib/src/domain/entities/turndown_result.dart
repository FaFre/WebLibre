class TurndownResults {
  final String plain;
  final String? markdown;

  TurndownResults({required this.plain, required String markdown})
    : markdown = (plain != markdown) ? markdown : null;
}
