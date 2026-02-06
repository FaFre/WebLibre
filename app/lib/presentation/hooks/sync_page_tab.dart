/*
 * Copyright (c) 2024-2026 Fabian Freund.
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

void useSyncPageWithTab(
  TabController tabController,
  PageController pageController, {
  void Function(int index)? onIndexChanged,
}) {
  useEffect(() {
    Future<void> syncPage() async {
      await pageController.animateToPage(
        tabController.index,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 300),
      );
      onIndexChanged?.call(tabController.index);
    }

    void syncTab() {
      if (!tabController.indexIsChanging) {
        final index = pageController.page!.round();

        tabController.animateTo(index);
        onIndexChanged?.call(index);
      }
    }

    tabController.addListener(syncPage);
    pageController.addListener(syncTab);

    return () {
      tabController.removeListener(syncPage);
      pageController.removeListener(syncTab);
    };
  }, [tabController, pageController]);
}
