import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';

class TorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(TorIcons.onionAlt, color: Color(0xFF7D4698)),
      title: const Text('Tor Proxy'),
      content: const Text(
        'This container requires a Tor proxy for secure connections, which is not currently running.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text('Enable'),
        ),
      ],
    );
  }
}
