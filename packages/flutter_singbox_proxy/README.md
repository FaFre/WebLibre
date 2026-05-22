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
  shipped in the AAR — if the AAR is missing, the plugin still compiles but
  `start` reports an `IllegalStateException` at runtime.

## Building official sing-box libbox

The plugin does not commit binary AARs. Build them from the official sing-box
checkout before release/F-Droid builds:

```sh
packages/flutter_singbox_proxy/scripts/build-libbox-android.sh \
  --source /path/to/sing-box
```

By default the script looks for `../../../sing-box` relative to this package,
which matches the local workspace layout used during development. It copies
`libbox.aar` into `android/libs/`; Gradle consumes that AAR automatically when
present.

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

The script pins `github.com/sagernet/gomobile/cmd/gomobile@v0.1.12` and
`gobind@v0.1.12`. The sing-box source itself is whatever you point `--source`
at; the runtime accesses `io.nekohasekai.libbox.*` via reflection, so API drift
across sing-box releases surfaces as a `NoSuchMethodException` at start time
rather than a build failure. When bumping sing-box:

1. Rebuild the AAR with the new tag.
2. Smoke-test `start`/`stop` on a profile to catch missing/renamed setup
   methods (notably `SetupOptions.setOomKillerDisabled` /
   `setOomKillerEnabled` — `LibboxRuntime` falls back between the two).
3. Update this README with the verified sing-box tag if relying on it for a
   release.
