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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/user/data/models/proxy_dns_override.dart';

/// Per-profile DNS override editor. Keeps the UI surface minimal: a switch to
/// opt in, plus the most common shape (single resolver routed through *this*
/// profile).
class ProfileDnsOverrideSection extends HookConsumerWidget {
  final ProxyProfileDraftProvider draftProvider;

  const ProfileDnsOverrideSection({super.key, required this.draftProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrideJson = ref.watch(
      draftProvider.select((state) => state.dnsOverrideJson),
    );
    final initialOverride = useMemoized(() {
      if (overrideJson == null || overrideJson.trim().isEmpty) {
        return null;
      }
      try {
        return ProxyDnsOverride.fromJson(
          jsonDecode(overrideJson) as Map<String, dynamic>,
        );
      } catch (_) {
        return null;
      }
    }, [overrideJson]);

    final enabled = useState(initialOverride != null);
    final addressController = useTextEditingController(
      text: initialOverride?.remoteServerAddress ?? '',
    );

    // Reseed controls when the parent passes a new override (e.g. the
    // WireGuard form populating DNS from an imported `[Interface] DNS = …`).
    useEffect(() {
      enabled.value = initialOverride != null;
      final next = initialOverride?.remoteServerAddress ?? '';
      if (addressController.text != next) {
        addressController.text = next;
      }
      return null;
    }, [initialOverride]);

    void emitChange() {
      if (!enabled.value) {
        ref.read(draftProvider.notifier).setDnsOverrideJson(null);
        return;
      }
      final override = ProxyDnsOverride(
        remoteServerAddress: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
      );
      ref
          .read(draftProvider.notifier)
          .setDnsOverrideJson(jsonEncode(override.toJson()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Resolve names through a server reachable inside this profile '
          '(e.g. an internal DoH server behind a corporate WireGuard). '
          'Leave off to use automatic DNS handling.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: enabled.value,
          onChanged: (value) {
            enabled.value = value;
            emitChange();
          },
          title: const Text('Use a profile-specific resolver'),
        ),
        if (enabled.value) ...[
          const SizedBox(height: 8),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'DNS server address',
              hintText: 'https://10.0.0.1/dns-query',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => emitChange(),
          ),
        ],
      ],
    );
  }
}
