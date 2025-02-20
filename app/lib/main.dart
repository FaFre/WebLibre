import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/error_observer.dart';
import 'package:lensai/domain/services/app_initialization.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:lensai/presentation/hooks/on_initialization.dart';
import 'package:lensai/presentation/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('bang_navigator');

  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  // }

  runApp(
    ProviderScope(
      observers: const [ErrorObserver()],
      child: HookConsumer(
        builder: (context, ref, child) {
          final themeMode = ref.watch(
            generalSettingsRepositoryProvider.select(
              (value) => value.themeMode,
            ),
          );

          useOnInitialization(() async {
            await ref
                .read(appInitializationServiceProvider.notifier)
                .initialize();
          });

          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              return MainApp(
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: lightDynamic?.harmonized(),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: darkDynamic?.harmonized(),
                ),
                themeMode: themeMode,
              );
            },
          );
        },
      ),
    ),
  );
}
