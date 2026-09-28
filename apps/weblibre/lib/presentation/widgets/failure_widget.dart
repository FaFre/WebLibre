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
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/error_l10n.dart';

class FailureWidget extends StatelessWidget {
  const FailureWidget({
    super.key,
    this.title,
    this.exception,
    this.onRetry,
    this.compact = false,
  });

  final String? title;
  final dynamic exception;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(title ?? l10n.failureWidget_defaultTitle),
            subtitle: exception != null
                ? Text(describeError(l10n, exception as Object))
                : null,
            trailing: compact && onRetry != null
                ? IconButton.outlined(
                    onPressed: onRetry,
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.refresh_outlined),
                  )
                : null,
            textColor: Theme.of(context).colorScheme.error,
          ),
          if (!compact && onRetry != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: Text(l10n.common_retry),
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
