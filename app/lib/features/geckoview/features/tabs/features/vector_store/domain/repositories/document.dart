import 'dart:async';

import 'package:collection/collection.dart';
import 'package:exceptions/exceptions.dart';
import 'package:langchain/langchain.dart' as langchain;
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:lensai/core/providers/models.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/database/daos/vector.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/utils/markdown_document_splitter.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document.g.dart';

@Riverpod()
class DocumentRepository extends _$DocumentRepository {
  late VectorDao _vectorDao;
  late OpenAIEmbeddings _embeddings;

  Future<void> _insertMarkdownDocumentsSplitted(
    List<langchain.Document> originalDocuments, {
    List<(String, String)> headersToSplitOn = const [
      ('#', 'h1'),
      ('##', 'h2'),
      ('###', 'h3'),
      ('####', 'h4'),
      ('#####', 'h5'),
      ('######', 'h6'),
    ],
    int chunkSize = 748,
    int chunkOverlap = 150,
  }) {
    return _vectorDao.transaction(() async {
      for (final doc in originalDocuments) {
        final splitted = splitMarkdownDocument(
          doc,
          headersToSplitOn: headersToSplitOn,
          chunkSize: chunkSize,
          chunkOverlap: chunkOverlap,
        );

        final splittedWithSource = splitted.mapNotNull(
          (splitted) => (
            mainDocumentId: splitted.mainDocumentId,
            parts:
                splitted.parts
                    .map(
                      (part) => part.copyWith(
                        metadata: {...part.metadata, 'source': part.id},
                      ),
                    )
                    .toList(),
          ),
        );

        await _vectorDao.insertDocuments(
          splittedWithSource?.parts ?? [doc],
          mainDocumentId: splittedWithSource?.mainDocumentId,
        );
      }
    });
  }

  Future<Result> updateEmbeddings({String? mainDocumentId, String? contextId}) {
    return Result.fromAsync(() async {
      final missing =
          await _vectorDao
              .getDocumentsWithMissingEmbeddings(
                mainDocumentId: mainDocumentId,
                contextId: contextId,
              )
              .get();

      final documentEmbeddings = await _embeddings.embedDocuments(
        missing
            .map((doc) => langchain.Document(pageContent: doc.content))
            .toList(),
      );

      return _vectorDao.insertEmbeddings(
        missing.mapIndexed((i, doc) => (doc, documentEmbeddings[i])).toList(),
      );
    });
  }

  @override
  void build() {
    _vectorDao = ref.watch(tabDatabaseProvider).vectorDao;
    _embeddings = ref.watch(embeddingModelProvider);

    final tabContentService = ref.watch(tabContentServiceProvider);

    final tabContentSub = tabContentService.tabContentStream.listen((
      content,
    ) async {
      final bestContent =
          content.isProbablyReaderable
              ? content.extractedContentMarkdown
              : content.fullContentMarkdown;

      if (bestContent != null) {
        await _insertMarkdownDocumentsSplitted([
          Document(id: content.tabId, pageContent: bestContent),
        ]);
      }
    });

    ref.onDispose(() async {
      await tabContentSub.cancel();
    });
  }
}
