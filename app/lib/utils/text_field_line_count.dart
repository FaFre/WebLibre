import 'package:flutter/material.dart';

int _getLineCountUsingBoxes(String text, TextStyle style, double maxWidth) {
  final textSpan = TextSpan(text: text, style: style);

  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(maxWidth: maxWidth);

  // Select all text
  final selection = TextSelection(baseOffset: 0, extentOffset: text.length);

  // Each box represents one line
  final lines = textPainter.getBoxesForSelection(selection);
  return lines.length;
}

int? getTextFieldLineCount(GlobalKey key, String text, TextStyle style) {
  final box = key.currentContext?.findRenderObject();
  if (box case final RenderBox box) {
    final width = box.size.width;

    return _getLineCountUsingBoxes(text, style, width);
  }

  return null;
}
