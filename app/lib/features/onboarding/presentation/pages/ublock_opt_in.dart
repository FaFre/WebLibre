import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/features/onboarding/presentation/pages/abstract/i_form_page.dart';

class UBlockOptInPage extends HookConsumerWidget implements IFormPage {
  @override
  final GlobalKey<FormState> formKey;

  const UBlockOptInPage({super.key, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: ListView(
        children: [
          const SizedBox(height: 24),
          SvgPicture.asset('assets/images/ublock.svg'),
          const SizedBox(height: 8),
          Center(
            child: Text('uBlock Origin', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: MarkdownBody(
              data: '''
uBlock Origin (uBO) is a CPU and memory-efficient **wide-spectrum content blocker** by **Raymond Hill** and available as a browser extensions for WebLibre.

It blocks ads, trackers, coin miners, popups, annoying anti-blockers, malware sites, etc., by default using **EasyList, EasyPrivacy, Peter Lowe's Blocklist, Online Malicious URL Blocklist, and uBO filter lists**. 

There are many other lists available to block even more.
                ''',
            ),
          ),
          const SizedBox(height: 24),
          FormField(
            initialValue: false,
            onSaved: (newValue) {
              if (newValue == true) {
                unawaited(
                  ref
                      .read(browserAddonServiceProvider.notifier)
                      .install('uBlock0@raymondhill.net'),
                );
              }
            },
            builder: (field) => SwitchListTile(
              value: field.value ?? false,
              title: const Text('Install uBlock Origin Extension'),
              onChanged: (value) {
                field.didChange(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
