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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/profile_editor_section.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';

class CustomOutboundProfileForm extends HookConsumerWidget {
  final ProxyProfileDraftProvider draftProvider;
  final ProxyProfileDraftState draft;

  const CustomOutboundProfileForm({
    super.key,
    required this.draftProvider,
    required this.draft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configController = useTextEditingController(
      text: draft.customConfigJson,
    );
    final secretController = useTextEditingController(
      text: draft.customSecretJson,
    );

    useEffect(() {
      if (configController.text != draft.customConfigJson) {
        configController.text = draft.customConfigJson;
      }
      return null;
    }, [draft.customConfigJson]);

    useEffect(() {
      if (secretController.text != draft.customSecretJson) {
        secretController.text = draft.customSecretJson;
      }
      return null;
    }, [draft.customSecretJson]);

    final notifier = ref.read(draftProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileEditorSection(
          title: 'Outbound',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: configController,
              minLines: 10,
              maxLines: 18,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Outbound JSON',
                helperText: 'Public sing-box outbound object.',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.setCustomConfigJson,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ProfileEditorSection(
          title: 'Secrets',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ObscurableTextField(
              controller: secretController,
              enabled: draft.secretLoaded,
              revealedMinLines: 4,
              revealedMaxLines: 10,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Secret JSON',
                helperText:
                    'Optional values merged into the outbound at runtime.',
                border: OutlineInputBorder(),
              ),
              onChanged: notifier.setCustomSecretJson,
            ),
          ),
        ),
      ],
    );
  }
}
