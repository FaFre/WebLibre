import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:socks5_proxy/socks_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tor Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TorDemoPage(),
    );
  }
}

class TorDemoPage extends StatefulWidget {
  const TorDemoPage({super.key});

  @override
  State<TorDemoPage> createState() => _TorDemoPageState();
}

class _TorDemoPageState extends State<TorDemoPage> {
  final _tor = FlutterTor();
  final _logs = <TorLogMessage>[];

  TransportType _selectedTransport = TransportType.none;
  int? _socksPort;
  int _bootstrapProgress = 0;
  bool _isRunning = false;
  String _entryCountries = '';
  String _exitCountries = '';
  bool _strictNodes = false;
  final _bridgeLinesController = TextEditingController();

  // IP test state
  String? _currentIp;
  bool _isTestingIp = false;

  @override
  void initState() {
    super.initState();

    // Listen to logs
    _tor.logStream.listen((log) {
      setState(() {
        _logs.add(log);
        if (_logs.length > 100) {
          _logs.removeAt(0);
        }
      });
    });

    // Listen to status changes
    _tor.statusStream.listen((status) {
      print(
        'DEBUG statusStream: isRunning=${status.isRunning}, socksPort=${status.socksPort}, bootstrap=${status.bootstrapProgress}',
      );
      setState(() {
        _isRunning = status.isRunning;
        final newPort = status.socksPort?.toInt();
        if (newPort != _socksPort) {
          print('DEBUG: Port changed from $_socksPort to $newPort');
        }
        _socksPort = newPort;
        _bootstrapProgress = status.bootstrapProgress.toInt();
      });
    });

    // Listen to bootstrap progress
    _tor.bootstrapProgressStream.listen((progress) {
      setState(() {
        _bootstrapProgress = progress;
      });
    });
  }

  Future<void> _startTor() async {
    try {
      final bridgeLines = _bridgeLinesController.text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      final config = TorConfiguration(
        transport: _selectedTransport,
        bridgeLines: bridgeLines,
        entryNodeCountries: _entryCountries.isEmpty ? null : _entryCountries,
        exitNodeCountries: _exitCountries.isEmpty ? null : _exitCountries,
        strictNodes: _strictNodes,
      );

      final socksPort = await _tor.start(config);
      print('DEBUG startTor result: socksPort=${socksPort}');
      setState(() {
        _socksPort = socksPort.toInt();
        print('DEBUG: Set _socksPort to $_socksPort from start result');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tor started on port ${socksPort}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start Tor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopTor() async {
    try {
      await _tor.stop();
      setState(() {
        _socksPort = null;
        _bootstrapProgress = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tor stopped')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop Tor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestNewIdentity() async {
    try {
      await _tor.requestNewIdentity();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Requested new Tor identity')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to request new identity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testIpAddress() async {
    if (_socksPort == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tor is not running. Start Tor first.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isTestingIp = true;
      _currentIp = null;
    });

    // Debug: Show which port we're using
    print('DEBUG: _testIpAddress called');
    print('DEBUG: Current _socksPort value: $_socksPort');
    print('DEBUG: Attempting to connect to SOCKS5 proxy on port $_socksPort');

    try {
      final portToUse = _socksPort!;
      print('DEBUG: About to connect via SOCKS5 proxy at 127.0.0.1:$portToUse');

      // Create HttpClient object
      final client = HttpClient();

      // Assign connection factory
      SocksTCPClient.assignToHttpClient(client, [
        ProxySettings(InternetAddress.loopbackIPv4, portToUse),
      ]);

      // Connect to ifconfig.me through the SOCKS5 proxy
      _currentIp = await client
          .getUrl(Uri.parse('https://icanhazip.com/'))
          .then((x) => x.close())
          .then((x) => utf8.decodeStream(x));

      print('DEBUG: Connected to ifconfig.me through SOCKS5 proxy');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your Tor IP: ${_currentIp}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error: $e');
      setState(() {
        _currentIp = 'Error: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch IP: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isTestingIp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Tor Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Status Card
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${_isRunning ? 'Running' : 'Stopped'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_socksPort != null) Text('SOCKS Port: $_socksPort'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _bootstrapProgress / 100),
                  Text('Bootstrap: $_bootstrapProgress%'),
                ],
              ),
            ),
          ),

          // Configuration
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<TransportType>(
                    value: _selectedTransport,
                    decoration: const InputDecoration(
                      labelText: 'Transport Type',
                    ),
                    items: TransportType.values.map((transport) {
                      return DropdownMenuItem(
                        value: transport,
                        child: Text(transport.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTransport = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bridgeLinesController,
                    decoration: const InputDecoration(
                      labelText: 'Bridge Lines (one per line)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Entry Countries (e.g., de,fr,nl)',
                    ),
                    onChanged: (value) => _entryCountries = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Exit Countries (e.g., ch,is,se)',
                    ),
                    onChanged: (value) => _exitCountries = value,
                  ),
                  CheckboxListTile(
                    title: const Text('Strict Nodes'),
                    value: _strictNodes,
                    onChanged: (value) {
                      setState(() {
                        _strictNodes = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRunning ? null : _startTor,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Tor'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRunning ? _stopTor : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Tor'),
                        ),
                      ),
                    ],
                  ),
                  if (_isRunning) ...[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _requestNewIdentity,
                      icon: const Icon(Icons.refresh),
                      label: const Text('New Identity'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isTestingIp ? null : _testIpAddress,
                      icon: _isTestingIp
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.public),
                      label: Text(
                        _isTestingIp ? 'Testing...' : 'Test IP Address',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_currentIp != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _currentIp!.startsWith('Error')
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _currentIp!.startsWith('Error')
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentIp!.startsWith('Error')
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              color: _currentIp!.startsWith('Error')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentIp!.startsWith('Error')
                                    ? _currentIp!
                                    : 'Your Tor IP: $_currentIp',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _currentIp!.startsWith('Error')
                                      ? Colors.red.shade900
                                      : Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  Text('Logs:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color color;
                        switch (log.severity) {
                          case 'ERR':
                            color = Colors.red;
                            break;
                          case 'WARN':
                            color = Colors.orange;
                            break;
                          case 'NOTICE':
                            color = Colors.blue;
                            break;
                          default:
                            color = Colors.black;
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            '[${log.severity}] ${log.message}',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
