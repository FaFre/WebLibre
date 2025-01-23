extension StringExtension on String {
  String toCapitalized() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
