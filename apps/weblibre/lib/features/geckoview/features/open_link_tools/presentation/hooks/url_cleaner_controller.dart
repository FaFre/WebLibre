/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_rule.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';

class UrlCleanerController {
  final UrlCleanerResult? result;
  final bool applied;
  final bool Function() _applyCleanUrl;
  final bool Function(String previewUrl) _applyPreviewUrl;

  const UrlCleanerController._({
    required this.result,
    required this.applied,
    required bool Function() applyCleanUrl,
    required bool Function(String previewUrl) applyPreviewUrl,
  }) : _applyCleanUrl = applyCleanUrl,
       _applyPreviewUrl = applyPreviewUrl;

  bool get showTile =>
      result != null && (result!.removedParams.isNotEmpty || applied);

  bool applyCleanUrl() => _applyCleanUrl();

  bool applyPreviewUrl(String previewUrl) => _applyPreviewUrl(previewUrl);
}

UrlCleanerController useUrlCleanerController({
  required String? sourceUrl,
  required List<UrlCleanerRule>? rules,
  required bool cleanerEnabled,
  required bool allowReferralMarketing,
  required bool autoApply,
  required String? Function() getCurrentUrl,
  required void Function(String cleanedUrl) onApplyCleanedUrl,
}) {
  final cleanerResult = useState<UrlCleanerResult?>(null);
  final cleanerApplied = useState(false);

  final getCurrentUrlRef = useRef(getCurrentUrl);
  getCurrentUrlRef.value = getCurrentUrl;

  final onApplyCleanedUrlRef = useRef(onApplyCleanedUrl);
  onApplyCleanedUrlRef.value = onApplyCleanedUrl;

  useEffect(() {
    if (!cleanerEnabled || sourceUrl == null) {
      cleanerResult.value = null;
      return null;
    }

    if (rules == null) return null;

    final result = cleanUrl(
      sourceUrl,
      rules,
      allowReferral: allowReferralMarketing,
    );
    cleanerResult.value = result;

    // Preserve the "already cleaned" state until a new removable parameter
    // set is detected.
    if (result.removedParams.isNotEmpty) {
      cleanerApplied.value = false;
    }

    if (autoApply && result.changed) {
      onApplyCleanedUrlRef.value(result.cleanedUrl);
      cleanerApplied.value = true;
    }

    return null;
  }, [sourceUrl, rules, cleanerEnabled, allowReferralMarketing, autoApply]);

  bool applyCleanUrl() {
    final result = cleanerResult.value;
    if (result == null || !result.changed) return false;

    onApplyCleanedUrlRef.value(result.cleanedUrl);
    cleanerApplied.value = true;
    return true;
  }

  bool applyPreviewUrl(String previewUrl) {
    if (previewUrl == getCurrentUrlRef.value()) return false;

    onApplyCleanedUrlRef.value(previewUrl);
    cleanerApplied.value = true;
    return true;
  }

  return UrlCleanerController._(
    result: cleanerResult.value,
    applied: cleanerApplied.value,
    applyCleanUrl: applyCleanUrl,
    applyPreviewUrl: applyPreviewUrl,
  );
}
