# External Download Manager Feature - Implementation Plan

## Overview
Implement support for external download managers (ADM, 1DM, AB DM) as requested in GitHub issue #146.
The feature uses a database-stored setting (similar to AppLinks) rather than SharedPreferences,
and configures Mozilla's DownloadsFeature to forward downloads to third-party apps.

## Reference Implementation (Fenix)
- **Preference Key**: `pref_key_external_download_manager`
- **Usage in Fenix**:
  - `fenix/app/src/main/java/org/mozilla/fenix/browser/BaseBrowserFragment.kt:759` - DownloadsFeature configuration
  - `fenix/app/src/main/java/org/mozilla/fenix/addons/AddonPopupBaseFragment.kt:93` - DownloadsFeature in addons
  - `fenix/app/src/main/res/xml/downloads_settings_preferences.xml:8` - Settings UI XML
  - `fenix/app/src/main/res/values/preference_keys.xml:503` - Preference key definition

## WebLibre Pattern Reference (AppLinks)
The implementation should follow the existing AppLinks pattern as a reference:
- **Model**: `app/lib/features/user/data/models/general_settings.dart` - AppLinksMode not here (it's in native), but this shows the pattern
- **Repository**: `app/lib/features/user/domain/repositories/general_settings.dart:37-195` - GeneralSettingsRepository pattern
- **Native Storage**: `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/api/GeckoEngineSettingsApiImpl.kt:325-352` - AppLinks storage in SharedPreferences (our implementation will use global state set by Flutter)
- **Native Usage**: `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/GlobalComponents.kt:60-74` - shouldOpenLinksInApp/shouldPromptOpenLinksInApp pattern
- **Pigeon API**: `packages/flutter_mozilla_components/pigeons/gecko.dart:643-653` - AppLinksMode enum
- **Provider**: `app/lib/features/geckoview/features/browser/domain/providers.dart:382-395` - AppLinksModeNotifier
- **Service**: `packages/flutter_mozilla_components/lib/src/domain/services/gecko_engine_settings.dart:142-150` - setAppLinksMode/getAppLinksMode

## Architecture

### Data Flow
1. **Database Storage**: Setting stored in `user.db` -> `setting` table with partition_key='general'
2. **Flutter Layer**: GeneralSettings model manages the setting state
3. **Pigeon Bridge**: `setUseExternalDownloadManager(bool)`/`getUseExternalDownloadManager()` sync to native
4. **Native Layer**: GlobalComponents stores value as `var useExternalDownloadManager: Boolean`
5. **DownloadsFeature**: Uses `shouldForwardToThirdParties = { GlobalComponents.useExternalDownloadManager }`

### Key Components
- **Setting Type**: Boolean (default: false)
- **Storage Location**: user.db, setting table, partition_key='general', key='useExternalDownloadManager'
- **Native Integration**: Mozilla Android Components DownloadsFeature's shouldForwardToThirdParties callback

## Implementation Steps

### Phase 1: Data Model & Database Layer

#### Step 1.1 - Update GeneralSettings Model
**File**: `app/lib/features/user/data/models/general_settings.dart`

**Changes Required**:
- Add new field declaration: `final bool useExternalDownloadManager;`
- Add field to constructor parameters
- Add field to `withDefaults()` constructor (default value: `false`)
- Add field to `fromJson()`/`toJson()` methods via @JsonSerializable annotation
- Add field to `hashParameters` getter for FastEquatable

**Reference**: Look at `pullToRefreshEnabled` field (line 83) as a template

#### Step 1.2 - Update GeneralSettingsRepository
**File**: `app/lib/features/user/domain/repositories/general_settings.dart`

**Changes Required**:
- Add deserialization logic in `_deserializeSettings()` method (around line 142)
- Pattern:
  ```dart
  'useExternalDownloadManager': settings['useExternalDownloadManager']?.readAs(
    DriftSqlType.bool,
    db.typeMapping,
  ),
  ```
- This follows the same pattern as existing fields like `pullToRefreshEnabled` (line 125-128)

**Reference**: `_deserializeSettings()` method (lines 39-143) shows how all settings are deserialized

### Phase 2: Pigeon API Definition

#### Step 2.1 - Add Pigeon API Methods
**File**: `packages/flutter_mozilla_components/pigeons/gecko.dart`

**Location**: Find `GeckoEngineSettingsApi` interface (around line 1004-1015)

**Changes Required**:
- Add method declaration before closing brace:
  ```dart
  void setUseExternalDownloadManager(bool enabled);
  bool getUseExternalDownloadManager();
  ```

**Reference**: Similar to `setAppLinksMode` and `getAppLinksMode` methods (lines 1012-1014)

**Important**: After modifying this file, must run `melos build-pigeons --no-select` to regenerate interfaces

### Phase 3: Flutter Service Layer

#### Step 3.1 - Update GeckoEngineSettingsService
**File**: `packages/flutter_mozilla_components/lib/src/domain/services/gecko_engine_settings.dart`

**Location**: After `getAppLinksMode()` method (around line 148-151)

**Changes Required**:
- Add two methods to wrap Pigeon API calls:
  ```dart
  Future<void> setUseExternalDownloadManager(bool enabled) {
    return _api.setUseExternalDownloadManager(enabled);
  }

  Future<bool> getUseExternalDownloadManager() {
    return _api.getUseExternalDownloadManager();
  }
  ```

**Reference**: Follow pattern of `setAppLinksMode()`/`getAppLinksMode()` methods (lines 144-150)

#### Step 3.2 - Add Riverpod Provider
**File**: `app/lib/features/geckoview/features/browser/domain/providers.dart`

**Location**: After `AppLinksModeNotifier` class (around line 395)

**Changes Required**:
- Add new provider class:
  ```dart
  @Riverpod(keepAlive: true)
  class ExternalDownloadManagerNotifier extends _$ExternalDownloadManagerNotifier {
    final _service = GeckoEngineSettingsService();

    Future<void> setEnabled(bool enabled) async {
      await _service.setUseExternalDownloadManager(enabled);
      ref.invalidateSelf();
    }

    @override
    Future<bool> build() {
      return _service.getUseExternalDownloadManager();
    }
  }
  ```

**Reference**: Follow `AppLinksModeNotifier` pattern (lines 382-395)

**Important**: After modifying this file, must run `melos build --no-select` to generate provider code

### Phase 4: Native Implementation (Kotlin)

#### Step 4.1 - Implement Pigeon API Methods
**File**: `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/api/GeckoEngineSettingsApiImpl.kt`

**Location**: After `getAppLinksMode()` method (around line 353)

**Changes Required**:
- Add method implementations:
  ```kotlin
  override fun setUseExternalDownloadManager(enabled: Boolean) {
      GlobalComponents.useExternalDownloadManager = enabled
  }

  override fun getUseExternalDownloadManager(): Boolean {
      return GlobalComponents.useExternalDownloadManager ?: false
  }
  ```

**Reference**: Follow `setAppLinksMode()`/`getAppLinksMode()` implementation pattern (lines 325-352)
**Note**: Unlike AppLinks which uses SharedPreferences, we use a global variable that Flutter controls

#### Step 4.2 - Add Global State Variable
**File**: `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/GlobalComponents.kt`

**Location**: After other engine settings state (around line 74)

**Changes Required**:
- Add companion object variable:
  ```kotlin
  var useExternalDownloadManager: Boolean = false
  ```

**Reference**: Similar to `engineSettingsApi` and `pullToRefreshEnabled` variables (lines 58, 61)

#### Step 4.3 - Configure DownloadsFeature
**File**: `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/BaseBrowserFragment.kt`

**Location**: Find `downloadsFeature.set(...)` call (around line 271-293)

**Changes Required**:
- Add `shouldForwardToThirdParties` parameter to `DownloadsFeature` constructor:
  ```kotlin
  downloadsFeature.set(
      feature = DownloadsFeature(
          // ... existing parameters ...
          onNeedToRequestPermissions = { permissions ->
              requestDownloadPermissionsLauncher.launch(permissions)
          },
          shouldForwardToThirdParties = {
              GlobalComponents.useExternalDownloadManager
          },
      ),
      owner = this,
      view = view,
  )
  ```

**Reference**: Fenix implementation at `fenix/app/src/main/java/org/mozilla/fenix/browser/BaseBrowserFragment.kt:757-762`

### Phase 5: UI Implementation

#### Step 5.1 - Create Downloads Settings Section
**File**: `app/lib/features/settings/presentation/screens/privacy_security_settings.dart`

**Location**: In the `build()` method's ListView children list (around line 50)

**Changes Required**:
- Add `_DownloadsSection()` to children array after `_DataManagementSection()`
- Create new widget class:
  ```dart
  class _DownloadsSection extends StatelessWidget {
    const _DownloadsSection();

    @override
    Widget build(BuildContext context) {
      return const Column(
        children: [
          SettingSection(name: 'Downloads'),
          _ExternalDownloadManagerTile(),
        ],
      );
    }
  }
  ```

**Reference**: Look at `_PrivacyModesSection` (lines 65-78) or `_TrackingProtectionSection` patterns

#### Step 5.2 - Create Toggle Tile Widget
**File**: `app/lib/features/settings/presentation/screens/privacy_security_settings.dart`

**Location**: Add after the new `_DownloadsSection` class

**Changes Required**:
- Create `HookConsumerWidget` for the toggle:
  ```dart
  class _ExternalDownloadManagerTile extends HookConsumerWidget {
    const _ExternalDownloadManagerTile();

    @override
    Widget build(BuildContext context) {
      final useExternalDownloadManager = ref.watch(
        generalSettingsWithDefaultsProvider.select((s) => s.useExternalDownloadManager),
      );

      return SettingToggleTile(
        title: Text('Use external download manager'),
        subtitle: Text('Forward downloads to apps like ADM, 1DM, AB DM'),
        value: useExternalDownloadManager,
        onChanged: (value) async {
          await ref
              .read(generalSettingsRepositoryProvider.notifier)
              .updateSettings((s) => s.copyWith(useExternalDownloadManager: value));
        },
      );
    }
  }
  ```

**Reference**: Look at `_IncognitoModeSection` or other toggle implementations in the same file
**Pattern Reference**: `pullToRefreshEnabled` toggle at `app/lib/features/settings/presentation/screens/appearance_display_settings.dart:385-408`

### Phase 6: Synchronization & Initialization

#### Step 6.1 - Initial Synchronization
**Consideration**: When the app starts, we need to ensure the native side has the correct value.

**Options**:
1. **Option A**: Add to initialization code in `app/lib/domain/services/app_initialization.dart`
2. **Option B**: Let the provider's `build()` method handle it naturally (recommended)
3. **Option C**: Add to `app/lib/features/geckoview/features/browser/domain/providers.dart` initialization

**Recommended Approach**: Let the Riverpod provider handle it. When UI first renders, it will:
- Read from database via `generalSettingsRepositoryProvider`
- Provider's `build()` calls `getUseExternalDownloadManager()` from native
- The provider pattern will handle setting the value on native side when changed

**Note**: Unlike AppLinks (which reads from SharedPreferences in native code), this pattern relies on Flutter being the source of truth and syncing to native.

## Build Commands

After completing implementation changes, run these commands in order:

```bash
# 1. Regenerate Pigeon interfaces (after modifying gecko.dart)
melos build-pigeons --no-select

# 2. Regenerate Riverpod providers and models (after modifying providers.dart or models)
melos build --no-select
```

## Testing Checklist

- [ ] Setting toggle appears in Privacy & Security settings
- [ ] Toggle state persists across app restarts
- [ ] When enabled, downloads are forwarded to external apps
- [ ] When disabled, downloads use built-in manager
- [ ] Setting value is correctly stored in user.db
- [ ] Native side correctly reads value from Flutter
- [ ] DownloadsFeature uses correct shouldForwardToThirdParties value
- [ ] No SharedPreferences usage (requirement verified)

## File Modification Summary

| # | File | Phase | Change Type |
|---|------|-------|-------------|
| 1 | `app/lib/features/user/data/models/general_settings.dart` | 1.1 | Add model field |
| 2 | `app/lib/features/user/domain/repositories/general_settings.dart` | 1.2 | Add deserialization |
| 3 | `packages/flutter_mozilla_components/pigeons/gecko.dart` | 2.1 | Add Pigeon API methods |
| 4 | `packages/flutter_mozilla_components/lib/src/domain/services/gecko_engine_settings.dart` | 3.1 | Add service wrapper methods |
| 5 | `app/lib/features/geckoview/features/browser/domain/providers.dart` | 3.2 | Add Riverpod provider |
| 6 | `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/api/GeckoEngineSettingsApiImpl.kt` | 4.1 | Implement native methods |
| 7 | `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/GlobalComponents.kt` | 4.2 | Add global state variable |
| 8 | `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/BaseBrowserFragment.kt` | 4.3 | Configure DownloadsFeature |
| 9 | `app/lib/features/settings/presentation/screens/privacy_security_settings.dart` | 5.1, 5.2 | Add UI widgets |

## Important Notes

### Design Decisions

1. **No SharedPreferences in Native Code**: Unlike AppLinks which uses SharedPreferences, this feature uses a global variable set by Flutter. This ensures Flutter is the single source of truth.

2. **Database as Storage**: Setting is stored in the database (user.db, setting table) following the same pattern as other GeneralSettings.

3. **Provider Architecture**: Uses `@Riverpod(keepAlive: true)` to ensure the provider persists across widget rebuilds.

4. **Async Provider**: The provider returns `Future<bool>` because native Pigeon calls are asynchronous.

5. **Auto-Dispose Prevention**: `keepAlive: true` ensures the provider isn't disposed when no widgets are listening, which is important for maintaining sync state.

### Mozilla Android Components Integration

The `shouldForwardToThirdParties` callback in `DownloadsFeature` is invoked for each download request:
- When `true`: Download is forwarded to an external app via intent
- When `false`: Download is handled internally by FetchDownloadManager

This is the exact same mechanism used in Fenix for the same feature.

### Code Generation

Both `melos build-pigeons --no-select` and `melos build --no-select` are required because:
- Pigeon generates platform channel interfaces
- Riverpod generates provider code
- JSON serialization generates model methods
- CopyWith extension generates copyWith methods

Run these commands after modifying any annotated files.

## Related Code References

### Database Schema
**File**: `app/lib/features/user/data/database/definitions.drift:1-5`
- Setting table structure
- Uses Drift's `ANY` type for flexible value storage

### DAO Pattern
**File**: `app/lib/features/user/data/database/daos/setting.dart:29-62`
- `updateSetting()` method
- `getAllSettingsOfPartitionKey()` method
- Pattern for partition-based settings

### Settings UI Pattern
**File**: `app/lib/features/settings/presentation/screens/appearance_display_settings.dart:385-408`
- Example of toggle tile implementation
- Shows how to watch and update settings

### Native Feature Integration
**File**: `packages/flutter_mozilla_components/android/src/main/kotlin/eu/weblibre/flutter_mozilla_components/GlobalComponents.kt:60-74`
- Pattern for shouldOpenLinksInApp and shouldPromptOpenLinksInApp
- Similar to how shouldForwardToThirdParties will be used

## Success Criteria

Feature is complete when:
1. User can toggle "Use external download manager" in Privacy & Security settings
2. Toggle state persists in database (user.db, setting table)
3. When enabled, clicking download links prompts to open in external apps
4. When disabled, downloads use built-in download manager
5. Setting syncs correctly between Flutter and native layers
6. No SharedPreferences are used for this feature (verified requirement)
7. Code follows existing WebLibre patterns (GeneralSettings, AppLinks, etc.)
