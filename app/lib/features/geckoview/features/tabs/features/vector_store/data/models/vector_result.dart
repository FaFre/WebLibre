import 'dart:convert';

import 'package:langchain/langchain.dart';

class VectorResult {
  final String id;
  final String? mainDocumentId;
  final String? contextId;
  final String content;
  final Map<String, dynamic> metadata;
  final double distance;

  VectorResult({
    required this.id,
    required this.mainDocumentId,
    required this.contextId,
    required this.content,
    required String? metadata,
    required double? distance,
  }) : metadata =
           (metadata != null)
               ? jsonDecode(metadata) as Map<String, dynamic>
               : const {},
       distance = distance!;

  Document toDocument() {
    return Document(id: id, pageContent: content, metadata: metadata);
  }
}
