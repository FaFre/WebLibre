import 'package:collection/collection.dart';
import 'package:langchain/langchain.dart';
import 'package:lensai/core/uuid.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/utils/document_uuid.dart';

typedef DocumentParts = ({String mainDocumentId, List<Document> parts});

List<Document> mergeShortDocuments(
  List<Document> documents,
  int maxLength, {
  String separator = '\n',
  required Document Function(Document a, Document b) doMerge,
  int Function(String) lengthFunction = TextSplitter.defaultLengthFunction,
}) {
  final result = <Document>[];

  Document? current;
  for (final doc in documents) {
    if (current == null) {
      current = doc;
    } else if (lengthFunction(current.pageContent) +
            lengthFunction(doc.pageContent) <=
        maxLength) {
      current = doMerge(current, doc);
    } else {
      result.add(current);
      current = doc;
    }
  }

  if (current != null) {
    result.add(current);
  }

  return result;
}

List<String> _headerValueList(dynamic value) {
  return switch (value) {
    String _ => [value],
    List<String> _ => value,
    _ => throw Exception('Unsupported type'),
  };
}

DocumentParts? splitMarkdownDocument(
  Document originalDoc, {
  required List<(String, String)> headersToSplitOn,
  required int chunkSize,
  required int chunkOverlap,
}) {
  final markdownHeaderSplitter = MarkdownHeaderTextSplitter(
    stripHeaders: false,
    headersToSplitOn: headersToSplitOn,
  );

  final markdownTextSplitter = MarkdownTextSplitter(
    chunkSize: chunkSize,
    chunkOverlap: chunkOverlap,
  );

  final headerChunks = markdownHeaderSplitter.splitText(
    originalDoc.pageContent,
  );
  final docChunks = markdownTextSplitter.splitDocuments(headerChunks);

  if (docChunks.length == 1) {
    return null;
  }

  final headerKeys = headersToSplitOn.map((header) => header.$2).toSet();
  final mergedDocChunks = mergeShortDocuments(
    docChunks,
    chunkSize,
    doMerge: (a, b) {
      //Disallow merging into headers of the same
      final intersectingHeaders = a.metadata.keys
          .toSet()
          .intersection(b.metadata.keys.toSet())
          .intersection(headerKeys);

      return Document(
        id: a.id ?? b.id,
        pageContent: '${a.pageContent}\n${b.pageContent}',
        metadata: {
          ...a.metadata,
          ...b.metadata,
          for (final header in intersectingHeaders)
            header:
                {
                  ..._headerValueList(a.metadata[header]),
                  ..._headerValueList(b.metadata[header]),
                }.toList(),
        },
      );
    },
  );

  final mainDocumentId = originalDoc.id ?? uuid.v4();
  final documentIdFactory = DocumentUuid.fromUuid(mainDocumentId);

  return (
    mainDocumentId: mainDocumentId,
    parts:
        mergedDocChunks
            .mapIndexed(
              (i, doc) => Document(
                id: documentIdFactory.getDocumentPartUuid(i),
                pageContent: doc.pageContent,
                metadata: mergeMaps(originalDoc.metadata, doc.metadata),
              ),
            )
            .toList(),
  );
}
