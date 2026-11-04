/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

part of 'feature_policy.dart';

/// Every feature of the policy, with its [FeaturePolicy]. The string is the
/// feature's stable id, the name comments and docs refer to it by.
///
/// The `switch*` entries are the [VisibilitySwitch]es' own: their initial
/// values are the switch's value per preset.
enum FeatureId {
  /// Address bar / navigation / reload / Find in Page / pull to refresh /
  /// desktop site / built-in PDF viewer
  coreBrowsing(
    'core.browsing',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Regular and private tabs; List/Grid view; switch / close / pin /
  /// duplicate / reorder / reopen closed tabs
  coreTabs(
    'core.tabs',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Background tab Switch action
  coreBackgroundTabSwitch('core.background_tab_switch', FeaturePolicy.locked()),

  /// Default search provider / web suggestions / voice search
  searchDefaultProvider(
    'search.default_provider',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.userChoice)),
  ),

  /// Local results from tabs / bookmarks / history / indexed page text
  searchLocalResults(
    'search.local_results',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Search-provider chips (tap to pick a destination)
  bangsChips('bangs.chips', FeaturePolicy.locked()),

  /// Bookmarks with folders / search / HTML import and export
  libraryBookmarks('library.bookmarks', FeaturePolicy.locked()),

  /// Bookmark open behavior (ask / regular / private / Custom Tab / isolated)
  libraryBookmarkOpenBehavior(
    'library.bookmark_open_behavior',
    FeaturePolicy.locked(
      initial: PresetValues(average: PolicyToken.regularTab),
    ),
  ),

  /// History and downloads incl. pause / resume / retry / download folder
  libraryHistoryDownloads('library.history_downloads', FeaturePolicy.locked()),

  /// Home surface module layout (browser home when no tab is selected)
  homeLayoutHome('home.layout_home', FeaturePolicy.locked()),

  /// New-tab surface module layout (search screen before typing)
  homeLayoutNewTab(
    'home.layout_new_tab',
    FeaturePolicy.locked(
      initial: PresetValues(average: PolicyToken.calmNewTab),
    ),
  ),

  /// Search surface module layout (results while typing)
  searchLayoutResults('search.layout_results', FeaturePolicy.locked()),

  /// Feature-dependent modules follow their feature's visibility on every
  /// surface
  homeModuleFeatureFilter(
    'home.module_feature_filter',
    FeaturePolicy.notUserFacing(),
  ),

  /// App language / theme / OLED black / UI zoom / font size / reduced
  /// animations
  appearanceCore('appearance.core', FeaturePolicy.locked()),

  /// Tab bar position (Automatic / Top / Bottom) / compact or title style /
  /// ordinary toolbar buttons
  layoutBasic(
    'layout.basic',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.userChoice)),
  ),

  /// Adaptive side panel on larger windows (Automatic) / resize and collapse
  /// / Left or Right rail
  layoutAdaptiveSidePanel('layout.adaptive_side_panel', FeaturePolicy.locked()),

  /// Default keyboard shortcuts
  inputKeyboardShortcuts(
    'input.keyboard_shortcuts',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Touch / mouse and trackpad / multi-window / Picture-in-Picture
  inputPointerMultiwindow('input.pointer_multiwindow', FeaturePolicy.locked()),

  /// Enhanced Tracking Protection active (Strict)
  privacyEtp(
    'privacy.etp',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// DNS over HTTPS active (Increased Protection)
  privacyDoh(
    'privacy.doh',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Block insecure HTTP connections active
  privacyHttpsOnly(
    'privacy.https_only',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Global Privacy Control signal sent
  privacyGpc(
    'privacy.gpc',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Query parameter stripping active
  privacyQueryStripping(
    'privacy.query_stripping',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Bounce tracking protection active
  privacyBounceTracking(
    'privacy.bounce_tracking',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Third-party redirect blocking active
  privacyThirdPartyRedirectBlocking(
    'privacy.third_party_redirect_blocking',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Safe Browsing (malware and phishing) active
  privacySafeBrowsing(
    'privacy.safe_browsing',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Site isolation (Fission) active
  privacySiteIsolation(
    'privacy.site_isolation',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Local network access protection and local network request blocking
  privacyLocalNetworkProtection(
    'privacy.local_network_protection',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Recommended web engine hardening preferences (Complete Hardening without
  /// Optional items)
  privacyEngineHardeningBaseline(
    'privacy.engine_hardening_baseline',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Switches for HTTPS-Only mode / GPC / query stripping / bounce tracking /
  /// third-party redirect blocking
  privacyBasicSwitches(
    'privacy.basic_switches',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Tracking protection level change (Standard / Strict)
  privacyTrackingProtectionLevel(
    'privacy.tracking_protection_level',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// DoH provider choice / custom resolver / Max Protection
  privacyDohProviderControl(
    'privacy.doh_provider_control',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Safe Browsing malware and phishing switches
  privacySafeBrowsingSwitches(
    'privacy.safe_browsing_switches',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Browser Languages (languages websites see)
  privacyBrowserLanguages(
    'privacy.browser_languages',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Complete Hardening switch
  privacyCompleteHardeningSwitch(
    'privacy.complete_hardening_switch',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
    ], initial: PresetValues.follows(FeatureId.privacyEngineHardeningBaseline)),
  ),

  /// Resist Fingerprinting
  privacyResistFingerprinting(
    'privacy.resist_fingerprinting',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Hardened fingerprint protection defaults
  privacyFpHardenedDefaults(
    'privacy.fp_hardened_defaults',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Local network blocking switches
  privacyLocalNetworkBlockingSwitch(
    'privacy.local_network_blocking_switch',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
    ], initial: PresetValues.follows(FeatureId.privacyLocalNetworkProtection)),
  ),

  /// Custom tracking policies: cookie policy / tracker categories / suspected
  /// fingerprinter scope
  privacyEtpCustomPolicies(
    'privacy.etp_custom_policies',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Granular fingerprint overrides
  privacyFpOverrides(
    'privacy.fp_overrides',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Engine hardening groups and individual preferences
  privacyEngineHardeningGroups(
    'privacy.engine_hardening_groups',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Optional (aggressive) engine hardening items
  privacyEngineHardeningOptional(
    'privacy.engine_hardening_optional',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Fission (site isolation) switch
  privacySiteIsolationSwitch(
    'privacy.site_isolation_switch',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// URL Cleaner removes known tracking parameters
  urlCleanerCleaning(
    'url_cleaner.cleaning',
    FeaturePolicy.locked(
      initial: PresetValues(
        average: PolicyToken.autoApply,
        advanced: PolicyToken.ask,
        expert: PolicyToken.ask,
      ),
    ),
  ),

  /// Inspect and restore removed link parameters
  urlCleanerInspectRestore(
    'url_cleaner.inspect_restore',
    FeaturePolicy.locked(),
  ),

  /// URL Cleaner review prompt / referral marketing option / catalog settings
  urlCleanerReviewAndReferral(
    'url_cleaner.review_and_referral',
    FeaturePolicy.guarded([VisibilitySwitch.privacyAdvanced]),
  ),

  /// Unshortener
  linksUnshortener(
    'links.unshortener',
    FeaturePolicy.guarded([
      VisibilitySwitch.privacyAdvanced,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// uBlock Origin as starter content blocker
  extensionsUblockStarter(
    'extensions.ublock_starter',
    FeaturePolicy.locked(
      initial: PresetValues.all(PolicyToken.recommendInstall),
    ),
  ),

  /// uBlock Origin optimized filter-list defaults
  extensionsUblockOptimizedFilters(
    'extensions.ublock_optimized_filters',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.recommend)),
  ),

  /// Add-on Store / permissions / updates / pinned add-on bar
  extensionsAddonManagement(
    'extensions.addon_management',
    FeaturePolicy.locked(),
  ),

  /// Install signed extension from .xpi file
  extensionsInstallSignedXpi(
    'extensions.install_signed_xpi',
    FeaturePolicy.locked(),
  ),

  /// uBlock Origin filter-list selection
  extensionsFilterListSelection(
    'extensions.filter_list_selection',
    FeaturePolicy.locked(),
  ),

  /// Allow unsigned extensions
  extensionsAllowUnsigned(
    'extensions.allow_unsigned',
    FeaturePolicy.guarded([
      VisibilitySwitch.expertDetails,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// Custom extension collection source
  extensionsCustomCollection(
    'extensions.custom_collection',
    FeaturePolicy.guarded([VisibilitySwitch.expertDetails]),
  ),

  /// Site panel: permissions / autoplay / per-site tracking exception / clear
  /// site data
  sitePanel('site.panel', FeaturePolicy.locked()),

  /// Intent Gatekeeper Allow / Block prompts for apps sending links
  linksIntentGatekeeper('links.intent_gatekeeper', FeaturePolicy.locked()),

  /// Intent Gatekeeper per-app decision list
  // Always available: Recovery: lets every user undo a saved allow or block
  // decision.
  linksIntentGatekeeperManagement(
    'links.intent_gatekeeper_management',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Set WebLibre as default browser
  systemDefaultBrowser('system.default_browser', FeaturePolicy.locked()),

  /// How links sent from other apps open (External Link Handling)
  linksIncomingDefault(
    'links.incoming_default',
    FeaturePolicy.locked(
      initial: PresetValues(average: PolicyToken.regularTab),
    ),
  ),

  /// Incoming links default to private or isolated tabs
  linksIncomingPrivateIsolatedChoice(
    'links.incoming_private_isolated_choice',
    FeaturePolicy.guarded(
      [VisibilitySwitch.isolatedTabs],
      uiRequires: [FeatureId.tabsIsolatedUi],
    ),
  ),

  /// Open links in other apps (Open Links in Apps)
  linksOutgoingAppHandoff(
    'links.outgoing_app_handoff',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.ask)),
  ),

  /// Remembered per-site app-link choices
  // Always available: Recovery: lets every user undo a remembered app-link
  // choice.
  linksRememberedSiteRules(
    'links.remembered_site_rules',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Always ask before app handoff in private tabs / over Tor or proxy / in
  /// strict containers
  linksSensitiveContextConfirmation(
    'links.sensitive_context_confirmation',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Custom Tabs for apps that open WebLibre as a lightweight browser
  linksCustomTabs(
    'links.custom_tabs',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Current-profile security and backup controls
  profilesCurrentProfileControls(
    'profiles.current_profile_controls',
    FeaturePolicy.locked(),
  ),

  /// App Lock with device lock / auto-lock timing
  securityAppLockDevice(
    'security.app_lock_device',
    FeaturePolicy.locked(
      uiRequires: [FeatureId.profilesCurrentProfileControls],
    ),
  ),

  /// Profile password lock
  // Always available: Security: lock options for the current profile stay
  // reachable for everyone.
  securityProfilePassword(
    'security.profile_password',
    FeaturePolicy.alwaysAvailable(
      uiRequires: [FeatureId.profilesCurrentProfileControls],
    ),
  ),

  /// Multiple profiles with separate settings / extensions / data
  profilesMulti(
    'profiles.multi',
    FeaturePolicy.guarded([VisibilitySwitch.profiles]),
  ),

  /// Screenshot protection
  securityScreenshotProtection(
    'security.screenshot_protection',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// Manual Delete Browsing Data
  dataDeleteManual('data.delete_manual', FeaturePolicy.locked()),

  /// History retention (Auto-Clear History)
  dataHistoryRetention(
    'data.history_retention',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.days90)),
  ),

  /// Delete Browsing Data Automatically (on Quit and start)
  // Always available: Recovery: rules that delete data must always be
  // visible and changeable.
  dataAutoDelete(
    'data.auto_delete',
    FeaturePolicy.alwaysAvailable(
      initial: PresetValues.all(PolicyToken.disabled),
    ),
  ),

  /// Auto-Clear Unassigned Tabs
  // Always available: Recovery: rules that delete data must always be
  // visible and changeable.
  dataAutoClearUnassignedTabs(
    'data.auto_clear_unassigned_tabs',
    FeaturePolicy.alwaysAvailable(
      initial: PresetValues.all(PolicyToken.disabled),
    ),
  ),

  /// Reader Mode and reader appearance
  contentReaderMode(
    'content.reader_mode',
    FeaturePolicy.locked(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// On-device page translation
  contentTranslation('content.translation', FeaturePolicy.locked()),

  /// Enforce Reader Mode
  // Always available: Single setting next to Reader Mode.
  contentEnforceReaderMode(
    'content.enforce_reader_mode',
    FeaturePolicy.alwaysAvailable(
      initial: PresetValues.all(PolicyToken.disabled),
    ),
  ),

  /// External download manager integration
  // Always available: Single setting in Downloads.
  downloadsExternalManager(
    'downloads.external_manager',
    FeaturePolicy.alwaysAvailable(
      initial: PresetValues.all(PolicyToken.disabled),
    ),
  ),

  /// Share / print / PDF and image export / Markdown export / show QR code
  contentShareExport('content.share_export', FeaturePolicy.locked()),

  /// Scan QR codes from the address bar or home
  contentQrScanner('content.qr_scanner', FeaturePolicy.locked()),

  /// Isolated storage context (runtime capability shared by isolated tabs and
  /// web apps)
  storageIsolatedContext(
    'storage.isolated_context',
    FeaturePolicy.notUserFacing(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Install site as app or shortcut with normal storage
  webappsInstallBasic('webapps.install_basic', FeaturePolicy.locked()),

  /// Storage picker in the install dialog
  webappsStoragePicker(
    'webapps.storage_picker',
    FeaturePolicy.guarded(
      [VisibilitySwitch.webappStorage],
      initial: PresetValues(
        average: PolicyToken.hiddenShowSummary,
        advanced: PolicyToken.shown,
        expert: PolicyToken.shown,
      ),
    ),
  ),

  /// Web app with fresh isolated storage
  webappsStorageFreshIsolated(
    'webapps.storage_fresh_isolated',
    FeaturePolicy.guarded(
      [VisibilitySwitch.webappStorage],
      uiRequires: [FeatureId.webappsStoragePicker],
    ),
  ),

  /// Web app inheriting the source tab's isolated session
  // Always available: Automatic from the source tab; no control to hide.
  webappsStorageInheritIsolated(
    'webapps.storage_inherit_isolated',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Container-backed web app (shares the container's logins and connection)
  // Always available: Automatic from the source tab; no control to hide.
  webappsStorageContainer(
    'webapps.storage_container',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Several installs of one site for separate accounts
  webappsMultiInstall(
    'webapps.multi_install',
    FeaturePolicy.guarded(
      [VisibilitySwitch.webappStorage],
      uiRequires: [FeatureId.webappsStoragePicker],
    ),
  ),

  /// Firefox Sync sign-in or QR pairing / tabs / bookmarks / history
  syncFirefoxSync('sync.firefox_sync', FeaturePolicy.locked()),

  /// Send To Device
  syncSendToDevice('sync.send_to_device', FeaturePolicy.locked()),

  /// Custom sync server (FxA and token server overrides)
  syncCustomServer(
    'sync.custom_server',
    FeaturePolicy.guarded([VisibilitySwitch.expertDetails]),
  ),

  /// WebLibre Supporter subscription and account controls
  accountSupporter('account.supporter', FeaturePolicy.locked()),

  /// WebLibre Search (search modes / previews / Tor routing)
  searchWeblibreSearch('search.weblibre_search', FeaturePolicy.locked()),

  /// Settings search
  settingsSearch('settings.search', FeaturePolicy.locked()),

  /// Small Web Discover and source or category selection
  discoverySmallWeb('discovery.small_web', FeaturePolicy.locked()),

  /// Wander consoles (add and browse)
  // Always available: Lives inside Small Web; adds nothing elsewhere.
  discoveryWanderConsoles(
    'discovery.wander_consoles',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Subscribe to a detected RSS feed and read articles
  feedsSubscribeRead('feeds.subscribe_read', FeaturePolicy.locked()),

  /// Manual feed URLs / feed filters / archive
  // Always available: Lives inside the feed reader; adds nothing elsewhere.
  feedsManualAndArchive(
    'feeds.manual_and_archive',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Containers: named groups / colors and icons / pinning / moving tabs /
  /// exact-site assignments
  containerCore(
    'container.core',
    FeaturePolicy.guarded(
      [VisibilitySwitch.containers],
      initial: PresetValues(
        average: PolicyToken.uiHidden,
        advanced: PolicyToken.uiShown,
        expert: PolicyToken.uiShown,
      ),
    ),
  ),

  /// Cookie-isolated container (separate cookies / logins / site data;
  /// multiple accounts)
  containerCookieIsolation(
    'container.cookie_isolation',
    FeaturePolicy.guarded(
      [VisibilitySwitch.containers],
      uiRequires: [FeatureId.containerCore],
    ),
  ),

  /// Clear Container Data and Clear Data on Exit
  containerSiteDataClearing(
    'container.site_data_clearing',
    FeaturePolicy.guarded([VisibilitySwitch.containers]),
  ),

  /// Exclude from History
  containerHistoryExclusion(
    'container.history_exclusion',
    FeaturePolicy.guarded([VisibilitySwitch.containers]),
  ),

  /// Exclude from Search Index
  containerIndexExclusion(
    'container.index_exclusion',
    FeaturePolicy.guarded([VisibilitySwitch.containers]),
  ),

  /// Strict Mode (allowlist-only container)
  containerStrictMode(
    'container.strict_mode',
    FeaturePolicy.guarded([
      VisibilitySwitch.containers,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Wildcard site assignments and precedence
  containerWildcardAssignments(
    'container.wildcard_assignments',
    FeaturePolicy.guarded([VisibilitySwitch.containers]),
  ),

  /// Per-container App Link settings
  containerAppLinks(
    'container.app_links',
    FeaturePolicy.guarded([
      VisibilitySwitch.containers,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Per-container connection (Tor / VPN / proxy)
  containerProxyRouting(
    'container.proxy_routing',
    FeaturePolicy.guarded([
      VisibilitySwitch.containers,
      VisibilitySwitch.connections,
    ]),
  ),

  /// Bypass Global Proxy for one container
  containerBypassGlobalProxy(
    'container.bypass_global_proxy',
    FeaturePolicy.guarded([
      VisibilitySwitch.containers,
      VisibilitySwitch.connections,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Drag a tab onto another to create a container
  tabsDragToContainer(
    'tabs.drag_to_container',
    FeaturePolicy.guarded(
      [VisibilitySwitch.containers],
      uiRequires: [FeatureId.containerCore],
    ),
  ),

  /// Isolated tab creation UI
  tabsIsolatedUi(
    'tabs.isolated_ui',
    FeaturePolicy.guarded(
      [VisibilitySwitch.isolatedTabs],
      initial: PresetValues(
        average: PolicyToken.uiHidden,
        advanced: PolicyToken.uiShown,
        expert: PolicyToken.uiShown,
      ),
    ),
  ),

  /// Tab filters / sorting / bulk close / Bookmark All
  // Always available: Familiar tab tools (search, close all, sort); no new
  // concept.
  tabsViewTools('tabs.view_tools', FeaturePolicy.alwaysAvailable()),

  /// Parent-child tab relationships recorded when tabs open from other tabs
  tabsTreeRelationships(
    'tabs.tree_relationships',
    FeaturePolicy.notUserFacing(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Tree layout in the tab view (view menu and pinch layout cycle)
  tabsTreeViewMode(
    'tabs.tree_view_mode',
    FeaturePolicy.guarded([VisibilitySwitch.treeTabs]),
  ),

  /// Show hierarchy in List/Grid views
  tabsHierarchyDisplay(
    'tabs.hierarchy_display',
    FeaturePolicy.guarded([VisibilitySwitch.treeTabs]),
  ),

  /// Create Child Tabs option and child tab position
  tabsChildTabCreation(
    'tabs.child_tab_creation',
    FeaturePolicy.guarded([
      VisibilitySwitch.treeTabs,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// Quick tab switcher: Recently Used Tabs or disabled
  layoutStackingSimple(
    'layout.stacking_simple',
    FeaturePolicy.locked(
      initial: PresetValues(average: PolicyToken.recentlyUsedTabs),
    ),
  ),

  /// Container stacking modes (Accordion / Two Rows / Container Tabs)
  layoutStackingContainerModes(
    'layout.stacking_container_modes',
    FeaturePolicy.guarded([
      VisibilitySwitch.containers,
      VisibilitySwitch.layoutAdvanced,
    ]),
  ),

  /// Tab Groups stacking mode
  layoutStackingTabGroups(
    'layout.stacking_tab_groups',
    FeaturePolicy.guarded([VisibilitySwitch.layoutAdvanced]),
  ),

  /// Contextual toolbar fallbacks and long-press actions
  layoutContextualToolbarAdvanced(
    'layout.contextual_toolbar_advanced',
    FeaturePolicy.guarded([VisibilitySwitch.layoutAdvanced]),
  ),

  /// Browser menu customization
  layoutMenuCustomization(
    'layout.menu_customization',
    FeaturePolicy.guarded([VisibilitySwitch.layoutAdvanced]),
  ),

  /// Drawn gestures with bindings / exclusions / timing
  inputDrawnGestures(
    'input.drawn_gestures',
    FeaturePolicy.guarded([
      VisibilitySwitch.gestures,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// Remapped tab-bar and tab-view swipes
  inputTabSwipeRemap(
    'input.tab_swipe_remap',
    FeaturePolicy.guarded([VisibilitySwitch.gestures]),
  ),

  /// Custom keyboard shortcuts
  inputKeyboardShortcutCustomization(
    'input.keyboard_shortcut_customization',
    FeaturePolicy.guarded([VisibilitySwitch.keyboardCustomization]),
  ),

  /// Actions results in address-bar search
  // Always available: Shown only for a matching query; each action is
  // filtered by its own feature's switch.
  searchActionsResults(
    'search.actions_results',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Customize Sections (search and start views)
  // Always available: Needed to rearrange home and new tab, which onboarding
  // mentions to everyone.
  searchSectionCustomization(
    'search.section_customization',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Local search index management / clipboard and history suggestion
  /// controls
  // Always available: Privacy controls for stored page text and suggestions
  // stay reachable.
  searchIndexAndSuggestionControls(
    'search.index_and_suggestion_controls',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Typed ! triggers / pinned providers / Search On This Site / simple
  /// custom engines and their aliases / repository refresh
  bangsTypedAndBasicCustom(
    'bangs.typed_and_basic_custom',
    FeaturePolicy.locked(),
  ),

  /// Custom bang URL template flags / placeholder and space encoding
  bangsCustomFormatFlags(
    'bangs.custom_format_flags',
    FeaturePolicy.guarded([VisibilitySwitch.expertDetails]),
  ),

  /// Encrypted profile backups and restore / backup folder
  // Always available: Exception (product decision): backup and restore are
  // recovery features.
  backupProfileBackupRestore(
    'backup.profile_backup_restore',
    FeaturePolicy.alwaysAvailable(
      uiRequires: [FeatureId.profilesCurrentProfileControls],
    ),
  ),

  /// App settings export and import
  // Always available: Exception (product decision): part of backup and
  // restore.
  backupSettingsTransfer(
    'backup.settings_transfer',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Supporter encrypted settings snapshots
  // Always available: Exception (product decision): part of backup and
  // restore.
  backupSupporterEncryptedSettings(
    'backup.supporter_encrypted_settings',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Gecko preference export and import
  // Always available: Exception (product decision): an option inside the
  // settings export.
  backupGeckoPrefTransfer(
    'backup.gecko_pref_transfer',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Supporter browser-engine preference snapshots
  // Always available: Exception (product decision): part of backup and
  // restore.
  backupSupporterPrefSnapshots(
    'backup.supporter_pref_snapshots',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// Connection runtime (Tor and proxy client)
  connectionsCore('connections.core', FeaturePolicy.notUserFacing()),

  /// Tabs that require a stopped connection are blocked, never sent directly
  connectionsFailClosed(
    'connections.fail_closed',
    FeaturePolicy.notUserFacing(initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Basic Tor: start / assign to a browsing context / automatic transport /
  /// onion sites / New Identity
  connectionsTorBasic(
    'connections.tor_basic',
    FeaturePolicy.guarded([VisibilitySwitch.connections]),
  ),

  /// Import WireGuard file, proxy QR/link or subscription / route choice /
  /// status and testing
  connectionsImportVpnProxy(
    'connections.import_vpn_proxy',
    FeaturePolicy.guarded([VisibilitySwitch.connections]),
  ),

  /// Route all regular or private tabs through a connection
  connectionsGlobalRouting(
    'connections.global_routing',
    FeaturePolicy.guarded([VisibilitySwitch.connections]),
  ),

  /// Connection for a single isolated tab
  connectionsIsolatedTabRouting(
    'connections.isolated_tab_routing',
    FeaturePolicy.guarded(
      [VisibilitySwitch.connections, VisibilitySwitch.isolatedTabs],
      uiRequires: [FeatureId.tabsIsolatedUi],
    ),
  ),

  /// DNS Override per proxy connection profile
  connectionsDnsOverride(
    'connections.dns_override',
    FeaturePolicy.guarded([
      VisibilitySwitch.connections,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Manual proxy configuration: protocols / credentials / sing-box /
  /// WireGuard Allowed IPs
  connectionsManualProxyConfig(
    'connections.manual_proxy_config',
    FeaturePolicy.guarded([
      VisibilitySwitch.connections,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Manual Tor: obfs4 or Snowflake / bridge fetching / entry and exit
  /// country restrictions
  connectionsTorManual(
    'connections.tor_manual',
    FeaturePolicy.guarded([
      VisibilitySwitch.connections,
      VisibilitySwitch.expertDetails,
    ]),
  ),

  /// Website push via a UnifiedPush distributor
  // Always available: Exception (product decision): websites ask for
  // notifications themselves; distributor setup is offered when a site asks.
  notificationsWebPush(
    'notifications.web_push',
    FeaturePolicy.alwaysAvailable(),
  ),

  /// On-device AI master switch (local model, download and storage)
  // Off in every preset: Tinkerer and Expert show its controls
  // (`switch.ai`), but turning AI on is its own choice, the onboarding's
  // "Use on-device AI" goal or the switch itself. Wanting more controls is
  // not asking for model downloads or AI processing.
  aiLocalAi(
    'ai.local_ai',
    FeaturePolicy.guarded([
      VisibilitySwitch.ai,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// AI container suggestions and draft containers
  aiContainerSuggestions(
    'ai.container_suggestions',
    FeaturePolicy.guarded(
      [VisibilitySwitch.ai, VisibilitySwitch.containers],
      initial: PresetValues.follows(FeatureId.aiLocalAi),
      uiRequires: [FeatureId.containerCore],
    ),
  ),

  /// Error logs / basic filtering / Reset UI / icon cache / clear AI
  /// downloads
  // Always available: Support: error logs and Reset UI must stay reachable
  // for troubleshooting.
  diagnosticsBasic('diagnostics.basic', FeaturePolicy.alwaysAvailable()),

  /// TRACE and DEBUG logs / stack traces / proxy runtime diagnosis
  diagnosticsVerboseLogs(
    'diagnostics.verbose_logs',
    FeaturePolicy.guarded([VisibilitySwitch.expertDetails]),
  ),

  /// JavaScript on/off switch (global)
  advancedJavascriptControl(
    'advanced.javascript_control',
    FeaturePolicy.guarded([
      VisibilitySwitch.expertDetails,
    ], initial: PresetValues.all(PolicyToken.enabled)),
  ),

  /// Custom user agent
  advancedCustomUserAgent(
    'advanced.custom_user_agent',
    FeaturePolicy.guarded([VisibilitySwitch.expertDetails]),
  ),

  /// Trust third-party CA certificates
  advancedThirdPartyCa(
    'advanced.third_party_ca',
    FeaturePolicy.guarded([
      VisibilitySwitch.expertDetails,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// Experimental process options (Isolated Content Process / App Zygote
  /// Process)
  advancedExperimentalProcess(
    'advanced.experimental_process',
    FeaturePolicy.guarded([
      VisibilitySwitch.expertDetails,
    ], initial: PresetValues.all(PolicyToken.disabled)),
  ),

  /// Unmount Engine Off-Screen
  advancedUnmountEngineOffscreen(
    'advanced.unmount_engine_offscreen',
    FeaturePolicy.guarded([
      VisibilitySwitch.expertDetails,
    ], initial: PresetValues.all(PolicyToken.platformDependent)),
  ),

  /// Alpha build side by side
  releaseAlphaChannel('release.alpha_channel', FeaturePolicy.notUserFacing()),

  /// Visibility switch: Containers and all container options
  switchContainers(
    'switch.containers',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Isolated-tab creation and isolated choices in pickers
  switchIsolatedTabs(
    'switch.isolated_tabs',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Tor, VPN and proxy controls
  switchConnections(
    'switch.connections',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Multiple profiles (profile switcher, adding profiles)
  switchProfiles(
    'switch.profiles',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Tree layout, hierarchy display, child-tab creation
  switchTreeTabs(
    'switch.tree_tabs',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Container stacking modes, Tab Groups, toolbar
  /// fallbacks and long-press setup, menu customization
  switchLayoutAdvanced(
    'switch.layout_advanced',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Drawn gestures, swipe remapping, the gestures quick
  /// toggle
  switchGestures(
    'switch.gestures',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Editing keyboard shortcuts (the shortcut overview
  /// stays)
  switchKeyboardCustomization(
    'switch.keyboard_customization',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Privacy switches and presets, DoH provider, Browser
  /// Languages, URL Cleaner review, Unshortener
  switchPrivacyAdvanced(
    'switch.privacy_advanced',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Web-app Storage picker, fresh isolated storage,
  /// several installs per site
  switchWebappStorage(
    'switch.webapp_storage',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: On-device AI settings and tools
  switchAi(
    'switch.ai',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.enabled,
        expert: PolicyToken.enabled,
      ),
    ),
  ),

  /// Visibility switch: Every expert_detail control, together with that
  /// feature's own switch
  switchExpertDetails(
    'switch.expert_details',
    FeaturePolicy.visibilitySwitch(
      PresetValues(
        average: PolicyToken.disabled,
        advanced: PolicyToken.disabled,
        expert: PolicyToken.enabled,
      ),
    ),
  );

  const FeatureId(this.id, this.policy);

  /// The stable id, e.g. `container.core`.
  final String id;

  final FeaturePolicy policy;
}

/// The visibility switches. Persisted by [name].
enum VisibilitySwitch {
  containers(
    FeatureId.switchContainers,
    inherits: LegacyVisibilitySetting.showContainerUi,
  ),
  isolatedTabs(
    FeatureId.switchIsolatedTabs,
    inherits: LegacyVisibilitySetting.showIsolatedTabUi,
  ),
  connections(FeatureId.switchConnections),
  profiles(FeatureId.switchProfiles),
  treeTabs(FeatureId.switchTreeTabs),
  layoutAdvanced(FeatureId.switchLayoutAdvanced),
  gestures(FeatureId.switchGestures),
  keyboardCustomization(FeatureId.switchKeyboardCustomization),
  privacyAdvanced(FeatureId.switchPrivacyAdvanced),
  webappStorage(FeatureId.switchWebappStorage),
  ai(FeatureId.switchAi),
  expertDetails(FeatureId.switchExpertDetails);

  const VisibilitySwitch(this.featureId, {this.inherits});

  /// The switch's own entry, holding its initial values.
  final FeatureId featureId;

  /// The legacy setting an existing install copies while the switch is
  /// unwritten, and that turning the switch on turns back on. Without one,
  /// an existing install sees the switch on: the UI it guards was always
  /// visible.
  final LegacyVisibilitySetting? inherits;

  FeaturePolicy get policy => featureId.policy;
}
