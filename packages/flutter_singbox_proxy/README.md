# flutter_singbox_proxy

Android sing-box proxy runtime plugin for WebLibre.

The public API is Pigeon-based and intentionally uses a generic JSON profile
boundary. Flutter can add strongly typed editors over time while the native API
stays stable across sing-box protocol/schema updates.

Current state:

- Builds sing-box JSON for multiple simultaneous profile outbounds.
- Creates one authenticated local SOCKS inbound per active profile.
- Returns runtime endpoint metadata for Gecko container proxy integration.
- Exposes status/log callbacks.
- Starts libbox via reflection against the `io.nekohasekai.libbox.*` classes
  shipped in the combined WebLibre gomobile AAR.

## Building the Android gomobile runtime

The app uses one combined gomobile AAR for sing-box `libbox` and IPtProxy,
because multiple gomobile AARs in one Android app collide on generated runtime
symbols. Build it from the repository root before release/F-Droid builds:

```sh
melos run build-go-runtime --no-select
```

By default the script looks for sibling `../sing-box` and `../IPtProxy`
checkouts relative to this repository. It writes
`native/go_mobile_runtime/build/weblibre-go.aar`; Gradle requires that AAR
before compiling this plugin.

For F-Droid metadata, call the package-local prebuild script:

```sh
packages/flutter_singbox_proxy/scripts/fdroid-prebuild.sh \
  --source /path/to/sing-box
```

The build requires OpenJDK 17, Go, Android SDK/NDK, and gomobile/gobind. If
`JAVA_HOME` is unset and `/usr/lib/jvm/java-17-openjdk` exists, the script uses
that automatically. If gomobile/gobind are missing, the script installs the
official SagerNet gomobile tools with `go install`.

### Version compatibility

The combined runtime pins sing-box, IPtProxy, dnstt, and gomobile in
`native/go_mobile_runtime/pins.env`. The runtime accesses
`io.nekohasekai.libbox.*` via reflection, so API drift across sing-box releases
surfaces as a `NoSuchMethodException` at start time rather than a build failure.
When bumping sing-box:

1. Update `native/go_mobile_runtime/pins.env`.
2. Rebuild the AAR with the new tag.
3. Smoke-test `start`/`stop` on a profile to catch missing/renamed setup
   methods (notably `SetupOptions.setOomKillerDisabled` /
   `setOomKillerEnabled` - `LibboxRuntime` falls back between the two).
4. Update this README with the verified sing-box tag if relying on it for a
   release.
