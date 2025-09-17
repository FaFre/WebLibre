import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/history/domain/providers.dart';

class HistoryScreen extends HookConsumerWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(
      browsingHistoryProvider(
        start: DateTime(0),
        end: DateTime.now(),
        types: {
          VisitType.link,
          VisitType.redirectPermanent,
          VisitType.redirectTemporary,
          VisitType.typed,
        },
      ),
    );
  }
}
