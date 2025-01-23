import 'dart:io';

import 'package:langchain_openai/langchain_openai.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'models.g.dart';

// @Riverpod(keepAlive: true)
// ChatOpenAI summarizerModel(Ref ref) {
//   final openaiApiKey = Platform.environment['OPENAI_API_KEY'];
//   return ChatOpenAI(
//     apiKey: openaiApiKey,
//     baseUrl: 'https://api.together.xyz/v1',
//     defaultOptions: const ChatOpenAIOptions(model: 'deepseek-ai/DeepSeek-V3'),
//   );
// }

@Riverpod(keepAlive: true)
ChatOpenAI chatModel(Ref ref) {
  final openaiApiKey = 'FfTBKW1t5dOOXVoiaF2hbXPAHiz3fvfy';
  return ChatOpenAI(
    apiKey: openaiApiKey,
    baseUrl: 'https://api.deepinfra.com/v1/openai',
    defaultOptions: const ChatOpenAIOptions(
      model: 'meta-llama/Llama-3.3-70B-Instruct-Turbo',
    ),
  );
}

@Riverpod(keepAlive: true)
OpenAIEmbeddings embeddingModel(Ref ref) {
  final openaiApiKey = 'FfTBKW1t5dOOXVoiaF2hbXPAHiz3fvfy';
  return OpenAIEmbeddings(
    apiKey: openaiApiKey,
    baseUrl: 'https://api.deepinfra.com/v1/openai',
    model: 'BAAI/bge-m3',
  );
}

@Riverpod(keepAlive: true)
int embeddingDimensions(Ref ref) => 1024;
