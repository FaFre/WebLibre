import 'dart:ui';

int calculateCrossAxisItemCount({
  required double screenWidth,
  required double horizontalPadding,
  required double crossAxisSpacing,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final availableWidth =
      screenWidth - totalHorizontalPadding - crossAxisSpacing;

  final crossAxisCount = availableWidth ~/ 180.0;

  return crossAxisCount;
}

Size calculateItemSize({
  required double screenWidth,
  required double childAspectRatio,
  required double horizontalPadding,
  required double mainAxisSpacing,
  required double crossAxisSpacing,
  required int crossAxisCount,
}) {
  final totalHorizontalPadding = horizontalPadding * 2;
  final totalCrossAxisSpacing = crossAxisSpacing * (crossAxisCount - 1);
  final availableWidth =
      screenWidth - totalHorizontalPadding - totalCrossAxisSpacing;
  final itemWidth = availableWidth / crossAxisCount;
  final itemHeight = itemWidth / childAspectRatio;

  return Size(itemWidth, itemHeight + mainAxisSpacing);
}
