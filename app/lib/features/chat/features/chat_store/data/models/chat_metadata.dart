import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_metadata.g.dart';

@JsonSerializable()
class ChatMetadata with FastEquatable {
  final String? mainDocumentId;
  final String? contextId;

  ChatMetadata({this.mainDocumentId, this.contextId});

  factory ChatMetadata.fromJson(Map<String, dynamic> json) =>
      _$ChatMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMetadataToJson(this);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [mainDocumentId, contextId];
}
