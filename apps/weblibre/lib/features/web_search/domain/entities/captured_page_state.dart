import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';

part 'captured_page_state.g.dart';

enum CapturedPageStatus { capturing, downloading, ready, downloadFailed }

@CopyWith()
class CapturedPageState with FastEquatable {
  final Uri sourceUrl;
  final CapturedPageStatus status;
  final String? captureId;
  final Uri? finalUrl;
  final String? filename;

  /// Capture engine used: `singlefile` or `shot-scraper`.
  final String? method;

  /// Engine-specific selector — preset (singlefile) or mode (shot-scraper).
  final String? variant;

  /// MIME type returned by the backend (e.g. `text/html`, `application/pdf`,
  /// `image/png`). Used to choose the right file extension and to pick the
  /// right viewer when opening the artifact locally.
  final String? contentType;

  final int? byteLength;
  final String? localPath;
  final String? downloadToken;
  final String? errorMessage;

  CapturedPageState({
    required this.sourceUrl,
    required this.status,
    this.captureId,
    this.finalUrl,
    this.filename,
    this.method,
    this.variant,
    this.contentType,
    this.byteLength,
    this.localPath,
    this.downloadToken,
    this.errorMessage,
  });

  @override
  List<Object?> get hashParameters => [
    sourceUrl,
    status,
    captureId,
    finalUrl,
    filename,
    method,
    variant,
    contentType,
    byteLength,
    localPath,
    downloadToken,
    errorMessage,
  ];
}
