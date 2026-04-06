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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class QrScannerDialog extends HookWidget {
  const QrScannerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final qrKey = useMemoized(() => GlobalKey(debugLabel: 'qr_scanner'));
    final qrController = useState<QRViewController?>(null);

    final flashState = useState(false);

    useEffect(() {
      StreamSubscription<Barcode>? sub;

      if (qrController.value != null) {
        sub = qrController.value!.scannedDataStream.listen((event) {
          if (context.mounted) {
            Navigator.pop(context, event);
          }
        });
      }

      return () {
        unawaited(sub?.cancel());
      };
    }, [qrController.value]);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan code'),
          actions: [
            IconButton(
              isSelected: flashState.value,
              onPressed: () async {
                if (qrController.value != null) {
                  await qrController.value!.toggleFlash();

                  flashState.value =
                      await qrController.value!.getFlashStatus() ?? false;
                }
              },
              icon: const Icon(Icons.flash_on),
              selectedIcon: const Icon(Icons.flash_off),
            ),
            IconButton(
              onPressed: () async {
                await qrController.value?.flipCamera();
              },
              icon: const Icon(Icons.cameraswitch),
            ),
          ],
        ),
        body: SafeArea(
          child: QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              qrController.value = controller;
            },
            onPermissionSet: (controller, result) {
              if (!result) {
                ui_helper.showErrorMessage(
                  context,
                  'No Camera Permission granted',
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
