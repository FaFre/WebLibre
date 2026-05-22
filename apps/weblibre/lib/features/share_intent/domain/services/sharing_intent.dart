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
import 'dart:async';

import 'package:mime/mime.dart' as mime;
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/account/domain/services/account_callback_handler.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/entities/intent_source_policy.dart';
import 'package:weblibre/features/intent_gatekeeper/domain/services/intent_gatekeeper.dart';
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'sharing_intent.g.dart';

const _alwaysAllowPackageExtra = 'eu.weblibre.gatekeeper.always_allow_package';

StreamTransformer<Intent, ReceivedIntentParameter>
_buildSharingIntentTransformer(
  IntentGatekeeper gatekeeper,
  GeneralSettingsRepository settingsRepository,
) => StreamTransformer<Intent, ReceivedIntentParameter>.fromHandlers(
  handleData: (intent, sink) async {
    if (_extractAccountCallback(intent) != null) {
      // Account callback intents are consumed by accountCallbackStreamProvider —
      // suppress them from the regular share/sharing intent pipeline so they
      // don't open a browser tab.
      return;
    }

    final alwaysAllowPackage =
        intent.extra[_alwaysAllowPackageExtra] as String?;
    if (alwaysAllowPackage != null) {
      await settingsRepository.updateSettings(
        (current) => current.copyWith.externalAppIntentPolicies({
          ...current.externalAppIntentPolicies,
          alwaysAllowPackage: IntentSourcePolicy.allow,
        }),
      );
    }

    final shortcutContextId = intent.action == 'android.intent.action.VIEW'
        ? intent.extra['pwa_context_id'] as String?
        : null;
    final containerMode = intent.action == 'android.intent.action.VIEW'
        ? IntentContainerMode.fromWireValue(
            intent.extra['shortcut_container_mode'] as String?,
            contextId: shortcutContextId,
          )
        : IntentContainerMode.useSelected;

    final allowed = await gatekeeper.shouldAllow(
      fromPackageName: intent.fromPackageName,
      url: intent.data,
    );
    if (!allowed) {
      logger.i(
        'Blocked intent from ${intent.fromPackageName ?? 'unknown app'}',
      );
      return;
    }

    final data = switch (intent.action) {
      'android.intent.action.PROCESS_TEXT' =>
        intent.extra['android.intent.extra.PROCESS_TEXT'] as String?,
      'android.intent.action.WEB_SEARCH' => intent.extra['query'] as String?,
      'android.intent.action.VIEW' => intent.data,
      'android.intent.action.SEND' =>
        intent.extra['android.intent.extra.STREAM'] as String? ??
            intent.extra['android.intent.extra.TEXT'] as String?,
      _ => null,
    };

    // Extract container context from shortcut intents.
    final contextId = shortcutContextId;

    if (data != null) {
      if (uri_to_file.isUriSupported(data)) {
        var path = data;
        if (p.extension(data).whenNotEmpty == null) {
          if (intent.mimeType.whenNotEmpty != null) {
            final ext = mime.extensionFromMime(intent.mimeType!);
            if (ext != null) {
              path = p.setExtension(path, '.$ext');
            } else {
              logger.w(
                'Could not determine file extension for: ${intent.mimeType}',
              );
            }
          } else {
            logger.w('Received intent without extension and mime type $path');
          }
        }

        try {
          final file = await uri_to_file.toFile(path);
          final mimeType = mime.lookupMimeType(file.path);
          switch (mimeType) {
            case 'application/pdf':
              sink.add(
                ReceivedIntentParameter(
                  path,
                  null,
                  contextId: contextId,
                  containerMode: containerMode,
                ),
              );
            default:
              logger.w('Unhandled mime type: $mimeType');
          }
        } catch (e) {
          logger.e('Failed to convert URI to file: $e');
          // Fallback: pass the original URI
          sink.add(
            ReceivedIntentParameter(
              data,
              null,
              contextId: contextId,
              containerMode: containerMode,
            ),
          );
        }
      } else {
        sink.add(
          ReceivedIntentParameter(
            data,
            null,
            contextId: contextId,
            containerMode: containerMode,
          ),
        );
      }
    }
  },
);

/// Shared intent receiver instance. Both the sharing intent stream
/// and the account callback handler listen to its broadcast events.
@Riverpod(keepAlive: true)
Raw<IntentReceiver> intentReceiver(Ref ref) {
  final receiver = IntentReceiver.setUp();
  ref.onDispose(receiver.dispose);
  return receiver;
}

/// Runs the receiver event stream through [transformer] and forwards it into a
/// fresh single-subscription controller wired up to [ref]'s lifecycle.
///
/// Centralising this in one helper means the two intent-consuming providers
/// below (sharing intents + account callbacks) agree on the receiver semantics:
/// `receiver.events` includes the recovered cold-start intent for each
/// listener, plus all live intents.
Raw<Stream<T>> _consumeIntents<T>(
  Ref ref,
  IntentReceiver receiver,
  StreamTransformer<Intent, T> transformer,
) {
  final controller = StreamController<T>();

  final sub = receiver.events
      .transform(transformer)
      .listen(controller.add, onError: controller.addError);

  ref.onDispose(() {
    unawaited(sub.cancel());
    unawaited(controller.close());
  });

  return controller.stream;
}

@Riverpod(keepAlive: true)
Raw<Stream<ReceivedIntentParameter>> sharingIntentStream(Ref ref) {
  final receiver = ref.watch(intentReceiverProvider);
  final gatekeeper = ref.watch(intentGatekeeperProvider.notifier);
  final settingsRepository = ref.watch(
    generalSettingsRepositoryProvider.notifier,
  );
  return _consumeIntents(
    ref,
    receiver,
    _buildSharingIntentTransformer(gatekeeper, settingsRepository),
  );
}

/// Stream of account callback handoff codes extracted from deep link intents.
@Riverpod(keepAlive: true)
Raw<Stream<String>> accountCallbackStream(Ref ref) {
  final receiver = ref.watch(intentReceiverProvider);
  return _consumeIntents(ref, receiver, _accountCallbackTransformer);
}

/// Transformer that yields handoff codes for matching VIEW intents and
/// drops everything else. Shared with the sharing-intent suppression
/// branch via [_extractAccountCallback] so the two streams agree on which
/// intents are "account callbacks".
final _accountCallbackTransformer =
    StreamTransformer<Intent, String>.fromHandlers(
      handleData: (intent, sink) {
        final callback = _extractAccountCallback(intent);
        if (callback != null) {
          sink.add(callback.handoffCode);
        }
      },
    );

AccountCallback? _extractAccountCallback(Intent intent) {
  if (intent.action != 'android.intent.action.VIEW' || intent.data == null) {
    return null;
  }
  return tryParseAccountCallback(intent.data!);
}
