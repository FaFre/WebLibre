import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';

part 'container_topic.g.dart';

@Riverpod()
class ContainerTopicController extends _$ContainerTopicController {
  Future<String?> predictDocumentTopic(String containerId) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      return await ref.read(containerTopicProvider(containerId).future);
    });
    state = result;

    return result.valueOrNull;
  }

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }
}
