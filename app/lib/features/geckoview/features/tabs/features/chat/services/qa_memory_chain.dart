import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:lensai/core/models.dart';
import 'package:lensai/features/geckoview/features/tabs/data/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/domain/sqlite_vector_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'qa_memory_chain.g.dart';

typedef QAResult = ({String answer, List<Document> docs});

@Riverpod()
class QAMemoryChain extends _$QAMemoryChain {
  late RetrievalQAChain _retrievalQA;

  @override
  void build({
    required String chatId,
    String? mainDocumentId,
    String? contextId,
  }) {
    final chatModel = ref.watch(chatModelProvider);
    final embeddingsModel = ref.watch(embeddingModelProvider);
    final db = ref.watch(tabDatabaseProvider);

    final retriever = SqliteVectorStore(
      db.vectorDao,
      embeddings: embeddingsModel,
      mainDocumentId: mainDocumentId,
      contextId: contextId,
    ).asRetriever(
      defaultOptions: const VectorStoreRetrieverOptions(
        searchType: VectorStoreSimilaritySearch(k: 6),
      ),
    );

    final qaChain = OpenAIQAWithSourcesChain(llm: chatModel);
    final docPrompt = PromptTemplate.fromTemplate(
      'Content: {page_content}\nSource: {source}',
    );

    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docPrompt,
    );

    _retrievalQA = RetrievalQAChain(
      retriever: retriever,
      combineDocumentsChain: finalQAChain,
    );
  }

  Future<QAResult> processQuestion(String input) async {
    final result = await _retrievalQA(input);
    final qaResult = result['result'] as QAWithSources;

    return (answer: qaResult.answer, docs: <Document>[]);
  }
}
