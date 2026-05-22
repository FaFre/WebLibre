import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    show CaptureTabData;

/// Mirror of the capture_tab rows on disk under
/// `<profileDir>/files/sandbox_captures.json`. Kotlin reads this file during
/// pre-Gecko bootstrap, before tab restore can dispatch any load request.
///
/// The schema is intentionally tiny: only the fields Kotlin needs to build a
/// placeholder [SandboxEntry] with `redirectUrl = "about:blank"`. Dart
/// replaces those placeholders with real loopback URLs via
/// [SandboxCaptureApi.resetAll] once [CaptureServer] is running.
///
/// The [_version] field is written at the top of the JSON envelope. Kotlin
/// reads it and refuses to rehydrate any version higher than the one it
/// supports — a forward-incompatible write from a newer Dart side leaves
/// the registry empty for that cold start, which is the safe outcome
/// (sandbox tabs reopen as about:blank rather than loading live URLs).
/// Bump this in lockstep with the Kotlin `SUPPORTED_VERSION` constant.
const _version = 1;

class SandboxCaptureStore {
  File _file() {
    return File(
      p.join(
        filesystem.selectedProfileDir.path,
        'files',
        'sandbox_captures.json',
      ),
    );
  }

  Future<void> write(List<CaptureTabData> rows) async {
    final file = _file();
    await file.parent.create(recursive: true);
    final payload = jsonEncode({
      'version': _version,
      'entries': rows
          .map((r) {
            return {
              'tabId': r.tabId,
              'captureId': r.captureId,
              'sourceUrl': r.sourceUrl,
              'status': r.status,
            };
          })
          .toList(growable: false),
    });
    final tmp = File('${file.path}.part');
    await tmp.writeAsString(payload, flush: true);
    await tmp.rename(file.path);
  }
}
