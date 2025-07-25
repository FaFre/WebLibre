/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/onboarding/presentation/pages/abstract/i_form_page.dart';
import 'package:weblibre/features/onboarding/presentation/pages/ai_configuration.dart';
import 'package:weblibre/features/onboarding/presentation/pages/default_search.dart';
import 'package:weblibre/features/onboarding/presentation/pages/permissions.dart';
import 'package:weblibre/features/onboarding/presentation/pages/ublock_opt_in.dart';
import 'package:weblibre/features/onboarding/presentation/pages/welcome.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

class OnboardingScreen extends HookConsumerWidget {
  final int currentRevision;
  final int targetRevision;

  const OnboardingScreen({
    super.key,
    required this.currentRevision,
    required this.targetRevision,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final pageController = usePageController();

    final pages = useMemoized<List<Widget>>(() {
      switch (currentRevision) {
        case 1:
          return [const AiConfigurationPage()];
        default:
          return [
            const WelcomePage(),
            const DefaultSearchPage(),
            const AiConfigurationPage(),
            UBlockOptInPage(formKey: GlobalKey<FormState>()),
            PermissionsPage(formKey: GlobalKey<FormState>()),
          ];
      }
    }, [currentRevision, targetRevision]);

    final lastPage = useRef(pageController.initialPage);
    final currentPage = useState(pageController.initialPage);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                children: pages,
                onPageChanged: (value) {
                  if (value > lastPage.value) {
                    if (pages[lastPage.value] case final IFormPage formPage) {
                      formPage.formKey.currentState?.save();
                    }
                  }

                  lastPage.value = value;
                  currentPage.value = value;
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Visibility(
                    visible: currentPage.value > 0,
                    child: TextButton.icon(
                      onPressed: () async {
                        await pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous'),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: pages.length,
                      effect: WormEffect(
                        dotColor: theme.colorScheme.onSurface,
                        activeDotColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (currentPage.value < pages.length - 1)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        await pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                    ),
                  )
                else
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (pages[currentPage.value]
                            case final IFormPage formPage) {
                          formPage.formKey.currentState?.save();
                        }

                        await ref
                            .read(onboardingRepositoryProvider.notifier)
                            .pushRevision(targetRevision);

                        await ref
                            .read(tabRepositoryProvider.notifier)
                            .addTab(url: ref.read(docsUriProvider));

                        ref.invalidate(routerProvider);
                      },
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.done),
                      label: const Text('Done'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
