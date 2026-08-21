# Shared startup fixtures

These files are parsed by **both** `apps/weblibre/test/core/startup/startup_parity_test.dart`
and `packages/flutter_mozilla_components/android/src/test/kotlin/.../startup/StartupParityTest.kt`.

They exist because the startup arbitration contract has two independent
implementations — Dart reads `startup_config.json` to drive the picker and the
maintenance queue, Kotlin reads it before any profile consumer runs — and a
divergence between them is not a cosmetic bug: it can put Gecko on profile A while
Dart opens profile B's databases.

Both test suites locate this directory by walking up from the working directory, so
neither depends on how its runner sets CWD.

Do not "fix" a fixture to make one side pass. If the two disagree, one of the two
parsers is wrong.
