import 'package:fast_equatable/fast_equatable.dart';
import 'package:lensai/domain/entities/equatable_image.dart';

class TabPreview with FastEquatable {
  final String id;

  final String title;
  final EquatableImage? icon;

  final Uri url;
  final String? highlightedUrl;

  final String? content;

  TabPreview({
    required this.id,
    required this.title,
    required this.icon,
    required this.url,
    required this.highlightedUrl,
    required this.content,
  });

  @override
  List<Object?> get hashParameters => [
        id,
        title,
        icon,
        url,
        highlightedUrl,
        content,
      ];

  @override
  bool get cacheHash => true;
}
