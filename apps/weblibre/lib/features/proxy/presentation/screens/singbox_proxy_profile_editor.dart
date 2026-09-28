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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/proxy/presentation/utils/proxy_profile_draft_error_l10n.dart';
import 'package:weblibre/features/proxy/presentation/utils/singbox_proxy_profile_type_l10n.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/custom_outbound_profile_form.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/profile_dns_override_section.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/profile_editor_section.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_editor/structured_profile_form.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/button_spinner.dart';
import 'package:weblibre/utils/ui_helper.dart';

class SingboxProxyProfileEditorScreen extends ConsumerWidget {
  final String? profileId;
  final ProxyProfileSeed? seed;

  const SingboxProxyProfileEditorScreen({super.key, this.profileId, this.seed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final draftProvider = proxyProfileDraftProvider(
      profileId: profileId,
      seed: seed,
    );
    final draft = ref.watch(draftProvider);

    if (draft.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.proxy_editProfileTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (draft.loadError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.proxy_editProfileTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(draft.loadError!.describe(context)),
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
    final l10n = AppLocalizations.of(context);

    Future<void> handleSave() async {
      final outcome = await ref.read(draftProvider.notifier).save();
      if (!context.mounted) return;

      switch (outcome) {
        case SaveSucceeded():
          Navigator.pop(context);
        case SaveFailed(:final error):
          showErrorMessage(context, error.describe(context));
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
            label: Text(
              draft.isEditing
                  ? l10n.proxy_saveChanges
                  : l10n.proxy_createProfile,
            ),
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
                  title: Text(
                    draft.isEditing
                        ? l10n.proxy_editProfileTitle
                        : l10n.proxy_newProfileTitle,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      ProfileEditorSection(
                        title: l10n.proxy_sectionGeneral,
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
                        title: l10n.proxy_sectionDnsOverride,
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
                            l10n.proxy_addMenuTip,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      if (draft.type == SingboxProxyProfileType.wireguard) ...[
                        const SizedBox(height: 12),
                        const _WireGuardDisclaimer(),
                      ],
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

class _WireGuardDisclaimer extends StatelessWidget {
  const _WireGuardDisclaimer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        l10n.proxy_wireGuardTrademarkDisclaimer(wireGuardBrand),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
    final l10n = AppLocalizations.of(context);
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
          decoration: InputDecoration(
            labelText: l10n.proxy_fieldProfileName,
            border: const OutlineInputBorder(),
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
            decoration: InputDecoration(
              labelText: l10n.proxy_fieldProtocol,
              border: const OutlineInputBorder(),
              helperText: l10n.proxy_protocolFixedHelper,
            ),
            child: Text(draft.type.label(context)),
          )
        else
          DropdownButtonFormField<SingboxProxyProfileType>(
            key: ValueKey(draft.type),
            initialValue: draft.type,
            decoration: InputDecoration(
              labelText: l10n.proxy_fieldProtocol,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final type in SingboxProxyProfileType.values)
                DropdownMenuItem(value: type, child: Text(type.label(context))),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(draftProvider.notifier).setType(value);
              }
            },
          ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(MdiIcons.rocketLaunchOutline),
          title: Text(l10n.proxy_startAutomaticallyTitle),
          subtitle: Text(l10n.proxy_startAutomaticallySubtitle),
          value: draft.autostart,
          onChanged: ref.read(draftProvider.notifier).setAutostart,
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
