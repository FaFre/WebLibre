/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class EditBangScreen extends HookConsumerWidget {
  final Bang? initialBang;

  const EditBangScreen({super.key, required this.initialBang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
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

    final category = useState(initialBang?.category);
    final subCategory = useState(initialBang?.subCategory);
    final formatFlags = useState(initialBang?.format);

    return Scaffold(
      appBar: AppBar(
        title: Text(initialBang == null ? 'New Bang' : 'Edit Bang'),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final existingBang = await ref
                    .read(bangDataRepositoryProvider.notifier)
                    .getBang(
                      BangKey(
                        group: BangGroup.user,
                        trigger: triggerTextController.text,
                      ),
                    );

                if ((initialBang == null && existingBang != null) ||
                    (initialBang != null &&
                        existingBang != null &&
                        existingBang.trigger != initialBang!.trigger)) {
                  if (context.mounted) {
                    ui_helper.showErrorMessage(
                      context,
                      'A Bang with Trigger "${triggerTextController.text}" does already exist',
                    );
                  }

                  return;
                }

                final uri = Uri.parse(urlTextController.text);

                final bang = Bang(
                  group: BangGroup.user,
                  trigger: triggerTextController.text,
                  websiteName: nameTextController.text,
                  domain: uri.host,
                  urlTemplate: urlTextController.text,
                  searxngApi: false,
                  category: category.value,
                  subCategory: subCategory.value,
                  additionalTriggers: initialBang?.additionalTriggers,
                  format: formatFlags.value.isNotEmpty
                      ? formatFlags.value
                      : null,
                );

                if (initialBang != null &&
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
                  decoration: const InputDecoration(
                    label: Text('Name'),
                    helper: Text(
                      'The name of the website associated with the bang',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: triggerTextController,
                  decoration: const InputDecoration(
                    label: Text('Trigger'),
                    helper: Text(
                      'The specific trigger word or phrase used to invoke the bang.',
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlTextController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    label: Text('URL'),
                    helper: Text(
                      "The URL template to use when the bang is invoked, where `{{{s}}}` is replaced by the user's query.",
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (value?.contains('{{{s}}}') != true) {
                      return 'Must contain the query placeholder {{{s}}}';
                    }

                    return validateUrl(
                      value,
                      eagerParsing: false,
                      onlyHttpProtocol: true,
                    );
                  },
                ),
                const SizedBox(height: 24),
                DropdownMenuFormField(
                  key: ValueKey(EquatableValue([category.value, categories])),
                  enableFilter: true,
                  requestFocusOnTap: true,
                  label: const Text('Category'),
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
                  label: const Text('Sub Category'),
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
                Text('Flags', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 4),
                CheckboxListTile(
                  value:
                      formatFlags.value?.contains(BangFormat.openBasePath) ??
                      false,
                  title: const Text('Open Base Path'),
                  subtitle: const Text(
                    'When the bang is invoked with no query, opens the base path of the URL (/) instead of any path given in the template (g., /search)',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      formatFlags.value =
                          value
                                ? {
                                    ...?formatFlags.value,
                                    BangFormat.openBasePath,
                                  }
                                : {...?formatFlags.value}
                            ..remove(BangFormat.openBasePath);
                    }
                  },
                ),
                CheckboxListTile(
                  value:
                      formatFlags.value?.contains(
                        BangFormat.urlEncodePlaceholder,
                      ) ??
                      false,
                  title: const Text('URL Encode Placeholder'),
                  subtitle: const Text(
                    'URL encode the search terms. Some sites do not work with this, so it can be disabled by omitting this.',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      formatFlags.value =
                          value
                                ? {
                                    ...?formatFlags.value,
                                    BangFormat.urlEncodePlaceholder,
                                  }
                                : {...?formatFlags.value}
                            ..remove(BangFormat.urlEncodePlaceholder);
                    }
                  },
                ),
                CheckboxListTile(
                  value:
                      formatFlags.value?.contains(
                        BangFormat.urlEncodeSpaceToPlus,
                      ) ??
                      false,
                  title: const Text('URL Encode Space to Plus'),
                  subtitle: const Text(
                    'URL encodes spaces as +, instead of %20. Some sites only work correctly with one or the other.',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      formatFlags.value =
                          value
                                ? {
                                    ...?formatFlags.value,
                                    BangFormat.urlEncodeSpaceToPlus,
                                  }
                                : {...?formatFlags.value}
                            ..remove(BangFormat.urlEncodeSpaceToPlus);
                    }
                  },
                ),
                if (initialBang != null)
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
                      label: const Text('Delete'),
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final result = await showDialog<bool?>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              icon: const Icon(Icons.warning),
                              title: const Text('Delete Bang'),
                              content: const Text(
                                'Are you sure you want to delete this Bang?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

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
