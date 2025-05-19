import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/presentation/controllers/controllers.dart';

enum _AuthType { login, signup }

class UserAuthScreen extends HookConsumerWidget {
  const UserAuthScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final authType = useState(_AuthType.login);

    final userTextController = useTextEditingController();
    final passwordTextController = useTextEditingController();
    final confirmPasswordTextController = useTextEditingController();

    final authState = ref.watch(authControllerProvider);

    ref.listen(authStateProvider.select((value) => value.valueOrNull), (
      previous,
      next,
    ) {
      if (next?.token.isNotEmpty ?? false) {
        context.pop(true);
      }
    });

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: userTextController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                  icon: Icon(Icons.account_circle),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email must be provided';
                  }

                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8.0),
              HookBuilder(
                builder: (context) {
                  final obscure = useState(true);

                  return Column(
                    children: [
                      TextFormField(
                        controller: passwordTextController,
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          icon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              obscure.value = !obscure.value;
                            },
                            icon: Icon(
                              obscure.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        obscureText: obscure.value,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Password must be provided';
                          }

                          return null;
                        },
                      ),
                      if (authType.value == _AuthType.signup)
                        TextFormField(
                          controller: confirmPasswordTextController,
                          decoration: InputDecoration(
                            label: const Text('Confirm Password'),
                            icon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                obscure.value = !obscure.value;
                              },
                              icon: Icon(
                                obscure.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          obscureText: obscure.value,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Password must be provided';
                            }

                            if (value != passwordTextController.text) {
                              return 'Password not matching';
                            }

                            return null;
                          },
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              if (authState.hasError && !authState.isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    authState.error.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (!authState.isLoading)
                switch (authType.value) {
                  _AuthType.login => FilledButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final controller = ref.read(
                          authControllerProvider.notifier,
                        );

                        await controller.authWithPassword(
                          userTextController.text,
                          passwordTextController.text,
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                  _AuthType.signup => FilledButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final controller = ref.read(
                          authControllerProvider.notifier,
                        );

                        await controller.registerWithPassword(
                          userTextController.text,
                          passwordTextController.text,
                        );
                      }
                    },
                    child: const Text('Signup'),
                  ),
                }
              else
                const CircularProgressIndicator(),
              if (!authState.isLoading)
                switch (authType.value) {
                  _AuthType.login => TextButton(
                    onPressed: () {
                      final controller = ref.read(
                        authControllerProvider.notifier,
                      );

                      controller.clearState();
                      authType.value = _AuthType.signup;
                    },
                    child: const Text('Signup'),
                  ),
                  _AuthType.signup => TextButton(
                    onPressed: () {
                      final controller = ref.read(
                        authControllerProvider.notifier,
                      );

                      controller.clearState();
                      authType.value = _AuthType.login;
                    },
                    child: const Text('Login'),
                  ),
                },
            ],
          ),
        ),
      ),
    );
  }
}
