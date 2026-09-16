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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show AppLinkPromptRequest;
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';

/// A reason this prompt was raised whatever the user's "open links in apps"
/// mode says, paired with the icon that carries it.
@immutable
class AppLinkPromptWarning {
  final IconData icon;
  final String message;

  const AppLinkPromptWarning({required this.icon, required this.message});
}

/// Why the classifier forced this prompt (§2.4 step 4): a proxied or strict
/// container, a private tab, or a wallet scheme. These prompts arrive with
/// `canRemember = false` and cannot be turned off by setting a mode, so the
/// prompt has to say what it is protecting — otherwise the user is asked to
/// approve leaving a proxied container without being told that is the question.
///
/// Empty for an ordinary prompt, which needs no justification beyond the mode
/// the user chose.
List<AppLinkPromptWarning> appLinkPromptWarnings(AppLinkPromptRequest request) {
  return [
    // Deliberately does not name a proxy. `isProtectedContext` covers three different
    // arrangements — a container routed through a proxy, a strict container with no proxy at
    // all, and a protected destination reached from an ordinary tab — and native sends only
    // the verdict, not which one it was. Naming the proxy would promise an assurance that is
    // simply absent in two of the three cases.
    if (request.isProtectedContext)
      const AppLinkPromptWarning(
        icon: Icons.shield_outlined,
        message:
            'This link is protected here. The app opens its own connection, '
            'outside the rules this tab follows.',
      ),
    if (request.isPrivate)
      const AppLinkPromptWarning(
        icon: Icons.visibility_off_outlined,
        message:
            'This is a private tab. The app keeps its own history and '
            'sign-in state.',
      ),
    if (request.isWallet)
      const AppLinkPromptWarning(
        icon: Icons.badge_outlined,
        message:
            'This link asks a wallet app for credentials. Open it only if '
            'you started this.',
      ),
  ];
}

/// The target a prompt is offering, and why it was forced.
///
/// Both prompts showed the app's name and nothing else, so a forced prompt gave
/// the user no way to see where they were being asked to go — the one case where
/// that matters most, since it is the case they cannot switch off.
class AppLinkPromptDetails extends StatelessWidget {
  final AppLinkPromptRequest request;

  /// Tightens spacing and drops the target line to one row, for the banner.
  final bool dense;

  const AppLinkPromptDetails({
    required this.request,
    this.dense = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warnings = appLinkPromptWarnings(request);
    final targetUri = Uri.tryParse(request.target.url);
    final targetStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (targetUri != null)
          UriBreadcrumb(uri: targetUri, style: targetStyle)
        else
          Text(
            request.target.url,
            maxLines: dense ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: targetStyle,
          ),
        for (final warning in warnings) ...[
          SizedBox(height: dense ? 4 : 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                warning.icon,
                size: 16,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warning.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
