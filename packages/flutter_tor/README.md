# flutter_tor

A Flutter plugin for running Tor with pluggable transports on Android. This plugin provides a simple SOCKS5 proxy interface to the Tor network with support for multiple transport types and country-based node selection.

## Features

- **Multiple Transport Types**: Direct connection, obfs4, Snowflake, Meek, WebTunnel, and custom bridges
- **SOCKS5 Proxy**: Returns a random local port for SOCKS5 connections
- **Country Selection**: Configure entry and exit node countries
- **Background Service**: Keeps Tor running even when app is backgrounded
- **Log Streaming**: Real-time log messages from Tor
- **Bootstrap Progress**: Track connection progress (0-100%)
- **New Identity**: Request new Tor circuits on demand

## Supported Platforms

- ✅ Android
- ❌ iOS (not yet implemented)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_tor:
    path: ../flutter_tor  # Update path as needed
```

## Usage

### Basic Example

```dart
import 'package:flutter_tor/flutter_tor.dart';

final tor = FlutterTor();

// Start Tor with direct connection
final result = await tor.start(TorConfiguration(
  transport: TransportType.none,
  bridgeLines: [],
));

print('SOCKS proxy running on port ${result.socksPort}');
```

### With Snowflake Bridge

```dart
final result = await tor.start(TorConfiguration(
  transport: TransportType.snowflake,
  bridgeLines: [
    'snowflake 192.0.2.3:1 2B280B23E1107BB62ABFC40DDCC8824814F5...',
  ],
));
```

### With Country Selection

```dart
final result = await tor.start(TorConfiguration(
  transport: TransportType.obfs4,
  bridgeLines: ['obfs4 ...'],
  entryNodeCountries: 'de,fr,nl',  // Entry via Germany, France, or Netherlands
  exitNodeCountries: 'ch,is',      // Exit via Switzerland or Iceland
  strictNodes: false,               // Allow fallback if specified countries unavailable
));
```

### Listening to Logs

```dart
tor.logStream.listen((log) {
  print('[${log.severity}] ${log.message}');
});

tor.bootstrapProgressStream.listen((progress) {
  print('Bootstrap: $progress%');
});

tor.statusStream.listen((status) {
  print('Tor running: ${status.isRunning}');
  print('SOCKS port: ${status.socksPort}');
});
```

### Stop/Restart with Different Config

```dart
// Stop Tor
await tor.stop();

// Start again with different config
await tor.start(TorConfiguration(
  transport: TransportType.meek,
  bridgeLines: ['meek_lite ...'],
  exitNodeCountries: 'se,no',
));
```

### Request New Identity

```dart
// Get a new Tor circuit
await tor.requestNewIdentity();
```

## Transport Types

| Transport | Description |
|-----------|-------------|
| `none` | Direct Tor connection (no bridges) |
| `obfs4` | obfs4 pluggable transport |
| `snowflake` | Snowflake (default broker) |
| `snowflakeAmp` | Snowflake via AMP cache |
| `meek` | Meek pluggable transport |
| `meekAzure` | Meek via Azure CDN |
| `webtunnel` | WebTunnel pluggable transport |
| `custom` | Custom bridge lines (auto-detected) |

## Permissions

The plugin requires the following Android permissions (automatically added):

- `INTERNET` - Network access
- `ACCESS_NETWORK_STATE` - Network state detection
- `FOREGROUND_SERVICE` - Keep Tor running in background
- `FOREGROUND_SERVICE_SPECIAL_USE` - Android 14+ requirement
- `POST_NOTIFICATIONS` - Android 13+ for foreground service notification

## Architecture

This plugin is a simplified version of Orbot, extracting only the core Tor + Pluggable Transport functionality:

- **No VPN mode** - Only SOCKS5 proxy
- **No per-app routing** - Use the SOCKS proxy directly
- **Foreground Service** - Keeps Tor running with a notification
- **Pigeon Communication** - Type-safe Flutter ↔ Native communication

## Building from Source

### Prerequisites

1. Clone with submodules:
   ```bash
   git clone --recursive https://github.com/yourusername/orbot
   cd orbot/flutter_tor
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Pigeon code:
   ```bash
   flutter pub run pigeon --input pigeons/tor_api.dart
   ```

### Run Example

```bash
cd example
flutter run
```

## Dependencies

- **tor-android** (0.4.8.21.1) - Native Tor binaries
- **jtorctl** (0.4.5.7) - Tor control protocol
- **IPtProxy** (4.3.0) - Pluggable transports (obfs4, snowflake, meek, webtunnel)
- **Pigeon** (22.6.3) - Flutter ↔ Native communication

## Size Impact

- APK size increase: ~18-22MB (Tor binaries + IPtProxy for all ABIs)
- Supports: armeabi-v7a, arm64-v8a, x86, x86_64

## Limitations

- Android only (iOS not implemented)
- No VPN mode (SOCKS5 proxy only)
- No HTTP proxy (SOCKS5 only)
- GeoIP files may not be available (country selection optional)

## Troubleshooting

### Tor fails to start

- Check logStream for error messages
- Ensure bridge lines are valid for the selected transport
- Verify network connectivity
- Try with TransportType.none first

### Country selection not working

- GeoIP files must be available (check logs)
- Country codes must be ISO 3166-1 alpha-2 (e.g., "US", "DE")
- Use strictNodes: false to allow fallback

### App crashes on startup

- Ensure all submodules are initialized: `git submodule update --init --recursive`
- Check Android Studio build output for missing dependencies

## Contributing

This plugin is part of the Orbot project. See the main repository for contribution guidelines.

## License

Copyright © 2009-2025, Nathan Freitas, The Guardian Project

See LICENSE file for details.
