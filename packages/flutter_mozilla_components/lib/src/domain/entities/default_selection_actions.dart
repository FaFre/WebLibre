/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

typedef PerformAction = void Function(String selectedText);

class BaseSelectionAction extends CustomSelectionAction {
  final PerformAction performAction;

  BaseSelectionAction({
    required super.id,
    required super.title,
    required this.performAction,
    super.pattern,
  });
}

class CallAction extends BaseSelectionAction {
  CallAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_CALL',
        title: 'Call',
        pattern: SelectionPattern.phone,
        performAction: action,
      );
}

class EmailAction extends BaseSelectionAction {
  EmailAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_EMAIL',
        title: 'Email',
        pattern: SelectionPattern.email,
        performAction: action,
      );
}

class DefaultSearchAction extends BaseSelectionAction {
  DefaultSearchAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_SEARCH_DEFAULT',
        title: 'Web Search',
        performAction: action,
      );
}

class SearchAction extends BaseSelectionAction {
  SearchAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_SEARCH',
        title: 'Search',
        performAction: action,
      );
}

class PrivateSearchAction extends BaseSelectionAction {
  PrivateSearchAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_SEARCH_PRIVATELY',
        title: 'Private Search',
        performAction: action,
      );
}

class FindInPageAction extends BaseSelectionAction {
  FindInPageAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_FIND_IN_PAGE',
        title: 'Find in page',
        performAction: action,
      );
}

class ShareAction extends BaseSelectionAction {
  ShareAction(PerformAction action)
    : super(
        id: 'CUSTOM_CONTEXT_MENU_SHARE',
        title: 'Share',
        performAction: action,
      );
}
