// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get common_cancel => '取消';

  @override
  String get common_delete => '删除';

  @override
  String get common_close => '关闭';

  @override
  String get common_save => '保存';

  @override
  String get common_add => '添加';

  @override
  String get common_edit => '编辑';

  @override
  String get common_remove => '移除';

  @override
  String get common_clear => '清除';

  @override
  String get common_copy => '复制';

  @override
  String get common_open => '打开';

  @override
  String get common_reset => '重置';

  @override
  String get common_retry => '重试';

  @override
  String get common_done => '完成';

  @override
  String get common_undo => '撤销';

  @override
  String get common_dismiss => '忽略';

  @override
  String get common_discard => '舍弃';

  @override
  String get common_showLess => '收起';

  @override
  String get common_loading => '正在加载…';

  @override
  String get profileCopy_pickerContents => '标签页、历史记录和设置';

  @override
  String get profileCopy_dataDescription => '标签页、历史记录、书签、设置和已保存的网站登录信息';

  @override
  String get profileCopy_secretDataDescription => 'WebLibre 账户登录信息、同步设置和代理详情';

  @override
  String get profileCopy_cannotBeUndone => '此操作无法撤销。';

  @override
  String get profileCopy_nothingChanged => '未做任何更改。';

  @override
  String get profileCopy_restartsToWork => 'WebLibre 必须重启才能执行此操作。';

  @override
  String get profileCopy_asksPasswordAfterRestart =>
      '重启后，WebLibre 会要求输入备份文件的密码。';

  @override
  String get profileCopy_reopenToContinue => '请关闭 WebLibre 后重新打开。';

  @override
  String get profileCopy_signedInFromBackup => '恢复后的配置文件将使用备份中的 WebLibre 账户。';

  @override
  String get profileCopy_olderBackupKeepsCredentials =>
      '由旧版 WebLibre 创建的备份不包含这些信息，此时配置文件会保留其现有的登录信息。';

  @override
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged) {
    return 'WebLibre 无法安排此操作所需的重启。$nothingChanged';
  }

  @override
  String get profileCopy_shortcutsNeedPinningAgain => '恢复后需要重新固定主屏幕快捷方式。';

  @override
  String get profileCopy_restartClosesCurrentProfile =>
      '这还会关闭你当前正在使用的配置文件，它不一定是此处所指的配置文件。';

  @override
  String get profileCopy_restartKeepsOtherTabs => '其他标签页会在之后重新打开。';

  @override
  String profileCopy_privateTabsClosedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个隐私标签页将被关闭，其浏览数据将被清除。',
    );
    return '$_temp0';
  }

  @override
  String profileCopy_containersClearedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个设为退出时清除数据的容器中的数据将被清除。',
    );
    return '$_temp0';
  }

  @override
  String get httpErrorHandler_socketError => '无法连接远程服务';

  @override
  String get httpErrorHandler_httpError => '网络请求返回了错误';

  @override
  String get httpErrorHandler_formatError => '响应格式错误';

  @override
  String get httpErrorHandler_clientError => '无法连接远程服务';

  @override
  String profileDiscovery_recoveredProfileName(String idFragment) {
    return '已恢复的配置文件 $idFragment';
  }

  @override
  String get about_copyright => 'Copyright © Fabian Freund, 2024-2026';

  @override
  String get about_geckoVersionTitle => 'Gecko 版本';

  @override
  String get about_notAvailable => '不可用';

  @override
  String get about_feedbackTitle => '反馈';

  @override
  String get about_donateTitle => '捐赠';

  @override
  String get about_documentationTitle => '文档';

  @override
  String get about_githubTitle => 'GitHub';

  @override
  String get account_screenTitle => 'WebLibre 账户';

  @override
  String get account_searchHint => '搜索账户设置';

  @override
  String get account_loadFailed => '无法加载账户';

  @override
  String get account_sectionAccount => '账户';

  @override
  String get account_sectionSubscription => '订阅';

  @override
  String get account_sectionSearchCredits => '搜索额度';

  @override
  String get account_sectionSettingsSnapshots => '设置快照';

  @override
  String get account_sectionPreferencesSnapshots => '首选项快照';

  @override
  String get account_sectionEncryptedSync => '加密同步';

  @override
  String get account_signInTitle => '登录 WebLibre 账户';

  @override
  String get account_signInKeywords => '登录,账户,账号,身份验证';

  @override
  String get account_signInSyncKeyKeywords => '同步密钥,重置同步密钥';

  @override
  String get account_signingInTitle => '正在登录';

  @override
  String get account_signedInTitle => '已登录的账户';

  @override
  String get account_signInFailedTitle => '登录失败';

  @override
  String get account_syncAcrossDevicesSubtitle => '在设备间同步你的设置';

  @override
  String get account_signingInSubtitle => '请在浏览器中完成登录';

  @override
  String get account_signedInFallback => '已登录';

  @override
  String get account_entrySupporterSubscriptionTitle => '支持者订阅';

  @override
  String get account_entrySupporterSubscriptionKeywords => '账单,付款,支持者,订阅';

  @override
  String get account_entrySupporterSubscriptionSubtitle => '状态、账单和订阅管理';

  @override
  String get account_entrySearchCreditsTitle => '搜索额度';

  @override
  String get account_entrySearchCreditsKeywords => '令牌,搜索套餐';

  @override
  String get account_entrySearchCreditsSubtitle => '额度余额、令牌发放和购买';

  @override
  String get account_entrySettingsSnapshotsTitle => '设置快照';

  @override
  String get account_entrySettingsSnapshotsKeywords => '备份,设置同步';

  @override
  String get account_entrySettingsSnapshotsSubtitle => '存储和恢复已同步的应用设置';

  @override
  String get account_entryPreferencesSnapshotsTitle => '首选项快照';

  @override
  String get account_entryPreferencesSnapshotsKeywords => '备份,首选项同步,prefs';

  @override
  String get account_entryPreferencesSnapshotsSubtitle => '存储和恢复已同步的首选项文档';

  @override
  String get account_entrySetupEncryptedSyncTitle => '设置加密同步';

  @override
  String get account_entrySetupEncryptedSyncKeywords => '同步密钥,备份,快照';

  @override
  String get account_entrySetupEncryptedSyncSubtitle => '使用账户密码启用端到端加密同步';

  @override
  String get account_actionRestore => '恢复';

  @override
  String get account_actionEditLabel => '编辑标签';

  @override
  String get account_actionStore => '存储';

  @override
  String get account_actionTryAgain => '重试';

  @override
  String get account_actionSignOut => '退出登录';

  @override
  String get account_actionEnableSync => '启用同步';

  @override
  String get account_adoptTitleUsable => '此设备上仍保留着旧的登录信息';

  @override
  String get account_adoptTitleUnusable => '无法读取旧的登录信息';

  @override
  String account_adoptBodyUsable(String name) {
    return 'WebLibre 保留了 $name 的登录信息，它来自各配置文件拥有独立账户之前。它并非来自备份，此设备上也没有任何记录表明它属于哪个配置文件，因此 WebLibre 不会进行猜测。';
  }

  @override
  String get account_adoptBodyUnusable =>
      'WebLibre 保留了各配置文件拥有独立账户之前的登录信息，但已保存的数据已损坏，无法用于登录。唯一的办法是重新登录；移除它即可清除此消息。';

  @override
  String get account_adoptRetryError => '操作未成功。请检查网络连接后重试。';

  @override
  String get account_adoptNotMine => '不是我的';

  @override
  String get account_adoptRemoveIt => '移除';

  @override
  String get account_adoptUseItHere => '在此使用';

  @override
  String get account_forgetSignInTitle => '忘记此登录信息？';

  @override
  String account_forgetSignInContent(String name) {
    return '$name 的已保存会话将从此设备中删除。如果它属于其他配置文件，你需要在那里重新登录。';
  }

  @override
  String get account_actionForgetIt => '忘记';

  @override
  String get account_previousSignInFallback => '之前的登录';

  @override
  String account_signInAgainAs(String account) {
    return '以 $account 身份重新登录';
  }

  @override
  String get account_signInExpiredSubtitle => '此配置文件保存的登录信息已过期。你的同步密钥仍会保留。';

  @override
  String get account_signingInEllipsis => '正在登录…';

  @override
  String get account_completeSignInInApp => '请在 WebLibre 中完成登录';

  @override
  String get account_tooltipSignOut => '退出登录';

  @override
  String get account_signOutConfirmTitle => '退出登录？';

  @override
  String get account_signOutConfirmContent => '确定要退出你的 WebLibre 账户吗？';

  @override
  String get account_resetSyncKeyTitle => '重置同步密钥';

  @override
  String get account_resetSyncKeySubtitle => '如果你输错了密码或更改过密码，请重新输入';

  @override
  String get account_resetSyncKeyConfirmContent =>
      '你需要重新输入账户密码。如果密码已更改，使用旧密码加密的现有快照将无法再解密。';

  @override
  String get account_subscriptionLoadFailed => '无法加载订阅';

  @override
  String get account_checkConnectionRetry => '请检查网络连接后重试。';

  @override
  String get account_planFallbackSupporter => '支持者';

  @override
  String get account_badgeWillNotRenew => '不会续订';

  @override
  String get account_badgeActive => '有效';

  @override
  String account_untilDate(String date) {
    return '有效期至 $date';
  }

  @override
  String get account_actionManageSubscription => '管理订阅';

  @override
  String get account_badgePaused => '已暂停';

  @override
  String get account_pausedNote => '你的订阅已暂停。请在客户门户中恢复订阅以重新获得访问权限。';

  @override
  String get account_badgePastDue => '逾期未付';

  @override
  String get account_pastDueNote => '付款失败。请更新你的付款方式以保持订阅有效。';

  @override
  String get account_actionUpdatePaymentMethod => '更新付款方式';

  @override
  String get account_endedNote => '你的订阅已结束。请在客户门户中续订以继续使用。';

  @override
  String get account_actionRenewSubscription => '续订';

  @override
  String get account_planSupporterSubscription => '支持者订阅';

  @override
  String get account_subscribeSubtitle => '订阅以解锁同步功能';

  @override
  String get account_badgeInactive => '未订阅';

  @override
  String get account_actionSubscribe => '订阅';

  @override
  String get account_tooltipRefreshStatus => '刷新状态';

  @override
  String account_subscriptionEndsOn(String date) {
    return '你的订阅将于 $date 结束';
  }

  @override
  String get account_bannerTitle => '支持 WebLibre';

  @override
  String get account_bannerBody =>
      '支持者是一项可选订阅，用于资助 WebLibre 的开发，并提供需要托管服务才能运行的功能。浏览器本身及其隐私功能无需订阅。<learnMore>了解详情</learnMore>。';

  @override
  String get account_featureSearchLabel => 'WebLibre 搜索';

  @override
  String get account_featureSearchDescription =>
      '内置于浏览器中的私密、无广告搜索。它融合多个独立来源的结果，提供可调节的搜索模式，可经由 Tor 路由，并让你安全地预览页面——同时在设计上确保你的搜索无法与你的账户关联。';

  @override
  String get account_featureSyncLabel => '加密账户同步';

  @override
  String get account_featureSyncDescription =>
      '在不同配置文件和设备之间存储和恢复你的 WebLibre 设置与首选项。所有内容在上传前都会在你的设备上加密，只有你能读取。';

  @override
  String get account_becomeSupporter => '成为支持者';

  @override
  String get account_syncSetupEnterPassword => '请输入密码';

  @override
  String get account_syncSetupPasswordsMismatch => '两次输入的密码不一致';

  @override
  String get account_syncSetupPasswordMismatchBackup => '密码与你现有的加密备份不匹配。';

  @override
  String account_syncSetupFailed(String error) {
    return '无法设置同步：$error';
  }

  @override
  String get account_syncSetupTitle => '设置加密同步';

  @override
  String get account_syncSetupDescription =>
      '输入你的账户密码以启用端到端加密同步。你的数据会在上传前于设备上加密——服务器永远看不到你的设置。';

  @override
  String get account_fieldAccountPassword => '账户密码';

  @override
  String get account_fieldConfirmPassword => '确认密码';

  @override
  String account_failedLoadSnapshots(String error) {
    return '无法加载快照：$error';
  }

  @override
  String account_syncKindStored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': '设置已存储',
      'geckoUserJs': 'Gecko 首选项已存储',
      'other': '快照已存储',
    });
    return '$_temp0';
  }

  @override
  String account_syncKindSnapshotsTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': '设置快照',
      'geckoUserJs': 'Gecko 首选项快照',
      'other': '快照',
    });
    return '$_temp0';
  }

  @override
  String get account_storeCurrentTitle => '存储当前数据';

  @override
  String account_storeCurrentSubtitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': '加密并上传当前设置',
      'geckoUserJs': '加密并上传当前 Gecko 首选项',
      'other': '加密并上传当前数据',
    });
    return '$_temp0';
  }

  @override
  String get account_noSnapshotsYet => '尚未存储任何快照';

  @override
  String account_failedToStore(String error) {
    return '无法存储：$error';
  }

  @override
  String account_syncKindRestored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': '设置已恢复',
      'geckoUserJs': 'Gecko 首选项已恢复',
      'other': '快照已恢复',
    });
    return '$_temp0';
  }

  @override
  String get account_snapshotNotFound => '找不到快照';

  @override
  String get account_decryptionFailed => '解密失败——密码错误或数据已损坏。请尝试重置同步密钥。';

  @override
  String account_failedToRestore(String error) {
    return '无法恢复：$error';
  }

  @override
  String account_failedUpdateLabel(String error) {
    return '无法更新标签：$error';
  }

  @override
  String get account_snapshotDeleted => '快照已删除';

  @override
  String account_failedToDelete(String error) {
    return '无法删除：$error';
  }

  @override
  String get account_untitledSnapshot => '无标题';

  @override
  String get account_metaLabel => '标签';

  @override
  String get account_metaStored => '存储时间';

  @override
  String get account_metaAppVersion => '应用版本';

  @override
  String get account_metaDevice => '设备';

  @override
  String get account_storeSnapshotTitle => '存储快照';

  @override
  String get account_fieldLabelOptional => '标签（可选）';

  @override
  String get account_labelHintExample => '例如“更新前”“家中设置”';

  @override
  String get account_fieldLabel => '标签';

  @override
  String get account_restoreSnapshotTitle => '恢复快照';

  @override
  String get account_restoreOverwriteWarning => '这将覆盖你当前的本地设置。';

  @override
  String get account_thisSnapshotFallback => '此快照';

  @override
  String get account_deleteSnapshotTitle => '删除快照';

  @override
  String account_deleteSnapshotConfirm(String label) {
    return '确定要删除$label吗？';
  }

  @override
  String get account_authNetworkError => '网络错误。请检查网络连接后重试。';

  @override
  String get account_authSessionExpiredWithKey =>
      '你保存的登录信息已失效。请重新登录以完成此账户的恢复——你的同步密钥仍会保留。';

  @override
  String get account_authSessionExpiredNoKey => '你保存的登录信息已失效。请重新登录以继续。';

  @override
  String get account_authRestoreFailedFallback => '无法恢复你的账户会话，稍后将自动重试。';

  @override
  String get account_authSignInTimedOut => '登录超时，请重试。';

  @override
  String get account_authSignInOpenPageFailed => '无法打开登录页面，请重试。';

  @override
  String get account_authNoPendingSignIn => '未找到进行中的登录。请重新开始登录。';

  @override
  String get account_authSignInVerificationFailed => '无法验证登录，请重试。';

  @override
  String get account_authSignInNotCompleted => '无法完成登录，请重试。';

  @override
  String get account_authSignInFailedFallback => '登录失败，请重试。';

  @override
  String get addons_managerTitle => '扩展';

  @override
  String get addons_tabInstalled => '已安装';

  @override
  String get addons_tabBrowse => '浏览';

  @override
  String get addons_loadFailedTitle => '无法加载扩展';

  @override
  String get addons_noExtensionsFound => '未找到扩展。';

  @override
  String get addons_noneInstalledMessage => '尚未安装任何扩展。\n去商店看看吧。';

  @override
  String get addons_genericTitle => '扩展';

  @override
  String get addons_notFound => '找不到此扩展。';

  @override
  String get addons_platformAndroid => 'Android';

  @override
  String get addons_platformDesktop => '桌面版';

  @override
  String get addons_searchHint => '搜索 addons.mozilla.org';

  @override
  String get addons_desktopCompatibilityWarning =>
      '桌面版扩展未针对移动设备进行审核。部分扩展在 Android 上可能无法使用、崩溃或出现异常行为。';

  @override
  String get addons_actionInstall => '安装';

  @override
  String get addons_actionInstallExtension => '安装扩展';

  @override
  String get addons_actionInstallFromFile => '从文件安装';

  @override
  String get addons_actionViewPermissions => '查看权限';

  @override
  String get addons_actionRemoveExtension => '移除扩展';

  @override
  String get addons_actionNotNow => '暂不';

  @override
  String get addons_actionUpdate => '更新';

  @override
  String get addons_actionCheckForUpdates => '检查更新';

  @override
  String get addons_actionCheckForUpdatesButton => '检查更新';

  @override
  String get addons_actionCheckingForUpdates => '正在检查更新';

  @override
  String get addons_actionLearnMore => '详细了解';

  @override
  String get addons_actionReadMore => '展开';

  @override
  String get addons_sectionEnabled => '已启用';

  @override
  String get addons_sectionDisabled => '已停用';

  @override
  String get addons_sectionUnsupported => '不支持';

  @override
  String get addons_sectionDetails => '详细信息';

  @override
  String get addons_sectionDescription => '描述';

  @override
  String get addons_sectionManagement => '管理';

  @override
  String get addons_sectionUpdates => '更新';

  @override
  String get addons_sectionAboutExtension => '关于此扩展';

  @override
  String get addons_sectionTechnicalPermissions => '技术权限';

  @override
  String get addons_sectionMoreInformation => '更多信息';

  @override
  String get addons_requiredDataCollectionTitle => '必需的数据收集';

  @override
  String get addons_tooltipRemoveExtension => '移除扩展';

  @override
  String addons_extensionRemoved(String name) {
    return '已移除 $name';
  }

  @override
  String addons_extensionInstalled(String name) {
    return '已安装 $name';
  }

  @override
  String addons_installFailed(String error) {
    return '安装失败：$error';
  }

  @override
  String get addons_updateChecksStarted => '已开始在后台检查已安装扩展的更新';

  @override
  String get addons_statusInstalled => '已安装';

  @override
  String get addons_statusDisabled => '已停用';

  @override
  String get addons_statusAvailable => '可安装';

  @override
  String get addons_chipPrivateBrowsing => '隐私浏览';

  @override
  String get addons_chipRecommended => '推荐';

  @override
  String get addons_removeConfirmTitle => '移除扩展？';

  @override
  String addons_removeConfirmContent(String name) {
    return '要从 WebLibre 中移除 $name 吗？';
  }

  @override
  String get addons_autoUpdateGloballyDisabled => '全局自动更新已关闭。';

  @override
  String get addons_autoUpdateNeedsManualRun => '需先手动更新一次并重启应用，才能启用自动更新。';

  @override
  String get addons_autoUpdateAllow => '允许此扩展在后台接收更新。';

  @override
  String get addons_autoUpdateDisabledForExtension => '此扩展的后台更新已关闭。';

  @override
  String get addons_switchEnabledTitle => '已启用';

  @override
  String get addons_switchEnabledSubtitleAllow => '允许此扩展在 WebLibre 中运行。';

  @override
  String get addons_switchEnabledSubtitleCannot => '无法安全地启用此扩展。';

  @override
  String get addons_switchPrivateBrowsingTitle => '在隐私浏览中允许';

  @override
  String get addons_switchPrivateBrowsingSubtitle => '允许此扩展在隐私浏览标签页中运行。';

  @override
  String get addons_switchAutoUpdateTitle => '自动更新';

  @override
  String get addons_switchPinTitle => '固定到工具栏';

  @override
  String get addons_switchPinSubtitle => '在主标签栏中以图标形式显示此扩展。';

  @override
  String get addons_menuExtensionSettingsTitle => '扩展设置';

  @override
  String get addons_menuExtensionSettingsSubtitleTab => '在浏览器标签页中打开扩展选项页面';

  @override
  String get addons_menuExtensionSettingsSubtitleInline => '打开扩展选项页面';

  @override
  String get addons_menuFilterListsTitle => '过滤规则列表与加固';

  @override
  String get addons_menuFilterListsSubtitle => '管理过滤规则列表并应用 WebLibre 加固';

  @override
  String get addons_permissionsTitle => '权限';

  @override
  String addons_updateAvailable(String from, String to) {
    return '有可用更新：$from → $to';
  }

  @override
  String get addons_noUpdateAttemptYet => '暂无最近的更新尝试信息。';

  @override
  String addons_lastChecked(String date) {
    return '上次检查：$date';
  }

  @override
  String get addons_noUpdateAvailable => '没有可用更新';

  @override
  String get addons_noRemoteUpdateSource => '此本地安装的扩展没有远程更新源。';

  @override
  String get addons_updateCheckFailed => '无法开始检查更新。';

  @override
  String get addons_updateAvailableDialogTitle => '有可用更新';

  @override
  String addons_updateConfirmContent(String name, String from, String to) {
    return '要将 $name 从 $from 更新到 $to 吗？';
  }

  @override
  String get addons_noDescriptionProvided => '未提供描述。';

  @override
  String get addons_loadingDescription => '正在加载描述…';

  @override
  String get addons_fieldAuthor => '作者';

  @override
  String get addons_fieldVersion => '版本';

  @override
  String get addons_fieldLastUpdated => '上次更新';

  @override
  String get addons_fieldLastUpdatedInfo => '上次更新';

  @override
  String get addons_fieldHomepage => '主页';

  @override
  String get addons_fieldAddonListing => '商店页面';

  @override
  String get addons_fieldSize => '大小';

  @override
  String get addons_fieldCategories => '分类';

  @override
  String get addons_fieldLicense => '许可证';

  @override
  String get addons_fieldSupportSite => '支持网站';

  @override
  String get addons_fieldReviews => '评价';

  @override
  String get addons_fieldPrivacyPolicy => '隐私政策';

  @override
  String get addons_linkViewOnAmo => '在 addons.mozilla.org 上查看';

  @override
  String get addons_settingsTitleGeneric => '扩展设置';

  @override
  String addons_settingsTitleNamed(String name) {
    return '$name 设置';
  }

  @override
  String addons_settingsLoadFailed(String error) {
    return '无法加载扩展设置：$error';
  }

  @override
  String get addons_noSettingsPage => '此扩展没有提供设置页面。';

  @override
  String get addons_permissionsTitleGeneric => '扩展权限';

  @override
  String addons_permissionsTitleNamed(String name) {
    return '$name 权限';
  }

  @override
  String addons_permissionsLoadFailed(String error) {
    return '无法加载扩展权限：$error';
  }

  @override
  String get addons_noSpecialPermissions => '未列出特殊权限';

  @override
  String get addons_noTranslatedPermissionDetails => '此扩展目前未提供任何经过翻译的权限说明。';

  @override
  String addons_versionSentence(String version) {
    return '版本 $version';
  }

  @override
  String addons_usersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 位用户',
    );
    return '$_temp0';
  }

  @override
  String addons_byAuthor(String name) {
    return '作者：$name';
  }

  @override
  String get addons_permGroupRequired => '必需';

  @override
  String get addons_permGroupWebsites => '网站';

  @override
  String get addons_permGroupOptional => '可选';

  @override
  String get addons_permGroupDataCollection => '数据收集';

  @override
  String get addons_dateUnknown => '未知';

  @override
  String get addons_statusUpdatedSuccessfully => '更新成功';

  @override
  String get addons_statusNotInstalled => '扩展未安装';

  @override
  String addons_updateFailedWithMessage(String message) {
    return '更新失败：$message';
  }

  @override
  String get addons_updateFailedGeneric => '更新失败';

  @override
  String get addons_noUpdateChecksRecorded => '尚无更新检查记录';

  @override
  String get addons_statusBlocklisted => '此扩展已被列入封禁列表，应保持停用。';

  @override
  String get addons_statusNotCorrectlySigned => '此扩展签名不正确，无法安全启用。';

  @override
  String get addons_statusIncompatible => '此扩展与当前应用版本不兼容。';

  @override
  String get addons_statusSoftBlockedEnabled => '此扩展已被软屏蔽。保持启用时请谨慎使用。';

  @override
  String get addons_statusSoftBlockedDisabled => '此扩展已被软屏蔽，但仍可重新启用。';

  @override
  String get addons_statusUnsupported => '此扩展已安装，但 WebLibre 目前不支持它。';

  @override
  String get addons_permissionBookmarks => '读取和修改书签';

  @override
  String get addons_permissionBrowserSettings => '读取和修改浏览器设置';

  @override
  String get addons_permissionBrowsingData => '清除最近的浏览历史、Cookie 及有关数据';

  @override
  String get addons_permissionClipboardRead => '获取剪贴板数据';

  @override
  String get addons_permissionClipboardWrite => '将数据写入剪贴板';

  @override
  String get addons_permissionContextualIdentities => '访问和修改容器标签页';

  @override
  String get addons_permissionCookies => '访问你访问过的网站的 Cookie';

  @override
  String get addons_permissionDownloads => '下载文件和读写浏览器的下载历史';

  @override
  String get addons_permissionDownloadsOpen => '打开下载至你设备的文件';

  @override
  String get addons_permissionFind => '读取所有已打开的标签页中的文本';

  @override
  String get addons_permissionGeolocation => '获知你的位置';

  @override
  String get addons_permissionHistory => '获取浏览历史';

  @override
  String get addons_permissionManagement => '监控扩展使用情况和管理主题';

  @override
  String get addons_permissionNativeMessaging => '与浏览器以外的程序交换消息';

  @override
  String get addons_permissionNotifications => '向你显示通知';

  @override
  String get addons_permissionPkcs11 => '提供密码学身份认证服务';

  @override
  String get addons_permissionPrivacy => '读取和修改隐私设置';

  @override
  String get addons_permissionProxy => '控制浏览器的代理设置';

  @override
  String get addons_permissionSessions => '获取最近关闭的标签页';

  @override
  String get addons_permissionTabs => '获取浏览器标签页';

  @override
  String get addons_permissionTabHide => '隐藏和显示浏览器标签页';

  @override
  String get addons_permissionTopSites => '获取浏览历史';

  @override
  String get addons_permissionWebNavigation => '访问浏览器导航期间的活动信息';

  @override
  String get addons_permissionAllUrls => '访问你在所有网站的数据';

  @override
  String addons_permissionAccessDataFor(String host) {
    return '访问你在 $host 的数据';
  }

  @override
  String appLinks_bannerTitleNamed(String appName) {
    return '在 $appName 中打开此链接？';
  }

  @override
  String get appLinks_bannerTitleGeneric => '在应用中打开此链接？';

  @override
  String appLinks_bannerRememberFor(String scope) {
    return '对 $scope 记住此选择';
  }

  @override
  String get appLinks_bannerStayInBrowser => '留在浏览器中';

  @override
  String get appLinks_bannerOpenApp => '打开应用';

  @override
  String appLinks_dialogTitleNamed(String appName) {
    return '在 $appName 中打开？';
  }

  @override
  String get appLinks_dialogTitleGeneric => '在其他应用中打开？';

  @override
  String get appLinks_dialogBody => '此链接由 WebLibre 以外的应用处理。';

  @override
  String appLinks_dialogRememberFor(String scope) {
    return '对 $scope 记住我的选择';
  }

  @override
  String get appLinks_warningProtectedContext =>
      '此链接在此处受到保护。该应用会建立自己的连接，不受此标签页所遵循的规则约束。';

  @override
  String get appLinks_warningPrivateTab => '这是隐私标签页。该应用会保留自己的历史记录和登录状态。';

  @override
  String get appLinks_warningWallet => '此链接会向钱包应用请求凭据。仅当请求由你发起时才打开。';

  @override
  String appLinks_settingsTitleWithContainer(String containerName) {
    return '应用链接 — $containerName';
  }

  @override
  String get appLinks_settingsTitleDefault => '容器应用链接';

  @override
  String get appLinks_settingsIntro => '这些设置仅适用于此容器，并将完全取代其标签页的全局应用链接设置。';

  @override
  String get appLinks_modeAlwaysTitle => '始终';

  @override
  String get appLinks_modeAlwaysSubtitle => '始终在原生应用中打开链接，不再询问';

  @override
  String get appLinks_modeAskTitle => '打开前询问';

  @override
  String get appLinks_modeAskSubtitle => '在应用中打开链接前显示提示';

  @override
  String get appLinks_modeNeverTitle => '从不';

  @override
  String get appLinks_modeNeverSubtitle => '始终在浏览器而非应用中打开链接';

  @override
  String get appLinks_rememberedRulesHeader => '已记住的网站规则';

  @override
  String get appLinks_ruleAlwaysOpenSubtitle => '始终在应用中打开';

  @override
  String get appLinks_ruleAlwaysKeepSubtitle => '始终留在浏览器中';

  @override
  String get appLinks_removeRuleTooltip => '移除规则';

  @override
  String get bangs_menuTitle => 'Bang 快捷搜索';

  @override
  String get bangs_menuManageUserBangs => '管理自定义 Bang';

  @override
  String get bangs_menuSearchBangs => '搜索 Bang';

  @override
  String get bangs_menuBrowseCategories => '浏览分类';

  @override
  String get bangs_categoriesTitle => 'Bang 分类';

  @override
  String get bangs_loadCategoriesFailedTitle => '无法加载 Bang 分类';

  @override
  String get bangs_loadBangsFailedTitle => '无法加载 Bang';

  @override
  String get bangs_searchHint => '搜索';

  @override
  String get bangs_searchFailedTitle => 'Bang 搜索失败';

  @override
  String get bangs_userBangsTitle => '自定义 Bang';

  @override
  String get bangs_deleteBangTitle => '删除 Bang';

  @override
  String get bangs_deleteBangConfirm => '确定要删除此 Bang 吗？';

  @override
  String get bangs_editTitleCustomize => '自定义 Bang';

  @override
  String get bangs_editTitleNew => '新建 Bang';

  @override
  String get bangs_editTitleEdit => '编辑 Bang';

  @override
  String bangs_triggerAlreadyExists(String trigger) {
    return '已存在触发词为“$trigger”的 Bang';
  }

  @override
  String get bangs_fieldNameLabel => '名称';

  @override
  String get bangs_fieldNameHelper => '与此 Bang 关联的网站名称';

  @override
  String get bangs_fieldTriggerLabel => '触发词';

  @override
  String get bangs_fieldTriggerHelper => '用于调用此 Bang 的特定触发词或短语。';

  @override
  String get bangs_fieldAdditionalTriggersLabel => '其他触发词';

  @override
  String get bangs_fieldAdditionalTriggersHelper =>
      '其他可调用此 Bang 的词，以逗号或空格分隔。开头的 ! 可省略。';

  @override
  String get bangs_fieldUrlLabel => '网址';

  @override
  String bangs_fieldUrlHelper(String token) {
    return '调用此 Bang 时使用的网址模板，其中 `$token` 会被替换为用户的搜索词。';
  }

  @override
  String bangs_fieldUrlMissingPlaceholder(String token) {
    return '必须包含搜索词占位符 $token';
  }

  @override
  String get bangs_fieldCategoryLabel => '分类';

  @override
  String get bangs_fieldSubCategoryLabel => '子分类';

  @override
  String get bangs_flagsLabel => '选项';

  @override
  String get bangs_flagOpenBasePathTitle => '打开根路径';

  @override
  String get bangs_flagOpenBasePathSubtitle =>
      '在不带搜索词调用 Bang 时，打开网址的根路径（/），而不是模板中的路径（例如 /search）';

  @override
  String get bangs_flagUrlEncodePlaceholderTitle => '对占位符进行 URL 编码';

  @override
  String get bangs_flagUrlEncodePlaceholderSubtitle =>
      '对搜索词进行 URL 编码。部分网站不支持编码后的搜索词，对于这些网站请关闭此选项。';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusTitle => '将空格编码为加号';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle =>
      '将空格编码为 + 而非 %20。部分网站要求使用其中一种格式。';

  @override
  String get bangs_tooltipOfficialSearch => 'WebLibre 官方搜索';

  @override
  String get bangs_tooltipCustomizeAsOwn => '自定义为你自己的 Bang';

  @override
  String get bangs_tooltipUnpin => '从搜索提供商中取消固定';

  @override
  String get bangs_tooltipPin => '固定到搜索提供商';

  @override
  String bangs_tooltipTriggers(String triggers) {
    return '触发词：$triggers';
  }

  @override
  String get browserActions_categoryNavigation => '导航';

  @override
  String get browserActions_categoryScrolling => '滚动';

  @override
  String get browserActions_categoryTabs => '标签页';

  @override
  String get browserActions_categoryPage => '页面';

  @override
  String get browserActions_categoryOpen => '打开';

  @override
  String get browserActions_categoryApp => '应用';

  @override
  String get browserActions_focusAddressBarTitle => '地址栏';

  @override
  String get browserActions_focusAddressBarDescription => '编辑地址或开始搜索';

  @override
  String get browserActions_backTitle => '后退';

  @override
  String get browserActions_backDescription => '在历史记录中后退';

  @override
  String get browserActions_forwardTitle => '前进';

  @override
  String get browserActions_forwardDescription => '在历史记录中前进';

  @override
  String get browserActions_reloadTitle => '重新加载';

  @override
  String get browserActions_reloadDescription => '重新加载当前页面';

  @override
  String get browserActions_hardReloadTitle => '强制重新加载';

  @override
  String get browserActions_hardReloadDescription => '跳过缓存，重新加载当前页面';

  @override
  String get browserActions_scrollTopTitle => '滚动到顶部';

  @override
  String get browserActions_scrollTopDescription => '跳到页面顶部';

  @override
  String get browserActions_scrollBottomTitle => '滚动到底部';

  @override
  String get browserActions_scrollBottomDescription => '跳到页面底部';

  @override
  String get browserActions_pageUpTitle => '向上翻页';

  @override
  String get browserActions_pageUpDescription => '向上滚动一屏';

  @override
  String get browserActions_pageDownTitle => '向下翻页';

  @override
  String get browserActions_pageDownDescription => '向下滚动一屏';

  @override
  String get browserActions_newTabTitle => '新建标签页';

  @override
  String get browserActions_newTabDescription => '打开新标签页';

  @override
  String get browserActions_newPrivateTabTitle => '新建隐私标签页';

  @override
  String get browserActions_newPrivateTabDescription => '打开新的隐私标签页';

  @override
  String get browserActions_closeTabTitle => '关闭标签页';

  @override
  String get browserActions_closeTabDescription => '关闭当前标签页';

  @override
  String get browserActions_reopenClosedTabTitle => '重新打开关闭的标签页';

  @override
  String get browserActions_reopenClosedTabDescription => '恢复最近关闭的标签页';

  @override
  String get browserActions_duplicateTabTitle => '复制标签页';

  @override
  String get browserActions_duplicateTabDescription => '打开当前标签页的副本';

  @override
  String get browserActions_nextTabTitle => '下一个标签页';

  @override
  String get browserActions_nextTabDescription => '切换到下一个标签页';

  @override
  String get browserActions_previousTabTitle => '上一个标签页';

  @override
  String get browserActions_previousTabDescription => '切换到上一个标签页';

  @override
  String get browserActions_lastUsedTabTitle => '上次使用的标签页';

  @override
  String get browserActions_lastUsedTabDescription => '切换到之前使用的标签页';

  @override
  String get browserActions_selectTab1Title => '标签页 1';

  @override
  String get browserActions_selectTab1Description => '切换到标签栏中的第一个标签页';

  @override
  String get browserActions_selectTab2Title => '标签页 2';

  @override
  String get browserActions_selectTab2Description => '切换到标签栏中的第二个标签页';

  @override
  String get browserActions_selectTab3Title => '标签页 3';

  @override
  String get browserActions_selectTab3Description => '切换到标签栏中的第三个标签页';

  @override
  String get browserActions_selectTab4Title => '标签页 4';

  @override
  String get browserActions_selectTab4Description => '切换到标签栏中的第四个标签页';

  @override
  String get browserActions_selectTab5Title => '标签页 5';

  @override
  String get browserActions_selectTab5Description => '切换到标签栏中的第五个标签页';

  @override
  String get browserActions_selectTab6Title => '标签页 6';

  @override
  String get browserActions_selectTab6Description => '切换到标签栏中的第六个标签页';

  @override
  String get browserActions_selectTab7Title => '标签页 7';

  @override
  String get browserActions_selectTab7Description => '切换到标签栏中的第七个标签页';

  @override
  String get browserActions_selectTab8Title => '标签页 8';

  @override
  String get browserActions_selectTab8Description => '切换到标签栏中的第八个标签页';

  @override
  String get browserActions_selectLastTabTitle => '最后一个标签页';

  @override
  String get browserActions_selectLastTabDescription => '切换到标签栏中的最后一个标签页';

  @override
  String get browserActions_togglePinTabTitle => '固定/取消固定标签页';

  @override
  String get browserActions_togglePinTabDescription => '切换当前标签页的固定状态';

  @override
  String get browserActions_moveTabBackwardTitle => '标签页前移';

  @override
  String get browserActions_moveTabBackwardDescription => '将当前标签页向标签栏开头移动一位';

  @override
  String get browserActions_moveTabForwardTitle => '标签页后移';

  @override
  String get browserActions_moveTabForwardDescription => '将当前标签页向标签栏末尾移动一位';

  @override
  String get browserActions_moveTabToStartTitle => '标签页移到开头';

  @override
  String get browserActions_moveTabToStartDescription =>
      '将当前标签页移到其在标签栏中所在分组的开头';

  @override
  String get browserActions_moveTabToEndTitle => '标签页移到末尾';

  @override
  String get browserActions_moveTabToEndDescription => '将当前标签页移到其在标签栏中所在分组的末尾';

  @override
  String get browserActions_nextContainerTitle => '下一个容器';

  @override
  String get browserActions_nextContainerDescription => '切换到下一个容器及其上次使用的标签页';

  @override
  String get browserActions_previousContainerTitle => '上一个容器';

  @override
  String get browserActions_previousContainerDescription =>
      '切换到上一个容器及其上次使用的标签页';

  @override
  String get browserActions_toggleReaderModeTitle => '阅读模式';

  @override
  String get browserActions_toggleReaderModeDescription => '切换当前页面的阅读模式';

  @override
  String get browserActions_toggleDesktopModeTitle => '桌面版网站';

  @override
  String get browserActions_toggleDesktopModeDescription => '切换当前页面的桌面模式';

  @override
  String get browserActions_findInPageTitle => '在页面中查找';

  @override
  String get browserActions_findInPageDescription => '打开页面内查找';

  @override
  String get browserActions_findNextTitle => '查找下一个';

  @override
  String get browserActions_findNextDescription => '跳到上次搜索的下一个匹配项';

  @override
  String get browserActions_findPreviousTitle => '查找上一个';

  @override
  String get browserActions_findPreviousDescription => '跳到上次搜索的上一个匹配项';

  @override
  String get browserActions_increaseFontSizeTitle => '增大字号';

  @override
  String get browserActions_increaseFontSizeDescription => '增大页面字号';

  @override
  String get browserActions_decreaseFontSizeTitle => '减小字号';

  @override
  String get browserActions_decreaseFontSizeDescription => '减小页面字号';

  @override
  String get browserActions_resetFontSizeTitle => '重置字号';

  @override
  String get browserActions_resetFontSizeDescription => '恢复默认的页面字号';

  @override
  String get browserActions_toggleBookmarkTitle => '书签';

  @override
  String get browserActions_toggleBookmarkDescription => '将当前页面加入书签或移除书签';

  @override
  String get browserActions_sharePageTitle => '分享';

  @override
  String get browserActions_sharePageDescription => '分享当前页面';

  @override
  String get browserActions_translatePageTitle => '翻译';

  @override
  String get browserActions_translatePageDescription => '打开页面翻译面板';

  @override
  String get browserActions_printPageTitle => '打印';

  @override
  String get browserActions_printPageDescription => '打印当前页面';

  @override
  String get browserActions_showHomeTitle => '主页';

  @override
  String get browserActions_showHomeDescription => '打开主页';

  @override
  String get browserActions_showHistoryTitle => '历史记录';

  @override
  String get browserActions_showHistoryDescription => '打开浏览历史记录';

  @override
  String get browserActions_showBookmarksTitle => '书签';

  @override
  String get browserActions_showBookmarksDescription => '打开书签';

  @override
  String get browserActions_showContainersTitle => '容器';

  @override
  String get browserActions_showContainersDescription => '打开容器列表';

  @override
  String get browserActions_showTabViewTitle => '标签页视图';

  @override
  String get browserActions_showTabViewDescription => '打开标签页概览';

  @override
  String get browserActions_showDownloadsTitle => '下载';

  @override
  String get browserActions_showDownloadsDescription => '打开下载';

  @override
  String get browserActions_showAddonsTitle => '附加组件';

  @override
  String get browserActions_showAddonsDescription => '管理扩展';

  @override
  String get browserActions_openSettingsTitle => '设置';

  @override
  String get browserActions_openSettingsDescription => '打开设置';

  @override
  String get browserActions_showKeyboardShortcutsTitle => '键盘快捷键';

  @override
  String get browserActions_showKeyboardShortcutsDescription => '列出执行浏览器操作的按键';

  @override
  String get browserActions_toggleTabBarTitle => '隐藏/显示标签栏';

  @override
  String get browserActions_toggleTabBarDescription => '隐藏标签栏，或重新显示';

  @override
  String get browserActions_clearBrowsingDataTitle => '清除浏览数据';

  @override
  String get browserActions_clearBrowsingDataDescription => '选择要删除的浏览数据';

  @override
  String get browserActions_moveToBackgroundTitle => '最小化';

  @override
  String get browserActions_moveToBackgroundDescription => '将 WebLibre 转到后台';

  @override
  String get browserActions_quitBrowserTitle => '退出';

  @override
  String get browserActions_quitBrowserDescription => '关闭所有标签页并退出 WebLibre';

  @override
  String get browserActions_categoryCreate => '新建';

  @override
  String get browserActions_openInPrivateTabTitle => '在隐私标签页中打开';

  @override
  String get browserActions_openInPrivateTabDescription => '在新的隐私标签页中打开当前页面';

  @override
  String get browserActions_moveTabToContainerTitle => '移到容器';

  @override
  String get browserActions_moveTabToContainerDescription => '将当前标签页移到其他容器';

  @override
  String get browserActions_copyLinkTitle => '复制链接';

  @override
  String get browserActions_copyLinkDescription => '复制当前页面的地址';

  @override
  String get browserActions_siteSettingsTitle => '网站设置';

  @override
  String get browserActions_siteSettingsDescription => '此网站的权限和跟踪保护';

  @override
  String get browserActions_addToHomeScreenTitle => '添加到主屏幕';

  @override
  String get browserActions_addToHomeScreenDescription => '将当前网站安装为应用或快捷方式';

  @override
  String get browserActions_subscribeToPageFeedTitle => '订阅此页面';

  @override
  String get browserActions_subscribeToPageFeedDescription => '查找并关注当前页面的订阅源';

  @override
  String get browserActions_showFeedsTitle => '订阅源';

  @override
  String get browserActions_showFeedsDescription => '打开你的订阅源';

  @override
  String get browserActions_showProfilesTitle => '配置文件';

  @override
  String get browserActions_showProfilesDescription => '管理你的配置文件';

  @override
  String get browserActions_showProxySettingsTitle => '代理';

  @override
  String get browserActions_showProxySettingsDescription => '打开代理设置';

  @override
  String get browserActions_showTorTitle => 'Tor';

  @override
  String get browserActions_showTorDescription => '打开 Tor 设置';

  @override
  String get browserActions_showSyncSettingsTitle => '同步';

  @override
  String get browserActions_showSyncSettingsDescription => '打开同步设置';

  @override
  String get browserActions_showContentBlockerListsTitle => '过滤规则列表';

  @override
  String get browserActions_showContentBlockerListsDescription =>
      '管理内容拦截器的过滤规则列表';

  @override
  String get browserActions_showErrorLogsTitle => '错误日志';

  @override
  String get browserActions_showErrorLogsDescription => '查看应用的错误日志';

  @override
  String get browserActions_showAboutTitle => '关于';

  @override
  String get browserActions_showAboutDescription => '关于 WebLibre';

  @override
  String get browserActions_newContainerTitle => '新建容器';

  @override
  String get browserActions_newContainerDescription => '创建容器';

  @override
  String get browserActions_newBookmarkFolderTitle => '新建书签文件夹';

  @override
  String get browserActions_newBookmarkFolderDescription => '创建书签文件夹';

  @override
  String get browserActions_addFeedTitle => '添加订阅源';

  @override
  String get browserActions_addFeedDescription => '通过网址添加订阅源';

  @override
  String get browserActions_newSearchEngineTitle => '新建搜索快捷方式';

  @override
  String get browserActions_newSearchEngineDescription => '创建你自己的 Bang 搜索快捷方式';

  @override
  String get browserActions_newProfileTitle => '新建配置文件';

  @override
  String get browserActions_newProfileDescription => '创建浏览器配置文件';

  @override
  String get browserActions_newProxyProfileTitle => '新建代理配置';

  @override
  String get browserActions_newProxyProfileDescription => '添加代理服务器';

  @override
  String get browserActions_backupProfileTitle => '备份配置文件';

  @override
  String get browserActions_backupProfileDescription => '创建当前配置文件的备份';

  @override
  String get browserActions_toggleBookmarkKeywords => '收藏,收藏夹,保存页面,星标';

  @override
  String get browserActions_findInPageKeywords => '页内搜索,搜索文本,查找文本';

  @override
  String get browserActions_copyLinkKeywords => '复制网址,复制地址,剪贴板';

  @override
  String get browserActions_sharePageKeywords => '发送,分享链接,发送到';

  @override
  String get browserActions_toggleReaderModeKeywords => '阅读视图,阅读模式,文章,简化页面';

  @override
  String get browserActions_toggleDesktopModeKeywords =>
      '桌面版,请求桌面版网站,电脑版,移动版网站,user agent,用户代理';

  @override
  String get browserActions_translatePageKeywords => '翻译,语言,译者';

  @override
  String get browserActions_siteSettingsKeywords =>
      '权限,Cookie,跟踪保护,相机,麦克风,位置,网站信息';

  @override
  String get browserActions_addToHomeScreenKeywords =>
      'pwa,安装,网页应用,快捷方式,桌面图标,应用';

  @override
  String get browserActions_subscribeToPageFeedKeywords =>
      'rss,atom,订阅源,订阅,关注,新闻';

  @override
  String get browserActions_printPageKeywords => 'pdf,另存为 pdf,打印机';

  @override
  String get browserActions_increaseFontSizeKeywords => '放大,更大的文字,更大的字体,文字大小';

  @override
  String get browserActions_decreaseFontSizeKeywords => '缩小,更小的文字,更小的字体,文字大小';

  @override
  String get browserActions_resetFontSizeKeywords => '默认文字大小,重置缩放,文字大小';

  @override
  String get browserActions_openInPrivateTabKeywords => '无痕,隐私浏览,隐私模式';

  @override
  String get browserActions_moveTabToContainerKeywords => '分配容器,身份,标签页分组';

  @override
  String get browserActions_duplicateTabKeywords => '克隆标签页,复制标签页';

  @override
  String get browserActions_togglePinTabKeywords => '固定标签页,取消固定,置顶';

  @override
  String get browserActions_closeTabKeywords => '关闭,移除标签页';

  @override
  String get browserActions_reopenClosedTabKeywords => '撤销关闭,恢复标签页,最近关闭';

  @override
  String get browserActions_showHistoryKeywords => '访问过的页面,浏览历史,最近访问';

  @override
  String get browserActions_showBookmarksKeywords => '收藏夹,已保存的页面,书签管理器';

  @override
  String get browserActions_showDownloadsKeywords => '已下载的文件,文件,下载管理器';

  @override
  String get browserActions_showTabViewKeywords => '标签页概览,所有标签页,标签页切换器,打开的标签页';

  @override
  String get browserActions_showContainersKeywords => '身份,容器列表,工作区';

  @override
  String get browserActions_showFeedsKeywords => 'rss,atom,新闻,订阅';

  @override
  String get browserActions_showProfilesKeywords => '用户,账户,切换配置文件';

  @override
  String get browserActions_showProxySettingsKeywords =>
      'vpn,sing-box,socks,连接,网络,翻墙';

  @override
  String get browserActions_showTorKeywords => '洋葱,匿名,网桥,匿名性,onion';

  @override
  String get browserActions_showSyncSettingsKeywords => '账户,同步,设备';

  @override
  String get browserActions_showAddonsKeywords => '扩展,插件,附加组件,webextensions';

  @override
  String get browserActions_showContentBlockerListsKeywords =>
      'ublock,adblock,广告拦截,过滤器,屏蔽列表';

  @override
  String get browserActions_openSettingsKeywords => '首选项,选项,配置';

  @override
  String get browserActions_showKeyboardShortcutsKeywords => '热键,按键绑定,按键';

  @override
  String get browserActions_showErrorLogsKeywords => '日志,调试,崩溃,错误报告';

  @override
  String get browserActions_showAboutKeywords => '版本,许可证,信息';

  @override
  String get browserActions_newContainerKeywords => '添加容器,创建身份,工作区';

  @override
  String get browserActions_newBookmarkFolderKeywords => '添加文件夹,创建文件夹,整理书签';

  @override
  String get browserActions_addFeedKeywords => 'rss,atom,订阅,添加订阅';

  @override
  String get browserActions_newSearchEngineKeywords =>
      'bang,自定义搜索,添加搜索引擎,搜索快捷方式';

  @override
  String get browserActions_newProfileKeywords => '添加用户,创建配置文件,新账户';

  @override
  String get browserActions_newProxyProfileKeywords =>
      '添加代理,vpn,服务器,sing-box,socks,节点';

  @override
  String get browserActions_backupProfileKeywords => '备份,导出,保存数据,存档';

  @override
  String get browserActions_clearBrowsingDataKeywords =>
      '删除历史记录,清除缓存,Cookie,擦除,清空,隐私';

  @override
  String get bookmarks_title => '书签';

  @override
  String get bookmarks_filterHint => '筛选书签…';

  @override
  String get bookmarks_emptyFolder => '空';

  @override
  String get bookmarks_searchHiddenByFoldersOnly => '有匹配的书签被“仅显示文件夹”隐藏';

  @override
  String bookmarks_noSearchMatches(String query) {
    return '没有与“$query”匹配的书签';
  }

  @override
  String get bookmarks_loadFailedTitle => '无法加载书签';

  @override
  String get bookmarks_loadFoldersFailedTitle => '无法加载书签文件夹';

  @override
  String get bookmarks_folderLabel => '文件夹';

  @override
  String get bookmarks_unnamedFolder => '未命名文件夹';

  @override
  String bookmarks_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选择 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_tooltipOpenInBackground => '在后台打开';

  @override
  String get bookmarks_tooltipMoveSelected => '移动所选项';

  @override
  String get bookmarks_tooltipDeleteSelected => '删除所选项';

  @override
  String get bookmarks_tooltipClearSearch => '清除搜索';

  @override
  String get bookmarks_tooltipSearchBookmarks => '搜索书签';

  @override
  String get bookmarks_tooltipCollapse => '折叠';

  @override
  String get bookmarks_tooltipExpand => '展开';

  @override
  String get bookmarks_menuAddBookmarkHere => '在此处添加书签';

  @override
  String get bookmarks_menuAddSubfolderHere => '在此处添加子文件夹';

  @override
  String get bookmarks_menuCollapseAll => '全部折叠';

  @override
  String get bookmarks_menuShowEmptyFolders => '显示空文件夹';

  @override
  String get bookmarks_menuHideEmptyFolders => '隐藏空文件夹';

  @override
  String get bookmarks_menuShowBookmarks => '显示书签';

  @override
  String get bookmarks_menuFoldersOnly => '仅显示文件夹';

  @override
  String get bookmarks_menuVisibility => '显示内容';

  @override
  String get bookmarks_menuSort => '排序';

  @override
  String get bookmarks_menuImport => '导入';

  @override
  String get bookmarks_menuExport => '导出';

  @override
  String get bookmarks_formatJson => 'JSON';

  @override
  String get bookmarks_formatHtml => 'HTML';

  @override
  String get bookmarks_actionOpenInNewTab => '在新标签页中打开';

  @override
  String get bookmarks_actionOpenInBackground => '在后台打开';

  @override
  String get bookmarks_actionShare => '分享';

  @override
  String get bookmarks_actionMove => '移动';

  @override
  String get bookmarks_actionFlatten => '展开到上级';

  @override
  String get bookmarks_actionAddSubfolder => '添加子文件夹';

  @override
  String get bookmarks_actionAddBookmark => '添加书签';

  @override
  String get bookmarks_actionMerge => '合并';

  @override
  String get bookmarks_actionReplace => '替换';

  @override
  String get bookmarks_noEntriesSelected => '未选择任何书签';

  @override
  String bookmarks_openedTabsInBackground(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已在后台打开 $count 个标签页',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_movedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移动 $count 项',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_deletedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importFailedToReadFile => '无法读取文件';

  @override
  String bookmarks_importSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已成功导入 $count 个书签',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_importFailedWithError(String error) {
    return '导入失败：$error';
  }

  @override
  String get bookmarks_exportDialogTitle => '导出书签';

  @override
  String get bookmarks_exportSuccess => '书签导出成功';

  @override
  String bookmarks_exportFailedWithError(String error) {
    return '导出失败：$error';
  }

  @override
  String get bookmarks_sortDefault => '默认';

  @override
  String get bookmarks_sortTitleAsc => '标题 A-Z';

  @override
  String get bookmarks_sortTitleDesc => '标题 Z-A';

  @override
  String get bookmarks_sortUrlAsc => '网址 A-Z';

  @override
  String get bookmarks_sortUrlDesc => '网址 Z-A';

  @override
  String get bookmarks_sortDateAddedDesc => '最新优先';

  @override
  String get bookmarks_sortDateAddedAsc => '最早优先';

  @override
  String get bookmarks_deleteBookmarkTitle => '删除书签';

  @override
  String get bookmarks_deleteBookmarkContent => '确定要删除此书签吗？';

  @override
  String get bookmarks_deleteFolderTitle => '删除文件夹';

  @override
  String get bookmarks_deleteFolderConfirmUnknown => '确定要删除此文件夹及其中的所有书签吗？';

  @override
  String bookmarks_deleteFolderConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '确定要删除此文件夹及其中的 $count 个书签吗？',
      zero: '确定要删除此文件夹吗？',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importDialogTitle => '导入书签';

  @override
  String get bookmarks_importDialogContent =>
      '导入前是否要清除所有现有书签？\n\n选择“替换”将删除现有书签，选择“合并”则保留它们。';

  @override
  String get bookmarks_importProgressTitle => '正在导入书签';

  @override
  String get bookmarks_importPhaseParsing => '正在读取文件…';

  @override
  String get bookmarks_importPhaseErasing => '正在移除现有书签…';

  @override
  String bookmarks_importPhaseInsertingProgress(int inserted, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$inserted / $total 个书签',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importPhaseInsertingIndeterminate => '正在保存书签…';

  @override
  String get bookmarks_moveToFolderTitle => '移动到文件夹';

  @override
  String get bookmarks_editBookmarkTitle => '编辑书签';

  @override
  String get bookmarks_createBookmarkTitle => '新建书签';

  @override
  String get bookmarks_editFolderTitle => '编辑文件夹';

  @override
  String get bookmarks_createFolderTitle => '新建文件夹';

  @override
  String get bookmarks_fieldNameLabel => '名称';

  @override
  String get bookmarks_fieldUrlLabel => '网址';

  @override
  String get bookmarks_addToTop => '添加到顶部';

  @override
  String get browser_actionSelect => '选择';

  @override
  String get browser_actionKeep => '保留';

  @override
  String get browser_actionInstall => '安装';

  @override
  String get browser_bookmarkAllTitle => '将所有标签页加入书签';

  @override
  String get browser_bookmarkAllFastTitle => '快速';

  @override
  String get browser_bookmarkAllFastSubtitle => '自动将所有标签页添加到所选文件夹';

  @override
  String get browser_bookmarkAllDetailedTitle => '详细';

  @override
  String get browser_bookmarkAllDetailedSubtitle => '逐个检查和编辑每个书签';

  @override
  String get browser_clearSiteDataTitle => '清除网站数据';

  @override
  String browser_clearSiteDataContent(String formattedTypes, String host) {
    return '这将清除 $host 的以下数据：\n$formattedTypes\n\n你可能需要重新登录。';
  }

  @override
  String get browser_contentSelectionExtractedTitle => '提取的内容';

  @override
  String get browser_contentSelectionExtractedSubtitle => '为阅读优化的内容，不含导航和广告';

  @override
  String get browser_contentSelectionFullTitle => '完整内容';

  @override
  String get browser_contentSelectionFullSubtitle => '包含所有元素和结构的完整页面';

  @override
  String get browser_deleteDataTitle => '删除浏览数据';

  @override
  String get browser_installAddonSheetTitle => '从文件安装扩展';

  @override
  String get browser_installAddonSelectFileButton => '选择 XPI 文件';

  @override
  String get browser_installAddonNoFileSelected => '未选择文件';

  @override
  String get browser_installAddonPinnedNotice => '从本地 XPI 安装的扩展将固定为该版本，不会自动更新。';

  @override
  String get browser_installAddonNotXpiError => '请选择 .xpi 文件';

  @override
  String browser_installAddonPickFileFailed(String error) {
    return '无法选择文件：$error';
  }

  @override
  String get browser_installAddonInstalledMessage => '扩展已安装。此本地版本的自动更新已关闭。';

  @override
  String get browser_installAddonNotSignedError =>
      '此扩展未经 Mozilla 签名。请在扩展设置中启用“允许未签名的扩展”后再安装。';

  @override
  String browser_installAddonInstallFailed(String error) {
    return '安装失败：$error';
  }

  @override
  String get browser_keepTabTitle => '保留标签页？';

  @override
  String get browser_keepTabContent => '要保留还是舍弃此标签页？';

  @override
  String get browser_qrCodeTitle => '分享二维码';

  @override
  String get browser_selectFolderTitle => '选择文件夹';

  @override
  String get browser_tabTreeCurrentTabNotInTree => '当前标签页不属于此树';

  @override
  String get browser_menuManageExtensions => '管理扩展';

  @override
  String get browser_menuAddRegularTab => '新建普通标签页';

  @override
  String get browser_menuAddChildTab => '新建子标签页';

  @override
  String get browser_menuAddPrivateTab => '新建隐私标签页';

  @override
  String get browser_menuAddIsolatedTab => '新建隔离标签页';

  @override
  String get browser_fontSizeTitle => '文字大小';

  @override
  String get browser_fontSizeAutomaticNotice => '已启用自动字号。请在设置中关闭后再手动调整。';

  @override
  String get browser_fontSizeResetButton => '重置为 100%';

  @override
  String get browser_historyNoPreviousPages => '没有之前的页面';

  @override
  String get browser_historyNoForwardPages => '没有可前进的页面';

  @override
  String get browser_certSandboxedCaptureTitle => '沙盒捕获';

  @override
  String get browser_certSandboxedCaptureSubtitle => '此页面来自离线存档——没有实时连接。';

  @override
  String get browser_certConnectionNotSecure => '连接不安全';

  @override
  String get browser_certConnectionSecure => '连接安全';

  @override
  String browser_certVerifiedBy(String issuer) {
    return '验证者：$issuer';
  }

  @override
  String get browser_containerFallbackName => '容器';

  @override
  String get browser_actionEnable => '启用';

  @override
  String get browser_closeAllPrivateTabsTitle => '关闭所有隐私标签页';

  @override
  String get browser_closeAllPrivateTabsContent => '确定要关闭所有显示的隐私标签页吗？';

  @override
  String get browser_closeAllTabsTitle => '关闭所有标签页';

  @override
  String get browser_closeAllTabsContent => '确定要关闭所有显示的标签页吗？';

  @override
  String get browser_enableAiTabSuggestionsTitle => '启用 AI 标签页建议';

  @override
  String get browser_enableAiTabSuggestionsContent =>
      '启用此功能可能需要下载 AI 模型。下载大小和进度无法事先确定。\n\n要继续吗？';

  @override
  String get browser_tooltipExpandGroup => '展开分组';

  @override
  String get browser_tooltipCollapseGroup => '折叠分组';

  @override
  String browser_tabGroupSizeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '包含 $count 个标签页的分组',
    );
    return '$_temp0';
  }

  @override
  String get browser_searchOrEnterUrl => '搜索或输入网址';

  @override
  String get browser_tabCannotBeMovedHere => '无法将标签页移动到此处';

  @override
  String get browser_quickActionNewTab => '新建标签页';

  @override
  String get browser_quickActionNewPrivateTab => '新建隐私标签页';

  @override
  String get browser_quickActionNewIsolatedTab => '新建隔离标签页';

  @override
  String get browser_shareLink => '分享链接';

  @override
  String get browser_showQrCode => '显示二维码';

  @override
  String get browser_exportAsPdf => '导出为 PDF';

  @override
  String get browser_failedToPrintPage => '无法打印页面';

  @override
  String get browser_print => '打印';

  @override
  String get browser_shareScreenshot => '分享截图';

  @override
  String get browser_exportAsPng => '导出为 PNG';

  @override
  String browser_openInNamedApp(String appName) {
    return '在 $appName 中打开';
  }

  @override
  String get browser_openInApp => '在应用中打开';

  @override
  String get browser_copyAddress => '复制地址';

  @override
  String get browser_noTargetDevices => '没有目标设备';

  @override
  String browser_sentTabToDevice(String deviceName) {
    return '已将标签页发送到 $deviceName';
  }

  @override
  String get browser_failedToSendTab => '无法发送标签页';

  @override
  String get browser_loadingDevices => '正在加载设备…';

  @override
  String get browser_failedToLoadDevices => '无法加载设备';

  @override
  String get browser_sendToDevice => '发送到设备';

  @override
  String get browser_containerMenuNewTab => '新建标签页';

  @override
  String get browser_unpinContainer => '取消固定容器';

  @override
  String get browser_pinContainer => '固定容器';

  @override
  String get browser_closeSubmenuAllTabs => '所有标签页';

  @override
  String get browser_closeSubmenuPrivateTabs => '隐私标签页';

  @override
  String get browser_closeSubmenuIsolatedTabs => '隔离标签页';

  @override
  String get browser_closeSubmenuFilteredTabs => '筛选出的标签页';

  @override
  String get browser_menuCloseTabs => '关闭标签页';

  @override
  String get browser_menuBookmarkAll => '全部加入书签';

  @override
  String get browser_menuAssignedSites => '已分配的网站…';

  @override
  String get browser_menuClearContainerData => '清除容器数据';

  @override
  String get browser_menuEditContainer => '编辑容器…';

  @override
  String get browser_menuDeleteContainer => '删除容器';

  @override
  String browser_bookmarksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 个书签',
    );
    return '$_temp0';
  }

  @override
  String get browser_containerDataClearedSuccess => '容器数据已成功清除';

  @override
  String browser_containerDataClearedWithTabsClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '容器数据已清除，已关闭 $count 个标签页。',
    );
    return '$_temp0';
  }

  @override
  String browser_errorClearingData(String error) {
    return '清除数据时出错：$error';
  }

  @override
  String get browser_appLinksSectionTitle => '应用链接';

  @override
  String get browser_openLinksForThisSite => '此网站的链接打开方式';

  @override
  String get browser_followsTheDefault => '跟随默认设置';

  @override
  String get browser_followDefault => '跟随默认设置';

  @override
  String get browser_openInAppOption => '在应用中打开';

  @override
  String get browser_keepInBrowser => '留在浏览器中';

  @override
  String get browser_noAppFoundForSite => '未找到可处理此网站的应用';

  @override
  String browser_alwaysOpensInApp(String appName) {
    return '始终在 $appName 中打开';
  }

  @override
  String get browser_theAppFallback => '该应用';

  @override
  String get browser_alwaysStaysInBrowser => '始终留在浏览器中';

  @override
  String get browser_followsDefaultOpensInApps => '跟随默认设置：在应用中打开';

  @override
  String get browser_followsDefaultNoAppFound => '跟随默认设置：未找到应用';

  @override
  String get browser_followsDefaultAsksFirst => '跟随默认设置：先询问';

  @override
  String get browser_followsDefaultStaysInBrowser => '跟随默认设置：留在浏览器中';

  @override
  String get browser_selectDataTypesToClear => '选择要清除的数据类型';

  @override
  String get browser_cookiesCacheAndSiteData => 'Cookie、缓存和网站数据';

  @override
  String get browser_dataTypeAuthSessions => '登录会话';

  @override
  String get browser_dataTypeAuthSessionsSubtitle => '已保存的登录信息、活动会话';

  @override
  String get browser_dataTypeSiteData => '网站数据';

  @override
  String get browser_dataTypeSiteDataSubtitle => '离线存储、数据库、本地文件';

  @override
  String get browser_dataTypeCookies => 'Cookie';

  @override
  String get browser_dataTypeCookiesSubtitle => '登录令牌、偏好设置、跟踪数据';

  @override
  String get browser_dataTypeCachedFiles => '缓存文件';

  @override
  String get browser_dataTypeCachedFilesSubtitle => '图片、脚本、样式表';

  @override
  String get browser_closeTabAfterClearing => '清除后关闭标签页';

  @override
  String get browser_closeTabAfterClearingSubtitle => '数据清除后关闭此标签页';

  @override
  String get browser_clearingEllipsis => '正在清除…';

  @override
  String get browser_clearNow => '立即清除';

  @override
  String get browser_selectAtLeastOneDataType => '请至少选择一种数据类型';

  @override
  String get browser_siteDataCleared => '网站数据已清除';

  @override
  String browser_failedToClearSiteData(String error) {
    return '无法清除网站数据：$error';
  }

  @override
  String get browser_alwaysUseDesktopSite => '始终使用桌面版网站';

  @override
  String get browser_unavailableOnThisPage => '在此页面上不可用';

  @override
  String browser_setByRuleFor(String host) {
    return '由针对 $host 的规则设置';
  }

  @override
  String get browser_siteAlwaysLoadsInDesktopMode => '此网站始终以桌面模式加载';

  @override
  String get browser_siteFollowsDefaultMode => '此网站使用默认模式';

  @override
  String browser_failedToToggleDesktopMode(String error) {
    return '无法切换桌面模式：$error';
  }

  @override
  String get browser_gesturesTitle => '手势';

  @override
  String get browser_gesturesTurnedOffGlobally => '手势已全局关闭';

  @override
  String get browser_gesturesUnavailableOnThisPage => '手势在此页面上不可用';

  @override
  String browser_gesturesDisabledByRuleFor(String host) {
    return '已被针对 $host 的规则停用';
  }

  @override
  String get browser_gesturesDisabledOnThisSite => '此网站上的手势已停用';

  @override
  String get browser_gesturesEnabledOnThisSite => '此网站上的手势已启用';

  @override
  String browser_failedToToggleGestures(String error) {
    return '无法切换手势：$error';
  }

  @override
  String browser_errorLoadingPermissions(String error) {
    return '加载权限时出错：$error';
  }

  @override
  String get browser_permissionsSectionTitle => '权限';

  @override
  String get browser_showAll => '显示全部';

  @override
  String get browser_noPermissionsSetForSite => '此网站未设置任何权限';

  @override
  String get browser_permissionAsk => '询问';

  @override
  String get browser_permissionAllow => '允许';

  @override
  String get browser_permissionBlock => '阻止';

  @override
  String get browser_autoplayTitle => '自动播放';

  @override
  String get browser_autoplayAllowAll => '全部允许';

  @override
  String get browser_autoplayBlockAudible => '阻止有声媒体';

  @override
  String get browser_autoplayBlockAll => '全部阻止';

  @override
  String get browser_failedToLoadTrackingProtection => '无法加载跟踪保护';

  @override
  String get browser_enhancedTrackingProtection => '增强型跟踪保护';

  @override
  String get browser_trackersBeingBlocked => '此网站上的跟踪器正被拦截';

  @override
  String get browser_trackersAllowed => '此网站上的跟踪器已被允许';

  @override
  String browser_failedToToggleTrackingProtection(String error) {
    return '无法切换跟踪保护：$error';
  }

  @override
  String get browser_resizeSidePanel => '调整侧边面板大小';

  @override
  String get browser_unassignedContainerLabel => '未分配';

  @override
  String get browser_tooltipCloseTab => '关闭标签页';

  @override
  String get browser_urlCleaned => '网址已清理';

  @override
  String get browser_urlPreviewApplied => '已应用网址预览';

  @override
  String browser_trackingParametersDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '检测到 $count 个跟踪参数',
    );
    return '$_temp0';
  }

  @override
  String get browser_linkIsClean => '链接无需清理';

  @override
  String get browser_removeTrackingTooltip => '移除跟踪';

  @override
  String get browser_menuFindInPage => '在页面中查找';

  @override
  String get browser_menuReaderMode => '阅读模式';

  @override
  String get browser_menuFetchFeedsOnPage => '获取页面上的订阅源';

  @override
  String get browser_menuAddBookmark => '添加书签';

  @override
  String get browser_cloneRegular => '普通';

  @override
  String get browser_clonePrivate => '隐私';

  @override
  String get browser_cloneIsolated => '隔离';

  @override
  String get browser_menuCloneTab => '复制标签页';

  @override
  String get browser_menuAssignContainer => '分配容器';

  @override
  String get browser_menuUrlRelation => '网址关联';

  @override
  String get browser_menuUnassignUrlRelation => '取消网址关联';

  @override
  String get browser_menuUnassignContainer => '取消容器分配';

  @override
  String get browser_menuContainerSubmenu => '容器';

  @override
  String get browser_menuMoveUp => '上移';

  @override
  String get browser_menuMoveDown => '下移';

  @override
  String get browser_menuReorder => '调整顺序';

  @override
  String get browser_menuShare => '分享';

  @override
  String get browser_menuCopyAsMarkdown => '复制为 Markdown';

  @override
  String get browser_markdownCopiedToClipboard => 'Markdown 已复制到剪贴板';

  @override
  String get browser_menuExportAsMarkdown => '导出为 Markdown';

  @override
  String get browser_menuExportSubmenu => '导出';

  @override
  String get browser_menuCloseTab => '关闭标签页';

  @override
  String get browser_menuReload => '重新加载';

  @override
  String get browser_menuDesktopMode => '桌面模式';

  @override
  String get browser_menuAddToHomeScreen => '添加到主屏幕';

  @override
  String get browser_menuChangeParent => '更改父标签页…';

  @override
  String get browser_menuDetachFromParent => '从父标签页分离';

  @override
  String get browser_menuHierarchy => '层级';

  @override
  String get browser_pageTranslated => '已翻译';

  @override
  String get browser_menuTranslatePage => '翻译页面';

  @override
  String get browser_unpinTab => '取消固定标签页';

  @override
  String get browser_pinTab => '固定标签页';

  @override
  String browser_errorGeneric(String error) {
    return '错误：$error';
  }

  @override
  String get browser_tabNoLongerExists => '标签页已不存在';

  @override
  String get browser_chooseAParentTab => '选择父标签页';

  @override
  String get browser_makeStandalone => '设为独立标签页';

  @override
  String get browser_detachFromCurrentParent => '从当前父标签页分离';

  @override
  String get browser_noCandidateTabsInContainer => '此容器中没有可选的标签页。';

  @override
  String get browser_clearContainerDataIntro => '这将清除此容器的所有数据：';

  @override
  String get browser_bulletCookies => '• Cookie';

  @override
  String get browser_bulletSiteData => '• 网站数据';

  @override
  String get browser_bulletCache => '• 缓存';

  @override
  String get browser_bulletPermissions => '• 权限';

  @override
  String browser_tabsWillBeClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将关闭 $count 个标签页。',
    );
    return '$_temp0';
  }

  @override
  String get browser_recreateTabsAfterClearing => '清除后重新创建标签页';

  @override
  String get browser_actionClearData => '清除数据';

  @override
  String get browser_closeFromSameHost => '关闭同一网站的标签页';

  @override
  String get browser_closeTabAndDescendants => '关闭标签页及其子标签页';

  @override
  String get browser_tabUnpinned => '已取消固定标签页';

  @override
  String browser_createdContainerNamed(String containerName) {
    return '已创建容器“$containerName”';
  }

  @override
  String get browser_newContainerFallback => '新容器';

  @override
  String get browser_assignedParentTab => '已分配父标签页';

  @override
  String get browser_couldNotAssignParentTab => '无法分配父标签页';

  @override
  String get browser_dropTabOntoTabTitle => '将标签页拖放到标签页上';

  @override
  String get browser_chooseHowTabsRelated => '选择这些标签页之间的关系。';

  @override
  String get browser_createContainerOption => '创建容器';

  @override
  String get browser_createContainerOptionSubtitle => '用这两个标签页创建一个新容器。';

  @override
  String get browser_assignNewParentOption => '分配新的父标签页';

  @override
  String get browser_assignNewParentOptionSubtitle => '将被拖放到的标签页设为父标签页。';

  @override
  String get browser_tabReorderingOnlyInDefaultMode => '仅在默认的手动排序模式下才能调整标签页顺序';

  @override
  String get browser_tooltipSearchInsideTabs => '在标签页内容中搜索';

  @override
  String get browser_filterTabType => '标签页类型';

  @override
  String get browser_sortPinnedFirst => '固定的标签页优先';

  @override
  String get browser_filterSort => '排序';

  @override
  String get browser_hierarchicalView => '层级视图';

  @override
  String get browser_filterDate => '按日期筛选';

  @override
  String get browser_quickInterval => '快速时段';

  @override
  String get browser_resetFilter => '重置筛选';

  @override
  String get browser_tooltipFilterAndSort => '筛选与排序';

  @override
  String get browser_tooltipChangeViewMode => '更改视图模式';

  @override
  String browser_downloadingAiModelsProgress(int percent) {
    return '正在下载 AI 模型（$percent%）';
  }

  @override
  String get browser_disableAiTabSuggestions => '停用 AI 标签页建议';

  @override
  String get browser_enableAiTabSuggestionsTooltip => '启用 AI 标签页建议';

  @override
  String get browser_disableReorderingMode => '关闭排序模式';

  @override
  String get browser_enableReorderingMode => '开启排序模式';

  @override
  String get browser_reorderingRequiresDefaultManualMode => '调整顺序需要使用默认的手动排序模式';

  @override
  String get browser_dragAndDropTabsToReorder => '拖放标签页以调整顺序';

  @override
  String get browser_tooltipTabActions => '标签页操作';

  @override
  String get browser_hintSearchTabs => '搜索标签页';

  @override
  String get browser_noSyncedTabsAvailable => '没有可用的同步标签页';

  @override
  String browser_failedToLoadSyncedTabs(String error) {
    return '无法加载同步的标签页：$error';
  }

  @override
  String get browser_translateFromLabel => '源语言';

  @override
  String get browser_translateToLabel => '目标语言';

  @override
  String browser_translationError(String error) {
    return '翻译错误：$error';
  }

  @override
  String get browser_failedToRestorePage => '无法恢复页面';

  @override
  String get browser_showOriginal => '显示原文';

  @override
  String get browser_failedToTranslatePage => '无法翻译页面';

  @override
  String get browser_retranslate => '重新翻译';

  @override
  String get browser_translateAction => '翻译';

  @override
  String get browser_tabTypeFilterAll => '所有标签页';

  @override
  String get browser_tabTypeFilterRegular => '普通';

  @override
  String get browser_tabTypeFilterPrivate => '隐私';

  @override
  String get browser_tabTypeFilterIsolated => '隔离';

  @override
  String get browser_tabSortDefault => '默认';

  @override
  String get browser_tabSortTitleAsc => '标题 A-Z';

  @override
  String get browser_tabSortTitleDesc => '标题 Z-A';

  @override
  String get browser_tabSortUrlAsc => '网址 A-Z';

  @override
  String get browser_tabSortUrlDesc => '网址 Z-A';

  @override
  String get browser_tabSortNewestFirst => '最新优先';

  @override
  String get browser_tabSortOldestFirst => '最早优先';

  @override
  String get browser_tabIntervalLastHour => '过去 1 小时';

  @override
  String get browser_tabIntervalLast3Hours => '过去 3 小时';

  @override
  String get browser_tabIntervalLast8Hours => '过去 8 小时';

  @override
  String get browser_tabIntervalLastDay => '过去 1 天';

  @override
  String get browser_tabIntervalLast3Days => '过去 3 天';

  @override
  String get browser_tabIntervalLastWeek => '过去 1 周';

  @override
  String get browser_tabIntervalLastMonth => '过去 1 个月';

  @override
  String get browser_tabsViewModeList => '列表';

  @override
  String get browser_tabsViewModeGrid => '网格';

  @override
  String get browser_tabsViewModeTree => '树状';

  @override
  String get browser_permissionCamera => '相机';

  @override
  String get browser_permissionMicrophone => '麦克风';

  @override
  String get browser_permissionLocation => '位置';

  @override
  String get browser_permissionNotification => '通知';

  @override
  String get browser_permissionPersistentStorage => '持久存储';

  @override
  String get browser_permissionCrossOriginStorage => '跨源存储';

  @override
  String get browser_permissionMediaKeySystem => '媒体密钥系统（DRM）';

  @override
  String get browser_tabReorderBlockedMessage => '请清除标签页视图的筛选或搜索后再调整顺序';

  @override
  String get contextualToolbar_tooltipHome => '主页';

  @override
  String get contextualToolbar_tooltipHideTabBar => '隐藏标签栏';

  @override
  String get contextualToolbar_tooltipClearBrowsingData => '清除浏览数据';

  @override
  String get contextualToolbar_tooltipAddBookmark => '添加书签';

  @override
  String get contextualToolbar_tooltipRemoveBookmark => '移除书签';

  @override
  String get contextualToolbar_tooltipEnableGestures => '启用手势';

  @override
  String get contextualToolbar_tooltipDisableGestures => '停用手势';

  @override
  String get contextualToolbar_actionHardRefresh => '强制刷新';

  @override
  String get contextualToolbar_actionCloseOthers => '关闭其他标签页';

  @override
  String get contextualToolbar_actionCloseFromSameHost => '关闭同一网站的标签页';

  @override
  String get contextualToolbar_actionCloseTabAndDescendants => '关闭标签页及其子标签页';

  @override
  String get contextualToolbar_actionAddBookmark => '添加书签';

  @override
  String get contextualToolbar_actionRemoveBookmark => '移除书签';

  @override
  String get contextualToolbar_actionCloneAsRegular => '复制为普通标签页';

  @override
  String get contextualToolbar_actionCloneAsPrivate => '复制为隐私标签页';

  @override
  String get contextualToolbar_actionCloneAsIsolated => '复制为隔离标签页';

  @override
  String get contextualToolbar_bookmarkAdded => '已添加书签';

  @override
  String get contextualToolbar_bookmarkRemoved => '已移除书签';

  @override
  String get contextualToolbar_fontSizeAutoAdjustmentHint =>
      '请先在设置中关闭自动字号，才能手动调整';

  @override
  String get contextualToolbar_buttonLabelBack => '后退';

  @override
  String get contextualToolbar_buttonLabelForward => '前进';

  @override
  String get contextualToolbar_buttonLabelHome => '主页';

  @override
  String get contextualToolbar_buttonLabelHistory => '历史记录';

  @override
  String get contextualToolbar_buttonLabelBookmarks => '书签';

  @override
  String get contextualToolbar_buttonLabelBookmarkToggle => '加入书签';

  @override
  String get contextualToolbar_buttonLabelShare => '分享';

  @override
  String get contextualToolbar_buttonLabelAddTab => '新建标签页';

  @override
  String get contextualToolbar_buttonLabelTabsCount => '标签页';

  @override
  String get contextualToolbar_buttonLabelNavigationMenu => '菜单';

  @override
  String get contextualToolbar_buttonLabelReload => '重新加载';

  @override
  String get contextualToolbar_buttonLabelReaderMode => '阅读模式';

  @override
  String get contextualToolbar_buttonLabelDesktop => '桌面版网站';

  @override
  String get contextualToolbar_buttonLabelTranslation => '翻译';

  @override
  String get contextualToolbar_buttonLabelFindInPage => '在页面中查找';

  @override
  String get contextualToolbar_buttonLabelCloseTab => '关闭标签页';

  @override
  String get contextualToolbar_buttonLabelInputUrl => '地址栏';

  @override
  String get contextualToolbar_buttonLabelQrScan => '扫描二维码';

  @override
  String get contextualToolbar_buttonLabelVoiceSearch => '语音搜索';

  @override
  String get contextualToolbar_buttonLabelDuplicateTab => '复制标签页';

  @override
  String get contextualToolbar_buttonLabelIncreaseFont => '增大字号';

  @override
  String get contextualToolbar_buttonLabelDecreaseFont => '减小字号';

  @override
  String get contextualToolbar_buttonLabelMoveToBackground => '转到后台';

  @override
  String get contextualToolbar_buttonLabelToggleGestures => '手势';

  @override
  String get contextualToolbar_buttonLabelHideTabBar => '隐藏标签栏';

  @override
  String get contextualToolbar_buttonLabelPageUp => '向上翻页';

  @override
  String get contextualToolbar_buttonLabelPageDown => '向下翻页';

  @override
  String get contextualToolbar_buttonLabelFont => '文字大小';

  @override
  String get contextualToolbar_buttonLabelExtensionShortcut => '扩展';

  @override
  String get contextualToolbar_buttonLabelClearBrowsingData => '清除数据';

  @override
  String get contextualToolbar_buttonLabelQuit => '退出';

  @override
  String get contextualToolbar_longPressBackHistoryMenu => '历史菜单（之前的页面）';

  @override
  String get contextualToolbar_longPressForwardHistoryMenu => '历史菜单（之后的页面）';

  @override
  String get contextualToolbar_longPressOpenBookmarks => '打开书签';

  @override
  String get contextualToolbar_longPressAddRegularTab => '新建普通标签页';

  @override
  String get contextualToolbar_longPressAddChildTab => '新建子标签页';

  @override
  String get contextualToolbar_longPressAddPrivateTab => '新建隐私标签页';

  @override
  String get contextualToolbar_longPressAddIsolatedTab => '新建隔离标签页';

  @override
  String get contextualToolbar_longPressOpenSettings => '打开设置';

  @override
  String get contextualToolbar_longPressHardRefresh => '强制刷新（跳过缓存）';

  @override
  String get contextualToolbar_longPressShowTranslationOptions => '显示翻译选项';

  @override
  String get contextualToolbar_longPressScrollToTop => '滚动到顶部';

  @override
  String get contextualToolbar_longPressScrollToBottom => '滚动到底部';

  @override
  String get contextualToolbar_longPressExtensionsMenu => '扩展菜单';

  @override
  String get contextualToolbar_longPressQuitWithoutConfirmation => '直接退出，不再确认';

  @override
  String get menu_sectionQuickToggles => '快捷开关';

  @override
  String get menu_sectionPageActions => '页面操作';

  @override
  String get menu_sectionExtensions => '扩展';

  @override
  String get menu_sectionTabActions => '标签页操作';

  @override
  String get menu_sectionQuickLinks => '快捷链接';

  @override
  String get menu_sectionConnection => '连接';

  @override
  String get menu_sectionProfile => '配置文件与应用';

  @override
  String get menu_sectionAbout => '关于';

  @override
  String get menu_itemDesktopMode => '桌面版';

  @override
  String get menu_itemReaderMode => '阅读';

  @override
  String get menu_itemGestures => '手势';

  @override
  String get menu_itemAddBookmark => '添加书签';

  @override
  String get menu_itemFindInPage => '在页面中查找';

  @override
  String get menu_itemTranslatePage => '翻译页面';

  @override
  String get menu_itemAddToHomeScreen => '添加到主屏幕';

  @override
  String get menu_itemOpenInApp => '在应用中打开';

  @override
  String get menu_itemContainers => '容器';

  @override
  String get menu_itemManageContainers => '管理容器';

  @override
  String get menu_itemAssignContainer => '分配容器';

  @override
  String get menu_itemAssignUrlToContainer => '将网址分配给容器';

  @override
  String get menu_itemUnassignUrlFromContainer => '取消网址的容器分配';

  @override
  String get menu_itemUnassignContainer => '取消容器分配';

  @override
  String get menu_itemShare => '分享';

  @override
  String get menu_itemCopyAddress => '复制地址';

  @override
  String get menu_itemShareScreenshot => '分享截图';

  @override
  String get menu_itemShareLink => '分享链接';

  @override
  String get menu_itemSendToDevice => '发送到设备';

  @override
  String get menu_itemShowQrCode => '显示二维码';

  @override
  String get menu_itemMoreDisclosure => '更多';

  @override
  String get menu_itemCloneTab => '复制标签页';

  @override
  String get menu_itemCloneRegularTab => '普通';

  @override
  String get menu_itemClonePrivateTab => '隐私';

  @override
  String get menu_itemCloneIsolatedTab => '隔离';

  @override
  String get menu_itemExport => '导出';

  @override
  String get menu_itemCopyAsMarkdown => '复制为 Markdown';

  @override
  String get menu_itemExportAsMarkdown => '导出为 Markdown';

  @override
  String get menu_itemExportAsPdf => '导出为 PDF';

  @override
  String get menu_itemExportAsPng => '导出为 PNG';

  @override
  String get menu_itemPrintPage => '打印';

  @override
  String get menu_itemPinTopSite => '固定到快捷方式';

  @override
  String get menu_itemFetchFeeds => '获取订阅源';

  @override
  String get menu_itemHistory => '历史记录';

  @override
  String get menu_itemBookmarks => '书签';

  @override
  String get menu_itemDownloads => '下载';

  @override
  String get menu_itemBangs => 'Bang';

  @override
  String get menu_itemFeeds => '订阅源';

  @override
  String get menu_itemSmallWeb => '小众网络';

  @override
  String get menu_itemClearData => '清除数据';

  @override
  String get menu_itemProfileSwitch => '配置文件';

  @override
  String get menu_itemSyncNow => '立即同步';

  @override
  String get menu_itemAppSettings => '设置';

  @override
  String get menu_itemQuitBrowser => '退出浏览器';

  @override
  String get menu_itemAbout => '关于';

  @override
  String get menu_itemMoreDisclosureDescription => '将其下方的所有内容折叠到“更多”行中';

  @override
  String get menu_itemSendToDeviceDescription => '设备列表来自你的账户';

  @override
  String get menu_reorderHideTooltip => '隐藏';

  @override
  String get menu_reorderShowTooltip => '显示';

  @override
  String menu_reorderRowsShown(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '显示 $shown/$total 行',
    );
    return '$_temp0';
  }

  @override
  String get menu_reorderDefaultTitle => '自定义菜单';

  @override
  String get menu_reorderSubtitleSections => '拖动以调整顺序。关闭某个版块即可在菜单中隐藏它。';

  @override
  String get menu_reorderSubtitleSectionRows => '拖动以调整此版块中各行的顺序。';

  @override
  String get menu_reorderSubtitleItemRows => '拖动以调整此项展开后各行的顺序。';

  @override
  String get menu_reorderBackTooltip => '返回版块列表';

  @override
  String get menu_reorderResetToDefaults => '恢复默认';

  @override
  String get menu_customizeMenuButton => '自定义菜单';

  @override
  String get menu_navStop => '停止';

  @override
  String get menu_navBack => '后退';

  @override
  String get menu_navForward => '前进';

  @override
  String get menu_navCloseTab => '关闭标签页';

  @override
  String get menu_navReload => '重新加载';

  @override
  String get menu_navCloseOthers => '关闭其他标签页';

  @override
  String get menu_navCloseFromSameHost => '关闭同一网站的标签页';

  @override
  String get menu_navCloseTabAndDescendants => '关闭标签页及其子标签页';

  @override
  String get menu_navHardRefresh => '强制刷新';

  @override
  String get menu_profileTapToSwitch => '点按以切换配置文件';

  @override
  String get menu_profileSyncComplete => '同步完成';

  @override
  String menu_openInApp(String appName) {
    return '在 $appName 中打开';
  }

  @override
  String get menu_pageTranslated => '已翻译';

  @override
  String get menu_extensionsTitle => '扩展';

  @override
  String get menu_extensionFallbackTitle => '扩展';

  @override
  String get menu_extensionsSettingsTooltip => '扩展设置';

  @override
  String get menu_extensionsManage => '管理扩展';

  @override
  String get menu_containersExpansionTitle => '容器';

  @override
  String get menu_containersManage => '管理容器';

  @override
  String get menu_containersAssign => '分配容器';

  @override
  String get menu_containersAssignUrl => '将网址分配给容器';

  @override
  String get menu_containersUnassignUrl => '取消网址的容器分配';

  @override
  String get menu_containersUnassign => '取消容器分配';

  @override
  String get menu_shareExpansionTitle => '分享';

  @override
  String get menu_shareUrlCleaned => '网址已清理';

  @override
  String get menu_shareUrlPreviewApplied => '已应用网址预览';

  @override
  String get menu_shareCopyAddress => '复制地址';

  @override
  String get menu_shareScreenshot => '分享截图';

  @override
  String get menu_shareLink => '分享链接';

  @override
  String get menu_shareShowQrCode => '显示二维码';

  @override
  String get menu_sendToDeviceExpansionTitle => '发送到设备';

  @override
  String get menu_sendToDeviceNone => '没有目标设备';

  @override
  String get menu_sendToDeviceLoading => '正在加载设备…';

  @override
  String get menu_sendToDeviceLoadFailed => '无法加载设备';

  @override
  String menu_sendToDeviceSuccess(String deviceName) {
    return '已将标签页发送到 $deviceName';
  }

  @override
  String get menu_sendToDeviceSendFailed => '无法发送标签页';

  @override
  String get menu_cloneTabExpansionTitle => '复制标签页';

  @override
  String get menu_cloneTypeRegular => '普通';

  @override
  String get menu_cloneTypePrivate => '隐私';

  @override
  String get menu_cloneTypeIsolated => '隔离';

  @override
  String get menu_exportExpansionTitle => '导出';

  @override
  String get menu_exportCopyAsMarkdown => '复制为 Markdown';

  @override
  String get menu_exportAsMarkdown => '导出为 Markdown';

  @override
  String get menu_exportAsPdf => '导出为 PDF';

  @override
  String get menu_exportAsPng => '导出为 PNG';

  @override
  String get menu_exportMarkdownCopied => 'Markdown 已复制到剪贴板';

  @override
  String get menu_exportPrint => '打印';

  @override
  String get menu_exportPrintFailed => '无法打印页面';

  @override
  String get menu_pinUnpinFromShortcuts => '从快捷方式中取消固定';

  @override
  String get menu_pinPinToShortcuts => '固定到快捷方式';

  @override
  String get menu_pinUnpinnedMessage => '已从快捷方式中取消固定';

  @override
  String get menu_pinPinnedMessage => '已固定到快捷方式';

  @override
  String get menu_pinUpdateFailed => '无法更新快捷方式';

  @override
  String get menu_fetchFeedsTitle => '获取页面上的订阅源';

  @override
  String get menu_fetchFeedsNone => '未找到网页订阅源';

  @override
  String get menu_fetchFeedsAvailable => '可用的网页订阅源';

  @override
  String get menu_fetchFeedsLoading => '正在获取网页订阅源…';

  @override
  String get menu_connectionTitle => '连接';

  @override
  String get menu_connectionRegularTabs => '普通标签页';

  @override
  String get menu_connectionPrivateTabs => '隐私标签页';

  @override
  String menu_connectionAllThrough(String proxyTitle) {
    return '全部经由 $proxyTitle';
  }

  @override
  String get menu_connectionPerContainer => '按容器';

  @override
  String get menu_connectionPerContainerSubtitle => '仅路由已分配代理的容器';

  @override
  String get menu_connectionDirect => '直连';

  @override
  String get menu_connectionPrivateNeverInheritSubtitle => '隐私标签页从不沿用全局路由';

  @override
  String get menu_connectionThisIsolatedTab => '此隔离标签页';

  @override
  String get menu_connectionFollowsContainer => '跟随其容器';

  @override
  String get menu_connectionFollowContainerOption => '跟随其容器';

  @override
  String get menu_connectionFollowContainerOptionSubtitle => '使用分配给此标签页所属容器的路由';

  @override
  String get menu_connectionIsolatedDirectSubtitle => '绕过其容器将应用的路由';

  @override
  String get menu_connectionThisContainer => '此容器';

  @override
  String get menu_connectionFollowsGlobalRouting => '跟随全局路由';

  @override
  String get menu_connectionContainerFallbackTitle => '容器';

  @override
  String get menu_connectionFollowGlobalRoutingOption => '跟随全局路由';

  @override
  String get menu_connectionFollowGlobalRoutingOptionSubtitle =>
      '使用与普通标签页相同的路由';

  @override
  String get menu_connectionContainerDirectSubtitle => '此容器绕过全局代理';

  @override
  String menu_connectionFailedToChangeRoute(String error) {
    return '无法更改路由：$error';
  }

  @override
  String menu_connectionProxyError(String error) {
    return '代理错误：$error';
  }

  @override
  String menu_connectionNotRoutedByContainer(String container) {
    return '不经由容器“$container”路由';
  }

  @override
  String get menu_connectionNotRoutedByTabContainer => '不经由此标签页的容器路由';

  @override
  String get menu_connectionCheckingRouting => '正在检查路由…';

  @override
  String get menu_connectionStartingRouting => '正在启动路由…';

  @override
  String menu_connectionBlockedNotRunning(String proxyTitle) {
    return '已阻止 — $proxyTitle 未运行';
  }

  @override
  String menu_connectionThisTabVia(String proxyTitle) {
    return '此标签页：$proxyTitle';
  }

  @override
  String get menu_connectionThisTabDirect => '此标签页：直接连接';

  @override
  String menu_connectionStartProxy(String proxyTitle) {
    return '启动 $proxyTitle';
  }

  @override
  String get menu_connectionProxySettings => '代理设置';

  @override
  String get menu_connectionUnused => '未被任何路由使用';

  @override
  String menu_connectionUsageContainerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个容器',
    );
    return '$_temp0';
  }

  @override
  String menu_connectionUsageIsolatedTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个隔离标签页',
    );
    return '$_temp0';
  }

  @override
  String get menu_connectionUsageBlocked => '已阻止';

  @override
  String get contextmenu_openInNewTab => '在新标签页中打开';

  @override
  String get contextmenu_tooltipOpenInDifferentTabType => '在其他类型的标签页中打开';

  @override
  String get contextmenu_newRegularTab => '新建普通标签页';

  @override
  String get contextmenu_newPrivateTab => '新建隐私标签页';

  @override
  String get contextmenu_newIsolatedTab => '新建隔离标签页';

  @override
  String get contextmenu_openImageInNewTab => '在新标签页中打开图片';

  @override
  String get contextmenu_openInContainer => '在容器中打开';

  @override
  String get contextmenu_selectContainerTitle => '选择容器';

  @override
  String get contextmenu_loadContainersFailedTitle => '无法加载容器';

  @override
  String get contextmenu_newContainer => '新建容器';

  @override
  String get contextmenu_openInApp => '在应用中打开';

  @override
  String contextmenu_openInAppNamed(String appName) {
    return '在 $appName 中打开';
  }

  @override
  String get contextmenu_copyLink => '复制链接';

  @override
  String get contextmenu_copyLinkText => '复制链接文本';

  @override
  String get contextmenu_copyImage => '复制图片';

  @override
  String get contextmenu_copyImageLocation => '复制图片地址';

  @override
  String get contextmenu_saveFile => '保存文件';

  @override
  String get contextmenu_saveImage => '保存图片';

  @override
  String get contextmenu_shareImage => '分享图片';

  @override
  String get contextmenu_shareEmailAddress => '分享电子邮件地址';

  @override
  String get contextmenu_urlCleanedMessage => '网址已清理';

  @override
  String get contextmenu_urlPreviewAppliedMessage => '已应用网址预览';

  @override
  String get findInPage_hint => '在页面中查找';

  @override
  String findInPage_matchPosition(int current, int total) {
    return '第 $current 项，共 $total 项';
  }

  @override
  String get findInPage_noMatches => '未找到';

  @override
  String get history_titleHistory => '历史记录';

  @override
  String get history_titleDownloads => '下载';

  @override
  String get history_filterHintHistory => '筛选历史记录…';

  @override
  String get history_filterHintDownloads => '筛选下载…';

  @override
  String history_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选择 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipClearSearch => '清除搜索';

  @override
  String get history_tooltipSearchHistory => '搜索历史记录';

  @override
  String get history_tooltipSearchDownloads => '搜索下载';

  @override
  String history_tooltipClearContainerHistory(String container) {
    return '清除“$container”的历史记录';
  }

  @override
  String get history_filterDate => '日期';

  @override
  String get history_filterContainer => '容器';

  @override
  String get history_allContainers => '所有容器';

  @override
  String get history_unnamedContainer => '未命名容器';

  @override
  String history_containerFilterLabel(String container) {
    return '容器：$container';
  }

  @override
  String get history_resetFilter => '重置筛选';

  @override
  String get history_filterTypeFollowedLinks => '点击的链接';

  @override
  String get history_filterTypeTypedAddresses => '输入的地址';

  @override
  String get history_filterTypeEmbeddedPageElements => '嵌入的页面元素';

  @override
  String get history_filterTypePermanentRedirects => '永久重定向';

  @override
  String get history_filterTypeTemporaryRedirects => '临时重定向';

  @override
  String get history_filterTypeDownloads => '下载';

  @override
  String get history_filterTypeFrames => '网页框架';

  @override
  String get history_filterTypePageReloads => '页面重新加载';

  @override
  String get history_filterTypeBookmarks => '书签';

  @override
  String get history_visitTypeFollowedLink => '点击的链接';

  @override
  String get history_visitTypeTypedAddress => '输入的地址';

  @override
  String get history_visitTypeEmbeddedPageElement => '嵌入的页面元素';

  @override
  String get history_visitTypePermanentRedirect => '永久重定向';

  @override
  String get history_visitTypeTemporaryRedirect => '临时重定向';

  @override
  String get history_visitTypeDownload => '下载';

  @override
  String get history_visitTypeFrame => '网页框架';

  @override
  String get history_visitTypePageReload => '页面重新加载';

  @override
  String get history_visitTypeBookmark => '书签';

  @override
  String get history_clearContainerHistoryTitle => '清除容器历史记录';

  @override
  String history_clearContainerHistoryContent(String container) {
    return '确定要清除“$container”的所有历史记录吗？';
  }

  @override
  String get history_downloadedFileNotFound => '找不到已下载的文件';

  @override
  String get history_couldNotOpenDownloadedFile => '无法打开已下载的文件';

  @override
  String get history_loadHistoryFailedTitle => '无法加载历史记录';

  @override
  String get history_loadDownloadsFailedTitle => '无法加载下载列表';

  @override
  String get history_deleteFileTitle => '删除文件';

  @override
  String history_deleteFileConfirm(String fileName) {
    return '确定要删除 $fileName 吗？';
  }

  @override
  String get history_deleteFileWarning => '这将从你的设备中永久删除该文件。';

  @override
  String get history_deleteFileRememberChoice => '对其余文件记住我的选择';

  @override
  String get history_deleteFileActionKeep => '保留';

  @override
  String get history_filterDistinctUrls => '不重复的网址';

  @override
  String history_visitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 次访问',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipDeleteHistory => '删除历史记录';

  @override
  String get history_deleteMenuTimeRange => '删除指定时段的历史记录…';

  @override
  String get history_deleteMenuBrowsingData => '删除浏览数据…';

  @override
  String get history_deleteTimeRangeTitle => '删除指定时间范围的历史记录';

  @override
  String get history_deleteTimeRangeFrom => '从';

  @override
  String get history_deleteTimeRangeTo => '至';

  @override
  String get history_deleteTimeRangeLastHour => '过去一小时';

  @override
  String get history_deleteTimeRangeToday => '今天';

  @override
  String get history_deleteTimeRangeLastWeek => '过去 7 天';

  @override
  String get history_deleteTimeRangeExplanation =>
      '此范围内的所有访问记录都将被删除，包括所有容器。此范围内已完成和失败的下载也会从下载列表中移除，但文件仍保留在设备上。正在进行的下载将保留。';

  @override
  String get history_deleteTimeRangeInvalid => '开始时间必须早于结束时间。';

  @override
  String get openLinkTools_openLinkTitle => '打开链接';

  @override
  String get openLinkTools_urlCleanedMessage => '网址已清理';

  @override
  String get openLinkTools_urlPreviewAppliedMessage => '已应用网址预览';

  @override
  String get openLinkTools_urlBlockedByClearUrls => '网址已被 ClearURLs 阻止';

  @override
  String openLinkTools_unshortenFailedWithError(String error) {
    return '无法还原短链接：$error';
  }

  @override
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit) {
    return '剩余调用次数：$remaining/$limit';
  }

  @override
  String get openLinkTools_unshortenTileTitle => '还原短链接';

  @override
  String get openLinkTools_unshortenTileSubtitle => '解析短网址';

  @override
  String get openLinkTools_unshortenerInfoTooltip => '短链接还原服务信息';

  @override
  String openLinkTools_openInAppNamed(String appName) {
    return '在 $appName 中打开';
  }

  @override
  String get openLinkTools_openInAppGeneric => '在应用中打开';

  @override
  String get openLinkTools_openInAppSubtitle => '在已安装的应用中打开';

  @override
  String get openLinkTools_couldNotOpenInApp => '无法在应用中打开';

  @override
  String get openLinkTools_openInNewTabTitle => '在新标签页中打开';

  @override
  String get openLinkTools_openInNewTabSubtitle => '添加到浏览器标签页';

  @override
  String get openLinkTools_openInCustomTabTitle => '在自定义标签页中打开';

  @override
  String get openLinkTools_openInCustomTabSubtitle => '在单独的窗口中打开';

  @override
  String get openLinkTools_unshortenerAttributionTitle => '短链接还原服务说明';

  @override
  String openLinkTools_unshortenerAttributionBody(String service) {
    return '此模块会将短链接发送到 $service 进行解析。该服务会在其服务器上检查每个链接，并保存重定向结果供以后的请求使用。请勿发送包含隐私或敏感数据的链接。';
  }

  @override
  String get openLinkTools_unshortenerRateLimitNotice =>
      '免费 API 对新查询的速率限制为每小时 10 次请求。';

  @override
  String openLinkTools_privacyPolicyLabel(String link) {
    return '隐私政策：$link';
  }

  @override
  String get openLinkTools_removeTrackingParametersTitle => '移除跟踪参数';

  @override
  String get openLinkTools_removeTrackingParametersSubtitle => '选择要从此网址中移除的参数。';

  @override
  String get openLinkTools_referralMarketingBadge => '推广营销';

  @override
  String openLinkTools_selectedForRemovalCount(int selected, int total) {
    return '已选择移除 $selected 项，共 $total 项';
  }

  @override
  String get openLinkTools_cleanedUrlLabel => '清理后的网址：';

  @override
  String get openLinkTools_restoreDefaultsTitle => '恢复默认设置？';

  @override
  String get openLinkTools_restoreDefaultsContent => '这将重置网址清理设置，并移除本地存储的规则库。';

  @override
  String get openLinkTools_actionRestore => '恢复';

  @override
  String get openLinkTools_actionApplyChanges => '应用更改';

  @override
  String openLinkTools_couldNotOpenLink(String url) {
    return '无法打开链接：$url';
  }

  @override
  String get openLinkTools_tileTitleCleaned => '网址已清理';

  @override
  String openLinkTools_tileSubtitleRemovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已移除 $count 个跟踪参数',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitlePartiallyCleaned => '网址已部分清理';

  @override
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '已移除 $removed/$total 个跟踪参数',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitleTrackingDetected => '检测到跟踪';

  @override
  String openLinkTools_tileSubtitleFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '发现 $count 个跟踪参数',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_cleanUrlTooltip => '清理网址';

  @override
  String get openLinkTools_unshortenerSettingsTitle => '短链接还原';

  @override
  String get openLinkTools_unshortenerSettingsSubtitle => '短链接解析行为、令牌配置和服务说明。';

  @override
  String get openLinkTools_unshortenerEnabledTitle => '启用短链接还原';

  @override
  String get openLinkTools_unshortenerEnabledKeywords => '短链接,短网址,short links';

  @override
  String get openLinkTools_unshortenerEnabledSubtitle => '将短网址解析为其目标地址';

  @override
  String get openLinkTools_descriptionLabel => '描述';

  @override
  String get openLinkTools_unshortenerDescriptionBody =>
      '此模块会将短链接发送到 unshorten.me 进行解析。该服务会在其服务器上检查每个链接，并保存重定向结果供以后的请求使用。请勿发送包含隐私或敏感数据的链接。';

  @override
  String get openLinkTools_attributionServiceLabel => '服务';

  @override
  String get openLinkTools_attributionPrivacyPolicyLabel => '隐私政策';

  @override
  String get openLinkTools_apiTokenLabel => 'API 令牌';

  @override
  String get openLinkTools_apiTokenLabelKeywords => '令牌,token';

  @override
  String get openLinkTools_apiTokenHint => '可选令牌，可获得更高限额';

  @override
  String get openLinkTools_urlCleanerSettingsTitle => '网址清理';

  @override
  String get openLinkTools_urlCleanerSettingsSubtitle => '网址清理行为、规则库更新和来源说明。';

  @override
  String get openLinkTools_urlCleanerDescriptionBody =>
      '此模块会从网址中移除跟踪参数、来源参数及其他不必要的参数，还可以离线解析常见的网址重定向。';

  @override
  String get openLinkTools_urlCleanerEnabledTitle => '启用网址清理';

  @override
  String get openLinkTools_urlCleanerEnabledKeywords =>
      '清理网址,clean urls,clearurls';

  @override
  String get openLinkTools_urlCleanerEnabledSubtitle => '从网址中移除跟踪参数';

  @override
  String get openLinkTools_autoApplyTitle => '自动应用';

  @override
  String get openLinkTools_autoApplyKeywords => '自动应用,自动';

  @override
  String get openLinkTools_autoApplySubtitle => '自动将网址替换为清理后的版本';

  @override
  String get openLinkTools_allowReferralTitle => '允许推广营销';

  @override
  String get openLinkTools_allowReferralKeywords =>
      '联盟营销,推广,返利,affiliate,referral';

  @override
  String get openLinkTools_allowReferralSubtitle => '保留推广和联盟营销跟踪参数';

  @override
  String get openLinkTools_autoUpdateCatalogTitle => '自动更新规则库';

  @override
  String get openLinkTools_autoUpdateCatalogSubtitle => '每周检查规则更新';

  @override
  String get openLinkTools_updateCatalogTitle => '更新规则库';

  @override
  String get openLinkTools_lastUpdateNotAvailable => '上次更新：无';

  @override
  String openLinkTools_lastUpdateWithDate(String date) {
    return '上次更新：$date';
  }

  @override
  String openLinkTools_lastAutoUpdateWithDate(String date) {
    return '上次更新：$date（自动）';
  }

  @override
  String openLinkTools_lastCheckWithDate(String date) {
    return '上次检查：$date';
  }

  @override
  String get openLinkTools_catalogUpdatedMessage => '规则库已更新';

  @override
  String openLinkTools_updateFailedWithError(String error) {
    return '更新失败：$error';
  }

  @override
  String get openLinkTools_restoreDefaultsButtonTitle => '恢复默认设置';

  @override
  String get openLinkTools_restoreDefaultsButtonSubtitle => '重置为内置规则库和默认设置';

  @override
  String get openLinkTools_clearUrlAttributionText => '此模块基于 ClearURL 规则：';

  @override
  String get openLinkTools_urlCleanerOverviewSectionTitle => '概览';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionTitle => '描述';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionKeywords => '跟踪参数,重定向';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle =>
      '移除跟踪参数并离线清理重定向';

  @override
  String get openLinkTools_urlCleanerBehaviorSectionTitle => '行为';

  @override
  String get openLinkTools_urlCleanerCatalogSectionTitle => '规则库';

  @override
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle =>
      '获取最新的网址清理规则';

  @override
  String get openLinkTools_urlCleanerAttributionSectionTitle => '来源说明';

  @override
  String get openLinkTools_indexUrlCleanerAttributionTitle => '来源说明';

  @override
  String get openLinkTools_indexUrlCleanerAttributionSubtitle => '致谢和来源链接';

  @override
  String get openLinkTools_unshortenerOverviewSectionTitle => '概览';

  @override
  String get openLinkTools_indexUnshortenerDescriptionTitle => '描述';

  @override
  String get openLinkTools_indexUnshortenerDescriptionKeywords => '短链接,重定向';

  @override
  String get openLinkTools_indexUnshortenerDescriptionSubtitle =>
      '使用 unshorten.me 服务解析短网址';

  @override
  String get openLinkTools_unshortenerBehaviorSectionTitle => '行为';

  @override
  String get openLinkTools_indexUnshortenerApiTokenSubtitle =>
      '可选令牌，可获得更高的请求限额';

  @override
  String get openLinkTools_unshortenerAttributionSectionTitle => '服务说明';

  @override
  String get openLinkTools_indexUnshortenerAttributionTitle => '服务说明';

  @override
  String get openLinkTools_indexUnshortenerAttributionKeywords => '隐私政策,速率限制';

  @override
  String get openLinkTools_indexUnshortenerAttributionSubtitle =>
      '速率限制、服务主页和隐私政策';

  @override
  String get pwa_addToHomeScreenTitle => '添加到主屏幕';

  @override
  String get pwa_nameFieldLabel => '名称';

  @override
  String get pwa_storageLabel => '存储';

  @override
  String get pwa_defaultContainerLabel => '容器';

  @override
  String get pwa_installAsAppTitle => '安装为应用';

  @override
  String get pwa_installAsAppSubtitle => '在独立窗口中运行。';

  @override
  String get pwa_addShortcutTitle => '添加快捷方式';

  @override
  String get pwa_addShortcutSubtitle => '在浏览器中以普通标签页打开。';

  @override
  String get pwa_storageDefaultTitle => '默认';

  @override
  String get pwa_storageDefaultSubtitle => '使用浏览器默认存储（不使用容器）。';

  @override
  String pwa_storageContainerTitle(String label) {
    return '容器“$label”';
  }

  @override
  String get pwa_storageContainerSubtitle => '与所选容器共享 Cookie 和数据。';

  @override
  String get pwa_storageInheritIsolatedTitle => '沿用当前隔离环境';

  @override
  String get pwa_storageInheritIsolatedSubtitle => '与当前打开的隔离会话共享存储。';

  @override
  String get pwa_storageNewIsolatedTitle => '新建隔离环境';

  @override
  String get pwa_storageNewIsolatedSubtitle => '为此次安装单独创建一个全新的存储空间。';

  @override
  String get pwa_defaultWebAppName => '此网页应用';

  @override
  String get pwa_defaultSiteName => '此网站';

  @override
  String pwa_addedToHomeScreen(String name) {
    return '已将 $name 添加到主屏幕';
  }

  @override
  String pwa_installFailedManifestBacked(String name) {
    return '无法添加 $name。该网站可能不支持安装。';
  }

  @override
  String pwa_installFailedGeneric(String name) {
    return '无法将 $name 添加到主屏幕';
  }

  @override
  String get pwa_noTabSelected => '未选择标签页，请重试。';

  @override
  String get search_moduleLabelRecentSearches => '最近搜索';

  @override
  String get search_moduleLabelSearchProviders => '搜索提供商';

  @override
  String get search_moduleLabelSearchSuggestions => '建议';

  @override
  String get search_moduleLabelTabs => '标签页';

  @override
  String get search_moduleLabelArticles => '文章';

  @override
  String get search_moduleLabelBookmarks => '书签';

  @override
  String get search_moduleLabelHistory => '历史记录（引擎）';

  @override
  String get search_moduleLabelLocalHistory => '本地内容';

  @override
  String get search_moduleLabelCombinedHistory => '历史记录';

  @override
  String get search_moduleLabelPopularSites => '热门网站';

  @override
  String get search_moduleLabelHistoryHighlights => '历史精选';

  @override
  String get search_moduleLabelTopSites => '快捷方式';

  @override
  String get search_moduleLabelRecentHistory => '最近访问';

  @override
  String get search_moduleLabelRecentArticles => '最新文章';

  @override
  String get search_moduleLabelRecentTabs => '最近标签页';

  @override
  String get search_moduleLabelContainers => '容器';

  @override
  String get search_moduleLabelFrequentBangs => '常用 Bang';

  @override
  String get search_moduleLabelQuote => '名言';

  @override
  String get search_moduleLabelQuickActions => '快捷操作';

  @override
  String get search_moduleLabelActions => '操作';

  @override
  String get search_couldNotLoadHistory => '无法加载历史记录';

  @override
  String get search_couldNotLoadLocalContent => '无法加载本地内容';

  @override
  String get search_failedSearchingArticles => '文章搜索失败';

  @override
  String get search_contentMatchTooltip => '内容匹配';

  @override
  String get search_tabTypeRegular => '普通';

  @override
  String get search_tabTypeChild => '子页';

  @override
  String get search_tabTypePrivate => '隐私';

  @override
  String get search_tabTypeIsolated => '隔离';

  @override
  String get search_fillLinkFromClipboard => '从剪贴板填入链接';

  @override
  String get search_actionNewTab => '新建标签页';

  @override
  String get search_actionViewTabs => '查看标签页';

  @override
  String get search_actionResumeLastTab => '继续浏览上次的标签页';

  @override
  String get search_bangTabAllProviders => '所有提供商';

  @override
  String get search_bangTabSearchOnThisSite => '在此网站中搜索';

  @override
  String get search_editShortcutDialogTitle => '编辑快捷方式';

  @override
  String get search_addShortcut => '添加快捷方式';

  @override
  String get search_titleFieldLabel => '标题';

  @override
  String get search_urlFieldLabel => '网址';

  @override
  String get search_titleCannotBeEmpty => '标题不能为空';

  @override
  String get search_urlCannotBeEmpty => '网址不能为空';

  @override
  String get search_enterValidUrl => '请输入有效的网址';

  @override
  String get search_actionPin => '固定';

  @override
  String get search_actionUnpin => '取消固定';

  @override
  String get search_actionResetFrequency => '重置使用频率';

  @override
  String get search_actionEditBang => '编辑 Bang';

  @override
  String get search_actionCustomizeAsOwnBang => '自定义为你自己的 Bang';

  @override
  String search_resetBangDialogTitle(String triggerName) {
    return '重置 $triggerName 的使用频率？';
  }

  @override
  String get search_resetBangDialogContent => '这会将该 Bang 从快速选择列表中移除。';

  @override
  String get search_customizeSectionsButton => '自定义版块';

  @override
  String get search_customizeSectionsHeading => '自定义版块';

  @override
  String get search_resetToDefaults => '恢复默认';

  @override
  String search_showAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '显示全部 $count 项',
    );
    return '$_temp0';
  }

  @override
  String get search_disableReorderingMode => '关闭排序模式';

  @override
  String get search_enableReorderingMode => '开启排序模式';

  @override
  String get search_dragDropShortcutsHint => '拖放快捷方式以调整顺序';

  @override
  String get search_failedReorderShortcut => '无法调整快捷方式顺序';

  @override
  String search_hideAllFromHost(String host) {
    return '隐藏来自 $host 的全部';
  }

  @override
  String search_pinnedSite(String title) {
    return '已固定“$title”';
  }

  @override
  String get search_failedPinSite => '无法固定网站';

  @override
  String get search_shortcutUpdated => '快捷方式已更新';

  @override
  String get search_failedUpdateShortcut => '无法更新快捷方式';

  @override
  String search_addedSite(String title) {
    return '已添加“$title”';
  }

  @override
  String get search_failedAddShortcut => '无法添加快捷方式';

  @override
  String search_hidAllShortcutsFromHost(String host) {
    return '已隐藏来自 $host 的所有快捷方式';
  }

  @override
  String search_removedSite(String title) {
    return '已移除“$title”';
  }

  @override
  String get search_failedRemoveShortcut => '无法移除快捷方式';

  @override
  String get search_quoteCardTitle => '路上的一点思考';

  @override
  String get search_refreshQuoteTooltip => '换一条名言';

  @override
  String get search_quotePlaceholder => '打开一个新标签页，让这里变成你的空间。';

  @override
  String get search_searchFieldLabel => '搜索或输入网址';

  @override
  String get search_invalidAddress => '地址无效';

  @override
  String get search_actionSwitchToContainer => '切换到容器';

  @override
  String get search_actionSwitchToProfile => '切换到此配置文件（将重启浏览器）';

  @override
  String get search_actionOpenFeed => '打开订阅源';

  @override
  String search_actionSettingLocation(String category, String section) {
    return '设置 › $category › $section';
  }

  @override
  String search_actionSettingCategory(String category) {
    return '设置 › $category';
  }

  @override
  String get search_actionUnnamedContainer => '未命名容器';

  @override
  String get search_actionUntitledFeed => '无标题订阅源';

  @override
  String get tabs_actionSelect => '选择';

  @override
  String get tabs_actionUnselect => '取消选择';

  @override
  String get tabs_unsavedChangesTitle => '未保存的更改';

  @override
  String get tabs_unsavedChangesConfirm => '有未保存的更改。要舍弃还是保存？';

  @override
  String get tabs_deleteContainerTitle => '删除容器';

  @override
  String get tabs_deleteContainerConfirm => '确定要删除此容器吗？其中的标签页将被关闭。';

  @override
  String get tabs_deleteContainerAlsoDeleteHistory => '同时删除浏览历史记录';

  @override
  String get tabs_deleteContainerHistoryKeptNote =>
      '如果不勾选，访问记录仍会保留在历史记录中，但不再归属于任何容器。';

  @override
  String get tabs_deleteContainerButton => '删除容器';

  @override
  String get tabs_containersTitle => '容器';

  @override
  String get tabs_noContainersYet => '尚无容器';

  @override
  String get tabs_loadContainersFailedTitle => '无法加载容器';

  @override
  String get tabs_containerFabLabel => '新建容器';

  @override
  String get tabs_untitledContainer => '未命名';

  @override
  String get tabs_emptyContainerLabel => '空';

  @override
  String tabs_tabCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个标签页',
    );
    return '$_temp0';
  }

  @override
  String get tabs_chipPinned => '已固定';

  @override
  String get tabs_chipIsolated => '隔离';

  @override
  String get tabs_chipDirect => '直连';

  @override
  String get tabs_chipClearOnExit => '退出时清除';

  @override
  String get tabs_chipActive => '当前';

  @override
  String get tabs_selectContainerTitle => '选择容器';

  @override
  String get tabs_unassignedTitle => '未分配';

  @override
  String get tabs_unassignedSubtitle => '未分配到容器的标签页';

  @override
  String get tabs_draftContainersTitle => '建议的容器';

  @override
  String get tabs_suggestionsFailedTitle => '无法加载建议';

  @override
  String get tabs_siteAssignmentsTitle => '网站分配';

  @override
  String get tabs_addSiteLabel => '添加网站';

  @override
  String get tabs_addSiteHint => 'example.com 或 *.example.com';

  @override
  String get tabs_addSiteHelperText => '匹配单个网站，或使用 *.example.com 匹配其所有子域名';

  @override
  String get tabs_urlMustBeProvided => '必须提供网址';

  @override
  String get tabs_invalidUrl => '网址无效';

  @override
  String get tabs_siteAlreadyAssigned => '此网站已分配';

  @override
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  ) {
    return '$site 已分配给“$containerName”';
  }

  @override
  String tabs_siteAlreadyAssignedToAnotherContainer(String site) {
    return '$site 已分配给其他容器';
  }

  @override
  String get tabs_newContainerTitle => '新建容器';

  @override
  String get tabs_editContainerTitle => '编辑容器';

  @override
  String get tabs_containerNameHint => '容器名称';

  @override
  String get tabs_changeColor => '更改颜色';

  @override
  String get tabs_changeIcon => '更改图标';

  @override
  String get tabs_sectionDisplay => '显示';

  @override
  String get tabs_pinContainer => '固定容器';

  @override
  String get tabs_pinContainerSubtitle => '将此容器保持在列表顶部';

  @override
  String get tabs_wallpaperLabel => '壁纸';

  @override
  String get tabs_wallpaperSelectedSubtitle => '选中此容器时显示在主页上';

  @override
  String get tabs_wallpaperDefaultSubtitle => '使用设置中的壁纸';

  @override
  String get tabs_wallpaperEmptyDescription => '此容器将使用设置中的壁纸。';

  @override
  String get tabs_sectionPrivacySecurity => '隐私与安全';

  @override
  String get tabs_cookieIsolation => 'Cookie 隔离';

  @override
  String get tabs_proxyConnectionLabel => '代理连接';

  @override
  String get tabs_proxyConnectionNone => '无';

  @override
  String get tabs_bypassGlobalProxy => '绕过全局代理';

  @override
  String get tabs_bypassGlobalProxySubtitle => '启用全局路由时，此容器仍使用普通连接';

  @override
  String get tabs_clearDataOnExit => '退出时清除数据';

  @override
  String get tabs_clearDataOnExitSubtitle =>
      '应用关闭时，清除此容器中普通标签页的 Cookie 和网站数据。隔离标签页的数据单独保存。';

  @override
  String get tabs_excludeFromSearchIndex => '不加入搜索索引';

  @override
  String get tabs_excludeFromSearchIndexSubtitle => '不将此容器中的页面加入本地搜索索引';

  @override
  String get tabs_excludeFromHistory => '不记录历史';

  @override
  String get tabs_excludeFromHistorySubtitle =>
      '不记录此容器中标签页的新访问，并将其页面从本地搜索中移除。现有浏览历史记录将保留。';

  @override
  String get tabs_sectionAssignments => '分配';

  @override
  String get tabs_assignedSites => '已分配的网站';

  @override
  String tabs_assignedSitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已配置 $count 条规则',
    );
    return '$_temp0';
  }

  @override
  String get tabs_assignedSitesEmptySubtitle => '将匹配的网站导向此容器';

  @override
  String get tabs_strictMode => '严格模式';

  @override
  String get tabs_strictModeSubtitle => '只允许加载已分配的网站，阻止其他所有网站';

  @override
  String get tabs_requiresCookieIsolation => '需要启用 Cookie 隔离';

  @override
  String get tabs_sectionAppLinks => '应用链接';

  @override
  String get tabs_isolatedAppLinkSettings => '独立的应用链接设置';

  @override
  String get tabs_isolatedAppLinkSettingsSubtitle =>
      '为此容器使用单独的应用打开模式和已记住的网站规则，而非全局设置';

  @override
  String get tabs_appLinkBehavior => '应用链接行为';

  @override
  String get tabs_appLinkBehaviorSubtitle => '配置此容器的应用打开模式和已记住的网站';

  @override
  String get tabs_selectColorTitle => '选择颜色';

  @override
  String get tabs_customColorTitle => '自定义颜色';

  @override
  String get tabs_hexLabel => 'Hex';

  @override
  String get tabs_hueLabel => '色相';

  @override
  String get tabs_saturationLabel => '饱和度';

  @override
  String get tabs_lightnessLabel => '亮度';

  @override
  String get tabs_chooseIconTitle => '选择图标';

  @override
  String tabs_iconCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个 MDI 图标',
    );
    return '$_temp0';
  }

  @override
  String get tabs_searchIconsHint => '搜索 MDI 图标';

  @override
  String get tabs_noIconsFound => '未找到图标。';

  @override
  String get gestures_screenTitle => '手势';

  @override
  String get gestures_builtInGestureKeywords => '滑动,轻扫,swipe';

  @override
  String get gestures_resetSwipesToDefaultsAction => '将滑动手势恢复默认';

  @override
  String get gestures_twoFingerSwipeTitle => '双指滑动';

  @override
  String get gestures_twoFingerSwipeKeywords => '容器';

  @override
  String get gestures_twoFingerSwipeAction => '下一个或上一个容器';

  @override
  String get gestures_pinchTitle => '双指捏合';

  @override
  String get gestures_pinchKeywords => '网格,列表,树状,布局,缩放';

  @override
  String get gestures_pinchAction => '网格、列表或树状布局';

  @override
  String get gestures_webPagesSectionTitle => '网页';

  @override
  String get gestures_drawnGesturesTitle => '绘制手势';

  @override
  String get gestures_drawnGesturesKeywords => '笔画,鼠标手势,stroke';

  @override
  String get gestures_drawnGesturesSubtitle => '在页面上绘制笔画来执行操作';

  @override
  String get gestures_gestureBindingsTitle => '手势绑定';

  @override
  String get gestures_gestureBindingsSubtitle => '笔画与操作的对应关系';

  @override
  String get gestures_behaviorTimingTitle => '行为与时间';

  @override
  String get gestures_behaviorTimingSubtitleShort => '笔画长度、超时、冷却时间';

  @override
  String get gestures_excludedSitesTitle => '排除的网站';

  @override
  String get gestures_excludedSitesSubtitle => '按网站停用手势';

  @override
  String get gestures_feedbackTitle => '反馈';

  @override
  String get gestures_feedbackSubtitleShort => '实时叠加层和建议';

  @override
  String get gestures_pullToRefreshTitle => '下拉刷新';

  @override
  String get gestures_pullToRefreshKeywords => '重新加载,刷新';

  @override
  String get gestures_pullToRefreshSubtitle => '在页面顶部向下滑动以重新加载';

  @override
  String get gestures_toolbarSectionTitle => '工具栏';

  @override
  String get gestures_longPressButtonsTitle => '长按按钮';

  @override
  String get gestures_longPressButtonsSubtitle => '在自定义工具栏时为每个按钮单独选择';

  @override
  String get gestures_builtInCannotBeChangedDescription => '内置，无法更改';

  @override
  String get gestures_doNothingTitle => '无操作';

  @override
  String get gestures_doNothingSubtitle => '忽略此滑动';

  @override
  String get gestures_restoreDefaultGesturesTooltip => '恢复默认手势';

  @override
  String get gestures_addGestureButtonLabel => '添加手势';

  @override
  String get gestures_restoreDefaultGesturesConfirmTitle => '恢复默认手势？';

  @override
  String get gestures_restoreDefaultGesturesConfirmContent =>
      '所有手势都将恢复为默认操作，你的更改将会丢失。';

  @override
  String get gestures_noGesturesAssignedMessage => '尚未分配任何手势。';

  @override
  String get gestures_replaceExistingGestureTitle => '替换现有手势？';

  @override
  String gestures_replaceExistingGestureContent(String action) {
    return '此笔画已分配给“$action”。保存将替换该绑定。';
  }

  @override
  String get gestures_createGestureTitle => '创建手势';

  @override
  String get gestures_editGestureTitle => '编辑手势';

  @override
  String get gestures_targetActionLabel => '目标操作';

  @override
  String get gestures_startPositionLabel => '起始位置';

  @override
  String get gestures_fingersLabel => '手指数';

  @override
  String get gestures_strokePatternLabel => '笔画序列';

  @override
  String get gestures_drawStrokePatternPlaceholder => '在下方绘制笔画序列';

  @override
  String get gestures_undoLastAction => '撤销上一步';

  @override
  String get gestures_replaceGestureButtonLabel => '替换手势';

  @override
  String get gestures_saveGestureButtonLabel => '保存手势';

  @override
  String gestures_collisionWarning(String action) {
    return '已分配给“$action”。保存将替换它。';
  }

  @override
  String get gestures_chooseActionTitle => '选择操作';

  @override
  String get gestures_behaviorTimingScreenSubtitle => '笔画长度、超时和冷却时间。';

  @override
  String get gestures_resetToDefaultsTooltip => '恢复默认';

  @override
  String get gestures_resetBehaviorTimingConfirmTitle => '重置行为与时间？';

  @override
  String get gestures_resetBehaviorTimingConfirmContent =>
      '笔画长度、超时、冷却时间和笔画间隔将恢复为默认值。你的手势绑定和其他设置将保留。';

  @override
  String get gestures_minStrokeLengthTitle => '最短笔画长度';

  @override
  String get gestures_minStrokeLengthKeywords => '大小,长度,灵敏度';

  @override
  String get gestures_timeoutTitle => '超时';

  @override
  String get gestures_timeoutKeywords => '延迟';

  @override
  String get gestures_timeoutDescription => '如果在此时间内没有绘制新的方向，笔画将被放弃。';

  @override
  String get gestures_cooldownTitle => '冷却时间';

  @override
  String get gestures_cooldownKeywords => '间隔';

  @override
  String get gestures_cooldownDescription => '两次手势触发之间的最短间隔。';

  @override
  String get gestures_strokeIntervalTitle => '笔画间隔';

  @override
  String get gestures_strokeIntervalKeywords => '防抖,抖动,误触';

  @override
  String get gestures_strokeIntervalDescription =>
      '同一手势中方向变化之间的最短时间。变化过快将中止手势，以防误触发。';

  @override
  String get gestures_offLabel => '关闭';

  @override
  String get gestures_excludedSitesDescription =>
      '在这些网站上停用手势。子域名也包括在内（例如“example.com”同样涵盖“m.example.com”）。';

  @override
  String get gestures_noSitesExcludedMessage => '没有排除的网站。';

  @override
  String get gestures_feedbackScreenSubtitle => '实时叠加层和手势建议。';

  @override
  String get gestures_liveFeedbackTitle => '实时反馈';

  @override
  String get gestures_liveFeedbackSubtitle => '绘制时显示笔画及其对应操作';

  @override
  String get gestures_suggestNextTitle => '建议后续手势';

  @override
  String get gestures_suggestNextSubtitle => '同时显示你还可以完成的其他手势';

  @override
  String get gestures_suggestAfterTitle => '显示建议前的笔画数';

  @override
  String gestures_strokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 笔',
    );
    return '$_temp0';
  }

  @override
  String get gestures_suggestAfterDescription => '显示建议前需要绘制的笔画数。';

  @override
  String get gestures_actionRestore => '恢复';

  @override
  String get gestures_actionReplace => '替换';

  @override
  String get gestures_tabBarSurfaceTitle => '标签栏滑动';

  @override
  String get gestures_tabBarSurfaceDescription => '在标签栏或侧边栏上滑动';

  @override
  String get gestures_tabViewSurfaceTitle => '标签页视图滑动';

  @override
  String get gestures_tabViewSurfaceDescription => '在标签页列表或网格中的标签页上滑动';

  @override
  String get gestures_tabBarSwipeBackwardTitle => '沿标签栏向左滑动';

  @override
  String get gestures_tabBarSwipeBackwardDescription => '在侧边栏上向上滑动效果相同';

  @override
  String get gestures_tabBarSwipeForwardTitle => '沿标签栏向右滑动';

  @override
  String get gestures_tabBarSwipeForwardDescription => '在侧边栏上向下滑动效果相同';

  @override
  String get gestures_tabBarSwipeOutwardTitle => '朝屏幕边缘滑动';

  @override
  String get gestures_tabBarSwipeOutwardDescription =>
      '底部标签栏向下，顶部标签栏向上，侧边栏向屏幕外侧';

  @override
  String get gestures_tabBarSwipeInwardTitle => '背离屏幕边缘滑动';

  @override
  String get gestures_tabBarSwipeInwardDescription =>
      '底部标签栏向上，顶部标签栏向下，侧边栏向页面内侧';

  @override
  String get gestures_tabSwipeLeftTitle => '向左滑动标签页';

  @override
  String get gestures_tabSwipeLeftDescription => '作用于被滑动的标签页，而非当前打开的标签页';

  @override
  String get gestures_tabSwipeRightTitle => '向右滑动标签页';

  @override
  String get gestures_tabSwipeRightDescription => '作用于被滑动的标签页，而非当前打开的标签页';

  @override
  String get gestures_startPositionAnywhere => '任意位置';

  @override
  String get gestures_startPositionLeftEdge => '左边缘';

  @override
  String get gestures_startPositionRightEdge => '右边缘';

  @override
  String get gestures_startPositionTopEdge => '上边缘';

  @override
  String get gestures_startPositionBottomEdge => '下边缘';

  @override
  String get gestures_startPositionLeftHalf => '左半边';

  @override
  String get gestures_startPositionRightHalf => '右半边';

  @override
  String get gestures_strokesSectionTitle => '笔画';

  @override
  String get gestures_indexMinStrokeLengthSubtitle => '被识别为一个方向的最短滑动距离';

  @override
  String get gestures_timingSectionTitle => '时间';

  @override
  String get gestures_indexTimeoutSubtitle => '未绘制新方向时放弃笔画';

  @override
  String get gestures_indexCooldownSubtitle => '两次手势触发之间的最短间隔';

  @override
  String get gestures_indexStrokeIntervalSubtitle => '方向变化过快时拒绝手势';

  @override
  String get gestures_overlaySectionTitle => '叠加层';

  @override
  String get gestures_indexSuggestAfterSubtitle => '显示建议前需要绘制的笔画数';

  @override
  String get intentGatekeeper_dialogTitle => '在 WebLibre 中打开链接？';

  @override
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  ) {
    return '$appName 正尝试在 $browserName 中打开链接。';
  }

  @override
  String get intentGatekeeper_alwaysAllow => '始终允许';

  @override
  String get intentGatekeeper_allowOnce => '允许一次';

  @override
  String get intentGatekeeper_blockOnce => '阻止一次';

  @override
  String get intentGatekeeper_alwaysBlock => '始终阻止';

  @override
  String get keyboardShortcuts_title => '键盘快捷键';

  @override
  String get keyboardShortcuts_searchHint => '搜索操作或按键';

  @override
  String get keyboardShortcuts_noMatchingActions => '没有匹配的操作。';

  @override
  String get keyboardShortcuts_overviewNoneAssigned => '尚未为浏览器操作分配任何按键。';

  @override
  String get keyboardShortcuts_overviewDisabled => '键盘快捷键已关闭。';

  @override
  String get keyboardShortcuts_enableTitle => '启用键盘快捷键';

  @override
  String get keyboardShortcuts_enableSubtitle => '通过实体键盘执行浏览器操作，即使网页处于焦点状态也有效';

  @override
  String get keyboardShortcuts_noShortcut => '无快捷键';

  @override
  String get keyboardShortcuts_tooltipChange => '更改';

  @override
  String keyboardShortcuts_tooltipRemoveChord(String chord) {
    return '移除 $chord';
  }

  @override
  String get keyboardShortcuts_tooltipResetToDefault => '恢复默认';

  @override
  String get keyboardShortcuts_addShortcut => '添加快捷键';

  @override
  String get keyboardShortcuts_changeShortcutTitle => '更改快捷键';

  @override
  String get keyboardShortcuts_restoreDefaultsTooltip => '恢复默认快捷键';

  @override
  String get keyboardShortcuts_restoreDefaultsTitle => '恢复默认快捷键？';

  @override
  String get keyboardShortcuts_restoreDefaultsContent =>
      '所有操作都将恢复为 Firefox 的默认按键，你的更改将会丢失。';

  @override
  String keyboardShortcuts_recorderInstructions(String actionTitle) {
    return '请按下“$actionTitle”的组合键。';
  }

  @override
  String get keyboardShortcuts_recorderWaitingForKeys => '等待按键…';

  @override
  String get keyboardShortcuts_recorderProblemNotAssignable =>
      '网页需要使用此按键。请同时按住 Ctrl、Alt 或 Meta，或使用功能键。';

  @override
  String get keyboardShortcuts_recorderProblemAlreadyBound => '这已经是此操作的快捷键。';

  @override
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle) {
    return '当前已被“$ownerTitle”使用。保存后将移至此处。';
  }

  @override
  String get keyboardShortcuts_actionCustomize => '自定义';

  @override
  String get keyboardShortcuts_actionReassign => '重新分配';

  @override
  String get keyboardShortcuts_actionRestore => '恢复';

  @override
  String get onboarding_actionPrevious => '上一步';

  @override
  String get onboarding_actionNext => '下一步';

  @override
  String get onboarding_actionRestore => '恢复';

  @override
  String get onboarding_restoreTargetUnreadable => '无法读取此配置文件，因此无法向其中恢复任何内容。';

  @override
  String get onboarding_welcomeBackTitle => '欢迎回来！';

  @override
  String get onboarding_welcomeReadyTitle => 'WebLibre 已准备就绪';

  @override
  String get onboarding_chooseExperience => '选择你的初始设置方式：';

  @override
  String get onboarding_modeExpressTitle => '快速开始';

  @override
  String get onboarding_modeExpressSubtitle => '使用推荐的默认设置，直接开始浏览。';

  @override
  String get onboarding_modeDetailedTitle => '自定义设置';

  @override
  String get onboarding_modeDetailedSubtitle => '配置 DNS、工具栏、扩展等。';

  @override
  String get onboarding_modeRestoreTitle => '从备份恢复';

  @override
  String get onboarding_modeRestoreSubtitle => '从加密的备份文件导入配置文件。';

  @override
  String get onboarding_updateNoticeTitle => '变化很大！';

  @override
  String get onboarding_updateNoticeBody =>
      '此次更新包含重大变更，需要你检查自己的设置。请浏览以下页面，确认你的配置。';

  @override
  String get onboarding_updateNoticeExtensions => '由于已知的迁移问题，更新后请重新检查你的扩展。';

  @override
  String get onboarding_updateNoticeSettingsPreserved =>
      '除非你在此设置过程中主动更改，否则现有设置不会被覆盖。';

  @override
  String get onboarding_eulaAcceptance =>
      '我已阅读并接受<eula>最终用户许可协议</eula>和<privacy>隐私政策</privacy>。';

  @override
  String get onboarding_privacyPolicy => '隐私政策';

  @override
  String get onboarding_eulaDocumentTitle => '最终用户许可协议';

  @override
  String get onboarding_aiFeaturesTitle => 'AI 功能';

  @override
  String get onboarding_aiOnDeviceTitle => '设备端 AI';

  @override
  String get onboarding_aiOnDeviceSubtitle => '在本地设备上运行的功能，包括容器主题和标签页建议';

  @override
  String get onboarding_aiWarningTitle => '注意事项';

  @override
  String get onboarding_aiWarningPoint1 =>
      'WebLibre 使用本地 AI 模型分析你打开的标签页标题，建议将标签页归入哪些容器以及如何为这些容器命名。所有处理完全在你的设备上进行。';

  @override
  String get onboarding_aiWarningPoint2 =>
      'AI 增强功能完全在浏览器内运行，所有数据都保留在你的设备上。本地 AI 处理尊重你的隐私，并能更快地提供容器分组和名称建议。你可以随时在设置中控制此行为。';

  @override
  String get onboarding_aiWarningPoint3 => 'AI 有时会出错，请检查建议的分组名称和所选标签页。';

  @override
  String get onboarding_searchTitle => '搜索';

  @override
  String get onboarding_searchDefaultProviderLabel => '默认搜索提供商';

  @override
  String get onboarding_searchMore => '搜索更多';

  @override
  String get onboarding_searchDefaultAutocompleteLabel => '默认自动补全提供商';

  @override
  String get onboarding_searchLoadFailedTitle => '无法加载搜索引擎';

  @override
  String get onboarding_dohTitle => 'DNS over HTTPS';

  @override
  String get onboarding_permissionsTitle => '权限';

  @override
  String get onboarding_permissionsNotificationsTitle => '通知';

  @override
  String get onboarding_permissionsNotificationsSubtitle => '用于向你发送下载相关的通知';

  @override
  String get onboarding_permissionsDefaultBrowserTitle => '默认浏览器';

  @override
  String get onboarding_permissionsDefaultBrowserSubtitle =>
      '将 WebLibre 设为默认浏览器';

  @override
  String get onboarding_privacyTitle => '隐私与加固';

  @override
  String get onboarding_privacyBrowserLanguagesTitle => '浏览器语言';

  @override
  String get onboarding_privacyBrowserLanguagesSubtitle => '配置向网站公开的语言偏好';

  @override
  String get onboarding_multipleLanguagesDetectedTitle => '检测到多种语言';

  @override
  String onboarding_multipleLanguagesWarning(int count, String locales) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你的浏览器配置了 $count 种语言（$locales）。',
    );
    return '$_temp0网站可以利用你独特的语言组合生成指纹，并在网络上跟踪你。';
  }

  @override
  String get onboarding_multipleLanguagesSuggestion =>
      '建议只保留一种浏览器语言，以减少可用于识别你的语言特征。';

  @override
  String get onboarding_reviewLanguages => '检查语言';

  @override
  String get onboarding_webEngineHardeningTitle => '全面加固网页引擎';

  @override
  String get onboarding_webEngineHardeningSubtitle => '为网页引擎应用所有推荐的安全加固首选项';

  @override
  String get onboarding_fingerprintProtectionTitle => '强化指纹保护';

  @override
  String get onboarding_fingerprintProtectionSubtitle => '加载全面的指纹保护默认设置';

  @override
  String get onboarding_compatibilityWarningTitle => '兼容性警告';

  @override
  String get onboarding_fingerprintWarningPoint1 =>
      '强化指纹保护会启用 60 多项保护目标，包括 Canvas 随机化、Navigator 伪装、媒体设备屏蔽等。';

  @override
  String get onboarding_fingerprintWarningPoint2 =>
      '这可能导致网站无法正常显示或出现异常行为。你可以在设置中微调各项保护目标。';

  @override
  String get onboarding_localNetworkProtectionTitle => '本地网络保护';

  @override
  String get onboarding_localNetworkProtectionSubtitle =>
      '网站可能会尝试访问你的设备以及家庭网络中的其他设备，例如路由器、打印机或智能家居设备。默认情况下，已知跟踪器的此类访问会被自动阻止。';

  @override
  String get onboarding_blockAllLocalNetworkTitle => '阻止所有本地网络请求';

  @override
  String get onboarding_blockAllLocalNetworkSubtitle =>
      '任何网站访问你家庭网络中的设备前都需征得许可，而不仅限于已知跟踪器';

  @override
  String get onboarding_toolbarLayoutTitle => '工具栏与布局';

  @override
  String get onboarding_ublockTitle => 'uBlock Origin';

  @override
  String get onboarding_ublockDescription =>
      'uBlock Origin（uBO）是由 **Raymond Hill** 开发的一款 CPU 和内存占用都很低的 **广谱内容拦截器**，可作为浏览器扩展在 WebLibre 中使用。\n\n默认情况下，它使用 **EasyList、EasyPrivacy、Peter Lowe\'s Blocklist、Online Malicious URL Blocklist 和 uBO 过滤规则列表** 拦截广告、跟踪器、挖矿脚本、弹出窗口、烦人的反拦截脚本、恶意网站等。\n\n还有许多其他列表可用于拦截更多内容。';

  @override
  String get onboarding_ublockInstallTitle => '安装 uBlock Origin 扩展';

  @override
  String get onboarding_ublockApplyDefaultsTitle => '应用优化的默认设置';

  @override
  String get onboarding_ublockApplyDefaultsSubtitle => '启用 WebLibre 加固过滤规则列表。';

  @override
  String get proxy_actionChange => '更改';

  @override
  String get proxy_actionFetch => '获取';

  @override
  String get proxy_actionSelectAll => '全选';

  @override
  String get proxy_actionShare => '分享';

  @override
  String get proxy_actionStart => '启动';

  @override
  String get proxy_actionStop => '停止';

  @override
  String get proxy_actionStopAndDelete => '停止并删除';

  @override
  String get proxy_actionTestConnection => '测试连接';

  @override
  String get proxy_connectionsTitle => '代理连接';

  @override
  String get proxy_addProfile => '添加配置';

  @override
  String get proxy_viewLogsTooltip => '查看日志';

  @override
  String get proxy_profilesSectionTitle => '代理配置';

  @override
  String proxy_loadProfilesFailed(String error) {
    return '无法加载代理配置：\n$error';
  }

  @override
  String get proxy_statusActive => '运行中';

  @override
  String get proxy_statusDisconnected => '未连接';

  @override
  String proxy_statusRoutingTraffic(int running, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$running/$total 个代理正在运行',
    );
    return '$_temp0';
  }

  @override
  String get proxy_statusTapToConnect => '点按一个配置以连接';

  @override
  String get proxy_stopAllTooltip => '全部停止';

  @override
  String get proxy_onionRoutingLabel => '洋葱路由';

  @override
  String get proxy_autostartLabel => '自启动';

  @override
  String get proxy_autostartTooltip => '随 WebLibre 启动';

  @override
  String proxy_egressIpTooltip(String ip) {
    return '出口 IP $ip';
  }

  @override
  String get proxy_latencyTesting => '测试中…';

  @override
  String get proxy_latencyTestRunningTooltip => '正在测试延迟';

  @override
  String get proxy_latencyNotRunningTooltip => '此配置未在运行';

  @override
  String get proxy_latencyFailed => '失败';

  @override
  String proxy_latencyMilliseconds(int ms) {
    return '$ms 毫秒';
  }

  @override
  String proxy_latencyHttpStatusTooltip(int statusCode, int ms) {
    return 'HTTP $statusCode，耗时 $ms 毫秒';
  }

  @override
  String proxy_startProxyFailed(String error) {
    return '无法启动代理：$error';
  }

  @override
  String proxy_stopProxyFailed(String error) {
    return '无法停止代理：$error';
  }

  @override
  String proxy_startBrandFailed(String brand, String error) {
    return '无法启动 $brand：$error';
  }

  @override
  String proxy_stopBrandFailed(String brand, String error) {
    return '无法停止 $brand：$error';
  }

  @override
  String get proxy_startConnectionDialogTitle => '启动代理连接？';

  @override
  String proxy_startConnectionDialogContent(String proxyTitle) {
    return '此标签页需要 $proxyTitle，但该连接未在运行。要立即启动吗？';
  }

  @override
  String get proxy_deleteProfileTitle => '删除配置？';

  @override
  String proxy_deleteProfileConfirm(String name) {
    return '要删除 $name 及其存储的机密信息吗？分配给此配置的标签页和容器将被阻止，直到你选择其他代理或清除分配。';
  }

  @override
  String proxy_deleteProfileConfirmRunning(String name) {
    return '要停止 $name，然后删除它及其存储的机密信息吗？分配给此配置的标签页和容器将被阻止，直到你选择其他代理或清除分配。';
  }

  @override
  String proxy_deleteProfileFailed(String error) {
    return '无法删除配置：$error';
  }

  @override
  String proxy_shareDialogTitle(String name) {
    return '分享“$name”';
  }

  @override
  String get proxy_shareDialogWarning => '此链接包含完整的配置，包括所有已存储的凭据。请谨慎分享。';

  @override
  String get proxy_copiedToClipboard => '已复制到剪贴板';

  @override
  String get proxy_editProfileTitle => '编辑配置';

  @override
  String get proxy_newProfileTitle => '新建配置';

  @override
  String get proxy_saveChanges => '保存更改';

  @override
  String get proxy_createProfile => '创建配置';

  @override
  String get proxy_sectionGeneral => '常规';

  @override
  String get proxy_sectionDnsOverride => 'DNS 覆盖';

  @override
  String get proxy_addMenuTip => '提示：可使用上一屏幕中的添加菜单从文件导入、粘贴分享链接或扫描二维码。';

  @override
  String proxy_wireGuardTrademarkDisclaimer(String brand) {
    return '$brand 是 Jason A. Donenfeld 的注册商标，保留所有权利。WebLibre 未获得 Jason A. Donenfeld 的认可或赞助，也与其无任何关联。';
  }

  @override
  String proxy_wireGuardConfigLabel(String brand) {
    return '$brand 配置';
  }

  @override
  String get proxy_fieldProfileName => '配置名称';

  @override
  String get proxy_fieldProtocol => '协议';

  @override
  String get proxy_protocolFixedHelper => '配置创建后协议不可更改。';

  @override
  String get proxy_customOutboundLabel => '自定义出站';

  @override
  String get proxy_startAutomaticallyTitle => '自动启动';

  @override
  String get proxy_startAutomaticallySubtitle =>
      'WebLibre 启动时连接此配置，使用它的标签页无需提示即可就绪';

  @override
  String proxy_dnsOverrideExplanation(String brand) {
    return '通过可经此连接访问的 DNS 服务器解析域名（例如企业 $brand 隧道后的内部 DoH 服务器）。保持关闭则使用自动 DNS 处理。';
  }

  @override
  String get proxy_dnsOverrideSwitchTitle => '使用此配置专用的解析器';

  @override
  String get proxy_fieldDnsServerAddress => 'DNS 服务器地址';

  @override
  String get proxy_sectionOutbound => '出站';

  @override
  String get proxy_sectionSecrets => '机密信息';

  @override
  String get proxy_fieldOutboundJson => '出站 JSON';

  @override
  String get proxy_outboundJsonHelper => '公开的 sing-box 出站对象。';

  @override
  String get proxy_fieldSecretJson => '机密 JSON';

  @override
  String get proxy_secretJsonHelper => '运行时合并到出站配置中的可选值。';

  @override
  String get proxy_sectionConnection => '连接';

  @override
  String get proxy_sectionCredentials => '凭据';

  @override
  String get proxy_sectionProtocolOptions => '协议选项';

  @override
  String get proxy_sectionTls => 'TLS';

  @override
  String get proxy_sectionTransport => '传输层';

  @override
  String get proxy_sectionMultiplex => '多路复用';

  @override
  String get proxy_sectionDial => '拨号';

  @override
  String get proxy_advancedOptionsHint => '高级协议选项仍可通过自定义出站 JSON 填写。';

  @override
  String get proxy_storedInSecureStorage => '存储在安全存储中。';

  @override
  String get proxy_booleanFieldUnset => '未设置（使用默认值）';

  @override
  String get proxy_booleanFieldEnabled => '已启用';

  @override
  String get proxy_booleanFieldDisabled => '已停用';

  @override
  String get proxy_addConnectionTitle => '添加连接';

  @override
  String get proxy_addConnectionSubtitle => '选择添加代理配置的方式。';

  @override
  String get proxy_methodClipboardTitle => '剪贴板';

  @override
  String get proxy_methodClipboardSubtitle => '粘贴分享链接或 URI';

  @override
  String get proxy_methodScanQrTitle => '扫描二维码';

  @override
  String get proxy_methodScanQrSubtitle => '来自其他设备';

  @override
  String get proxy_methodSubscriptionTitle => '订阅';

  @override
  String get proxy_methodSubscriptionSubtitle => '从网址获取';

  @override
  String get proxy_methodImportFileTitle => '导入文件';

  @override
  String get proxy_methodImportFileSubtitle => '.conf 或 sing-box JSON';

  @override
  String get proxy_enterManually => '手动输入';

  @override
  String get proxy_clipboardEmpty => '剪贴板为空。';

  @override
  String get proxy_importFromFileTitle => '从文件导入';

  @override
  String get proxy_importFileWireGuardSubtitle =>
      '包含 [Interface]/[Peer] 的 .conf 文件';

  @override
  String get proxy_importFileSingboxJsonTitle => 'sing-box 出站 JSON';

  @override
  String get proxy_importFileSingboxJsonSubtitle =>
      'Shadowsocks、Trojan、VMess、VLESS、Hysteria…';

  @override
  String proxy_importedProfileNamed(String name) {
    return '已导入配置“$name”';
  }

  @override
  String get proxy_importSubscriptionTitle => '导入订阅';

  @override
  String get proxy_fieldSubscriptionUrl => '订阅网址';

  @override
  String get proxy_subscriptionUrlRequired => '请输入完整的 https:// 订阅网址。';

  @override
  String proxy_subscriptionHttpError(int statusCode) {
    return '订阅服务器返回了 HTTP $statusCode。';
  }

  @override
  String get proxy_subscriptionTimedOut => '订阅服务器未能及时响应。';

  @override
  String proxy_subscriptionFetchFailed(String error) {
    return '无法获取订阅：$error';
  }

  @override
  String get proxy_subscriptionFormatHint =>
      '支持 v2rayN 格式：由 ss://、vless://、vmess://、trojan://、hysteria2://、tuic:// 等 URI 组成的 base64 编码列表。订阅中的路由规则将被忽略——仅导入代理节点。';

  @override
  String proxy_importedProfileDefaultName(int n) {
    return '已导入 $n';
  }

  @override
  String proxy_importedProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个配置',
    );
    return '$_temp0';
  }

  @override
  String proxy_importProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导入 $count 个配置',
    );
    return '$_temp0';
  }

  @override
  String proxy_subscriptionNodeSummary(int usable, int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable 个可用节点，$failed 个失败',
    );
    String _temp1 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable 个可用节点',
    );
    String _temp2 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$_temp0',
      zero: '$_temp1',
    );
    return '$_temp2';
  }

  @override
  String get proxy_logsTitle => '代理日志';

  @override
  String get proxy_logsCopyAllTooltip => '全部复制';

  @override
  String get proxy_logsClearTooltip => '清除日志';

  @override
  String get proxy_logsShareSubject => '代理日志';

  @override
  String get proxy_logsNoLinesMatchFilter => '没有符合当前筛选条件的日志行';

  @override
  String proxy_logsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已将 $count 行复制到剪贴板',
    );
    return '$_temp0';
  }

  @override
  String get proxy_logsShowAllLevels => '显示所有级别';

  @override
  String get proxy_logsShowErrorsOnly => '仅显示错误';

  @override
  String get proxy_logsShowWarningsAndAbove => '显示警告及以上级别';

  @override
  String get proxy_logsShowInfoAndAbove => '显示信息及以上级别';

  @override
  String get proxy_logsShowDebugAndAbove => '显示调试及以上级别';

  @override
  String get proxy_logsShowTraceAndAbove => '显示跟踪及以上级别';

  @override
  String get proxy_logsLatest => '最新';

  @override
  String get proxy_logsEmptyFiltered => '此级别没有日志行。请降低显示筛选级别或提高代理的日志级别。';

  @override
  String proxy_logsEmpty(String brand) {
    return '暂无日志。启动代理或 $brand 后即可在此查看输出。';
  }

  @override
  String get proxy_recordingLevelWarn => '正在记录警告和错误';

  @override
  String get proxy_recordingLevelInfo => '正在记录信息级别——这会降低浏览速度';

  @override
  String get proxy_recordingLevelDebug => '正在记录调试级别——这会降低浏览速度';

  @override
  String get proxy_recordingLevelTrace => '正在记录跟踪级别——这会降低浏览速度';

  @override
  String get proxy_logLevelAll => '全部';

  @override
  String get proxy_logLevelTrace => '跟踪';

  @override
  String get proxy_logLevelDebug => '调试';

  @override
  String get proxy_logLevelInfo => '信息';

  @override
  String get proxy_logLevelWarnings => '警告';

  @override
  String get proxy_logLevelErrors => '错误';

  @override
  String get proxy_logLevelSheetTitle => '代理日志级别';

  @override
  String get proxy_logLevelSheetExplanation =>
      '请仅在诊断问题时提高此级别，之后再改回来。更改此项会重启所有正在运行的代理。';

  @override
  String get proxy_verboseLoggingWarning => '详细日志会为每个连接和 DNS 查询写入一行，明显降低浏览速度。';

  @override
  String get proxy_logVerbosityWarnLabel => '警告和错误';

  @override
  String get proxy_logVerbosityInfoLabel => '信息';

  @override
  String get proxy_logVerbosityDebugLabel => '调试';

  @override
  String get proxy_logVerbosityTraceLabel => '跟踪';

  @override
  String get proxy_logVerbosityWarnDescription => '正常运行。问题仍会被记录。';

  @override
  String get proxy_logVerbosityInfoDescription => '每个连接和 DNS 查询。会降低浏览速度。';

  @override
  String get proxy_logVerbosityDebugDescription => '信息级别加上协议细节。会降低浏览速度。';

  @override
  String get proxy_logVerbosityTraceDescription =>
      'sing-box 能输出的一切内容。会大幅降低浏览速度。';

  @override
  String get proxy_loadingProxyTitle => '正在加载代理…';

  @override
  String proxy_torConnectionSubtitle(String torBrand) {
    return '经由 $torBrand 网络路由';
  }

  @override
  String get proxy_routingTitle => '代理路由';

  @override
  String get proxy_routingSubtitle => '选择承载普通和隐私标签页流量的代理。';

  @override
  String get proxy_routingSectionRegularTabs => '普通标签页';

  @override
  String get proxy_routingSectionRegularTabsKeywords => '路由,分流';

  @override
  String get proxy_routingSectionPrivateTabs => '隐私标签页';

  @override
  String get proxy_routingSectionPrivateTabsKeywords => '隐私,无痕';

  @override
  String get proxy_routingRegularTabsModeTitle => '普通标签页路由模式';

  @override
  String get proxy_routingRegularTabsModeKeywords => '容器,全局';

  @override
  String get proxy_routingRegularTabsModeSubtitle => '选择普通标签页如何经由代理路由';

  @override
  String get proxy_routingGlobalProxyTitle => '全局路由代理';

  @override
  String get proxy_routingGlobalProxyKeywords => '代理';

  @override
  String get proxy_routingGlobalProxySubtitle => '启用全局路由时所选的代理';

  @override
  String get proxy_routingPrivateTabsProxyTitle => '隐私标签页代理';

  @override
  String get proxy_routingPrivateTabsProxyKeywords => '代理';

  @override
  String get proxy_routingPrivateTabsProxySubtitle => '承载隐私标签页流量的代理';

  @override
  String get proxy_routingContainerBasedTitle => '基于容器的路由';

  @override
  String get proxy_routingContainerBasedSubtitle => '仅路由已分配代理的容器中的标签页。';

  @override
  String get proxy_routingGlobalRoutingTitle => '全局路由';

  @override
  String get proxy_routingGlobalRoutingSubtitle => '将普通标签页经由所选代理路由，除非容器绕过它。';

  @override
  String get proxy_routingNotUsedTitle => '基于容器的路由不使用此项';

  @override
  String get proxy_routingNotUsedSubtitle => '切换到上方的全局路由，即可选择承载所有普通标签页的代理。';

  @override
  String get proxy_routingNoneTitle => '无';

  @override
  String get proxy_routingNoneSubtitle => '使用浏览器的普通连接';

  @override
  String get proxy_routingUnknownProxySubtitle => '所选代理已不存在。';

  @override
  String get proxy_unknownProxyTitle => '未知代理';

  @override
  String get proxy_connectionPickerTitle => '代理连接';

  @override
  String get proxy_pickerUnknownProxySubtitle => '此代理配置已不存在';

  @override
  String get proxy_fieldServerAddress => '服务器地址';

  @override
  String get proxy_fieldServerPort => '服务器端口';

  @override
  String get proxy_fieldUsername => '用户名';

  @override
  String get proxy_fieldPassword => '密码';

  @override
  String get proxy_fieldUuid => 'UUID';

  @override
  String get proxy_fieldTlsEnabled => '启用 TLS';

  @override
  String get proxy_fieldTlsEnabledHelper => 'true 或 false。';

  @override
  String get proxy_fieldTlsServerName => 'TLS 服务器名称';

  @override
  String get proxy_fieldTlsInsecure => '允许无效的 TLS 证书';

  @override
  String get proxy_fieldTlsInsecureHelper => 'true 或 false。';

  @override
  String get proxy_fieldTlsAlpn => 'TLS ALPN';

  @override
  String get proxy_fieldTlsAlpnHelper => '以逗号分隔，或每行一个值。';

  @override
  String get proxy_fieldTransportType => '传输类型';

  @override
  String get proxy_fieldTransportTypeHelper => '例如 ws、http、grpc 或 quic。';

  @override
  String get proxy_fieldTransportPath => '传输路径';

  @override
  String get proxy_fieldGrpcServiceName => 'gRPC 服务名称';

  @override
  String get proxy_fieldMultiplexEnabled => '启用多路复用';

  @override
  String get proxy_fieldMultiplexEnabledHelper => 'true 或 false。';

  @override
  String get proxy_fieldMultiplexProtocol => '多路复用协议';

  @override
  String get proxy_fieldMultiplexMaxConnections => '多路复用最大连接数';

  @override
  String get proxy_fieldDialDetour => '拨号绕行（Detour）';

  @override
  String get proxy_fieldBindInterface => '绑定接口';

  @override
  String get proxy_fieldRoutingMark => '路由标记';

  @override
  String get proxy_fieldDomainStrategy => '域名策略';

  @override
  String get proxy_fieldDomainStrategyHelper => '例如 prefer_ipv4 或 prefer_ipv6。';

  @override
  String get proxy_fieldConnectTimeout => '连接超时';

  @override
  String get proxy_fieldConnectTimeoutHelper => '例如 5s。';

  @override
  String get proxy_fieldSocksVersion => 'SOCKS 版本';

  @override
  String get proxy_fieldMethod => '加密方法';

  @override
  String get proxy_fieldSecurity => '安全性';

  @override
  String get proxy_fieldAlterId => 'Alter ID';

  @override
  String get proxy_fieldFlow => '流控（Flow）';

  @override
  String get proxy_fieldAuthString => '认证字符串';

  @override
  String get proxy_fieldUploadBandwidth => '上传带宽';

  @override
  String get proxy_fieldDownloadBandwidth => '下载带宽';

  @override
  String get proxy_fieldObfuscation => '混淆';

  @override
  String get proxy_fieldReceiveWindowConn => '连接接收窗口';

  @override
  String get proxy_fieldReceiveWindow => '接收窗口';

  @override
  String get proxy_fieldDisableMtuDiscovery => '停用 MTU 发现';

  @override
  String get proxy_fieldDisableMtuDiscoveryHelper => 'true 或 false。';

  @override
  String get proxy_fieldUploadMbps => '上传速率（Mbps）';

  @override
  String get proxy_fieldDownloadMbps => '下载速率（Mbps）';

  @override
  String get proxy_fieldObfuscationType => '混淆类型';

  @override
  String get proxy_fieldObfuscationPassword => '混淆密码';

  @override
  String get proxy_fieldCongestionControl => '拥塞控制';

  @override
  String get proxy_fieldUdpRelayMode => 'UDP 中继模式';

  @override
  String get proxy_fieldZeroRttHandshake => '0-RTT 握手';

  @override
  String get proxy_fieldZeroRttHandshakeHelper => 'true 或 false。';

  @override
  String get proxy_fieldUser => '用户';

  @override
  String get proxy_fieldPrivateKey => '私钥';

  @override
  String get proxy_fieldPrivateKeyPassphrase => '私钥密码';

  @override
  String get proxy_fieldLocalAddress => '本地地址';

  @override
  String get proxy_fieldLocalAddressHelper =>
      '此设备在隧道内的地址，每行一个——例如 10.0.0.2/32。不带前缀的地址视为单个地址（/32，IPv6 则为 /128）。';

  @override
  String get proxy_fieldPeerPublicKey => '对端公钥';

  @override
  String get proxy_fieldWireguardPrivateKey => '私钥';

  @override
  String get proxy_fieldWireguardPrivateKeyHelper => '存储在安全存储中，而非配置 JSON 中。';

  @override
  String get proxy_fieldPreSharedKey => '预共享密钥';

  @override
  String get proxy_fieldPreSharedKeyHelper => '可选。存储在安全存储中。';

  @override
  String get proxy_fieldMtu => 'MTU';

  @override
  String get proxy_fieldMtuHelper =>
      '如果隧道能连接但页面始终无法加载，请调低此值：超过路径允许大小的数据包会被直接丢弃。1280 几乎在任何地方都是安全的；如果已连接到其他 VPN，请使用 1200 左右。';

  @override
  String get proxy_fieldPersistentKeepalive => '持久保活';

  @override
  String get proxy_fieldPersistentKeepaliveHelper =>
      '保活数据包之间的间隔秒数。手机通常位于 NAT 之后；没有保活，映射可能会在空闲时过期。届时对端将无法再访问手机，连接会停滞直到下一次握手。设为 0 可停用。';

  @override
  String get proxy_fieldReservedBytes => '保留字节';

  @override
  String get proxy_fieldReservedBytesHelper => '可选。三个以逗号分隔的数字，例如 0,0,0。';

  @override
  String get proxy_fieldShadowTlsVersion => '版本';

  @override
  String proxy_fieldErrorRequired(String field) {
    return '“$field”为必填项。';
  }

  @override
  String proxy_fieldErrorNotPositiveNumber(String field) {
    return '“$field”必须是正数。';
  }

  @override
  String proxy_fieldErrorPortRange(String field) {
    return '“$field”必须介于 1 和 65535 之间。';
  }

  @override
  String proxy_fieldErrorListLength(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '“$field”必须包含 $count 个数字。',
    );
    return '$_temp0';
  }

  @override
  String proxy_fieldErrorNotAllNumbers(String field) {
    return '“$field”只能包含数字。';
  }

  @override
  String proxy_fieldErrorBelowMin(String field, int min) {
    return '“$field”中的数字必须大于或等于 $min。';
  }

  @override
  String proxy_fieldErrorAboveMax(String field, int max) {
    return '“$field”中的数字必须小于或等于 $max。';
  }

  @override
  String proxy_fieldErrorInvalidCidr(String field, String value) {
    return '“$field”必须包含 IP 地址（可带 /前缀长度）——“$value”不是有效地址。';
  }

  @override
  String proxy_fieldErrorNotBoolean(String field) {
    return '“$field”必须是 true 或 false。';
  }

  @override
  String proxy_fieldErrorNotAllowedValue(String field, String values) {
    return '“$field”必须是以下值之一：$values。';
  }

  @override
  String get proxy_saveErrorAlreadySaving => '配置正在保存中。';

  @override
  String get proxy_saveErrorNameRequired => '必须填写配置名称。';

  @override
  String get proxy_saveErrorStillLoading => '配置仍在加载中，请稍候。';

  @override
  String get proxy_saveErrorConfigNotJson => '配置必须是 JSON 对象。';

  @override
  String get proxy_saveErrorSecretsNotJson => '机密信息必须是 JSON 对象。';

  @override
  String proxy_saveErrorUnexpected(String error) {
    return '无法保存代理配置：$error';
  }

  @override
  String get proxy_loadErrorNotFound => '找不到代理配置。';

  @override
  String proxy_loadErrorFailed(String error) {
    return '无法加载代理配置：$error';
  }

  @override
  String get qrScanner_noCameraPermission => '未授予相机权限。';

  @override
  String get qrScanner_scanCodeTitle => '扫描二维码';

  @override
  String get searchCredits_couldNotLoadTitle => '无法加载额度';

  @override
  String get searchCredits_title => '搜索额度';

  @override
  String get searchCredits_errorSubtitle => '请检查网络连接，然后点按刷新重试。';

  @override
  String get searchCredits_emptySubtitle => '购买搜索套餐即可开始使用';

  @override
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  ) {
    return '额度：$credits / $allowance  ·  已存令牌：$stash';
  }

  @override
  String searchCredits_creditsNoAllowance(int credits, int stash) {
    return '额度：$credits  ·  已存令牌：$stash';
  }

  @override
  String get searchCredits_tooltipRefresh => '刷新';

  @override
  String searchCredits_resetsOn(String date) {
    return '将于 $date 重置';
  }

  @override
  String searchCredits_lastIssuance(String relative, String absolute) {
    return '上次发放：$relative（$absolute）';
  }

  @override
  String get searchCredits_requestingTokens => '正在请求令牌…';

  @override
  String searchCredits_issuanceFailed(String error) {
    return '令牌发放失败：$error';
  }

  @override
  String get searchCredits_needsReauth => '请重新登录以请求令牌。';

  @override
  String get searchCredits_buySearchPackTitle => '购买搜索套餐';

  @override
  String get searchCredits_getTokensTitle => '获取令牌';

  @override
  String searchCredits_requestTokensCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '请求 $count 个令牌',
    );
    return '$_temp0';
  }

  @override
  String get searchCredits_noCreditsRemaining => '没有剩余额度';

  @override
  String get searchCredits_buyMoreTitle => '购买更多';

  @override
  String get settings_advancedTitle => '高级';

  @override
  String get settings_advancedSubtitle => '引擎行为、运行时覆盖和开发者工具。';

  @override
  String get settings_javascriptTitle => '启用 JavaScript';

  @override
  String get settings_javascriptKeywords => 'javascript,js,脚本';

  @override
  String get settings_javascriptSubtitle =>
      '关闭 JavaScript 可以提高安全性、隐私性和速度，但可能导致部分网站无法正常工作。';

  @override
  String get settings_userAgentLabel => '自定义用户代理（User Agent）';

  @override
  String get settings_userAgentLabelKeywords => 'ua,user agent,用户代理';

  @override
  String get settings_enterpriseRootsTitle => '使用第三方 CA 证书';

  @override
  String get settings_enterpriseRootsKeywords => '证书,企业根证书,ca,enterprise roots';

  @override
  String get settings_enterpriseRootsSubtitle => '允许使用 Android CA 存储中的第三方证书';

  @override
  String get settings_experimentalFeaturesTitle => '实验性功能';

  @override
  String get settings_experimentalFeaturesKeywords => '运行时,启动';

  @override
  String get settings_experimentalFeaturesSubtitle => '底层运行时功能和启动行为';

  @override
  String get settings_unmountGeckoViewTitle => '在屏幕外卸载引擎';

  @override
  String get settings_unmountGeckoViewKeywords => 'geckoview,内存,性能,挂起';

  @override
  String get settings_unmountGeckoViewSubtitle =>
      '在打开全屏视图（如设置、标签页或搜索）时将网页引擎从内存中移除，返回时再重建。这可以在此期间释放资源。返回页面时需要重新挂载引擎，可能会出现闪烁或重新加载，因此这是用性能换取内存，而不是修复问题。在 Android 12 及更早版本上，引擎总是会被卸载。';

  @override
  String get settings_iconCacheTitle => '图标缓存';

  @override
  String get settings_iconCacheKeywords => '网站图标,favicon,缓存';

  @override
  String get settings_iconCacheSubtitle => '已存储的网站图标';

  @override
  String get settings_iconCacheSizeLabel => '大小';

  @override
  String get settings_clearingAction => '正在清除';

  @override
  String get settings_mlDownloadsTitle => '机器学习下载';

  @override
  String get settings_mlDownloadsKeywords => 'ai,ml,模型,onnx,缓存,机器学习';

  @override
  String get settings_mlDownloadsSubtitle => '已下载的 AI 模型和运行时文件';

  @override
  String get settings_mlDownloadsClearDialogTitle => '清除机器学习下载？';

  @override
  String get settings_mlDownloadsClearDialogContent =>
      '这将清除此配置文件已下载的 AI 模型和 ONNX 运行时文件，需要时会重新下载。重试机器学习功能前请重启 WebLibre。';

  @override
  String get settings_mlDownloadsClearedMessage => '机器学习下载已清除。重试前请重启 WebLibre。';

  @override
  String settings_mlDownloadsClearFailedMessage(String error) {
    return '无法清除机器学习下载：$error';
  }

  @override
  String get settings_errorLogsTitle => '错误日志';

  @override
  String get settings_errorLogsKeywords => '日志,logs';

  @override
  String get settings_errorLogsSubtitle => '查看并复制日志以报告问题';

  @override
  String get settings_dartVmTitle => 'Dart VM';

  @override
  String get settings_dartVmKeywords => 'service url,服务地址';

  @override
  String get settings_dartVmSubtitle => '复制 Dart VM 服务地址';

  @override
  String get settings_dartVmCopyErrorFallback => '错误';

  @override
  String get settings_serviceUrlCopiedMessage => '服务地址已复制';

  @override
  String get settings_resetUiTitle => '重置界面';

  @override
  String get settings_resetUiKeywords => '刷新界面,ui';

  @override
  String get settings_resetUiSubtitle => '重建整个浏览器界面';

  @override
  String get settings_addonCollectionTitle => '自定义扩展合集';

  @override
  String get settings_addonCollectionSourceSectionTitle => '合集来源';

  @override
  String get settings_addonCollectionConfigTitle => '合集配置';

  @override
  String get settings_addonCollectionConfigKeywords =>
      '附加组件,扩展,合集,addons,collection';

  @override
  String get settings_addonCollectionConfigSubtitle => 'Mozilla 服务器、合集所有者和合集名称';

  @override
  String get settings_addonCollectionServerUrlLabel => '服务器网址';

  @override
  String get settings_addonCollectionUserLabel => '合集用户';

  @override
  String get settings_addonCollectionNameLabel => '合集名称';

  @override
  String get settings_addonCollectionActionsSectionTitle => '操作';

  @override
  String get settings_addonCollectionSaveRestartTitle => '保存并重启浏览器';

  @override
  String get settings_addonCollectionSaveRestartKeywords => '重启';

  @override
  String get settings_addonCollectionSaveRestartSubtitle => '应用自定义合集并重启浏览器';

  @override
  String get settings_bangSettingsTitle => 'Bang 设置';

  @override
  String get settings_bangSettingsKeywords => '快捷方式,bang,bangs';

  @override
  String get settings_bangSettingsSubtitle => 'Bang 快捷方式的使用情况、存储库和按需同步。';

  @override
  String get settings_bangFrequenciesTitle => 'Bang 使用频率';

  @override
  String get settings_bangFrequenciesKeywords => '使用情况,推荐';

  @override
  String get settings_bangFrequenciesSubtitle => '用于 Bang 推荐的使用记录';

  @override
  String get settings_browsingTitle => '浏览';

  @override
  String get settings_browsingSubtitle => '标签页、导航、应用链接和小众网络行为。';

  @override
  String get settings_newTabDefaultTitle => '新标签页默认类型';

  @override
  String get settings_newTabDefaultKeywords => '普通,隐私,隔离';

  @override
  String get settings_newTabDefaultSubtitle => '选择手动创建的标签页的默认类型';

  @override
  String get settings_tabTypeRegularLabel => '普通';

  @override
  String get settings_tabTypePrivateLabel => '隐私';

  @override
  String get settings_tabTypeIsolatedLabel => '隔离';

  @override
  String get settings_smallWebTabDefaultTitle => '小众网络标签页默认类型';

  @override
  String get settings_smallWebTabDefaultKeywords => '普通,隐私,隔离';

  @override
  String get settings_smallWebTabDefaultSubtitle => '选择进入小众网络时使用的标签页类型';

  @override
  String get settings_externalLinkHandlingTitle => '外部链接处理';

  @override
  String get settings_externalLinkHandlingKeywords => 'intent,外部链接';

  @override
  String get settings_externalLinkHandlingSubtitle => '选择外部链接在 WebLibre 中的打开方式';

  @override
  String get settings_promptOptionLabel => '询问';

  @override
  String get settings_externalLinkPromptSubtitle => '询问外部链接应如何打开';

  @override
  String get settings_externalLinkRegularSubtitle => '在普通标签页中打开外部链接';

  @override
  String get settings_externalLinkPrivateSubtitle => '在隐私标签页中打开外部链接';

  @override
  String get settings_externalLinkIsolatedSubtitle => '在隔离标签页中打开外部链接';

  @override
  String get settings_bookmarkOpenBehaviorTitle => '书签打开方式';

  @override
  String get settings_bookmarkOpenBehaviorKeywords => '书签,打开,自定义标签页,隔离';

  @override
  String get settings_bookmarkOpenBehaviorSubtitle => '选择点按书签时的打开方式';

  @override
  String get settings_bookmarkOpenPromptSubtitle => '询问书签应如何打开';

  @override
  String get settings_bookmarkOpenRegularSubtitle => '在普通标签页中打开书签';

  @override
  String get settings_bookmarkOpenPrivateSubtitle => '在隐私标签页中打开书签';

  @override
  String get settings_customTabOptionLabel => '自定义标签页';

  @override
  String get settings_bookmarkOpenCustomTabSubtitle => '在轻量的自定义标签页中打开书签';

  @override
  String get settings_bookmarkOpenIsolatedSubtitle => '在隔离标签页中打开书签';

  @override
  String get settings_tabListDirectionTitle => '标签页列表方向';

  @override
  String get settings_tabListDirectionKeywords => '排序,顺序';

  @override
  String get settings_tabListDirectionSubtitle => '选择最新的标签页显示在标签页列表的顶部还是底部';

  @override
  String get settings_directionNewestFirstLabel => '最新优先';

  @override
  String get settings_directionOldestFirstLabel => '最早优先';

  @override
  String get settings_tabBarDirectionTitle => '标签栏方向';

  @override
  String get settings_tabBarDirectionKeywords => '排序,顺序';

  @override
  String get settings_tabBarDirectionSubtitle => '选择最新的标签页显示在快速切换栏的左侧还是右侧';

  @override
  String get settings_childTabPlacementTitle => '新子标签页位置';

  @override
  String get settings_childTabPlacementKeywords =>
      '子标签页,新标签页,位置,顺序,列表末尾,父标签页之后';

  @override
  String get settings_childTabPlacementSubtitle =>
      '选择从其他标签页打开的标签页是紧跟在打开者之后，还是放到末尾。无论哪种方式都会记住打开者，因此树状视图不受影响。';

  @override
  String get settings_childTabAfterOpenerLabel => '打开者之后';

  @override
  String get settings_childTabAtEndLabel => '末尾';

  @override
  String get settings_createChildTabsTitle => '创建子标签页';

  @override
  String get settings_createChildTabsKeywords => '子标签页';

  @override
  String get settings_createChildTabsSubtitle =>
      '显示一个按钮，用于在当前标签页下创建子标签页（仅限树状视图）';

  @override
  String get settings_showContainerUiTitle => '显示容器界面';

  @override
  String get settings_showContainerUiKeywords => '容器';

  @override
  String get settings_showContainerUiSubtitle => '显示容器选择器、菜单和管理功能';

  @override
  String get settings_showIsolatedTabUiTitle => '显示隔离标签页界面';

  @override
  String get settings_showIsolatedTabUiKeywords => '隔离标签页';

  @override
  String get settings_showIsolatedTabUiSubtitle => '在界面中显示创建隔离标签页的选项';

  @override
  String get settings_backgroundTabBehaviorTitle => '后台标签页行为';

  @override
  String get settings_backgroundTabBehaviorKeywords => '切换,后台,新标签页,提示条,提示';

  @override
  String get settings_backgroundTabBehaviorSubtitle =>
      '适用于某个操作在后台打开新标签页时，例如“在新标签页中打开”或复制标签页';

  @override
  String get settings_backgroundTabPromptTitle => '停留并提供切换';

  @override
  String get settings_backgroundTabPromptSubtitle => '保留当前标签页，并显示带有“切换”操作的提示';

  @override
  String get settings_backgroundTabSwitchTitle => '立即切换';

  @override
  String get settings_backgroundTabSwitchSubtitle => '直接跳转到新打开的标签页';

  @override
  String get settings_tabBarSwipesTitle => '标签栏滑动';

  @override
  String get settings_tabBarSwipesKeywords => '手势,滑动,标签栏滑动行为';

  @override
  String get settings_tabBarSwipesSubtitle => '在“手势”中选择每种滑动的作用';

  @override
  String get settings_sequentialTabNavigationTitle => '顺序标签页导航';

  @override
  String get settings_sequentialTabNavigationKeywords =>
      '手势,滑动,下一个标签页,上一个标签页,容器,循环';

  @override
  String get settings_sequentialTabNavigationSubtitle =>
      '适用于标签栏滑动以及下一个/上一个标签页手势';

  @override
  String get settings_continueIntoNextContainerTitle => '继续进入下一个容器';

  @override
  String get settings_continueIntoNextContainerSubtitle =>
      '越过容器的第一个或最后一个标签页时，将进入相邻的容器。关闭时，导航将停留在当前容器内。';

  @override
  String get settings_loopAroundTitle => '循环切换';

  @override
  String get settings_loopAroundSubtitle => '越过最后一个标签页时将从第一个继续，反之亦然。';

  @override
  String get settings_openLinksInAppsTitle => '在应用中打开链接';

  @override
  String get settings_openLinksInAppsKeywords => '应用链接,外部应用';

  @override
  String get settings_openLinksInAppsSubtitle => '选择如何处理可以在其他应用中打开的链接';

  @override
  String get settings_appLinksAlwaysTitle => '始终';

  @override
  String get settings_appLinksAlwaysSubtitle => '始终在原生应用中打开链接，不再询问';

  @override
  String get settings_appLinksAskTitle => '打开前询问';

  @override
  String get settings_appLinksAskSubtitle => '在应用中打开链接前显示提示';

  @override
  String get settings_appLinksNeverTitle => '从不';

  @override
  String get settings_appLinksNeverSubtitle => '始终在浏览器而非应用中打开链接';

  @override
  String get settings_waitForAnswerTitle => '等待你的回答';

  @override
  String get settings_waitForAnswerSubtitle =>
      '询问期间暂停页面，而不是在后台加载。除非你选择留在浏览器中，否则不会连接该网站。';

  @override
  String get settings_offerAppStoreFallbackTitle => '提供应用商店备选';

  @override
  String get settings_offerAppStoreFallbackSubtitle =>
      '当链接指向未安装的应用且没有网页备选时，提供打开应用商店的选项';

  @override
  String get settings_allowLoginAppCallbacksTitle => '允许登录应用回调';

  @override
  String get settings_allowLoginAppCallbacksSubtitle =>
      '即使链接设为从不在应用中打开，也允许打开自定义标签页的应用接收其登录回调';

  @override
  String get settings_appLinkContainerFallbackName => '容器';

  @override
  String get settings_appLinkOverrideModeAlways => '始终在应用中打开';

  @override
  String get settings_appLinkOverrideModeAsk => '打开前询问';

  @override
  String get settings_appLinkOverrideModeNever => '始终将链接留在浏览器中';

  @override
  String get settings_appLinkContainerOverridesHeader => '拥有独立应用链接设置的容器';

  @override
  String settings_appLinkOverrideSummaryWithRules(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条已记住的规则',
    );
    return '$mode · $_temp0';
  }

  @override
  String get settings_appLinkRememberedRulesHeader => '已记住的网站规则';

  @override
  String get settings_appLinkRuleAlwaysOpenLabel => '始终在应用中打开';

  @override
  String get settings_appLinkRuleAlwaysKeepLabel => '始终留在浏览器中';

  @override
  String get settings_appLinkRuleRemoveTooltip => '移除规则';

  @override
  String get settings_globalDesktopModeTitle => '始终请求桌面版网站';

  @override
  String get settings_globalDesktopModeKeywords =>
      '桌面模式,用户代理,user agent,移动版网站,电脑版,平板';

  @override
  String get settings_globalDesktopModeSubtitle =>
      '默认以桌面模式打开新标签页。你仍可在页面菜单中为每个标签页切换桌面模式。';

  @override
  String get settings_desktopModeSitesTitle => '桌面模式网站';

  @override
  String get settings_desktopModeSitesKeywords => '桌面模式,按网站,用户代理,例外';

  @override
  String get settings_desktopModeSitesSubtitle => '始终以桌面模式加载的网站';

  @override
  String get settings_pullToRefreshTitle => '下拉刷新';

  @override
  String get settings_pullToRefreshKeywords => '重新加载,刷新';

  @override
  String get settings_pullToRefreshSubtitle => '在页面上向下滑动以重新加载';

  @override
  String get settings_customTabsTitle => '自定义标签页';

  @override
  String get settings_customTabsKeywords =>
      '自定义标签页,应用内浏览器,chrome custom tabs,外部应用,分享';

  @override
  String get settings_customTabsSubtitle =>
      '允许其他应用在轻量的应用内标签页中打开链接。关闭时，这些链接和分享的网址将在主浏览器中以普通标签页打开。';

  @override
  String get settings_doubleBackCloseTabTitle => '按两次返回关闭标签页';

  @override
  String get settings_doubleBackCloseTabKeywords => '返回按钮,返回键';

  @override
  String get settings_doubleBackCloseTabSubtitle =>
      '启用后，按两次返回按钮可关闭标签页。停用后，返回按钮只会在页面历史记录中后退。';

  @override
  String get settings_allowNonManifestPwaInstallTitle => '将网站安装为应用';

  @override
  String get settings_allowNonManifestPwaInstallKeywords => 'pwa,网页应用';

  @override
  String get settings_allowNonManifestPwaInstallSubtitle =>
      '允许将没有 PWA 清单的网站安装为独立应用';

  @override
  String get settings_urlCleanerTitle => '网址清理';

  @override
  String get settings_urlCleanerKeywords => 'utm,跟踪参数,clearurls';

  @override
  String get settings_urlCleanerSubtitle => '跟踪移除规则和规则库更新';

  @override
  String get settings_unshortenerTitle => '短链接还原';

  @override
  String get settings_unshortenerKeywords => '短链接,重定向';

  @override
  String get settings_unshortenerSubtitle => '短链接解析器和 API 令牌';

  @override
  String get settings_contextualToolbarSearchHint => '搜索工具栏按钮';

  @override
  String get settings_contextualToolbarTitleDefault => '自定义工具栏';

  @override
  String get settings_contextualToolbarTitleQuickSwitcher => '自定义切换栏按钮';

  @override
  String get settings_contextualToolbarResetToDefaults => '恢复默认';

  @override
  String get settings_contextualToolbarEnabledSection => '已启用';

  @override
  String get settings_contextualToolbarDisabledSection => '已停用';

  @override
  String get settings_contextualToolbarNoEnabledButtons =>
      '没有已启用的按钮。打开下方按钮的开关即可启用。';

  @override
  String settings_contextualToolbarNoEnabledButtonsMatch(String query) {
    return '没有与“$query”匹配的已启用按钮。';
  }

  @override
  String get settings_contextualToolbarAllButtonsEnabled => '所有按钮均已启用。';

  @override
  String settings_contextualToolbarNoDisabledButtonsMatch(String query) {
    return '没有与“$query”匹配的已停用按钮。';
  }

  @override
  String get settings_longPressNoneTitle => '无';

  @override
  String get settings_longPressNoneDescription => '此按钮的默认设置：长按不执行额外操作';

  @override
  String get settings_longPressDefaultDescription => '此按钮的默认设置';

  @override
  String get settings_longPressTitle => '长按';

  @override
  String get settings_longPressDescription => '长按按钮时执行的操作';

  @override
  String get settings_fallbackGreyOutLabel => '显示为灰色';

  @override
  String get settings_fallbackIfUnavailableTitle => '不可用时';

  @override
  String get settings_fallbackIfUnavailableDescription => '此按钮无法使用时改为显示';

  @override
  String get settings_customTrackingProtectionTitle => '自定义跟踪保护';

  @override
  String get settings_customTrackingProtectionSubtitle =>
      '自定义 Cookie、内容、跟踪器和指纹识别控制。';

  @override
  String get settings_fixMajorIssuesTitle => '修复网站的重大问题';

  @override
  String get settings_fixMajorIssuesSubtitle => '应用避免网站严重故障所需的例外（推荐）';

  @override
  String get settings_fixMinorIssuesTitle => '修复网站的次要问题';

  @override
  String get settings_fixMinorIssuesSubtitle => '应用例外以修复次要问题并启用便利功能';

  @override
  String get settings_blockCookiesTitle => '拦截 Cookie';

  @override
  String get settings_blockCookiesSubtitle => '根据下方的策略拦截 Cookie';

  @override
  String get settings_cookiePolicyTitle => 'Cookie 策略';

  @override
  String get settings_cookiePolicyTotalProtectionLabel => '全方位 Cookie 保护（推荐）';

  @override
  String get settings_cookiePolicyCrossSiteTrackersLabel => '跨网站和社交媒体跟踪器';

  @override
  String get settings_cookiePolicyUnvisitedLabel => '未访问过的网站';

  @override
  String get settings_cookiePolicyThirdPartyLabel => '所有第三方 Cookie';

  @override
  String get settings_cookiePolicyAllCookiesLabel => '所有 Cookie（可能导致网站无法正常工作）';

  @override
  String get settings_blockTrackingContentTitle => '拦截跟踪内容';

  @override
  String get settings_blockTrackingContentSubtitle => '拦截嵌入网站中的跟踪脚本和资源';

  @override
  String get settings_trackingScopeApplyToTitle => '应用于';

  @override
  String get settings_trackingScopeAllTabsLabel => '所有标签页';

  @override
  String get settings_trackingScopePrivateOnlyLabel => '仅隐私标签页';

  @override
  String get settings_adsAnalyticsSocialTrackersTitle => '广告、分析和社交跟踪器';

  @override
  String get settings_adsAnalyticsSocialTrackersSubtitle =>
      '拦截广告、分析、社交以及 Mozilla 社交跟踪器类别';

  @override
  String get settings_cryptominersTitle => '加密货币挖矿程序';

  @override
  String get settings_cryptominersSubtitle => '拦截利用你的设备挖掘加密货币的脚本';

  @override
  String get settings_knownFingerprintersTitle => '已知数字指纹跟踪程序';

  @override
  String get settings_knownFingerprintersSubtitle => '拦截收集信息以唯一识别你设备的脚本';

  @override
  String get settings_redirectTrackersTitle => '重定向跟踪器';

  @override
  String get settings_redirectTrackersSubtitle => '拦截通过中间网址重定向收集数据的跟踪器';

  @override
  String get settings_suspectedFingerprintersTitle => '疑似数字指纹跟踪程序';

  @override
  String get settings_suspectedFingerprintersSubtitle => '拦截其他可能被用来跟踪你的指纹识别技术';

  @override
  String get settings_desktopModeSitesScreenTitle => '桌面模式网站';

  @override
  String get settings_desktopModeSitesScreenDescription =>
      '这些网站始终以桌面模式加载，不受默认设置影响。子域名也包括在内（例如“example.com”同样涵盖“m.example.com”）。';

  @override
  String get settings_desktopModeSitesEmptyLabel => '尚未添加网站。';

  @override
  String get settings_dohTitle => 'DNS over HTTPS';

  @override
  String get settings_dohSubtitle => '加密 DNS 保护级别和解析服务器选择。';

  @override
  String get settings_errorLogsCopiedMessage => '日志已复制';

  @override
  String get settings_errorLogsSearchHint => '搜索日志消息';

  @override
  String get settings_errorLogsCopyTooltip => '复制日志';

  @override
  String get settings_errorLogsEmptyLabel => '没有可用的日志';

  @override
  String get settings_experimentalTitle => '实验性';

  @override
  String get settings_experimentalSubtitle => '运行时隔离和启动行为。';

  @override
  String get settings_isolatedContentProcessTitle => '隔离内容进程';

  @override
  String get settings_isolatedContentProcessKeywords => '重启';

  @override
  String get settings_isolatedContentProcessSubtitle => '在隔离进程中运行网页内容。需要重启应用。';

  @override
  String get settings_appZygoteProcessTitle => 'App Zygote 进程';

  @override
  String get settings_appZygoteProcessKeywords => '重启,android 10';

  @override
  String get settings_appZygoteProcessSubtitle =>
      '预加载内容服务以加快隔离进程的启动。需要 Android 10 及以上版本并重启应用。';

  @override
  String get settings_extensionsTitle => '扩展';

  @override
  String get settings_extensionsSubtitle => '管理附加组件、更新行为和扩展安全。';

  @override
  String get settings_manageExtensionsTitle => '管理扩展';

  @override
  String get settings_manageExtensionsKeywords => '附加组件,浏览器扩展,插件,addons';

  @override
  String get settings_manageExtensionsSubtitle => '浏览已安装、已停用、可用和不支持的扩展';

  @override
  String get settings_customCollectionTitle => '自定义合集';

  @override
  String get settings_customCollectionKeywords => '附加组件,扩展,addons';

  @override
  String get settings_customCollectionSubtitle => '使用自定义的 Mozilla 附加组件合集';

  @override
  String get settings_automaticUpdatesTitle => '自动更新';

  @override
  String get settings_automaticUpdatesKeywords => '附加组件,扩展,addons';

  @override
  String get settings_automaticUpdatesSubtitle => '每 12 小时自动检查并安装扩展更新';

  @override
  String settings_failedToLoadMessage(String error) {
    return '加载失败：$error';
  }

  @override
  String get settings_allowUnsignedExtensionsTitle => '允许未签名的扩展';

  @override
  String get settings_allowUnsignedExtensionsKeywords => '附加组件,扩展,addons';

  @override
  String get settings_allowUnsignedExtensionsSubtitle => '未签名的扩展未经 Mozilla 验证';

  @override
  String get settings_allowUnsignedWarningText =>
      '请仅安装来自可信来源的未签名扩展。它们可能包含恶意代码。';

  @override
  String get settings_allowUnsignedConfirmDialogTitle => '允许未签名的扩展？';

  @override
  String get settings_allowUnsignedConfirmWarningBold => '警告：这会严重削弱浏览器的安全性。';

  @override
  String get settings_allowUnsignedConfirmBody =>
      '未签名的扩展会绕过 Mozilla 的安全审核流程。恶意扩展可以：\n\n• 读取并修改你在任何网站上看到的一切内容\n• 窃取密码、银行信息和个人数据\n• 悄悄监视你的浏览活动\n• 在你的设备上安装其他恶意软件';

  @override
  String get settings_allowUnsignedConfirmFooter =>
      '仅当你是安装自己扩展的开发者，或完全信任其来源时，才启用此选项。';

  @override
  String get settings_allowAction => '允许';

  @override
  String settings_allowActionCountdown(int seconds) {
    return '允许（$seconds）';
  }

  @override
  String get settings_fingerprintProtectionTitle => '指纹保护';

  @override
  String get settings_fingerprintProtectionKeywords => '隐私,指纹,fingerprint';

  @override
  String get settings_fingerprintSearchHint => '搜索指纹覆盖目标';

  @override
  String get settings_loadDefaultsAction => '加载默认设置';

  @override
  String get settings_loadHardenedDefaultsAction => '加载强化默认设置';

  @override
  String get settings_fingerprintOverrideTargetsSection => '覆盖目标';

  @override
  String get settings_fingerprintInvalidOverride => '已保存的指纹覆盖格式无效';

  @override
  String get settings_fingerprintUnknownTarget => '已保存的指纹覆盖包含此版本未知的目标';

  @override
  String get settings_homeAndNewTabTitle => '主页与新标签页';

  @override
  String get settings_homeAndNewTabSubtitle => '主页和新标签页显示的内容';

  @override
  String get settings_addressFieldLabel => '地址';

  @override
  String get settings_homeTargetUrlEmptyError => '请输入地址，否则将显示主页';

  @override
  String get settings_homeTargetUrlInvalidError => '地址无效';

  @override
  String get settings_applyWhenLastTabClosesTitle => '关闭最后一个标签页时应用';

  @override
  String get settings_applyWhenLastTabClosesKeywords => '关闭,最后一个标签页,容器';

  @override
  String get settings_applyWhenLastTabClosesSubtitle =>
      '关闭容器中的最后一个标签页后停留在该容器，而不是打开其他地方的标签页';

  @override
  String settings_homeSearchBarCurrentlyLabel(String value) {
    return '当前：$value';
  }

  @override
  String get settings_wallpaperTitle => '壁纸';

  @override
  String get settings_wallpaperKeywords => '壁纸,背景,图片,照片,模糊,调暗,主页';

  @override
  String get settings_wallpaperSetSubtitle => '已为主页设置背景图片';

  @override
  String get settings_wallpaperUnsetSubtitle => '为主页设置背景图片';

  @override
  String get settings_customizeHomeSectionsTitle => '自定义主页版块';

  @override
  String get settings_customizeHomeSectionsKeywords => '主页,版块,快捷方式,名言,快捷操作,排序';

  @override
  String get settings_customizeHomeSectionsSubtitle => '选择主页显示的内容及其顺序';

  @override
  String get settings_customizeNewTabSectionsTitle => '自定义新标签页版块';

  @override
  String get settings_customizeNewTabSectionsKeywords => '新标签页,版块,快捷方式,排序';

  @override
  String get settings_customizeNewTabSectionsSubtitle => '选择新标签页显示的内容及其顺序';

  @override
  String get settings_browserLanguagesTitle => '浏览器语言';

  @override
  String get settings_browserLanguagesKeywords => '语言,区域,locale';

  @override
  String get settings_browserLanguagesSearchHint => '按标签搜索语言区域';

  @override
  String get settings_languageRegionSettingsSection => '语言与地区设置';

  @override
  String get settings_browserLanguagePreferenceLabel => '浏览器语言偏好';

  @override
  String get settings_customLocaleSection => '自定义语言区域';

  @override
  String get settings_addCustomLocaleTitle => '添加自定义语言区域';

  @override
  String get settings_addCustomLocaleKeywords => '语言区域标签,locale';

  @override
  String get settings_addCustomLocaleSubtitle => '输入语言区域标签，例如 en-US';

  @override
  String get settings_customLocaleFieldLabel => '自定义语言区域';

  @override
  String get settings_invalidLocaleError => '语言区域标识符无效';

  @override
  String get settings_homeTargetHomeLabel => '主页';

  @override
  String get settings_homeTargetResumeLastTabLabel => '上次打开的标签页';

  @override
  String get settings_homeTargetCustomUrlLabel => '自定义地址';

  @override
  String get settings_homeTargetHomeDescription => '显示快捷方式和你选择的版块';

  @override
  String get settings_homeTargetResumeLastTabDescription => '从上次离开的地方继续';

  @override
  String get settings_homeTargetCustomUrlDescription => '打开指定页面';

  @override
  String get settings_homeSearchBarAutoLabel => '跟随标签栏';

  @override
  String get settings_homeSearchBarTopLabel => '主页顶部';

  @override
  String get settings_homeSearchBarTabBarLabel => '在标签栏中';

  @override
  String get settings_homeSearchBarAutoDescription => '标签栏在哪一侧就显示在哪一侧';

  @override
  String get settings_homeSearchBarTopDescription => '固定在主页版块上方的搜索栏';

  @override
  String get settings_homeSearchBarTabBarDescription => '标签栏的地址栏，带有扫码和语音搜索';

  @override
  String get settings_generalTitle => '常规';

  @override
  String get settings_generalSubtitle => '外观、下载和浏览器默认设置。';

  @override
  String get settings_defaultBrowserTileTitle => '默认浏览器';

  @override
  String get settings_defaultBrowserTileKeywords => '系统浏览器';

  @override
  String get settings_defaultBrowserTileSubtitleSet => 'WebLibre 是你的默认浏览器';

  @override
  String get settings_defaultBrowserTileSubtitleNotSet => '将 WebLibre 设为默认浏览器';

  @override
  String get settings_defaultBrowserButtonDefault => '默认';

  @override
  String get settings_defaultBrowserButtonSet => '设置';

  @override
  String get settings_backupProfileTitle => '备份此配置文件';

  @override
  String get settings_backupProfileKeywords => '备份,存档,导出,保存,加密,恢复';

  @override
  String settings_backupProfileSubtitleReady(String name) {
    return '将“$name”写入加密的备份文件';
  }

  @override
  String get settings_backupProfileSubtitleError => '无法读取当前配置文件';

  @override
  String get settings_settingsTransferTileTitle => '导出与导入设置';

  @override
  String get settings_settingsTransferTileKeywords =>
      '导出,导入,设置,迁移,分享,剪贴板,json,复制';

  @override
  String get settings_settingsTransferTileSubtitle => '将设置写入文件或剪贴板，并可重新读取';

  @override
  String get settings_uiZoomTitle => '界面缩放';

  @override
  String get settings_uiZoomKeywords => '界面缩放,缩放,ui scale';

  @override
  String get settings_uiZoomSubtitle => '缩小或放大用户界面';

  @override
  String get settings_disableAnimationsTitle => '停用动画';

  @override
  String get settings_disableAnimationsKeywords => '动画,动效';

  @override
  String get settings_disableAnimationsSubtitle => '减少动态效果并关闭应用动画';

  @override
  String get settings_showModalBarrierTitle => '显示模态遮罩';

  @override
  String get settings_showModalBarrierKeywords => '对话框,底部面板,遮罩';

  @override
  String get settings_showModalBarrierSubtitle => '在对话框和底部面板后方调暗背景';

  @override
  String get settings_showSearchCloseButtonTitle => '显示关闭按钮';

  @override
  String get settings_showSearchCloseButtonKeywords =>
      '返回,关闭,忽略,墨水屏,e-ink,无障碍,新标签页';

  @override
  String get settings_showSearchCloseButtonSubtitle =>
      '添加一个按钮，无需返回手势即可关闭搜索或新标签页。这在没有返回按钮的设备上很有用。';

  @override
  String get settings_pureBlackTitle => '纯黑（OLED）';

  @override
  String get settings_pureBlackKeywords => 'oled,amoled,高对比度,黑色,深色';

  @override
  String get settings_pureBlackSubtitle => '在深色模式下使用纯黑界面，以便在 OLED 屏幕上省电';

  @override
  String get settings_themeTitle => '主题';

  @override
  String get settings_themeKeywords => '浅色,深色,主题模式,夜间模式';

  @override
  String get settings_themeModeSystem => '跟随系统';

  @override
  String get settings_themeModeLight => '浅色';

  @override
  String get settings_themeModeDark => '深色';

  @override
  String get settings_appLanguageSystemDefault => '系统默认';

  @override
  String settings_appLanguageCurrentlyLabel(String language) {
    return '当前：$language';
  }

  @override
  String get settings_appLanguageTranslationsNote =>
      '翻译刚刚推出，可能不完整或不准确，因此在你选择其他语言之前，WebLibre 将使用英语。选择“系统默认”即可跟随设备语言。';

  @override
  String get settings_refreshRateTitle => '刷新率';

  @override
  String get settings_refreshRateKeywords =>
      'fps,hz,赫兹,帧率,60hz,90hz,120hz,流畅,高刷新率,显示模式';

  @override
  String get settings_refreshRateSubtitle =>
      '在 90/120Hz 屏幕上选择“高”可获得最流畅的滚动和动画，选择“低”则可节省电量。';

  @override
  String get settings_refreshRateModeSystem => '跟随系统';

  @override
  String get settings_refreshRateModeHigh => '高';

  @override
  String get settings_refreshRateModeLow => '低';

  @override
  String get settings_downloadFolderTitle => '下载文件夹';

  @override
  String get settings_downloadFolderKeywords => '下载,文件夹,目录,存储,保存';

  @override
  String get settings_downloadFolderSubtitleDefault => '保存到系统的“下载”文件夹';

  @override
  String settings_downloadFolderSubtitleUnavailable(String folderName) {
    return '已无法访问——将保存到系统的“下载”文件夹（$folderName）';
  }

  @override
  String get settings_downloadFolderSubtitleExternalManager =>
      '由下载管理器应用选择文件的保存位置';

  @override
  String get settings_downloadFolderResetTooltip => '使用系统的“下载”文件夹';

  @override
  String get settings_externalDownloadManagerTitle => '使用外部下载管理器';

  @override
  String get settings_externalDownloadManagerKeywords => '下载,下载器';

  @override
  String get settings_externalDownloadManagerSubtitle => '使用其他应用管理下载';

  @override
  String get settings_preferredDownloadManagerTitle => '首选下载管理器';

  @override
  String get settings_preferredDownloadManagerKeywords =>
      '下载,下载管理器,始终使用,默认应用,选择器,询问';

  @override
  String get settings_preferredDownloadManagerSubtitleNotSet =>
      '未设置——下次出现选择器时勾选“始终使用此应用”';

  @override
  String settings_preferredDownloadManagerSubtitleThisApp(String appName) {
    return '$appName，每次下载前都会确认';
  }

  @override
  String settings_preferredDownloadManagerSubtitleUnavailable(
    String packageName,
  ) {
    return '已不再安装（$packageName）——每次都会询问';
  }

  @override
  String get settings_preferredDownloadManagerSubtitleExternalOff =>
      '未设置——仅在使用外部下载管理器时生效';

  @override
  String settings_preferredDownloadManagerSubtitleInactive(String appName) {
    return '$appName——外部下载管理器关闭时不会使用';
  }

  @override
  String get settings_preferredDownloadManagerClearTooltip => '清除首选管理器';

  @override
  String get settings_defaultBrowserSectionTitle => '默认浏览器';

  @override
  String get settings_defaultBrowserSectionKeywords => '浏览器默认设置';

  @override
  String get settings_indexDefaultBrowserSubtitle => '将 WebLibre 设为默认浏览器';

  @override
  String get settings_appearanceSectionTitle => '外观';

  @override
  String get settings_indexThemeSubtitle => '选择跟随系统、浅色或深色模式';

  @override
  String get settings_indexAppLanguageTitle => '应用语言';

  @override
  String get settings_indexAppLanguageKeywords => '语言,翻译,界面语言,locale';

  @override
  String get settings_indexAppLanguageSubtitle => '选择 WebLibre 自身界面使用的语言';

  @override
  String get settings_indexRefreshRateSubtitle => '请求高或低的屏幕刷新率（Android）';

  @override
  String get settings_indexShowCloseButtonSubtitle =>
      '添加一个按钮，无需返回手势即可关闭搜索/新标签页';

  @override
  String get settings_profileSectionTitle => '配置文件';

  @override
  String get settings_profileSectionKeywords => '用户,配置文件';

  @override
  String get settings_indexBackupProfileSubtitle => '为你正在使用的配置文件创建加密备份';

  @override
  String get settings_indexSettingsTransferSubtitle =>
      '在配置文件或设备之间迁移设置，或将其附加到错误报告中';

  @override
  String get settings_downloadsSectionTitle => '下载';

  @override
  String get settings_indexDownloadFolderSubtitle => '选择下载文件的保存位置';

  @override
  String get settings_indexPreferredDownloadManagerSubtitle => '无需询问即可接收下载的应用';

  @override
  String get settings_contentIdentitySectionTitle => '内容与身份';

  @override
  String get settings_contentIdentitySectionKeywords => '引擎';

  @override
  String get settings_indexJavascriptSubtitle => '开启或关闭网站脚本';

  @override
  String get settings_indexUserAgentSubtitle => '覆盖浏览器的用户代理字符串';

  @override
  String get settings_indexEnterpriseRootsSubtitle => '允许使用 Android CA 存储中的证书';

  @override
  String get settings_experimentalSectionTitle => '实验性';

  @override
  String get settings_developerToolsSectionTitle => '开发者工具';

  @override
  String get settings_developerToolsSectionKeywords => '调试,debug';

  @override
  String get settings_indexUnmountGeckoViewSubtitle =>
      '在覆盖层关闭后重建网页引擎，而不是让它保持运行';

  @override
  String get settings_tabsSectionTitle => '标签页';

  @override
  String get settings_indexTabListDirectionSubtitle => '选择列表视图中标签页的排列顺序';

  @override
  String get settings_indexTabBarDirectionSubtitle => '选择标签栏中标签页的排列顺序';

  @override
  String get settings_indexChildTabPlacementSubtitle => '选择从其他标签页打开的标签页插入的位置';

  @override
  String get settings_indexCreateChildTabsSubtitle => '显示一个按钮，用于在当前标签页下添加子标签页';

  @override
  String get settings_indexBackgroundTabBehaviorSubtitle => '选择标签页在后台打开后的行为';

  @override
  String get settings_navigationSectionTitle => '导航';

  @override
  String get settings_indexDoubleBackCloseTabSubtitle => '需要按两次返回按钮才能关闭当前标签页';

  @override
  String get settings_indexTabBarSwipesSubtitle => '选择在标签栏上滑动的作用';

  @override
  String get settings_indexSequentialTabNavigationSubtitle =>
      '选择按顺序切换标签页时在何处结束';

  @override
  String get settings_indexOpenLinksInAppsSubtitle => '选择外部应用链接的打开方式';

  @override
  String get settings_desktopModeSectionTitle => '桌面模式';

  @override
  String get settings_indexGlobalDesktopModeSubtitle => '默认以桌面模式打开新标签页';

  @override
  String get settings_homeScreenSectionTitle => '主屏幕';

  @override
  String get settings_indexAllowNonManifestPwaInstallSubtitle =>
      '允许将没有清单的网站安装为应用';

  @override
  String get settings_externalLinksSectionTitle => '外部链接';

  @override
  String get settings_indexCustomTabsSubtitle =>
      '允许其他应用在轻量的应用内标签页中打开链接，而不是在主浏览器中';

  @override
  String get settings_bookmarksSectionTitle => '书签';

  @override
  String get settings_resolverSettingsSectionTitle => '解析服务器设置';

  @override
  String get settings_indexDnsOverHttpsResolverTitle => 'DNS over HTTPS';

  @override
  String get settings_indexDnsOverHttpsResolverKeywords =>
      'doh,解析服务器,dns 提供商,自定义解析服务器,加密 dns';

  @override
  String get settings_indexDnsOverHttpsResolverSubtitle =>
      '保护级别、提供商选择和已保存的自定义解析服务器';

  @override
  String get settings_runtimeStartupSectionTitle => '运行时与启动';

  @override
  String get settings_indexIsolatedContentProcessSubtitle => '在隔离进程中运行网页内容';

  @override
  String get settings_indexAppZygoteProcessSubtitle => '预加载内容服务以加快隔离进程启动';

  @override
  String get settings_startupSectionTitle => '启动';

  @override
  String get settings_startupSectionKeywords => '启动,主页,继续,上一个标签页,自定义网址';

  @override
  String get settings_indexHomeTargetTitle => '没有可显示的标签页时';

  @override
  String get settings_indexHomeTargetKeywords => '启动,继续,上一个标签页,自定义网址,主页';

  @override
  String get settings_indexHomeTargetSubtitle => '启动时以及关闭最后一个标签页后';

  @override
  String get settings_indexHomeTargetOnLastTabClosedSubtitle =>
      '否则将改为打开其他容器中的标签页';

  @override
  String get settings_homeAppearanceSectionTitle => '外观';

  @override
  String get settings_homeAppearanceSectionKeywords => '主页,壁纸,背景,图片,模糊,调暗';

  @override
  String get settings_indexWallpaperSubtitle => '主页的背景图片';

  @override
  String get settings_layoutSectionTitle => '布局';

  @override
  String get settings_layoutSectionKeywords => '主页,新标签页,版块,模块,布局';

  @override
  String get settings_indexHomeSearchBarPlacementTitle => '搜索栏位置';

  @override
  String get settings_indexHomeSearchBarPlacementKeywords =>
      '搜索,搜索栏,位置,地址,网址,顶部,底部,标签栏,主页';

  @override
  String get settings_indexHomeSearchBarPlacementSubtitle => '主页提供搜索框的位置';

  @override
  String get settings_allowlistExceptionsSectionTitle => '允许列表例外';

  @override
  String get settings_indexAllowlistExceptionsTitle => '允许列表例外';

  @override
  String get settings_indexAllowlistExceptionsSubtitle => '针对网站重大和次要问题的兼容性例外';

  @override
  String get settings_cookiesSectionTitle => 'Cookie';

  @override
  String get settings_indexCookiesSubtitle => 'Cookie 拦截模式和策略选择';

  @override
  String get settings_trackingContentSectionTitle => '跟踪内容';

  @override
  String get settings_indexTrackingContentTitle => '跟踪内容';

  @override
  String get settings_indexTrackingContentSubtitle => '跟踪脚本及其拦截范围';

  @override
  String get settings_trackersSectionTitle => '跟踪器';

  @override
  String get settings_indexTrackersSubtitle => '加密货币挖矿程序、已知数字指纹跟踪程序和重定向跟踪器';

  @override
  String get settings_advancedFingerprintingProtectionSectionTitle => '高级指纹保护';

  @override
  String get settings_indexAdvancedFingerprintingProtectionTitle => '高级指纹保护';

  @override
  String get settings_indexAdvancedFingerprintingProtectionSubtitle =>
      '疑似数字指纹跟踪程序及标签页范围';

  @override
  String get settings_usageDataSectionTitle => '使用数据';

  @override
  String get settings_repositoriesSectionTitle => '存储库';

  @override
  String get settings_indexGeneralBangsSubtitle => '按需从 GitHub 同步';

  @override
  String get settings_generalBangsTileTitle => '通用 Bang';

  @override
  String get settings_generalBangsTileKeywords => '存储库,仓库';

  @override
  String get settings_generalBangsTileSubtitle => '按需从 GitHub 同步';

  @override
  String get settings_indexKagiBangsSubtitle => '按需从 GitHub 同步';

  @override
  String get settings_kagiBangsTileTitle => 'Kagi Bang';

  @override
  String get settings_kagiBangsTileKeywords => '存储库,仓库';

  @override
  String get settings_kagiBangsTileSubtitle => '按需从 GitHub 同步';

  @override
  String get settings_extensionsSectionTitle => '扩展';

  @override
  String get settings_updatesSectionTitle => '更新';

  @override
  String get settings_securitySectionTitle => '安全';

  @override
  String get settings_actionResetToDefaults => '恢复默认';

  @override
  String get settings_menuLayoutTitle => '自定义菜单';

  @override
  String get settings_menuLayoutHintSections => '拖动以调整顺序。关闭某个版块即可在菜单中隐藏它。';

  @override
  String get settings_menuLayoutHintSectionItems => '拖动以调整此版块中各行的顺序。';

  @override
  String get settings_menuLayoutHintSubItems => '拖动以调整此项展开后各行的顺序。';

  @override
  String get settings_moduleSurfaceHint => '拖动以调整顺序。关闭某个版块即可在此处隐藏它，不会影响另一个页面。';

  @override
  String get settings_moduleSurfaceTitleHome => '自定义主页';

  @override
  String get settings_moduleSurfaceTitleNewTab => '自定义新标签页';

  @override
  String get settings_homeSearchBarRowTitle => '搜索栏';

  @override
  String get settings_proxyTitle => '代理';

  @override
  String get settings_proxySubtitle => '管理代理连接并选择哪些标签页使用它们。';

  @override
  String get settings_proxyConnectionsTitle => '代理连接';

  @override
  String get settings_proxyConnectionsKeywords =>
      'sing-box,socks,vpn,wireguard,tor,onion,网桥,obfs4,snowflake,节点,翻墙';

  @override
  String get settings_proxyConnectionsSubtitle => '管理代理配置和连接';

  @override
  String get settings_proxyRoutingTitle => '代理路由';

  @override
  String get settings_proxyRoutingKeywords => '路由,容器,分流';

  @override
  String get settings_proxyRoutingSubtitle => '选择承载普通和隐私标签页的代理';

  @override
  String get settings_proxyLogsTitle => '代理日志';

  @override
  String get settings_proxyLogsKeywords => '日志,记录,诊断,调试,跟踪,详细,故障排除,级别,log';

  @override
  String get settings_toolbarLayoutTitle => '工具栏与布局';

  @override
  String get settings_toolbarLayoutSearchHint => '搜索工具栏与布局设置';

  @override
  String get settings_privacySecurityTitle => '隐私与安全';

  @override
  String get settings_privacySecuritySubtitle => '跟踪保护、指纹识别、浏览数据和网络加固。';

  @override
  String get settings_trackingProtectionExceptionsTitle => '跟踪保护例外';

  @override
  String get settings_trackingProtectionExceptionsKeywords => '例外';

  @override
  String get settings_trackingProtectionExceptionsTileSubtitle => '已停用跟踪保护的网站';

  @override
  String get settings_incognitoModeTitle => '无痕模式';

  @override
  String get settings_incognitoModeKeywords => '隐私模式,无痕';

  @override
  String get settings_incognitoModeSubtitle => '应用重启时删除所选的浏览数据';

  @override
  String get settings_trackingProtectionExceptionsSearchHint => '搜索例外网址';

  @override
  String get settings_trackingProtectionExceptionsDeleteAll => '全部删除';

  @override
  String get settings_trackingProtectionExceptionsSectionTitle => '例外列表';

  @override
  String get settings_trackingProtectionExceptionsEntrySubtitle => '已停用跟踪保护的网站';

  @override
  String get settings_trackingProtectionExceptionsRemoveTooltip => '移除例外';

  @override
  String get settings_trackingProtectionExceptionsEmptyTitle => '没有例外';

  @override
  String get settings_trackingProtectionExceptionsEmptySubtitle =>
      '添加到例外中的网站将显示在这里';

  @override
  String get settings_trackingProtectionExceptionsErrorTitle => '加载例外时出错';

  @override
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error) {
    return '无法删除例外：$error';
  }

  @override
  String settings_trackingProtectionExceptionsRemoveFailed(String error) {
    return '无法移除例外：$error';
  }

  @override
  String get settings_deleteBrowsingDataTileTitle => '删除浏览数据';

  @override
  String get settings_deleteBrowsingDataTileKeywords => '清除数据,清除';

  @override
  String get settings_autoClearHistoryTitle => '自动清除历史记录';

  @override
  String get settings_autoClearHistoryKeywords => '历史记录保留';

  @override
  String get settings_autoClearHistorySubtitle => '自动删除早于所选时间段的浏览历史记录';

  @override
  String get settings_autoClearUnassignedTabsTitle => '自动清除未分配的标签页';

  @override
  String get settings_autoClearUnassignedTabsKeywords => '清理标签页';

  @override
  String get settings_autoClearUnassignedTabsSubtitle => '自动关闭早于所选时间段的未分配标签页';

  @override
  String get settings_durationNever => '从不';

  @override
  String get settings_duration1Day => '1 天';

  @override
  String get settings_duration3Days => '3 天';

  @override
  String get settings_duration1Week => '1 周';

  @override
  String get settings_duration2Weeks => '2 周';

  @override
  String get settings_duration1Month => '1 个月';

  @override
  String get settings_duration3Months => '3 个月';

  @override
  String get settings_globalPrivacyControlTitle => '全球隐私控制（GPC）';

  @override
  String get settings_globalPrivacyControlKeywords =>
      'gpc,global privacy control';

  @override
  String get settings_screenshotProtectionTitle => '截图保护';

  @override
  String get settings_screenshotProtectionKeywords => '截图,截屏,录屏';

  @override
  String get settings_screenshotProtectionSubtitle =>
      '在 Android 上阻止对此应用进行截图和录屏。';

  @override
  String get settings_allowPrivateTabScreenshotsTitle => '允许在隐私标签页中截图';

  @override
  String get settings_allowPrivateTabScreenshotsKeywords => '截图,截屏,无痕,隐私';

  @override
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle =>
      '已被截图保护覆盖，截图保护会阻止所有标签页的截取。';

  @override
  String get settings_allowPrivateTabScreenshotsSubtitle =>
      '隐私标签页可以被截图和录屏，并会显示在应用切换器的预览中。';

  @override
  String get settings_httpsOnlyModeTitle => '阻止不安全的 HTTP 连接';

  @override
  String get settings_httpsOnlyModeKeywords => '仅 https,https only';

  @override
  String get settings_httpsOnlyModeDisabledLabel => '停用';

  @override
  String get settings_httpsOnlyModeEnabledLabel => '启用';

  @override
  String get settings_httpsOnlyModePrivateOnlyLabel => '仅隐私模式';

  @override
  String get settings_dnsOverHttpsTileTitle => 'DNS over HTTPS';

  @override
  String get settings_enhancedTrackingProtectionTitle => '增强型跟踪保护';

  @override
  String get settings_enhancedTrackingProtectionKeywords => 'etp,标准,严格,自定义';

  @override
  String get settings_trackingProtectionDisabledLabel => '停用';

  @override
  String get settings_trackingProtectionStandardLabel => '标准';

  @override
  String get settings_trackingProtectionStandardSubtitle =>
      '拦截较少的跟踪器类别，在保护与兼容性之间取得平衡。';

  @override
  String get settings_trackingProtectionStrictLabel => '严格';

  @override
  String get settings_trackingProtectionStrictSubtitle =>
      '拦截更多跟踪器类别（包括跟踪内容），但可能导致部分网站无法正常工作。';

  @override
  String get settings_trackingProtectionCustomLabel => '自定义';

  @override
  String get settings_trackingProtectionCustomSubtitle => '选择要拦截的跟踪器和脚本。';

  @override
  String get settings_contentBlockingDatabaseTitle => '内容拦截数据库';

  @override
  String get settings_contentBlockingDatabaseKeywords => '广告,跟踪器,内容拦截';

  @override
  String get settings_contentBlockingDatabaseSubtitle =>
      '为广告、分析和社交跟踪器等 ETP 类别使用 GeckoView 拦截列表。需要重启应用。';

  @override
  String get settings_bounceTrackingProtectionTitle => '反弹跟踪保护';

  @override
  String get settings_bounceTrackingProtectionKeywords => '重定向跟踪器';

  @override
  String get settings_bounceTrackingProtectionSubtitle =>
      '拦截通过网站之间的中间网址重定向收集数据的重定向跟踪器';

  @override
  String get settings_queryParameterStrippingTitle => '查询参数剥离';

  @override
  String get settings_queryParameterStrippingKeywords => 'utm,跟踪参数';

  @override
  String get settings_queryParameterStrippingSubtitle => '从网址中移除跟踪参数，防止跨网站用户跟踪';

  @override
  String get settings_queryParameterStrippingDisabledLabel => '停用';

  @override
  String get settings_queryParameterStrippingEnabledLabel => '启用';

  @override
  String get settings_queryParameterStrippingPrivateOnlyLabel => '仅隐私模式';

  @override
  String get settings_uBlockFilterListsTileTitle => 'uBlock 过滤规则列表与加固';

  @override
  String get settings_uBlockFilterListsTileKeywords => 'ublock,过滤器,过滤规则,广告拦截';

  @override
  String get settings_uBlockFilterListsTileSubtitle =>
      '管理过滤规则列表并应用 WebLibre 加固';

  @override
  String get settings_fissionEnabledTitle => 'Fission（站点隔离）';

  @override
  String get settings_fissionEnabledKeywords => '站点隔离,网站隔离';

  @override
  String get settings_fissionEnabledSubtitle =>
      '将每个网站隔离到单独的系统进程中以提高安全性。需要重启应用。';

  @override
  String get settings_safeBrowsingMalwareTitle => '安全浏览恶意软件防护';

  @override
  String get settings_safeBrowsingMalwareKeywords =>
      'google safe browsing,安全浏览,谷歌';

  @override
  String get settings_safeBrowsingMalwareSubtitle => '对危险网站和恶意下载发出警告。';

  @override
  String get settings_safeBrowsingPhishingTitle => '安全浏览钓鱼防护';

  @override
  String get settings_safeBrowsingPhishingKeywords =>
      'google safe browsing,安全浏览,钓鱼,谷歌';

  @override
  String get settings_safeBrowsingPhishingSubtitle => '对欺诈网站和虚假登录页面发出警告。';

  @override
  String get settings_extensionsWebApiTitle => '扩展 Web API';

  @override
  String get settings_extensionsWebApiKeywords => '扩展 api,extension api';

  @override
  String get settings_extensionsWebApiSubtitle =>
      '向网页内容和扩展页面开放 mozAddonManager API。需要重启应用。';

  @override
  String get settings_appOpeningProtectionSectionHeader => '应用打开保护';

  @override
  String get settings_blockAppsOpeningBrowserTitle => '阻止应用打开你的浏览器';

  @override
  String get settings_blockAppsOpeningBrowserKeywords =>
      'intent gatekeeper,外部应用';

  @override
  String get settings_blockAppsOpeningBrowserSubtitle =>
      '打开其他应用发送给 WebLibre 的链接前先询问。';

  @override
  String get settings_managedAppsSectionHeader => '已管理的应用';

  @override
  String get settings_managedAppAlwaysAllowedLabel => '始终允许';

  @override
  String get settings_managedAppAlwaysBlockedLabel => '始终阻止';

  @override
  String get settings_managedAppActionAllow => '允许';

  @override
  String get settings_managedAppActionBlock => '阻止';

  @override
  String get settings_browserLanguagesTileTitle => '浏览器语言';

  @override
  String get settings_browserLanguagesTileSubtitle => '配置向网站公开的语言偏好';

  @override
  String get settings_fingerprintProtectionTileTitle => '指纹保护';

  @override
  String get settings_fingerprintProtectionTileSubtitle => '精细控制浏览器指纹识别';

  @override
  String get settings_resistFingerprintingTileTitle => '抵御指纹识别';

  @override
  String get settings_resistFingerprintingTileKeywords =>
      'rfp,resist fingerprinting';

  @override
  String get settings_resistFingerprintingTileSubtitle => '高级指纹保护加固';

  @override
  String get settings_lnaEnabledTitle => '本地网络访问';

  @override
  String get settings_lnaEnabledKeywords => 'lan,局域网,本地网络';

  @override
  String get settings_lnaEnabledSubtitle => '启用对本地网络和设备访问的拦截';

  @override
  String get settings_lnaBlockingTitle => '拦截本地网络请求';

  @override
  String get settings_lnaBlockingKeywords => 'lan,局域网,本地网络';

  @override
  String get settings_lnaBlockingSubtitle => '拦截网页对本地网络地址的请求';

  @override
  String get settings_lnaBlockTrackersTitle => '拦截本地网络跟踪器';

  @override
  String get settings_lnaBlockTrackersKeywords => 'lan,局域网,本地网络';

  @override
  String get settings_lnaBlockTrackersSubtitle => '阻止跟踪器访问本地网络资源';

  @override
  String get settings_transferTitle => '导出与导入';

  @override
  String get settings_transferChangeExportFolder => '更改导出文件夹';

  @override
  String get settings_transferIntro =>
      '在配置文件或设备之间迁移设置，或将其附加到错误报告中。这只包含设置——不含标签页、历史记录、书签或登录信息。如需迁移这些内容，请备份整个配置文件。';

  @override
  String get settings_transferDeviceOnlyNote =>
      '网页搜索偏好、主页和新标签页布局、菜单顺序以及固定的附加组件会保留在此设备上';

  @override
  String get settings_transferExportSectionTitle => '导出';

  @override
  String get settings_transferExportSectionSubtitle => '将所选部分导出为可读的文件';

  @override
  String get settings_transferSaveFileButton => '保存文件';

  @override
  String get settings_transferImportSectionTitle => '导入';

  @override
  String get settings_transferImportSectionSubtitle => '打开文件后选择要应用的设置';

  @override
  String get settings_transferOpenFileButton => '打开文件';

  @override
  String get settings_transferPasteButton => '粘贴';

  @override
  String settings_transferExportFolderChanged(String name) {
    return '导出内容将保存到 $name';
  }

  @override
  String settings_transferSavedAs(String name) {
    return '已保存为 $name';
  }

  @override
  String get settings_transferExportFolderGone => '导出文件夹已不存在。请重新选择后重试。';

  @override
  String settings_transferSaveFailed(String error) {
    return '无法保存导出内容：$error';
  }

  @override
  String get settings_transferCopiedToClipboard => '设置已复制到剪贴板';

  @override
  String settings_transferCopyFailed(String error) {
    return '无法复制导出内容：$error';
  }

  @override
  String get settings_transferImportNothingApplicable =>
      '此导出中没有此版本 WebLibre 可以应用的内容。';

  @override
  String get settings_transferImportedSuccess => '设置已导入';

  @override
  String settings_transferImportFailed(String error) {
    return '无法导入设置：$error';
  }

  @override
  String get settings_transferNotASettingsFile => '该文件不是设置导出文件。';

  @override
  String settings_transferReadFileFailed(String error) {
    return '无法读取文件：$error';
  }

  @override
  String get settings_transferClipboardEmpty => '剪贴板为空。';

  @override
  String settings_transferReadClipboardFailed(String error) {
    return '无法读取剪贴板：$error';
  }

  @override
  String get settings_transferSectionAppSettingsTitle => '应用设置';

  @override
  String settings_transferSectionAppSettingsDescription(String torBrand) {
    return '外观、浏览、标签页、隐私、$torBrand 和网页引擎设置';
  }

  @override
  String get settings_transferSectionGeckoPrefsTitle => 'Gecko 首选项';

  @override
  String get settings_transferSectionGeckoPrefsDescription => '你手动更改过的高级引擎首选项';

  @override
  String get settings_importErrorNotJson => '这不是 JSON 文件。';

  @override
  String get settings_importErrorNotSettingsExport => '这不是 WebLibre 设置导出文件。';

  @override
  String get settings_importErrorMissingFormatVersion => '导出文件未注明其格式版本。';

  @override
  String settings_importErrorNewerFormatVersion(int version, int supported) {
    return '此导出文件由较新版本的 WebLibre 生成（格式 $version，此版本最高只能读取 $supported）。请更新应用后重试。';
  }

  @override
  String get settings_importErrorNoSettings => '导出文件中不包含任何设置。';

  @override
  String settings_importErrorMalformedSection(String section) {
    return '“$section”部分格式错误。';
  }

  @override
  String settings_importErrorMalformedField(String field) {
    return '导出文件的“$field”字段格式错误。';
  }

  @override
  String settings_importErrorUnreadablePrefsLine(String section, String line) {
    return '“$section”部分中有一行 WebLibre 无法读取：“$line”。导入它会重置首选项，而不是恢复它们。';
  }

  @override
  String settings_importErrorNotPrefsSnapshot(String section) {
    return '“$section”部分不是 WebLibre 首选项快照。';
  }

  @override
  String settings_importErrorMissingSchemaVersion(String section) {
    return '“$section”部分未注明其架构版本。';
  }

  @override
  String settings_importErrorUnreadablePref(String section, String pref) {
    return '“$section”部分包含一项 WebLibre 无法回读的首选项：“$pref”。';
  }

  @override
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  ) {
    return '“$section”部分由较新版本的 WebLibre 生成（架构 $version，此版本最高只能读取 $supported）。请更新应用后重试。';
  }

  @override
  String settings_importPartialFailure(String failed, String error) {
    return '“$failed”部分在中途停止，可能只应用了一半：$error';
  }

  @override
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  ) {
    return '已导入：$applied。随后“$failed”部分在中途停止，可能只应用了一半：$error';
  }

  @override
  String get settings_webEngineHardeningTitle => '网页引擎加固';

  @override
  String get settings_webEngineHardeningKeywords => '加固,安全,hardening';

  @override
  String get settings_webEngineHardeningSearchHint => '搜索加固分组';

  @override
  String get settings_webEngineHardeningResetAllMenuItem => '重置所有首选项';

  @override
  String get settings_webEngineHardeningResetAllDialogTitle => '重置所有首选项？';

  @override
  String get settings_webEngineHardeningResetAllDialogContent =>
      '这会将所有用户定义的网页引擎首选项重置为默认值。';

  @override
  String get settings_webEngineHardeningOverviewTitle => '概览';

  @override
  String get settings_webEngineHardeningCompleteTitle => '全面加固';

  @override
  String get settings_webEngineHardeningCompleteSubtitle => '应用或重置所有分组的加固首选项';

  @override
  String get settings_webEngineHardeningCompleteToggleHint =>
      '一次性切换所有分组的加固首选项。';

  @override
  String get settings_webEngineHardeningGroupsTitle => '加固分组';

  @override
  String get settings_webEngineHardeningLoadFailedTitle => '无法加载首选项设置';

  @override
  String get settings_webEngineHardeningGroupSearchHint => '搜索加固设置';

  @override
  String get settings_webEngineHardeningGroupControlsTitle => '分组控制';

  @override
  String get settings_webEngineHardeningPreferenceSettingsTitle => '首选项设置';

  @override
  String get settings_webEngineHardeningOptionalBadge => '可选';

  @override
  String get settings_settingsHomeTitle => '设置';

  @override
  String get settings_settingsHomeSearchHint => '搜索所有设置';

  @override
  String get settings_searchTitle => '搜索';

  @override
  String get settings_searchSubtitle => '提供商、Bang、历史建议和设备端搜索。';

  @override
  String get settings_defaultSearchProviderTitle => '默认搜索提供商';

  @override
  String get settings_defaultSearchProviderKeywords => '搜索引擎';

  @override
  String get settings_defaultAutocompleteProviderTitle => '默认自动补全提供商';

  @override
  String get settings_defaultAutocompleteProviderKeywords => '建议,联想';

  @override
  String get settings_customSearchEnginesTitle => '自定义搜索引擎';

  @override
  String get settings_customSearchEnginesKeywords => '自定义 bang,提供商';

  @override
  String get settings_customSearchEnginesSubtitle => '添加和管理你自己的搜索提供商';

  @override
  String get settings_bangSettingsListTitle => 'Bang 设置';

  @override
  String get settings_bangSettingsListSubtitle => '管理 Bang 存储库和使用数据';

  @override
  String get settings_searchHistoryLimitTitle => '搜索历史记录上限';

  @override
  String get settings_searchHistoryLimitKeywords => '历史记录,条目';

  @override
  String get settings_searchHistoryLimitSubtitle => '要记住的最近搜索的最大数量';

  @override
  String get settings_searchHistoryLimitSuffix => '条';

  @override
  String get settings_validationEnterValue => '请输入一个值';

  @override
  String get settings_validationEnterValidNumber => '请输入有效的数字';

  @override
  String get settings_validationValueBetween0And100 => '值必须介于 0 和 100 之间';

  @override
  String get settings_allowClipboardAccessTitle => '允许读取剪贴板以提供建议';

  @override
  String get settings_allowClipboardAccessKeywords => '剪贴板';

  @override
  String get settings_allowClipboardAccessSubtitle => '浏览器可以读取剪贴板来建议网址';

  @override
  String get settings_historySuggestionsTitle => '根据历史记录提供建议';

  @override
  String get settings_historySuggestionsKeywords => '历史建议,访问过的页面,自动补全,内联补全,隐私';

  @override
  String get settings_historySuggestionsSubtitle =>
      '输入时显示访问过的页面，并根据历史记录补全地址。关闭此项不会删除你的历史记录。';

  @override
  String get settings_privateSearchSuggestionsTitle => '在隐私标签页中提供建议';

  @override
  String get settings_privateSearchSuggestionsKeywords => '隐私,无痕,搜索建议,历史记录';

  @override
  String get settings_privateSearchSuggestionsSubtitle =>
      '在隐私标签页中输入时使用建议提供商和你的历史记录。你输入的内容将发送给提供商。';

  @override
  String get settings_acceptSuggestionOnSubmitTitle => '按回车键自动补全';

  @override
  String get settings_acceptSuggestionOnSubmitKeywords => '提交,键盘,建议,回车';

  @override
  String get settings_acceptSuggestionOnSubmitSubtitle => '按下键盘上的回车键时接受内联建议';

  @override
  String get settings_popularSitesAutocompleteTitle => '热门网站建议';

  @override
  String get settings_popularSitesAutocompleteKeywords => '热门网站,域名,内联补全,自动补全';

  @override
  String get settings_popularSitesAutocompleteSubtitle =>
      '当历史记录和书签中没有匹配项时，用知名域名补全输入的文字';

  @override
  String get settings_localIndexEnabledTitle => '启用本地搜索索引';

  @override
  String get settings_localIndexEnabledKeywords => '页面文字,历史记录,全文搜索';

  @override
  String get settings_localIndexEnabledSubtitle =>
      '在本地为访问过的页面建立索引，以便浏览器搜索其内容。访问元数据保留在引擎中；只有页面文字存储在设备上。';

  @override
  String get settings_indexPrivateTabsTitle => '为隐私标签页建立索引';

  @override
  String get settings_indexPrivateTabsKeywords => '无痕,隐私';

  @override
  String get settings_indexPrivateTabsSubtitle => '将在隐私标签页中打开的页面加入本地索引。默认关闭。';

  @override
  String get settings_clearLocalIndexDialogTitle => '清除本地搜索索引？';

  @override
  String get settings_clearLocalIndexDialogContent =>
      '这将移除所有本地索引的页面内容。引擎历史记录（访问元数据）不受影响。';

  @override
  String get settings_localIndexStatsTitle => '已索引的页面';

  @override
  String get settings_localIndexStatsKeywords => '清除索引,统计';

  @override
  String settings_localIndexPagesIndexed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已索引 $count 个页面',
    );
    return '$_temp0';
  }

  @override
  String get settings_searchSectionProvidersTitle => '提供商';

  @override
  String get settings_searchSectionProvidersKeywords => '搜索引擎';

  @override
  String get settings_searchSectionBangShortcutsTitle => 'Bang 快捷方式';

  @override
  String get settings_searchSectionBangShortcutsKeywords => 'bang,bangs';

  @override
  String get settings_searchSectionHistorySuggestionsTitle => '历史记录与建议';

  @override
  String get settings_searchSectionLocalIndexTitle => '本地搜索索引';

  @override
  String get settings_searchSectionLocalIndexKeywords => '设备端搜索,索引';

  @override
  String get settings_indexDefaultSearchProviderSubtitle => '选择默认的搜索引擎';

  @override
  String get settings_indexDefaultAutocompleteProviderSubtitle => '选择搜索建议的提供商';

  @override
  String get settings_indexAcceptSuggestionOnSubmitSubtitle => '按下回车键时接受内联建议';

  @override
  String get settings_indexHistorySuggestionsSubtitle => '输入时建议访问过的页面';

  @override
  String get settings_indexPrivateSearchSuggestionsSubtitle =>
      '在隐私标签页中使用建议和历史记录';

  @override
  String get settings_indexPopularSitesAutocompleteSubtitle => '用知名域名补全输入的文字';

  @override
  String get settings_indexLocalIndexEnabledSubtitle => '在本地为访问过的页面建立索引以搜索内容';

  @override
  String get settings_indexIndexPrivateTabsSubtitle => '将隐私标签页加入本地索引';

  @override
  String get settings_indexLocalIndexStatsSubtitle => '查看并清除本地索引';

  @override
  String get settings_webContentTitle => '网页内容';

  @override
  String get settings_webContentSubtitle => '文字渲染、阅读模式、PDF 和本地 AI 功能。';

  @override
  String get settings_webFontsTitle => '网页字体';

  @override
  String get settings_webFontsKeywords => '字体';

  @override
  String get settings_webFontsSubtitle => '允许网站使用自定义字体';

  @override
  String get settings_automaticFontSizeTitle => '自动字号';

  @override
  String get settings_automaticFontSizeKeywords => '文字大小,字号';

  @override
  String get settings_automaticFontSizeSubtitle =>
      '根据系统设置自动调整字号。停用后可手动控制字号比例和字体放大。';

  @override
  String get settings_fontSizeFactorTitle => '字号比例';

  @override
  String get settings_fontSizeFactorKeywords => '缩放,文字';

  @override
  String get settings_fontSizeFactorSubtitle => '缩放网页文字大小';

  @override
  String get settings_disabledWhileAutomaticFontSize => '启用自动字号时不可用';

  @override
  String get settings_fontInflationTitle => '字体放大';

  @override
  String get settings_fontInflationKeywords => '可读性';

  @override
  String get settings_fontInflationSubtitle =>
      '放大缺少移动端 viewport meta 标签的页面上的文字';

  @override
  String get settings_inputAutoZoomTitle => '输入时自动缩放';

  @override
  String get settings_inputAutoZoomKeywords => '表单';

  @override
  String get settings_inputAutoZoomSubtitle => '聚焦文本输入框时自动放大';

  @override
  String get settings_forceUserScalableTitle => '在所有网站上允许缩放';

  @override
  String get settings_forceUserScalableKeywords => '双指缩放,无障碍';

  @override
  String get settings_forceUserScalableSubtitle => '允许双指缩放，即使网站禁止此手势';

  @override
  String get settings_pdfViewerTitle => '内置 PDF 查看器';

  @override
  String get settings_pdfViewerKeywords => 'pdf';

  @override
  String get settings_pdfViewerSubtitle => '直接在浏览器中打开 PDF 文件，无需下载';

  @override
  String get settings_enableReaderModeTitle => '启用阅读模式';

  @override
  String get settings_enableReaderModeKeywords => '阅读,可读性,阅读视图';

  @override
  String get settings_enableReaderModeSubtitle =>
      '在浏览器应用栏中添加一个可选工具，通过移除广告、侧边栏及其他非必要元素来简化网页。';

  @override
  String get settings_enforceReaderModeTitle => '强制阅读模式';

  @override
  String get settings_enforceReaderModeKeywords => '阅读';

  @override
  String get settings_enforceReaderModeSubtitle =>
      '忽略网站的可读性评分，始终显示阅读模式，即使网站可能不支持。';

  @override
  String get settings_onDeviceAiTitle => '设备端 AI';

  @override
  String get settings_onDeviceAiKeywords => '本地 ai,建议';

  @override
  String get settings_onDeviceAiSubtitle => '设备端功能，例如为打开的标签页建议容器及其名称';

  @override
  String get settings_webContentSectionDisplayTitle => '显示';

  @override
  String get settings_webContentSectionContentFeaturesTitle => '内容功能';

  @override
  String get settings_indexAutomaticFontSizeSubtitle => '根据系统设置调整字号';

  @override
  String get settings_indexFontInflationSubtitle => '放大没有移动端 viewport 的页面上的文字';

  @override
  String get settings_indexInputAutoZoomSubtitle => '聚焦文本输入框时自动缩放';

  @override
  String get settings_indexPdfViewerSubtitle => '直接在浏览器中打开 PDF 文件';

  @override
  String get settings_indexEnableReaderModeSubtitle => '提取并简化页面以提高可读性';

  @override
  String get settings_indexEnforceReaderModeSubtitle => '始终显示阅读模式功能';

  @override
  String get settings_indexOnDeviceAiSubtitle => '本地 AI 功能，包括容器主题和标签页建议';

  @override
  String get settings_ublockListsTitle => 'uBlock 过滤规则列表';

  @override
  String get settings_ublockListsSearchHint => '搜索列表、分组和外部网址';

  @override
  String get settings_ublockSectionManagement => '管理';

  @override
  String get settings_ublockSectionQuickActions => '快捷操作';

  @override
  String get settings_ublockSectionFilterLists => '过滤规则列表';

  @override
  String get settings_ublockSectionExternalLists => '外部列表';

  @override
  String get settings_actionApply => '应用';

  @override
  String get settings_ublockResetDialogTitle => '恢复默认设置？';

  @override
  String get settings_ublockResetDialogMessage =>
      '这将把 uBlock Origin 恢复为默认的过滤规则列表配置，并移除你添加的所有外部列表。';

  @override
  String get settings_ublockApplyHardeningsDialogTitle => '应用 WebLibre 加固？';

  @override
  String get settings_ublockApplyHardeningsDialogMessage =>
      '这将启用一组精选的额外过滤规则列表，并将一个合法短网址列表添加为外部列表。';

  @override
  String get settings_ublockInfoBannerMessage =>
      '对 uBlock Origin 过滤规则列表的更改需要重启应用才能生效。由于缓存原因，部分更改可能需要几分钟并再次重启才能完全生效。';

  @override
  String settings_ublockLoadFailed(String error) {
    return '无法加载过滤规则列表资源：$error';
  }

  @override
  String get settings_ublockQuickResetTitle => '恢复默认设置';

  @override
  String get settings_ublockQuickResetSubtitle =>
      '恢复 uBlock Origin 的默认过滤规则列表配置。';

  @override
  String get settings_ublockQuickApplyHardeningsTitle => '应用 WebLibre 加固';

  @override
  String get settings_ublockQuickApplyHardeningsSubtitle => '启用一组精选的额外过滤规则列表。';

  @override
  String get settings_ublockManageTitle => '由 WebLibre 管理';

  @override
  String get settings_ublockManageSubtitle =>
      'WebLibre 会在下次浏览器启动时控制 uBlock Origin 启用的过滤规则列表。';

  @override
  String get settings_ublockManageHint => '启用管理后将以 uBO 的常用基础列表为起点，并保留“我的过滤规则”。';

  @override
  String get settings_ublockAutoSelectTitle => '自动选择语言';

  @override
  String get settings_ublockAutoSelectSubtitle => '启用与设备语言相匹配的区域过滤规则列表。';

  @override
  String get settings_ublockAutoSelectedTooltip => '已根据你的语言自动选择';

  @override
  String get settings_ublockDefaultOnTooltip => '默认启用';

  @override
  String get settings_ublockVisitSupportTooltip => '访问支持页面';

  @override
  String get settings_ublockExternalListsHint =>
      '原始网址会作为外部列表转发给 uBlock Origin。描述仅在 WebLibre 中显示。';

  @override
  String get settings_ublockNoExternalLists => '未配置外部列表。';

  @override
  String settings_ublockNoExternalListsMatch(String query) {
    return '没有与“$query”匹配的外部列表。';
  }

  @override
  String get settings_ublockAddExternalListButton => '添加外部列表';

  @override
  String get settings_ublockEditListDialogTitle => '编辑外部过滤规则列表';

  @override
  String get settings_ublockAddListDialogTitle => '添加外部过滤规则列表';

  @override
  String get settings_ublockListUrlLabel => '列表网址';

  @override
  String get settings_ublockListUrlAlreadyAdded => '已添加';

  @override
  String get settings_ublockDescriptionLabel => '描述（可选）';

  @override
  String get settings_ublockDescriptionHint => '例如：烦人元素 — myAuthor';

  @override
  String get settings_ublockGroupDefault => '默认';

  @override
  String get settings_ublockGroupAds => '广告';

  @override
  String get settings_ublockGroupPrivacy => '隐私';

  @override
  String get settings_ublockGroupMalware => '恶意软件';

  @override
  String get settings_ublockGroupAnnoyances => '烦人元素';

  @override
  String get settings_ublockGroupMultipurpose => '多用途';

  @override
  String get settings_ublockGroupRegions => '区域';

  @override
  String get settings_categoryGeneralTitle => '常规';

  @override
  String get settings_categoryGeneralKeywords => '主题,界面缩放,默认浏览器';

  @override
  String get settings_categoryGeneralSubtitle => '外观、下载';

  @override
  String get settings_categoryBrowsingTitle => '浏览';

  @override
  String get settings_categoryBrowsingKeywords => '标签页,小众网络,网址清理,短链接还原';

  @override
  String get settings_categoryBrowsingSubtitle => '标签页、导航、外部链接';

  @override
  String get settings_categoryHomeNewTabTitle => '主页与新标签页';

  @override
  String get settings_categoryHomeNewTabKeywords =>
      '主页,新标签页,起始页,版块,快捷方式,常用网站,名言,壁纸,背景';

  @override
  String get settings_categoryHomeNewTabSubtitle => '主页和新标签页显示的内容';

  @override
  String get settings_categoryGesturesTitle => '手势';

  @override
  String get settings_categoryGesturesKeywords => '手势,滑动,笔画,标签栏,长按,双指捏合';

  @override
  String get settings_categoryGesturesSubtitle => '标签栏和标签页上的滑动、绘制手势';

  @override
  String get settings_categoryKeyboardShortcutsTitle => '键盘快捷键';

  @override
  String get settings_categoryKeyboardShortcutsKeywords => '键盘,快捷键,热键,按键绑定';

  @override
  String get settings_categoryKeyboardShortcutsSubtitle => '用于浏览器操作的实体键盘按键';

  @override
  String get settings_categoryToolbarLayoutTitle => '工具栏与布局';

  @override
  String get settings_categoryToolbarLayoutKeywords => '上下文工具栏,快速标签页切换器';

  @override
  String get settings_categoryToolbarLayoutSubtitle => '标签栏、工具栏、快速切换栏、标签页视图';

  @override
  String get settings_categoryWebContentTitle => '网页内容';

  @override
  String get settings_categoryWebContentKeywords => '阅读模式,pdf,字体';

  @override
  String get settings_categoryWebContentSubtitle => '页面显示、PDF、阅读模式、AI';

  @override
  String get settings_categoryNotificationsTitle => '通知';

  @override
  String get settings_categoryNotificationsKeywords =>
      '推送,unifiedpush,ntfy,分发器';

  @override
  String get settings_categoryNotificationsSubtitle => '网页推送方式、分发器、网站订阅';

  @override
  String get settings_categorySearchTitle => '搜索';

  @override
  String get settings_categorySearchKeywords => 'bang,建议,本地搜索索引';

  @override
  String get settings_categorySearchSubtitle => '提供商、Bang、搜索历史';

  @override
  String get settings_categoryPrivacySecurityTitle => '隐私与安全';

  @override
  String get settings_categoryPrivacySecurityKeywords =>
      '指纹,https,doh,安全浏览,网络保护';

  @override
  String get settings_categoryPrivacySecuritySubtitle => '跟踪保护、数据清除';

  @override
  String get settings_categoryProxyTitle => '代理';

  @override
  String get settings_categoryProxyKeywords =>
      '代理,sing-box,socks,vpn,wireguard,路由,tor,容器,翻墙';

  @override
  String get settings_categoryProxySubtitle => '连接和路由';

  @override
  String get settings_categoryExtensionsTitle => '扩展';

  @override
  String get settings_categoryExtensionsKeywords => '附加组件,插件,未签名扩展,addons';

  @override
  String get settings_categoryExtensionsSubtitle => '安装和管理扩展来源';

  @override
  String get settings_categoryAccountTitle => 'WebLibre 账户';

  @override
  String get settings_categoryAccountKeywords => '账户,账号,订阅';

  @override
  String get settings_categoryAccountSubtitle => '登录、同步设置';

  @override
  String get settings_categorySyncTitle => 'Firefox Sync';

  @override
  String get settings_categorySyncKeywords => '配对,设备名称,同步类型';

  @override
  String get settings_categorySyncSubtitle => '账户、立即同步、同步内容选择';

  @override
  String get settings_categoryAdvancedTitle => '高级';

  @override
  String get settings_categoryAdvancedKeywords => '实验性,错误日志,javascript';

  @override
  String get settings_categoryAdvancedSubtitle => 'JavaScript、用户代理、调试';

  @override
  String get settings_categoryGroupBrowserTitle => '浏览器';

  @override
  String get settings_categoryGroupServicesAdvancedTitle => '服务与高级';

  @override
  String get settings_privacySectionTrackingProtectionTitle => '跟踪保护';

  @override
  String get settings_privacySectionTrackingProtectionKeywords => '隐私';

  @override
  String get settings_indexEnhancedTrackingProtectionSubtitle => '选择拦截跟踪器的力度';

  @override
  String get settings_indexContentBlockingDatabaseSubtitle =>
      '为 ETP 类别使用 GeckoView 拦截列表';

  @override
  String get settings_indexBounceTrackingProtectionSubtitle =>
      '移除基于重定向的跟踪器留下的跟踪状态';

  @override
  String get settings_indexQueryParameterStrippingSubtitle => '从网址中移除跟踪参数';

  @override
  String get settings_privacySectionFingerprintingTitle => '指纹识别';

  @override
  String get settings_indexBrowserLanguagesSubtitle => '选择网站可以看到的语言';

  @override
  String get settings_privacySectionConnectionSecurityTitle => '连接安全';

  @override
  String get settings_indexHttpsOnlyModeSubtitle => '优先使用 HTTPS 并阻止不安全的连接';

  @override
  String get settings_indexDnsOverHttpsTitle => 'DNS over HTTPS';

  @override
  String get settings_indexDnsOverHttpsKeywords => 'doh,加密 dns';

  @override
  String get settings_indexDnsOverHttpsSubtitle => '加密 DNS 查询';

  @override
  String get settings_privacySectionNetworkProtectionTitle => '网络保护';

  @override
  String get settings_indexLnaBlockingSubtitle => '拦截对本地网络设备和服务的请求';

  @override
  String get settings_indexLnaBlockTrackersSubtitle => '拦截类似跟踪器的本地网络请求';

  @override
  String get settings_privacySectionSignalsModesTitle => '隐私信号与模式';

  @override
  String get settings_indexScreenshotProtectionSubtitle => '防止应用内容出现在截图中';

  @override
  String get settings_indexAllowPrivateTabScreenshotsSubtitle => '允许系统截取隐私标签页';

  @override
  String get settings_indexGlobalPrivacyControlSubtitle => '向网站发送隐私偏好信号';

  @override
  String get settings_privacySectionAppOpeningProtectionTitle => '应用打开保护';

  @override
  String get settings_indexAppOpeningProtectionSubtitle =>
      '控制哪些应用可以直接启动 WebLibre';

  @override
  String get settings_privacySectionDataManagementTitle => '数据管理';

  @override
  String get settings_indexDeleteBrowsingDataSubtitle =>
      '清除历史记录、Cookie 及其他浏览数据';

  @override
  String get settings_indexAutoClearHistorySubtitle => '在选定的时长后自动清除历史记录';

  @override
  String get settings_indexAutoClearUnassignedTabsSubtitle => '自动关闭未分配到容器的标签页';

  @override
  String get settings_privacySectionSafeBrowsingTitle => 'Google 安全浏览';

  @override
  String get settings_indexSafeBrowsingMalwareSubtitle => '对恶意软件和有害下载发出警告';

  @override
  String get settings_indexSafeBrowsingPhishingSubtitle => '对欺诈网站和虚假登录页面发出警告';

  @override
  String get settings_privacySectionAdvancedSecurityTitle => '高级安全';

  @override
  String get settings_indexWebEngineHardeningSubtitle => '加固浏览器引擎的行为和默认设置';

  @override
  String get settings_indexFissionEnabledSubtitle => '在不同源之间使用更强的站点隔离';

  @override
  String get settings_indexExtensionsWebAPIEnabledSubtitle =>
      '允许扩展向页面公开 Web API';

  @override
  String get settings_proxySectionTitle => '代理';

  @override
  String get settings_indexProxyLogsSubtitle => '查看代理日志并设置其记录的详细程度';

  @override
  String get settings_saveAndUse => '保存并使用';

  @override
  String get settings_replace => '替换';

  @override
  String get settings_later => '稍后';

  @override
  String get settings_restartNow => '立即重启';

  @override
  String get settings_sync => '同步';

  @override
  String get settings_chooseSearchProvider => '选择搜索提供商';

  @override
  String get settings_entriesLabel => '条目数';

  @override
  String get settings_lastSyncLabel => '上次同步';

  @override
  String get settings_notAvailable => '不可用';

  @override
  String get settings_protectionLevelTitle => '保护级别';

  @override
  String get settings_protectionLevelDescription =>
      'DNS over HTTPS 通过加密连接发送域名解析请求，以保护这些请求，让他人更难得知你即将访问哪些网站。';

  @override
  String get settings_defaultProtectionTitle => '默认保护';

  @override
  String get settings_defaultProtectionSubtitle => '仅在默认 DNS 失败时使用 DoH';

  @override
  String get settings_increasedProtectionTitle => '增强保护';

  @override
  String get settings_increasedProtectionSubtitle => '优先使用 DoH，以默认 DNS 作为备用';

  @override
  String get settings_maxProtectionTitle => '最大保护';

  @override
  String get settings_maxProtectionSubtitle => '仅使用 DoH，无备用';

  @override
  String get settings_protectionOffTitle => '关闭';

  @override
  String get settings_protectionOffSubtitle => '使用你的默认 DNS 解析服务器';

  @override
  String get settings_dohProviderTitle => 'DoH 提供商';

  @override
  String get settings_yourResolvers => '你的解析服务器';

  @override
  String get settings_addCustomResolver => '添加自定义解析服务器';

  @override
  String get settings_editCustomResolverTitle => '编辑自定义解析服务器';

  @override
  String get settings_resolverUrlLabel => '解析服务器网址';

  @override
  String get settings_alreadyBuiltInProvider => '已作为内置提供商提供';

  @override
  String get settings_alreadyAdded => '已添加';

  @override
  String get settings_resolverNameLabel => '名称（可选）';

  @override
  String get settings_resolverNameHint => '例如 dnsforge（广告拦截）';

  @override
  String get settings_searchHint => '搜索设置';

  @override
  String get settings_noSettingsAvailable => '没有可用的设置。';

  @override
  String settings_noSettingsMatch(String query) {
    return '没有与“$query”匹配的设置。';
  }

  @override
  String get settings_stringListEditorEmpty => '尚未添加任何内容。';

  @override
  String get settings_customizeMenu => '自定义菜单';

  @override
  String get settings_customizeMenuKeywords => '版块,行,排序';

  @override
  String get settings_customizeMenuSubtitle => '选择三点菜单的版块和行，并调整其顺序';

  @override
  String get settings_tabBarPositionTitle => '标签栏位置';

  @override
  String get settings_tabBarPositionKeywords => '顶部,底部';

  @override
  String settings_currentlyResolvesTo(String text, String value) {
    return '$text（当前：$value）';
  }

  @override
  String get settings_tabBarPositionAutoLabel => '自动';

  @override
  String get settings_tabBarPositionTopLabel => '顶部';

  @override
  String get settings_tabBarPositionBottomLabel => '底部';

  @override
  String get settings_tabBarPositionLeftLabel => '左侧';

  @override
  String get settings_tabBarPositionRightLabel => '右侧';

  @override
  String get settings_tabBarPositionAutoDescription => '大屏幕上为侧边栏，手机上为底部栏';

  @override
  String get settings_tabBarPositionTopDescription => '常驻标签栏，不自动隐藏';

  @override
  String get settings_tabBarPositionBottomDescription => '支持自动隐藏的标签栏';

  @override
  String get settings_tabBarPositionLeftDescription => '垂直侧边栏，滑动可隐藏';

  @override
  String get settings_tabBarPositionRightDescription => '垂直侧边栏，滑动可隐藏';

  @override
  String get settings_tabBarStyleTitle => '标签栏样式';

  @override
  String get settings_tabBarStyleKeywords => '布局,紧凑';

  @override
  String get settings_withTitleOption => '带标题';

  @override
  String get settings_withTitleDescription => '显示页面标题和网址路径';

  @override
  String get settings_compactOption => '紧凑';

  @override
  String get settings_compactDescription => '居中的网址胶囊，不显示页面标题';

  @override
  String get settings_showContextualToolbarTitle => '显示上下文工具栏';

  @override
  String get settings_showContextualToolbarKeywords => '底部工具栏';

  @override
  String get settings_showContextualToolbarSubtitle => '显示用于导航和操作的额外底部工具栏';

  @override
  String get settings_customizeToolbarButtons => '自定义工具栏按钮';

  @override
  String get settings_customizeToolbarButtonsKeywords => '按钮';

  @override
  String get settings_customizeSwitcherButtons => '自定义切换栏按钮';

  @override
  String get settings_customizeSwitcherButtonsKeywords => '按钮,新标签页,操作,末尾';

  @override
  String get settings_customizeSwitcherButtonsSubtitle =>
      '固定在切换栏末尾的操作按钮（独立于上下文工具栏）';

  @override
  String get settings_tabStackingTitle => '标签页堆叠';

  @override
  String get settings_tabStackingKeywords =>
      '最近标签页,最近使用,容器标签页,手风琴,两级,行,堆叠,标签页分组,标签页堆叠,标签页树,tab groups,停用';

  @override
  String get settings_tabStackingSubtitle => '快速标签页切换栏如何排列标签页';

  @override
  String get settings_recentlyUsedTabsOption => '最近使用的标签页';

  @override
  String get settings_recentlyUsedTabsDescription => '所有容器中最近使用的标签页';

  @override
  String get settings_containerTabsOption => '容器标签页';

  @override
  String get settings_containerTabsDescription => '所选容器中按顺序排列的标签页';

  @override
  String get settings_accordionOption => '手风琴';

  @override
  String get settings_accordionDescription => '所有容器显示为标签块，所选容器的标签页在其中展开';

  @override
  String get settings_twoRowsOption => '两行';

  @override
  String get settings_twoRowsDescription => '上方为所选容器的标签页，下方为最近使用的标签页';

  @override
  String get settings_tabGroupsOption => '标签页分组';

  @override
  String get settings_tabGroupsDescription =>
      '每个标签页与从它打开的标签页合为一个标签块，上方一行显示当前分组的标签页';

  @override
  String get settings_tabStackingFallbackAccordion => '此窗口或侧边面板空间不足，暂时显示为手风琴';

  @override
  String get settings_tabStackingFallbackContainerTabs =>
      '此窗口或侧边面板空间不足，暂时显示为容器标签页';

  @override
  String get settings_disabledOption => '停用';

  @override
  String get settings_disabledDescription => '隐藏快速标签页切换栏';

  @override
  String get settings_closeButtonsTitle => '标签块上的关闭按钮';

  @override
  String get settings_closeButtonsKeywords => '关闭,x 按钮,当前标签页';

  @override
  String get settings_closeButtonsSubtitle => '哪些切换栏标签块显示关闭按钮';

  @override
  String get settings_activeTabOnlyOption => '仅当前标签页';

  @override
  String get settings_activeTabOnlyDescription => '仅当前打开的标签页的标签块';

  @override
  String get settings_allTabsOption => '所有标签页';

  @override
  String get settings_allTabsDescription => '栏上的每个标签块';

  @override
  String get settings_neverOption => '从不';

  @override
  String get settings_neverCloseDescription => '不显示关闭按钮；可通过长按菜单或滑动切换栏来关闭标签页';

  @override
  String get settings_titleWidthTitle => '快速标签页切换栏中的标题宽度';

  @override
  String get settings_titleWidthKeywords => '宽度,标题,标签块,长度';

  @override
  String get settings_titleWidthSubtitle => '切换栏标签块上标签页标题的最大宽度';

  @override
  String get settings_historyFallbackTitle => '快速标签页切换栏中的历史记录备选';

  @override
  String get settings_historyFallbackKeywords => '建议';

  @override
  String get settings_historyFallbackSubtitle => '没有可用的标签块时使用浏览历史建议';

  @override
  String get settings_showTitlesTitle => '在快速标签页切换栏中显示标题';

  @override
  String get settings_showTitlesKeywords => '页面标题';

  @override
  String get settings_showTitlesSubtitle => '在快速标签页切换栏中同时显示标签页标题和图标';

  @override
  String get settings_hierarchyDepthTitle => '快速标签页切换栏中的层级深度';

  @override
  String get settings_hierarchyDepthKeywords => '层级,嵌套,深度,树状,箭头';

  @override
  String get settings_hierarchyDepthSubtitle =>
      '在折叠为数字徽章之前，切换栏标签块上显示多少个嵌套箭头（0 表示隐藏该指示器）';

  @override
  String settings_hierarchyGlyphsLabel(int glyphs) {
    String _temp0 = intl.Intl.pluralLogic(
      glyphs,
      locale: localeName,
      other: '$glyphs 级',
      zero: '关闭',
    );
    return '$_temp0';
  }

  @override
  String get settings_autoHideTabBarTitle => '自动隐藏标签栏';

  @override
  String get settings_autoHideTabBarKeywords => '滚动';

  @override
  String get settings_autoHideTabBarSubtitle => '滚动时隐藏标签栏';

  @override
  String get settings_autoHideSidePanelTitle => '自动隐藏侧边面板';

  @override
  String get settings_autoHideSidePanelKeywords => '鼠标,光标,悬停,侧边栏';

  @override
  String get settings_autoHideSidePanelSubtitle =>
      '让左侧或右侧标签栏不占用空间，鼠标移到该边缘时再滑出。仅在使用鼠标或触控板时有效；触摸屏幕会让面板重新回到页面旁边。';

  @override
  String get settings_bottomSheetTabViewTitle => '底部面板标签页视图';

  @override
  String get settings_bottomSheetTabViewKeywords => '面板';

  @override
  String get settings_bottomSheetTabViewSubtitle => '在底部面板而非全屏中显示标签页';

  @override
  String get settings_longPressUrlCopyTitle => '长按网址即可复制';

  @override
  String get settings_longPressUrlCopyKeywords => '复制网址';

  @override
  String get settings_longPressUrlCopySubtitle => '长按地址栏时将页面网址复制到剪贴板';

  @override
  String get settings_showFaviconsTitle => '在列表视图中显示网站图标';

  @override
  String get settings_showFaviconsKeywords => '图标';

  @override
  String get settings_showFaviconsSubtitle => '在标签页列表视图中显示网站图标而非页面缩略图';

  @override
  String get settings_previewPageContent => '页面内容';

  @override
  String get settings_previewPageTitle => 'WebLibre 预览';

  @override
  String get settings_previewTabNews => '新闻';

  @override
  String get settings_previewTabPrivate => '隐私';

  @override
  String get settings_previewTabBank => '银行';

  @override
  String get settings_previewTabSearch => '搜索';

  @override
  String get settings_livePreviewTitle => '实时预览';

  @override
  String get settings_livePreviewSubtitle => '反映你当前的工具栏和布局设置';

  @override
  String get settings_deleteAllExceptionsTitle => '删除所有例外？';

  @override
  String get settings_deleteAllExceptionsContent => '这将为所有例外网站重新启用跟踪保护。';

  @override
  String get settings_entryCopied => '条目已复制';

  @override
  String get settings_messageLabel => '消息：';

  @override
  String get settings_errorLabel => '错误：';

  @override
  String get settings_stackTraceLabel => '堆栈跟踪：';

  @override
  String get settings_importSettingsTitle => '导入设置';

  @override
  String get settings_importSettingsDescription =>
      '你选择的部分将替换此配置文件中的现有内容。未勾选的部分保持不变。';

  @override
  String settings_unreadableSections(int count, String sections) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '此文件中有 $count 个部分（$sections）无法被此版本的 WebLibre 读取，将被跳过。',
    );
    return '$_temp0';
  }

  @override
  String get settings_exportedLabel => '导出时间';

  @override
  String get settings_appVersionLabel => '应用版本';

  @override
  String get settings_credentialsNotCarried =>
      '导出内容不包括已保存的凭据和壁纸图片。此设备会保留自己的这些内容。';

  @override
  String get settings_geckoPrefsRestartNote => '部分引擎首选项需要重启浏览器后才能生效。';

  @override
  String get settings_userAgentChangedTitle => '用户代理已更改';

  @override
  String get settings_userAgentChangedContent => '需要重启浏览器才能使新的用户代理生效。';

  @override
  String get settings_tabBarSectionTitle => '标签栏';

  @override
  String get settings_contextualToolbarSectionTitle => '上下文工具栏';

  @override
  String get settings_quickTabSwitcherSectionTitle => '快速标签页切换栏';

  @override
  String get settings_tabViewSectionTitle => '标签页视图';

  @override
  String get settings_menuSectionTitle => '菜单';

  @override
  String get settings_menuSectionKeywords => '三点,溢出菜单,更多';

  @override
  String get settings_indexTabBarPositionSubtitle => '选择标签栏位于顶部、底部还是侧边';

  @override
  String get settings_indexTabBarStyleSubtitle => '在带标题和紧凑布局之间选择';

  @override
  String get settings_indexAutoHideTabBarSubtitle => '滚动时隐藏标签栏';

  @override
  String get settings_indexAutoHideSidePanelSubtitle => '鼠标移到侧边面板所在边缘时显示它';

  @override
  String get settings_indexLongPressUrlCopySubtitle => '从标签栏复制当前网址';

  @override
  String get settings_indexShowContextualToolbarSubtitle => '显示用于导航和操作的额外工具栏';

  @override
  String get settings_indexCustomizeToolbarButtonsSubtitle =>
      '选择在上下文工具栏中显示哪些操作';

  @override
  String get settings_indexTabStackingSubtitle => '选择快速标签页切换栏如何排列标签页';

  @override
  String get settings_indexCustomizeSwitcherButtonsSubtitle =>
      '选择在切换栏末尾显示哪些操作按钮';

  @override
  String get settings_indexHistoryFallbackSubtitle => '没有匹配的标签页时使用历史记录建议';

  @override
  String get settings_indexShowTitlesSubtitle => '在切换列表中显示页面标题';

  @override
  String get settings_indexHierarchyDepthSubtitle => '切换栏标签块上显示多少个嵌套箭头';

  @override
  String get settings_indexBottomSheetTabViewSubtitle => '以底部面板形式打开标签页切换器';

  @override
  String get settings_indexShowFaviconsSubtitle => '在标签页列表中显示网站图标';

  @override
  String get smallWeb_sheetTitle => '小众网络';

  @override
  String get smallWeb_refineCategoryTitle => '细化分类';

  @override
  String get smallWeb_allCategoriesChip => '全部';

  @override
  String smallWeb_searchingModeTitle(String mode) {
    return '正在搜索$mode';
  }

  @override
  String get smallWeb_discoverButtonLabel => '发现';

  @override
  String get smallWeb_browseConsolesButtonLabel => '浏览控制台';

  @override
  String get smallWeb_unavailableTitle => '小众网络不可用';

  @override
  String get smallWeb_noConsoleSelectedMessage => '未选择控制台';

  @override
  String smallWeb_consoleStats(int linkedConsoles, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedConsoles,
      locale: localeName,
      other: '$linkedConsoles 个关联控制台',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages 个页面',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get smallWeb_modeWebLabel => '网页';

  @override
  String get smallWeb_modeAppreciatedLabel => '精选';

  @override
  String get smallWeb_modeVideosLabel => '视频';

  @override
  String get smallWeb_modeCodeLabel => '代码';

  @override
  String get smallWeb_modeComicsLabel => '漫画';

  @override
  String get smallWeb_modeDescriptionAppreciated =>
      '浏览小众网络社区中经过精心挑选、深受用户喜爱的链接。';

  @override
  String get smallWeb_modeDescriptionVideos => '发现来自小众网络中独立创作者的视频内容。';

  @override
  String get smallWeb_modeDescriptionCode => '查找来自个人网站的代码片段、代码仓库和技术文章。';

  @override
  String get smallWeb_modeDescriptionComics => '探索独立插画师创作的漫画和网络插画。';

  @override
  String get smallWeb_sourceKagiLabel => 'Kagi';

  @override
  String get smallWeb_sourceKagiDescription => 'Kagi Search 的 Small Web';

  @override
  String get smallWeb_sourceWanderLabel => 'Wander';

  @override
  String get smallWeb_sourceWanderDescription => '通过控制台互联的网站环';

  @override
  String get smallWeb_noNewItemsFoundMessage => '未找到新内容。请尝试其他模式或分类。';

  @override
  String get smallWeb_discoveryFailedMessage => '发现失败，请重试。';

  @override
  String smallWeb_sessionErrorWithDetails(String error) {
    return '小众网络错误：$error';
  }

  @override
  String get smallWeb_kagiTitle => 'Kagi Small Web';

  @override
  String get smallWeb_kagiAttributionLine => '由 Kagi Search 开发 - 基于 MIT 许可证开源。';

  @override
  String get smallWeb_kagiBlogPostAction => '博客文章';

  @override
  String get smallWeb_kagiGithubAction => 'GitHub';

  @override
  String get smallWeb_kagiDescriptionWeb =>
      'Kagi Small Web 汇集了小众网络中个人网站和博客的最新文章。';

  @override
  String get smallWeb_kagiDescriptionAppreciated =>
      'Kagi Small Web 的此模式重点展示由该开源项目精选的小众网络优质文章。';

  @override
  String get smallWeb_kagiDescriptionVideos =>
      'Kagi Small Web 的此模式专注于小型独立创作者的视频内容以及精选的种子频道。';

  @override
  String get smallWeb_kagiDescriptionCode =>
      'Kagi Small Web 的此模式专注于来自个人网站及其他小众网络来源的代码相关文章。';

  @override
  String get smallWeb_kagiDescriptionComics =>
      'Kagi Small Web 的此模式专注于通过 Small Web 项目发现的漫画和插画内容。';

  @override
  String get smallWeb_wanderTitle => 'Wander';

  @override
  String get smallWeb_wanderDescription =>
      'Wander 是一个由个人网站组成的网络，这些网站通过共享的控制台相互连接，帮助人们浏览整个 Wander 社区的页面。';

  @override
  String get smallWeb_wanderAttributionLine => '由 Susam Pal 开发 - 基于 MIT 许可证开源。';

  @override
  String get smallWeb_wanderProjectAction => '项目';

  @override
  String get smallWeb_wanderSetupConsoleAction => '设置你的控制台';

  @override
  String get smallWeb_menuTooltip => '菜单';

  @override
  String get smallWeb_removeBookmarkTooltip => '移除书签';

  @override
  String get smallWeb_addBookmarkTooltip => '添加书签';

  @override
  String get smallWeb_bookmarkRemovedMessage => '已移除书签';

  @override
  String get smallWeb_bookmarkAddedMessage => '已添加书签';

  @override
  String get smallWeb_exitTooltip => '退出小众网络';

  @override
  String get smallWeb_selectConsoleTitle => '选择控制台';

  @override
  String get smallWeb_randomButtonLabel => '随机';

  @override
  String get smallWeb_filterConsolesHint => '筛选控制台…';

  @override
  String get smallWeb_linkedConsolesToggleLabel => '已关联';

  @override
  String get smallWeb_allConsolesToggleLabel => '全部';

  @override
  String get smallWeb_noConsoleSelectedYetMessage => '尚未选择控制台。请点按“发现”。';

  @override
  String get smallWeb_addConsoleByUrlTooltip => '通过网址添加控制台';

  @override
  String get smallWeb_couldNotLoadSessionTitle => '无法加载小众网络会话';

  @override
  String get smallWeb_noLinkedConsolesFound => '未找到关联的控制台。';

  @override
  String smallWeb_noConsolesMatchingQuery(String query) {
    return '没有与“$query”匹配的控制台。';
  }

  @override
  String get smallWeb_failedToLoadConsoles => '无法加载控制台。';

  @override
  String smallWeb_pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个页面',
    );
    return '$_temp0';
  }

  @override
  String get smallWeb_noConsolesDiscoveredYet => '尚未发现任何控制台。';

  @override
  String smallWeb_addedConsole(String host) {
    return '已添加控制台 $host';
  }

  @override
  String get smallWeb_addConsoleDialogTitle => '添加控制台';

  @override
  String get smallWeb_addConsoleDialogBody =>
      '请输入 Wander 控制台的网址。网址可以指向网站根目录或 /wander/ 路径。';

  @override
  String get smallWeb_urlFieldLabel => '网址';

  @override
  String get smallWeb_wanderConsoleFetchFailed => '无法从此控制台获取 wander.js。';

  @override
  String get smallWeb_wanderConsoleEmpty => 'wander.js 文件中不包含任何控制台或页面';

  @override
  String get smallWeb_wanderConsoleAlreadyAdded => '此控制台已添加';

  @override
  String get smallWeb_recentDiscoveriesTitle => '最近发现';

  @override
  String smallWeb_clearModeHistory(String mode) {
    return '清除$mode的发现记录';
  }

  @override
  String get smallWeb_clearAllDiscoveriesConfirmTitle => '清除所有发现记录？';

  @override
  String get smallWeb_clearAllDiscoveriesConfirmContent =>
      '这将永久移除所有模式和来源的最近发现记录。';

  @override
  String get smallWeb_actionClearAll => '全部清除';

  @override
  String get smallWeb_clearAllDiscoveriesMenuItem => '清除所有发现记录';

  @override
  String get smallWeb_noDiscoveriesYetMessage => '尚无发现记录。\n点按“发现”开始探索吧！';

  @override
  String smallWeb_showMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '再显示 $count 项',
    );
    return '$_temp0';
  }

  @override
  String smallWeb_failedToLoadHistory(String error) {
    return '无法加载历史记录：$error';
  }

  @override
  String get sync_screenTitle => 'Firefox Sync';

  @override
  String get sync_searchHint => '搜索同步设置';

  @override
  String get sync_statusSyncing => '正在同步';

  @override
  String get sync_statusNeverSynced => '从未同步';

  @override
  String sync_statusLastSynced(String date) {
    return '上次同步：$date';
  }

  @override
  String get sync_sectionAccount => '账户';

  @override
  String get sync_sectionAccountKeywords => '配对,设备名称,扫码,pairing';

  @override
  String get sync_entrySignedInAccountTitle => '已登录的账户';

  @override
  String get sync_entrySignInTitle => '登录';

  @override
  String get sync_entryAccountSubtitle => '账户状态、扫码配对和设备名称';

  @override
  String get sync_signedIn => '已登录';

  @override
  String get sync_notSignedIn => '未登录';

  @override
  String get sync_authExpired => '身份验证已过期。请重新登录以继续同步。';

  @override
  String get sync_syncingTabsBookmarksHistory => '正在同步标签页、书签和历史记录';

  @override
  String get sync_signInPrompt => '登录以同步标签页、书签和历史记录';

  @override
  String get sync_actionSignOut => '退出登录';

  @override
  String get sync_scanQrTitle => '扫描二维码进行配对';

  @override
  String get sync_scanQrSubtitle => '扫描电脑上 firefox.com/pair 页面中的二维码';

  @override
  String get sync_invalidQrCode => '二维码无效：不是有效的网址';

  @override
  String get sync_deviceNameTitle => '设备名称';

  @override
  String get sync_unknown => '未知';

  @override
  String get sync_sectionSynchronization => '同步';

  @override
  String get sync_syncNowTitle => '立即同步';

  @override
  String get sync_syncNowKeywords => '历史记录,书签,标签页';

  @override
  String get sync_syncHistoryTitle => '同步历史记录';

  @override
  String get sync_syncBookmarksTitle => '同步书签';

  @override
  String get sync_syncOpenTabsTitle => '同步打开的标签页';

  @override
  String get sync_sectionServerOverrides => '自定义服务器';

  @override
  String get sync_entryServerOverridesTitle => '自定义服务器';

  @override
  String get sync_entryServerOverridesKeywords =>
      'fxa,令牌服务器,token server,自建,服务器';

  @override
  String get sync_entryServerOverridesSubtitle => '自定义 Firefox 账户和令牌服务器地址';

  @override
  String get sync_fxaServerOverrideTitle => '自定义 FxA 服务器';

  @override
  String get sync_defaultMozillaServer => '默认 Mozilla 服务器';

  @override
  String get sync_tokenServerOverrideTitle => '自定义同步令牌服务器';

  @override
  String get sync_automaticFromFxaServer => '自动从 FxA 服务器获取';

  @override
  String get sync_restartAppNotice => '更改自定义服务器后请重启应用。';

  @override
  String get sync_signOutDialogTitle => '退出登录？';

  @override
  String get sync_signOutDialogContent => '确定要退出 Firefox Sync 吗？';

  @override
  String get sync_deviceNameHint => '输入设备名称';

  @override
  String get sync_deviceNameEmpty => '设备名称不能为空';

  @override
  String get sync_deviceNameUpdateFailed => '无法更新设备名称';

  @override
  String get sync_mustBeValidHttpsUrl => '必须是有效的 HTTPS 网址';

  @override
  String get tor_sectionService => '服务';

  @override
  String get tor_sectionServiceKeywords => '开关,启动,停止,start,stop';

  @override
  String get tor_sectionCircumvention => '审查规避';

  @override
  String get tor_sectionCircumventionKeywords =>
      '网桥,传输,obfs4,snowflake,bridges,翻墙,审查';

  @override
  String get tor_sectionCountryRestrictions => '国家/地区限制';

  @override
  String get tor_sectionCountryRestrictionsKeywords => '入口,出口,国家,地区';

  @override
  String get tor_sectionAbout => '关于';

  @override
  String get tor_sectionAboutKeywords => '商标,法律';

  @override
  String tor_proxyLabel(String brand) {
    return '$brand 代理';
  }

  @override
  String tor_serviceLabel(String brand) {
    return '$brand 服务';
  }

  @override
  String get tor_serviceLabelKeywords => '启用,连接';

  @override
  String tor_serviceSubtitle(String brand) {
    return '启动或停止 $brand 服务';
  }

  @override
  String get tor_startAutomaticallyTitle => '自动启动';

  @override
  String get tor_startAutomaticallyKeywords => '自启动,启动,开机,autostart';

  @override
  String tor_startAutomaticallySectionSubtitle(String brand) {
    return 'WebLibre 启动时连接 $brand 服务';
  }

  @override
  String tor_startAutomaticallySubtitle(String brand) {
    return 'WebLibre 启动时连接 $brand 服务，使用它的标签页无需提示即可就绪';
  }

  @override
  String get tor_requestNewIdentityTitle => '请求新身份';

  @override
  String get tor_requestNewIdentityKeywords => '线路,circuit';

  @override
  String get tor_requestNewIdentitySubtitle => '为新连接使用新的线路';

  @override
  String tor_requestingNewIdentityMessage(String brand) {
    return '正在请求新的 $brand 身份…';
  }

  @override
  String get tor_autoConfigureTransportTitle => '自动配置传输方式';

  @override
  String get tor_autoConfigureTransportKeywords => '自动';

  @override
  String get tor_autoConfigureSectionSubtitle => '自动为你的网络选择合适的可插拔传输';

  @override
  String tor_autoConfigureSubtitle(String brand) {
    return '在某些地区，必须使用可插拔传输才能连接到 $brand';
  }

  @override
  String get tor_requireBridgeTitle => '我确定不使用网桥就无法连接';

  @override
  String get tor_transportTitle => '传输方式';

  @override
  String get tor_transportKeywords => '直连,obfs4,snowflake';

  @override
  String tor_transportSectionSubtitle(String torBrand) {
    return '未启用自动配置时，选择连接 $torBrand 网络的方式';
  }

  @override
  String get tor_transportAutoConfiguredTitle => '已自动配置';

  @override
  String get tor_transportAutoConfiguredSubtitle => '关闭上方的自动配置即可手动选择传输方式。';

  @override
  String get tor_transportDirectTitle => '直接连接';

  @override
  String tor_transportDirectSubtitle(String brand) {
    return '如果 $brand 未被封锁，这是连接 $brand 的最佳方式';
  }

  @override
  String get tor_transportObfs4Title => 'obfs4';

  @override
  String get tor_transportObfs4Subtitle => '适用于审查较轻的网络和高带宽使用';

  @override
  String get tor_transportSnowflakeTitle => 'Snowflake';

  @override
  String get tor_transportSnowflakeSubtitle => '适用于审查严格的网络';

  @override
  String get tor_fetchFreshBridgesTitle => '连接前获取最新网桥';

  @override
  String get tor_entryCountryTitle => '入口国家/地区';

  @override
  String get tor_entryCountrySubtitle => '选择入口守卫所在的国家/地区';

  @override
  String get tor_entryCountryKeywords => '守卫,入口,guard';

  @override
  String get tor_exitCountryTitle => '出口国家/地区';

  @override
  String get tor_exitCountrySubtitle => '选择出口节点所在的国家/地区';

  @override
  String get tor_exitCountryKeywords => '出口,exit';

  @override
  String get tor_automaticOption => '自动';

  @override
  String get tor_trademarkTitle => '商标';

  @override
  String get tor_trademarkKeywords => '法律';

  @override
  String tor_trademarkDisclaimer(String brand) {
    return '$brand 是 The Tor Project 的商标，保留所有权利。WebLibre 未获得 Tor Project 的认可或赞助，也与其无任何关联。';
  }

  @override
  String get tor_screenSubtitle => '洋葱路由、可插拔传输、网桥和国家/地区限制。';

  @override
  String tor_dialogContent(String brand) {
    return '此容器需要 $brand 代理来建立安全连接，但该代理当前未运行。';
  }

  @override
  String get tor_actionEnable => '启用';

  @override
  String tor_connectingNotification(String proxyLabel) {
    return '$proxyLabel 正在连接…';
  }

  @override
  String get tor_countrySearchHint => '搜索国家/地区…';

  @override
  String get tor_unnamedCountry => '未命名国家/地区';

  @override
  String get user_profilesTitle => '配置文件';

  @override
  String get user_activeProfileLabel => '当前使用';

  @override
  String get user_loadProfilesFailedTitle => '无法加载配置文件';

  @override
  String get user_askWhichProfileTitle => '询问要打开哪个配置文件';

  @override
  String get user_askWhichProfileSubtitle => '启动时存在多个配置文件的情况下';

  @override
  String get user_createBackupTitle => '创建备份';

  @override
  String get user_restartingToTakeBackup => '正在重启以创建备份';

  @override
  String get user_backupRestartsTitle => 'WebLibre 会重启来执行此操作';

  @override
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile) {
    return '$restartClosesCurrentProfile备份是在配置文件关闭时进行的，因此其内容在备份期间不会改变。';
  }

  @override
  String get user_setPasswordNextTitle => '接下来设置密码';

  @override
  String get user_setPasswordNextSubtitle => '重启后，WebLibre 会要求输入备份文件的密码。';

  @override
  String get user_verifyBackupIntegrityTitle => '验证备份完整性';

  @override
  String get user_verifyBackupIntegritySubtitle => '检查备份是否可以恢复';

  @override
  String get user_tempDataSkippedTitle => '将跳过临时数据';

  @override
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain) {
    return '不会保存缓存文件及其他 WebLibre 可以重建的数据。$shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataIncludedTitle => '包含 WebLibre 账户数据';

  @override
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription) {
    return '备份文件包含此配置文件的$profileSecretDataDescription。替换配置文件时会恢复这些数据，创建新配置文件时则不会。请使用强密码。';
  }

  @override
  String get user_closingToTakeBackup => '正在关闭 WebLibre 以创建备份…';

  @override
  String get user_actionBackup => '备份';

  @override
  String get user_backupsTitle => '备份';

  @override
  String get user_changeBackupFolderTooltip => '更改备份文件夹';

  @override
  String get user_chooseBackupFolderPrompt => '选择备份的存储位置。';

  @override
  String get user_chooseBackupFolderHint => '请选择应用外部的位置，这样卸载应用后备份仍会保留。';

  @override
  String get user_chooseFolderButtonLabel => '选择文件夹';

  @override
  String get user_noBackupsFound => '未找到备份';

  @override
  String get user_loadBackupsFailedTitle => '无法加载备份';

  @override
  String get user_authReasonRequireAuth => '为配置文件启用身份验证';

  @override
  String get user_authReasonConfirmUnlock => '确认你可以解锁此配置文件';

  @override
  String get user_authReasonUnlockProfile => '解锁配置文件';

  @override
  String user_authFailedExisting(String nothingChanged) {
    return '无法确认你的身份。$nothingChanged';
  }

  @override
  String get user_authFailedNew => '无法确认你的身份。只有在此设备能够解锁时，才会创建已锁定的配置文件。';

  @override
  String get user_editProfileTitle => '编辑配置文件';

  @override
  String get user_createProfileTitle => '创建配置文件';

  @override
  String get user_nameFieldLabel => '名称';

  @override
  String get user_authenticationSectionTitle => '身份验证';

  @override
  String get user_requireAuthenticationTitle => '需要身份验证';

  @override
  String get user_requireAuthenticationSubtitle => '打开此配置文件前先进行验证';

  @override
  String get user_autoLockTitle => '自动锁定';

  @override
  String get user_autoLockSubtitle => '何时重新锁定配置文件';

  @override
  String get user_lockInBackgroundTitle => '进入后台时锁定';

  @override
  String get user_lockInBackgroundSubtitle => 'WebLibre 离开屏幕后立即锁定';

  @override
  String get user_lockAfterTimeoutTitle => '超时后锁定';

  @override
  String get user_lockAfterTimeoutSubtitle => '在一段时间无操作后锁定';

  @override
  String get user_lockOnStartupTitle => '仅在启动时锁定';

  @override
  String get user_lockOnStartupSubtitle => '启动时解锁一次，之后保持解锁状态，直到 WebLibre 完全关闭';

  @override
  String get user_timeoutFieldTitle => '超时时间';

  @override
  String get user_timeoutFieldSubtitle => '锁定前等待的时长';

  @override
  String get user_timeoutOneMinute => '1 分钟';

  @override
  String get user_timeoutFiveMinutes => '5 分钟';

  @override
  String get user_timeoutFifteenMinutes => '15 分钟';

  @override
  String get user_timeoutOneHour => '1 小时';

  @override
  String get user_profileActionsSectionTitle => '配置文件操作';

  @override
  String get user_switchDeleteUnavailableForActive => '无法切换或删除你正在使用的配置文件。';

  @override
  String get user_switchToThisProfileLabel => '切换到此配置文件';

  @override
  String user_deleteFailedWithError(String error) {
    return '无法删除：$error';
  }

  @override
  String get user_deleteProfileFailedGeneric => '无法删除此配置文件';

  @override
  String get user_restoreBackupTitle => '恢复备份';

  @override
  String get user_backupRestoredMessage => '备份已恢复';

  @override
  String get user_passwordFieldLabel => '密码';

  @override
  String get user_wrongBackupPassword => '此密码无法打开该备份文件';

  @override
  String get user_passwordHelperText => '创建此备份文件时使用的密码。';

  @override
  String get user_createNewProfileTitle => '创建新配置文件';

  @override
  String get user_createNewProfileSubtitle => '保留现有配置文件，并添加此备份';

  @override
  String get user_replaceExistingProfileTitle => '替换现有配置文件';

  @override
  String get user_replaceExistingProfileSubtitle => '重启并用此备份覆盖一个配置文件';

  @override
  String get user_newProfileNoSignInTitle => '新配置文件不包含 WebLibre 登录信息';

  @override
  String get user_newProfileNoSignInSubtitle =>
      '标签页、历史记录和书签会被恢复。登录和同步数据仍保留在原配置文件中。';

  @override
  String user_restoringIntoTitle(String profileLabel) {
    return '恢复到“$profileLabel”';
  }

  @override
  String get user_backupKeepsLockConfigured => '备份将保留你配置的锁定设置。';

  @override
  String get user_profileKeepsNameAndLock => '该配置文件将保留其名称和锁定设置。';

  @override
  String get user_profileToReplaceLabel => '要替换的配置文件';

  @override
  String get user_selectProfileToReplaceValidator => '请选择要替换的配置文件';

  @override
  String user_multipleProfilesShareNameTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个配置文件名为“$name”',
    );
    return '$_temp0';
  }

  @override
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone) {
    return '备份中指明了配置文件的名称，但无法确定是哪一个，请选择要替换的配置文件。$cannotBeUndone';
  }

  @override
  String user_backupTakenFromTitle(String name) {
    return '此备份来自“$name”';
  }

  @override
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  ) {
    return '它将替换“$targetLabel”，后者保留其名称和锁定设置。$shortcutsNeedPinningAgain';
  }

  @override
  String user_profileWillBeCalledTitle(String name) {
    return '此配置文件将被命名为“$name”';
  }

  @override
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain) {
    return '该名称来自备份。$shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataRestoredTitle => 'WebLibre 账户数据将被恢复';

  @override
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  ) {
    return '替换时将恢复备份文件中的$profileSecretDataDescription。$signedInFromBackup$olderBackupKeepsCredentials';
  }

  @override
  String get user_replacesSetupProfileTitle => '这将替换你正在设置的配置文件';

  @override
  String get user_replacesEverythingTitle => '这将替换该配置文件中的所有内容';

  @override
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword) {
    return '$restartsThenAsksPassword恢复开始时，此配置文件中已有的所有内容都将被替换。';
  }

  @override
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  ) {
    return '$restartsThenAsksPassword恢复开始时，它将替换$targetDescription中当前的$profileDataDescription。';
  }

  @override
  String get user_thatProfileFallbackLabel => '该配置文件';

  @override
  String get user_restoringBackupProgress => '正在恢复备份…';

  @override
  String get user_closingToRestoreProgress => '正在关闭 WebLibre 以进行恢复…';

  @override
  String get user_actionRestore => '恢复';

  @override
  String user_switchToProfileTitle(String profileName) {
    return '切换到“$profileName”？';
  }

  @override
  String user_switchClosesReopensAs(String profileName) {
    return 'WebLibre 将关闭，并以“$profileName”重新打开。';
  }

  @override
  String get user_switchConsequencesList => '• 隐私标签页将被清除。\n• 你离开的配置文件的网页通知将暂停。';

  @override
  String get user_actionNotNow => '暂不';

  @override
  String get user_actionSwitchAndRestart => '切换并重启';

  @override
  String get user_passwordConfirmationTitle => '确认密码';

  @override
  String get user_actionConfirm => '确认';

  @override
  String get user_selectProfileTitle => '选择配置文件';

  @override
  String get user_manageProfilesLabel => '管理配置文件';

  @override
  String get user_profileAvatarHint => '切换到此配置文件。长按可编辑。';

  @override
  String user_profileAvatarTooltip(String label) {
    return '$label\n长按可编辑';
  }

  @override
  String get user_addProfileLabel => '添加配置文件';

  @override
  String get user_addProfileButtonLabel => '添加';

  @override
  String get user_quitBrowserTitle => '退出浏览器';

  @override
  String get user_quitBrowserContent => '这将正常关闭浏览器并清除隐私标签页的数据。';

  @override
  String get user_actionQuit => '退出';

  @override
  String user_deleteProfileTitle(String profileName) {
    return '删除“$profileName”？';
  }

  @override
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return '其$profileDataDescription将被移除。$cannotBeUndone';
  }

  @override
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork$restartClosesCurrentProfile要删除的配置文件会先被关闭。';
  }

  @override
  String get user_actionDeleteAndRestart => '删除并重启';

  @override
  String user_replaceProfileTitle(String profileName) {
    return '用此备份替换“$profileName”？';
  }

  @override
  String user_replaceProfilePlaceholderContent(String cannotBeUndone) {
    return '备份将替换你正在设置的配置文件，其中已有的所有内容都将丢失。$cannotBeUndone';
  }

  @override
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return '备份将替换“$profileName”中的所有内容——包括其$profileDataDescription。备份之后添加的任何内容都将丢失。$cannotBeUndone';
  }

  @override
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  ) {
    return '$signedInFromBackup恢复还将包括备份中的$profileSecretDataDescription。$olderBackupKeepsCredentials';
  }

  @override
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  ) {
    return '该配置文件将被重命名为“$adoptedName”，并保留其锁定设置。$shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  ) {
    return '此备份来自“$sourceProfileName”。“$profileName”将保留其名称和锁定设置。$shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsThenAsksPassword在此之前不会替换任何内容。$restartClosesCurrentProfile';
  }

  @override
  String get user_actionReplaceAndRestart => '替换并重启';

  @override
  String user_backupProfileTitle(String profileName) {
    return '备份“$profileName”？';
  }

  @override
  String get user_backupProfileContent => '备份是在配置文件关闭时进行的，因此其中的内容不会发生变化。';

  @override
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork$restartClosesCurrentProfile';
  }

  @override
  String get user_actionBackupAndRestart => '备份并重启';

  @override
  String get user_profileAlreadyActive => '此配置文件已在使用中';

  @override
  String user_switchProfileFailedWithError(String error) {
    return '无法切换配置文件：$error';
  }

  @override
  String get user_profileLockedTitle => '配置文件已锁定';

  @override
  String get user_unlockingLabel => '正在解锁…';

  @override
  String get user_unlockButtonLabel => '解锁';

  @override
  String user_restartFailedWithError(String error) {
    return '无法重启：$error';
  }

  @override
  String get user_restartingLabel => '正在重启…';

  @override
  String get user_chooseAnotherProfileLabel => '选择其他配置文件';

  @override
  String get user_searchSuggestionProviderNone => '已停用';

  @override
  String get user_searchSuggestionProviderBrave => 'Brave';

  @override
  String get user_searchSuggestionProviderDdg => 'DuckDuckGo';

  @override
  String get user_searchSuggestionProviderKagi => 'Kagi';

  @override
  String get user_searchSuggestionProviderQwant => 'Qwant';

  @override
  String get user_deleteBrowsingDataTypeTabsTitle => '打开的标签页';

  @override
  String get user_deleteBrowsingDataTypeHistoryTitle => '浏览历史记录';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesTitle => '最近搜索';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesDescription =>
      '搜索页面上显示的查询';

  @override
  String get user_deleteBrowsingDataTypeCookiesTitle => 'Cookie 和网站数据';

  @override
  String get user_deleteBrowsingDataTypeCookiesDescription => '你将从大多数网站退出登录';

  @override
  String get user_deleteBrowsingDataTypeCacheTitle => '缓存的图片和文件';

  @override
  String get user_deleteBrowsingDataTypeCacheDescription => '释放存储空间';

  @override
  String get user_deleteBrowsingDataTypePermissionsTitle => '网站权限';

  @override
  String get user_deleteBrowsingDataTypeDownloadsTitle => '下载';

  @override
  String get wallpaper_title => '壁纸';

  @override
  String get wallpaper_settingsDescription => '显示在主页背景中，适用于所有未设置自有壁纸的容器。';

  @override
  String get wallpaper_chooseImage => '选择图片';

  @override
  String get wallpaper_replace => '替换';

  @override
  String get wallpaper_blurLabel => '模糊';

  @override
  String get wallpaper_dimLabel => '调暗';

  @override
  String get wallpaper_dimDescription => '调暗会将图片融入应用背景，使页面文字在浅色和深色主题下都清晰可读。';

  @override
  String get wallpaper_editorDefaultDescription => '主页将保留默认背景。';

  @override
  String get wallpaper_importErrorUnreadable => '无法读取该文件';

  @override
  String get wallpaper_importErrorTooLarge => '该图片过大';

  @override
  String get wallpaper_importErrorNotAnImage => '该文件不是图片';

  @override
  String get wallpaper_importErrorDecodeFailed => '无法读取该图片';

  @override
  String get webFeed_addFeedTitle => '添加订阅源';

  @override
  String get webFeed_fieldUrlLabel => '网址';

  @override
  String get webFeed_actionIgnore => '忽略';

  @override
  String get webFeed_unnamedFeedTitle => '无标题订阅源';

  @override
  String get webFeed_unnamedArticleTitle => '无标题文章';

  @override
  String get webFeed_fetchFeedFailedTitle => '无法获取订阅源';

  @override
  String get webFeed_feedsTitle => '订阅源';

  @override
  String get webFeed_loadFeedsFailedTitle => '无法加载订阅源';

  @override
  String get webFeed_feedFabLabel => '添加订阅源';

  @override
  String get webFeed_loadFeedFailedTitle => '无法加载订阅源';

  @override
  String get webFeed_newFeedTitle => '新建订阅源';

  @override
  String get webFeed_editFeedTitle => '编辑订阅源';

  @override
  String get webFeed_fetchingFeedMessage => '正在获取订阅源…';

  @override
  String get webFeed_fieldTitleLabel => '标题';

  @override
  String get webFeed_fieldDescriptionLabel => '描述';

  @override
  String get webFeed_fieldIconUrlLabel => '图标网址';

  @override
  String get webFeed_fieldSiteLinkLabel => '网站链接';

  @override
  String get webFeed_fieldFeedUrlLabel => '订阅源网址';

  @override
  String get webFeed_deleteFeedTitle => '删除订阅源';

  @override
  String get webFeed_deleteFeedConfirm => '确定要删除此订阅源及其所有文章吗？';

  @override
  String get webFeed_articlesTitle => '文章';

  @override
  String get webFeed_searchLabel => '搜索';

  @override
  String get webFeed_loadArticlesFailedTitle => '无法加载文章';

  @override
  String webFeed_publishedLabel(String date) {
    return '发布于：$date';
  }

  @override
  String get webFeed_notAvailable => '无';

  @override
  String webFeed_updatedLabel(String date) {
    return '更新于：$date';
  }

  @override
  String get webFeed_authorsLabel => '作者：';

  @override
  String get webFeed_tagsLabel => '标签：';

  @override
  String get webFeed_readArticleFailedTitle => '无法加载文章';

  @override
  String webFeed_lastFetchedLabel(String date) {
    return '上次获取：$date';
  }

  @override
  String get webFeed_tagsFieldLabel => '标签';

  @override
  String get webPush_screenTitle => '通知';

  @override
  String get webPush_screenSubtitle => '通过 UnifiedPush 推送的网站通知';

  @override
  String get webPush_distributorTileTitle => 'UnifiedPush 分发器';

  @override
  String get webPush_distributorTileKeywords => '通知,推送,unifiedpush,ntfy,push';

  @override
  String get webPush_checking => '正在检查…';

  @override
  String webPush_couldNotReadStatus(String error) {
    return '无法读取推送状态：$error';
  }

  @override
  String get webPush_updatingDistributor => '正在更新…';

  @override
  String get webPush_registrationRecovering => '正在从注册错误中恢复…';

  @override
  String webPush_lastRegistrationError(String error) {
    return '上次注册错误：$error';
  }

  @override
  String get webPush_disablingWebPush => '正在停用…';

  @override
  String get webPush_disableWebPush => '停用网页推送';

  @override
  String get webPush_statusNoneAvailable => '没有可用的分发器';

  @override
  String get webPush_statusNotSelected => '未配置';

  @override
  String get webPush_statusPending => '正在连接…';

  @override
  String get webPush_statusReady => '已启用';

  @override
  String get webPush_statusUnavailable => '分发器不可用';

  @override
  String get webPush_statusDescNoneAvailable =>
      '安装 UnifiedPush 分发器应用（例如 ntfy）以接收网站通知。';

  @override
  String get webPush_statusDescNotSelected => '在下方选择一个分发器以启用网站通知。';

  @override
  String get webPush_statusDescPending => '正在等待分发器确认注册。';

  @override
  String get webPush_statusDescReady => '网站通知将通过此分发器送达。';

  @override
  String get webPush_statusDescUnavailable =>
      '所选分发器已不再安装。在你选择其他分发器之前，网站通知将无法送达。';

  @override
  String get webPush_noDistributorInstalled =>
      '未安装 UnifiedPush 分发器。请安装一个（例如 ntfy）后重试。';

  @override
  String get webPush_chooseDistributorTitle => '选择分发器';

  @override
  String get webPush_distributorConfigured => 'UnifiedPush 分发器已配置。';

  @override
  String webPush_couldNotConfigureDistributor(String error) {
    return '无法配置分发器：$error';
  }

  @override
  String get webPush_webPushDisabled => '网页推送已停用。';

  @override
  String webPush_couldNotDisableWebPush(String error) {
    return '无法停用网页推送：$error';
  }

  @override
  String get webPush_notificationPermissionTitle => '通知权限';

  @override
  String get webPush_notificationPermissionKeywords => '通知,权限';

  @override
  String webPush_notificationPermissionCouldNotRead(String error) {
    return '无法读取权限状态：$error';
  }

  @override
  String get webPush_notificationPermissionGranted => '已授予';

  @override
  String get webPush_notificationPermissionDenied => '已拒绝。推送消息仍会送达，但无法显示通知。';

  @override
  String get webPush_grantAction => '授予';

  @override
  String webPush_couldNotUpdatePermission(String error) {
    return '无法更新通知权限：$error';
  }

  @override
  String get webPush_loadingSubscriptions => '正在加载订阅…';

  @override
  String get webPush_couldNotReadSubscriptions => '无法读取订阅';

  @override
  String get webPush_noSiteSubscriptions => '没有网站订阅';

  @override
  String get webPush_noSiteSubscriptionsDescription => '你允许发送通知的网站将显示在这里。';

  @override
  String get webPush_subscriptionActive => '已启用';

  @override
  String get webPush_subscriptionDelayedDelivery => '端点已保存；在分发器就绪前暂停推送';

  @override
  String get webPush_subscriptionWaitingForEndpoint => '正在等待分发器分配端点';

  @override
  String get webPush_revokeSubscriptionHint => '如需阻止某个网站发送通知，请在网站设置中撤销其通知权限。';

  @override
  String get webPush_deliverySectionTitle => '推送方式';

  @override
  String get webPush_indexDistributorSubtitle => '负责推送网站通知的应用';

  @override
  String get webPush_indexNotificationPermissionSubtitle => '显示网站通知所必需';

  @override
  String get webPush_subscriptionsSectionTitle => '订阅';

  @override
  String get webPush_indexSiteSubscriptionsTitle => '网站订阅';

  @override
  String get webPush_indexSiteSubscriptionsKeywords => '网站,订阅';

  @override
  String get webPush_indexSiteSubscriptionsSubtitle => '已订阅推送通知的网站';

  @override
  String get webSearch_fetchPageDataTitle => '获取页面数据';

  @override
  String get webSearch_downloadFailedTapToRetry => '下载失败 — 点按重试';

  @override
  String get webSearch_methodTrafilaturaTitle => '提取预览';

  @override
  String get webSearch_methodSinglefileTitle => '完整页面捕获';

  @override
  String get webSearch_methodPdfTitle => 'PDF 快照';

  @override
  String get webSearch_methodPngTitle => '图片快照';

  @override
  String get webSearch_methodTrafilaturaSubtitle => '为应用内预览优化的阅读文本和元数据';

  @override
  String get webSearch_methodSinglefileSubtitle => '存档完整页面，包括布局和资源，供日后使用';

  @override
  String get webSearch_methodPdfSubtitle => '将页面渲染为 PDF，便于离线阅读和分享';

  @override
  String get webSearch_methodPngSubtitle => '为渲染后的页面截取整页 PNG 截图';

  @override
  String get webSearch_previewUnavailableTitle => '预览不可用';

  @override
  String get webSearch_previewUnavailableMessage => '打开预览前，请先从结果列表中获取该页面。';

  @override
  String get webSearch_openInBrowserTooltip => '在浏览器中打开';

  @override
  String webSearch_torToggleOn(String brand) {
    return '$brand 已开启';
  }

  @override
  String webSearch_torToggleOff(String brand) {
    return '$brand 已关闭';
  }

  @override
  String get webSearch_languageAuto => '自动';

  @override
  String get webSearch_languageAutoDeviceDefault => '自动（设备默认）';

  @override
  String get webSearch_countryAny => '任意';

  @override
  String get webSearch_countryAnyRegion => '任意地区';

  @override
  String webSearch_countryDeviceDefault(String name) {
    return '$name（设备）';
  }

  @override
  String get webSearch_safeSearchPillDefault => '安全：默认';

  @override
  String get webSearch_safeSearchPillOff => '安全：关闭';

  @override
  String get webSearch_safeSearchPillModerate => '安全：适中';

  @override
  String get webSearch_safeSearchPillStrict => '安全：严格';

  @override
  String get webSearch_safeSearchMenuDefault => '默认（适中）';

  @override
  String get webSearch_safeSearchMenuOff => '关闭';

  @override
  String get webSearch_safeSearchMenuModerate => '适中';

  @override
  String get webSearch_safeSearchMenuStrict => '严格';

  @override
  String get webSearch_freshnessAnyTime => '任何时间';

  @override
  String get webSearch_freshnessPastDay => '过去一天';

  @override
  String get webSearch_freshnessPastWeek => '过去一周';

  @override
  String get webSearch_freshnessPastMonth => '过去一个月';

  @override
  String get webSearch_freshnessPastYear => '过去一年';

  @override
  String get webSearch_modeGeneralLabel => '综合';

  @override
  String get webSearch_modeIndependentWebLabel => '独立网站';

  @override
  String get webSearch_modeSmallWebLabel => '小众网络';

  @override
  String get webSearch_modeGeneralDescription => '在整个开放网络中提供均衡的结果';

  @override
  String get webSearch_modeIndependentWebDescription => '优先选择规模较小、商业化程度较低的来源';

  @override
  String get webSearch_modeSmallWebDescription => '独立、个人和小众网站';

  @override
  String get webSearch_fetchTooltip => '获取';

  @override
  String get webSearch_additionalSnippetsHeading => '更多摘录';

  @override
  String get webSearch_questionPrefix => '问：';

  @override
  String get webSearch_snippetsTooltip => '摘录';

  @override
  String webSearch_showMoreLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '显示另外 $count 个链接',
    );
    return '$_temp0';
  }

  @override
  String get webSearch_factsheetHeading => '概况';

  @override
  String get webSearch_searchFailedTitle => '搜索失败';

  @override
  String get webSearch_searchingLabel => '正在搜索网络…';

  @override
  String webSearch_noResultsFor(String query) {
    return '未找到与“$query”相关的结果。';
  }

  @override
  String webSearch_creditsTokensStatus(int credits, int tokens) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '额度 $credits',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tokens,
      locale: localeName,
      other: '令牌 $tokens',
    );
    return '$_temp0  |  $_temp1';
  }

  @override
  String get webSearch_needsCreditsMessage => '没有可用于新网页搜索的搜索额度或令牌。';

  @override
  String get webSearch_buySearchPackButton => '购买搜索套餐';

  @override
  String get webSearch_socketConnectionError => '搜索连接出错，请重试。';

  @override
  String get webSearch_closeErrorSessionTimeout => '搜索会话超时，请重试。';

  @override
  String get webSearch_closeErrorCreditInvalid => '无法验证你的搜索额度。该额度可能已被使用，请重试。';

  @override
  String get webSearch_closeErrorPolicyForbidden => '搜索策略不允许访问所请求的页面。';

  @override
  String get webSearch_closeErrorServerFailed => '服务器端搜索失败，请重试。';

  @override
  String webSearch_closeErrorUnknown(int code) {
    return '搜索连接意外关闭（代码 $code），请重试。';
  }

  @override
  String get webSearch_unknownErrorDetail => '未知错误';

  @override
  String webSearch_streamErrorProtocol(String detail) {
    return '搜索协议错误，会话已结束，请重试。（$detail）';
  }

  @override
  String webSearch_streamErrorSearchFailed(String detail) {
    return '服务器端搜索失败，请重试。（$detail）';
  }

  @override
  String webSearch_streamErrorFetchFailed(String detail) {
    return '无法从来源获取此页面。（$detail）';
  }

  @override
  String webSearch_streamErrorExtractFailed(String detail) {
    return '无法从此页面提取可读预览。（$detail）';
  }

  @override
  String webSearch_streamErrorNotAllowed(String detail) {
    return '搜索策略不允许访问此页面。（$detail）';
  }

  @override
  String webSearch_streamErrorCaptureFailed(String detail) {
    return '页面捕获失败。（$detail）';
  }

  @override
  String webSearch_streamErrorGeneric(String detail) {
    return '搜索错误：$detail';
  }

  @override
  String webSearch_torStartFailed(String torBrand) {
    return '无法为搜索启动 $torBrand。请关闭 $torBrand 开关或重试。';
  }

  @override
  String get webSearch_creditCheckFailed => '无法检查搜索额度，请重试。';

  @override
  String get webSearch_tokenIssuanceFailed => '无法发放搜索令牌，请重试。';

  @override
  String get mainApp_initializationErrorTitle => '初始化错误';

  @override
  String get mainApp_initializationErrorMessage => '无法初始化应用';

  @override
  String get mainApp_initStageLoadingFormats => '正在加载格式…';

  @override
  String get mainApp_initStageLoadingPackageInfo => '正在加载应用信息…';

  @override
  String get mainApp_initStageSyncingBangs => '正在同步 Bang…';

  @override
  String get mainApp_downloadCompleted => '下载完成';

  @override
  String get mainApp_downloadOpenFailed => '无法打开已下载的文件';

  @override
  String mainApp_downloadFailed(String name) {
    return '下载失败：$name';
  }

  @override
  String mainApp_containerBlockedWithHost(String host) {
    return '$host 未分配给此容器';
  }

  @override
  String get mainApp_containerBlockedNoHost => '此网站未分配给此容器';

  @override
  String get mainApp_sandboxNoCredits => '你的搜索额度已用完。请购买更多额度以继续。';

  @override
  String get mainApp_sandboxTokenIssuanceFailed => '无法发放新的搜索令牌。请检查网络连接后重试。';

  @override
  String mainApp_sandboxFetchPolicyRejected(String detail) {
    return '抓取策略阻止了此次捕获：$detail';
  }

  @override
  String get mainApp_sandboxDetailNotAllowed => '不允许';

  @override
  String mainApp_sandboxCaptureFailed(String detail) {
    return '捕获失败：$detail';
  }

  @override
  String get mainApp_sandboxDetailUnknownError => '未知错误';

  @override
  String get mainApp_sandboxDownloadFailed => '无法下载捕获结果。';

  @override
  String mainApp_sandboxUnknownError(String detail) {
    return '沙盒捕获错误：$detail';
  }

  @override
  String get mainApp_syncFailed => '同步失败';

  @override
  String get startup_pickerTitle => '选择配置文件';

  @override
  String startup_pickerEachProfileKeepsOwn(String contents) {
    return '每个配置文件都保留各自的$contents。';
  }

  @override
  String get startup_pickerOpensByDefaultLocked => '默认打开 · 已锁定';

  @override
  String get startup_pickerOpensByDefault => '默认打开';

  @override
  String get startup_pickerLocked => '已锁定';

  @override
  String get startup_haltMaintenanceTitle => '未完成的配置文件操作';

  @override
  String get startup_haltMaintenanceBody =>
      '之前运行时的备份、恢复或删除操作未完成。WebLibre 必须先完成它，才能打开任何配置文件。';

  @override
  String get startup_haltUnavailableTitle => '启动尚未就绪';

  @override
  String startup_haltUnavailableBody(String reopenToContinue) {
    return 'WebLibre 需要重启后才能选择配置文件。$reopenToContinue';
  }

  @override
  String get startup_haltProfileAccessBusyTitle => '配置文件正在使用中';

  @override
  String get startup_haltProfileAccessBusyBody =>
      '另一个 WebLibre 任务仍在使用此配置文件。请稍后重试。';

  @override
  String get startup_haltNoProfileTitle => '没有可用的配置文件';

  @override
  String get startup_haltNoProfileBody =>
      'WebLibre 无法读取现有配置文件，也无法创建新的配置文件。存储空间可能已满或不可用。';

  @override
  String get startup_haltArbitrationFailedTitle => '无法确定要打开哪个配置文件';

  @override
  String startup_haltArbitrationFailedBody(String reopenToContinue) {
    return 'WebLibre 不会猜测要使用哪个配置文件。$reopenToContinue';
  }

  @override
  String get startup_tryAgain => '重试';

  @override
  String get startup_tryingAgain => '正在重试…';

  @override
  String get startup_closeWebLibre => '关闭 WebLibre';

  @override
  String get startup_technicalDetails => '技术详情';

  @override
  String get startup_copyDetails => '复制详情';

  @override
  String get startup_maintenanceFinishingInterrupted => '正在完成因上次重启而中断的操作…';

  @override
  String get startup_maintenanceNotRunnableUnsupported =>
      '此任务由较新版本的 WebLibre 创建，无法在此运行。';

  @override
  String get startup_maintenanceNotRunnableNoDestination => '此备份没有记录目标文件夹。';

  @override
  String get startup_maintenanceNotRunnableNoBackupFile => '此恢复没有记录备份文件。';

  @override
  String get startup_maintenanceNotRunnableRestoreHere =>
      'WebLibre 无法在此启动界面中执行恢复。';

  @override
  String get startup_maintenanceNotRunnableDeleteHere =>
      'WebLibre 无法在此启动界面中删除配置文件。';

  @override
  String get startup_maintenanceRecoveredRestore => '已完成一次中断的恢复。';

  @override
  String get startup_maintenanceRecoveredRestoreRolledBack =>
      '已撤销一次中断的恢复。配置文件保持原样。';

  @override
  String get startup_maintenanceRecoveredRestoreReconciled =>
      '已清理一次中断的恢复。请检查配置文件，确认备份是否已应用。';

  @override
  String get startup_maintenanceRecoveredDeletion => '已完成一次中断的删除。';

  @override
  String get startup_maintenanceTaskDidNotFinish => '操作未完成。';

  @override
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  ) {
    return 'WebLibre 已无法安全地处理此配置文件。$nothingChanged$reopenToContinue';
  }

  @override
  String startup_maintenanceTaskCancelled(String task) {
    return '已取消$task。';
  }

  @override
  String get startup_maintenanceEvidenceDiscarded => '已舍弃中断记录。';

  @override
  String get startup_maintenanceEvidenceDiscardedKept =>
      '已舍弃中断记录。WebLibre 无法确定已保存的数据属于哪个配置文件，因此将其保留在设备上，而不是删除。';

  @override
  String startup_maintenanceWrongPassword(String nothingChanged) {
    return '此密码无法打开该备份文件。请检查后重试。$nothingChanged';
  }

  @override
  String startup_maintenanceUnreadableArchive(String nothingChanged) {
    return '此密码无法打开该备份文件，或文件已损坏。请检查密码后重试。$nothingChanged';
  }

  @override
  String startup_maintenanceDamagedArchive(String nothingChanged) {
    return '此备份文件已损坏，无法读取。$nothingChanged';
  }

  @override
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged) {
    return '此备份文件由较新版本的 WebLibre 创建，无法在此读取。$nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  ) {
    return '可用空间不足：此操作大约需要 $required，但仅有 $free 可用。$nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  ) {
    return '可用空间不足：此操作大约需要 $required。$nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged) {
    return '可用空间不足，无法执行此操作。$nothingChanged';
  }

  @override
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged) {
    return '无法将备份写入该文件夹。请重新选择文件夹后重试。$nothingChanged';
  }

  @override
  String get startup_maintenanceProfileNoLongerExists => '该配置文件已不存在。';

  @override
  String get startup_maintenanceRestoreEvidenceUnresolved =>
      '此前尝试此恢复时留下了一条尚未处理的记录。';

  @override
  String get startup_maintenanceRestoreWrongProfile => '此备份与要替换的配置文件不匹配。';

  @override
  String get startup_maintenanceRestoreRejected => '无法恢复此备份文件。';

  @override
  String get startup_maintenanceRestoreIncomplete => '备份文件不完整。';

  @override
  String get startup_maintenanceRestoreNoMetadata => '备份文件中没有配置文件元数据。';

  @override
  String get startup_maintenanceRestoreMalformedMetadata =>
      '无法读取备份文件中的配置文件元数据。';

  @override
  String get startup_maintenanceRestoreNoProfileData => '备份文件中没有配置文件数据。';

  @override
  String get startup_maintenanceHeadline => '配置文件维护';

  @override
  String get startup_maintenanceMustFinish =>
      '此任务必须完成后才能打开任何配置文件。在任务进行期间，WebLibre 会保持配置文件关闭。';

  @override
  String get startup_maintenanceNothingLeft => '没有需要完成的操作了。';

  @override
  String get startup_maintenanceCannotReadRecord =>
      'WebLibre 发现了中断的配置文件操作，但无法读取其记录。';

  @override
  String get startup_maintenancePasswordLabel => '备份文件密码';

  @override
  String get startup_maintenancePasswordRejected => '此密码无法打开该备份文件';

  @override
  String get startup_maintenancePasswordHelperRequiredBackup =>
      '必填。恢复备份时需要此密码，且它不会被保存在任何地方。';

  @override
  String get startup_maintenancePasswordHelperRequiredRestore =>
      '必填。请输入创建此备份文件时使用的密码。';

  @override
  String get startup_maintenancePasswordHelperBackup =>
      '恢复备份时需要此密码。它不会被保存在任何地方。';

  @override
  String get startup_maintenancePasswordHelperRestore => '创建此备份文件时使用的密码。';

  @override
  String get startup_maintenanceTryFinishingAgain => '再次尝试完成';

  @override
  String get startup_maintenanceDiscardAndContinueBlocked => '舍弃记录并继续';

  @override
  String get startup_maintenanceDiscardAndContinueNoTasks => '舍弃记录并继续';

  @override
  String get startup_maintenanceOpenWebLibreRetry => '打开 WebLibre';

  @override
  String get startup_maintenanceOpenWebLibre => '打开 WebLibre';

  @override
  String get startup_maintenanceTakesSeveralMinutes =>
      '这可能需要几分钟。请保持 WebLibre 打开。';

  @override
  String get startup_maintenanceThenAfterThisOne => '接下来';

  @override
  String get startup_maintenanceSkipForNow => '暂时跳过';

  @override
  String get startup_maintenanceInterruptedMustFinish =>
      '此操作在开始后被中断。必须先完成它才能打开任何配置文件。';

  @override
  String get startup_maintenanceInterruptedFinishFailed =>
      '此操作在开始后被中断，且未能成功完成。在完成之前，无法重新开始。';

  @override
  String get startup_maintenanceInterruptedUnreadable =>
      '此操作在开始后被中断，且 WebLibre 无法读取它当时正在执行的内容。在处理该记录之前，无法再次运行。';

  @override
  String get startup_maintenanceDiscardDialogTitle => '舍弃中断记录？';

  @override
  String get startup_maintenanceDiscardDialogContent =>
      'WebLibre 无法读取备份、恢复或删除操作停止时正在执行的内容。舍弃该记录后浏览器即可再次打开，但之后可能需要检查被替换的配置文件。\n\n如果配置文件缺失，WebLibre 会恢复替换前保存的数据。如果配置文件存在，WebLibre 会删除这些已保存的数据。如果 WebLibre 无法确定已保存的数据属于哪个配置文件，则会保留数据而不是删除。';

  @override
  String get startup_maintenanceDiscardIt => '舍弃';

  @override
  String get startup_maintenanceBackupVerb => '立即备份';

  @override
  String get startup_maintenanceBackupRetry => '重试备份';

  @override
  String get startup_maintenanceBackupCancel => '取消此备份';

  @override
  String startup_maintenanceBackupDescribe(String profileName) {
    return '备份“$profileName”';
  }

  @override
  String startup_maintenanceBackupConsequence(String secretDataDescription) {
    return '为此配置文件写入一个加密的备份文件，其中包括其$secretDataDescription。';
  }

  @override
  String startup_maintenanceBackupActivity(String profileName) {
    return '正在打包“$profileName”…';
  }

  @override
  String startup_maintenanceBackupDescribeDone(String profileName) {
    return '“$profileName”已备份到你选择的文件夹。';
  }

  @override
  String get startup_maintenanceRestoreOverVerb => '立即替换';

  @override
  String get startup_maintenanceRestoreOverRetry => '重试恢复';

  @override
  String get startup_maintenanceRestoreOverCancel => '取消此恢复';

  @override
  String startup_maintenanceRestoreOverDescribe(String profileName) {
    return '替换“$profileName”';
  }

  @override
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return '用备份替换此配置文件中的所有内容。$signedInFromBackup$olderBackupKeepsCredentials它还会采用备份的名称。$cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return '用备份替换此配置文件中的所有内容。$signedInFromBackup$olderBackupKeepsCredentials$cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverActivity(String profileName) {
    return '正在替换“$profileName”…';
  }

  @override
  String startup_maintenanceRestoreOverDescribeDone(String profileName) {
    return '“$profileName”已被替换为备份。';
  }

  @override
  String get startup_maintenanceDeleteVerb => '立即删除';

  @override
  String get startup_maintenanceDeleteRetry => '重试删除';

  @override
  String get startup_maintenanceDeleteCancel => '取消此删除';

  @override
  String startup_maintenanceDeleteDescribe(String profileName) {
    return '删除“$profileName”';
  }

  @override
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return '移除此配置文件及其$profileDataDescription。$cannotBeUndone';
  }

  @override
  String startup_maintenanceDeleteActivity(String profileName) {
    return '正在删除“$profileName”…';
  }

  @override
  String startup_maintenanceDeleteDescribeDone(String profileName) {
    return '“$profileName”已删除。';
  }

  @override
  String get startup_maintenanceRestoreCloneVerb => '无法运行';

  @override
  String get startup_maintenanceRestoreCloneRetry => '重试恢复';

  @override
  String get startup_maintenanceRestoreCloneCancel => '取消此恢复';

  @override
  String startup_maintenanceRestoreCloneDescribe(String profileName) {
    return '恢复“$profileName”';
  }

  @override
  String get startup_maintenanceRestoreCloneConsequence =>
      '此恢复由较新版本的 WebLibre 创建，无法在此运行。';

  @override
  String startup_maintenanceRestoreCloneActivity(String profileName) {
    return '正在恢复“$profileName”…';
  }

  @override
  String startup_maintenanceRestoreCloneDescribeDone(String profileName) {
    return '“$profileName”已恢复。';
  }

  @override
  String get startup_maintenanceUnknownVerb => '运行';

  @override
  String get startup_maintenanceUnknownRetry => '重试任务';

  @override
  String get startup_maintenanceUnknownCancel => '取消此任务';

  @override
  String startup_maintenanceUnknownDescribe(String taskId) {
    return '未知任务 $taskId';
  }

  @override
  String get startup_maintenanceUnknownConsequence =>
      '此任务由较新版本的 WebLibre 创建，无法运行。';

  @override
  String get startup_maintenanceUnknownActivity => '正在处理…';

  @override
  String get startup_maintenanceUnknownDescribeDone => '完成。';

  @override
  String units_bytes(String value) {
    return '$value B';
  }

  @override
  String units_kilobytes(String value) {
    return '$value KB';
  }

  @override
  String units_megabytes(String value) {
    return '$value MB';
  }

  @override
  String units_milliseconds(String value) {
    return '$value 毫秒';
  }

  @override
  String get failureWidget_defaultTitle => '出了点问题';

  @override
  String get failureWidget_unknownError => '未知错误';

  @override
  String get speechToTextButton_serviceNotAvailable => '语音识别不可用';

  @override
  String get formValidators_urlRequired => '必须填写网址';

  @override
  String get formValidators_invalidUrl => '网址无效';

  @override
  String get formValidators_valueRequired => '必须填写此项';

  @override
  String get formValidators_nameRequired => '必须填写名称';

  @override
  String get formValidators_nameInvalidCharacters => '名称包含无效字符';

  @override
  String uiHelper_findInPageSuggestion(String query) {
    return '在此页面中查找“$query”？';
  }

  @override
  String get uiHelper_actionFind => '查找';

  @override
  String uiHelper_openedTabsFromAnotherDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已打开来自其他设备的 $count 个标签页',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_navigateBackToCloseTab => '再按一次“返回”关闭当前标签页';

  @override
  String get uiHelper_navigateBackToExitApp => '再按一次“返回”退出应用';

  @override
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName) {
    return '已在后台打开新标签页“$tabName”';
  }

  @override
  String get uiHelper_newTabOpenedInBackground => '已在后台打开新标签页';

  @override
  String get uiHelper_actionShow => '查看';

  @override
  String get uiHelper_wantToOpenLinkFromClipboard => '打开剪贴板中的链接？';

  @override
  String uiHelper_newTabOpenedNamed(String tabName) {
    return '已打开新标签页“$tabName”';
  }

  @override
  String get uiHelper_newTabOpened => '已打开新标签页';

  @override
  String get uiHelper_actionSwitch => '切换';

  @override
  String uiHelper_couldNotLaunchUrl(String url) {
    return '无法打开网址（$url）';
  }

  @override
  String uiHelper_canNotHandleScheme(String scheme) {
    return '无法处理“$scheme”';
  }

  @override
  String uiHelper_tabsClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已关闭 $count 个标签页',
      one: '已关闭标签页',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_closeIsolatedTabsTitle => '关闭隔离标签页？';

  @override
  String uiHelper_closeIsolatedTabsConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这将永久清除 $count 个隔离会话的浏览数据。',
      one: '这将永久清除此隔离会话的所有浏览数据。',
    );
    return '$_temp0';
  }
}
