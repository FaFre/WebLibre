import 'package:flutter/material.dart';

class ShareTile extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onTapQr;

  const ShareTile({super.key, this.onTap, this.onTapQr});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('Share link'),
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VerticalDivider(indent: 4, endIndent: 4),
          IconButton(icon: const Icon(Icons.qr_code), onPressed: onTapQr),
        ],
      ),
    );
  }
}
