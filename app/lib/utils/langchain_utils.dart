import 'dart:typed_data';

import 'package:langchain/langchain.dart';

String combineDocuments(List<Document> documents, {String separator = '\n\n'}) {
  return documents.map((d) => d.pageContent).join(separator);
}

Uint8List serializeVector(List<double> vector) {
  final buffer = Float32List.fromList(vector).buffer;
  return Uint8List.view(buffer);
}
