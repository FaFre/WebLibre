// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: MIT

// Flutter dependencies not necessarily needed for tor usage:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// Example application dependencies you can replace with any that works for you:
import 'package:socks5_proxy/socks_client.dart';
import 'package:tor/socks_socket.dart';
// The only real import needed for basic usage:
import 'package:tor/tor.dart'; // This would go at the top, but dart autoformatter doesn't like it there.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyAppState();
}

class _MyAppState extends State<Home> {
  // Flag to track if tor has started.
  bool torStarted = false;

  // Set the default text for the host input field.
  final hostController = TextEditingController(text: 'https://icanhazip.com/');
  // https://check.torproject.org is another good option.

  // Set the default text for the onion input field.
  final onionController = TextEditingController(
      text:
          'https://cflarexljc3rw355ysrkrzwapozws6nre6xsy3n4yrj7taye3uiby3ad.onion');
  // See https://blog.cloudflare.com/cloudflare-onion-service/ for more options:
  // cflarexljc3rw355ysrkrzwapozws6nre6xsy3n4yrj7taye3uiby3ad.onion
  // cflarenuttlfuyn7imozr4atzvfbiw3ezgbdjdldmdx7srterayaozid.onion
  // cflares35lvdlczhy3r6qbza5jjxbcplzvdveabhf7bsp7y4nzmn67yd.onion
  // cflareusni3s7vwhq2f7gc4opsik7aa4t2ajedhzr42ez6uajaywh3qd.onion
  // cflareki4v3lh674hq55k3n7xd4ibkwx3pnw67rr3gkpsonjmxbktxyd.onion
  // cflarejlah424meosswvaeqzb54rtdetr4xva6mq2bm2hfcx5isaglid.onion
  // cflaresuje2rb7w2u3w43pn4luxdi6o7oatv6r2zrfb5xvsugj35d2qd.onion
  // cflareer7qekzp3zeyqvcfktxfrmncse4ilc7trbf6bp6yzdabxuload.onion
  // cflareub6dtu7nvs3kqmoigcjdwap2azrkx5zohb2yk7gqjkwoyotwqd.onion
  // cflare2nge4h4yqr3574crrd7k66lil3torzbisz6uciyuzqc2h2ykyd.onion

  final bitcoinOnionController = TextEditingController(
      text:
          'qly7g5n5t3f3h23xvbp44vs6vpmayurno4basuu5rcvrupli7y2jmgid.onion:50001');
  // For more options, see https://bitnodes.io/nodes/addresses/?q=onion and
  // https://sethforprivacy.com/about/

  final moneroOnionController = TextEditingController(
      text:
          'ucdouiihzwvb5edg3ezeufcs4yp26gq4x64n6b4kuffb7s7jxynnk7qd.onion:18081/json_rpc');

  Future<void> startTor() async {
    await Tor.init();

    // Start the proxy
    await Tor.instance.start();

    // Toggle started flag.
    setState(() {
      torStarted = Tor.instance.started; // Update flag
    });

    print('Done awaiting; tor should be running');
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spacerSmall = SizedBox(height: 10);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tor example'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: torStarted
                        ? null
                        : () async {
                            unawaited(
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => const Dialog(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text("Starting tor..."),
                                  ),
                                ),
                              ),
                            );

                            final time = DateTime.now();

                            print("NOW: $time");

                            await startTor();

                            print("Starting tor took "
                                "${DateTime.now().difference(time).inSeconds} "
                                "seconds. Proxy running on port ${Tor.instance.port}");

                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    child: const Text("Start"),
                  ),
                  TextButton(
                    onPressed: !torStarted
                        ? null
                        : () async {
                            Tor.instance.stop();
                            setState(() {
                              torStarted = false; // Update flag
                            });
                          },
                    child: const Text("Stop"),
                  ),
                ],
              ),
              Row(
                children: [
                  // Host input field.
                  Expanded(
                    child: TextField(
                      controller: hostController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Host to request',
                      ),
                    ),
                  ),
                  spacerSmall,
                  TextButton(
                    onPressed: torStarted
                        ? () async {
                            // `socks5_proxy` package example, use another socks5
                            // connection of your choice.

                            // Create HttpClient object
                            final client = HttpClient();

                            // Assign connection factory.
                            SocksTCPClient.assignToHttpClient(client, [
                              ProxySettings(InternetAddress.loopbackIPv4,
                                  Tor.instance.port,
                                  password:
                                      null), // TODO Need to get from tor config file.
                            ]);

                            // GET request.
                            final url = Uri.parse(hostController.text);
                            final request = await client.getUrl(url);
                            final response = await request.close();

                            // Print response.
                            var responseString =
                                await utf8.decodeStream(response);
                            print(responseString);
                            // If host input left to default icanhazip.com, a Tor
                            // exit node IP should be printed to the console.
                            //
                            // https://check.torproject.org is also good for
                            // doublechecking torability.

                            // Close client
                            client.close();
                          }
                        : null,
                    child: const Text("Make proxied request"),
                  ),
                ],
              ),
              spacerSmall,
              TextButton(
                onPressed: torStarted
                    ? () async {
                        // Instantiate a socks socket at localhost and on the port selected by the tor service.
                        var socksSocket = await SOCKSSocket.create(
                          proxyHost: InternetAddress.loopbackIPv4.address,
                          proxyPort: Tor.instance.port,
                          sslEnabled: true, // For SSL connections.
                        );

                        // Connect to the socks instantiated above.
                        await socksSocket.connect();

                        // Connect to bitcoin.stackwallet.com on port 50002 via socks socket.
                        //
                        // Note that this is an SSL example.
                        await socksSocket.connectTo(
                            'bitcoin.stackwallet.com', 50002);

                        // Send a server features command to the connected socket, see method for more specific usage example..
                        await socksSocket.sendServerFeaturesCommand();

                        // You should see a server response printed to the console.
                        //
                        // Example response:
                        // `flutter: secure responseData: {
                        // 	"id": "0",
                        // 	"jsonrpc": "2.0",
                        // 	"result": {
                        // 		"cashtokens": true,
                        // 		"dsproof": true,
                        // 		"genesis_hash": "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
                        // 		"hash_function": "sha256",
                        // 		"hosts": {
                        // 			"bitcoin.stackwallet.com": {
                        // 				"ssl_port": 50002,
                        // 				"tcp_port": 50001,
                        // 				"ws_port": 50003,
                        // 				"wss_port": 50004
                        // 			}
                        // 		},
                        // 		"protocol_max": "1.5",
                        // 		"protocol_min": "1.4",
                        // 		"pruning": null,
                        // 		"server_version": "Fulcrum 1.9.1"
                        // 	}
                        // }

                        // Close the socket.
                        await socksSocket.close();
                      }
                    : null,
                child: const Text(
                  "Connect to bitcoin.stackwallet.com:50002 (SSL) via socks socket",
                ),
              ),
              spacerSmall,
              Row(
                children: [
                  // Bitcoin onion input field.
                  Expanded(
                    child: TextField(
                      controller: bitcoinOnionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Bitcoin onion address to test',
                      ),
                    ),
                  ),
                  spacerSmall,
                  TextButton(
                    onPressed: torStarted
                        ? () async {
                            // Validate the onion address.
                            if (!onionController.text.contains(".onion")) {
                              print("Invalid onion address");
                              return;
                            } else if (!onionController.text.contains(":")) {
                              print("Invalid onion address (needs port)");
                              return;
                            }

                            String domain =
                                bitcoinOnionController.text.split(":").first;
                            int port = int.parse(
                                bitcoinOnionController.text.split(":").last);

                            // Instantiate a socks socket at localhost and on the port selected by the tor service.
                            var socksSocket = await SOCKSSocket.create(
                              proxyHost: InternetAddress.loopbackIPv4.address,
                              proxyPort: Tor.instance.port,
                              sslEnabled: !domain
                                  .endsWith(".onion"), // For SSL connections.
                            );

                            // Connect to the socks instantiated above.
                            await socksSocket.connect();

                            // Connect to onion node via socks socket.
                            //
                            // Note that this is an SSL example.
                            await socksSocket.connectTo(domain, port);

                            // Send a server features command to the connected socket, see method for more specific usage example..
                            await socksSocket.sendServerFeaturesCommand();

                            // You should see a server response printed to the console.
                            //
                            // Example response:
                            // `flutter: secure responseData: {
                            // 	"id": "0",
                            // 	"jsonrpc": "2.0",
                            // 	"result": {
                            // 		"cashtokens": true,
                            // 		"dsproof": true,
                            // 		"genesis_hash": "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
                            // 		"hash_function": "sha256",
                            // 		"hosts": {
                            // 			"bitcoin.stackwallet.com": {
                            // 				"ssl_port": 50002,
                            // 				"tcp_port": 50001,
                            // 				"ws_port": 50003,
                            // 				"wss_port": 50004
                            // 			}
                            // 		},
                            // 		"protocol_max": "1.5",
                            // 		"protocol_min": "1.4",
                            // 		"pruning": null,
                            // 		"server_version": "Fulcrum 1.9.1"
                            // 	}
                            // }

                            // Close the socket.
                            await socksSocket.close();
                          }

                        // A mutex should be added to this example to prevent
                        // multiple connections from being made at once.  TODO
                        : null,
                    child: const Text(
                      "Test Bitcoin onion node connection",
                    ),
                  ),
                ],
              ),
              spacerSmall,
              Row(
                children: [
                  // Monero onion input field.
                  Expanded(
                    child: TextField(
                      controller: moneroOnionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Monero onion address to test',
                      ),
                    ),
                  ),
                  spacerSmall,
                  TextButton(
                    onPressed: torStarted
                        ? () async {
                            // Validate the onion address.
                            if (!moneroOnionController.text
                                .contains(".onion")) {
                              print("Invalid onion address");
                              return;
                            } else if (!moneroOnionController.text
                                .contains(":")) {
                              print("Invalid onion address (needs port)");
                              return;
                            }

                            final String host =
                                moneroOnionController.text.split(":").first;
                            final int port = int.parse(moneroOnionController
                                .text
                                .split(":")
                                .last
                                .split("/")
                                .first);
                            final String path = moneroOnionController.text
                                .split(":")
                                .last
                                .split("/")
                                .last; // Extract the path

                            var socksSocket = await SOCKSSocket.create(
                              proxyHost: InternetAddress.loopbackIPv4.address,
                              proxyPort: Tor.instance.port,
                              sslEnabled: false,
                            );

                            await socksSocket.connect();
                            await socksSocket.connectTo(host, port);

                            final body = jsonEncode({
                              "jsonrpc": "2.0",
                              "id": "0",
                              "method": "get_info",
                            });

                            final request = 'POST /$path HTTP/1.1\r\n'
                                'Host: $host\r\n'
                                'Content-Type: application/json\r\n'
                                'Content-Length: ${body.length}\r\n'
                                '\r\n'
                                '$body';

                            socksSocket.write(request);
                            print("Request sent: $request");

                            await for (var response
                                in socksSocket.inputStream) {
                              final result = utf8.decode(response);
                              print("Response received: $result");
                              break;
                            }

                            // You should see a server response printed to the console.
                            //
                            // Example response:
                            // Host: ucdouiihzwvb5edg3ezeufcs4yp26gq4x64n6b4kuffb7s7jxynnk7qd.onion
                            // Content-Type: application/json
                            // Content-Length: 46
                            //
                            // {"jsonrpc":"2.0","id":"0","method":"get_info"}
                            // flutter: Response received: HTTP/1.1 200 Ok
                            // Server: Epee-based
                            // Content-Length: 1434
                            // Content-Type: application/json
                            // Last-Modified: Thu, 03 Oct 2024 23:08:19 GMT
                            // Accept-Ranges: bytes
                            //
                            // {
                            // "id": "0",
                            // "jsonrpc": "2.0",
                            // "result": {
                            // "adjusted_time": 1727996959,
                            // ...

                            await socksSocket.close();
                          }

                        // A mutex should be added to this example to prevent
                        // multiple connections from being made at once.  TODO
                        : null,
                    child: const Text(
                      "Test Monero onion node connection",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
