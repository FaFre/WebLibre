import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/color_picker_dialog.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';

enum _DialogMode { create, edit }

const _timeoutOptions = <DropdownMenuItem<Duration?>>[
  DropdownMenuItem(child: Text('Immediately')),
  DropdownMenuItem(value: Duration(minutes: 1), child: Text('1 minute')),
  DropdownMenuItem(value: Duration(minutes: 5), child: Text('5 minutes')),
  DropdownMenuItem(value: Duration(minutes: 15), child: Text('15 minutes')),
  DropdownMenuItem(value: Duration(hours: 1), child: Text('1 hour')),
];

class ContainerEditScreen extends HookConsumerWidget {
  final _DialogMode _mode;

  final ContainerData initialContainer;

  const ContainerEditScreen._({
    required _DialogMode mode,
    required this.initialContainer,
  }) : _mode = mode;

  factory ContainerEditScreen.create({
    required ContainerData initialContainer,
  }) {
    return ContainerEditScreen._(
      mode: _DialogMode.create,
      initialContainer: initialContainer,
    );
  }

  factory ContainerEditScreen.edit({required ContainerData initialContainer}) {
    return ContainerEditScreen._(
      mode: _DialogMode.edit,
      initialContainer: initialContainer,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = useState(initialContainer.color);
    final contextualIdentity = useState(
      initialContainer.metadata.contextualIdentity,
    );
    final authSettings = useState(initialContainer.metadata.authSettings);
    final useProxy = useState(initialContainer.metadata.useProxy);

    final textController = useTextEditingController(
      text: initialContainer.name,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_mode) {
          _DialogMode.create => 'New Container',
          _DialogMode.edit => 'Edit Container',
        }),
        actions: [
          IconButton(
            onPressed: () async {
              final name = textController.text.trim();
              final container = initialContainer.copyWith(
                name: name.isNotEmpty ? name : null,
                color: selectedColor.value,
                metadata: initialContainer.metadata.copyWith(
                  contextualIdentity: contextualIdentity.value,
                  authSettings: authSettings.value,
                  useProxy: useProxy.value && contextualIdentity.value != null,
                ),
              );

              //Check for permissions, when auth is set or getting set
              if (initialContainer
                      .metadata
                      .authSettings
                      .authenticationRequired ||
                  container.metadata.authSettings.authenticationRequired) {
                final authResult = await ref
                    .read(localAuthenticationServiceProvider.notifier)
                    .authenticate(
                      authKey: 'container_access::${container.id}',
                      localizedReason:
                          'Require authentication for container ${container.name ?? 'New Container'}',
                    );

                if (!authResult) {
                  return;
                }
              }

              switch (_mode) {
                case _DialogMode.create:
                  await ref
                      .read(containerRepositoryProvider.notifier)
                      .addContainer(container);
                case _DialogMode.edit:
                  await ref
                      .read(containerRepositoryProvider.notifier)
                      .replaceContainer(container);
              }

              if (context.mounted) {
                context.pop();
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedColor.value,
                            ),
                          ),
                        ),
                        label: const Text('Name'),
                      ),
                      controller: textController,
                    ),
                    TextButton.icon(
                      label: const Text('Select Color'),
                      icon: const Icon(Icons.colorize),
                      onPressed: () async {
                        final color = await showDialog<Color?>(
                          context: context,
                          builder: (context) =>
                              ColorPickerDialog(selectedColor.value),
                        );

                        if (color != null) {
                          selectedColor.value = color;
                        }
                      },
                    ),
                    SwitchListTile.adaptive(
                      value: contextualIdentity.value != null,
                      title: const Text('Cookie Isolation'),
                      secondary: const Icon(MdiIcons.cookieLock),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (_mode == _DialogMode.create)
                          ? (value) {
                              contextualIdentity.value = value
                                  ? initialContainer
                                            .metadata
                                            .contextualIdentity ??
                                        uuid.v4()
                                  : null;

                              if (!value && useProxy.value) {
                                useProxy.value = false;
                              }
                            }
                          : null,
                    ),
                    SwitchListTile.adaptive(
                      value: useProxy.value,
                      title: const Text('Use Tor Proxy'),
                      secondary: const Icon(TorIcons.onionAlt),
                      contentPadding: EdgeInsets.zero,
                      onChanged: switch (_mode) {
                        _DialogMode.create => (value) {
                          if (value && contextualIdentity.value == null) {
                            contextualIdentity.value =
                                initialContainer.metadata.contextualIdentity ??
                                uuid.v4();
                          }

                          useProxy.value = value;
                        },
                        _DialogMode.edit =>
                          (contextualIdentity.value != null)
                              ? (value) {
                                  useProxy.value = value;
                                }
                              : null,
                      },
                    ),
                    SwitchListTile.adaptive(
                      value: authSettings.value.authenticationRequired,
                      title: const Text('Require Authentication'),
                      secondary: const Icon(MdiIcons.fingerprint),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        authSettings.value = authSettings.value.copyWith
                            .authenticationRequired(value);
                      },
                    ),
                    if (authSettings.value.authenticationRequired)
                      CheckboxListTile.adaptive(
                        value: authSettings.value.lockOnAppBackground,
                        title: const Text('Auto-lock on background'),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          authSettings.value = authSettings.value.copyWith
                              .lockOnAppBackground(value!);
                        },
                      ),
                    if (authSettings.value.authenticationRequired)
                      CheckboxListTile.adaptive(
                        value: authSettings.value.lockTimeout != null,
                        title: const Text('Timeout'),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          final newValue = value!
                              ? _timeoutOptions[1].value
                              : null;

                          authSettings.value = authSettings.value.copyWith
                              .lockTimeout(newValue);
                        },
                        secondary: DropdownButton(
                          value: authSettings.value.lockTimeout,
                          items: _timeoutOptions,
                          onChanged: (value) {
                            authSettings.value = authSettings.value.copyWith
                                .lockTimeout(value);
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (_mode == _DialogMode.edit)
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
                            title: const Text('Delete Container'),
                            content: const Text(
                              'Are you sure you want to delete this container and close all attached tabs?',
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
                            .read(containerRepositoryProvider.notifier)
                            .deleteContainer(initialContainer.id);

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
    );
  }
}
