import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:langchain/langchain.dart' as langchain;
import 'package:lensai/core/uuid.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/models/vector_result.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/utils/hash.dart';
import 'package:lensai/utils/langchain_utils.dart';

part 'vector.g.dart';

@DriftAccessor()
class VectorDao extends DatabaseAccessor<TabDatabase> with _$VectorDaoMixin {
  VectorDao(super.attachedDatabase);

  Future<int> deleteDocuments(List<String> ids) {
    return db.document.deleteWhere((doc) => doc.documentId.isIn(ids));
  }

  Future<int> deleteDocumentsByMainDocumentId(String mainDocumentId) {
    return db.document
        .deleteWhere((doc) => doc.mainDocumentId.equals(mainDocumentId));
  }

  SingleOrNullSelectable<DocumentData> getDocumentById(String documentId) {
    return db.document.select()
      ..where((row) => row.documentId.equals(documentId));
  }

  Selectable<DocumentData> getDocuments({
    String? mainDocumentId,
    String? contextId,
  }) {
    final statement = db.document.select();

    if (mainDocumentId != null) {
      statement.where((row) => row.mainDocumentId.equals(mainDocumentId));
    }

    if (contextId != null) {
      statement.where((row) => row.contextId.equals(contextId));
    }

    return statement;
  }

  Selectable<DocumentData> getDocumentsWithMissingEmbeddings({
    String? mainDocumentId,
    String? contextId,
  }) {
    return db.missingDocumentEmbeddings(
      mainDocumentId: mainDocumentId,
      contextId: contextId,
    );
  }

  Future<void> insertDocuments(
    List<langchain.Document> documents, {
    String? mainDocumentId,
    String? contextId,
  }) {
    return db.document.insertAll(
      documents.map((document) {
        final documentId = document.id ?? uuid.v4();
        final contentHash = sha2(document.pageContent);

        return DocumentCompanion.insert(
          documentId: documentId,
          mainDocumentId: Value.absentIfNull(mainDocumentId),
          contextId: Value.absentIfNull(contextId),
          content: document.pageContent,
          metadata: (document.metadata.isNotEmpty)
              ? Value(jsonEncode(document.metadata))
              : const Value.absent(),
          contentHash: contentHash,
        );
      }),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> insertEmbeddings(List<(DocumentData, List<double>)> documents) {
    return db.documentVec.insertAll(
      documents.map(
        (doc) {
          final (document, vector) = doc;

          return DocumentVecCompanion.insert(
            id: document.documentId,
            embedding: serializeVector(vector),
            mainDocumentId: Value.absentIfNull(document.mainDocumentId),
            contextId: Value.absentIfNull(document.contextId),
            contentHash: document.contentHash,
          );
        },
      ),
    );
  }

  Future<List<String>> insertDocumentsWithEmbedings(
    List<(langchain.Document, List<double>)> documents, {
    String? mainDocumentId,
    String? contextId,
  }) async {
    final insertedIds = <String>[];

    await db.batch((b) async {
      final insertableDocuments = <Insertable<DocumentData>>[];
      final insertableEmbeddings = <Insertable<DocumentVecData>>[];

      for (final (document, vector) in documents) {
        final documentId = document.id ?? uuid.v4();
        final contentHash = sha2(document.pageContent);

        insertedIds.add(documentId);

        insertableDocuments.add(
          DocumentCompanion.insert(
            documentId: documentId,
            mainDocumentId: Value.absentIfNull(mainDocumentId),
            contextId: Value.absentIfNull(contextId),
            content: document.pageContent,
            metadata: (document.metadata.isNotEmpty)
                ? Value(jsonEncode(document.metadata))
                : const Value.absent(),
            contentHash: contentHash,
          ),
        );

        insertableEmbeddings.add(
          DocumentVecCompanion.insert(
            id: documentId,
            embedding: serializeVector(vector),
            mainDocumentId: Value.absentIfNull(mainDocumentId),
            contextId: Value.absentIfNull(contextId),
            contentHash: contentHash,
          ),
        );
      }

      await db.document.insertAll(
        insertableDocuments,
        mode: InsertMode.insertOrReplace,
      );

      await db.documentVec.insertAll(insertableEmbeddings);
    });

    return insertedIds;
  }

  Selectable<VectorResult> vectorSearch({
    required langchain.VectorStoreSimilaritySearch config,
    required List<double> searchVectors,
    String? mainDocumentId,
    String? contextId,
  }) {
    assert(config.filter?.isNotEmpty ?? true, 'Filters are unsupported');
    assert(
      !(mainDocumentId != null && contextId != null),
      'Either filter by document or context, not both',
    );

    return db.queryVectors(
      searchVectors: serializeVector(searchVectors),
      k: config.k,
      mainDocumentId: mainDocumentId,
      contextId: contextId,
    );
  }
}
