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
  /// Cleaning result for the URL currently held by the caller.
  final UrlCleanerResult? result;

  /// Result the tracking details UI works from.
  ///
  /// This stays anchored to the last URL that actually carried tracking
  /// parameters, so the full parameter list survives a clean — without it a
  /// cleaned URL reports no removable parameters and the user loses any way
  /// to put one back.
  final UrlCleanerResult? details;

  final bool Function() _applyCleanUrl;
  final bool Function(String previewUrl) _applyPreviewUrl;

  const UrlCleanerController._({
    required this.result,
    required this.details,
    required bool Function() applyCleanUrl,
    required bool Function(String previewUrl) applyPreviewUrl,
  }) : _applyCleanUrl = applyCleanUrl,
       _applyPreviewUrl = applyPreviewUrl;

  bool get showTile => details != null && details!.removedParams.isNotEmpty;

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
  final detailsResult = useState<UrlCleanerResult?>(null);

  // URLs this controller handed back to the caller. Re-cleaning one of them
  // would auto-apply over a choice the user just made and shrink [details]
  // down to whatever is left, so they are treated as settled.
  final derivedUrls = useRef(<String>{});

  final getCurrentUrlRef = useRef(getCurrentUrl);
  getCurrentUrlRef.value = getCurrentUrl;

  final onApplyCleanedUrlRef = useRef(onApplyCleanedUrl);
  onApplyCleanedUrlRef.value = onApplyCleanedUrl;

  useEffect(() {
    if (!cleanerEnabled || sourceUrl == null) {
      cleanerResult.value = null;
      detailsResult.value = null;
      derivedUrls.value.clear();
      return null;
    }

    if (rules == null) return null;

    final result = cleanUrl(
      sourceUrl,
      rules,
      allowReferral: allowReferralMarketing,
    );
    cleanerResult.value = result;

    if (derivedUrls.value.contains(sourceUrl)) {
      // Our own output came back around: keep the parameter list anchored to
      // the URL it was collected from and leave the applied state alone.
      return null;
    }

    derivedUrls.value.clear();
    detailsResult.value = result.removedParams.isNotEmpty ? result : null;

    if (autoApply && result.changed) {
      derivedUrls.value.add(result.cleanedUrl);
      onApplyCleanedUrlRef.value(result.cleanedUrl);
    }

    return null;
  }, [sourceUrl, rules, cleanerEnabled, allowReferralMarketing, autoApply]);

  bool applyCleanUrl() {
    final result = cleanerResult.value;
    if (result == null || !result.changed) return false;

    derivedUrls.value.add(result.cleanedUrl);
    onApplyCleanedUrlRef.value(result.cleanedUrl);
    return true;
  }

  bool applyPreviewUrl(String previewUrl) {
    if (previewUrl == getCurrentUrlRef.value()) return false;

    derivedUrls.value.add(previewUrl);
    onApplyCleanedUrlRef.value(previewUrl);
    return true;
  }

  return UrlCleanerController._(
    result: cleanerResult.value,
    details: detailsResult.value,
    applyCleanUrl: applyCleanUrl,
    applyPreviewUrl: applyPreviewUrl,
  );
}
