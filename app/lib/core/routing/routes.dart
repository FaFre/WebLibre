import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lensai/core/routing/widgets/dialog_page.dart';
import 'package:lensai/data/models/web_page_info.dart';
import 'package:lensai/features/about/presentation/screens/about.dart';
import 'package:lensai/features/bangs/presentation/screens/categories.dart';
import 'package:lensai/features/bangs/presentation/screens/list.dart';
import 'package:lensai/features/bangs/presentation/screens/search.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/dialogs/web_page_dialog.dart';
import 'package:lensai/features/geckoview/features/browser/presentation/screens/browser.dart';
import 'package:lensai/features/geckoview/features/search/presentation/screens/search.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/screens/container_edit.dart';
import 'package:lensai/features/geckoview/features/tabs/presentation/screens/container_list.dart';
import 'package:lensai/features/settings/presentation/screens/bang_settings.dart';
import 'package:lensai/features/settings/presentation/screens/general_settings.dart';
import 'package:lensai/features/settings/presentation/screens/settings.dart';
import 'package:lensai/features/settings/presentation/screens/web_engine_hardening.dart';
import 'package:lensai/features/settings/presentation/screens/web_engine_hardening_group.dart';
import 'package:lensai/features/settings/presentation/screens/web_engine_settings.dart';
import 'package:lensai/features/tor/presentation/screens/tor_proxy.dart';
import 'package:lensai/features/user/presentation/screens/auth.dart';

part 'routes.g.dart';
part 'routes.settings.dart';
part 'routes.browser.dart';
part 'routes.bangs.dart';

@TypedGoRoute<AboutRoute>(name: 'AboutRoute', path: '/about')
class AboutRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const AboutDialogScreen());
  }
}

@TypedGoRoute<UserAuthRoute>(name: 'UserAuthRoute', path: '/userAuth')
class UserAuthRoute extends GoRouteData {
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return DialogPage(builder: (_) => const UserAuthScreen());
  }
}
