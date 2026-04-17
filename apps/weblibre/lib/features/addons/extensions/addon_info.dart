import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

extension AddonInfoUi on AddonInfo {
  bool get hasOptionsPage => optionsPageUrl?.isNotEmpty ?? false;

  bool get canUserToggleEnabled {
    return switch (disabledReason) {
      AddonDisabledReason.blocklisted ||
      AddonDisabledReason.notCorrectlySigned ||
      AddonDisabledReason.incompatible => false,
      _ => true,
    };
  }

  String? get statusBannerMessage {
    return switch (disabledReason) {
      AddonDisabledReason.blocklisted =>
        'This extension has been blocklisted and should remain disabled.',
      AddonDisabledReason.notCorrectlySigned =>
        'This extension is not correctly signed and cannot be safely enabled.',
      AddonDisabledReason.incompatible =>
        'This extension is incompatible with the current app version.',
      AddonDisabledReason.softBlocked =>
        isEnabled
            ? 'This extension is soft-blocked. Use caution while it remains enabled.'
            : 'This extension is soft-blocked, but it can still be re-enabled.',
      AddonDisabledReason.unsupported =>
        'This extension is installed, but WebLibre does not currently support it.',
      _ => null,
    };
  }
}
