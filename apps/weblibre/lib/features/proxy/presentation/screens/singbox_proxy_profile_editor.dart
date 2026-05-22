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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/domain/extensions/singbox_proxy_profile_type_x.dart';
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/custom_outbound_profile_form.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/profile_dns_override_section.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/profile_editor_section.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/structured_profile_form.dart';
import 'package:weblibre/presentation/widgets/button_spinner.dart';
import 'package:weblibre/utils/ui_helper.dart';

class SingboxProxyProfileEditorScreen extends ConsumerWidget {
  final String? profileId;
  final ProxyProfileSeed? seed;

  const SingboxProxyProfileEditorScreen({super.key, this.profileId, this.seed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftProvider = proxyProfileDraftProvider(
      profileId: profileId,
      seed: seed,
    );
    final draft = ref.watch(draftProvider);

    if (draft.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (draft.loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(draft.loadError!),
          ),
        ),
      );
    }

    return _Editor(draftProvider: draftProvider, draft: draft);
  }
}

class _Editor extends ConsumerWidget {
  final ProxyProfileDraftProvider draftProvider;
  final ProxyProfileDraftState draft;

  const _Editor({required this.draftProvider, required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> handleSave() async {
      final outcome = await ref.read(draftProvider.notifier).save();
      if (!context.mounted) return;

      switch (outcome) {
        case SaveSucceeded():
          Navigator.pop(context);
        case SaveFailed(:final message):
          showErrorMessage(context, message);
      }
    }

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: draft.isSaving ? null : handleSave,
            icon: draft.isSaving
                ? const ButtonSpinner()
                : const Icon(Icons.check),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            label: Text(draft.isEditing ? 'Save Changes' : 'Create Profile'),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return CustomScrollView(
              controller: controller,
              slivers: [
                SliverAppBar.large(
                  centerTitle: false,
                  title: Text(draft.isEditing ? 'Edit Profile' : 'New Profile'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      ProfileEditorSection(
                        title: 'General',
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _GeneralSection(
                            draftProvider: draftProvider,
                            draft: draft,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ProtocolForm(draftProvider: draftProvider, draft: draft),
                      const SizedBox(height: 24),
                      ProfileEditorSection(
                        title: 'DNS Override',
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: ProfileDnsOverrideSection(
                            draftProvider: draftProvider,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!draft.isEditing)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Tip: use the add menu on the previous screen to '
                            'import from a file, paste a share link, or scan '
                            'a QR code.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GeneralSection extends HookConsumerWidget {
  final ProxyProfileDraftProvider draftProvider;
  final ProxyProfileDraftState draft;

  const _GeneralSection({required this.draftProvider, required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: draft.name);
    useEffect(() {
      if (nameController.text != draft.name) {
        nameController.text = draft.name;
      }
      return null;
    }, [draft.name]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            border: OutlineInputBorder(),
          ),
          onChanged: ref.read(draftProvider.notifier).setName,
        ),
        const SizedBox(height: 16),
        if (draft.isEditing)
          // Protocol is locked after creation: each type stores a different
          // config/secret JSON shape, so switching mid-edit would silently
          // rewrite the profile under a foreign schema. To change protocol,
          // create a new profile.
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Protocol',
              border: OutlineInputBorder(),
              helperText: 'Protocol is fixed once a profile is created.',
            ),
            child: Text(draft.type.label),
          )
        else
          DropdownButtonFormField<SingboxProxyProfileType>(
            key: ValueKey(draft.type),
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Protocol',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final type in SingboxProxyProfileType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(draftProvider.notifier).setType(value);
              }
            },
          ),
      ],
    );
  }
}

class _ProtocolForm extends StatelessWidget {
  final ProxyProfileDraftProvider draftProvider;
  final ProxyProfileDraftState draft;

  const _ProtocolForm({required this.draftProvider, required this.draft});

  @override
  Widget build(BuildContext context) {
    final spec = singboxProxyFormSpecs[draft.type];
    if (spec != null) {
      return StructuredProfileForm(
        key: ValueKey((draft.type, draft.profileId)),
        spec: spec,
        draftProvider: draftProvider,
        draft: draft,
      );
    }

    return CustomOutboundProfileForm(
      key: ValueKey(('custom', draft.profileId)),
      draftProvider: draftProvider,
      draft: draft,
    );
  }
}
