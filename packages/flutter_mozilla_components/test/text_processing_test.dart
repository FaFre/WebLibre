import 'package:flutter_mozilla_components/src/utils/ml/embedding_text_processing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Text processing basic cases', () {
    test('trailing domain-like text should be removed', () {
      expect(
        preprocessText("Some Title - Random Mail"),
        equals("Some Title"),
        reason: "Should remove '- Random Mail' suffix",
      );
    });

    test('trailing domain-like text with |', () {
      expect(
        preprocessText("Another Title | Some Video Website"),
        equals("Another Title"),
        reason: "Should remove '| Some Video Website' suffix",
      );
    });

    test('no delimiter', () {
      expect(
        preprocessText("Simple Title"),
        equals("Simple Title"),
        reason: "Should remain unchanged since there's no recognized delimiter",
      );
    });

    test('not enough info in first part', () {
      expect(
        preprocessText("AB - Mail"),
        equals("AB - Mail"),
        reason:
            "Should not remove '- Mail' because the first part is too short",
      );
    });

    test('should not match for texts such as check-in', () {
      expect(
        preprocessText("Check-in for flight"),
        equals("Check-in for flight"),
        reason: "Should not remove '-in'",
      );
    });
  });

  group('Text processing edge cases', () {
    test('empty string', () {
      expect(
        preprocessText(""),
        equals(""),
        reason: "Empty string returns empty string",
      );
    });

    test('exactly 20 chars', () {
      const domain20Chars = "12345678901234567890"; // 20 characters
      expect(
        preprocessText("My Title - $domain20Chars"),
        equals("My Title - $domain20Chars"),
        reason:
            "Should not remove suffix because it's exactly 20 chars long, not < 20",
      );
    });

    test('multiple delimiters, remove last only', () {
      expect(
        preprocessText("Complex - Title - SomethingSmall"),
        equals("Complex Title"),
        reason:
            "Should remove only the last '- SomethingSmall', ignoring earlier delimiters",
      );
    });

    test('repeated delimiters', () {
      expect(
        preprocessText("Title --- Domain"),
        equals("Title"),
        reason: "Should remove the last chunk and filter out empty strings",
      );

      expect(
        preprocessText("Title || Domain"),
        equals("Title"),
        reason: "Should remove the last chunk with double pipe delimiters too",
      );
    });

    test('long trailing text', () {
      const longDomain = "Useful information is present";
      expect(
        preprocessText("Some Title - $longDomain"),
        equals("Some Title - $longDomain"),
        reason: "Should not remove suffix if it's >= 20 characters",
      );
    });
  });
}
