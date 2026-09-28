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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/bangs/domain/services/bang_query.dart';
import 'package:weblibre/features/bangs/presentation/dialogs/delete_bang_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class EditBangScreen extends HookConsumerWidget {
  final Bang? initialBang;

  /// The form is seeded from a bang the user does not own, and saving creates
  /// their own copy instead of writing back to the source. See
  /// [EditUserBangRoute.fork].
  final bool fork;

  const EditBangScreen({
    super.key,
    required this.initialBang,
    this.fork = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // A fork looks like an edit but behaves like a new bang: there is no
    // existing user bang behind it to rename, overwrite or delete.
    final editsExistingUserBang = initialBang != null && !fork;
    final categories = ref.watch(
      bangCategoriesProvider.select((value) => value.value),
    );

    final nameTextController = useTextEditingController(
      text: initialBang?.websiteName,
    );
    final triggerTextController = useTextEditingController(
      text: initialBang?.trigger,
    );
    final urlTextController = useTextEditingController(
      text: initialBang?.urlTemplate,
    );
    final aliasTextController = useTextEditingController(
      text: formatBangAliases(initialBang?.additionalTriggers),
    );

    final category = useState(initialBang?.category);
    final subCategory = useState(initialBang?.subCategory);
    final formatFlags = useState(
      initialBang?.format ??
          {BangFormat.urlEncodePlaceholder, BangFormat.urlEncodeSpaceToPlus},
    );

    void updateFormatFlag(BangFormat flag, bool enabled) {
      final flags = {...formatFlags.value};

      if (enabled) {
        flags.add(flag);
      } else {
        flags.remove(flag);
      }

      formatFlags.value = flags;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fork
              ? l10n.bangs_editTitleCustomize
              : initialBang == null
              ? l10n.bangs_editTitleNew
              : l10n.bangs_editTitleEdit,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final name = nameTextController.text.trim();
                final trigger = triggerTextController.text.trim();
                final urlTemplate = urlTextController.text.trim();

                final existingBang = await ref
                    .read(bangDataRepositoryProvider.notifier)
                    .getBang(BangKey(group: BangGroup.user, trigger: trigger));

                if ((!editsExistingUserBang && existingBang != null) ||
                    (editsExistingUserBang &&
                        existingBang != null &&
                        existingBang.trigger != initialBang!.trigger)) {
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      l10n.bangs_triggerAlreadyExists(trigger),
                    );
                  }

                  return;
                }

                final uri = parseValidatedUrl(
                  urlTemplate,
                  eagerParsing: false,
                  onlyHttpProtocol: true,
                );
                if (uri == null) {
                  return;
                }

                final bang = Bang(
                  group: BangGroup.user,
                  trigger: trigger,
                  websiteName: name,
                  domain: uri.host,
                  urlTemplate: urlTemplate,
                  searxngApi: false,
                  category: category.value,
                  subCategory: subCategory.value,
                  additionalTriggers: parseBangAliases(
                    aliasTextController.text,
                    trigger: trigger,
                  ),
                  snapDomain: initialBang?.snapDomain,
                  format: formatFlags.value,
                );

                if (editsExistingUserBang &&
                    initialBang!.trigger != bang.trigger) {
                  await ref
                      .read(bangDataRepositoryProvider.notifier)
                      .deleteBang(
                        BangKey(
                          group: BangGroup.user,
                          trigger: initialBang!.trigger,
                        ),
                      );
                }

                await ref
                    .read(bangDataRepositoryProvider.notifier)
                    .upsertBang(bang);

                if (context.mounted) {
                  context.pop();
                }
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),

      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView(
              children: [
                TextFormField(
                  controller: nameTextController,
                  decoration: InputDecoration(
                    label: Text(l10n.bangs_fieldNameLabel),
                    helper: Text(l10n.bangs_fieldNameHelper),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) =>
                      validateRequired(value?.trim(), l10n: l10n),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: triggerTextController,
                  decoration: InputDecoration(
                    label: Text(l10n.bangs_fieldTriggerLabel),
                    helper: Text(l10n.bangs_fieldTriggerHelper),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) =>
                      validateRequired(value?.trim(), l10n: l10n),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: aliasTextController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    label: Text(l10n.bangs_fieldAdditionalTriggersLabel),
                    helper: Text(l10n.bangs_fieldAdditionalTriggersHelper),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlTextController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    label: Text(l10n.bangs_fieldUrlLabel),
                    helper: Text(l10n.bangs_fieldUrlHelper('{{{s}}}')),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    final urlTemplate = value?.trim();

                    if (urlTemplate?.contains('{{{s}}}') != true) {
                      return l10n.bangs_fieldUrlMissingPlaceholder('{{{s}}}');
                    }

                    return validateUrl(
                      urlTemplate,
                      eagerParsing: false,
                      onlyHttpProtocol: true,
                      l10n: l10n,
                    );
                  },
                ),
                const SizedBox(height: 24),
                DropdownMenuFormField(
                  key: ValueKey(EquatableValue([category.value, categories])),
                  enableFilter: true,
                  requestFocusOnTap: true,
                  label: Text(l10n.bangs_fieldCategoryLabel),
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: category.value,
                  dropdownMenuEntries: [
                    ...?categories?.keys.map(
                      (e) => DropdownMenuEntry(value: e, label: e),
                    ),
                  ],
                  onSelected: (value) {
                    if (category.value != value) {
                      category.value = value;
                      subCategory.value = null;
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownMenuFormField(
                  key: ValueKey(
                    EquatableValue([subCategory.value, categories]),
                  ),
                  enableFilter: true,
                  requestFocusOnTap: true,
                  label: Text(l10n.bangs_fieldSubCategoryLabel),
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: subCategory.value,
                  dropdownMenuEntries: [
                    ...?categories?[category.value]?.map(
                      (e) => DropdownMenuEntry(value: e, label: e),
                    ),
                  ],
                  onSelected: (value) {
                    if (subCategory.value != value) {
                      subCategory.value = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.bangs_flagsLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: formatFlags.value.contains(BangFormat.openBasePath),
                  title: Text(l10n.bangs_flagOpenBasePathTitle),
                  subtitle: Text(l10n.bangs_flagOpenBasePathSubtitle),
                  onChanged: (value) {
                    if (value != null) {
                      updateFormatFlag(BangFormat.openBasePath, value);
                    }
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: formatFlags.value.contains(
                    BangFormat.urlEncodePlaceholder,
                  ),
                  title: Text(l10n.bangs_flagUrlEncodePlaceholderTitle),
                  subtitle: Text(l10n.bangs_flagUrlEncodePlaceholderSubtitle),
                  onChanged: (value) {
                    if (value != null) {
                      updateFormatFlag(BangFormat.urlEncodePlaceholder, value);
                    }
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: formatFlags.value.contains(
                    BangFormat.urlEncodeSpaceToPlus,
                  ),
                  title: Text(l10n.bangs_flagUrlEncodeSpaceToPlusTitle),
                  subtitle: Text(l10n.bangs_flagUrlEncodeSpaceToPlusSubtitle),
                  onChanged: (value) {
                    if (value != null) {
                      updateFormatFlag(BangFormat.urlEncodeSpaceToPlus, value);
                    }
                  },
                ),
                if (editsExistingUserBang)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.error,
                        iconColor: Theme.of(context).colorScheme.error,
                      ),
                      label: Text(l10n.common_delete),
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final result = await showDeleteBangDialog(context);

                        if (result == true) {
                          await ref
                              .read(bangDataRepositoryProvider.notifier)
                              .deleteBang(
                                BangKey(
                                  group: BangGroup.user,
                                  trigger: initialBang!.trigger,
                                ),
                              );

                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
