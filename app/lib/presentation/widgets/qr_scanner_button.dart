import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:weblibre/features/qr_scanner/presentation/dialogs/qr_scanner_dialog.dart';

class QrScannerButton extends HookConsumerWidget {
  final void Function(Barcode? scanResult) onScanResult;

  const QrScannerButton({required this.onScanResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        final result = await showDialog<Barcode>(
          context: context,
          builder: (context) {
            return QrScannerDialog();
          },
        );

        onScanResult(result);
      },
      icon: const Icon(MdiIcons.barcodeScan),
    );
  }
}
