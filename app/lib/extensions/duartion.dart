extension DurationX on Duration {
  String formatTimeZoneOffset() {
    final hours = inHours.abs().toString().padLeft(2, '0');
    final minutes = (inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = isNegative ? '-' : '+';

    return '$sign$hours$minutes';
  }
}
