import 'package:flutter/material.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final proxy = FlutterSingboxProxy();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: FutureBuilder<SingboxProxyRuntimeState>(
          future: proxy.getState(),
          builder: (context, snapshot) {
            final status = snapshot.data?.status.name ?? 'unknown';
            return Center(child: Text('sing-box proxy status: $status'));
          },
        ),
      ),
    );
  }
}
