import 'package:collection/collection.dart';
import 'package:langchain/langchain.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/database/daos/vector.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/models/vector_result.dart';

class SqliteVectorStore extends VectorStore {
  final VectorDao _dao;

  final String? mainDocumentId;
  final String? contextId;

  SqliteVectorStore(
    this._dao, {
    required super.embeddings,
    this.mainDocumentId,
    this.contextId,
  });

  @override
  Future<List<String>> addVectors({
    required List<Document> documents,
    required List<List<double>> vectors,
  }) {
    return _dao.insertDocumentsWithEmbedings(
      documents.mapIndexed((i, doc) => (doc, vectors[i])).toList(),
      contextId: contextId,
      mainDocumentId: mainDocumentId,
    );
  }

  @override
  Future<void> delete({required List<String> ids}) {
    return _dao.deleteDocuments(ids);
  }

  @override
  Future<List<(Document, double)>> similaritySearchByVectorWithScores({
    required List<double> embedding,
    VectorStoreSimilaritySearch config = const VectorStoreSimilaritySearch(),
  }) async {
    Iterable<VectorResult> results =
        await _dao
            .vectorSearch(
              config: config,
              searchVectors: embedding,
              contextId: contextId,
              mainDocumentId: mainDocumentId,
            )
            .get();

    if (config.scoreThreshold != null) {
      results = results.where(
        (result) => result.distance >= config.scoreThreshold!,
      );
    }

    return results
        .map((result) => (result.toDocument(), result.distance))
        .toList();
  }
}
