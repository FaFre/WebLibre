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
import 'package:weblibre/features/proxy/data/forms/singbox_form_field.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_spec.dart';
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/profile_editor_section.dart';
import 'package:weblibre/presentation/widgets/obscurable_text_field.dart';

class StructuredProfileForm extends HookConsumerWidget {
  final SingboxProxyFormSpec spec;
  final ProxyProfileDraftProvider draftProvider;
  final ProxyProfileDraftState draft;

  const StructuredProfileForm({
    super.key,
    required this.spec,
    required this.draftProvider,
    required this.draft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllers = useMemoized(
      () => {
        for (final field in spec.fields) field.key: TextEditingController(),
      },
      [spec.type],
    );

    useEffect(() {
      return () {
        for (final controller in controllers.values) {
          controller.dispose();
        }
      };
    }, [controllers]);

    useEffect(() {
      _syncControllers(controllers, draft.values);
      return null;
    }, [controllers, draft.values]);

    final sections = _structuredFieldSections(spec.fields);
    final notifier = ref.read(draftProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (sectionIndex, section) in sections.indexed) ...[
          if (sectionIndex > 0) const SizedBox(height: 24),
          ProfileEditorSection(
            title: section.title,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _SectionFields(
                fields: section.fields,
                controllers: controllers,
                secretLoaded: draft.secretLoaded,
                onChanged: notifier.setFieldValue,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Advanced protocol options can still be entered with Custom Outbound JSON.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SectionFields extends StatelessWidget {
  final List<SingboxProxyFormField> fields;
  final Map<String, TextEditingController> controllers;
  final bool secretLoaded;
  final void Function(String key, String value) onChanged;

  const _SectionFields({
    required this.fields,
    required this.controllers,
    required this.secretLoaded,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, field) in fields.indexed) ...[
          if (index > 0) const SizedBox(height: 16),
          if (field.isBoolean)
            _BooleanField(
              field: field,
              controller: controllers[field.key]!,
              onChanged: (value) => onChanged(field.key, value),
            )
          else if (field.isSecret)
            ObscurableTextField(
              controller: controllers[field.key],
              enabled: secretLoaded,
              keyboardType: field.isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              textInputAction: index == fields.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              revealedMinLines: field.key == 'private_key' ? 4 : null,
              revealedMaxLines: field.key == 'private_key' ? 8 : 1,
              decoration: InputDecoration(
                labelText: field.required ? '${field.label} *' : field.label,
                helperText: field.helperText ?? 'Stored in secure storage.',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => onChanged(field.key, value),
            )
          else
            TextField(
              controller: controllers[field.key],
              keyboardType: field.isNumber
                  ? TextInputType.number
                  : field.isStringList
                  ? TextInputType.multiline
                  : TextInputType.text,
              textInputAction: field.isStringList
                  ? TextInputAction.newline
                  : index == fields.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              minLines: field.isStringList ? 2 : 1,
              maxLines: field.isStringList ? 4 : 1,
              decoration: InputDecoration(
                labelText: field.required ? '${field.label} *' : field.label,
                helperText: field.helperText,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => onChanged(field.key, value),
            ),
        ],
      ],
    );
  }
}

({String title, List<SingboxProxyFormField> fields}) _section(
  String title,
  List<SingboxProxyFormField> fields,
) {
  return (title: title, fields: fields);
}

List<({String title, List<SingboxProxyFormField> fields})>
_structuredFieldSections(List<SingboxProxyFormField> fields) {
  final basic = <SingboxProxyFormField>[];
  final tls = <SingboxProxyFormField>[];
  final transport = <SingboxProxyFormField>[];
  final multiplex = <SingboxProxyFormField>[];
  final dial = <SingboxProxyFormField>[];
  final secrets = <SingboxProxyFormField>[];
  final protocol = <SingboxProxyFormField>[];

  for (final field in fields) {
    if (field.key.startsWith('tls.')) {
      tls.add(field);
    } else if (field.key.startsWith('transport.')) {
      transport.add(field);
    } else if (field.key.startsWith('multiplex.')) {
      multiplex.add(field);
    } else if (_dialFieldKeys.contains(field.key)) {
      dial.add(field);
    } else if (field.isSecret) {
      secrets.add(field);
    } else if (_basicFieldKeys.contains(field.key)) {
      basic.add(field);
    } else {
      protocol.add(field);
    }
  }

  return [
    if (basic.isNotEmpty) _section('Connection', basic),
    if (secrets.isNotEmpty) _section('Credentials', secrets),
    if (protocol.isNotEmpty) _section('Protocol Options', protocol),
    if (tls.isNotEmpty) _section('TLS', tls),
    if (transport.isNotEmpty) _section('Transport', transport),
    if (multiplex.isNotEmpty) _section('Multiplex', multiplex),
    if (dial.isNotEmpty) _section('Dial', dial),
  ];
}

const _basicFieldKeys = {
  'server',
  'server_port',
  'version',
  'local_address',
  'peer_public_key',
};
const _dialFieldKeys = {
  'detour',
  'bind_interface',
  'routing_mark',
  'domain_strategy',
  'connect_timeout',
};

void _syncControllers(
  Map<String, TextEditingController> controllers,
  Map<String, String> values,
) {
  for (final entry in controllers.entries) {
    final next = values[entry.key] ?? '';
    if (entry.value.text != next) {
      entry.value.text = next;
    }
  }
}

class _BooleanField extends HookWidget {
  final SingboxProxyFormField field;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _BooleanField({
    required this.field,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = useListenableSelector(
      controller,
      () => parseFormBool(controller.text),
    );

    return InputDecorator(
      decoration: InputDecoration(
        labelText: field.required ? '${field.label} *' : field.label,
        helperText: field.helperText,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value == null
                  ? 'Unset (uses default)'
                  : (value ? 'Enabled' : 'Disabled'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (value != null)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                controller.text = '';
                onChanged('');
              },
            ),
          Switch(
            value: value ?? false,
            onChanged: (next) {
              final text = next ? 'true' : 'false';
              controller.text = text;
              onChanged(text);
            },
          ),
        ],
      ),
    );
  }
}
