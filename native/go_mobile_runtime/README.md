# Go Mobile Runtime

This directory builds the single Android `gomobile` AAR used by WebLibre.

`gomobile` does not support multiple Go mobile AARs in one Android app because
the generated Go runtime/JNI symbols collide. WebLibre therefore binds sing-box
`libbox` and IPtProxy in one `gomobile bind` invocation.

Pinned inputs are defined in `pins.env`:

- sing-box `v1.13.12`
- IPtProxy `5.4.2`
- IPtProxy's `dnstt` submodule commit `f1b9b97a269f83bad41d2ceef291b4d2c161cd11`
- `github.com/sagernet/gomobile@v0.1.12`

Build locally from the repository root:

```sh
melos run build-go-runtime --no-select
```

The default source locations are sibling checkouts of this repository:

- `../sing-box`
- `../IPtProxy`

IPtProxy requires its `dnstt` submodule. Initialize it in the IPtProxy checkout
or pass `--dnstt-source /path/to/dnstt`.

Override them when needed:

```sh
native/go_mobile_runtime/scripts/build-android.sh \
  --sing-box-source /path/to/sing-box \
  --iptproxy-source /path/to/IPtProxy
```

The output AAR is written to `native/go_mobile_runtime/build/weblibre-go.aar`.

GitHub release builds clone the pinned sources from `pins.env` and run the same
Melos command before building the Flutter APK/AAB artifacts. The app Gradle
build and CI native runtime build both read `weblibre.ndkVersion` from
`apps/weblibre/android/gradle.properties`; it is currently Android NDK r28c
(`28.2.13676358`), matching Flutter 3.44's default NDK. This is new enough for
the `cronet-go` Android arm64 archives linked by sing-box's naive outbound path.
