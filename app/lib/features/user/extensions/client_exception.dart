import 'package:lensai/extensions/string.dart';
import 'package:pocketbase/pocketbase.dart';

extension ClientExceptionExtension on ClientException {
  String get errorMessage {
    var message = "${response["message"] as String? ?? ""}\n\n";
    final data = response["data"] as Map<String, dynamic>;
    try {
      data.forEach((key, value) {
        final detailedMessage = (value as Map<String, dynamic>)["message"];
        if (detailedMessage != null) {
          message += '${key.toCapitalized()}: $detailedMessage\n';
        }
      });
    } catch (_) {}
    try {
      if (originalError != null) {
        message += ' $originalError';
      }
    } catch (_) {}

    return message.trim();
  }
}
