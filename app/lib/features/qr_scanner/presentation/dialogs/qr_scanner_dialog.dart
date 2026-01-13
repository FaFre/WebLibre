import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class QrScannerDialog extends HookWidget {
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
