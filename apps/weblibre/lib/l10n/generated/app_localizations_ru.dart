// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_close => 'Закрыть';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_add => 'Добавить';

  @override
  String get common_edit => 'Изменить';

  @override
  String get common_remove => 'Удалить';

  @override
  String get common_clear => 'Очистить';

  @override
  String get common_copy => 'Копировать';

  @override
  String get common_open => 'Открыть';

  @override
  String get common_reset => 'Сбросить';

  @override
  String get common_retry => 'Повторить';

  @override
  String get common_done => 'Готово';

  @override
  String get common_undo => 'Отменить';

  @override
  String get common_dismiss => 'Скрыть';

  @override
  String get common_discard => 'Отбросить';

  @override
  String get common_showLess => 'Свернуть';

  @override
  String get common_loading => 'Загрузка…';

  @override
  String get profileCopy_pickerContents => 'вкладки, историю и настройки';

  @override
  String get profileCopy_dataDescription =>
      'вкладки, история, закладки, настройки и сохранённые логины сайтов';

  @override
  String get profileCopy_secretDataDescription =>
      'вход в аккаунт WebLibre, настройки синхронизации и данные прокси';

  @override
  String get profileCopy_cannotBeUndone => 'Это действие нельзя отменить.';

  @override
  String get profileCopy_nothingChanged => 'Ничего не было изменено.';

  @override
  String get profileCopy_restartsToWork =>
      'Для этого WebLibre нужно перезапустить.';

  @override
  String get profileCopy_asksPasswordAfterRestart =>
      'После перезапуска WebLibre запросит пароль файла резервной копии.';

  @override
  String get profileCopy_reopenToContinue =>
      'Закройте WebLibre и откройте снова.';

  @override
  String get profileCopy_signedInFromBackup =>
      'Восстановленный профиль использует аккаунт WebLibre из резервной копии.';

  @override
  String get profileCopy_olderBackupKeepsCredentials =>
      'Резервная копия, созданная старой версией WebLibre, не содержит данных входа в аккаунт, поэтому текущие данные входа сохранятся.';

  @override
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged) {
    return 'WebLibre не удалось запланировать перезапуск, необходимый для этой операции. $nothingChanged';
  }

  @override
  String get profileCopy_shortcutsNeedPinningAgain =>
      'После восстановления заново добавьте ярлыки на главный экран.';

  @override
  String get profileCopy_restartClosesCurrentProfile =>
      'Также будет закрыт профиль, который вы используете сейчас, — это не всегда профиль, указанный здесь.';

  @override
  String get profileCopy_restartKeepsOtherTabs =>
      'Остальные вкладки откроются снова после перезапуска.';

  @override
  String profileCopy_privateTabsClosedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count приватных вкладок закроются, и их данные просмотра будут удалены.',
      many:
          '$count приватных вкладок закроются, и их данные просмотра будут удалены.',
      few:
          '$count приватные вкладки закроются, и их данные просмотра будут удалены.',
      one:
          '$count приватная вкладка закроется, и её данные просмотра будут удалены.',
    );
    return '$_temp0';
  }

  @override
  String profileCopy_containersClearedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count контейнера, настроенных на очистку данных при выходе, будут очищены.',
      many:
          '$count контейнеров, настроенных на очистку данных при выходе, будут очищены.',
      few:
          '$count контейнера, настроенных на очистку данных при выходе, будут очищены.',
      one:
          '$count контейнер, настроенный на очистку данных при выходе, будет очищен.',
    );
    return '$_temp0';
  }

  @override
  String get httpErrorHandler_socketError =>
      'Не удалось связаться с удалённым сервисом';

  @override
  String get httpErrorHandler_httpError => 'Веб-запрос вернул ошибку';

  @override
  String get httpErrorHandler_formatError => 'Неверный формат ответа';

  @override
  String get httpErrorHandler_clientError =>
      'Не удалось связаться с удалённым сервисом';

  @override
  String profileDiscovery_recoveredProfileName(String idFragment) {
    return 'Восстановленный профиль $idFragment';
  }

  @override
  String get about_copyright => 'Copyright © Fabian Freund, 2024-2026';

  @override
  String get about_geckoVersionTitle => 'Версия Gecko';

  @override
  String get about_notAvailable => 'Н/Д';

  @override
  String get about_feedbackTitle => 'Обратная связь';

  @override
  String get about_donateTitle => 'Пожертвовать';

  @override
  String get about_documentationTitle => 'Документация';

  @override
  String get about_githubTitle => 'GitHub';

  @override
  String get account_screenTitle => 'Аккаунт WebLibre';

  @override
  String get account_searchHint => 'Поиск в настройках аккаунта';

  @override
  String get account_loadFailed => 'Не удалось загрузить аккаунт';

  @override
  String get account_sectionAccount => 'Аккаунт';

  @override
  String get account_sectionSubscription => 'Подписка';

  @override
  String get account_sectionSearchCredits => 'Поисковые кредиты';

  @override
  String get account_sectionSettingsSnapshots => 'Снимки настроек';

  @override
  String get account_sectionPreferencesSnapshots => 'Снимки параметров';

  @override
  String get account_sectionEncryptedSync => 'Зашифрованная синхронизация';

  @override
  String get account_signInTitle => 'Войти в аккаунт WebLibre';

  @override
  String get account_signInKeywords =>
      'вход, войти, аккаунт, учётная запись, авторизация';

  @override
  String get account_signInSyncKeyKeywords =>
      'ключ синхронизации, сбросить ключ синхронизации';

  @override
  String get account_signingInTitle => 'Выполняется вход';

  @override
  String get account_signedInTitle => 'Аккаунт, в который выполнен вход';

  @override
  String get account_signInFailedTitle => 'Ошибка входа';

  @override
  String get account_syncAcrossDevicesSubtitle =>
      'Синхронизируйте настройки между устройствами';

  @override
  String get account_signingInSubtitle => 'Завершите вход в браузере';

  @override
  String get account_signedInFallback => 'Вход выполнен';

  @override
  String get account_entrySupporterSubscriptionTitle => 'Подписка сторонника';

  @override
  String get account_entrySupporterSubscriptionKeywords =>
      'оплата, платёж, сторонник, поддержка, supporter';

  @override
  String get account_entrySupporterSubscriptionSubtitle =>
      'Состояние, оплата и управление подпиской';

  @override
  String get account_entrySearchCreditsTitle => 'Поисковые кредиты';

  @override
  String get account_entrySearchCreditsKeywords =>
      'токены, поисковый пакет, баланс';

  @override
  String get account_entrySearchCreditsSubtitle =>
      'Баланс кредитов, выдача токенов и покупки';

  @override
  String get account_entrySettingsSnapshotsTitle => 'Снимки настроек';

  @override
  String get account_entrySettingsSnapshotsKeywords =>
      'резервные копии, синхронизация настроек';

  @override
  String get account_entrySettingsSnapshotsSubtitle =>
      'Сохранение и восстановление синхронизируемых настроек приложения';

  @override
  String get account_entryPreferencesSnapshotsTitle => 'Снимки параметров';

  @override
  String get account_entryPreferencesSnapshotsKeywords =>
      'резервные копии, синхронизация параметров, prefs';

  @override
  String get account_entryPreferencesSnapshotsSubtitle =>
      'Сохранение и восстановление синхронизируемых документов параметров';

  @override
  String get account_entrySetupEncryptedSyncTitle =>
      'Настроить зашифрованную синхронизацию';

  @override
  String get account_entrySetupEncryptedSyncKeywords =>
      'ключ синхронизации, резервные копии, снимки';

  @override
  String get account_entrySetupEncryptedSyncSubtitle =>
      'Включить сквозное шифрование синхронизации с помощью пароля аккаунта';

  @override
  String get account_actionRestore => 'Восстановить';

  @override
  String get account_actionEditLabel => 'Изменить метку';

  @override
  String get account_actionStore => 'Сохранить';

  @override
  String get account_actionTryAgain => 'Повторить';

  @override
  String get account_actionSignOut => 'Выйти';

  @override
  String get account_actionEnableSync => 'Включить синхронизацию';

  @override
  String get account_adoptTitleUsable =>
      'На этом устройстве остался старый вход';

  @override
  String get account_adoptTitleUnusable => 'Не удаётся прочитать старый вход';

  @override
  String account_adoptBodyUsable(String name) {
    return 'WebLibre сохранил вход ($name) со времён, когда у профилей ещё не было отдельных аккаунтов. Он не из резервной копии, и на этом устройстве нигде не записано, какому профилю он принадлежал, поэтому WebLibre не будет гадать.';
  }

  @override
  String get account_adoptBodyUnusable =>
      'WebLibre сохранил вход со времён, когда у профилей ещё не было отдельных аккаунтов, но сохранённые данные повреждены и не подходят для входа. Вернуть доступ можно только повторным входом; удаление убирает это сообщение.';

  @override
  String get account_adoptRetryError =>
      'Не получилось. Проверьте подключение и повторите попытку.';

  @override
  String get account_adoptNotMine => 'Это не мой';

  @override
  String get account_adoptRemoveIt => 'Удалить';

  @override
  String get account_adoptUseItHere => 'Использовать здесь';

  @override
  String get account_forgetSignInTitle => 'Забыть этот вход?';

  @override
  String account_forgetSignInContent(String name) {
    return 'Сохранённый сеанс ($name) будет удалён с этого устройства. Если он принадлежал другому профилю, там придётся войти снова.';
  }

  @override
  String get account_actionForgetIt => 'Забыть';

  @override
  String get account_previousSignInFallback => 'имя неизвестно';

  @override
  String account_signInAgainAs(String account) {
    return 'Войти снова как $account';
  }

  @override
  String get account_signInExpiredSubtitle =>
      'Срок сохранённого входа этого профиля истёк. Ключ синхронизации сохранён.';

  @override
  String get account_signingInEllipsis => 'Выполняется вход…';

  @override
  String get account_completeSignInInApp => 'Завершите вход в WebLibre';

  @override
  String get account_tooltipSignOut => 'Выйти';

  @override
  String get account_signOutConfirmTitle => 'Выйти?';

  @override
  String get account_signOutConfirmContent => 'Выйти из аккаунта WebLibre?';

  @override
  String get account_resetSyncKeyTitle => 'Сбросить ключ синхронизации';

  @override
  String get account_resetSyncKeySubtitle =>
      'Введите пароль заново, если вы ошиблись при вводе или изменили его';

  @override
  String get account_resetSyncKeyConfirmContent =>
      'Нужно будет заново ввести пароль аккаунта. Если пароль изменился, существующие снимки, зашифрованные старым паролем, больше не удастся расшифровать.';

  @override
  String get account_subscriptionLoadFailed => 'Не удалось загрузить подписку';

  @override
  String get account_checkConnectionRetry =>
      'Проверьте подключение и повторите попытку.';

  @override
  String get account_planFallbackSupporter => 'Сторонник';

  @override
  String get account_badgeWillNotRenew => 'Не будет продлена';

  @override
  String get account_badgeActive => 'Активна';

  @override
  String account_untilDate(String date) {
    return 'До $date';
  }

  @override
  String get account_actionManageSubscription => 'Управление подпиской';

  @override
  String get account_badgePaused => 'Приостановлена';

  @override
  String get account_pausedNote =>
      'Подписка приостановлена. Возобновите её в личном кабинете, чтобы восстановить доступ.';

  @override
  String get account_badgePastDue => 'Просрочена';

  @override
  String get account_pastDueNote =>
      'Платёж не прошёл. Обновите способ оплаты, чтобы подписка оставалась активной.';

  @override
  String get account_actionUpdatePaymentMethod => 'Обновить способ оплаты';

  @override
  String get account_endedNote =>
      'Подписка закончилась. Продлите её в личном кабинете, чтобы продолжить.';

  @override
  String get account_actionRenewSubscription => 'Продлить подписку';

  @override
  String get account_planSupporterSubscription => 'Подписка сторонника';

  @override
  String get account_subscribeSubtitle =>
      'Оформите подписку, чтобы открыть функции синхронизации';

  @override
  String get account_badgeInactive => 'Неактивна';

  @override
  String get account_actionSubscribe => 'Подписаться';

  @override
  String get account_tooltipRefreshStatus => 'Обновить состояние';

  @override
  String account_subscriptionEndsOn(String date) {
    return 'Подписка закончится $date';
  }

  @override
  String get account_bannerTitle => 'Поддержите WebLibre';

  @override
  String get account_bannerBody =>
      'Подписка сторонника необязательна: она помогает финансировать разработку WebLibre и даёт доступ к функциям, для которых нужен сервер. Сам браузер и его функции защиты приватности доступны без подписки. <learnMore>Подробнее</learnMore>.';

  @override
  String get account_featureSearchLabel => 'WebLibre Search';

  @override
  String get account_featureSearchDescription =>
      'Приватный поиск без рекламы, встроенный в браузер. Он объединяет результаты из нескольких независимых источников, предлагает настраиваемые режимы поиска, может работать через Tor и позволяет безопасно просматривать страницы. Архитектура сервиса не позволяет связать ваши поисковые запросы с аккаунтом.';

  @override
  String get account_featureSyncLabel => 'Зашифрованная синхронизация аккаунта';

  @override
  String get account_featureSyncDescription =>
      'Сохраняйте и восстанавливайте настройки и параметры WebLibre в разных профилях и на разных устройствах. Всё шифруется на устройстве перед отправкой, поэтому прочитать данные можете только вы.';

  @override
  String get account_becomeSupporter => 'Стать сторонником';

  @override
  String get account_syncSetupEnterPassword => 'Введите пароль';

  @override
  String get account_syncSetupPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get account_syncSetupPasswordMismatchBackup =>
      'Пароль не подходит к существующим зашифрованным резервным копиям.';

  @override
  String account_syncSetupFailed(String error) {
    return 'Не удалось настроить синхронизацию: $error';
  }

  @override
  String get account_syncSetupTitle => 'Настройка зашифрованной синхронизации';

  @override
  String get account_syncSetupDescription =>
      'Введите пароль аккаунта, чтобы включить сквозное шифрование синхронизации. Данные шифруются на устройстве перед отправкой — сервер никогда не видит ваши настройки.';

  @override
  String get account_fieldAccountPassword => 'Пароль аккаунта';

  @override
  String get account_fieldConfirmPassword => 'Подтверждение пароля';

  @override
  String account_failedLoadSnapshots(String error) {
    return 'Не удалось загрузить снимки: $error';
  }

  @override
  String account_syncKindStored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Настройки сохранены',
      'geckoUserJs': 'Параметры Gecko сохранены',
      'other': 'Снимок сохранён',
    });
    return '$_temp0';
  }

  @override
  String account_syncKindSnapshotsTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Снимки настроек',
      'geckoUserJs': 'Снимки параметров Gecko',
      'other': 'Снимки',
    });
    return '$_temp0';
  }

  @override
  String get account_storeCurrentTitle => 'Сохранить текущие';

  @override
  String account_storeCurrentSubtitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Зашифровать и отправить текущие настройки',
      'geckoUserJs': 'Зашифровать и отправить текущие параметры Gecko',
      'other': 'Зашифровать и отправить текущие данные',
    });
    return '$_temp0';
  }

  @override
  String get account_noSnapshotsYet => 'Снимков пока нет';

  @override
  String account_failedToStore(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String account_syncKindRestored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Настройки восстановлены',
      'geckoUserJs': 'Параметры Gecko восстановлены',
      'other': 'Снимок восстановлен',
    });
    return '$_temp0';
  }

  @override
  String get account_snapshotNotFound => 'Снимок не найден';

  @override
  String get account_decryptionFailed =>
      'Ошибка расшифровки — неверный пароль или повреждённые данные. Попробуйте сбросить ключ синхронизации.';

  @override
  String account_failedToRestore(String error) {
    return 'Не удалось восстановить: $error';
  }

  @override
  String account_failedUpdateLabel(String error) {
    return 'Не удалось обновить метку: $error';
  }

  @override
  String get account_snapshotDeleted => 'Снимок удалён';

  @override
  String account_failedToDelete(String error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String get account_untitledSnapshot => 'Без названия';

  @override
  String get account_metaLabel => 'Метка';

  @override
  String get account_metaStored => 'Сохранён';

  @override
  String get account_metaAppVersion => 'Версия приложения';

  @override
  String get account_metaDevice => 'Устройство';

  @override
  String get account_storeSnapshotTitle => 'Сохранить снимок';

  @override
  String get account_fieldLabelOptional => 'Метка (необязательно)';

  @override
  String get account_labelHintExample =>
      'например, «Перед обновлением», «Домашняя настройка»';

  @override
  String get account_fieldLabel => 'Метка';

  @override
  String get account_restoreSnapshotTitle => 'Восстановить снимок';

  @override
  String get account_restoreOverwriteWarning =>
      'Текущие локальные настройки будут перезаписаны.';

  @override
  String get account_thisSnapshotFallback => 'этот снимок';

  @override
  String get account_deleteSnapshotTitle => 'Удалить снимок';

  @override
  String account_deleteSnapshotConfirm(String label) {
    return 'Удалить $label?';
  }

  @override
  String get account_authNetworkError =>
      'Ошибка сети. Проверьте подключение и повторите попытку.';

  @override
  String get account_authSessionExpiredWithKey =>
      'Сохранённый вход больше недействителен. Войдите снова, чтобы завершить восстановление аккаунта, — ключ синхронизации сохранён.';

  @override
  String get account_authSessionExpiredNoKey =>
      'Сохранённый вход больше недействителен. Войдите снова, чтобы продолжить.';

  @override
  String get account_authRestoreFailedFallback =>
      'Не удалось восстановить сеанс аккаунта. Скоро будет новая попытка.';

  @override
  String get account_authSignInTimedOut =>
      'Время входа истекло. Повторите попытку.';

  @override
  String get account_authSignInOpenPageFailed =>
      'Не удалось открыть страницу входа. Повторите попытку.';

  @override
  String get account_authNoPendingSignIn =>
      'Незавершённый вход не найден. Начните вход заново.';

  @override
  String get account_authSignInVerificationFailed =>
      'Не удалось подтвердить вход. Повторите попытку.';

  @override
  String get account_authSignInNotCompleted =>
      'Не удалось завершить вход. Повторите попытку.';

  @override
  String get account_authSignInFailedFallback =>
      'Ошибка входа. Повторите попытку.';

  @override
  String get addons_managerTitle => 'Расширения';

  @override
  String get addons_tabInstalled => 'Установленные';

  @override
  String get addons_tabBrowse => 'Каталог';

  @override
  String get addons_loadFailedTitle => 'Не удалось загрузить расширения';

  @override
  String get addons_noExtensionsFound => 'Расширения не найдены.';

  @override
  String get addons_noneInstalledMessage =>
      'Расширения ещё не установлены.\nНайдите их в каталоге.';

  @override
  String get addons_genericTitle => 'Расширение';

  @override
  String get addons_notFound => 'Не удалось найти это расширение.';

  @override
  String get addons_platformAndroid => 'Android';

  @override
  String get addons_platformDesktop => 'ПК';

  @override
  String get addons_searchHint => 'Поиск на addons.mozilla.org';

  @override
  String get addons_desktopCompatibilityWarning =>
      'Расширения для ПК не проверяются для мобильных устройств. Некоторые из них могут не работать, аварийно завершаться или вести себя неожиданно на Android.';

  @override
  String get addons_actionInstall => 'Установить';

  @override
  String get addons_actionInstallExtension => 'Установить расширение';

  @override
  String get addons_actionInstallFromFile => 'Установить из файла';

  @override
  String get addons_actionViewPermissions => 'Просмотреть разрешения';

  @override
  String get addons_actionRemoveExtension => 'Удалить расширение';

  @override
  String get addons_actionNotNow => 'Не сейчас';

  @override
  String get addons_actionUpdate => 'Обновить';

  @override
  String get addons_actionCheckForUpdates => 'Проверить обновления';

  @override
  String get addons_actionCheckForUpdatesButton => 'Проверить обновления';

  @override
  String get addons_actionCheckingForUpdates => 'Проверка обновлений';

  @override
  String get addons_actionLearnMore => 'Подробнее';

  @override
  String get addons_actionReadMore => 'Читать далее';

  @override
  String get addons_sectionEnabled => 'Включённые';

  @override
  String get addons_sectionDisabled => 'Отключённые';

  @override
  String get addons_sectionUnsupported => 'Неподдерживаемые';

  @override
  String get addons_sectionDetails => 'Сведения';

  @override
  String get addons_sectionDescription => 'Описание';

  @override
  String get addons_sectionManagement => 'Управление';

  @override
  String get addons_sectionUpdates => 'Обновления';

  @override
  String get addons_sectionAboutExtension => 'Об этом расширении';

  @override
  String get addons_sectionTechnicalPermissions => 'Технические разрешения';

  @override
  String get addons_sectionMoreInformation => 'Дополнительная информация';

  @override
  String get addons_requiredDataCollectionTitle => 'Обязательный сбор данных';

  @override
  String get addons_tooltipRemoveExtension => 'Удалить расширение';

  @override
  String addons_extensionRemoved(String name) {
    return '$name удалено';
  }

  @override
  String addons_extensionInstalled(String name) {
    return '$name установлено';
  }

  @override
  String addons_installFailed(String error) {
    return 'Ошибка установки: $error';
  }

  @override
  String get addons_updateChecksStarted =>
      'Запущена фоновая проверка обновлений установленных расширений';

  @override
  String get addons_statusInstalled => 'Установлено';

  @override
  String get addons_statusDisabled => 'Отключено';

  @override
  String get addons_statusAvailable => 'Доступно';

  @override
  String get addons_chipPrivateBrowsing => 'Приватный просмотр';

  @override
  String get addons_chipRecommended => 'Рекомендуется';

  @override
  String get addons_removeConfirmTitle => 'Удалить расширение?';

  @override
  String addons_removeConfirmContent(String name) {
    return 'Удалить $name из WebLibre?';
  }

  @override
  String get addons_autoUpdateGloballyDisabled =>
      'Автоматические обновления отключены глобально.';

  @override
  String get addons_autoUpdateNeedsManualRun =>
      'Прежде чем включить автоматические обновления, один раз обновите расширение вручную и перезапустите приложение.';

  @override
  String get addons_autoUpdateAllow =>
      'Разрешить этому расширению получать обновления в фоне.';

  @override
  String get addons_autoUpdateDisabledForExtension =>
      'Фоновые обновления для этого расширения отключены.';

  @override
  String get addons_switchEnabledTitle => 'Включено';

  @override
  String get addons_switchEnabledSubtitleAllow =>
      'Разрешить этому расширению работать в WebLibre.';

  @override
  String get addons_switchEnabledSubtitleCannot =>
      'Это расширение нельзя безопасно включить.';

  @override
  String get addons_switchPrivateBrowsingTitle =>
      'Разрешить в приватном режиме';

  @override
  String get addons_switchPrivateBrowsingSubtitle =>
      'Разрешить этому расширению работать в приватных вкладках.';

  @override
  String get addons_switchAutoUpdateTitle => 'Автоматические обновления';

  @override
  String get addons_switchPinTitle => 'Закрепить на панели';

  @override
  String get addons_switchPinSubtitle =>
      'Показывать значок этого расширения на основной панели вкладок.';

  @override
  String get addons_menuExtensionSettingsTitle => 'Настройки расширения';

  @override
  String get addons_menuExtensionSettingsSubtitleTab =>
      'Открыть страницу настроек расширения во вкладке браузера';

  @override
  String get addons_menuExtensionSettingsSubtitleInline =>
      'Открыть страницу настроек расширения';

  @override
  String get addons_menuFilterListsTitle => 'Списки фильтров и усиление защиты';

  @override
  String get addons_menuFilterListsSubtitle =>
      'Управление списками фильтров и применение усиленной защиты WebLibre';

  @override
  String get addons_permissionsTitle => 'Разрешения';

  @override
  String addons_updateAvailable(String from, String to) {
    return 'Доступно обновление: $from → $to';
  }

  @override
  String get addons_noUpdateAttemptYet =>
      'Сведений о недавних попытках обновления пока нет.';

  @override
  String addons_lastChecked(String date) {
    return 'Последняя проверка: $date';
  }

  @override
  String get addons_noUpdateAvailable => 'Обновлений нет';

  @override
  String get addons_noRemoteUpdateSource =>
      'У этого локально установленного расширения нет источника обновлений в сети.';

  @override
  String get addons_updateCheckFailed =>
      'Не удалось запустить проверку обновлений.';

  @override
  String get addons_updateAvailableDialogTitle => 'Доступно обновление';

  @override
  String addons_updateConfirmContent(String name, String from, String to) {
    return 'Обновить $name с версии $from до $to?';
  }

  @override
  String get addons_noDescriptionProvided => 'Описание отсутствует.';

  @override
  String get addons_loadingDescription => 'Загрузка описания…';

  @override
  String get addons_fieldAuthor => 'Автор';

  @override
  String get addons_fieldVersion => 'Версия';

  @override
  String get addons_fieldLastUpdated => 'Последнее обновление';

  @override
  String get addons_fieldLastUpdatedInfo => 'Последнее обновление';

  @override
  String get addons_fieldHomepage => 'Домашняя страница';

  @override
  String get addons_fieldAddonListing => 'Страница в каталоге';

  @override
  String get addons_fieldSize => 'Размер';

  @override
  String get addons_fieldCategories => 'Категории';

  @override
  String get addons_fieldLicense => 'Лицензия';

  @override
  String get addons_fieldSupportSite => 'Сайт поддержки';

  @override
  String get addons_fieldReviews => 'Отзывы';

  @override
  String get addons_fieldPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get addons_linkViewOnAmo => 'Открыть на addons.mozilla.org';

  @override
  String get addons_settingsTitleGeneric => 'Настройки расширения';

  @override
  String addons_settingsTitleNamed(String name) {
    return 'Настройки $name';
  }

  @override
  String addons_settingsLoadFailed(String error) {
    return 'Не удалось загрузить настройки расширения: $error';
  }

  @override
  String get addons_noSettingsPage =>
      'У этого расширения нет страницы настроек.';

  @override
  String get addons_permissionsTitleGeneric => 'Разрешения расширения';

  @override
  String addons_permissionsTitleNamed(String name) {
    return 'Разрешения $name';
  }

  @override
  String addons_permissionsLoadFailed(String error) {
    return 'Не удалось загрузить разрешения расширения: $error';
  }

  @override
  String get addons_noSpecialPermissions => 'Особые разрешения не указаны';

  @override
  String get addons_noTranslatedPermissionDetails =>
      'Это расширение пока не предоставляет переведённых описаний разрешений.';

  @override
  String addons_versionSentence(String version) {
    return 'Версия $version';
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
      other: '$countString пользователя',
      many: '$countString пользователей',
      few: '$countString пользователя',
      one: '$countString пользователь',
    );
    return '$_temp0';
  }

  @override
  String addons_byAuthor(String name) {
    return 'автор: $name';
  }

  @override
  String get addons_permGroupRequired => 'Обязательные';

  @override
  String get addons_permGroupWebsites => 'Сайты';

  @override
  String get addons_permGroupOptional => 'Необязательные';

  @override
  String get addons_permGroupDataCollection => 'Сбор данных';

  @override
  String get addons_dateUnknown => 'Неизвестно';

  @override
  String get addons_statusUpdatedSuccessfully => 'Обновлено';

  @override
  String get addons_statusNotInstalled => 'Расширение не установлено';

  @override
  String addons_updateFailedWithMessage(String message) {
    return 'Ошибка обновления: $message';
  }

  @override
  String get addons_updateFailedGeneric => 'Ошибка обновления';

  @override
  String get addons_noUpdateChecksRecorded =>
      'Проверок обновлений пока не было';

  @override
  String get addons_statusBlocklisted =>
      'Это расширение занесено в список блокировки и должно оставаться отключённым.';

  @override
  String get addons_statusNotCorrectlySigned =>
      'Это расширение подписано неправильно и не может быть безопасно включено.';

  @override
  String get addons_statusIncompatible =>
      'Это расширение несовместимо с текущей версией приложения.';

  @override
  String get addons_statusSoftBlockedEnabled =>
      'Это расширение заблокировано с возможностью повторного включения. Будьте осторожны, пока оно работает.';

  @override
  String get addons_statusSoftBlockedDisabled =>
      'Это расширение заблокировано, но его можно снова включить.';

  @override
  String get addons_statusUnsupported =>
      'Это расширение установлено, но WebLibre пока его не поддерживает.';

  @override
  String get addons_permissionBookmarks => 'Читать и изменять закладки';

  @override
  String get addons_permissionBrowserSettings =>
      'Читать и изменять настройки браузера';

  @override
  String get addons_permissionBrowsingData =>
      'Удалять недавнюю историю, куки и связанные данные';

  @override
  String get addons_permissionClipboardRead =>
      'Получать данные, которые вы копируете и вставляете';

  @override
  String get addons_permissionClipboardWrite =>
      'Помещать данные в буфер обмена';

  @override
  String get addons_permissionContextualIdentities =>
      'Получать доступ к вкладкам в контейнерах и изменять их';

  @override
  String get addons_permissionCookies =>
      'Получать доступ к куки посещённых сайтов';

  @override
  String get addons_permissionDownloads =>
      'Загружать файлы, а также читать и изменять историю загрузок';

  @override
  String get addons_permissionDownloadsOpen =>
      'Открывать файлы, загруженные на устройство';

  @override
  String get addons_permissionFind => 'Читать текст всех открытых вкладок';

  @override
  String get addons_permissionGeolocation =>
      'Получать доступ к вашему местоположению';

  @override
  String get addons_permissionHistory => 'Получать доступ к истории просмотра';

  @override
  String get addons_permissionManagement =>
      'Отслеживать использование расширений и управлять темами';

  @override
  String get addons_permissionNativeMessaging =>
      'Обмениваться сообщениями с программами помимо браузера';

  @override
  String get addons_permissionNotifications => 'Показывать уведомления';

  @override
  String get addons_permissionPkcs11 =>
      'Предоставлять службы криптографической аутентификации';

  @override
  String get addons_permissionPrivacy =>
      'Читать и изменять настройки приватности';

  @override
  String get addons_permissionProxy => 'Управлять настройками прокси браузера';

  @override
  String get addons_permissionSessions =>
      'Получать доступ к недавно закрытым вкладкам';

  @override
  String get addons_permissionTabs => 'Получать доступ к вкладкам браузера';

  @override
  String get addons_permissionTabHide =>
      'Скрывать и показывать вкладки браузера';

  @override
  String get addons_permissionTopSites => 'Получать доступ к истории просмотра';

  @override
  String get addons_permissionWebNavigation =>
      'Получать доступ к активности браузера во время навигации';

  @override
  String get addons_permissionAllUrls =>
      'Получать доступ к вашим данным на всех сайтах';

  @override
  String addons_permissionAccessDataFor(String host) {
    return 'Получать доступ к вашим данным для $host';
  }

  @override
  String appLinks_bannerTitleNamed(String appName) {
    return 'Открыть эту ссылку в $appName?';
  }

  @override
  String get appLinks_bannerTitleGeneric => 'Открыть эту ссылку в приложении?';

  @override
  String appLinks_bannerRememberFor(String scope) {
    return 'Запомнить для $scope';
  }

  @override
  String get appLinks_bannerStayInBrowser => 'Остаться в браузере';

  @override
  String get appLinks_bannerOpenApp => 'Открыть приложение';

  @override
  String appLinks_dialogTitleNamed(String appName) {
    return 'Открыть в $appName?';
  }

  @override
  String get appLinks_dialogTitleGeneric => 'Открыть в другом приложении?';

  @override
  String get appLinks_dialogBody =>
      'Эту ссылку обрабатывает приложение вне WebLibre.';

  @override
  String appLinks_dialogRememberFor(String scope) {
    return 'Запомнить мой выбор для $scope';
  }

  @override
  String get appLinks_warningProtectedContext =>
      'Здесь эта ссылка защищена. Приложение установит собственное соединение, не соблюдая правила этой вкладки.';

  @override
  String get appLinks_warningPrivateTab =>
      'Это приватная вкладка. Приложение ведёт собственную историю и сохраняет вход в аккаунт.';

  @override
  String get appLinks_warningWallet =>
      'Эта ссылка запрашивает учётные данные у приложения-кошелька. Открывайте её, только если запрос отправили вы.';

  @override
  String appLinks_settingsTitleWithContainer(String containerName) {
    return 'Ссылки на приложения — $containerName';
  }

  @override
  String get appLinks_settingsTitleDefault =>
      'Ссылки на приложения для контейнера';

  @override
  String get appLinks_settingsIntro =>
      'Эти настройки действуют только для этого контейнера и полностью заменяют глобальные настройки ссылок на приложения для его вкладок.';

  @override
  String get appLinks_modeAlwaysTitle => 'Всегда';

  @override
  String get appLinks_modeAlwaysSubtitle =>
      'Всегда открывать ссылки в их приложениях без вопроса';

  @override
  String get appLinks_modeAskTitle => 'Спрашивать перед открытием';

  @override
  String get appLinks_modeAskSubtitle =>
      'Показывать запрос перед открытием ссылок в приложениях';

  @override
  String get appLinks_modeNeverTitle => 'Никогда';

  @override
  String get appLinks_modeNeverSubtitle =>
      'Всегда открывать ссылки в браузере, а не в приложениях';

  @override
  String get appLinks_rememberedRulesHeader => 'Запомненные правила для сайтов';

  @override
  String get appLinks_ruleAlwaysOpenSubtitle => 'Всегда открывать в приложении';

  @override
  String get appLinks_ruleAlwaysKeepSubtitle => 'Всегда оставлять в браузере';

  @override
  String get appLinks_removeRuleTooltip => 'Удалить правило';

  @override
  String get bangs_menuTitle => 'Бэнги';

  @override
  String get bangs_menuManageUserBangs => 'Управление своими бэнгами';

  @override
  String get bangs_menuSearchBangs => 'Поиск бэнгов';

  @override
  String get bangs_menuBrowseCategories => 'Просмотр категорий';

  @override
  String get bangs_categoriesTitle => 'Категории бэнгов';

  @override
  String get bangs_loadCategoriesFailedTitle =>
      'Не удалось загрузить категории бэнгов';

  @override
  String get bangs_loadBangsFailedTitle => 'Не удалось загрузить бэнги';

  @override
  String get bangs_searchHint => 'Поиск';

  @override
  String get bangs_searchFailedTitle => 'Ошибка поиска бэнгов';

  @override
  String get bangs_userBangsTitle => 'Мои бэнги';

  @override
  String get bangs_deleteBangTitle => 'Удалить бэнг';

  @override
  String get bangs_deleteBangConfirm => 'Удалить этот бэнг?';

  @override
  String get bangs_editTitleCustomize => 'Настроить бэнг';

  @override
  String get bangs_editTitleNew => 'Новый бэнг';

  @override
  String get bangs_editTitleEdit => 'Изменить бэнг';

  @override
  String bangs_triggerAlreadyExists(String trigger) {
    return 'Бэнг с триггером «$trigger» уже существует';
  }

  @override
  String get bangs_fieldNameLabel => 'Название';

  @override
  String get bangs_fieldNameHelper => 'Название сайта, связанного с бэнгом';

  @override
  String get bangs_fieldTriggerLabel => 'Триггер';

  @override
  String get bangs_fieldTriggerHelper => 'Слово или фраза, вызывающие бэнг.';

  @override
  String get bangs_fieldAdditionalTriggersLabel => 'Дополнительные триггеры';

  @override
  String get bangs_fieldAdditionalTriggersHelper =>
      'Другие слова, вызывающие этот бэнг, через запятую или пробел. Начальный ! необязателен.';

  @override
  String get bangs_fieldUrlLabel => 'URL-адрес';

  @override
  String bangs_fieldUrlHelper(String token) {
    return 'Шаблон URL-адреса, используемый при вызове бэнга; `$token` заменяется запросом пользователя.';
  }

  @override
  String bangs_fieldUrlMissingPlaceholder(String token) {
    return 'Должен содержать заполнитель запроса $token';
  }

  @override
  String get bangs_fieldCategoryLabel => 'Категория';

  @override
  String get bangs_fieldSubCategoryLabel => 'Подкатегория';

  @override
  String get bangs_flagsLabel => 'Флаги';

  @override
  String get bangs_flagOpenBasePathTitle => 'Открывать базовый путь';

  @override
  String get bangs_flagOpenBasePathSubtitle =>
      'Если бэнг вызван без запроса, открывается базовый путь URL-адреса (/) вместо пути из шаблона (например, /search)';

  @override
  String get bangs_flagUrlEncodePlaceholderTitle =>
      'URL-кодирование заполнителя';

  @override
  String get bangs_flagUrlEncodePlaceholderSubtitle =>
      'Кодировать поисковые запросы для URL-адреса. Некоторые сайты не работают с закодированными запросами — для них отключите этот параметр.';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusTitle =>
      'Кодировать пробел как плюс';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle =>
      'Кодировать пробелы как + вместо %20. Некоторым сайтам нужен определённый формат.';

  @override
  String get bangs_tooltipOfficialSearch => 'Официальный поиск WebLibre';

  @override
  String get bangs_tooltipCustomizeAsOwn => 'Настроить как собственный бэнг';

  @override
  String get bangs_tooltipUnpin => 'Открепить от поисковых систем';

  @override
  String get bangs_tooltipPin => 'Закрепить среди поисковых систем';

  @override
  String bangs_tooltipTriggers(String triggers) {
    return 'Триггеры: $triggers';
  }

  @override
  String get browserActions_categoryNavigation => 'Навигация';

  @override
  String get browserActions_categoryScrolling => 'Прокрутка';

  @override
  String get browserActions_categoryTabs => 'Вкладки';

  @override
  String get browserActions_categoryPage => 'Страница';

  @override
  String get browserActions_categoryOpen => 'Открыть';

  @override
  String get browserActions_categoryApp => 'Приложение';

  @override
  String get browserActions_focusAddressBarTitle => 'Адресная строка';

  @override
  String get browserActions_focusAddressBarDescription =>
      'Изменить адрес или начать поиск';

  @override
  String get browserActions_backTitle => 'Назад';

  @override
  String get browserActions_backDescription => 'Вернуться назад по истории';

  @override
  String get browserActions_forwardTitle => 'Вперёд';

  @override
  String get browserActions_forwardDescription => 'Перейти вперёд по истории';

  @override
  String get browserActions_reloadTitle => 'Перезагрузить';

  @override
  String get browserActions_reloadDescription =>
      'Перезагрузить текущую страницу';

  @override
  String get browserActions_hardReloadTitle => 'Полная перезагрузка';

  @override
  String get browserActions_hardReloadDescription =>
      'Перезагрузить текущую страницу в обход кеша';

  @override
  String get browserActions_scrollTopTitle => 'В начало';

  @override
  String get browserActions_scrollTopDescription => 'Перейти в начало страницы';

  @override
  String get browserActions_scrollBottomTitle => 'В конец';

  @override
  String get browserActions_scrollBottomDescription =>
      'Перейти в конец страницы';

  @override
  String get browserActions_pageUpTitle => 'Страница вверх';

  @override
  String get browserActions_pageUpDescription =>
      'Прокрутить вверх на один экран';

  @override
  String get browserActions_pageDownTitle => 'Страница вниз';

  @override
  String get browserActions_pageDownDescription =>
      'Прокрутить вниз на один экран';

  @override
  String get browserActions_newTabTitle => 'Новая вкладка';

  @override
  String get browserActions_newTabDescription => 'Открыть новую вкладку';

  @override
  String get browserActions_newPrivateTabTitle => 'Новая приватная вкладка';

  @override
  String get browserActions_newPrivateTabDescription =>
      'Открыть новую приватную вкладку';

  @override
  String get browserActions_closeTabTitle => 'Закрыть вкладку';

  @override
  String get browserActions_closeTabDescription => 'Закрыть текущую вкладку';

  @override
  String get browserActions_reopenClosedTabTitle => 'Вернуть закрытую вкладку';

  @override
  String get browserActions_reopenClosedTabDescription =>
      'Снова открыть последнюю закрытую вкладку';

  @override
  String get browserActions_duplicateTabTitle => 'Дублировать вкладку';

  @override
  String get browserActions_duplicateTabDescription =>
      'Открыть копию текущей вкладки';

  @override
  String get browserActions_nextTabTitle => 'Следующая вкладка';

  @override
  String get browserActions_nextTabDescription =>
      'Перейти на следующую вкладку';

  @override
  String get browserActions_previousTabTitle => 'Предыдущая вкладка';

  @override
  String get browserActions_previousTabDescription =>
      'Перейти на предыдущую вкладку';

  @override
  String get browserActions_lastUsedTabTitle =>
      'Последняя использованная вкладка';

  @override
  String get browserActions_lastUsedTabDescription =>
      'Перейти на вкладку, использованную перед текущей';

  @override
  String get browserActions_selectTab1Title => 'Вкладка 1';

  @override
  String get browserActions_selectTab1Description =>
      'Перейти на первую вкладку панели вкладок';

  @override
  String get browserActions_selectTab2Title => 'Вкладка 2';

  @override
  String get browserActions_selectTab2Description =>
      'Перейти на вторую вкладку панели вкладок';

  @override
  String get browserActions_selectTab3Title => 'Вкладка 3';

  @override
  String get browserActions_selectTab3Description =>
      'Перейти на третью вкладку панели вкладок';

  @override
  String get browserActions_selectTab4Title => 'Вкладка 4';

  @override
  String get browserActions_selectTab4Description =>
      'Перейти на четвёртую вкладку панели вкладок';

  @override
  String get browserActions_selectTab5Title => 'Вкладка 5';

  @override
  String get browserActions_selectTab5Description =>
      'Перейти на пятую вкладку панели вкладок';

  @override
  String get browserActions_selectTab6Title => 'Вкладка 6';

  @override
  String get browserActions_selectTab6Description =>
      'Перейти на шестую вкладку панели вкладок';

  @override
  String get browserActions_selectTab7Title => 'Вкладка 7';

  @override
  String get browserActions_selectTab7Description =>
      'Перейти на седьмую вкладку панели вкладок';

  @override
  String get browserActions_selectTab8Title => 'Вкладка 8';

  @override
  String get browserActions_selectTab8Description =>
      'Перейти на восьмую вкладку панели вкладок';

  @override
  String get browserActions_selectLastTabTitle => 'Последняя вкладка';

  @override
  String get browserActions_selectLastTabDescription =>
      'Перейти на последнюю вкладку панели вкладок';

  @override
  String get browserActions_togglePinTabTitle =>
      'Закрепить / открепить вкладку';

  @override
  String get browserActions_togglePinTabDescription =>
      'Переключить закрепление текущей вкладки';

  @override
  String get browserActions_moveTabBackwardTitle => 'Переместить вкладку назад';

  @override
  String get browserActions_moveTabBackwardDescription =>
      'Переместить текущую вкладку на одну позицию к началу панели вкладок';

  @override
  String get browserActions_moveTabForwardTitle => 'Переместить вкладку вперёд';

  @override
  String get browserActions_moveTabForwardDescription =>
      'Переместить текущую вкладку на одну позицию к концу панели вкладок';

  @override
  String get browserActions_moveTabToStartTitle =>
      'Переместить вкладку в начало';

  @override
  String get browserActions_moveTabToStartDescription =>
      'Переместить текущую вкладку в начало её группы на панели вкладок';

  @override
  String get browserActions_moveTabToEndTitle => 'Переместить вкладку в конец';

  @override
  String get browserActions_moveTabToEndDescription =>
      'Переместить текущую вкладку в конец её группы на панели вкладок';

  @override
  String get browserActions_nextContainerTitle => 'Следующий контейнер';

  @override
  String get browserActions_nextContainerDescription =>
      'Перейти к последней использованной вкладке следующего контейнера';

  @override
  String get browserActions_previousContainerTitle => 'Предыдущий контейнер';

  @override
  String get browserActions_previousContainerDescription =>
      'Перейти к последней использованной вкладке предыдущего контейнера';

  @override
  String get browserActions_toggleReaderModeTitle => 'Режим чтения';

  @override
  String get browserActions_toggleReaderModeDescription =>
      'Переключить режим чтения для текущей страницы';

  @override
  String get browserActions_toggleDesktopModeTitle => 'Версия для ПК';

  @override
  String get browserActions_toggleDesktopModeDescription =>
      'Переключить версию для ПК для текущей страницы';

  @override
  String get browserActions_findInPageTitle => 'Найти на странице';

  @override
  String get browserActions_findInPageDescription =>
      'Открыть поиск на странице';

  @override
  String get browserActions_findNextTitle => 'Найти далее';

  @override
  String get browserActions_findNextDescription =>
      'Перейти к следующему совпадению последнего поиска';

  @override
  String get browserActions_findPreviousTitle => 'Найти ранее';

  @override
  String get browserActions_findPreviousDescription =>
      'Перейти к предыдущему совпадению последнего поиска';

  @override
  String get browserActions_increaseFontSizeTitle => 'Увеличить шрифт';

  @override
  String get browserActions_increaseFontSizeDescription =>
      'Увеличить размер шрифта страницы';

  @override
  String get browserActions_decreaseFontSizeTitle => 'Уменьшить шрифт';

  @override
  String get browserActions_decreaseFontSizeDescription =>
      'Уменьшить размер шрифта страницы';

  @override
  String get browserActions_resetFontSizeTitle => 'Сбросить шрифт';

  @override
  String get browserActions_resetFontSizeDescription =>
      'Вернуть стандартный размер шрифта страницы';

  @override
  String get browserActions_toggleBookmarkTitle => 'Закладка';

  @override
  String get browserActions_toggleBookmarkDescription =>
      'Добавить текущую страницу в закладки или удалить из них';

  @override
  String get browserActions_sharePageTitle => 'Поделиться';

  @override
  String get browserActions_sharePageDescription =>
      'Поделиться текущей страницей';

  @override
  String get browserActions_translatePageTitle => 'Перевести';

  @override
  String get browserActions_translatePageDescription =>
      'Открыть панель перевода страницы';

  @override
  String get browserActions_printPageTitle => 'Печать';

  @override
  String get browserActions_printPageDescription =>
      'Напечатать текущую страницу';

  @override
  String get browserActions_showHomeTitle => 'Домой';

  @override
  String get browserActions_showHomeDescription => 'Открыть домашнюю страницу';

  @override
  String get browserActions_showHistoryTitle => 'История';

  @override
  String get browserActions_showHistoryDescription =>
      'Открыть историю просмотра';

  @override
  String get browserActions_showBookmarksTitle => 'Закладки';

  @override
  String get browserActions_showBookmarksDescription => 'Открыть закладки';

  @override
  String get browserActions_showContainersTitle => 'Контейнеры';

  @override
  String get browserActions_showContainersDescription =>
      'Открыть список контейнеров';

  @override
  String get browserActions_showTabViewTitle => 'Обзор вкладок';

  @override
  String get browserActions_showTabViewDescription => 'Открыть обзор вкладок';

  @override
  String get browserActions_showDownloadsTitle => 'Загрузки';

  @override
  String get browserActions_showDownloadsDescription => 'Открыть загрузки';

  @override
  String get browserActions_showAddonsTitle => 'Дополнения';

  @override
  String get browserActions_showAddonsDescription => 'Управление расширениями';

  @override
  String get browserActions_openSettingsTitle => 'Настройки';

  @override
  String get browserActions_openSettingsDescription => 'Открыть настройки';

  @override
  String get browserActions_showKeyboardShortcutsTitle => 'Сочетания клавиш';

  @override
  String get browserActions_showKeyboardShortcutsDescription =>
      'Список клавиш, запускающих действия браузера';

  @override
  String get browserActions_toggleTabBarTitle =>
      'Скрыть / показать панель вкладок';

  @override
  String get browserActions_toggleTabBarDescription =>
      'Скрыть панель вкладок или вернуть её';

  @override
  String get browserActions_clearBrowsingDataTitle =>
      'Очистить данные просмотра';

  @override
  String get browserActions_clearBrowsingDataDescription =>
      'Выбрать данные просмотра для удаления';

  @override
  String get browserActions_moveToBackgroundTitle => 'Свернуть';

  @override
  String get browserActions_moveToBackgroundDescription =>
      'Отправить WebLibre в фон';

  @override
  String get browserActions_quitBrowserTitle => 'Выйти';

  @override
  String get browserActions_quitBrowserDescription =>
      'Закрыть все вкладки и выйти из WebLibre';

  @override
  String get browserActions_categoryCreate => 'Создать';

  @override
  String get browserActions_openInPrivateTabTitle =>
      'Открыть в приватной вкладке';

  @override
  String get browserActions_openInPrivateTabDescription =>
      'Открыть текущую страницу в новой приватной вкладке';

  @override
  String get browserActions_moveTabToContainerTitle =>
      'Переместить в контейнер';

  @override
  String get browserActions_moveTabToContainerDescription =>
      'Переместить текущую вкладку в другой контейнер';

  @override
  String get browserActions_copyLinkTitle => 'Копировать ссылку';

  @override
  String get browserActions_copyLinkDescription =>
      'Скопировать адрес текущей страницы';

  @override
  String get browserActions_siteSettingsTitle => 'Настройки сайта';

  @override
  String get browserActions_siteSettingsDescription =>
      'Разрешения и защита от отслеживания для этого сайта';

  @override
  String get browserActions_addToHomeScreenTitle => 'Добавить на главный экран';

  @override
  String get browserActions_addToHomeScreenDescription =>
      'Установить текущий сайт как приложение или ярлык';

  @override
  String get browserActions_subscribeToPageFeedTitle =>
      'Подписаться на страницу';

  @override
  String get browserActions_subscribeToPageFeedDescription =>
      'Найти ленты текущей страницы и подписаться на них';

  @override
  String get browserActions_showFeedsTitle => 'Ленты';

  @override
  String get browserActions_showFeedsDescription => 'Открыть ваши ленты';

  @override
  String get browserActions_showProfilesTitle => 'Профили';

  @override
  String get browserActions_showProfilesDescription => 'Управление профилями';

  @override
  String get browserActions_showProxySettingsTitle => 'Прокси';

  @override
  String get browserActions_showProxySettingsDescription =>
      'Открыть настройки прокси';

  @override
  String get browserActions_showTorTitle => 'Tor';

  @override
  String get browserActions_showTorDescription => 'Открыть настройки Tor';

  @override
  String get browserActions_showSyncSettingsTitle => 'Синхронизация';

  @override
  String get browserActions_showSyncSettingsDescription =>
      'Открыть настройки синхронизации';

  @override
  String get browserActions_showContentBlockerListsTitle => 'Списки фильтров';

  @override
  String get browserActions_showContentBlockerListsDescription =>
      'Управление списками фильтров блокировщика контента';

  @override
  String get browserActions_showErrorLogsTitle => 'Журналы ошибок';

  @override
  String get browserActions_showErrorLogsDescription =>
      'Просмотреть журналы ошибок приложения';

  @override
  String get browserActions_showAboutTitle => 'О программе';

  @override
  String get browserActions_showAboutDescription => 'О WebLibre';

  @override
  String get browserActions_newContainerTitle => 'Новый контейнер';

  @override
  String get browserActions_newContainerDescription => 'Создать контейнер';

  @override
  String get browserActions_newBookmarkFolderTitle => 'Новая папка закладок';

  @override
  String get browserActions_newBookmarkFolderDescription =>
      'Создать папку закладок';

  @override
  String get browserActions_addFeedTitle => 'Добавить ленту';

  @override
  String get browserActions_addFeedDescription =>
      'Подписаться на ленту по её адресу';

  @override
  String get browserActions_newSearchEngineTitle => 'Новый поисковый ярлык';

  @override
  String get browserActions_newSearchEngineDescription =>
      'Создать собственный бэнг';

  @override
  String get browserActions_newProfileTitle => 'Новый профиль';

  @override
  String get browserActions_newProfileDescription => 'Создать профиль браузера';

  @override
  String get browserActions_newProxyProfileTitle => 'Новый профиль прокси';

  @override
  String get browserActions_newProxyProfileDescription =>
      'Добавить прокси-сервер';

  @override
  String get browserActions_backupProfileTitle => 'Резервная копия профиля';

  @override
  String get browserActions_backupProfileDescription =>
      'Создать резервную копию текущего профиля';

  @override
  String get browserActions_toggleBookmarkKeywords =>
      'избранное, сохранить страницу, звёздочка, закладка';

  @override
  String get browserActions_findInPageKeywords =>
      'поиск на странице, найти текст, искать текст';

  @override
  String get browserActions_copyLinkKeywords =>
      'копировать url, копировать адрес, буфер обмена';

  @override
  String get browserActions_sharePageKeywords =>
      'отправить, поделиться ссылкой, переслать';

  @override
  String get browserActions_toggleReaderModeKeywords =>
      'режим чтения, чтение, статья, упростить страницу';

  @override
  String get browserActions_toggleDesktopModeKeywords =>
      'полная версия, версия для компьютера, мобильная версия, user agent';

  @override
  String get browserActions_translatePageKeywords =>
      'перевод, язык, переводчик';

  @override
  String get browserActions_siteSettingsKeywords =>
      'разрешения, куки, защита от отслеживания, камера, микрофон, местоположение, сведения о сайте';

  @override
  String get browserActions_addToHomeScreenKeywords =>
      'pwa, установить, веб-приложение, ярлык, лаунчер, приложение';

  @override
  String get browserActions_subscribeToPageFeedKeywords =>
      'rss, atom, лента, подписаться, следить, новости';

  @override
  String get browserActions_printPageKeywords =>
      'pdf, сохранить как pdf, принтер, печать';

  @override
  String get browserActions_increaseFontSizeKeywords =>
      'увеличить масштаб, крупнее текст, больше шрифт, размер текста';

  @override
  String get browserActions_decreaseFontSizeKeywords =>
      'уменьшить масштаб, мельче текст, меньше шрифт, размер текста';

  @override
  String get browserActions_resetFontSizeKeywords =>
      'стандартный размер текста, сбросить масштаб, размер текста';

  @override
  String get browserActions_openInPrivateTabKeywords =>
      'инкогнито, приватный просмотр, приватный режим';

  @override
  String get browserActions_moveTabToContainerKeywords =>
      'назначить контейнер, личность, группа вкладок';

  @override
  String get browserActions_duplicateTabKeywords =>
      'клонировать вкладку, копировать вкладку';

  @override
  String get browserActions_togglePinTabKeywords =>
      'закрепить вкладку, открепить, прикрепить';

  @override
  String get browserActions_closeTabKeywords => 'закрыть, убрать вкладку';

  @override
  String get browserActions_reopenClosedTabKeywords =>
      'отменить закрытие, восстановить вкладку, недавно закрытые';

  @override
  String get browserActions_showHistoryKeywords =>
      'посещённые страницы, история просмотра, недавно посещённые, журнал';

  @override
  String get browserActions_showBookmarksKeywords =>
      'избранное, сохранённые страницы, менеджер закладок';

  @override
  String get browserActions_showDownloadsKeywords =>
      'загруженные файлы, файлы, менеджер загрузок, скачивания';

  @override
  String get browserActions_showTabViewKeywords =>
      'обзор вкладок, все вкладки, переключатель вкладок, открытые вкладки';

  @override
  String get browserActions_showContainersKeywords =>
      'личности, список контейнеров, рабочие пространства';

  @override
  String get browserActions_showFeedsKeywords => 'rss, atom, новости, подписки';

  @override
  String get browserActions_showProfilesKeywords =>
      'пользователи, аккаунты, сменить профиль';

  @override
  String get browserActions_showProxySettingsKeywords =>
      'vpn, впн, sing-box, socks, подключение, сеть';

  @override
  String get browserActions_showTorKeywords =>
      'onion, луковая, анонимный, мосты, анонимность';

  @override
  String get browserActions_showSyncSettingsKeywords =>
      'аккаунт, синхронизировать, устройства';

  @override
  String get browserActions_showAddonsKeywords =>
      'расширения, плагины, дополнения, webextensions';

  @override
  String get browserActions_showContentBlockerListsKeywords =>
      'ublock, adblock, блокировщик рекламы, фильтры, списки блокировки';

  @override
  String get browserActions_openSettingsKeywords =>
      'параметры, опции, конфигурация, настройки';

  @override
  String get browserActions_showKeyboardShortcutsKeywords =>
      'горячие клавиши, привязки клавиш, клавиши';

  @override
  String get browserActions_showErrorLogsKeywords =>
      'журналы, логи, отладка, сбой, отчёт об ошибке';

  @override
  String get browserActions_showAboutKeywords => 'версия, лицензия, информация';

  @override
  String get browserActions_newContainerKeywords =>
      'добавить контейнер, создать личность, рабочее пространство';

  @override
  String get browserActions_newBookmarkFolderKeywords =>
      'добавить папку, создать папку, упорядочить закладки';

  @override
  String get browserActions_addFeedKeywords =>
      'rss, atom, подписаться, добавить подписку';

  @override
  String get browserActions_newSearchEngineKeywords =>
      'бэнг, bang, свой поиск, добавить поисковую систему, поисковый ярлык';

  @override
  String get browserActions_newProfileKeywords =>
      'добавить пользователя, создать профиль, новый аккаунт';

  @override
  String get browserActions_newProxyProfileKeywords =>
      'добавить прокси, vpn, впн, сервер, sing-box, socks';

  @override
  String get browserActions_backupProfileKeywords =>
      'резервная копия, бэкап, экспорт, сохранить данные, архив';

  @override
  String get browserActions_clearBrowsingDataKeywords =>
      'удалить историю, очистить кеш, куки, стереть, очистить, приватность';

  @override
  String get bookmarks_title => 'Закладки';

  @override
  String get bookmarks_filterHint => 'Фильтр закладок…';

  @override
  String get bookmarks_emptyFolder => 'Пусто';

  @override
  String get bookmarks_searchHiddenByFoldersOnly =>
      'Найденные закладки скрыты режимом «Только папки»';

  @override
  String bookmarks_noSearchMatches(String query) {
    return 'Нет закладок, соответствующих «$query»';
  }

  @override
  String get bookmarks_loadFailedTitle => 'Не удалось загрузить закладки';

  @override
  String get bookmarks_loadFoldersFailedTitle =>
      'Не удалось загрузить папки закладок';

  @override
  String get bookmarks_folderLabel => 'Папка';

  @override
  String get bookmarks_unnamedFolder => 'Папка без названия';

  @override
  String bookmarks_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count',
      many: 'Выбрано $count',
      few: 'Выбрано $count',
      one: 'Выбран $count',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_tooltipOpenInBackground => 'Открыть в фоне';

  @override
  String get bookmarks_tooltipMoveSelected => 'Переместить выбранное';

  @override
  String get bookmarks_tooltipDeleteSelected => 'Удалить выбранное';

  @override
  String get bookmarks_tooltipClearSearch => 'Очистить поиск';

  @override
  String get bookmarks_tooltipSearchBookmarks => 'Поиск закладок';

  @override
  String get bookmarks_tooltipCollapse => 'Свернуть';

  @override
  String get bookmarks_tooltipExpand => 'Развернуть';

  @override
  String get bookmarks_menuAddBookmarkHere => 'Добавить закладку сюда';

  @override
  String get bookmarks_menuAddSubfolderHere => 'Добавить подпапку сюда';

  @override
  String get bookmarks_menuCollapseAll => 'Свернуть все';

  @override
  String get bookmarks_menuShowEmptyFolders => 'Показывать пустые папки';

  @override
  String get bookmarks_menuHideEmptyFolders => 'Скрывать пустые папки';

  @override
  String get bookmarks_menuShowBookmarks => 'Показывать закладки';

  @override
  String get bookmarks_menuFoldersOnly => 'Только папки';

  @override
  String get bookmarks_menuVisibility => 'Отображение';

  @override
  String get bookmarks_menuSort => 'Сортировка';

  @override
  String get bookmarks_menuImport => 'Импорт';

  @override
  String get bookmarks_menuExport => 'Экспорт';

  @override
  String get bookmarks_formatJson => 'JSON';

  @override
  String get bookmarks_formatHtml => 'HTML';

  @override
  String get bookmarks_actionOpenInNewTab => 'Открыть в новой вкладке';

  @override
  String get bookmarks_actionOpenInBackground => 'Открыть в фоне';

  @override
  String get bookmarks_actionShare => 'Поделиться';

  @override
  String get bookmarks_actionMove => 'Переместить';

  @override
  String get bookmarks_actionFlatten => 'Расформировать';

  @override
  String get bookmarks_actionAddSubfolder => 'Добавить подпапку';

  @override
  String get bookmarks_actionAddBookmark => 'Добавить закладку';

  @override
  String get bookmarks_actionMerge => 'Объединить';

  @override
  String get bookmarks_actionReplace => 'Заменить';

  @override
  String get bookmarks_noEntriesSelected => 'Не выбрано ни одной закладки';

  @override
  String bookmarks_openedTabsInBackground(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыто $count вкладки в фоне',
      many: 'Открыто $count вкладок в фоне',
      few: 'Открыто $count вкладки в фоне',
      one: 'Открыта $count вкладка в фоне',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_movedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Перемещено $count элемента',
      many: 'Перемещено $count элементов',
      few: 'Перемещено $count элемента',
      one: 'Перемещён $count элемент',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_deletedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count элемента',
      many: 'Удалено $count элементов',
      few: 'Удалено $count элемента',
      one: 'Удалён $count элемент',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importFailedToReadFile => 'Не удалось прочитать файл';

  @override
  String bookmarks_importSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count закладки',
      many: 'Импортировано $count закладок',
      few: 'Импортировано $count закладки',
      one: 'Импортирована $count закладка',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_importFailedWithError(String error) {
    return 'Ошибка импорта: $error';
  }

  @override
  String get bookmarks_exportDialogTitle => 'Экспорт закладок';

  @override
  String get bookmarks_exportSuccess => 'Закладки экспортированы';

  @override
  String bookmarks_exportFailedWithError(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get bookmarks_sortDefault => 'По умолчанию';

  @override
  String get bookmarks_sortTitleAsc => 'Название А–Я';

  @override
  String get bookmarks_sortTitleDesc => 'Название Я–А';

  @override
  String get bookmarks_sortUrlAsc => 'URL-адрес А–Я';

  @override
  String get bookmarks_sortUrlDesc => 'URL-адрес Я–А';

  @override
  String get bookmarks_sortDateAddedDesc => 'Сначала новые';

  @override
  String get bookmarks_sortDateAddedAsc => 'Сначала старые';

  @override
  String get bookmarks_deleteBookmarkTitle => 'Удалить закладку';

  @override
  String get bookmarks_deleteBookmarkContent => 'Удалить эту закладку?';

  @override
  String get bookmarks_deleteFolderTitle => 'Удалить папку';

  @override
  String get bookmarks_deleteFolderConfirmUnknown =>
      'Удалить эту папку вместе со всеми её закладками?';

  @override
  String bookmarks_deleteFolderConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить эту папку и $count закладки в ней?',
      many: 'Удалить эту папку и $count закладок в ней?',
      few: 'Удалить эту папку и $count закладки в ней?',
      one: 'Удалить эту папку и $count закладку в ней?',
      zero: 'Удалить эту папку?',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importDialogTitle => 'Импорт закладок';

  @override
  String get bookmarks_importDialogContent =>
      'Удалить все существующие закладки перед импортом?\n\nВыберите «Заменить», чтобы удалить существующие закладки, или «Объединить», чтобы сохранить их.';

  @override
  String get bookmarks_importProgressTitle => 'Импорт закладок';

  @override
  String get bookmarks_importPhaseParsing => 'Чтение файла…';

  @override
  String get bookmarks_importPhaseErasing => 'Удаление существующих закладок…';

  @override
  String bookmarks_importPhaseInsertingProgress(int inserted, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$inserted из $total закладки',
      many: '$inserted из $total закладок',
      few: '$inserted из $total закладок',
      one: '$inserted из $total закладки',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importPhaseInsertingIndeterminate =>
      'Сохранение закладок…';

  @override
  String get bookmarks_moveToFolderTitle => 'Переместить в папку';

  @override
  String get bookmarks_editBookmarkTitle => 'Изменить закладку';

  @override
  String get bookmarks_createBookmarkTitle => 'Создать закладку';

  @override
  String get bookmarks_editFolderTitle => 'Изменить папку';

  @override
  String get bookmarks_createFolderTitle => 'Создать папку';

  @override
  String get bookmarks_fieldNameLabel => 'Название';

  @override
  String get bookmarks_fieldUrlLabel => 'URL-адрес';

  @override
  String get bookmarks_addToTop => 'Добавить в начало';

  @override
  String get browser_actionSelect => 'Выбрать';

  @override
  String get browser_actionKeep => 'Оставить';

  @override
  String get browser_actionInstall => 'Установить';

  @override
  String get browser_bookmarkAllTitle => 'Добавить все вкладки в закладки';

  @override
  String get browser_bookmarkAllFastTitle => 'Быстро';

  @override
  String get browser_bookmarkAllFastSubtitle =>
      'Автоматически добавить все вкладки в выбранную папку';

  @override
  String get browser_bookmarkAllDetailedTitle => 'Подробно';

  @override
  String get browser_bookmarkAllDetailedSubtitle =>
      'Просмотреть и изменить каждую закладку по отдельности';

  @override
  String get browser_clearSiteDataTitle => 'Очистить данные сайта';

  @override
  String browser_clearSiteDataContent(String formattedTypes, String host) {
    return 'Для $host будут удалены следующие данные:\n$formattedTypes\n\nВозможно, придётся войти снова.';
  }

  @override
  String get browser_contentSelectionExtractedTitle => 'Извлечённое содержимое';

  @override
  String get browser_contentSelectionExtractedSubtitle =>
      'Содержимое, оптимизированное для чтения, без навигации и рекламы';

  @override
  String get browser_contentSelectionFullTitle => 'Полное содержимое';

  @override
  String get browser_contentSelectionFullSubtitle =>
      'Вся страница со всеми элементами и структурой';

  @override
  String get browser_deleteDataTitle => 'Удаление данных просмотра';

  @override
  String get browser_installAddonSheetTitle => 'Установка расширения из файла';

  @override
  String get browser_installAddonSelectFileButton => 'Выбрать файл XPI';

  @override
  String get browser_installAddonNoFileSelected => 'Файл не выбран';

  @override
  String get browser_installAddonPinnedNotice =>
      'Расширения, установленные из локального XPI, остаются на этой версии и не обновляются автоматически.';

  @override
  String get browser_installAddonNotXpiError => 'Выберите файл .xpi';

  @override
  String browser_installAddonPickFileFailed(String error) {
    return 'Не удалось выбрать файл: $error';
  }

  @override
  String get browser_installAddonInstalledMessage =>
      'Расширение установлено. Для этой локальной версии автоматические обновления отключены.';

  @override
  String get browser_installAddonNotSignedError =>
      'Это расширение не подписано Mozilla. Чтобы установить его, включите «Разрешить неподписанные расширения» в настройках расширений.';

  @override
  String browser_installAddonInstallFailed(String error) {
    return 'Ошибка установки: $error';
  }

  @override
  String get browser_keepTabTitle => 'Оставить вкладку?';

  @override
  String get browser_keepTabContent => 'Оставить эту вкладку или закрыть её?';

  @override
  String get browser_qrCodeTitle => 'QR-код для отправки';

  @override
  String get browser_selectFolderTitle => 'Выбор папки';

  @override
  String get browser_tabTreeCurrentTabNotInTree =>
      'Текущая вкладка не входит в это дерево';

  @override
  String get browser_menuManageExtensions => 'Управление расширениями';

  @override
  String get browser_menuAddRegularTab => 'Добавить обычную вкладку';

  @override
  String get browser_menuAddChildTab => 'Добавить дочернюю вкладку';

  @override
  String get browser_menuAddPrivateTab => 'Добавить приватную вкладку';

  @override
  String get browser_menuAddIsolatedTab => 'Добавить изолированную вкладку';

  @override
  String get browser_fontSizeTitle => 'Размер текста';

  @override
  String get browser_fontSizeAutomaticNotice =>
      'Включён автоматический размер шрифта. Отключите его в настройках, чтобы менять размер вручную.';

  @override
  String get browser_fontSizeResetButton => 'Сбросить до 100 %';

  @override
  String get browser_historyNoPreviousPages => 'Нет предыдущих страниц';

  @override
  String get browser_historyNoForwardPages => 'Нет следующих страниц';

  @override
  String get browser_certSandboxedCaptureTitle => 'Снимок из песочницы';

  @override
  String get browser_certSandboxedCaptureSubtitle =>
      'Страница загружена из офлайн-архива — без живого соединения.';

  @override
  String get browser_certConnectionNotSecure => 'Соединение не защищено';

  @override
  String get browser_certConnectionSecure => 'Соединение защищено';

  @override
  String browser_certVerifiedBy(String issuer) {
    return 'Проверено: $issuer';
  }

  @override
  String get browser_containerFallbackName => 'Контейнер';

  @override
  String get browser_actionEnable => 'Включить';

  @override
  String get browser_closeAllPrivateTabsTitle =>
      'Закрыть все приватные вкладки';

  @override
  String get browser_closeAllPrivateTabsContent =>
      'Закрыть все показанные приватные вкладки?';

  @override
  String get browser_closeAllTabsTitle => 'Закрыть все вкладки';

  @override
  String get browser_closeAllTabsContent => 'Закрыть все показанные вкладки?';

  @override
  String get browser_enableAiTabSuggestionsTitle =>
      'Включить предложения вкладок с ИИ';

  @override
  String get browser_enableAiTabSuggestionsContent =>
      'Для этой функции может понадобиться загрузить модели ИИ. Размер загрузки и её ход нельзя определить заранее.\n\nПродолжить?';

  @override
  String get browser_tooltipExpandGroup => 'Развернуть группу';

  @override
  String get browser_tooltipCollapseGroup => 'Свернуть группу';

  @override
  String browser_tabGroupSizeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Группа из $count вкладки',
      many: 'Группа из $count вкладок',
      few: 'Группа из $count вкладок',
      one: 'Группа из $count вкладки',
    );
    return '$_temp0';
  }

  @override
  String get browser_searchOrEnterUrl => 'Введите запрос или URL-адрес';

  @override
  String get browser_tabCannotBeMovedHere => 'Вкладку нельзя переместить сюда';

  @override
  String get browser_quickActionNewTab => 'Новая вкладка';

  @override
  String get browser_quickActionNewPrivateTab => 'Новая приватная вкладка';

  @override
  String get browser_quickActionNewIsolatedTab => 'Новая изолированная вкладка';

  @override
  String get browser_shareLink => 'Поделиться ссылкой';

  @override
  String get browser_showQrCode => 'Показать QR-код';

  @override
  String get browser_exportAsPdf => 'Экспорт в PDF';

  @override
  String get browser_failedToPrintPage => 'Не удалось напечатать страницу';

  @override
  String get browser_print => 'Печать';

  @override
  String get browser_shareScreenshot => 'Поделиться снимком экрана';

  @override
  String get browser_exportAsPng => 'Экспорт в PNG';

  @override
  String browser_openInNamedApp(String appName) {
    return 'Открыть в $appName';
  }

  @override
  String get browser_openInApp => 'Открыть в приложении';

  @override
  String get browser_copyAddress => 'Копировать адрес';

  @override
  String get browser_noTargetDevices => 'Нет устройств для отправки';

  @override
  String browser_sentTabToDevice(String deviceName) {
    return 'Вкладка отправлена на $deviceName';
  }

  @override
  String get browser_failedToSendTab => 'Не удалось отправить вкладку';

  @override
  String get browser_loadingDevices => 'Загрузка устройств…';

  @override
  String get browser_failedToLoadDevices => 'Не удалось загрузить устройства';

  @override
  String get browser_sendToDevice => 'Отправить на устройство';

  @override
  String get browser_containerMenuNewTab => 'Новая вкладка';

  @override
  String get browser_unpinContainer => 'Открепить контейнер';

  @override
  String get browser_pinContainer => 'Закрепить контейнер';

  @override
  String get browser_closeSubmenuAllTabs => 'Все вкладки';

  @override
  String get browser_closeSubmenuPrivateTabs => 'Приватные вкладки';

  @override
  String get browser_closeSubmenuIsolatedTabs => 'Изолированные вкладки';

  @override
  String get browser_closeSubmenuFilteredTabs => 'Отфильтрованные вкладки';

  @override
  String get browser_menuCloseTabs => 'Закрыть вкладки';

  @override
  String get browser_menuBookmarkAll => 'Добавить все в закладки';

  @override
  String get browser_menuAssignedSites => 'Привязанные сайты…';

  @override
  String get browser_menuClearContainerData => 'Очистить данные контейнера';

  @override
  String get browser_menuEditContainer => 'Изменить контейнер…';

  @override
  String get browser_menuDeleteContainer => 'Удалить контейнер';

  @override
  String browser_bookmarksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count закладки',
      many: 'Добавлено $count закладок',
      few: 'Добавлено $count закладки',
      one: 'Добавлена $count закладка',
    );
    return '$_temp0';
  }

  @override
  String get browser_containerDataClearedSuccess => 'Данные контейнера очищены';

  @override
  String browser_containerDataClearedWithTabsClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Данные контейнера очищены. Закрыто $count вкладки.',
      many: 'Данные контейнера очищены. Закрыто $count вкладок.',
      few: 'Данные контейнера очищены. Закрыто $count вкладки.',
      one: 'Данные контейнера очищены. Закрыта $count вкладка.',
    );
    return '$_temp0';
  }

  @override
  String browser_errorClearingData(String error) {
    return 'Ошибка очистки данных: $error';
  }

  @override
  String get browser_appLinksSectionTitle => 'Ссылки на приложения';

  @override
  String get browser_openLinksForThisSite => 'Открытие ссылок этого сайта';

  @override
  String get browser_followsTheDefault => 'Как по умолчанию';

  @override
  String get browser_followDefault => 'Как по умолчанию';

  @override
  String get browser_openInAppOption => 'Открывать в приложении';

  @override
  String get browser_keepInBrowser => 'Оставлять в браузере';

  @override
  String get browser_noAppFoundForSite =>
      'Для этого сайта не найдено приложение';

  @override
  String browser_alwaysOpensInApp(String appName) {
    return 'Всегда открывается в $appName';
  }

  @override
  String get browser_theAppFallback => 'приложении';

  @override
  String get browser_alwaysStaysInBrowser => 'Всегда остаётся в браузере';

  @override
  String get browser_followsDefaultOpensInApps =>
      'Как по умолчанию: открывается в приложениях';

  @override
  String get browser_followsDefaultNoAppFound =>
      'Как по умолчанию: приложение не найдено';

  @override
  String get browser_followsDefaultAsksFirst =>
      'Как по умолчанию: сначала спрашивать';

  @override
  String get browser_followsDefaultStaysInBrowser =>
      'Как по умолчанию: остаётся в браузере';

  @override
  String get browser_selectDataTypesToClear =>
      'Выберите типы данных для очистки';

  @override
  String get browser_cookiesCacheAndSiteData => 'Куки, кеш и данные сайтов';

  @override
  String get browser_dataTypeAuthSessions => 'Сеансы входа';

  @override
  String get browser_dataTypeAuthSessionsSubtitle =>
      'Сохранённые логины, активные сеансы';

  @override
  String get browser_dataTypeSiteData => 'Данные сайта';

  @override
  String get browser_dataTypeSiteDataSubtitle =>
      'Офлайн-хранилище, базы данных, локальные файлы';

  @override
  String get browser_dataTypeCookies => 'Куки';

  @override
  String get browser_dataTypeCookiesSubtitle =>
      'Токены входа, настройки, данные отслеживания';

  @override
  String get browser_dataTypeCachedFiles => 'Кешированные файлы';

  @override
  String get browser_dataTypeCachedFilesSubtitle =>
      'Изображения, скрипты, таблицы стилей';

  @override
  String get browser_closeTabAfterClearing => 'Закрыть вкладку после очистки';

  @override
  String get browser_closeTabAfterClearingSubtitle =>
      'Закрыть эту вкладку, когда данные будут очищены';

  @override
  String get browser_clearingEllipsis => 'Очистка…';

  @override
  String get browser_clearNow => 'Очистить';

  @override
  String get browser_selectAtLeastOneDataType =>
      'Выберите хотя бы один тип данных';

  @override
  String get browser_siteDataCleared => 'Данные сайта очищены';

  @override
  String browser_failedToClearSiteData(String error) {
    return 'Не удалось очистить данные сайта: $error';
  }

  @override
  String get browser_alwaysUseDesktopSite => 'Всегда версия для ПК';

  @override
  String get browser_unavailableOnThisPage => 'Недоступно на этой странице';

  @override
  String browser_setByRuleFor(String host) {
    return 'Задано правилом для $host';
  }

  @override
  String get browser_siteAlwaysLoadsInDesktopMode =>
      'Этот сайт всегда загружается в версии для ПК';

  @override
  String get browser_siteFollowsDefaultMode =>
      'Этот сайт использует режим по умолчанию';

  @override
  String browser_failedToToggleDesktopMode(String error) {
    return 'Не удалось переключить версию для ПК: $error';
  }

  @override
  String get browser_gesturesTitle => 'Жесты';

  @override
  String get browser_gesturesTurnedOffGlobally => 'Жесты отключены глобально';

  @override
  String get browser_gesturesUnavailableOnThisPage =>
      'Жесты недоступны на этой странице';

  @override
  String browser_gesturesDisabledByRuleFor(String host) {
    return 'Отключено правилом для $host';
  }

  @override
  String get browser_gesturesDisabledOnThisSite =>
      'Жесты отключены на этом сайте';

  @override
  String get browser_gesturesEnabledOnThisSite =>
      'Жесты включены на этом сайте';

  @override
  String browser_failedToToggleGestures(String error) {
    return 'Не удалось переключить жесты: $error';
  }

  @override
  String browser_errorLoadingPermissions(String error) {
    return 'Ошибка загрузки разрешений: $error';
  }

  @override
  String get browser_permissionsSectionTitle => 'Разрешения';

  @override
  String get browser_showAll => 'Показать все';

  @override
  String get browser_noPermissionsSetForSite =>
      'Для этого сайта разрешения не заданы';

  @override
  String get browser_permissionAsk => 'Спрашивать';

  @override
  String get browser_permissionAllow => 'Разрешить';

  @override
  String get browser_permissionBlock => 'Блокировать';

  @override
  String get browser_autoplayTitle => 'Автовоспроизведение';

  @override
  String get browser_autoplayAllowAll => 'Разрешить всё';

  @override
  String get browser_autoplayBlockAudible => 'Блокировать со звуком';

  @override
  String get browser_autoplayBlockAll => 'Блокировать всё';

  @override
  String get browser_failedToLoadTrackingProtection =>
      'Не удалось загрузить защиту от отслеживания';

  @override
  String get browser_enhancedTrackingProtection =>
      'Улучшенная защита от отслеживания';

  @override
  String get browser_trackersBeingBlocked =>
      'Трекеры на этом сайте блокируются';

  @override
  String get browser_trackersAllowed => 'Трекеры на этом сайте разрешены';

  @override
  String browser_failedToToggleTrackingProtection(String error) {
    return 'Не удалось переключить защиту от отслеживания: $error';
  }

  @override
  String get browser_resizeSidePanel => 'Изменить размер боковой панели';

  @override
  String get browser_unassignedContainerLabel => 'Без контейнера';

  @override
  String get browser_tooltipCloseTab => 'Закрыть вкладку';

  @override
  String get browser_urlCleaned => 'URL-адрес очищен';

  @override
  String get browser_urlPreviewApplied => 'Предпросмотр URL-адреса применён';

  @override
  String browser_trackingParametersDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Обнаружено $count параметра отслеживания',
      many: 'Обнаружено $count параметров отслеживания',
      few: 'Обнаружено $count параметра отслеживания',
      one: 'Обнаружен $count параметр отслеживания',
    );
    return '$_temp0';
  }

  @override
  String get browser_linkIsClean => 'Ссылка чистая';

  @override
  String get browser_removeTrackingTooltip => 'Удалить отслеживание';

  @override
  String get browser_menuFindInPage => 'Найти на странице';

  @override
  String get browser_menuReaderMode => 'Режим чтения';

  @override
  String get browser_menuFetchFeedsOnPage => 'Найти ленты на странице';

  @override
  String get browser_menuAddBookmark => 'Добавить закладку';

  @override
  String get browser_cloneRegular => 'Обычная';

  @override
  String get browser_clonePrivate => 'Приватная';

  @override
  String get browser_cloneIsolated => 'Изолированная';

  @override
  String get browser_menuCloneTab => 'Клонировать вкладку';

  @override
  String get browser_menuAssignContainer => 'Назначить контейнер';

  @override
  String get browser_menuUrlRelation => 'Привязать URL-адрес';

  @override
  String get browser_menuUnassignUrlRelation => 'Отвязать URL-адрес';

  @override
  String get browser_menuUnassignContainer => 'Убрать из контейнера';

  @override
  String get browser_menuContainerSubmenu => 'Контейнер';

  @override
  String get browser_menuMoveUp => 'Переместить вверх';

  @override
  String get browser_menuMoveDown => 'Переместить вниз';

  @override
  String get browser_menuReorder => 'Порядок';

  @override
  String get browser_menuShare => 'Поделиться';

  @override
  String get browser_menuCopyAsMarkdown => 'Копировать как Markdown';

  @override
  String get browser_markdownCopiedToClipboard =>
      'Markdown скопирован в буфер обмена';

  @override
  String get browser_menuExportAsMarkdown => 'Экспорт в Markdown';

  @override
  String get browser_menuExportSubmenu => 'Экспорт';

  @override
  String get browser_menuCloseTab => 'Закрыть вкладку';

  @override
  String get browser_menuReload => 'Перезагрузить';

  @override
  String get browser_menuDesktopMode => 'Версия для ПК';

  @override
  String get browser_menuAddToHomeScreen => 'Добавить на главный экран';

  @override
  String get browser_menuChangeParent => 'Сменить родительскую…';

  @override
  String get browser_menuDetachFromParent => 'Отделить от родительской';

  @override
  String get browser_menuHierarchy => 'Иерархия';

  @override
  String get browser_pageTranslated => 'Переведено';

  @override
  String get browser_menuTranslatePage => 'Перевести страницу';

  @override
  String get browser_unpinTab => 'Открепить вкладку';

  @override
  String get browser_pinTab => 'Закрепить вкладку';

  @override
  String browser_errorGeneric(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get browser_tabNoLongerExists => 'Вкладка больше не существует';

  @override
  String get browser_chooseAParentTab => 'Выберите родительскую вкладку';

  @override
  String get browser_makeStandalone => 'Сделать самостоятельной';

  @override
  String get browser_detachFromCurrentParent =>
      'Отделить от текущей родительской вкладки';

  @override
  String get browser_noCandidateTabsInContainer =>
      'В этом контейнере нет подходящих вкладок.';

  @override
  String get browser_clearContainerDataIntro =>
      'Будут удалены все данные этого контейнера:';

  @override
  String get browser_bulletCookies => '• Куки';

  @override
  String get browser_bulletSiteData => '• Данные сайтов';

  @override
  String get browser_bulletCache => '• Кеш';

  @override
  String get browser_bulletPermissions => '• Разрешения';

  @override
  String browser_tabsWillBeClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будут закрыты $count вкладки.',
      many: 'Будут закрыты $count вкладок.',
      few: 'Будут закрыты $count вкладки.',
      one: 'Будет закрыта $count вкладка.',
    );
    return '$_temp0';
  }

  @override
  String get browser_recreateTabsAfterClearing =>
      'Пересоздать вкладки после очистки';

  @override
  String get browser_actionClearData => 'Очистить данные';

  @override
  String get browser_closeFromSameHost => 'Закрыть с того же сайта';

  @override
  String get browser_closeTabAndDescendants => 'Закрыть вкладку и дочерние';

  @override
  String get browser_tabUnpinned => 'Вкладка откреплена';

  @override
  String browser_createdContainerNamed(String containerName) {
    return 'Создан контейнер «$containerName»';
  }

  @override
  String get browser_newContainerFallback => 'Новый контейнер';

  @override
  String get browser_assignedParentTab => 'Родительская вкладка назначена';

  @override
  String get browser_couldNotAssignParentTab =>
      'Не удалось назначить родительскую вкладку';

  @override
  String get browser_dropTabOntoTabTitle => 'Вкладка перетащена на вкладку';

  @override
  String get browser_chooseHowTabsRelated =>
      'Выберите, как связать эти вкладки.';

  @override
  String get browser_createContainerOption => 'Создать контейнер';

  @override
  String get browser_createContainerOptionSubtitle =>
      'Создать новый контейнер с обеими вкладками.';

  @override
  String get browser_assignNewParentOption => 'Назначить родительскую';

  @override
  String get browser_assignNewParentOptionSubtitle =>
      'Сделать вкладку, на которую перетащили, родительской.';

  @override
  String get browser_tabReorderingOnlyInDefaultMode =>
      'Изменять порядок вкладок можно только в ручном режиме по умолчанию';

  @override
  String get browser_tooltipSearchInsideTabs => 'Поиск внутри вкладок';

  @override
  String get browser_filterTabType => 'Тип вкладок';

  @override
  String get browser_sortPinnedFirst => 'Сначала закреплённые';

  @override
  String get browser_filterSort => 'Сортировка';

  @override
  String get browser_hierarchicalView => 'Иерархический вид';

  @override
  String get browser_filterDate => 'Фильтр по дате';

  @override
  String get browser_quickInterval => 'Быстрый интервал';

  @override
  String get browser_resetFilter => 'Сбросить фильтр';

  @override
  String get browser_tooltipFilterAndSort => 'Фильтр и сортировка';

  @override
  String get browser_tooltipChangeViewMode => 'Сменить вид';

  @override
  String browser_downloadingAiModelsProgress(int percent) {
    return 'Загрузка моделей ИИ ($percent %)';
  }

  @override
  String get browser_disableAiTabSuggestions =>
      'Отключить предложения вкладок с ИИ';

  @override
  String get browser_enableAiTabSuggestionsTooltip =>
      'Включить предложения вкладок с ИИ';

  @override
  String get browser_disableReorderingMode => 'Выключить режим упорядочивания';

  @override
  String get browser_enableReorderingMode => 'Включить режим упорядочивания';

  @override
  String get browser_reorderingRequiresDefaultManualMode =>
      'Для упорядочивания нужен ручной режим по умолчанию';

  @override
  String get browser_dragAndDropTabsToReorder =>
      'Перетаскивайте вкладки, чтобы изменить порядок';

  @override
  String get browser_tooltipTabActions => 'Действия с вкладками';

  @override
  String get browser_hintSearchTabs => 'Поиск вкладок';

  @override
  String get browser_noSyncedTabsAvailable => 'Нет синхронизированных вкладок';

  @override
  String browser_failedToLoadSyncedTabs(String error) {
    return 'Не удалось загрузить синхронизированные вкладки: $error';
  }

  @override
  String get browser_translateFromLabel => 'С';

  @override
  String get browser_translateToLabel => 'На';

  @override
  String browser_translationError(String error) {
    return 'Ошибка перевода: $error';
  }

  @override
  String get browser_failedToRestorePage => 'Не удалось восстановить страницу';

  @override
  String get browser_showOriginal => 'Показать оригинал';

  @override
  String get browser_failedToTranslatePage => 'Не удалось перевести страницу';

  @override
  String get browser_retranslate => 'Перевести заново';

  @override
  String get browser_translateAction => 'Перевести';

  @override
  String get browser_tabTypeFilterAll => 'Все вкладки';

  @override
  String get browser_tabTypeFilterRegular => 'Обычные';

  @override
  String get browser_tabTypeFilterPrivate => 'Приватные';

  @override
  String get browser_tabTypeFilterIsolated => 'Изолированные';

  @override
  String get browser_tabSortDefault => 'По умолчанию';

  @override
  String get browser_tabSortTitleAsc => 'Название А–Я';

  @override
  String get browser_tabSortTitleDesc => 'Название Я–А';

  @override
  String get browser_tabSortUrlAsc => 'URL-адрес А–Я';

  @override
  String get browser_tabSortUrlDesc => 'URL-адрес Я–А';

  @override
  String get browser_tabSortNewestFirst => 'Сначала новые';

  @override
  String get browser_tabSortOldestFirst => 'Сначала старые';

  @override
  String get browser_tabIntervalLastHour => 'Последний час';

  @override
  String get browser_tabIntervalLast3Hours => 'Последние 3 часа';

  @override
  String get browser_tabIntervalLast8Hours => 'Последние 8 часов';

  @override
  String get browser_tabIntervalLastDay => 'Последние сутки';

  @override
  String get browser_tabIntervalLast3Days => 'Последние 3 дня';

  @override
  String get browser_tabIntervalLastWeek => 'Последняя неделя';

  @override
  String get browser_tabIntervalLastMonth => 'Последний месяц';

  @override
  String get browser_tabsViewModeList => 'Список';

  @override
  String get browser_tabsViewModeGrid => 'Сетка';

  @override
  String get browser_tabsViewModeTree => 'Дерево';

  @override
  String get browser_permissionCamera => 'Камера';

  @override
  String get browser_permissionMicrophone => 'Микрофон';

  @override
  String get browser_permissionLocation => 'Местоположение';

  @override
  String get browser_permissionNotification => 'Уведомления';

  @override
  String get browser_permissionPersistentStorage => 'Постоянное хранилище';

  @override
  String get browser_permissionCrossOriginStorage => 'Межсайтовое хранилище';

  @override
  String get browser_permissionMediaKeySystem => 'Система ключей медиа (DRM)';

  @override
  String get browser_tabReorderBlockedMessage =>
      'Сбросьте фильтр или поиск в обзоре вкладок, чтобы изменить порядок';

  @override
  String get contextualToolbar_tooltipHome => 'Домой';

  @override
  String get contextualToolbar_tooltipHideTabBar => 'Скрыть панель вкладок';

  @override
  String get contextualToolbar_tooltipClearBrowsingData =>
      'Очистить данные просмотра';

  @override
  String get contextualToolbar_tooltipAddBookmark => 'Добавить закладку';

  @override
  String get contextualToolbar_tooltipRemoveBookmark => 'Удалить закладку';

  @override
  String get contextualToolbar_tooltipEnableGestures => 'Включить жесты';

  @override
  String get contextualToolbar_tooltipDisableGestures => 'Отключить жесты';

  @override
  String get contextualToolbar_actionHardRefresh => 'Полная перезагрузка';

  @override
  String get contextualToolbar_actionCloseOthers => 'Закрыть остальные';

  @override
  String get contextualToolbar_actionCloseFromSameHost =>
      'Закрыть с того же сайта';

  @override
  String get contextualToolbar_actionCloseTabAndDescendants =>
      'Закрыть вкладку и дочерние';

  @override
  String get contextualToolbar_actionAddBookmark => 'Добавить закладку';

  @override
  String get contextualToolbar_actionRemoveBookmark => 'Удалить закладку';

  @override
  String get contextualToolbar_actionCloneAsRegular =>
      'Клонировать как обычную';

  @override
  String get contextualToolbar_actionCloneAsPrivate =>
      'Клонировать как приватную';

  @override
  String get contextualToolbar_actionCloneAsIsolated =>
      'Клонировать как изолированную';

  @override
  String get contextualToolbar_bookmarkAdded => 'Закладка добавлена';

  @override
  String get contextualToolbar_bookmarkRemoved => 'Закладка удалена';

  @override
  String get contextualToolbar_fontSizeAutoAdjustmentHint =>
      'Отключите автоматический размер шрифта в настройках, чтобы менять его вручную';

  @override
  String get contextualToolbar_buttonLabelBack => 'Назад';

  @override
  String get contextualToolbar_buttonLabelForward => 'Вперёд';

  @override
  String get contextualToolbar_buttonLabelHome => 'Домой';

  @override
  String get contextualToolbar_buttonLabelHistory => 'История';

  @override
  String get contextualToolbar_buttonLabelBookmarks => 'Закладки';

  @override
  String get contextualToolbar_buttonLabelBookmarkToggle => 'Закладка';

  @override
  String get contextualToolbar_buttonLabelShare => 'Поделиться';

  @override
  String get contextualToolbar_buttonLabelAddTab => 'Новая вкладка';

  @override
  String get contextualToolbar_buttonLabelTabsCount => 'Вкладки';

  @override
  String get contextualToolbar_buttonLabelNavigationMenu => 'Меню';

  @override
  String get contextualToolbar_buttonLabelReload => 'Перезагрузить';

  @override
  String get contextualToolbar_buttonLabelReaderMode => 'Режим чтения';

  @override
  String get contextualToolbar_buttonLabelDesktop => 'Версия для ПК';

  @override
  String get contextualToolbar_buttonLabelTranslation => 'Перевести';

  @override
  String get contextualToolbar_buttonLabelFindInPage => 'Найти на странице';

  @override
  String get contextualToolbar_buttonLabelCloseTab => 'Закрыть вкладку';

  @override
  String get contextualToolbar_buttonLabelInputUrl => 'Адресная строка';

  @override
  String get contextualToolbar_buttonLabelQrScan => 'Сканировать QR-код';

  @override
  String get contextualToolbar_buttonLabelVoiceSearch => 'Голосовой поиск';

  @override
  String get contextualToolbar_buttonLabelDuplicateTab => 'Дублировать вкладку';

  @override
  String get contextualToolbar_buttonLabelIncreaseFont => 'Увеличить шрифт';

  @override
  String get contextualToolbar_buttonLabelDecreaseFont => 'Уменьшить шрифт';

  @override
  String get contextualToolbar_buttonLabelMoveToBackground => 'В фон';

  @override
  String get contextualToolbar_buttonLabelToggleGestures => 'Жесты';

  @override
  String get contextualToolbar_buttonLabelHideTabBar => 'Скрыть панель вкладок';

  @override
  String get contextualToolbar_buttonLabelPageUp => 'Страница вверх';

  @override
  String get contextualToolbar_buttonLabelPageDown => 'Страница вниз';

  @override
  String get contextualToolbar_buttonLabelFont => 'Размер текста';

  @override
  String get contextualToolbar_buttonLabelExtensionShortcut => 'Расширения';

  @override
  String get contextualToolbar_buttonLabelClearBrowsingData =>
      'Очистить данные';

  @override
  String get contextualToolbar_buttonLabelQuit => 'Выйти';

  @override
  String get contextualToolbar_longPressBackHistoryMenu =>
      'Меню истории (предыдущие страницы)';

  @override
  String get contextualToolbar_longPressForwardHistoryMenu =>
      'Меню истории (следующие страницы)';

  @override
  String get contextualToolbar_longPressOpenBookmarks => 'Открыть закладки';

  @override
  String get contextualToolbar_longPressAddRegularTab =>
      'Добавить обычную вкладку';

  @override
  String get contextualToolbar_longPressAddChildTab =>
      'Добавить дочернюю вкладку';

  @override
  String get contextualToolbar_longPressAddPrivateTab =>
      'Добавить приватную вкладку';

  @override
  String get contextualToolbar_longPressAddIsolatedTab =>
      'Добавить изолированную вкладку';

  @override
  String get contextualToolbar_longPressOpenSettings => 'Открыть настройки';

  @override
  String get contextualToolbar_longPressHardRefresh =>
      'Полная перезагрузка (без кеша)';

  @override
  String get contextualToolbar_longPressShowTranslationOptions =>
      'Показать параметры перевода';

  @override
  String get contextualToolbar_longPressScrollToTop => 'Прокрутить в начало';

  @override
  String get contextualToolbar_longPressScrollToBottom => 'Прокрутить в конец';

  @override
  String get contextualToolbar_longPressExtensionsMenu => 'Меню расширений';

  @override
  String get contextualToolbar_longPressQuitWithoutConfirmation =>
      'Выйти без подтверждения';

  @override
  String get menu_sectionQuickToggles => 'Быстрые переключатели';

  @override
  String get menu_sectionPageActions => 'Действия со страницей';

  @override
  String get menu_sectionExtensions => 'Расширения';

  @override
  String get menu_sectionTabActions => 'Действия с вкладкой';

  @override
  String get menu_sectionQuickLinks => 'Быстрые ссылки';

  @override
  String get menu_sectionConnection => 'Подключение';

  @override
  String get menu_sectionProfile => 'Профиль и приложение';

  @override
  String get menu_sectionAbout => 'О программе';

  @override
  String get menu_itemDesktopMode => 'Для ПК';

  @override
  String get menu_itemReaderMode => 'Чтение';

  @override
  String get menu_itemGestures => 'Жесты';

  @override
  String get menu_itemAddBookmark => 'Добавить закладку';

  @override
  String get menu_itemFindInPage => 'Найти на странице';

  @override
  String get menu_itemTranslatePage => 'Перевести страницу';

  @override
  String get menu_itemAddToHomeScreen => 'Добавить на главный экран';

  @override
  String get menu_itemOpenInApp => 'Открыть в приложении';

  @override
  String get menu_itemContainers => 'Контейнеры';

  @override
  String get menu_itemManageContainers => 'Управление контейнерами';

  @override
  String get menu_itemAssignContainer => 'Назначить контейнер';

  @override
  String get menu_itemAssignUrlToContainer =>
      'Привязать URL-адрес к контейнеру';

  @override
  String get menu_itemUnassignUrlFromContainer =>
      'Отвязать URL-адрес от контейнера';

  @override
  String get menu_itemUnassignContainer => 'Убрать из контейнера';

  @override
  String get menu_itemShare => 'Поделиться';

  @override
  String get menu_itemCopyAddress => 'Копировать адрес';

  @override
  String get menu_itemShareScreenshot => 'Поделиться снимком экрана';

  @override
  String get menu_itemShareLink => 'Поделиться ссылкой';

  @override
  String get menu_itemSendToDevice => 'Отправить на устройство';

  @override
  String get menu_itemShowQrCode => 'Показать QR-код';

  @override
  String get menu_itemMoreDisclosure => 'Ещё';

  @override
  String get menu_itemCloneTab => 'Клонировать вкладку';

  @override
  String get menu_itemCloneRegularTab => 'Обычная';

  @override
  String get menu_itemClonePrivateTab => 'Приватная';

  @override
  String get menu_itemCloneIsolatedTab => 'Изолированная';

  @override
  String get menu_itemExport => 'Экспорт';

  @override
  String get menu_itemCopyAsMarkdown => 'Копировать как Markdown';

  @override
  String get menu_itemExportAsMarkdown => 'Экспорт в Markdown';

  @override
  String get menu_itemExportAsPdf => 'Экспорт в PDF';

  @override
  String get menu_itemExportAsPng => 'Экспорт в PNG';

  @override
  String get menu_itemPrintPage => 'Печать';

  @override
  String get menu_itemPinTopSite => 'Закрепить в ярлыках';

  @override
  String get menu_itemFetchFeeds => 'Найти ленты';

  @override
  String get menu_itemHistory => 'История';

  @override
  String get menu_itemBookmarks => 'Закладки';

  @override
  String get menu_itemDownloads => 'Загрузки';

  @override
  String get menu_itemBangs => 'Бэнги';

  @override
  String get menu_itemFeeds => 'Ленты';

  @override
  String get menu_itemSmallWeb => 'Малый веб';

  @override
  String get menu_itemClearData => 'Очистка';

  @override
  String get menu_itemProfileSwitch => 'Профиль';

  @override
  String get menu_itemSyncNow => 'Синхронизировать';

  @override
  String get menu_itemAppSettings => 'Настройки';

  @override
  String get menu_itemQuitBrowser => 'Выйти из браузера';

  @override
  String get menu_itemAbout => 'О программе';

  @override
  String get menu_itemMoreDisclosureDescription =>
      'Сворачивает всё, что ниже, под строку «Ещё»';

  @override
  String get menu_itemSendToDeviceDescription =>
      'Список устройств берётся из вашего аккаунта';

  @override
  String get menu_reorderHideTooltip => 'Скрыть';

  @override
  String get menu_reorderShowTooltip => 'Показать';

  @override
  String menu_reorderRowsShown(int shown, int total) {
    return 'Показано строк: $shown из $total';
  }

  @override
  String get menu_reorderDefaultTitle => 'Настройка меню';

  @override
  String get menu_reorderSubtitleSections =>
      'Перетаскивайте, чтобы изменить порядок. Выключите раздел, чтобы скрыть его из меню.';

  @override
  String get menu_reorderSubtitleSectionRows =>
      'Перетаскивайте, чтобы изменить порядок строк в этом разделе.';

  @override
  String get menu_reorderSubtitleItemRows =>
      'Перетаскивайте, чтобы изменить порядок строк, которые открывает эта строка.';

  @override
  String get menu_reorderBackTooltip => 'Назад к разделам';

  @override
  String get menu_reorderResetToDefaults => 'Сбросить по умолчанию';

  @override
  String get menu_customizeMenuButton => 'Настроить меню';

  @override
  String get menu_navStop => 'Стоп';

  @override
  String get menu_navBack => 'Назад';

  @override
  String get menu_navForward => 'Вперёд';

  @override
  String get menu_navCloseTab => 'Закрыть';

  @override
  String get menu_navReload => 'Обновить';

  @override
  String get menu_navCloseOthers => 'Закрыть остальные';

  @override
  String get menu_navCloseFromSameHost => 'Закрыть с того же сайта';

  @override
  String get menu_navCloseTabAndDescendants => 'Закрыть вкладку и дочерние';

  @override
  String get menu_navHardRefresh => 'Полная перезагрузка';

  @override
  String get menu_profileTapToSwitch => 'Нажмите, чтобы сменить профиль';

  @override
  String get menu_profileSyncComplete => 'Синхронизация завершена';

  @override
  String menu_openInApp(String appName) {
    return 'Открыть в $appName';
  }

  @override
  String get menu_pageTranslated => 'Переведено';

  @override
  String get menu_extensionsTitle => 'Расширения';

  @override
  String get menu_extensionFallbackTitle => 'Расширение';

  @override
  String get menu_extensionsSettingsTooltip => 'Настройки расширения';

  @override
  String get menu_extensionsManage => 'Управление расширениями';

  @override
  String get menu_containersExpansionTitle => 'Контейнеры';

  @override
  String get menu_containersManage => 'Управление контейнерами';

  @override
  String get menu_containersAssign => 'Назначить контейнер';

  @override
  String get menu_containersAssignUrl => 'Привязать URL-адрес к контейнеру';

  @override
  String get menu_containersUnassignUrl => 'Отвязать URL-адрес от контейнера';

  @override
  String get menu_containersUnassign => 'Убрать из контейнера';

  @override
  String get menu_shareExpansionTitle => 'Поделиться';

  @override
  String get menu_shareUrlCleaned => 'URL-адрес очищен';

  @override
  String get menu_shareUrlPreviewApplied => 'Предпросмотр URL-адреса применён';

  @override
  String get menu_shareCopyAddress => 'Копировать адрес';

  @override
  String get menu_shareScreenshot => 'Поделиться снимком экрана';

  @override
  String get menu_shareLink => 'Поделиться ссылкой';

  @override
  String get menu_shareShowQrCode => 'Показать QR-код';

  @override
  String get menu_sendToDeviceExpansionTitle => 'Отправить на устройство';

  @override
  String get menu_sendToDeviceNone => 'Нет устройств для отправки';

  @override
  String get menu_sendToDeviceLoading => 'Загрузка устройств…';

  @override
  String get menu_sendToDeviceLoadFailed => 'Не удалось загрузить устройства';

  @override
  String menu_sendToDeviceSuccess(String deviceName) {
    return 'Вкладка отправлена на $deviceName';
  }

  @override
  String get menu_sendToDeviceSendFailed => 'Не удалось отправить вкладку';

  @override
  String get menu_cloneTabExpansionTitle => 'Клонировать вкладку';

  @override
  String get menu_cloneTypeRegular => 'Обычная';

  @override
  String get menu_cloneTypePrivate => 'Приватная';

  @override
  String get menu_cloneTypeIsolated => 'Изолированная';

  @override
  String get menu_exportExpansionTitle => 'Экспорт';

  @override
  String get menu_exportCopyAsMarkdown => 'Копировать как Markdown';

  @override
  String get menu_exportAsMarkdown => 'Экспорт в Markdown';

  @override
  String get menu_exportAsPdf => 'Экспорт в PDF';

  @override
  String get menu_exportAsPng => 'Экспорт в PNG';

  @override
  String get menu_exportMarkdownCopied => 'Markdown скопирован в буфер обмена';

  @override
  String get menu_exportPrint => 'Печать';

  @override
  String get menu_exportPrintFailed => 'Не удалось напечатать страницу';

  @override
  String get menu_pinUnpinFromShortcuts => 'Открепить из ярлыков';

  @override
  String get menu_pinPinToShortcuts => 'Закрепить в ярлыках';

  @override
  String get menu_pinUnpinnedMessage => 'Откреплено из ярлыков';

  @override
  String get menu_pinPinnedMessage => 'Закреплено в ярлыках';

  @override
  String get menu_pinUpdateFailed => 'Не удалось обновить ярлыки';

  @override
  String get menu_fetchFeedsTitle => 'Найти ленты на странице';

  @override
  String get menu_fetchFeedsNone => 'Веб-ленты не найдены';

  @override
  String get menu_fetchFeedsAvailable => 'Доступные веб-ленты';

  @override
  String get menu_fetchFeedsLoading => 'Поиск веб-лент…';

  @override
  String get menu_connectionTitle => 'Подключение';

  @override
  String get menu_connectionRegularTabs => 'Обычные вкладки';

  @override
  String get menu_connectionPrivateTabs => 'Приватные вкладки';

  @override
  String menu_connectionAllThrough(String proxyTitle) {
    return 'Все через $proxyTitle';
  }

  @override
  String get menu_connectionPerContainer => 'По контейнерам';

  @override
  String get menu_connectionPerContainerSubtitle =>
      'Маршрутизируются только контейнеры с назначенным прокси';

  @override
  String get menu_connectionDirect => 'Напрямую';

  @override
  String get menu_connectionPrivateNeverInheritSubtitle =>
      'Приватные вкладки никогда не наследуют глобальный маршрут';

  @override
  String get menu_connectionThisIsolatedTab => 'Эта изолированная вкладка';

  @override
  String get menu_connectionFollowsContainer => 'Как у контейнера';

  @override
  String get menu_connectionFollowContainerOption => 'Как у контейнера';

  @override
  String get menu_connectionFollowContainerOptionSubtitle =>
      'Использовать маршрут, назначенный контейнеру этой вкладки';

  @override
  String get menu_connectionIsolatedDirectSubtitle =>
      'В обход маршрута, который применил бы её контейнер';

  @override
  String get menu_connectionThisContainer => 'Этот контейнер';

  @override
  String get menu_connectionFollowsGlobalRouting => 'Глобальная маршрутизация';

  @override
  String get menu_connectionContainerFallbackTitle => 'Контейнер';

  @override
  String get menu_connectionFollowGlobalRoutingOption =>
      'Глобальная маршрутизация';

  @override
  String get menu_connectionFollowGlobalRoutingOptionSubtitle =>
      'Тот же маршрут, что и у обычных вкладок';

  @override
  String get menu_connectionContainerDirectSubtitle =>
      'В обход глобального прокси для этого контейнера';

  @override
  String menu_connectionFailedToChangeRoute(String error) {
    return 'Не удалось изменить маршрут: $error';
  }

  @override
  String menu_connectionProxyError(String error) {
    return 'Ошибка прокси: $error';
  }

  @override
  String menu_connectionNotRoutedByContainer(String container) {
    return 'Не маршрутизируется контейнером «$container»';
  }

  @override
  String get menu_connectionNotRoutedByTabContainer =>
      'Не маршрутизируется контейнером этой вкладки';

  @override
  String get menu_connectionCheckingRouting => 'Проверка маршрутизации…';

  @override
  String get menu_connectionStartingRouting => 'Запуск маршрутизации…';

  @override
  String menu_connectionBlockedNotRunning(String proxyTitle) {
    return 'Заблокировано — $proxyTitle не запущен';
  }

  @override
  String menu_connectionThisTabVia(String proxyTitle) {
    return 'Эта вкладка: $proxyTitle';
  }

  @override
  String get menu_connectionThisTabDirect => 'Эта вкладка: прямое подключение';

  @override
  String menu_connectionStartProxy(String proxyTitle) {
    return 'Запустить $proxyTitle';
  }

  @override
  String get menu_connectionProxySettings => 'Настройки прокси';

  @override
  String get menu_connectionUnused => 'Не используется ни одним маршрутом';

  @override
  String menu_connectionUsageContainerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count контейнера',
      many: '$count контейнеров',
      few: '$count контейнера',
      one: '$count контейнер',
    );
    return '$_temp0';
  }

  @override
  String menu_connectionUsageIsolatedTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изолированных вкладок',
      many: '$count изолированных вкладок',
      few: '$count изолированные вкладки',
      one: '$count изолированная вкладка',
    );
    return '$_temp0';
  }

  @override
  String get menu_connectionUsageBlocked => 'Заблокировано';

  @override
  String get contextmenu_openInNewTab => 'Открыть в новой вкладке';

  @override
  String get contextmenu_tooltipOpenInDifferentTabType =>
      'Открыть во вкладке другого типа';

  @override
  String get contextmenu_newRegularTab => 'Новая обычная вкладка';

  @override
  String get contextmenu_newPrivateTab => 'Новая приватная вкладка';

  @override
  String get contextmenu_newIsolatedTab => 'Новая изолированная вкладка';

  @override
  String get contextmenu_openImageInNewTab =>
      'Открыть изображение в новой вкладке';

  @override
  String get contextmenu_openInContainer => 'Открыть в контейнере';

  @override
  String get contextmenu_selectContainerTitle => 'Выберите контейнер';

  @override
  String get contextmenu_loadContainersFailedTitle =>
      'Не удалось загрузить контейнеры';

  @override
  String get contextmenu_newContainer => 'Новый контейнер';

  @override
  String get contextmenu_openInApp => 'Открыть в приложении';

  @override
  String contextmenu_openInAppNamed(String appName) {
    return 'Открыть в $appName';
  }

  @override
  String get contextmenu_copyLink => 'Копировать ссылку';

  @override
  String get contextmenu_copyLinkText => 'Копировать текст ссылки';

  @override
  String get contextmenu_copyImage => 'Копировать изображение';

  @override
  String get contextmenu_copyImageLocation => 'Копировать адрес изображения';

  @override
  String get contextmenu_saveFile => 'Сохранить файл';

  @override
  String get contextmenu_saveImage => 'Сохранить изображение';

  @override
  String get contextmenu_shareImage => 'Поделиться изображением';

  @override
  String get contextmenu_shareEmailAddress => 'Поделиться адресом эл. почты';

  @override
  String get contextmenu_urlCleanedMessage => 'URL-адрес очищен';

  @override
  String get contextmenu_urlPreviewAppliedMessage =>
      'Предпросмотр URL-адреса применён';

  @override
  String get findInPage_hint => 'Найти на странице';

  @override
  String findInPage_matchPosition(int current, int total) {
    return '$current из $total';
  }

  @override
  String get findInPage_noMatches => 'Не найдено';

  @override
  String get history_titleHistory => 'История';

  @override
  String get history_titleDownloads => 'Загрузки';

  @override
  String get history_filterHintHistory => 'Фильтр истории…';

  @override
  String get history_filterHintDownloads => 'Фильтр загрузок…';

  @override
  String history_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count',
      many: 'Выбрано $count',
      few: 'Выбрано $count',
      one: 'Выбран $count',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipClearSearch => 'Очистить поиск';

  @override
  String get history_tooltipSearchHistory => 'Поиск в истории';

  @override
  String get history_tooltipSearchDownloads => 'Поиск в загрузках';

  @override
  String history_tooltipClearContainerHistory(String container) {
    return 'Очистить историю контейнера «$container»';
  }

  @override
  String get history_filterDate => 'Дата';

  @override
  String get history_filterContainer => 'Контейнер';

  @override
  String get history_allContainers => 'Все контейнеры';

  @override
  String get history_unnamedContainer => 'Контейнер без названия';

  @override
  String history_containerFilterLabel(String container) {
    return 'Контейнер: $container';
  }

  @override
  String get history_resetFilter => 'Сбросить фильтр';

  @override
  String get history_filterTypeFollowedLinks => 'Переходы по ссылкам';

  @override
  String get history_filterTypeTypedAddresses => 'Введённые адреса';

  @override
  String get history_filterTypeEmbeddedPageElements =>
      'Встроенные элементы страниц';

  @override
  String get history_filterTypePermanentRedirects =>
      'Постоянные перенаправления';

  @override
  String get history_filterTypeTemporaryRedirects =>
      'Временные перенаправления';

  @override
  String get history_filterTypeDownloads => 'Загрузки';

  @override
  String get history_filterTypeFrames => 'Фреймы';

  @override
  String get history_filterTypePageReloads => 'Перезагрузки страниц';

  @override
  String get history_filterTypeBookmarks => 'Закладки';

  @override
  String get history_visitTypeFollowedLink => 'Переход по ссылке';

  @override
  String get history_visitTypeTypedAddress => 'Введённый адрес';

  @override
  String get history_visitTypeEmbeddedPageElement =>
      'Встроенный элемент страницы';

  @override
  String get history_visitTypePermanentRedirect => 'Постоянное перенаправление';

  @override
  String get history_visitTypeTemporaryRedirect => 'Временное перенаправление';

  @override
  String get history_visitTypeDownload => 'Загрузка';

  @override
  String get history_visitTypeFrame => 'Фрейм';

  @override
  String get history_visitTypePageReload => 'Перезагрузка страницы';

  @override
  String get history_visitTypeBookmark => 'Закладка';

  @override
  String get history_clearContainerHistoryTitle =>
      'Очистить историю контейнера';

  @override
  String history_clearContainerHistoryContent(String container) {
    return 'Очистить всю историю контейнера «$container»?';
  }

  @override
  String get history_downloadedFileNotFound => 'Загруженный файл не найден';

  @override
  String get history_couldNotOpenDownloadedFile =>
      'Не удалось открыть загруженный файл';

  @override
  String get history_loadHistoryFailedTitle => 'Не удалось загрузить историю';

  @override
  String get history_loadDownloadsFailedTitle =>
      'Не удалось загрузить список загрузок';

  @override
  String get history_deleteFileTitle => 'Удалить файл';

  @override
  String history_deleteFileConfirm(String fileName) {
    return 'Удалить $fileName?';
  }

  @override
  String get history_deleteFileWarning =>
      'Файл будет безвозвратно удалён с устройства.';

  @override
  String get history_deleteFileRememberChoice =>
      'Запомнить выбор для остальных файлов';

  @override
  String get history_deleteFileActionKeep => 'Оставить';

  @override
  String get history_filterDistinctUrls => 'Уникальные URL-адреса';

  @override
  String history_visitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count посещения',
      many: '$count посещений',
      few: '$count посещения',
      one: '$count посещение',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipDeleteHistory => 'Удалить историю';

  @override
  String get history_deleteMenuTimeRange => 'Удалить за период…';

  @override
  String get history_deleteMenuBrowsingData => 'Удалить данные просмотра…';

  @override
  String get history_deleteTimeRangeTitle => 'Удалить историю за период';

  @override
  String get history_deleteTimeRangeFrom => 'С';

  @override
  String get history_deleteTimeRangeTo => 'По';

  @override
  String get history_deleteTimeRangeLastHour => 'Последний час';

  @override
  String get history_deleteTimeRangeToday => 'Сегодня';

  @override
  String get history_deleteTimeRangeLastWeek => 'Последние 7 дней';

  @override
  String get history_deleteTimeRangeExplanation =>
      'Все посещения за этот период удаляются во всех контейнерах. Завершённые и неудавшиеся загрузки за этот период также исчезнут из списка загрузок, но файлы останутся на устройстве. Загрузки, которые ещё выполняются, сохраняются.';

  @override
  String get history_deleteTimeRangeInvalid =>
      'Начало должно быть раньше конца.';

  @override
  String get history_tooltipEntryActions => 'Другие действия';

  @override
  String get history_actionOpenInBackground => 'Открыть в фоне';

  @override
  String get history_actionCopyLink => 'Копировать ссылку';

  @override
  String get history_actionShareLink => 'Поделиться ссылкой';

  @override
  String get openLinkTools_openLinkTitle => 'Открыть ссылку';

  @override
  String get openLinkTools_urlCleanedMessage => 'URL-адрес очищен';

  @override
  String get openLinkTools_urlPreviewAppliedMessage =>
      'Предпросмотр URL-адреса применён';

  @override
  String get openLinkTools_urlBlockedByClearUrls =>
      'URL-адрес заблокирован ClearURLs';

  @override
  String openLinkTools_unshortenFailedWithError(String error) {
    return 'Не удалось развернуть ссылку: $error';
  }

  @override
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit) {
    return 'Осталось запросов: $remaining/$limit';
  }

  @override
  String get openLinkTools_unshortenTileTitle => 'Развернуть';

  @override
  String get openLinkTools_unshortenTileSubtitle =>
      'Раскрыть сокращённый URL-адрес';

  @override
  String get openLinkTools_unshortenerInfoTooltip => 'О сервисе разворачивания';

  @override
  String openLinkTools_openInAppNamed(String appName) {
    return 'Открыть в $appName';
  }

  @override
  String get openLinkTools_openInAppGeneric => 'Открыть в приложении';

  @override
  String get openLinkTools_openInAppSubtitle =>
      'Открыть в установленном приложении';

  @override
  String get openLinkTools_couldNotOpenInApp =>
      'Не удалось открыть в приложении';

  @override
  String get openLinkTools_openInNewTabTitle => 'Открыть в новой вкладке';

  @override
  String get openLinkTools_openInNewTabSubtitle =>
      'Добавить к вкладкам браузера';

  @override
  String get openLinkTools_openInCustomTabTitle => 'Открыть в Custom Tab';

  @override
  String get openLinkTools_openInCustomTabSubtitle =>
      'Открыть в отдельном окне';

  @override
  String get openLinkTools_unshortenerAttributionTitle =>
      'О сервисе разворачивания ссылок';

  @override
  String openLinkTools_unshortenerAttributionBody(String service) {
    return 'Этот модуль раскрывает сокращённые ссылки, отправляя их в $service. Сервис проверяет каждую ссылку на своих серверах и сохраняет перенаправление для будущих запросов. Не отправляйте ссылки, содержащие личные или конфиденциальные данные.';
  }

  @override
  String get openLinkTools_unshortenerRateLimitNotice =>
      'Бесплатный API ограничен 10 запросами в час для новых проверок.';

  @override
  String openLinkTools_privacyPolicyLabel(String link) {
    return 'Политика конфиденциальности: $link';
  }

  @override
  String get openLinkTools_removeTrackingParametersTitle =>
      'Удаление параметров отслеживания';

  @override
  String get openLinkTools_removeTrackingParametersSubtitle =>
      'Выберите параметры, которые нужно удалить из этого URL-адреса.';

  @override
  String get openLinkTools_referralMarketingBadge => 'Реферальный маркетинг';

  @override
  String openLinkTools_selectedForRemovalCount(int selected, int total) {
    return 'Выбрано для удаления: $selected из $total';
  }

  @override
  String get openLinkTools_cleanedUrlLabel => 'Очищенный URL-адрес:';

  @override
  String get openLinkTools_restoreDefaultsTitle => 'Восстановить по умолчанию?';

  @override
  String get openLinkTools_restoreDefaultsContent =>
      'Настройки очистки URL-адресов будут сброшены, а локально сохранённый каталог удалён.';

  @override
  String get openLinkTools_actionRestore => 'Восстановить';

  @override
  String get openLinkTools_actionApplyChanges => 'Применить изменения';

  @override
  String openLinkTools_couldNotOpenLink(String url) {
    return 'Не удалось открыть ссылку: $url';
  }

  @override
  String get openLinkTools_tileTitleCleaned => 'URL-адрес очищен';

  @override
  String openLinkTools_tileSubtitleRemovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count параметра отслеживания',
      many: 'Удалено $count параметров отслеживания',
      few: 'Удалено $count параметра отслеживания',
      one: 'Удалён $count параметр отслеживания',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitlePartiallyCleaned =>
      'URL-адрес очищен частично';

  @override
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Удалено $removed из $total параметра отслеживания',
      many: 'Удалено $removed из $total параметров отслеживания',
      few: 'Удалено $removed из $total параметров отслеживания',
      one: 'Удалено $removed из $total параметра отслеживания',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitleTrackingDetected =>
      'Обнаружено отслеживание';

  @override
  String openLinkTools_tileSubtitleFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count параметра отслеживания',
      many: 'Найдено $count параметров отслеживания',
      few: 'Найдено $count параметра отслеживания',
      one: 'Найден $count параметр отслеживания',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_cleanUrlTooltip => 'Очистить URL-адрес';

  @override
  String get openLinkTools_unshortenerSettingsTitle => 'Разворачивание ссылок';

  @override
  String get openLinkTools_unshortenerSettingsSubtitle =>
      'Поведение при раскрытии коротких ссылок, настройка токена и сведения о сервисе.';

  @override
  String get openLinkTools_unshortenerEnabledTitle =>
      'Включить разворачивание ссылок';

  @override
  String get openLinkTools_unshortenerEnabledKeywords =>
      'короткие ссылки, сокращённые ссылки, развернуть';

  @override
  String get openLinkTools_unshortenerEnabledSubtitle =>
      'Раскрывать сокращённые URL-адреса до конечного адреса';

  @override
  String get openLinkTools_descriptionLabel => 'Описание';

  @override
  String get openLinkTools_unshortenerDescriptionBody =>
      'Этот модуль раскрывает сокращённые ссылки, отправляя их в unshorten.me. Сервис проверяет каждую ссылку на своих серверах и сохраняет перенаправление для будущих запросов. Не отправляйте ссылки, содержащие личные или конфиденциальные данные.';

  @override
  String get openLinkTools_attributionServiceLabel => 'Сервис';

  @override
  String get openLinkTools_attributionPrivacyPolicyLabel =>
      'Политика конфиденциальности';

  @override
  String get openLinkTools_apiTokenLabel => 'Токен API';

  @override
  String get openLinkTools_apiTokenLabelKeywords => 'токен, ключ, token';

  @override
  String get openLinkTools_apiTokenHint =>
      'Необязательный токен для повышенных лимитов';

  @override
  String get openLinkTools_urlCleanerSettingsTitle => 'Очистка URL-адресов';

  @override
  String get openLinkTools_urlCleanerSettingsSubtitle =>
      'Поведение очистки URL-адресов, обновления каталога правил и сведения об источниках.';

  @override
  String get openLinkTools_urlCleanerDescriptionBody =>
      'Этот модуль удаляет из URL-адресов параметры отслеживания, реферера и другие ненужные параметры. Он также может раскрывать распространённые перенаправления офлайн.';

  @override
  String get openLinkTools_urlCleanerEnabledTitle =>
      'Включить очистку URL-адресов';

  @override
  String get openLinkTools_urlCleanerEnabledKeywords =>
      'очистка ссылок, clean urls, трекинг';

  @override
  String get openLinkTools_urlCleanerEnabledSubtitle =>
      'Удалять параметры отслеживания из URL-адресов';

  @override
  String get openLinkTools_autoApplyTitle => 'Применять автоматически';

  @override
  String get openLinkTools_autoApplyKeywords => 'автоматически, автоприменение';

  @override
  String get openLinkTools_autoApplySubtitle =>
      'Автоматически заменять URL-адрес очищенной версией';

  @override
  String get openLinkTools_allowReferralTitle =>
      'Разрешить реферальный маркетинг';

  @override
  String get openLinkTools_allowReferralKeywords =>
      'партнёрские, реферальные, affiliate, referral';

  @override
  String get openLinkTools_allowReferralSubtitle =>
      'Сохранять реферальные и партнёрские параметры отслеживания';

  @override
  String get openLinkTools_autoUpdateCatalogTitle => 'Автообновление каталога';

  @override
  String get openLinkTools_autoUpdateCatalogSubtitle =>
      'Проверять обновления правил раз в неделю';

  @override
  String get openLinkTools_updateCatalogTitle => 'Обновить каталог';

  @override
  String get openLinkTools_lastUpdateNotAvailable =>
      'Последнее обновление: нет данных';

  @override
  String openLinkTools_lastUpdateWithDate(String date) {
    return 'Последнее обновление: $date';
  }

  @override
  String openLinkTools_lastAutoUpdateWithDate(String date) {
    return 'Последнее обновление: $date (авто)';
  }

  @override
  String openLinkTools_lastCheckWithDate(String date) {
    return 'Последняя проверка: $date';
  }

  @override
  String get openLinkTools_catalogUpdatedMessage => 'Каталог обновлён';

  @override
  String openLinkTools_updateFailedWithError(String error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String get openLinkTools_restoreDefaultsButtonTitle =>
      'Восстановить по умолчанию';

  @override
  String get openLinkTools_restoreDefaultsButtonSubtitle =>
      'Вернуть встроенный каталог и настройки по умолчанию';

  @override
  String get openLinkTools_clearUrlAttributionText =>
      'Этот модуль основан на правилах ClearURLs:';

  @override
  String get openLinkTools_urlCleanerOverviewSectionTitle => 'Обзор';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionTitle => 'Описание';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionKeywords =>
      'параметры отслеживания, перенаправления, редиректы';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle =>
      'Удаление параметров отслеживания и офлайн-очистка перенаправлений';

  @override
  String get openLinkTools_urlCleanerBehaviorSectionTitle => 'Поведение';

  @override
  String get openLinkTools_urlCleanerCatalogSectionTitle => 'Каталог';

  @override
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle =>
      'Загрузить последние правила очистки URL-адресов';

  @override
  String get openLinkTools_urlCleanerAttributionSectionTitle => 'Источники';

  @override
  String get openLinkTools_indexUrlCleanerAttributionTitle => 'Источники';

  @override
  String get openLinkTools_indexUrlCleanerAttributionSubtitle =>
      'Благодарности и ссылки на источники';

  @override
  String get openLinkTools_unshortenerOverviewSectionTitle => 'Обзор';

  @override
  String get openLinkTools_indexUnshortenerDescriptionTitle => 'Описание';

  @override
  String get openLinkTools_indexUnshortenerDescriptionKeywords =>
      'короткие ссылки, перенаправления, редиректы';

  @override
  String get openLinkTools_indexUnshortenerDescriptionSubtitle =>
      'Раскрытие сокращённых URL-адресов с помощью сервиса unshorten.me';

  @override
  String get openLinkTools_unshortenerBehaviorSectionTitle => 'Поведение';

  @override
  String get openLinkTools_indexUnshortenerApiTokenSubtitle =>
      'Необязательный токен для повышенных лимитов запросов';

  @override
  String get openLinkTools_unshortenerAttributionSectionTitle => 'О сервисе';

  @override
  String get openLinkTools_indexUnshortenerAttributionTitle => 'О сервисе';

  @override
  String get openLinkTools_indexUnshortenerAttributionKeywords =>
      'политика конфиденциальности, лимит запросов';

  @override
  String get openLinkTools_indexUnshortenerAttributionSubtitle =>
      'Лимиты запросов, сайт сервиса и политика конфиденциальности';

  @override
  String get pwa_addToHomeScreenTitle => 'Добавить на главный экран';

  @override
  String get pwa_nameFieldLabel => 'Название';

  @override
  String get pwa_storageLabel => 'Хранилище';

  @override
  String get pwa_defaultContainerLabel => 'Контейнер';

  @override
  String get pwa_installAsAppTitle => 'Установить как приложение';

  @override
  String get pwa_installAsAppSubtitle =>
      'Запускается отдельно, в собственном окне.';

  @override
  String get pwa_addShortcutTitle => 'Добавить ярлык';

  @override
  String get pwa_addShortcutSubtitle =>
      'Открывается в обычной вкладке браузера.';

  @override
  String get pwa_storageDefaultTitle => 'По умолчанию';

  @override
  String get pwa_storageDefaultSubtitle =>
      'Использует стандартное хранилище браузера (без контейнера).';

  @override
  String pwa_storageContainerTitle(String label) {
    return 'Контейнер «$label»';
  }

  @override
  String get pwa_storageContainerSubtitle =>
      'Использует общие куки и данные с выбранным контейнером.';

  @override
  String get pwa_storageInheritIsolatedTitle =>
      'Унаследовать текущий изолированный контекст';

  @override
  String get pwa_storageInheritIsolatedSubtitle =>
      'Использует общее хранилище с открытым изолированным сеансом.';

  @override
  String get pwa_storageNewIsolatedTitle => 'Новый изолированный контекст';

  @override
  String get pwa_storageNewIsolatedSubtitle =>
      'Создаёт новое хранилище только для этой установки.';

  @override
  String get pwa_defaultWebAppName => 'это веб-приложение';

  @override
  String get pwa_defaultSiteName => 'этот сайт';

  @override
  String pwa_addedToHomeScreen(String name) {
    return 'Добавлено на главный экран: $name';
  }

  @override
  String pwa_installFailedManifestBacked(String name) {
    return 'Не удалось добавить $name. Возможно, сайт не поддерживает установку.';
  }

  @override
  String pwa_installFailedGeneric(String name) {
    return 'Не удалось добавить на главный экран: $name';
  }

  @override
  String get pwa_noTabSelected => 'Вкладка не выбрана. Повторите попытку.';

  @override
  String get search_moduleLabelRecentSearches => 'Недавние запросы';

  @override
  String get search_moduleLabelSearchProviders => 'Поисковые системы';

  @override
  String get search_moduleLabelSearchSuggestions => 'Подсказки';

  @override
  String get search_moduleLabelTabs => 'Вкладки';

  @override
  String get search_moduleLabelArticles => 'Статьи';

  @override
  String get search_moduleLabelBookmarks => 'Закладки';

  @override
  String get search_moduleLabelHistory => 'История (движок)';

  @override
  String get search_moduleLabelLocalHistory => 'Локальный контент';

  @override
  String get search_moduleLabelCombinedHistory => 'История';

  @override
  String get search_moduleLabelPopularSites => 'Популярные сайты';

  @override
  String get search_moduleLabelHistoryHighlights => 'Интересное из истории';

  @override
  String get search_moduleLabelTopSites => 'Ярлыки';

  @override
  String get search_moduleLabelRecentHistory => 'Недавняя история';

  @override
  String get search_moduleLabelRecentArticles => 'Недавние статьи';

  @override
  String get search_moduleLabelRecentTabs => 'Недавние вкладки';

  @override
  String get search_moduleLabelContainers => 'Контейнеры';

  @override
  String get search_moduleLabelFrequentBangs => 'Частые бэнги';

  @override
  String get search_moduleLabelQuote => 'Цитата';

  @override
  String get search_moduleLabelQuickActions => 'Быстрые действия';

  @override
  String get search_moduleLabelActions => 'Действия';

  @override
  String get search_couldNotLoadHistory => 'Не удалось загрузить историю';

  @override
  String get search_couldNotLoadLocalContent =>
      'Не удалось загрузить локальный контент';

  @override
  String get search_failedSearchingArticles => 'Ошибка поиска статей';

  @override
  String get search_contentMatchTooltip => 'Совпадение в содержимом';

  @override
  String get search_tabTypeRegular => 'Обычная';

  @override
  String get search_tabTypeChild => 'Дочерняя';

  @override
  String get search_tabTypePrivate => 'Приватная';

  @override
  String get search_tabTypeIsolated => 'Изолир.';

  @override
  String get search_fillLinkFromClipboard => 'Вставить ссылку из буфера обмена';

  @override
  String get search_actionNewTab => 'Новая вкладка';

  @override
  String get search_actionViewTabs => 'Вкладки';

  @override
  String get search_actionResumeLastTab => 'Последняя вкладка';

  @override
  String get search_bangTabAllProviders => 'Все системы';

  @override
  String get search_bangTabSearchOnThisSite => 'Поиск на этом сайте';

  @override
  String get search_editShortcutDialogTitle => 'Изменить ярлык';

  @override
  String get search_addShortcut => 'Добавить ярлык';

  @override
  String get search_titleFieldLabel => 'Название';

  @override
  String get search_urlFieldLabel => 'URL-адрес';

  @override
  String get search_titleCannotBeEmpty => 'Название не может быть пустым';

  @override
  String get search_urlCannotBeEmpty => 'URL-адрес не может быть пустым';

  @override
  String get search_enterValidUrl => 'Введите допустимый URL-адрес';

  @override
  String get search_actionPin => 'Закрепить';

  @override
  String get search_actionUnpin => 'Открепить';

  @override
  String get search_actionResetFrequency => 'Сбросить частоту';

  @override
  String get search_actionEditBang => 'Изменить бэнг';

  @override
  String get search_actionCustomizeAsOwnBang =>
      'Настроить как собственный бэнг';

  @override
  String search_resetBangDialogTitle(String triggerName) {
    return 'Сбросить частоту использования $triggerName?';
  }

  @override
  String get search_resetBangDialogContent =>
      'Бэнг будет удалён из списка быстрого выбора.';

  @override
  String get search_customizeSectionsButton => 'Настроить разделы';

  @override
  String get search_customizeSectionsHeading => 'Настройка разделов';

  @override
  String get search_resetToDefaults => 'Сбросить по умолчанию';

  @override
  String search_showAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показать все ($count)',
      many: 'Показать все ($count)',
      few: 'Показать все ($count)',
      one: 'Показать все ($count)',
    );
    return '$_temp0';
  }

  @override
  String get search_disableReorderingMode => 'Выключить режим упорядочивания';

  @override
  String get search_enableReorderingMode => 'Включить режим упорядочивания';

  @override
  String get search_dragDropShortcutsHint =>
      'Перетаскивайте ярлыки, чтобы изменить порядок';

  @override
  String get search_failedReorderShortcut => 'Не удалось переместить ярлык';

  @override
  String search_hideAllFromHost(String host) {
    return 'Скрыть все с $host';
  }

  @override
  String search_pinnedSite(String title) {
    return '«$title» закреплён';
  }

  @override
  String get search_failedPinSite => 'Не удалось закрепить сайт';

  @override
  String get search_shortcutUpdated => 'Ярлык обновлён';

  @override
  String get search_failedUpdateShortcut => 'Не удалось обновить ярлык';

  @override
  String search_addedSite(String title) {
    return '«$title» добавлен';
  }

  @override
  String get search_failedAddShortcut => 'Не удалось добавить ярлык';

  @override
  String search_hidAllShortcutsFromHost(String host) {
    return 'Все ярлыки с $host скрыты';
  }

  @override
  String search_removedSite(String title) {
    return '«$title» удалён';
  }

  @override
  String get search_failedRemoveShortcut => 'Не удалось удалить ярлык';

  @override
  String get search_quoteCardTitle => 'Мысль в дорогу';

  @override
  String get search_refreshQuoteTooltip => 'Другая цитата';

  @override
  String get search_quotePlaceholder =>
      'Откройте новую вкладку и сделайте это место своим.';

  @override
  String get search_searchFieldLabel => 'Введите запрос или URL-адрес';

  @override
  String get search_invalidAddress => 'Недопустимый адрес';

  @override
  String get search_actionSwitchToContainer => 'Перейти в контейнер';

  @override
  String get search_actionSwitchToProfile =>
      'Перейти в этот профиль (браузер перезапустится)';

  @override
  String get search_actionOpenFeed => 'Открыть ленту';

  @override
  String search_actionSettingLocation(String category, String section) {
    return 'Настройки › $category › $section';
  }

  @override
  String search_actionSettingCategory(String category) {
    return 'Настройки › $category';
  }

  @override
  String get search_actionUnnamedContainer => 'Контейнер без названия';

  @override
  String get search_actionUntitledFeed => 'Лента без названия';

  @override
  String get tabs_actionSelect => 'Выбрать';

  @override
  String get tabs_actionUnselect => 'Отменить выбор';

  @override
  String get tabs_unsavedChangesTitle => 'Несохранённые изменения';

  @override
  String get tabs_unsavedChangesConfirm =>
      'Есть несохранённые изменения. Отбросить или сохранить их?';

  @override
  String get tabs_deleteContainerTitle => 'Удалить контейнер';

  @override
  String get tabs_deleteContainerConfirm =>
      'Удалить этот контейнер? Его вкладки будут закрыты.';

  @override
  String get tabs_deleteContainerAlsoDeleteHistory =>
      'Также удалить историю просмотра';

  @override
  String get tabs_deleteContainerHistoryKeptNote =>
      'Если флажок снят, посещения останутся в истории, но больше не будут привязаны к контейнеру.';

  @override
  String get tabs_deleteContainerButton => 'Удалить контейнер';

  @override
  String get tabs_containersTitle => 'Контейнеры';

  @override
  String get tabs_noContainersYet => 'Контейнеров пока нет';

  @override
  String get tabs_loadContainersFailedTitle =>
      'Не удалось загрузить контейнеры';

  @override
  String get tabs_containerFabLabel => 'Новый контейнер';

  @override
  String get tabs_untitledContainer => 'Без названия';

  @override
  String get tabs_emptyContainerLabel => 'Пусто';

  @override
  String tabs_tabCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вкладки',
      many: '$count вкладок',
      few: '$count вкладки',
      one: '$count вкладка',
    );
    return '$_temp0';
  }

  @override
  String get tabs_chipPinned => 'Закреплён';

  @override
  String get tabs_chipIsolated => 'Изолирован';

  @override
  String get tabs_chipDirect => 'Напрямую';

  @override
  String get tabs_chipClearOnExit => 'Очистка при выходе';

  @override
  String get tabs_chipActive => 'Активен';

  @override
  String get tabs_selectContainerTitle => 'Выберите контейнер';

  @override
  String get tabs_unassignedTitle => 'Без контейнера';

  @override
  String get tabs_unassignedSubtitle => 'Вкладки, не привязанные к контейнеру';

  @override
  String get tabs_draftContainersTitle => 'Предлагаемые контейнеры';

  @override
  String get tabs_suggestionsFailedTitle => 'Не удалось загрузить предложения';

  @override
  String get tabs_siteAssignmentsTitle => 'Привязка сайтов';

  @override
  String get tabs_addSiteLabel => 'Добавить сайт';

  @override
  String get tabs_addSiteHint => 'example.com или *.example.com';

  @override
  String get tabs_addSiteHelperText =>
      'Укажите один сайт или используйте *.example.com, чтобы охватить все его поддомены';

  @override
  String get tabs_urlMustBeProvided => 'Необходимо указать URL-адрес';

  @override
  String get tabs_invalidUrl => 'Недопустимый URL-адрес';

  @override
  String get tabs_siteAlreadyAssigned => 'Этот сайт уже привязан';

  @override
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  ) {
    return '$site уже привязан к контейнеру «$containerName»';
  }

  @override
  String tabs_siteAlreadyAssignedToAnotherContainer(String site) {
    return '$site уже привязан к другому контейнеру';
  }

  @override
  String get tabs_newContainerTitle => 'Новый контейнер';

  @override
  String get tabs_editContainerTitle => 'Изменить контейнер';

  @override
  String get tabs_containerNameHint => 'Название контейнера';

  @override
  String get tabs_changeColor => 'Изменить цвет';

  @override
  String get tabs_changeIcon => 'Изменить значок';

  @override
  String get tabs_sectionDisplay => 'Отображение';

  @override
  String get tabs_pinContainer => 'Закрепить контейнер';

  @override
  String get tabs_pinContainerSubtitle =>
      'Держать этот контейнер в начале списка';

  @override
  String get tabs_wallpaperLabel => 'Обои';

  @override
  String get tabs_wallpaperSelectedSubtitle =>
      'Показываются на домашней странице, когда выбран этот контейнер';

  @override
  String get tabs_wallpaperDefaultSubtitle => 'Используются обои из настроек';

  @override
  String get tabs_wallpaperEmptyDescription =>
      'Этот контейнер использует обои, заданные в настройках.';

  @override
  String get tabs_sectionPrivacySecurity => 'Приватность и безопасность';

  @override
  String get tabs_cookieIsolation => 'Изоляция куки';

  @override
  String get tabs_proxyConnectionLabel => 'Прокси-подключение';

  @override
  String get tabs_proxyConnectionNone => 'Нет';

  @override
  String get tabs_bypassGlobalProxy => 'В обход глобального прокси';

  @override
  String get tabs_bypassGlobalProxySubtitle =>
      'Использовать обычное подключение для этого контейнера, когда включена глобальная маршрутизация';

  @override
  String get tabs_clearDataOnExit => 'Очищать данные при выходе';

  @override
  String get tabs_clearDataOnExitSubtitle =>
      'Удалять куки и данные сайтов обычных вкладок этого контейнера при закрытии приложения. У изолированных вкладок данные хранятся отдельно.';

  @override
  String get tabs_excludeFromSearchIndex => 'Исключить из поискового индекса';

  @override
  String get tabs_excludeFromSearchIndexSubtitle =>
      'Не добавлять страницы этого контейнера в локальный поисковый индекс';

  @override
  String get tabs_excludeFromHistory => 'Исключить из истории';

  @override
  String get tabs_excludeFromHistorySubtitle =>
      'Не записывать новые посещения во вкладках этого контейнера и убрать его страницы из локального поиска. Существующая история просмотра сохраняется.';

  @override
  String get tabs_sectionAssignments => 'Привязки';

  @override
  String get tabs_assignedSites => 'Привязанные сайты';

  @override
  String tabs_assignedSitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Настроено $count правила',
      many: 'Настроено $count правил',
      few: 'Настроено $count правила',
      one: 'Настроено $count правило',
    );
    return '$_temp0';
  }

  @override
  String get tabs_assignedSitesEmptySubtitle =>
      'Открывать подходящие сайты в этом контейнере';

  @override
  String get tabs_strictMode => 'Строгий режим';

  @override
  String get tabs_strictModeSubtitle =>
      'Загружать только привязанные сайты; блокировать всё остальное';

  @override
  String get tabs_requiresCookieIsolation =>
      'Требуется включённая изоляция куки';

  @override
  String get tabs_sectionAppLinks => 'Ссылки на приложения';

  @override
  String get tabs_isolatedAppLinkSettings =>
      'Отдельные настройки ссылок на приложения';

  @override
  String get tabs_isolatedAppLinkSettingsSubtitle =>
      'Использовать для этого контейнера собственный режим открытия в приложениях и запомненные правила сайтов вместо глобальных настроек';

  @override
  String get tabs_appLinkBehavior => 'Поведение ссылок на приложения';

  @override
  String get tabs_appLinkBehaviorSubtitle =>
      'Настроить режим открытия в приложениях и запомненные сайты для этого контейнера';

  @override
  String get tabs_selectColorTitle => 'Выбор цвета';

  @override
  String get tabs_customColorTitle => 'Свой цвет';

  @override
  String get tabs_hexLabel => 'Hex';

  @override
  String get tabs_hueLabel => 'Тон';

  @override
  String get tabs_saturationLabel => 'Насыщенность';

  @override
  String get tabs_lightnessLabel => 'Светлота';

  @override
  String get tabs_chooseIconTitle => 'Выбор значка';

  @override
  String tabs_iconCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count значка MDI',
      many: '$count значков MDI',
      few: '$count значка MDI',
      one: '$count значок MDI',
    );
    return '$_temp0';
  }

  @override
  String get tabs_searchIconsHint => 'Поиск значков MDI';

  @override
  String get tabs_noIconsFound => 'Значки не найдены.';

  @override
  String get gestures_screenTitle => 'Жесты';

  @override
  String get gestures_builtInGestureKeywords => 'свайп, смахивание, проведение';

  @override
  String get gestures_resetSwipesToDefaultsAction =>
      'Сбросить свайпы по умолчанию';

  @override
  String get gestures_twoFingerSwipeTitle => 'Свайп двумя пальцами';

  @override
  String get gestures_twoFingerSwipeKeywords => 'контейнер';

  @override
  String get gestures_twoFingerSwipeAction =>
      'Следующий или предыдущий контейнер';

  @override
  String get gestures_pinchTitle => 'Сведение пальцев';

  @override
  String get gestures_pinchKeywords => 'сетка, список, дерево, макет, щипок';

  @override
  String get gestures_pinchAction => 'Сетка, список или дерево';

  @override
  String get gestures_webPagesSectionTitle => 'Веб-страницы';

  @override
  String get gestures_drawnGesturesTitle => 'Рисуемые жесты';

  @override
  String get gestures_drawnGesturesKeywords => 'штрих, росчерк';

  @override
  String get gestures_drawnGesturesSubtitle =>
      'Рисуйте штрихи на странице, чтобы выполнять действия';

  @override
  String get gestures_gestureBindingsTitle => 'Привязки жестов';

  @override
  String get gestures_gestureBindingsSubtitle =>
      'Штрихи, назначенные действиям';

  @override
  String get gestures_behaviorTimingTitle => 'Поведение и тайминги';

  @override
  String get gestures_behaviorTimingSubtitleShort =>
      'Длина штриха, тайм-аут, пауза';

  @override
  String get gestures_excludedSitesTitle => 'Исключённые сайты';

  @override
  String get gestures_excludedSitesSubtitle =>
      'Отключение жестов для отдельных сайтов';

  @override
  String get gestures_feedbackTitle => 'Обратная связь';

  @override
  String get gestures_feedbackSubtitleShort => 'Наложение и подсказки';

  @override
  String get gestures_pullToRefreshTitle => 'Потянуть для обновления';

  @override
  String get gestures_pullToRefreshKeywords => 'перезагрузка, обновить';

  @override
  String get gestures_pullToRefreshSubtitle =>
      'Проведите вниз в начале страницы, чтобы перезагрузить её';

  @override
  String get gestures_toolbarSectionTitle => 'Панель инструментов';

  @override
  String get gestures_longPressButtonsTitle => 'Долгое нажатие на кнопки';

  @override
  String get gestures_longPressButtonsSubtitle =>
      'Выбирается для каждой кнопки при настройке панели инструментов';

  @override
  String get gestures_builtInCannotBeChangedDescription =>
      'Встроенный, нельзя изменить';

  @override
  String get gestures_doNothingTitle => 'Ничего не делать';

  @override
  String get gestures_doNothingSubtitle => 'Свайп игнорируется';

  @override
  String get gestures_restoreDefaultGesturesTooltip =>
      'Восстановить жесты по умолчанию';

  @override
  String get gestures_addGestureButtonLabel => 'Добавить жест';

  @override
  String get gestures_restoreDefaultGesturesConfirmTitle =>
      'Восстановить жесты по умолчанию?';

  @override
  String get gestures_restoreDefaultGesturesConfirmContent =>
      'Всем жестам вернутся действия по умолчанию. Ваши изменения будут потеряны.';

  @override
  String get gestures_noGesturesAssignedMessage => 'Жесты ещё не назначены.';

  @override
  String get gestures_replaceExistingGestureTitle =>
      'Заменить существующий жест?';

  @override
  String gestures_replaceExistingGestureContent(String action) {
    return 'Этот штрих уже назначен действию «$action». При сохранении эта привязка будет заменена.';
  }

  @override
  String get gestures_createGestureTitle => 'Создание жеста';

  @override
  String get gestures_editGestureTitle => 'Изменение жеста';

  @override
  String get gestures_targetActionLabel => 'Действие';

  @override
  String get gestures_startPositionLabel => 'Начальная позиция';

  @override
  String get gestures_fingersLabel => 'Пальцы';

  @override
  String get gestures_strokePatternLabel => 'Шаблон штрихов';

  @override
  String get gestures_drawStrokePatternPlaceholder =>
      'Задайте шаблон штрихов ниже';

  @override
  String get gestures_undoLastAction => 'Отменить последний';

  @override
  String get gestures_replaceGestureButtonLabel => 'Заменить жест';

  @override
  String get gestures_saveGestureButtonLabel => 'Сохранить жест';

  @override
  String gestures_collisionWarning(String action) {
    return 'Уже назначено действию «$action». При сохранении будет заменено.';
  }

  @override
  String get gestures_chooseActionTitle => 'Выбор действия';

  @override
  String get gestures_behaviorTimingScreenSubtitle =>
      'Длина штриха, тайм-аут и пауза.';

  @override
  String get gestures_resetToDefaultsTooltip => 'Сбросить по умолчанию';

  @override
  String get gestures_resetBehaviorTimingConfirmTitle =>
      'Сбросить поведение и тайминги?';

  @override
  String get gestures_resetBehaviorTimingConfirmContent =>
      'Длина штриха, тайм-аут, пауза и интервал штрихов вернутся к значениям по умолчанию. Привязки жестов и другие настройки сохранятся.';

  @override
  String get gestures_minStrokeLengthTitle => 'Минимальная длина штриха';

  @override
  String get gestures_minStrokeLengthKeywords =>
      'размер, длина, чувствительность';

  @override
  String get gestures_timeoutTitle => 'Тайм-аут';

  @override
  String get gestures_timeoutKeywords => 'задержка, время ожидания';

  @override
  String get gestures_timeoutDescription =>
      'Штрих сбрасывается, если за это время не нарисовано новое направление.';

  @override
  String get gestures_cooldownTitle => 'Пауза';

  @override
  String get gestures_cooldownKeywords => 'интервал, задержка';

  @override
  String get gestures_cooldownDescription =>
      'Минимальная задержка между срабатываниями двух жестов.';

  @override
  String get gestures_strokeIntervalTitle => 'Интервал штрихов';

  @override
  String get gestures_strokeIntervalKeywords =>
      'дребезг, дрожание, случайное срабатывание';

  @override
  String get gestures_strokeIntervalDescription =>
      'Минимальное время между сменами направления в одном жесте. Более быстрые смены прерывают жест, защищая от случайных срабатываний.';

  @override
  String get gestures_offLabel => 'Выкл.';

  @override
  String get gestures_excludedSitesDescription =>
      'На этих сайтах жесты отключены. Поддомены включаются (например, «example.com» охватывает и «m.example.com»).';

  @override
  String get gestures_noSitesExcludedMessage => 'Исключённых сайтов нет.';

  @override
  String get gestures_feedbackScreenSubtitle =>
      'Наложение в реальном времени и подсказки жестов.';

  @override
  String get gestures_liveFeedbackTitle => 'Отображение в реальном времени';

  @override
  String get gestures_liveFeedbackSubtitle =>
      'Показывать штрих и его действие во время рисования';

  @override
  String get gestures_suggestNextTitle => 'Подсказывать продолжение';

  @override
  String get gestures_suggestNextSubtitle =>
      'Также показывать другие жесты, которые можно завершить';

  @override
  String get gestures_suggestAfterTitle => 'Подсказывать после';

  @override
  String gestures_strokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count штриха',
      many: '$count штрихов',
      few: '$count штриха',
      one: '$count штрих',
    );
    return '$_temp0';
  }

  @override
  String get gestures_suggestAfterDescription =>
      'Сколько штрихов нарисовать, прежде чем появятся подсказки.';

  @override
  String get gestures_actionRestore => 'Восстановить';

  @override
  String get gestures_actionReplace => 'Заменить';

  @override
  String get gestures_tabBarSurfaceTitle => 'Свайпы по панели вкладок';

  @override
  String get gestures_tabBarSurfaceDescription =>
      'Свайпы по панели вкладок или боковой панели';

  @override
  String get gestures_tabViewSurfaceTitle => 'Свайпы в обзоре вкладок';

  @override
  String get gestures_tabViewSurfaceDescription =>
      'Свайпы по вкладке в списке или сетке вкладок';

  @override
  String get gestures_tabBarSwipeBackwardTitle => 'Свайп влево вдоль панели';

  @override
  String get gestures_tabBarSwipeBackwardDescription =>
      'Свайп вверх по боковой панели делает то же самое';

  @override
  String get gestures_tabBarSwipeForwardTitle => 'Свайп вправо вдоль панели';

  @override
  String get gestures_tabBarSwipeForwardDescription =>
      'Свайп вниз по боковой панели делает то же самое';

  @override
  String get gestures_tabBarSwipeOutwardTitle => 'Свайп к краю экрана';

  @override
  String get gestures_tabBarSwipeOutwardDescription =>
      'Вниз на нижней панели, вверх на верхней, вбок наружу на боковой';

  @override
  String get gestures_tabBarSwipeInwardTitle => 'Свайп от края экрана';

  @override
  String get gestures_tabBarSwipeInwardDescription =>
      'Вверх на нижней панели, вниз на верхней, вбок к странице на боковой';

  @override
  String get gestures_tabSwipeLeftTitle => 'Свайп вкладки влево';

  @override
  String get gestures_tabSwipeLeftDescription =>
      'Действует на смахнутую вкладку, а не на открытую';

  @override
  String get gestures_tabSwipeRightTitle => 'Свайп вкладки вправо';

  @override
  String get gestures_tabSwipeRightDescription =>
      'Действует на смахнутую вкладку, а не на открытую';

  @override
  String get gestures_startPositionAnywhere => 'В любом месте';

  @override
  String get gestures_startPositionLeftEdge => 'Левый край';

  @override
  String get gestures_startPositionRightEdge => 'Правый край';

  @override
  String get gestures_startPositionTopEdge => 'Верхний край';

  @override
  String get gestures_startPositionBottomEdge => 'Нижний край';

  @override
  String get gestures_startPositionLeftHalf => 'Левая половина';

  @override
  String get gestures_startPositionRightHalf => 'Правая половина';

  @override
  String get gestures_strokesSectionTitle => 'Штрихи';

  @override
  String get gestures_indexMinStrokeLengthSubtitle =>
      'Минимальная длина свайпа, распознаваемая как направление';

  @override
  String get gestures_timingSectionTitle => 'Тайминги';

  @override
  String get gestures_indexTimeoutSubtitle =>
      'Сбрасывать штрих, если не нарисовано новое направление';

  @override
  String get gestures_indexCooldownSubtitle =>
      'Минимальная задержка между срабатываниями двух жестов';

  @override
  String get gestures_indexStrokeIntervalSubtitle =>
      'Отклонять жест при слишком быстрой смене направления';

  @override
  String get gestures_overlaySectionTitle => 'Наложение';

  @override
  String get gestures_indexSuggestAfterSubtitle =>
      'Сколько штрихов нарисовать, прежде чем появятся подсказки';

  @override
  String get intentGatekeeper_dialogTitle => 'Открыть ссылку в WebLibre?';

  @override
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  ) {
    return '$appName пытается открыть ссылку в $browserName.';
  }

  @override
  String get intentGatekeeper_alwaysAllow => 'Всегда разрешать';

  @override
  String get intentGatekeeper_allowOnce => 'Разрешить один раз';

  @override
  String get intentGatekeeper_blockOnce => 'Заблокировать один раз';

  @override
  String get intentGatekeeper_alwaysBlock => 'Всегда блокировать';

  @override
  String get keyboardShortcuts_title => 'Сочетания клавиш';

  @override
  String get keyboardShortcuts_searchHint => 'Поиск действий или клавиш';

  @override
  String get keyboardShortcuts_noMatchingActions => 'Подходящих действий нет.';

  @override
  String get keyboardShortcuts_overviewNoneAssigned =>
      'Действиям браузера не назначены клавиши.';

  @override
  String get keyboardShortcuts_overviewDisabled =>
      'Сочетания клавиш отключены.';

  @override
  String get keyboardShortcuts_enableTitle => 'Включить сочетания клавиш';

  @override
  String get keyboardShortcuts_enableSubtitle =>
      'Действия браузера с аппаратной клавиатуры, даже когда фокус на странице';

  @override
  String get keyboardShortcuts_noShortcut => 'Нет сочетания';

  @override
  String get keyboardShortcuts_tooltipChange => 'Изменить';

  @override
  String keyboardShortcuts_tooltipRemoveChord(String chord) {
    return 'Удалить $chord';
  }

  @override
  String get keyboardShortcuts_tooltipResetToDefault => 'Сбросить по умолчанию';

  @override
  String get keyboardShortcuts_addShortcut => 'Добавить сочетание';

  @override
  String get keyboardShortcuts_changeShortcutTitle => 'Изменить сочетание';

  @override
  String get keyboardShortcuts_restoreDefaultsTooltip =>
      'Восстановить сочетания по умолчанию';

  @override
  String get keyboardShortcuts_restoreDefaultsTitle =>
      'Восстановить сочетания по умолчанию?';

  @override
  String get keyboardShortcuts_restoreDefaultsContent =>
      'Всем действиям вернутся стандартные клавиши Firefox. Ваши изменения будут потеряны.';

  @override
  String keyboardShortcuts_recorderInstructions(String actionTitle) {
    return 'Нажмите сочетание клавиш для «$actionTitle».';
  }

  @override
  String get keyboardShortcuts_recorderWaitingForKeys =>
      'Ожидание нажатия клавиш…';

  @override
  String get keyboardShortcuts_recorderProblemNotAssignable =>
      'Эта клавиша нужна веб-страницам. Удерживайте вместе с ней Ctrl, Alt или Meta либо используйте функциональную клавишу.';

  @override
  String get keyboardShortcuts_recorderProblemAlreadyBound =>
      'Это сочетание уже назначено этому действию.';

  @override
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle) {
    return 'Сейчас используется действием «$ownerTitle». При сохранении оно будет перенесено сюда.';
  }

  @override
  String get keyboardShortcuts_actionCustomize => 'Настроить';

  @override
  String get keyboardShortcuts_actionReassign => 'Переназначить';

  @override
  String get keyboardShortcuts_actionRestore => 'Восстановить';

  @override
  String get onboarding_actionPrevious => 'Назад';

  @override
  String get onboarding_actionNext => 'Далее';

  @override
  String get onboarding_actionRestore => 'Восстановить';

  @override
  String get onboarding_restoreTargetUnreadable =>
      'Не удалось прочитать этот профиль, поэтому восстановить в него ничего нельзя.';

  @override
  String get onboarding_welcomeBackTitle => 'С возвращением!';

  @override
  String get onboarding_welcomeReadyTitle => 'WebLibre готов к работе';

  @override
  String get onboarding_chooseExperience =>
      'Выберите вариант начальной настройки:';

  @override
  String get onboarding_modeExpressTitle => 'Быстрый старт';

  @override
  String get onboarding_modeExpressSubtitle =>
      'Использовать рекомендуемые настройки и начать работу.';

  @override
  String get onboarding_modeDetailedTitle => 'Своя настройка';

  @override
  String get onboarding_modeDetailedSubtitle =>
      'Настроить DNS, панель инструментов, расширения и многое другое.';

  @override
  String get onboarding_modeRestoreTitle => 'Восстановить из резервной копии';

  @override
  String get onboarding_modeRestoreSubtitle =>
      'Импортировать профиль из зашифрованного файла резервной копии.';

  @override
  String get onboarding_updateNoticeTitle => 'Многое изменилось!';

  @override
  String get onboarding_updateNoticeBody =>
      'Это обновление содержит существенные изменения, поэтому нужно проверить настройки. Пройдите следующие страницы, чтобы проверить конфигурацию.';

  @override
  String get onboarding_updateNoticeExtensions =>
      'После этого обновления перепроверьте расширения: известны проблемы при их переносе.';

  @override
  String get onboarding_updateNoticeSettingsPreserved =>
      'Существующие настройки не будут перезаписаны, если вы явно не измените их во время этой настройки.';

  @override
  String get onboarding_eulaAcceptance =>
      'Я ознакомлен(а) с <eula>лицензионным соглашением</eula> и <privacy>политикой конфиденциальности</privacy> и принимаю их.';

  @override
  String get onboarding_privacyPolicy => 'Политика конфиденциальности';

  @override
  String get onboarding_eulaDocumentTitle =>
      'Лицензионное соглашение с конечным пользователем';

  @override
  String get onboarding_aiFeaturesTitle => 'Функции ИИ';

  @override
  String get onboarding_aiOnDeviceTitle => 'ИИ на устройстве';

  @override
  String get onboarding_aiOnDeviceSubtitle =>
      'Локальные функции на устройстве, включая темы контейнеров и предложения вкладок';

  @override
  String get onboarding_aiWarningTitle => 'Что нужно учитывать';

  @override
  String get onboarding_aiWarningPoint1 =>
      'WebLibre использует локальную модель ИИ, чтобы анализировать заголовки открытых вкладок и предлагать, в какие контейнеры их сгруппировать и как эти контейнеры назвать. Вся обработка выполняется только на вашем устройстве.';

  @override
  String get onboarding_aiWarningPoint2 =>
      'Функции ИИ работают полностью внутри браузера, и все данные остаются на устройстве. Локальная обработка сохраняет вашу конфиденциальность и ускоряет подбор групп контейнеров и их названий. Это поведение можно изменить в любой момент в настройках.';

  @override
  String get onboarding_aiWarningPoint3 =>
      'ИИ может ошибаться, поэтому проверяйте предложенные названия групп и выбор вкладок.';

  @override
  String get onboarding_searchTitle => 'Поиск';

  @override
  String get onboarding_searchDefaultProviderLabel =>
      'Поисковая система по умолчанию';

  @override
  String get onboarding_searchMore => 'Другие системы';

  @override
  String get onboarding_searchDefaultAutocompleteLabel =>
      'Сервис подсказок по умолчанию';

  @override
  String get onboarding_searchLoadFailedTitle =>
      'Не удалось загрузить поисковые системы';

  @override
  String get onboarding_dohTitle => 'DNS через HTTPS';

  @override
  String get onboarding_permissionsTitle => 'Разрешения';

  @override
  String get onboarding_permissionsNotificationsTitle => 'Уведомления';

  @override
  String get onboarding_permissionsNotificationsSubtitle =>
      'Нужны для уведомлений о загрузках';

  @override
  String get onboarding_permissionsDefaultBrowserTitle =>
      'Браузер по умолчанию';

  @override
  String get onboarding_permissionsDefaultBrowserSubtitle =>
      'Сделать WebLibre браузером по умолчанию';

  @override
  String get onboarding_privacyTitle => 'Приватность и усиление защиты';

  @override
  String get onboarding_privacyBrowserLanguagesTitle => 'Языки браузера';

  @override
  String get onboarding_privacyBrowserLanguagesSubtitle =>
      'Настроить языковые предпочтения, сообщаемые сайтам';

  @override
  String get onboarding_multipleLanguagesDetectedTitle =>
      'Обнаружено несколько языков';

  @override
  String onboarding_multipleLanguagesWarning(int count, String locales) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В браузере настроено $count языка ($locales).',
      many: 'В браузере настроено $count языков ($locales).',
      few: 'В браузере настроено $count языка ($locales).',
      one: 'В браузере настроен $count язык ($locales).',
    );
    return '$_temp0 Сайты могут использовать уникальное сочетание ваших языков, чтобы создать цифровой отпечаток и отслеживать вас в интернете.';
  }

  @override
  String get onboarding_multipleLanguagesSuggestion =>
      'Можно оставить в браузере только один язык, чтобы сайтам было сложнее составить ваш цифровой отпечаток.';

  @override
  String get onboarding_reviewLanguages => 'Проверить языки';

  @override
  String get onboarding_webEngineHardeningTitle =>
      'Полное усиление защиты веб-движка';

  @override
  String get onboarding_webEngineHardeningSubtitle =>
      'Применить к веб-движку все рекомендуемые параметры усиления безопасности';

  @override
  String get onboarding_fingerprintProtectionTitle =>
      'Усиленная защита от цифровых отпечатков';

  @override
  String get onboarding_fingerprintProtectionSubtitle =>
      'Загрузить полный набор параметров защиты от цифровых отпечатков';

  @override
  String get onboarding_compatibilityWarningTitle =>
      'Предупреждение о совместимости';

  @override
  String get onboarding_fingerprintWarningPoint1 =>
      'Усиленная защита от цифровых отпечатков включает более 60 мер защиты, в том числе рандомизацию canvas, подмену navigator, маскировку медиаустройств и многое другое.';

  @override
  String get onboarding_fingerprintWarningPoint2 =>
      'Из-за этого сайты могут работать неправильно или вести себя неожиданно. Отдельные меры защиты можно настроить в настройках.';

  @override
  String get onboarding_localNetworkProtectionTitle => 'Защита локальной сети';

  @override
  String get onboarding_localNetworkProtectionSubtitle =>
      'Сайты могут пытаться обращаться к вашему устройству и другим устройствам в домашней сети — маршрутизаторам, принтерам или устройствам умного дома. По умолчанию известным трекерам это автоматически запрещено.';

  @override
  String get onboarding_blockAllLocalNetworkTitle =>
      'Блокировать все запросы к локальной сети';

  @override
  String get onboarding_blockAllLocalNetworkSubtitle =>
      'Запрашивать разрешение, прежде чем любой сайт, а не только известные трекеры, обратится к устройствам в домашней сети';

  @override
  String get onboarding_toolbarLayoutTitle => 'Панель инструментов и макет';

  @override
  String get onboarding_ublockTitle => 'uBlock Origin';

  @override
  String get onboarding_ublockDescription =>
      'uBlock Origin (uBO) — экономный в отношении процессора и памяти **блокировщик контента широкого спектра** от **Raymond Hill**, доступный как расширение для WebLibre.\n\nПо умолчанию он блокирует рекламу, трекеры, майнеры, всплывающие окна, назойливые анти-блокировщики, вредоносные сайты и многое другое с помощью списков **EasyList, EasyPrivacy, Peter Lowe\'s Blocklist, Online Malicious URL Blocklist и фильтров uBO**.\n\nДоступно множество других списков для блокировки дополнительного контента.';

  @override
  String get onboarding_ublockInstallTitle =>
      'Установить расширение uBlock Origin';

  @override
  String get onboarding_ublockApplyDefaultsTitle =>
      'Применить оптимизированные настройки';

  @override
  String get onboarding_ublockApplyDefaultsSubtitle =>
      'Включить списки фильтров WebLibre для усиления защиты.';

  @override
  String get proxy_actionChange => 'Изменить';

  @override
  String get proxy_actionFetch => 'Получить';

  @override
  String get proxy_actionSelectAll => 'Выбрать все';

  @override
  String get proxy_actionShare => 'Поделиться';

  @override
  String get proxy_actionStart => 'Запустить';

  @override
  String get proxy_actionStop => 'Остановить';

  @override
  String get proxy_actionStopAndDelete => 'Остановить и удалить';

  @override
  String get proxy_actionTestConnection => 'Проверить соединение';

  @override
  String get proxy_connectionsTitle => 'Прокси-подключения';

  @override
  String get proxy_addProfile => 'Добавить профиль';

  @override
  String get proxy_viewLogsTooltip => 'Журналы';

  @override
  String get proxy_profilesSectionTitle => 'Профили';

  @override
  String proxy_loadProfilesFailed(String error) {
    return 'Не удалось загрузить профили прокси:\n$error';
  }

  @override
  String get proxy_statusActive => 'Активно';

  @override
  String get proxy_statusDisconnected => 'Отключено';

  @override
  String proxy_statusRoutingTraffic(int running, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Запущено $running из $total прокси',
      many: 'Запущено $running из $total прокси',
      few: 'Запущено $running из $total прокси',
      one: 'Запущено $running из $total прокси',
    );
    return '$_temp0';
  }

  @override
  String get proxy_statusTapToConnect =>
      'Нажмите на профиль, чтобы подключиться';

  @override
  String get proxy_stopAllTooltip => 'Остановить все';

  @override
  String get proxy_onionRoutingLabel => 'Луковая маршрутизация';

  @override
  String get proxy_autostartLabel => 'Автозапуск';

  @override
  String get proxy_autostartTooltip => 'Запускается вместе с WebLibre';

  @override
  String proxy_egressIpTooltip(String ip) {
    return 'Выходной IP $ip';
  }

  @override
  String get proxy_latencyTesting => 'Проверка…';

  @override
  String get proxy_latencyTestRunningTooltip => 'Идёт проверка задержки';

  @override
  String get proxy_latencyNotRunningTooltip => 'Профиль не запущен';

  @override
  String get proxy_latencyFailed => 'Ошибка';

  @override
  String proxy_latencyMilliseconds(int ms) {
    return '$ms мс';
  }

  @override
  String proxy_latencyHttpStatusTooltip(int statusCode, int ms) {
    return 'HTTP $statusCode за $ms мс';
  }

  @override
  String proxy_startProxyFailed(String error) {
    return 'Не удалось запустить прокси: $error';
  }

  @override
  String proxy_stopProxyFailed(String error) {
    return 'Не удалось остановить прокси: $error';
  }

  @override
  String proxy_startBrandFailed(String brand, String error) {
    return 'Не удалось запустить $brand: $error';
  }

  @override
  String proxy_stopBrandFailed(String brand, String error) {
    return 'Не удалось остановить $brand: $error';
  }

  @override
  String get proxy_startConnectionDialogTitle =>
      'Запустить прокси-подключение?';

  @override
  String proxy_startConnectionDialogContent(String proxyTitle) {
    return 'Этой вкладке нужно подключение $proxyTitle, но оно не запущено. Запустить его сейчас?';
  }

  @override
  String get proxy_deleteProfileTitle => 'Удалить профиль?';

  @override
  String proxy_deleteProfileConfirm(String name) {
    return 'Удалить $name и сохранённые секреты? Вкладки и контейнеры, назначенные этому профилю, будут заблокированы, пока вы не выберете другой прокси или не снимете назначение.';
  }

  @override
  String proxy_deleteProfileConfirmRunning(String name) {
    return 'Остановить $name, а затем удалить его и сохранённые секреты? Вкладки и контейнеры, назначенные этому профилю, будут заблокированы, пока вы не выберете другой прокси или не снимете назначение.';
  }

  @override
  String proxy_deleteProfileFailed(String error) {
    return 'Не удалось удалить профиль: $error';
  }

  @override
  String proxy_shareDialogTitle(String name) {
    return 'Поделиться «$name»';
  }

  @override
  String get proxy_shareDialogWarning =>
      'Эта ссылка содержит весь профиль, включая сохранённые учётные данные. Делитесь ею осторожно.';

  @override
  String get proxy_copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get proxy_editProfileTitle => 'Изменить профиль';

  @override
  String get proxy_newProfileTitle => 'Новый профиль';

  @override
  String get proxy_saveChanges => 'Сохранить изменения';

  @override
  String get proxy_createProfile => 'Создать профиль';

  @override
  String get proxy_sectionGeneral => 'Общие';

  @override
  String get proxy_sectionDnsOverride => 'Свой DNS';

  @override
  String get proxy_addMenuTip =>
      'Совет: чтобы импортировать из файла, вставить ссылку или отсканировать QR-код, используйте меню добавления на предыдущем экране.';

  @override
  String proxy_wireGuardTrademarkDisclaimer(String brand) {
    return '$brand — зарегистрированный товарный знак Jason A. Donenfeld; все права защищены. WebLibre не одобрен, не спонсируется и не связан с Jason A. Donenfeld.';
  }

  @override
  String proxy_wireGuardConfigLabel(String brand) {
    return 'Конфигурация $brand';
  }

  @override
  String get proxy_fieldProfileName => 'Имя профиля';

  @override
  String get proxy_fieldProtocol => 'Протокол';

  @override
  String get proxy_protocolFixedHelper =>
      'После создания профиля протокол изменить нельзя.';

  @override
  String get proxy_customOutboundLabel => 'Свой outbound';

  @override
  String get proxy_startAutomaticallyTitle => 'Запускать автоматически';

  @override
  String get proxy_startAutomaticallySubtitle =>
      'Подключать этот профиль при запуске WebLibre, чтобы использующие его вкладки были готовы без запроса';

  @override
  String proxy_dnsOverrideExplanation(String brand) {
    return 'Разрешать имена через DNS-сервер, доступный через это подключение (например, внутренний сервер DoH за корпоративным туннелем $brand). Оставьте выключенным, чтобы DNS обрабатывался автоматически.';
  }

  @override
  String get proxy_dnsOverrideSwitchTitle =>
      'Использовать отдельный резолвер для профиля';

  @override
  String get proxy_fieldDnsServerAddress => 'Адрес DNS-сервера';

  @override
  String get proxy_sectionOutbound => 'Outbound';

  @override
  String get proxy_sectionSecrets => 'Секреты';

  @override
  String get proxy_fieldOutboundJson => 'Outbound JSON';

  @override
  String get proxy_outboundJsonHelper => 'Публичный объект outbound sing-box.';

  @override
  String get proxy_fieldSecretJson => 'Секретный JSON';

  @override
  String get proxy_secretJsonHelper =>
      'Необязательные значения, добавляемые в outbound во время работы.';

  @override
  String get proxy_sectionConnection => 'Подключение';

  @override
  String get proxy_sectionCredentials => 'Учётные данные';

  @override
  String get proxy_sectionProtocolOptions => 'Параметры протокола';

  @override
  String get proxy_sectionTls => 'TLS';

  @override
  String get proxy_sectionTransport => 'Транспорт';

  @override
  String get proxy_sectionMultiplex => 'Мультиплексирование';

  @override
  String get proxy_sectionDial => 'Dial';

  @override
  String get proxy_advancedOptionsHint =>
      'Расширенные параметры протокола также можно задать в JSON-конфигурации «Свой outbound».';

  @override
  String get proxy_storedInSecureStorage => 'Хранится в защищённом хранилище.';

  @override
  String get proxy_booleanFieldUnset => 'Не задано (по умолчанию)';

  @override
  String get proxy_booleanFieldEnabled => 'Включено';

  @override
  String get proxy_booleanFieldDisabled => 'Выключено';

  @override
  String get proxy_addConnectionTitle => 'Добавить подключение';

  @override
  String get proxy_addConnectionSubtitle =>
      'Выберите способ добавления профиля прокси.';

  @override
  String get proxy_methodClipboardTitle => 'Буфер обмена';

  @override
  String get proxy_methodClipboardSubtitle => 'Вставить ссылку или URI';

  @override
  String get proxy_methodScanQrTitle => 'Сканировать QR';

  @override
  String get proxy_methodScanQrSubtitle => 'С другого устройства';

  @override
  String get proxy_methodSubscriptionTitle => 'Подписка';

  @override
  String get proxy_methodSubscriptionSubtitle => 'Получить по URL-адресу';

  @override
  String get proxy_methodImportFileTitle => 'Импорт файла';

  @override
  String get proxy_methodImportFileSubtitle => '.conf или sing-box JSON';

  @override
  String get proxy_enterManually => 'Ввести вручную';

  @override
  String get proxy_clipboardEmpty => 'Буфер обмена пуст.';

  @override
  String get proxy_importFromFileTitle => 'Импорт из файла';

  @override
  String get proxy_importFileWireGuardSubtitle =>
      'Файл .conf с [Interface]/[Peer]';

  @override
  String get proxy_importFileSingboxJsonTitle => 'Sing-box outbound JSON';

  @override
  String get proxy_importFileSingboxJsonSubtitle =>
      'Shadowsocks, Trojan, VMess, VLESS, Hysteria, …';

  @override
  String proxy_importedProfileNamed(String name) {
    return 'Профиль «$name» импортирован';
  }

  @override
  String get proxy_importSubscriptionTitle => 'Импорт подписки';

  @override
  String get proxy_fieldSubscriptionUrl => 'URL-адрес подписки';

  @override
  String get proxy_subscriptionUrlRequired =>
      'Введите полный URL-адрес подписки с https://.';

  @override
  String proxy_subscriptionHttpError(int statusCode) {
    return 'Сервер подписки ответил HTTP $statusCode.';
  }

  @override
  String get proxy_subscriptionTimedOut =>
      'Сервер подписки не ответил вовремя.';

  @override
  String proxy_subscriptionFetchFailed(String error) {
    return 'Не удалось получить подписку: $error';
  }

  @override
  String get proxy_subscriptionFormatHint =>
      'Поддерживается формат в стиле v2rayN: список URI ss://, vless://, vmess://, trojan://, hysteria2://, tuic:// и подобных в кодировке base64. Правила маршрутизации из подписки игнорируются — импортируются только узлы прокси.';

  @override
  String proxy_importedProfileDefaultName(int n) {
    return 'Импорт $n';
  }

  @override
  String proxy_importedProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count профиля',
      many: 'Импортировано $count профилей',
      few: 'Импортировано $count профиля',
      one: 'Импортирован $count профиль',
    );
    return '$_temp0';
  }

  @override
  String proxy_importProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировать $count профиля',
      many: 'Импортировать $count профилей',
      few: 'Импортировать $count профиля',
      one: 'Импортировать $count профиль',
    );
    return '$_temp0';
  }

  @override
  String proxy_subscriptionNodeSummary(int usable, int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable пригодных узлов',
      many: '$usable пригодных узлов',
      few: '$usable пригодных узла',
      one: '$usable пригодный узел',
    );
    String _temp1 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$failed узлов с ошибкой',
      many: '$failed узлов с ошибкой',
      few: '$failed узла с ошибкой',
      one: '$failed узел с ошибкой',
    );
    String _temp2 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable пригодных узлов',
      many: '$usable пригодных узлов',
      few: '$usable пригодных узла',
      one: '$usable пригодный узел',
    );
    String _temp3 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$_temp0, $_temp1',
      zero: '$_temp2',
    );
    return '$_temp3';
  }

  @override
  String get proxy_logsTitle => 'Журналы прокси';

  @override
  String get proxy_logsCopyAllTooltip => 'Копировать все';

  @override
  String get proxy_logsClearTooltip => 'Очистить журнал';

  @override
  String get proxy_logsShareSubject => 'журналы прокси';

  @override
  String get proxy_logsNoLinesMatchFilter =>
      'Нет строк журнала, соответствующих текущему фильтру';

  @override
  String proxy_logsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скопировано $count строки',
      many: 'Скопировано $count строк',
      few: 'Скопировано $count строки',
      one: 'Скопирована $count строка',
    );
    return '$_temp0';
  }

  @override
  String get proxy_logsShowAllLevels => 'Показать все уровни';

  @override
  String get proxy_logsShowErrorsOnly => 'Показать только ошибки';

  @override
  String get proxy_logsShowWarningsAndAbove => 'Показать предупреждения и выше';

  @override
  String get proxy_logsShowInfoAndAbove => 'Показать информацию и выше';

  @override
  String get proxy_logsShowDebugAndAbove => 'Показать отладку и выше';

  @override
  String get proxy_logsShowTraceAndAbove => 'Показать трассировку и выше';

  @override
  String get proxy_logsLatest => 'Последние';

  @override
  String get proxy_logsEmptyFiltered =>
      'На этом уровне нет строк журнала. Понизьте фильтр отображения или повысьте уровень журналирования прокси.';

  @override
  String proxy_logsEmpty(String brand) {
    return 'Строк журнала пока нет. Запустите прокси или $brand, чтобы увидеть вывод здесь.';
  }

  @override
  String get proxy_recordingLevelWarn => 'Записываются предупреждения и ошибки';

  @override
  String get proxy_recordingLevelInfo =>
      'Записывается Info — это замедляет браузер';

  @override
  String get proxy_recordingLevelDebug =>
      'Записывается Debug — это замедляет браузер';

  @override
  String get proxy_recordingLevelTrace =>
      'Записывается Trace — это замедляет браузер';

  @override
  String get proxy_logLevelAll => 'Все';

  @override
  String get proxy_logLevelTrace => 'Trace';

  @override
  String get proxy_logLevelDebug => 'Debug';

  @override
  String get proxy_logLevelInfo => 'Info';

  @override
  String get proxy_logLevelWarnings => 'Предупр.';

  @override
  String get proxy_logLevelErrors => 'Ошибки';

  @override
  String get proxy_logLevelSheetTitle => 'Уровень журнала прокси';

  @override
  String get proxy_logLevelSheetExplanation =>
      'Повышайте уровень только на время диагностики проблемы, затем верните обратно. Изменение перезапускает все работающие прокси.';

  @override
  String get proxy_verboseLoggingWarning =>
      'Подробный журнал записывает строку для каждого соединения и DNS-запроса, что заметно замедляет браузер.';

  @override
  String get proxy_logVerbosityWarnLabel => 'Предупреждения и ошибки';

  @override
  String get proxy_logVerbosityInfoLabel => 'Info';

  @override
  String get proxy_logVerbosityDebugLabel => 'Debug';

  @override
  String get proxy_logVerbosityTraceLabel => 'Trace';

  @override
  String get proxy_logVerbosityWarnDescription =>
      'Обычная работа. Проблемы всё равно записываются.';

  @override
  String get proxy_logVerbosityInfoDescription =>
      'Каждое соединение и DNS-запрос. Замедляет браузер.';

  @override
  String get proxy_logVerbosityDebugDescription =>
      'Info плюс подробности протокола. Замедляет браузер.';

  @override
  String get proxy_logVerbosityTraceDescription =>
      'Всё, что может сообщить sing-box. Сильно замедляет браузер.';

  @override
  String get proxy_loadingProxyTitle => 'Загрузка прокси…';

  @override
  String proxy_torConnectionSubtitle(String torBrand) {
    return 'Маршрутизация через сеть $torBrand';
  }

  @override
  String get proxy_routingTitle => 'Маршрутизация прокси';

  @override
  String get proxy_routingSubtitle =>
      'Выберите, через какой прокси идёт трафик обычных и приватных вкладок.';

  @override
  String get proxy_routingSectionRegularTabs => 'Обычные вкладки';

  @override
  String get proxy_routingSectionRegularTabsKeywords =>
      'маршрутизация, маршрут, routing';

  @override
  String get proxy_routingSectionPrivateTabs => 'Приватные вкладки';

  @override
  String get proxy_routingSectionPrivateTabsKeywords =>
      'приватные, инкогнито, private';

  @override
  String get proxy_routingRegularTabsModeTitle =>
      'Режим маршрутизации обычных вкладок';

  @override
  String get proxy_routingRegularTabsModeKeywords => 'контейнер, глобальный';

  @override
  String get proxy_routingRegularTabsModeSubtitle =>
      'Выберите, как обычные вкладки маршрутизируются через прокси';

  @override
  String get proxy_routingGlobalProxyTitle =>
      'Прокси для глобальной маршрутизации';

  @override
  String get proxy_routingGlobalProxyKeywords => 'прокси, proxy';

  @override
  String get proxy_routingGlobalProxySubtitle =>
      'Прокси, выбранный для включённой глобальной маршрутизации';

  @override
  String get proxy_routingPrivateTabsProxyTitle =>
      'Прокси для приватных вкладок';

  @override
  String get proxy_routingPrivateTabsProxyKeywords => 'прокси, proxy';

  @override
  String get proxy_routingPrivateTabsProxySubtitle =>
      'Прокси, через который идёт трафик приватных вкладок';

  @override
  String get proxy_routingContainerBasedTitle => 'Маршрутизация по контейнерам';

  @override
  String get proxy_routingContainerBasedSubtitle =>
      'Маршрутизируются только вкладки в контейнерах с назначенным прокси.';

  @override
  String get proxy_routingGlobalRoutingTitle => 'Глобальная маршрутизация';

  @override
  String get proxy_routingGlobalRoutingSubtitle =>
      'Направлять обычные вкладки через выбранный прокси, если контейнер не обходит его.';

  @override
  String get proxy_routingNotUsedTitle =>
      'Не используется при маршрутизации по контейнерам';

  @override
  String get proxy_routingNotUsedSubtitle =>
      'Переключитесь выше на глобальную маршрутизацию, чтобы выбрать прокси для всех обычных вкладок.';

  @override
  String get proxy_routingNoneTitle => 'Нет';

  @override
  String get proxy_routingNoneSubtitle =>
      'Использовать обычное подключение браузера';

  @override
  String get proxy_routingUnknownProxySubtitle =>
      'Выбранный прокси больше не существует.';

  @override
  String get proxy_unknownProxyTitle => 'Неизвестный прокси';

  @override
  String get proxy_connectionPickerTitle => 'Прокси-подключение';

  @override
  String get proxy_pickerUnknownProxySubtitle =>
      'Этот профиль прокси больше не существует';

  @override
  String get proxy_fieldServerAddress => 'Адрес сервера';

  @override
  String get proxy_fieldServerPort => 'Порт сервера';

  @override
  String get proxy_fieldUsername => 'Имя пользователя';

  @override
  String get proxy_fieldPassword => 'Пароль';

  @override
  String get proxy_fieldUuid => 'UUID';

  @override
  String get proxy_fieldTlsEnabled => 'TLS включён';

  @override
  String get proxy_fieldTlsEnabledHelper => 'true или false.';

  @override
  String get proxy_fieldTlsServerName => 'Имя сервера TLS';

  @override
  String get proxy_fieldTlsInsecure =>
      'Разрешить недействительные сертификаты TLS';

  @override
  String get proxy_fieldTlsInsecureHelper => 'true или false.';

  @override
  String get proxy_fieldTlsAlpn => 'TLS ALPN';

  @override
  String get proxy_fieldTlsAlpnHelper =>
      'Через запятую или по одному значению на строку.';

  @override
  String get proxy_fieldTransportType => 'Тип транспорта';

  @override
  String get proxy_fieldTransportTypeHelper =>
      'Например, ws, http, grpc или quic.';

  @override
  String get proxy_fieldTransportPath => 'Путь транспорта';

  @override
  String get proxy_fieldGrpcServiceName => 'Имя сервиса gRPC';

  @override
  String get proxy_fieldMultiplexEnabled => 'Мультиплексирование включено';

  @override
  String get proxy_fieldMultiplexEnabledHelper => 'true или false.';

  @override
  String get proxy_fieldMultiplexProtocol => 'Протокол мультиплексирования';

  @override
  String get proxy_fieldMultiplexMaxConnections =>
      'Макс. соединений мультиплексирования';

  @override
  String get proxy_fieldDialDetour => 'Dial Detour';

  @override
  String get proxy_fieldBindInterface => 'Привязка к интерфейсу';

  @override
  String get proxy_fieldRoutingMark => 'Метка маршрутизации';

  @override
  String get proxy_fieldDomainStrategy => 'Стратегия доменов';

  @override
  String get proxy_fieldDomainStrategyHelper =>
      'Например, prefer_ipv4 или prefer_ipv6.';

  @override
  String get proxy_fieldConnectTimeout => 'Тайм-аут соединения';

  @override
  String get proxy_fieldConnectTimeoutHelper => 'Например, 5s.';

  @override
  String get proxy_fieldSocksVersion => 'Версия SOCKS';

  @override
  String get proxy_fieldMethod => 'Метод';

  @override
  String get proxy_fieldSecurity => 'Безопасность';

  @override
  String get proxy_fieldAlterId => 'Alter ID';

  @override
  String get proxy_fieldFlow => 'Flow';

  @override
  String get proxy_fieldAuthString => 'Строка аутентификации';

  @override
  String get proxy_fieldUploadBandwidth => 'Пропускная способность отдачи';

  @override
  String get proxy_fieldDownloadBandwidth => 'Пропускная способность загрузки';

  @override
  String get proxy_fieldObfuscation => 'Обфускация';

  @override
  String get proxy_fieldReceiveWindowConn => 'Окно приёма (соединение)';

  @override
  String get proxy_fieldReceiveWindow => 'Окно приёма';

  @override
  String get proxy_fieldDisableMtuDiscovery => 'Отключить определение MTU';

  @override
  String get proxy_fieldDisableMtuDiscoveryHelper => 'true или false.';

  @override
  String get proxy_fieldUploadMbps => 'Отдача, Мбит/с';

  @override
  String get proxy_fieldDownloadMbps => 'Загрузка, Мбит/с';

  @override
  String get proxy_fieldObfuscationType => 'Тип обфускации';

  @override
  String get proxy_fieldObfuscationPassword => 'Пароль обфускации';

  @override
  String get proxy_fieldCongestionControl => 'Контроль перегрузки';

  @override
  String get proxy_fieldUdpRelayMode => 'Режим ретрансляции UDP';

  @override
  String get proxy_fieldZeroRttHandshake => 'Рукопожатие Zero RTT';

  @override
  String get proxy_fieldZeroRttHandshakeHelper => 'true или false.';

  @override
  String get proxy_fieldUser => 'Пользователь';

  @override
  String get proxy_fieldPrivateKey => 'Закрытый ключ';

  @override
  String get proxy_fieldPrivateKeyPassphrase =>
      'Парольная фраза закрытого ключа';

  @override
  String get proxy_fieldLocalAddress => 'Локальный адрес';

  @override
  String get proxy_fieldLocalAddressHelper =>
      'Адрес этого устройства внутри туннеля, по одному на строку (например, 10.0.0.2/32). Адрес без префикса считается одиночным (/32 или /128 для IPv6).';

  @override
  String get proxy_fieldPeerPublicKey => 'Открытый ключ пира';

  @override
  String get proxy_fieldWireguardPrivateKey => 'Закрытый ключ';

  @override
  String get proxy_fieldWireguardPrivateKeyHelper =>
      'Хранится в защищённом хранилище, а не в JSON профиля.';

  @override
  String get proxy_fieldPreSharedKey => 'Общий ключ (PSK)';

  @override
  String get proxy_fieldPreSharedKeyHelper =>
      'Необязательно. Хранится в защищённом хранилище.';

  @override
  String get proxy_fieldMtu => 'MTU';

  @override
  String get proxy_fieldMtuHelper =>
      'Уменьшите это значение, если туннель подключается, но страницы не загружаются: пакеты, превышающие допустимый для соединения размер, отбрасываются. Значение 1280 подходит почти везде; если уже подключён другой VPN, используйте около 1200.';

  @override
  String get proxy_fieldPersistentKeepalive => 'Постоянный keepalive';

  @override
  String get proxy_fieldPersistentKeepaliveHelper =>
      'Интервал между пакетами keepalive в секундах. Телефоны часто находятся за NAT; без keepalive привязка может истечь во время простоя. Тогда пир больше не сможет связаться с телефоном, и соединения зависнут до следующего рукопожатия. Установите 0, чтобы отключить.';

  @override
  String get proxy_fieldReservedBytes => 'Зарезервированные байты';

  @override
  String get proxy_fieldReservedBytesHelper =>
      'Необязательно. Три числа через запятую, например 0,0,0.';

  @override
  String get proxy_fieldShadowTlsVersion => 'Версия';

  @override
  String proxy_fieldErrorRequired(String field) {
    return 'Поле «$field» обязательно.';
  }

  @override
  String proxy_fieldErrorNotPositiveNumber(String field) {
    return 'Поле «$field» должно быть положительным числом.';
  }

  @override
  String proxy_fieldErrorPortRange(String field) {
    return 'Поле «$field» должно быть от 1 до 65535.';
  }

  @override
  String proxy_fieldErrorListLength(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Поле «$field» должно содержать $count числа.',
      many: 'Поле «$field» должно содержать $count чисел.',
      few: 'Поле «$field» должно содержать $count числа.',
      one: 'Поле «$field» должно содержать $count число.',
    );
    return '$_temp0';
  }

  @override
  String proxy_fieldErrorNotAllNumbers(String field) {
    return 'Поле «$field» должно содержать только числа.';
  }

  @override
  String proxy_fieldErrorBelowMin(String field, int min) {
    return 'Поле «$field» должно содержать числа не меньше $min.';
  }

  @override
  String proxy_fieldErrorAboveMax(String field, int max) {
    return 'Поле «$field» должно содержать числа не больше $max.';
  }

  @override
  String proxy_fieldErrorInvalidCidr(String field, String value) {
    return 'Поле «$field» должно содержать IP-адреса, при необходимости с /префиксом. «$value» не является IP-адресом.';
  }

  @override
  String proxy_fieldErrorNotBoolean(String field) {
    return 'Поле «$field» должно быть true или false.';
  }

  @override
  String proxy_fieldErrorNotAllowedValue(String field, String values) {
    return 'Поле «$field» должно быть одним из: $values.';
  }

  @override
  String get proxy_saveErrorAlreadySaving => 'Профиль уже сохраняется.';

  @override
  String get proxy_saveErrorNameRequired => 'Требуется имя профиля.';

  @override
  String get proxy_saveErrorStillLoading =>
      'Профиль ещё загружается. Подождите.';

  @override
  String get proxy_saveErrorConfigNotJson =>
      'Конфигурация должна быть объектом JSON.';

  @override
  String get proxy_saveErrorSecretsNotJson =>
      'Секреты должны быть объектом JSON.';

  @override
  String proxy_saveErrorUnexpected(String error) {
    return 'Не удалось сохранить профиль прокси: $error';
  }

  @override
  String get proxy_loadErrorNotFound => 'Профиль прокси не найден.';

  @override
  String proxy_loadErrorFailed(String error) {
    return 'Не удалось загрузить профиль прокси: $error';
  }

  @override
  String get qrScanner_noCameraPermission =>
      'Нет разрешения на доступ к камере.';

  @override
  String get qrScanner_scanCodeTitle => 'Сканировать код';

  @override
  String get searchCredits_couldNotLoadTitle => 'Не удалось загрузить кредиты';

  @override
  String get searchCredits_title => 'Поисковые кредиты';

  @override
  String get searchCredits_errorSubtitle =>
      'Проверьте подключение и нажмите «Обновить», чтобы повторить попытку.';

  @override
  String get searchCredits_emptySubtitle =>
      'Купите поисковый пакет, чтобы начать';

  @override
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  ) {
    return 'Кредиты: $credits / $allowance  ·  Сохранённые токены: $stash';
  }

  @override
  String searchCredits_creditsNoAllowance(int credits, int stash) {
    return 'Кредиты: $credits  ·  Сохранённые токены: $stash';
  }

  @override
  String get searchCredits_tooltipRefresh => 'Обновить';

  @override
  String searchCredits_resetsOn(String date) {
    return 'Обновится $date';
  }

  @override
  String searchCredits_lastIssuance(String relative, String absolute) {
    return 'Последняя выдача: $relative  ($absolute)';
  }

  @override
  String get searchCredits_requestingTokens => 'Запрос токенов…';

  @override
  String searchCredits_issuanceFailed(String error) {
    return 'Не удалось выдать токены: $error';
  }

  @override
  String get searchCredits_needsReauth =>
      'Войдите снова, чтобы запросить токены.';

  @override
  String get searchCredits_buySearchPackTitle => 'Купить поисковый пакет';

  @override
  String get searchCredits_getTokensTitle => 'Получить токены';

  @override
  String searchCredits_requestTokensCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Запросить $count токена',
      many: 'Запросить $count токенов',
      few: 'Запросить $count токена',
      one: 'Запросить $count токен',
    );
    return '$_temp0';
  }

  @override
  String get searchCredits_noCreditsRemaining => 'Кредитов не осталось';

  @override
  String get searchCredits_buyMoreTitle => 'Купить ещё';

  @override
  String get settings_advancedTitle => 'Дополнительно';

  @override
  String get settings_advancedSubtitle =>
      'Поведение движка, переопределения во время работы и инструменты разработчика.';

  @override
  String get settings_javascriptTitle => 'Включить JavaScript';

  @override
  String get settings_javascriptKeywords => 'javascript, js, скрипты';

  @override
  String get settings_javascriptSubtitle =>
      'Отключение JavaScript может повысить безопасность, приватность и скорость, но некоторые сайты могут работать неправильно.';

  @override
  String get settings_userAgentLabel => 'Свой User Agent';

  @override
  String get settings_userAgentLabelKeywords =>
      'ua, юзер-агент, агент пользователя';

  @override
  String get settings_enterpriseRootsTitle =>
      'Использовать сторонние сертификаты ЦС';

  @override
  String get settings_enterpriseRootsKeywords =>
      'сертификаты, корневые сертификаты, ca, цс';

  @override
  String get settings_enterpriseRootsSubtitle =>
      'Разрешает использовать сторонние сертификаты из хранилища ЦС Android';

  @override
  String get settings_experimentalFeaturesTitle => 'Экспериментальные функции';

  @override
  String get settings_experimentalFeaturesKeywords =>
      'среда выполнения, запуск';

  @override
  String get settings_experimentalFeaturesSubtitle =>
      'Низкоуровневые функции среды выполнения и поведение при запуске';

  @override
  String get settings_unmountGeckoViewTitle => 'Выгружать движок вне экрана';

  @override
  String get settings_unmountGeckoViewKeywords =>
      'geckoview, память, производительность, приостановка';

  @override
  String get settings_unmountGeckoViewSubtitle =>
      'Выгружать веб-движок из памяти, пока открыт полноэкранный раздел (например, настройки, вкладки или поиск), и восстанавливать его при возврате. Это временно освобождает ресурсы. При возврате на страницу движок нужно подключить заново, что может вызвать мерцание или перезагрузку. Это экономия памяти за счёт производительности, а не способ устранить неполадки. На Android 12 и более ранних версиях движок выгружается всегда.';

  @override
  String get settings_iconCacheTitle => 'Кеш значков';

  @override
  String get settings_iconCacheKeywords => 'фавиконы, favicons, кеш';

  @override
  String get settings_iconCacheSubtitle => 'Сохранённые значки сайтов';

  @override
  String get settings_iconCacheSizeLabel => 'Размер';

  @override
  String get settings_clearingAction => 'Очистка';

  @override
  String get settings_mlDownloadsTitle => 'Загрузки ML';

  @override
  String get settings_mlDownloadsKeywords =>
      'ии, ai, ml, модели, onnx, кеш, машинное обучение';

  @override
  String get settings_mlDownloadsSubtitle =>
      'Загруженные модели ИИ и файлы среды выполнения';

  @override
  String get settings_mlDownloadsClearDialogTitle => 'Очистить загрузки ML?';

  @override
  String get settings_mlDownloadsClearDialogContent =>
      'Будут удалены загруженные модели ИИ и файлы среды выполнения ONNX для этого профиля. При необходимости они будут загружены снова. Перезапустите WebLibre, прежде чем снова использовать функции ML.';

  @override
  String get settings_mlDownloadsClearedMessage =>
      'Загрузки ML очищены. Перезапустите WebLibre перед повторной попыткой.';

  @override
  String settings_mlDownloadsClearFailedMessage(String error) {
    return 'Не удалось очистить загрузки ML: $error';
  }

  @override
  String get settings_errorLogsTitle => 'Журналы ошибок';

  @override
  String get settings_errorLogsKeywords => 'журналы, логи';

  @override
  String get settings_errorLogsSubtitle =>
      'Просмотр и копирование журналов для сообщения о проблемах';

  @override
  String get settings_dartVmTitle => 'Dart VM';

  @override
  String get settings_dartVmKeywords => 'service url, url сервиса';

  @override
  String get settings_dartVmSubtitle => 'Копировать URL-адрес сервиса Dart VM';

  @override
  String get settings_dartVmCopyErrorFallback => 'Ошибка';

  @override
  String get settings_serviceUrlCopiedMessage => 'URL-адрес сервиса скопирован';

  @override
  String get settings_resetUiTitle => 'Сбросить интерфейс';

  @override
  String get settings_resetUiKeywords => 'обновить интерфейс, перерисовать';

  @override
  String get settings_resetUiSubtitle =>
      'Полностью перестроить интерфейс браузера';

  @override
  String get settings_addonCollectionTitle => 'Своя коллекция расширений';

  @override
  String get settings_addonCollectionSourceSectionTitle => 'Источник коллекции';

  @override
  String get settings_addonCollectionConfigTitle => 'Настройка коллекции';

  @override
  String get settings_addonCollectionConfigKeywords =>
      'дополнения, расширения, коллекция';

  @override
  String get settings_addonCollectionConfigSubtitle =>
      'Сервер Mozilla, владелец и название коллекции';

  @override
  String get settings_addonCollectionServerUrlLabel => 'URL-адрес сервера';

  @override
  String get settings_addonCollectionUserLabel => 'Владелец коллекции';

  @override
  String get settings_addonCollectionNameLabel => 'Название коллекции';

  @override
  String get settings_addonCollectionActionsSectionTitle => 'Действия';

  @override
  String get settings_addonCollectionSaveRestartTitle =>
      'Сохранить и перезапустить браузер';

  @override
  String get settings_addonCollectionSaveRestartKeywords => 'перезапуск';

  @override
  String get settings_addonCollectionSaveRestartSubtitle =>
      'Применить свою коллекцию и перезапустить браузер';

  @override
  String get settings_bangSettingsTitle => 'Настройки бэнгов';

  @override
  String get settings_bangSettingsKeywords => 'ярлыки, бэнги, bangs';

  @override
  String get settings_bangSettingsSubtitle =>
      'Использование бэнгов, репозитории и синхронизация по запросу.';

  @override
  String get settings_bangFrequenciesTitle => 'Частота бэнгов';

  @override
  String get settings_bangFrequenciesKeywords => 'использование, рекомендации';

  @override
  String get settings_bangFrequenciesSubtitle =>
      'Учёт использования для рекомендаций бэнгов';

  @override
  String get settings_browsingTitle => 'Просмотр';

  @override
  String get settings_browsingSubtitle =>
      'Вкладки, навигация, ссылки на приложения и поведение малого веба.';

  @override
  String get settings_newTabDefaultTitle => 'Тип новой вкладки';

  @override
  String get settings_newTabDefaultKeywords =>
      'обычная, приватная, изолированная';

  @override
  String get settings_newTabDefaultSubtitle =>
      'Выберите тип по умолчанию для вкладок, создаваемых вручную';

  @override
  String get settings_tabTypeRegularLabel => 'Обычная';

  @override
  String get settings_tabTypePrivateLabel => 'Приватная';

  @override
  String get settings_tabTypeIsolatedLabel => 'Изолированная';

  @override
  String get settings_smallWebTabDefaultTitle => 'Тип вкладки малого веба';

  @override
  String get settings_smallWebTabDefaultKeywords =>
      'обычная, приватная, изолированная';

  @override
  String get settings_smallWebTabDefaultSubtitle =>
      'Выберите тип вкладки, используемый при входе в малый веб';

  @override
  String get settings_externalLinkHandlingTitle => 'Обработка внешних ссылок';

  @override
  String get settings_externalLinkHandlingKeywords =>
      'интенты, intents, внешние ссылки';

  @override
  String get settings_externalLinkHandlingSubtitle =>
      'Выберите, как внешние ссылки открываются в WebLibre';

  @override
  String get settings_promptOptionLabel => 'Спрашивать';

  @override
  String get settings_externalLinkPromptSubtitle =>
      'Спрашивать, как открывать внешние ссылки';

  @override
  String get settings_externalLinkRegularSubtitle =>
      'Открывать внешние ссылки в обычной вкладке';

  @override
  String get settings_externalLinkPrivateSubtitle =>
      'Открывать внешние ссылки в приватной вкладке';

  @override
  String get settings_externalLinkIsolatedSubtitle =>
      'Открывать внешние ссылки в изолированной вкладке';

  @override
  String get settings_bookmarkOpenBehaviorTitle => 'Открытие закладок';

  @override
  String get settings_bookmarkOpenBehaviorKeywords =>
      'закладки, открыть, custom tab, изолированная';

  @override
  String get settings_bookmarkOpenBehaviorSubtitle =>
      'Выберите, как открывается закладка при нажатии';

  @override
  String get settings_bookmarkOpenPromptSubtitle =>
      'Спрашивать, как открыть закладку';

  @override
  String get settings_bookmarkOpenRegularSubtitle =>
      'Открывать закладку в обычной вкладке';

  @override
  String get settings_bookmarkOpenPrivateSubtitle =>
      'Открывать закладку в приватной вкладке';

  @override
  String get settings_customTabOptionLabel => 'Custom Tab';

  @override
  String get settings_bookmarkOpenCustomTabSubtitle =>
      'Открывать закладку в облегчённой Custom Tab';

  @override
  String get settings_bookmarkOpenIsolatedSubtitle =>
      'Открывать закладку в изолированной вкладке';

  @override
  String get settings_tabListDirectionTitle => 'Порядок списка вкладок';

  @override
  String get settings_tabListDirectionKeywords => 'сортировка, порядок';

  @override
  String get settings_tabListDirectionSubtitle =>
      'Выберите, показывать ли новейшую вкладку вверху или внизу списка вкладок';

  @override
  String get settings_directionNewestFirstLabel => 'Сначала новые';

  @override
  String get settings_directionOldestFirstLabel => 'Сначала старые';

  @override
  String get settings_tabBarDirectionTitle => 'Порядок панели вкладок';

  @override
  String get settings_tabBarDirectionKeywords => 'сортировка, порядок';

  @override
  String get settings_tabBarDirectionSubtitle =>
      'Выберите, показывать ли новейшую вкладку слева или справа в быстром переключателе';

  @override
  String get settings_childTabPlacementTitle =>
      'Позиция новой дочерней вкладки';

  @override
  String get settings_childTabPlacementKeywords =>
      'дочерние вкладки, новая вкладка, позиция, порядок, конец списка, после родительской';

  @override
  String get settings_childTabPlacementSubtitle =>
      'Выберите, где размещать вкладку, открытую из другой: сразу после исходной или в конце списка. Связь с исходной вкладкой сохраняется в обоих случаях, поэтому древовидный вид не меняется.';

  @override
  String get settings_childTabAfterOpenerLabel => 'После исходной';

  @override
  String get settings_childTabAtEndLabel => 'В конце';

  @override
  String get settings_createChildTabsTitle => 'Создание дочерних вкладок';

  @override
  String get settings_createChildTabsKeywords => 'дочерние вкладки';

  @override
  String get settings_createChildTabsSubtitle =>
      'Показывать кнопку для создания дочерней вкладки под текущей (только в древовидном виде)';

  @override
  String get settings_showContainerUiTitle =>
      'Показывать интерфейс контейнеров';

  @override
  String get settings_showContainerUiKeywords => 'контейнеры';

  @override
  String get settings_showContainerUiSubtitle =>
      'Показывать выбор контейнеров, меню и управление ими';

  @override
  String get settings_showIsolatedTabUiTitle =>
      'Показывать интерфейс изолированных вкладок';

  @override
  String get settings_showIsolatedTabUiKeywords => 'изолированные вкладки';

  @override
  String get settings_showIsolatedTabUiSubtitle =>
      'Показывать в интерфейсе варианты создания изолированных вкладок';

  @override
  String get settings_backgroundTabBehaviorTitle => 'Поведение фоновых вкладок';

  @override
  String get settings_backgroundTabBehaviorKeywords =>
      'переключиться, фон, новая вкладка, уведомление, запрос';

  @override
  String get settings_backgroundTabBehaviorSubtitle =>
      'Действует, когда действие открывает новую вкладку в фоне, например «Открыть в новой вкладке» или клонирование вкладки';

  @override
  String get settings_backgroundTabPromptTitle =>
      'Остаться и предложить переход';

  @override
  String get settings_backgroundTabPromptSubtitle =>
      'Оставаться на текущей вкладке и показывать уведомление с действием «Перейти»';

  @override
  String get settings_backgroundTabSwitchTitle => 'Переходить сразу';

  @override
  String get settings_backgroundTabSwitchSubtitle =>
      'Сразу переходить на новую вкладку';

  @override
  String get settings_tabBarSwipesTitle => 'Свайпы по панели вкладок';

  @override
  String get settings_tabBarSwipesKeywords =>
      'жесты, свайп, поведение свайпов по панели вкладок';

  @override
  String get settings_tabBarSwipesSubtitle =>
      'Выберите действие каждого свайпа в разделе «Жесты»';

  @override
  String get settings_sequentialTabNavigationTitle =>
      'Последовательный переход по вкладкам';

  @override
  String get settings_sequentialTabNavigationKeywords =>
      'жесты, свайп, следующая вкладка, предыдущая вкладка, контейнеры, по кругу, зациклить';

  @override
  String get settings_sequentialTabNavigationSubtitle =>
      'Действует для свайпа по панели вкладок и жестов следующей/предыдущей вкладки';

  @override
  String get settings_continueIntoNextContainerTitle =>
      'Переходить в следующий контейнер';

  @override
  String get settings_continueIntoNextContainerSubtitle =>
      'Переход дальше первой или последней вкладки контейнера ведёт в соседний контейнер. Если выключено, навигация остаётся внутри текущего контейнера.';

  @override
  String get settings_loopAroundTitle => 'По кругу';

  @override
  String get settings_loopAroundSubtitle =>
      'Переход дальше последней вкладки продолжается с первой, и наоборот.';

  @override
  String get settings_openLinksInAppsTitle => 'Открывать ссылки в приложениях';

  @override
  String get settings_openLinksInAppsKeywords =>
      'ссылки на приложения, внешние приложения, app links';

  @override
  String get settings_openLinksInAppsSubtitle =>
      'Выберите, как обрабатываются ссылки, которые можно открыть в других приложениях';

  @override
  String get settings_appLinksAlwaysTitle => 'Всегда';

  @override
  String get settings_appLinksAlwaysSubtitle =>
      'Всегда открывать ссылки в их приложениях без вопроса';

  @override
  String get settings_appLinksAskTitle => 'Спрашивать перед открытием';

  @override
  String get settings_appLinksAskSubtitle =>
      'Показывать запрос перед открытием ссылок в приложениях';

  @override
  String get settings_appLinksNeverTitle => 'Никогда';

  @override
  String get settings_appLinksNeverSubtitle =>
      'Всегда открывать ссылки в браузере, а не в приложениях';

  @override
  String get settings_waitForAnswerTitle => 'Ждать вашего ответа';

  @override
  String get settings_waitForAnswerSubtitle =>
      'Не загружать страницу в фоне, пока показывается запрос. Сайт не получает запрос, если вы не останетесь в браузере.';

  @override
  String get settings_offerAppStoreFallbackTitle =>
      'Предлагать магазин приложений';

  @override
  String get settings_offerAppStoreFallbackSubtitle =>
      'Если ссылка ведёт в неустановленное приложение и веб-версии нет, предлагать открыть магазин приложений';

  @override
  String get settings_allowLoginAppCallbacksTitle =>
      'Разрешить приложениям получать результат входа';

  @override
  String get settings_allowLoginAppCallbacksSubtitle =>
      'Разрешить приложениям, открывшим Custom Tab, получать результат входа, даже если ссылки настроены никогда не открываться в приложениях';

  @override
  String get settings_appLinkContainerFallbackName => 'Контейнер';

  @override
  String get settings_appLinkOverrideModeAlways =>
      'Всегда открывать в приложениях';

  @override
  String get settings_appLinkOverrideModeAsk => 'Спрашивает перед открытием';

  @override
  String get settings_appLinkOverrideModeNever =>
      'Всегда оставляет ссылки в браузере';

  @override
  String get settings_appLinkContainerOverridesHeader =>
      'Контейнеры с собственными настройками ссылок на приложения';

  @override
  String settings_appLinkOverrideSummaryWithRules(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запомненного правила',
      many: '$count запомненных правил',
      few: '$count запомненных правила',
      one: '$count запомненное правило',
    );
    return '$mode · $_temp0';
  }

  @override
  String get settings_appLinkRememberedRulesHeader =>
      'Запомненные правила для сайтов';

  @override
  String get settings_appLinkRuleAlwaysOpenLabel =>
      'Всегда открывать в приложении';

  @override
  String get settings_appLinkRuleAlwaysKeepLabel =>
      'Всегда оставлять в браузере';

  @override
  String get settings_appLinkRuleRemoveTooltip => 'Удалить правило';

  @override
  String get settings_globalDesktopModeTitle =>
      'Всегда запрашивать версию для ПК';

  @override
  String get settings_globalDesktopModeKeywords =>
      'версия для компьютера, режим пк, user agent, мобильная версия, планшет';

  @override
  String get settings_globalDesktopModeSubtitle =>
      'Открывать новые вкладки в версии для ПК по умолчанию. Версию для ПК по-прежнему можно переключать для каждой вкладки в меню страницы.';

  @override
  String get settings_desktopModeSitesTitle => 'Сайты в версии для ПК';

  @override
  String get settings_desktopModeSitesKeywords =>
      'версия для пк, для отдельных сайтов, user agent, исключения';

  @override
  String get settings_desktopModeSitesSubtitle =>
      'Сайты, которые всегда загружаются в версии для ПК';

  @override
  String get settings_pullToRefreshTitle => 'Потянуть для обновления';

  @override
  String get settings_pullToRefreshKeywords => 'перезагрузка, обновить';

  @override
  String get settings_pullToRefreshSubtitle =>
      'Проведите вниз по странице, чтобы перезагрузить её';

  @override
  String get settings_customTabsTitle => 'Custom Tabs';

  @override
  String get settings_customTabsKeywords =>
      'custom tabs, встроенный браузер, chrome custom tabs, внешнее приложение, поделиться';

  @override
  String get settings_customTabsSubtitle =>
      'Разрешить другим приложениям открывать ссылки в облегчённой встроенной вкладке. Если выключено, такие ссылки и отправленные URL-адреса открываются обычными вкладками в основном браузере.';

  @override
  String get settings_doubleBackCloseTabTitle =>
      'Двойное «Назад» закрывает вкладку';

  @override
  String get settings_doubleBackCloseTabKeywords => 'кнопка назад';

  @override
  String get settings_doubleBackCloseTabSubtitle =>
      'Если включено, двойное нажатие «Назад» закрывает вкладку. Если выключено, кнопка «Назад» только перемещает по истории страницы.';

  @override
  String get settings_allowNonManifestPwaInstallTitle =>
      'Устанавливать сайты как приложения';

  @override
  String get settings_allowNonManifestPwaInstallKeywords =>
      'pwa, веб-приложения';

  @override
  String get settings_allowNonManifestPwaInstallSubtitle =>
      'Разрешить устанавливать сайты без манифеста PWA как отдельные приложения';

  @override
  String get settings_urlCleanerTitle => 'Очистка URL-адресов';

  @override
  String get settings_urlCleanerKeywords =>
      'utm, параметры отслеживания, трекинг';

  @override
  String get settings_urlCleanerSubtitle =>
      'Правила удаления отслеживания и обновления каталога';

  @override
  String get settings_unshortenerTitle => 'Разворачивание ссылок';

  @override
  String get settings_unshortenerKeywords =>
      'короткие ссылки, перенаправления, редиректы';

  @override
  String get settings_unshortenerSubtitle =>
      'Раскрытие коротких ссылок и токен API';

  @override
  String get settings_contextualToolbarSearchHint => 'Поиск кнопок панели';

  @override
  String get settings_contextualToolbarTitleDefault =>
      'Настройка панели инструментов';

  @override
  String get settings_contextualToolbarTitleQuickSwitcher =>
      'Настройка кнопок переключателя';

  @override
  String get settings_contextualToolbarResetToDefaults =>
      'Сбросить по умолчанию';

  @override
  String get settings_contextualToolbarEnabledSection => 'Включённые';

  @override
  String get settings_contextualToolbarDisabledSection => 'Выключенные';

  @override
  String get settings_contextualToolbarNoEnabledButtons =>
      'Нет включённых кнопок. Включите кнопку ниже.';

  @override
  String settings_contextualToolbarNoEnabledButtonsMatch(String query) {
    return 'Нет включённых кнопок, соответствующих «$query».';
  }

  @override
  String get settings_contextualToolbarAllButtonsEnabled =>
      'Все кнопки включены.';

  @override
  String settings_contextualToolbarNoDisabledButtonsMatch(String query) {
    return 'Нет выключенных кнопок, соответствующих «$query».';
  }

  @override
  String get settings_longPressNoneTitle => 'Нет';

  @override
  String get settings_longPressNoneDescription =>
      'По умолчанию для этой кнопки: удержание ничего не делает';

  @override
  String get settings_longPressDefaultDescription =>
      'По умолчанию для этой кнопки';

  @override
  String get settings_longPressTitle => 'Долгое нажатие';

  @override
  String get settings_longPressDescription => 'Что делает удержание кнопки';

  @override
  String get settings_fallbackGreyOutLabel => 'Затенить';

  @override
  String get settings_fallbackIfUnavailableTitle => 'Если недоступна';

  @override
  String get settings_fallbackIfUnavailableDescription =>
      'Показывается вместо этой кнопки, пока её нельзя использовать';

  @override
  String get settings_customTrackingProtectionTitle =>
      'Своя защита от отслеживания';

  @override
  String get settings_customTrackingProtectionSubtitle =>
      'Собственные настройки куки, контента, трекеров и цифровых отпечатков.';

  @override
  String get settings_fixMajorIssuesTitle =>
      'Исправлять серьёзные проблемы сайтов';

  @override
  String get settings_fixMajorIssuesSubtitle =>
      'Применять исключения, необходимые для предотвращения серьёзных поломок сайтов (рекомендуется)';

  @override
  String get settings_fixMinorIssuesTitle =>
      'Исправлять мелкие проблемы сайтов';

  @override
  String get settings_fixMinorIssuesSubtitle =>
      'Применять исключения для исправления мелких проблем и включения удобных функций';

  @override
  String get settings_blockCookiesTitle => 'Блокировать куки';

  @override
  String get settings_blockCookiesSubtitle =>
      'Блокировать куки согласно политике ниже';

  @override
  String get settings_cookiePolicyTitle => 'Политика куки';

  @override
  String get settings_cookiePolicyTotalProtectionLabel =>
      'Полная защита куки (рекомендуется)';

  @override
  String get settings_cookiePolicyCrossSiteTrackersLabel =>
      'Межсайтовые трекеры и трекеры социальных сетей';

  @override
  String get settings_cookiePolicyUnvisitedLabel => 'Непосещённые сайты';

  @override
  String get settings_cookiePolicyThirdPartyLabel => 'Все сторонние куки';

  @override
  String get settings_cookiePolicyAllCookiesLabel =>
      'Все куки (может нарушить работу сайтов)';

  @override
  String get settings_blockTrackingContentTitle =>
      'Блокировать отслеживающий контент';

  @override
  String get settings_blockTrackingContentSubtitle =>
      'Блокировать отслеживающие скрипты и ресурсы, встроенные в сайты';

  @override
  String get settings_trackingScopeApplyToTitle => 'Область применения';

  @override
  String get settings_trackingScopeAllTabsLabel => 'Все вкладки';

  @override
  String get settings_trackingScopePrivateOnlyLabel =>
      'Только приватные вкладки';

  @override
  String get settings_adsAnalyticsSocialTrackersTitle =>
      'Реклама, аналитика и социальные трекеры';

  @override
  String get settings_adsAnalyticsSocialTrackersSubtitle =>
      'Блокировать категории трекеров рекламы, аналитики, соцсетей и социальных трекеров Mozilla';

  @override
  String get settings_cryptominersTitle => 'Криптомайнеры';

  @override
  String get settings_cryptominersSubtitle =>
      'Блокировать скрипты, использующие ваше устройство для майнинга криптовалюты';

  @override
  String get settings_knownFingerprintersTitle =>
      'Известные сборщики цифровых отпечатков';

  @override
  String get settings_knownFingerprintersSubtitle =>
      'Блокировать скрипты, собирающие информацию для уникальной идентификации устройства';

  @override
  String get settings_redirectTrackersTitle => 'Трекеры перенаправлений';

  @override
  String get settings_redirectTrackersSubtitle =>
      'Блокировать трекеры, собирающие данные через промежуточные перенаправления URL-адресов';

  @override
  String get settings_suspectedFingerprintersTitle =>
      'Подозрительные сборщики цифровых отпечатков';

  @override
  String get settings_suspectedFingerprintersSubtitle =>
      'Блокировать дополнительные техники цифровых отпечатков, которые могут использоваться для отслеживания';

  @override
  String get settings_desktopModeSitesScreenTitle => 'Сайты в версии для ПК';

  @override
  String get settings_desktopModeSitesScreenDescription =>
      'Эти сайты всегда загружаются в версии для ПК, независимо от настройки по умолчанию. Поддомены включаются (например, «example.com» охватывает и «m.example.com»).';

  @override
  String get settings_desktopModeSitesEmptyLabel => 'Сайты не добавлены.';

  @override
  String get settings_dohTitle => 'DNS через HTTPS';

  @override
  String get settings_dohSubtitle =>
      'Уровень защиты зашифрованного DNS и выбор резолвера.';

  @override
  String get settings_errorLogsCopiedMessage => 'Журналы скопированы';

  @override
  String get settings_errorLogsSearchHint => 'Поиск в журнале';

  @override
  String get settings_errorLogsCopyTooltip => 'Копировать журналы';

  @override
  String get settings_errorLogsEmptyLabel => 'Журналы отсутствуют';

  @override
  String get settings_experimentalTitle => 'Экспериментальные';

  @override
  String get settings_experimentalSubtitle =>
      'Изоляция среды выполнения и поведение при запуске.';

  @override
  String get settings_isolatedContentProcessTitle =>
      'Изолированный процесс контента';

  @override
  String get settings_isolatedContentProcessKeywords =>
      'перезапуск, изоляция, процесс';

  @override
  String get settings_isolatedContentProcessSubtitle =>
      'Запускать веб-контент в изолированном процессе. Требуется перезапуск приложения.';

  @override
  String get settings_appZygoteProcessTitle => 'Процесс App Zygote';

  @override
  String get settings_appZygoteProcessKeywords => 'перезапуск, android 10';

  @override
  String get settings_appZygoteProcessSubtitle =>
      'Предзагружать сервис контента для более быстрого запуска изолированного процесса. Требуются Android 10+ и перезапуск приложения.';

  @override
  String get settings_extensionsTitle => 'Расширения';

  @override
  String get settings_extensionsSubtitle =>
      'Управление дополнениями, поведение обновлений и безопасность расширений.';

  @override
  String get settings_manageExtensionsTitle => 'Управление расширениями';

  @override
  String get settings_manageExtensionsKeywords =>
      'дополнения, расширения браузера, addons';

  @override
  String get settings_manageExtensionsSubtitle =>
      'Установленные, отключённые, доступные и неподдерживаемые расширения';

  @override
  String get settings_customCollectionTitle => 'Своя коллекция';

  @override
  String get settings_customCollectionKeywords => 'дополнения, addons';

  @override
  String get settings_customCollectionSubtitle =>
      'Использовать собственную коллекцию дополнений Mozilla';

  @override
  String get settings_automaticUpdatesTitle => 'Автоматические обновления';

  @override
  String get settings_automaticUpdatesKeywords =>
      'дополнения, расширения, addons';

  @override
  String get settings_automaticUpdatesSubtitle =>
      'Автоматически проверять и устанавливать обновления расширений каждые 12 часов';

  @override
  String settings_failedToLoadMessage(String error) {
    return 'Не удалось загрузить: $error';
  }

  @override
  String get settings_allowUnsignedExtensionsTitle =>
      'Разрешить неподписанные расширения';

  @override
  String get settings_allowUnsignedExtensionsKeywords => 'дополнения, addons';

  @override
  String get settings_allowUnsignedExtensionsSubtitle =>
      'Неподписанные расширения не проверены Mozilla';

  @override
  String get settings_allowUnsignedWarningText =>
      'Устанавливайте неподписанные расширения только из надёжных источников. Они могут содержать вредоносный код.';

  @override
  String get settings_allowUnsignedConfirmDialogTitle =>
      'Разрешить неподписанные расширения?';

  @override
  String get settings_allowUnsignedConfirmWarningBold =>
      'Внимание: это значительно ослабляет безопасность браузера.';

  @override
  String get settings_allowUnsignedConfirmBody =>
      'Неподписанные расширения обходят проверку безопасности Mozilla. Вредоносные расширения могут:\n\n• Читать и изменять всё, что вы видите на любом сайте\n• Похищать пароли, банковские и личные данные\n• Незаметно следить за вашими действиями в браузере\n• Устанавливать на устройство другое вредоносное ПО';

  @override
  String get settings_allowUnsignedConfirmFooter =>
      'Включайте это, только если вы разработчик, устанавливающий собственное расширение, или полностью доверяете источнику.';

  @override
  String get settings_allowAction => 'Разрешить';

  @override
  String settings_allowActionCountdown(int seconds) {
    return 'Разрешить ($seconds)';
  }

  @override
  String get settings_fingerprintProtectionTitle =>
      'Защита от цифровых отпечатков';

  @override
  String get settings_fingerprintProtectionKeywords =>
      'приватность, фингерпринтинг, отпечаток';

  @override
  String get settings_fingerprintSearchHint => 'Поиск мер защиты от отпечатков';

  @override
  String get settings_loadDefaultsAction => 'Загрузить по умолчанию';

  @override
  String get settings_loadHardenedDefaultsAction =>
      'Загрузить усиленные по умолчанию';

  @override
  String get settings_fingerprintOverrideTargetsSection => 'Меры защиты';

  @override
  String get settings_fingerprintInvalidOverride =>
      'Сохранённые переопределения отпечатков имеют недопустимый формат';

  @override
  String get settings_fingerprintUnknownTarget =>
      'Сохранённые переопределения отпечатков указывают меру защиты, неизвестную этой версии';

  @override
  String get settings_homeAndNewTabTitle => 'Домашняя страница и новая вкладка';

  @override
  String get settings_homeAndNewTabSubtitle =>
      'Что показывают домашняя страница и новая вкладка';

  @override
  String get settings_addressFieldLabel => 'Адрес';

  @override
  String get settings_homeTargetUrlEmptyError =>
      'Введите адрес, иначе будет показана домашняя страница';

  @override
  String get settings_homeTargetUrlInvalidError => 'Недопустимый адрес';

  @override
  String get settings_applyWhenLastTabClosesTitle =>
      'Применять при закрытии последней вкладки';

  @override
  String get settings_applyWhenLastTabClosesKeywords =>
      'закрыть, последняя вкладка, контейнер';

  @override
  String get settings_applyWhenLastTabClosesSubtitle =>
      'При закрытии последней вкладки в контейнере оставаться в нём, а не открывать вкладку из другого места';

  @override
  String settings_homeSearchBarCurrentlyLabel(String value) {
    return 'Сейчас: $value';
  }

  @override
  String get settings_wallpaperTitle => 'Обои';

  @override
  String get settings_wallpaperKeywords =>
      'обои, фон, изображение, фото, картинка, размытие, затемнение, домашняя';

  @override
  String get settings_wallpaperSetSubtitle =>
      'Для домашней страницы задано фоновое изображение';

  @override
  String get settings_wallpaperUnsetSubtitle =>
      'Задать фоновое изображение для домашней страницы';

  @override
  String get settings_customizeHomeSectionsTitle =>
      'Настроить разделы домашней страницы';

  @override
  String get settings_customizeHomeSectionsKeywords =>
      'домашняя, разделы, ярлыки, цитата, быстрые действия, порядок';

  @override
  String get settings_customizeHomeSectionsSubtitle =>
      'Выберите, что показывает домашняя страница и в каком порядке';

  @override
  String get settings_customizeNewTabSectionsTitle =>
      'Настроить разделы новой вкладки';

  @override
  String get settings_customizeNewTabSectionsKeywords =>
      'новая вкладка, разделы, ярлыки, порядок';

  @override
  String get settings_customizeNewTabSectionsSubtitle =>
      'Выберите, что показывает новая вкладка и в каком порядке';

  @override
  String get settings_browserLanguagesTitle => 'Языки браузера';

  @override
  String get settings_browserLanguagesKeywords => 'локаль, язык, locale';

  @override
  String get settings_browserLanguagesSearchHint => 'Поиск локалей по тегу';

  @override
  String get settings_languageRegionSettingsSection => 'Язык и регион';

  @override
  String get settings_browserLanguagePreferenceLabel =>
      'Языковое предпочтение браузера';

  @override
  String get settings_customLocaleSection => 'Своя локаль';

  @override
  String get settings_addCustomLocaleTitle => 'Добавить свою локаль';

  @override
  String get settings_addCustomLocaleKeywords => 'тег локали, locale';

  @override
  String get settings_addCustomLocaleSubtitle =>
      'Введите тег локали, например en-US';

  @override
  String get settings_customLocaleFieldLabel => 'Своя локаль';

  @override
  String get settings_invalidLocaleError => 'Недопустимый идентификатор локали';

  @override
  String get settings_homeTargetHomeLabel => 'Домашняя страница';

  @override
  String get settings_homeTargetResumeLastTabLabel =>
      'Последняя открытая вкладка';

  @override
  String get settings_homeTargetCustomUrlLabel => 'Свой адрес';

  @override
  String get settings_homeTargetHomeDescription =>
      'Показывать ярлыки и выбранные разделы';

  @override
  String get settings_homeTargetResumeLastTabDescription =>
      'Продолжить с того места, где вы остановились';

  @override
  String get settings_homeTargetCustomUrlDescription =>
      'Открывать определённую страницу';

  @override
  String get settings_homeSearchBarAutoLabel => 'Как у панели вкладок';

  @override
  String get settings_homeSearchBarTopLabel => 'Вверху домашней страницы';

  @override
  String get settings_homeSearchBarTabBarLabel => 'В панели вкладок';

  @override
  String get settings_homeSearchBarAutoDescription =>
      'У того края, где находится панель вкладок';

  @override
  String get settings_homeSearchBarTopDescription =>
      'Закреплённая строка поиска над разделами домашней страницы';

  @override
  String get settings_homeSearchBarTabBarDescription =>
      'Адресная строка панели вкладок с QR- и голосовым поиском';

  @override
  String get settings_generalTitle => 'Общие';

  @override
  String get settings_generalSubtitle =>
      'Внешний вид, загрузки и параметры браузера по умолчанию.';

  @override
  String get settings_defaultBrowserTileTitle => 'Браузер по умолчанию';

  @override
  String get settings_defaultBrowserTileKeywords => 'системный браузер';

  @override
  String get settings_defaultBrowserTileSubtitleSet =>
      'WebLibre — ваш браузер по умолчанию';

  @override
  String get settings_defaultBrowserTileSubtitleNotSet =>
      'Сделать WebLibre браузером по умолчанию';

  @override
  String get settings_defaultBrowserButtonDefault => 'По умолч.';

  @override
  String get settings_defaultBrowserButtonSet => 'Сделать';

  @override
  String get settings_backupProfileTitle => 'Создать резервную копию профиля';

  @override
  String get settings_backupProfileKeywords =>
      'резервная копия, бэкап, архив, экспорт, сохранить, зашифрованный, восстановить';

  @override
  String settings_backupProfileSubtitleReady(String name) {
    return 'Записать «$name» в зашифрованный файл резервной копии';
  }

  @override
  String get settings_backupProfileSubtitleError =>
      'Не удалось прочитать активный профиль';

  @override
  String get settings_settingsTransferTileTitle => 'Экспорт и импорт настроек';

  @override
  String get settings_settingsTransferTileKeywords =>
      'экспорт, импорт, настройки, перенос, поделиться, буфер обмена, json, копировать, миграция';

  @override
  String get settings_settingsTransferTileSubtitle =>
      'Записать настройки в файл или буфер обмена и прочитать их обратно';

  @override
  String get settings_uiZoomTitle => 'Масштаб интерфейса';

  @override
  String get settings_uiZoomKeywords => 'масштаб, размер интерфейса, zoom';

  @override
  String get settings_uiZoomSubtitle => 'Сделать интерфейс меньше или больше';

  @override
  String get settings_disableAnimationsTitle => 'Отключить анимации';

  @override
  String get settings_disableAnimationsKeywords => 'движение, анимация';

  @override
  String get settings_disableAnimationsSubtitle =>
      'Уменьшить движение и отключить анимации приложения';

  @override
  String get settings_showModalBarrierTitle => 'Затемнять фон окон';

  @override
  String get settings_showModalBarrierKeywords =>
      'диалоги, нижние панели, наложение';

  @override
  String get settings_showModalBarrierSubtitle =>
      'Затемнять фон за диалогами и нижними панелями';

  @override
  String get settings_showSearchCloseButtonTitle =>
      'Показывать кнопку закрытия';

  @override
  String get settings_showSearchCloseButtonKeywords =>
      'назад, закрыть, скрыть, e-ink, eink, электронные чернила, доступность, новая вкладка';

  @override
  String get settings_showSearchCloseButtonSubtitle =>
      'Добавить кнопку, закрывающую страницу поиска или новой вкладки без жеста «Назад». Полезно на устройствах без кнопки «Назад».';

  @override
  String get settings_pureBlackTitle => 'Чистый чёрный (OLED)';

  @override
  String get settings_pureBlackKeywords =>
      'oled, amoled, высокий контраст, чёрный, тёмный';

  @override
  String get settings_pureBlackSubtitle =>
      'Использовать чисто чёрный фон в тёмной теме для экономии энергии на OLED-экранах';

  @override
  String get settings_themeTitle => 'Тема';

  @override
  String get settings_themeKeywords => 'светлая, тёмная, режим темы';

  @override
  String get settings_themeModeSystem => 'Системная';

  @override
  String get settings_themeModeLight => 'Светлая';

  @override
  String get settings_themeModeDark => 'Тёмная';

  @override
  String get settings_appLanguageSystemDefault => 'Как в системе';

  @override
  String settings_appLanguageCurrentlyLabel(String language) {
    return 'Сейчас: $language';
  }

  @override
  String get settings_appLanguageTranslationsNote =>
      'Переводы новые и могут быть неполными или неточными, поэтому WebLibre использует английский, пока вы не выберете другой язык. Выберите «Как в системе», чтобы использовать язык устройства.';

  @override
  String get settings_refreshRateTitle => 'Частота обновления';

  @override
  String get settings_refreshRateKeywords =>
      'fps, гц, герц, частота кадров, 60 гц, 90 гц, 120 гц, плавность, высокая частота, режим экрана';

  @override
  String get settings_refreshRateSubtitle =>
      'Выберите «Высокая» для самой плавной прокрутки и анимаций на экранах 90/120 Гц или «Низкая» для экономии заряда.';

  @override
  String get settings_refreshRateModeSystem => 'Системная';

  @override
  String get settings_refreshRateModeHigh => 'Высокая';

  @override
  String get settings_refreshRateModeLow => 'Низкая';

  @override
  String get settings_downloadFolderTitle => 'Папка загрузок';

  @override
  String get settings_downloadFolderKeywords =>
      'загрузки, папка, каталог, хранилище, сохранение';

  @override
  String get settings_downloadFolderSubtitleDefault =>
      'Сохранение в системную папку «Загрузки»';

  @override
  String settings_downloadFolderSubtitleUnavailable(String folderName) {
    return 'Больше недоступна — сохранение в системную папку «Загрузки» ($folderName)';
  }

  @override
  String get settings_downloadFolderSubtitleExternalManager =>
      'Место сохранения файлов выбирает менеджер загрузок';

  @override
  String get settings_downloadFolderResetTooltip =>
      'Использовать системную папку «Загрузки»';

  @override
  String get settings_externalDownloadManagerTitle =>
      'Внешний менеджер загрузок';

  @override
  String get settings_externalDownloadManagerKeywords => 'загрузки, скачивания';

  @override
  String get settings_externalDownloadManagerSubtitle =>
      'Управлять загрузками с помощью другого приложения';

  @override
  String get settings_preferredDownloadManagerTitle =>
      'Предпочтительный менеджер загрузок';

  @override
  String get settings_preferredDownloadManagerKeywords =>
      'загрузки, менеджер загрузок, всегда использовать, приложение по умолчанию, выбор, спрашивать';

  @override
  String get settings_preferredDownloadManagerSubtitleNotSet =>
      'Не задан — отметьте «Всегда использовать это приложение», когда в следующий раз появится окно выбора';

  @override
  String settings_preferredDownloadManagerSubtitleThisApp(String appName) {
    return '$appName, с подтверждением перед каждой загрузкой';
  }

  @override
  String settings_preferredDownloadManagerSubtitleUnavailable(
    String packageName,
  ) {
    return 'Больше не установлен ($packageName) — спрашивать каждый раз';
  }

  @override
  String get settings_preferredDownloadManagerSubtitleExternalOff =>
      'Не задан — используется только с внешним менеджером загрузок';

  @override
  String settings_preferredDownloadManagerSubtitleInactive(String appName) {
    return '$appName — не используется, пока внешний менеджер загрузок выключен';
  }

  @override
  String get settings_preferredDownloadManagerClearTooltip =>
      'Сбросить предпочтительный менеджер';

  @override
  String get settings_defaultBrowserSectionTitle => 'Браузер по умолчанию';

  @override
  String get settings_defaultBrowserSectionKeywords => 'браузер по умолчанию';

  @override
  String get settings_indexDefaultBrowserSubtitle =>
      'Сделать WebLibre браузером по умолчанию';

  @override
  String get settings_appearanceSectionTitle => 'Внешний вид';

  @override
  String get settings_indexThemeSubtitle =>
      'Выбор системной, светлой или тёмной темы';

  @override
  String get settings_indexAppLanguageTitle => 'Язык приложения';

  @override
  String get settings_indexAppLanguageKeywords =>
      'локаль, перевод, язык интерфейса, русский';

  @override
  String get settings_indexAppLanguageSubtitle =>
      'Выбор языка собственного интерфейса WebLibre';

  @override
  String get settings_indexRefreshRateSubtitle =>
      'Запрашивать высокую или низкую частоту обновления экрана (Android)';

  @override
  String get settings_indexShowCloseButtonSubtitle =>
      'Добавить кнопку, закрывающую страницу поиска / новой вкладки без жеста «Назад»';

  @override
  String get settings_profileSectionTitle => 'Профиль';

  @override
  String get settings_profileSectionKeywords => 'пользователь, профиль';

  @override
  String get settings_indexBackupProfileSubtitle =>
      'Создать зашифрованную резервную копию используемого профиля';

  @override
  String get settings_indexSettingsTransferSubtitle =>
      'Перенести настройки между профилями или устройствами либо приложить их к сообщению об ошибке';

  @override
  String get settings_downloadsSectionTitle => 'Загрузки';

  @override
  String get settings_indexDownloadFolderSubtitle =>
      'Выбор места сохранения загруженных файлов';

  @override
  String get settings_indexPreferredDownloadManagerSubtitle =>
      'Приложение, в которое загрузки передаются без вопроса';

  @override
  String get settings_contentIdentitySectionTitle => 'Контент и идентификация';

  @override
  String get settings_contentIdentitySectionKeywords => 'движок';

  @override
  String get settings_indexJavascriptSubtitle =>
      'Включить или выключить скрипты на сайтах';

  @override
  String get settings_indexUserAgentSubtitle =>
      'Переопределить строку user agent браузера';

  @override
  String get settings_indexEnterpriseRootsSubtitle =>
      'Разрешить сертификаты из хранилища ЦС Android';

  @override
  String get settings_experimentalSectionTitle => 'Экспериментальные';

  @override
  String get settings_developerToolsSectionTitle => 'Инструменты разработчика';

  @override
  String get settings_developerToolsSectionKeywords => 'отладка, debug';

  @override
  String get settings_indexUnmountGeckoViewSubtitle =>
      'Перестраивать веб-движок после наложения, а не держать его в памяти';

  @override
  String get settings_tabsSectionTitle => 'Вкладки';

  @override
  String get settings_indexTabListDirectionSubtitle =>
      'Выбор порядка вкладок в виде списка';

  @override
  String get settings_indexTabBarDirectionSubtitle =>
      'Выбор порядка вкладок на панели вкладок';

  @override
  String get settings_indexChildTabPlacementSubtitle =>
      'Выбор места вставки вкладок, открытых из другой вкладки';

  @override
  String get settings_indexCreateChildTabsSubtitle =>
      'Показывать кнопку, добавляющую дочернюю вкладку под текущей';

  @override
  String get settings_indexBackgroundTabBehaviorSubtitle =>
      'Выбор действия после открытия вкладки в фоне';

  @override
  String get settings_navigationSectionTitle => 'Навигация';

  @override
  String get settings_indexDoubleBackCloseTabSubtitle =>
      'Закрывать текущую вкладку двумя нажатиями «Назад»';

  @override
  String get settings_indexTabBarSwipesSubtitle =>
      'Выбор действий свайпов по панели вкладок';

  @override
  String get settings_indexSequentialTabNavigationSubtitle =>
      'Выбор того, где заканчивается последовательный переход по вкладкам';

  @override
  String get settings_indexOpenLinksInAppsSubtitle =>
      'Выбор способа открытия ссылок на внешние приложения';

  @override
  String get settings_desktopModeSectionTitle => 'Версия для ПК';

  @override
  String get settings_indexGlobalDesktopModeSubtitle =>
      'Открывать новые вкладки в версии для ПК по умолчанию';

  @override
  String get settings_homeScreenSectionTitle => 'Главный экран';

  @override
  String get settings_indexAllowNonManifestPwaInstallSubtitle =>
      'Разрешить устанавливать сайты без манифеста как приложения';

  @override
  String get settings_externalLinksSectionTitle => 'Внешние ссылки';

  @override
  String get settings_indexCustomTabsSubtitle =>
      'Разрешить другим приложениям открывать ссылки в облегчённой встроенной вкладке вместо основного браузера';

  @override
  String get settings_bookmarksSectionTitle => 'Закладки';

  @override
  String get settings_resolverSettingsSectionTitle => 'Настройки резолвера';

  @override
  String get settings_indexDnsOverHttpsResolverTitle => 'DNS через HTTPS';

  @override
  String get settings_indexDnsOverHttpsResolverKeywords =>
      'doh, резолвер, dns-провайдер, свой резолвер';

  @override
  String get settings_indexDnsOverHttpsResolverSubtitle =>
      'Уровень защиты, выбор провайдера и сохранённые свои резолверы';

  @override
  String get settings_runtimeStartupSectionTitle => 'Среда выполнения и запуск';

  @override
  String get settings_indexIsolatedContentProcessSubtitle =>
      'Запускать веб-контент в изолированном процессе';

  @override
  String get settings_indexAppZygoteProcessSubtitle =>
      'Предзагружать сервис контента для быстрого запуска изолированного процесса';

  @override
  String get settings_startupSectionTitle => 'Запуск';

  @override
  String get settings_startupSectionKeywords =>
      'запуск, домашняя, продолжить, последняя вкладка, свой url';

  @override
  String get settings_indexHomeTargetTitle => 'Когда нет вкладки для показа';

  @override
  String get settings_indexHomeTargetKeywords =>
      'запуск, продолжить, последняя вкладка, свой url, домашняя страница';

  @override
  String get settings_indexHomeTargetSubtitle =>
      'При запуске и после закрытия последней вкладки';

  @override
  String get settings_indexHomeTargetOnLastTabClosedSubtitle =>
      'Иначе вместо этого открывается вкладка из другого контейнера';

  @override
  String get settings_homeAppearanceSectionTitle => 'Внешний вид';

  @override
  String get settings_homeAppearanceSectionKeywords =>
      'домашняя, обои, фон, изображение, размытие, затемнение';

  @override
  String get settings_indexWallpaperSubtitle =>
      'Фоновое изображение для домашней страницы';

  @override
  String get settings_layoutSectionTitle => 'Макет';

  @override
  String get settings_layoutSectionKeywords =>
      'домашняя, новая вкладка, разделы, модули, макет';

  @override
  String get settings_indexHomeSearchBarPlacementTitle =>
      'Положение строки поиска';

  @override
  String get settings_indexHomeSearchBarPlacementKeywords =>
      'поиск, строка, положение, адрес, url, вверху, внизу, панель вкладок, домашняя';

  @override
  String get settings_indexHomeSearchBarPlacementSubtitle =>
      'Где на домашней странице находится поле поиска';

  @override
  String get settings_allowlistExceptionsSectionTitle =>
      'Исключения из списка разрешённых';

  @override
  String get settings_indexAllowlistExceptionsTitle =>
      'Исключения из списка разрешённых';

  @override
  String get settings_indexAllowlistExceptionsSubtitle =>
      'Исключения для совместимости при серьёзных и мелких проблемах сайтов';

  @override
  String get settings_cookiesSectionTitle => 'Куки';

  @override
  String get settings_indexCookiesSubtitle =>
      'Режим блокировки куки и выбор политики';

  @override
  String get settings_trackingContentSectionTitle => 'Отслеживающий контент';

  @override
  String get settings_indexTrackingContentTitle => 'Отслеживающий контент';

  @override
  String get settings_indexTrackingContentSubtitle =>
      'Отслеживающие скрипты и область блокировки';

  @override
  String get settings_trackersSectionTitle => 'Трекеры';

  @override
  String get settings_indexTrackersSubtitle =>
      'Криптомайнеры, известные сборщики отпечатков и трекеры перенаправлений';

  @override
  String get settings_advancedFingerprintingProtectionSectionTitle =>
      'Расширенная защита от цифровых отпечатков';

  @override
  String get settings_indexAdvancedFingerprintingProtectionTitle =>
      'Расширенная защита от цифровых отпечатков';

  @override
  String get settings_indexAdvancedFingerprintingProtectionSubtitle =>
      'Подозрительные сборщики отпечатков и область действия';

  @override
  String get settings_usageDataSectionTitle => 'Данные использования';

  @override
  String get settings_repositoriesSectionTitle => 'Репозитории';

  @override
  String get settings_indexGeneralBangsSubtitle =>
      'Синхронизация с GitHub по запросу';

  @override
  String get settings_generalBangsTileTitle => 'Общие бэнги';

  @override
  String get settings_generalBangsTileKeywords => 'репозиторий';

  @override
  String get settings_generalBangsTileSubtitle =>
      'Синхронизация с GitHub по запросу';

  @override
  String get settings_indexKagiBangsSubtitle =>
      'Синхронизация с GitHub по запросу';

  @override
  String get settings_kagiBangsTileTitle => 'Бэнги Kagi';

  @override
  String get settings_kagiBangsTileKeywords => 'репозиторий';

  @override
  String get settings_kagiBangsTileSubtitle =>
      'Синхронизация с GitHub по запросу';

  @override
  String get settings_extensionsSectionTitle => 'Расширения';

  @override
  String get settings_updatesSectionTitle => 'Обновления';

  @override
  String get settings_securitySectionTitle => 'Безопасность';

  @override
  String get settings_actionResetToDefaults => 'Сбросить по умолчанию';

  @override
  String get settings_menuLayoutTitle => 'Настройка меню';

  @override
  String get settings_menuLayoutHintSections =>
      'Перетаскивайте, чтобы изменить порядок. Выключите раздел, чтобы скрыть его из меню.';

  @override
  String get settings_menuLayoutHintSectionItems =>
      'Перетаскивайте, чтобы изменить порядок строк в этом разделе.';

  @override
  String get settings_menuLayoutHintSubItems =>
      'Перетаскивайте, чтобы изменить порядок строк, открываемых этим пунктом.';

  @override
  String get settings_moduleSurfaceHint =>
      'Перетаскивайте, чтобы изменить порядок. Выключите раздел, чтобы скрыть его здесь, не затрагивая другую страницу.';

  @override
  String get settings_moduleSurfaceTitleHome => 'Настройка домашней страницы';

  @override
  String get settings_moduleSurfaceTitleNewTab => 'Настройка новой вкладки';

  @override
  String get settings_homeSearchBarRowTitle => 'Строка поиска';

  @override
  String get settings_proxyTitle => 'Прокси';

  @override
  String get settings_proxySubtitle =>
      'Управление прокси-подключениями и выбор вкладок, которые их используют.';

  @override
  String get settings_proxyConnectionsTitle => 'Прокси-подключения';

  @override
  String get settings_proxyConnectionsKeywords =>
      'sing-box, socks, vpn, впн, wireguard, tor, onion, мосты, obfs4, snowflake';

  @override
  String get settings_proxyConnectionsSubtitle =>
      'Управление профилями прокси и подключениями';

  @override
  String get settings_proxyRoutingTitle => 'Маршрутизация прокси';

  @override
  String get settings_proxyRoutingKeywords =>
      'маршрутизация, маршрут, контейнер';

  @override
  String get settings_proxyRoutingSubtitle =>
      'Выберите, через какой прокси идут обычные и приватные вкладки';

  @override
  String get settings_proxyLogsTitle => 'Журналы прокси';

  @override
  String get settings_proxyLogsKeywords =>
      'журнал, журналирование, логи, диагностика, отладка, debug, trace, подробно, устранение неполадок, уровень';

  @override
  String get settings_toolbarLayoutTitle => 'Панель инструментов и макет';

  @override
  String get settings_toolbarLayoutSearchHint =>
      'Поиск настроек панели инструментов и макета';

  @override
  String get settings_privacySecurityTitle => 'Приватность и безопасность';

  @override
  String get settings_privacySecuritySubtitle =>
      'Защита от отслеживания, цифровые отпечатки, данные просмотра и усиление защиты сети.';

  @override
  String get settings_trackingProtectionExceptionsTitle =>
      'Исключения защиты от отслеживания';

  @override
  String get settings_trackingProtectionExceptionsKeywords => 'исключения';

  @override
  String get settings_trackingProtectionExceptionsTileSubtitle =>
      'Сайты, на которых защита от отслеживания отключена';

  @override
  String get settings_autoDeleteBrowsingDataTitle =>
      'Автоматическое удаление данных просмотра';

  @override
  String get settings_autoDeleteBrowsingDataKeywords =>
      'инкогнито, приватный режим, выход, закрыть, удалить при выходе, очистка данных, incognito, quit';

  @override
  String get settings_autoDeleteBrowsingDataSubtitle =>
      'Удалять выбранные данные просмотра при выходе или при каждом запуске WebLibre';

  @override
  String get settings_autoDeleteBrowsingDataQuitOnlySubtitle =>
      'Удалять выбранные данные просмотра при выходе из WebLibre';

  @override
  String get settings_autoDeleteOnStartTitle => 'Удалять также при запуске';

  @override
  String get settings_autoDeleteOnStartSubtitle =>
      'Охватывает сеансы, завершённые без «Выйти» — например, если WebLibre смахнули из списка недавних приложений или Android закрыл его в фоне. Если выключено, их данные сохраняются до следующего выхода.';

  @override
  String get settings_confirmBeforeQuitTitle => 'Подтверждать выход';

  @override
  String get settings_confirmBeforeQuitKeywords =>
      'выход, выйти, закрыть, подтверждение, диалог, больше не спрашивать, quit, exit';

  @override
  String get settings_confirmBeforeQuitSubtitle =>
      'Спрашивать, прежде чем «Выйти» закроет WebLibre. Долгое нажатие на «Выйти» пропускает вопрос.';

  @override
  String get settings_trackingProtectionExceptionsSearchHint =>
      'Поиск URL-адресов исключений';

  @override
  String get settings_trackingProtectionExceptionsDeleteAll => 'Удалить все';

  @override
  String get settings_trackingProtectionExceptionsSectionTitle =>
      'Список исключений';

  @override
  String get settings_trackingProtectionExceptionsEntrySubtitle =>
      'Сайт с отключённой защитой от отслеживания';

  @override
  String get settings_trackingProtectionExceptionsRemoveTooltip =>
      'Удалить исключение';

  @override
  String get settings_trackingProtectionExceptionsEmptyTitle =>
      'Исключений нет';

  @override
  String get settings_trackingProtectionExceptionsEmptySubtitle =>
      'Здесь появятся сайты, добавленные в исключения';

  @override
  String get settings_trackingProtectionExceptionsErrorTitle =>
      'Ошибка загрузки исключений';

  @override
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error) {
    return 'Не удалось удалить исключения: $error';
  }

  @override
  String settings_trackingProtectionExceptionsRemoveFailed(String error) {
    return 'Не удалось удалить исключение: $error';
  }

  @override
  String get settings_deleteBrowsingDataTileTitle =>
      'Удаление данных просмотра';

  @override
  String get settings_deleteBrowsingDataTileKeywords =>
      'очистить данные, удалить данные';

  @override
  String get settings_autoClearHistoryTitle => 'Автоочистка истории';

  @override
  String get settings_autoClearHistoryKeywords => 'хранение истории';

  @override
  String get settings_autoClearHistorySubtitle =>
      'Автоматически удалять историю просмотра старше выбранного периода';

  @override
  String get settings_autoClearUnassignedTabsTitle =>
      'Автоочистка вкладок без контейнера';

  @override
  String get settings_autoClearUnassignedTabsKeywords => 'очистка вкладок';

  @override
  String get settings_autoClearUnassignedTabsSubtitle =>
      'Автоматически закрывать вкладки без контейнера старше выбранного периода';

  @override
  String get settings_durationNever => 'Никогда';

  @override
  String get settings_duration1Day => '1 день';

  @override
  String get settings_duration3Days => '3 дня';

  @override
  String get settings_duration1Week => '1 неделя';

  @override
  String get settings_duration2Weeks => '2 недели';

  @override
  String get settings_duration1Month => '1 месяц';

  @override
  String get settings_duration3Months => '3 месяца';

  @override
  String get settings_globalPrivacyControlTitle =>
      'Global Privacy Control (GPC)';

  @override
  String get settings_globalPrivacyControlKeywords =>
      'gpc, не продавать данные';

  @override
  String get settings_screenshotProtectionTitle => 'Защита от снимков экрана';

  @override
  String get settings_screenshotProtectionKeywords =>
      'снимки экрана, скриншоты';

  @override
  String get settings_screenshotProtectionSubtitle =>
      'Блокирует снимки и запись экрана для этого приложения на Android.';

  @override
  String get settings_allowPrivateTabScreenshotsTitle =>
      'Разрешить снимки экрана в приватных вкладках';

  @override
  String get settings_allowPrivateTabScreenshotsKeywords =>
      'снимки экрана, скриншоты, инкогнито, приватные';

  @override
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle =>
      'Переопределено защитой от снимков экрана, которая блокирует захват во всех вкладках.';

  @override
  String get settings_allowPrivateTabScreenshotsSubtitle =>
      'Приватные вкладки можно снимать и записывать, и они видны в превью переключателя приложений.';

  @override
  String get settings_httpsOnlyModeTitle =>
      'Блокировать незащищённые HTTP-соединения';

  @override
  String get settings_httpsOnlyModeKeywords => 'только https, https only';

  @override
  String get settings_httpsOnlyModeDisabledLabel => 'Выкл.';

  @override
  String get settings_httpsOnlyModeEnabledLabel => 'Вкл.';

  @override
  String get settings_httpsOnlyModePrivateOnlyLabel => 'Только приватные';

  @override
  String get settings_dnsOverHttpsTileTitle => 'DNS через HTTPS';

  @override
  String get settings_enhancedTrackingProtectionTitle =>
      'Улучшенная защита от отслеживания';

  @override
  String get settings_enhancedTrackingProtectionKeywords =>
      'etp, стандартная, строгая, своя';

  @override
  String get settings_trackingProtectionDisabledLabel => 'Отключена';

  @override
  String get settings_trackingProtectionStandardLabel => 'Стандартная';

  @override
  String get settings_trackingProtectionStandardSubtitle =>
      'Обеспечивает баланс защиты и совместимости, блокируя меньше категорий трекеров.';

  @override
  String get settings_trackingProtectionStrictLabel => 'Строгая';

  @override
  String get settings_trackingProtectionStrictSubtitle =>
      'Блокирует больше категорий трекеров, включая отслеживающий контент, но может нарушить работу некоторых сайтов.';

  @override
  String get settings_trackingProtectionCustomLabel => 'Своя';

  @override
  String get settings_trackingProtectionCustomSubtitle =>
      'Выберите, какие трекеры и скрипты блокировать.';

  @override
  String get settings_contentBlockingDatabaseTitle =>
      'База блокировки контента';

  @override
  String get settings_contentBlockingDatabaseKeywords =>
      'реклама, трекеры, блокировка контента';

  @override
  String get settings_contentBlockingDatabaseSubtitle =>
      'Использовать списки блокировки GeckoView для категорий ETP, таких как реклама, аналитика и социальные трекеры. Требуется перезапуск приложения.';

  @override
  String get settings_bounceTrackingProtectionTitle =>
      'Защита от отскакивающего отслеживания';

  @override
  String get settings_bounceTrackingProtectionKeywords =>
      'трекеры перенаправлений, bounce tracking';

  @override
  String get settings_bounceTrackingProtectionSubtitle =>
      'Блокирует трекеры, собирающие данные через промежуточные перенаправления между сайтами';

  @override
  String get settings_queryParameterStrippingTitle =>
      'Удаление параметров запроса';

  @override
  String get settings_queryParameterStrippingKeywords =>
      'utm, параметры отслеживания';

  @override
  String get settings_queryParameterStrippingSubtitle =>
      'Удаляет параметры отслеживания из URL-адресов, чтобы предотвратить межсайтовое отслеживание';

  @override
  String get settings_queryParameterStrippingDisabledLabel => 'Выкл.';

  @override
  String get settings_queryParameterStrippingEnabledLabel => 'Вкл.';

  @override
  String get settings_queryParameterStrippingPrivateOnlyLabel =>
      'Только приватные';

  @override
  String get settings_uBlockFilterListsTileTitle =>
      'Списки фильтров uBlock и усиление защиты';

  @override
  String get settings_uBlockFilterListsTileKeywords =>
      'ublock, фильтры, блокировщик рекламы';

  @override
  String get settings_uBlockFilterListsTileSubtitle =>
      'Управление списками фильтров и применение усиленной защиты WebLibre';

  @override
  String get settings_fissionEnabledTitle => 'Fission (изоляция сайтов)';

  @override
  String get settings_fissionEnabledKeywords => 'изоляция сайтов';

  @override
  String get settings_fissionEnabledSubtitle =>
      'Изолирует каждый сайт в отдельном процессе ОС для повышения безопасности. Требуется перезапуск приложения.';

  @override
  String get settings_safeBrowsingMalwareTitle =>
      'Safe Browsing: защита от вредоносного ПО';

  @override
  String get settings_safeBrowsingMalwareKeywords =>
      'google safe browsing, вредоносное по';

  @override
  String get settings_safeBrowsingMalwareSubtitle =>
      'Предупреждать об опасных сайтах и вредоносных загрузках.';

  @override
  String get settings_safeBrowsingPhishingTitle =>
      'Safe Browsing: защита от фишинга';

  @override
  String get settings_safeBrowsingPhishingKeywords =>
      'google safe browsing, фишинг';

  @override
  String get settings_safeBrowsingPhishingSubtitle =>
      'Предупреждать о мошеннических сайтах и страницах входа.';

  @override
  String get settings_extensionsWebApiTitle => 'Web API расширений';

  @override
  String get settings_extensionsWebApiKeywords => 'api расширений';

  @override
  String get settings_extensionsWebApiSubtitle =>
      'Открыть API mozAddonManager для веб-контента и страниц расширений. Требуется перезапуск приложения.';

  @override
  String get settings_appOpeningProtectionSectionHeader =>
      'Защита от открытия приложениями';

  @override
  String get settings_blockAppsOpeningBrowserTitle =>
      'Не давать приложениям открывать браузер';

  @override
  String get settings_blockAppsOpeningBrowserKeywords =>
      'контроль интентов, внешние приложения';

  @override
  String get settings_blockAppsOpeningBrowserSubtitle =>
      'Спрашивать перед открытием ссылок, которые другие приложения отправляют в WebLibre.';

  @override
  String get settings_managedAppsSectionHeader => 'Управляемые приложения';

  @override
  String get settings_managedAppAlwaysAllowedLabel => 'Всегда разрешено';

  @override
  String get settings_managedAppAlwaysBlockedLabel => 'Всегда заблокировано';

  @override
  String get settings_managedAppActionAllow => 'Разрешить';

  @override
  String get settings_managedAppActionBlock => 'Блокировать';

  @override
  String get settings_browserLanguagesTileTitle => 'Языки браузера';

  @override
  String get settings_browserLanguagesTileSubtitle =>
      'Настроить языковые предпочтения, сообщаемые сайтам';

  @override
  String get settings_fingerprintProtectionTileTitle =>
      'Защита от цифровых отпечатков';

  @override
  String get settings_fingerprintProtectionTileSubtitle =>
      'Детальная настройка защиты от цифровых отпечатков браузера';

  @override
  String get settings_resistFingerprintingTileTitle =>
      'Противодействие отпечаткам (RFP)';

  @override
  String get settings_resistFingerprintingTileKeywords =>
      'rfp, resist fingerprinting';

  @override
  String get settings_resistFingerprintingTileSubtitle =>
      'Расширенное усиление защиты от цифровых отпечатков';

  @override
  String get settings_lnaEnabledTitle => 'Доступ к локальной сети';

  @override
  String get settings_lnaEnabledKeywords => 'lan, локальная сеть';

  @override
  String get settings_lnaEnabledSubtitle =>
      'Включить блокировку доступа к локальной сети и устройствам';

  @override
  String get settings_lnaBlockingTitle =>
      'Блокировать запросы к локальной сети';

  @override
  String get settings_lnaBlockingKeywords => 'lan, локальная сеть';

  @override
  String get settings_lnaBlockingSubtitle =>
      'Блокировать запросы веб-страниц к адресам локальной сети';

  @override
  String get settings_lnaBlockTrackersTitle =>
      'Блокировать трекеры в локальной сети';

  @override
  String get settings_lnaBlockTrackersKeywords => 'lan, локальная сеть';

  @override
  String get settings_lnaBlockTrackersSubtitle =>
      'Не давать трекерам обращаться к ресурсам локальной сети';

  @override
  String get settings_transferTitle => 'Экспорт и импорт';

  @override
  String get settings_transferChangeExportFolder => 'Изменить папку экспорта';

  @override
  String get settings_transferIntro =>
      'Переносите настройки между профилями или устройствами либо прикладывайте их к сообщению об ошибке. Переносятся только настройки — без вкладок, истории, закладок и логинов. Чтобы перенести их, создайте резервную копию всего профиля.';

  @override
  String get settings_transferDeviceOnlyNote =>
      'Настройки веб-поиска, макет домашней страницы и новой вкладки, порядок меню и закреплённые дополнения остаются на этом устройстве';

  @override
  String get settings_transferExportSectionTitle => 'Экспорт';

  @override
  String get settings_transferExportSectionSubtitle =>
      'Экспортировать выбранные разделы в читаемый файл';

  @override
  String get settings_transferSaveFileButton => 'Сохранить файл';

  @override
  String get settings_transferImportSectionTitle => 'Импорт';

  @override
  String get settings_transferImportSectionSubtitle =>
      'Выберите, какие настройки применить после открытия файла';

  @override
  String get settings_transferOpenFileButton => 'Открыть файл';

  @override
  String get settings_transferPasteButton => 'Вставить';

  @override
  String settings_transferExportFolderChanged(String name) {
    return 'Экспорт будет сохраняться в $name';
  }

  @override
  String settings_transferSavedAs(String name) {
    return 'Сохранено как $name';
  }

  @override
  String get settings_transferExportFolderGone =>
      'Папки экспорта больше нет. Выберите папку снова и повторите попытку.';

  @override
  String settings_transferSaveFailed(String error) {
    return 'Не удалось сохранить экспорт: $error';
  }

  @override
  String get settings_transferCopiedToClipboard =>
      'Настройки скопированы в буфер обмена';

  @override
  String settings_transferCopyFailed(String error) {
    return 'Не удалось скопировать экспорт: $error';
  }

  @override
  String get settings_transferImportNothingApplicable =>
      'В этом экспорте нет ничего, что может применить эта версия WebLibre.';

  @override
  String get settings_transferImportedSuccess => 'Настройки импортированы';

  @override
  String settings_transferImportFailed(String error) {
    return 'Не удалось импортировать настройки: $error';
  }

  @override
  String get settings_transferNotASettingsFile =>
      'Этот файл не является экспортом настроек.';

  @override
  String settings_transferReadFileFailed(String error) {
    return 'Не удалось прочитать файл: $error';
  }

  @override
  String get settings_transferClipboardEmpty => 'Буфер обмена пуст.';

  @override
  String settings_transferReadClipboardFailed(String error) {
    return 'Не удалось прочитать буфер обмена: $error';
  }

  @override
  String get settings_transferSectionAppSettingsTitle => 'Настройки приложения';

  @override
  String settings_transferSectionAppSettingsDescription(String torBrand) {
    return 'Внешний вид, просмотр, вкладки, приватность, настройки $torBrand и веб-движка';
  }

  @override
  String get settings_transferSectionGeckoPrefsTitle => 'Параметры Gecko';

  @override
  String get settings_transferSectionGeckoPrefsDescription =>
      'Расширенные параметры движка, изменённые вручную';

  @override
  String get settings_importErrorNotJson => 'Это не файл JSON.';

  @override
  String get settings_importErrorNotSettingsExport =>
      'Это не экспорт настроек WebLibre.';

  @override
  String get settings_importErrorMissingFormatVersion =>
      'В экспорте не указана версия формата.';

  @override
  String settings_importErrorNewerFormatVersion(int version, int supported) {
    return 'Этот экспорт создан более новой версией WebLibre (формат $version, эта версия читает до $supported). Обновите приложение и повторите попытку.';
  }

  @override
  String get settings_importErrorNoSettings => 'Экспорт не содержит настроек.';

  @override
  String settings_importErrorMalformedSection(String section) {
    return 'Раздел «$section» имеет неверную структуру.';
  }

  @override
  String settings_importErrorMalformedField(String field) {
    return 'Поле «$field» экспорта имеет неверный формат.';
  }

  @override
  String settings_importErrorUnreadablePrefsLine(String section, String line) {
    return 'В разделе «$section» есть строка, которую WebLibre не может прочитать: «$line». Импорт сбросил бы параметры, а не восстановил их.';
  }

  @override
  String settings_importErrorNotPrefsSnapshot(String section) {
    return 'Раздел «$section» не является снимком параметров WebLibre.';
  }

  @override
  String settings_importErrorMissingSchemaVersion(String section) {
    return 'В разделе «$section» не указана версия схемы.';
  }

  @override
  String settings_importErrorUnreadablePref(String section, String pref) {
    return 'Раздел «$section» содержит параметр, который WebLibre не смог прочитать обратно: «$pref».';
  }

  @override
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  ) {
    return 'Раздел «$section» создан более новой версией WebLibre (схема $version, эта версия читает до $supported). Обновите приложение и повторите попытку.';
  }

  @override
  String settings_importPartialFailure(String failed, String error) {
    return 'Раздел «$failed» остановился на полпути и мог примениться частично: $error';
  }

  @override
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  ) {
    return 'Импортировано: $applied. Затем раздел «$failed» остановился на полпути и мог примениться частично: $error';
  }

  @override
  String get settings_webEngineHardeningTitle => 'Усиление защиты веб-движка';

  @override
  String get settings_webEngineHardeningKeywords =>
      'усиление защиты, hardening, безопасность';

  @override
  String get settings_webEngineHardeningSearchHint =>
      'Поиск групп усиления защиты';

  @override
  String get settings_webEngineHardeningResetAllMenuItem =>
      'Сбросить все параметры';

  @override
  String get settings_webEngineHardeningResetAllDialogTitle =>
      'Сбросить все параметры?';

  @override
  String get settings_webEngineHardeningResetAllDialogContent =>
      'Все заданные пользователем параметры веб-движка будут сброшены к значениям по умолчанию.';

  @override
  String get settings_webEngineHardeningOverviewTitle => 'Обзор';

  @override
  String get settings_webEngineHardeningCompleteTitle =>
      'Полное усиление защиты';

  @override
  String get settings_webEngineHardeningCompleteSubtitle =>
      'Применить или сбросить все сгруппированные параметры усиления защиты';

  @override
  String get settings_webEngineHardeningCompleteToggleHint =>
      'Переключить все сгруппированные параметры усиления защиты сразу.';

  @override
  String get settings_webEngineHardeningGroupsTitle => 'Группы усиления защиты';

  @override
  String get settings_webEngineHardeningLoadFailedTitle =>
      'Не удалось загрузить параметры';

  @override
  String get settings_webEngineHardeningGroupSearchHint =>
      'Поиск параметров усиления защиты';

  @override
  String get settings_webEngineHardeningGroupControlsTitle =>
      'Управление группой';

  @override
  String get settings_webEngineHardeningPreferenceSettingsTitle => 'Параметры';

  @override
  String get settings_webEngineHardeningOptionalBadge => 'Необязательно';

  @override
  String get settings_settingsHomeTitle => 'Настройки';

  @override
  String get settings_settingsHomeSearchHint => 'Поиск по всем настройкам';

  @override
  String get settings_searchTitle => 'Поиск';

  @override
  String get settings_searchSubtitle =>
      'Поисковые системы, бэнги, подсказки из истории и поиск на устройстве.';

  @override
  String get settings_defaultSearchProviderTitle =>
      'Поисковая система по умолчанию';

  @override
  String get settings_defaultSearchProviderKeywords =>
      'поисковая система, поисковик';

  @override
  String get settings_defaultAutocompleteProviderTitle =>
      'Сервис подсказок по умолчанию';

  @override
  String get settings_defaultAutocompleteProviderKeywords =>
      'подсказки, автодополнение';

  @override
  String get settings_customSearchEnginesTitle => 'Свои поисковые системы';

  @override
  String get settings_customSearchEnginesKeywords =>
      'свои бэнги, поисковые системы';

  @override
  String get settings_customSearchEnginesSubtitle =>
      'Добавление собственных поисковых систем и управление ими';

  @override
  String get settings_bangSettingsListTitle => 'Настройки бэнгов';

  @override
  String get settings_bangSettingsListSubtitle =>
      'Управление репозиториями бэнгов и данными использования';

  @override
  String get settings_searchHistoryLimitTitle => 'Лимит истории поиска';

  @override
  String get settings_searchHistoryLimitKeywords => 'история, записи';

  @override
  String get settings_searchHistoryLimitSubtitle =>
      'Максимальное число запоминаемых недавних запросов';

  @override
  String get settings_searchHistoryLimitSuffix => 'записей';

  @override
  String get settings_validationEnterValue => 'Введите значение';

  @override
  String get settings_validationEnterValidNumber => 'Введите допустимое число';

  @override
  String get settings_validationValueBetween0And100 =>
      'Значение должно быть от 0 до 100';

  @override
  String get settings_allowClipboardAccessTitle =>
      'Доступ к буферу обмена для подсказок';

  @override
  String get settings_allowClipboardAccessKeywords => 'буфер обмена';

  @override
  String get settings_allowClipboardAccessSubtitle =>
      'Браузер может читать буфер обмена, чтобы предлагать URL-адреса';

  @override
  String get settings_historySuggestionsTitle => 'Подсказки из истории';

  @override
  String get settings_historySuggestionsKeywords =>
      'подсказки из истории, посещённые страницы, автодополнение, призрачный текст, приватность';

  @override
  String get settings_historySuggestionsSubtitle =>
      'Показывать посещённые страницы и дополнять адреса из истории во время ввода. При отключении история сохраняется.';

  @override
  String get settings_privateSearchSuggestionsTitle =>
      'Подсказки в приватных вкладках';

  @override
  String get settings_privateSearchSuggestionsKeywords =>
      'приватные, инкогнито, поисковые подсказки, история, приватность';

  @override
  String get settings_privateSearchSuggestionsSubtitle =>
      'Использовать сервис подсказок и историю при вводе в приватной вкладке. Введённый текст отправляется сервису.';

  @override
  String get settings_acceptSuggestionOnSubmitTitle =>
      'Автодополнение по Enter';

  @override
  String get settings_acceptSuggestionOnSubmitKeywords =>
      'отправка, клавиатура, подсказки';

  @override
  String get settings_acceptSuggestionOnSubmitSubtitle =>
      'Принимать встроенную подсказку при нажатии Enter на клавиатуре';

  @override
  String get settings_popularSitesAutocompleteTitle =>
      'Подсказки популярных сайтов';

  @override
  String get settings_popularSitesAutocompleteKeywords =>
      'популярные сайты, домены, призрачный текст, автодополнение';

  @override
  String get settings_popularSitesAutocompleteSubtitle =>
      'Дополнять введённый текст известными доменами, если в истории и закладках нет совпадений';

  @override
  String get settings_localIndexEnabledTitle =>
      'Включить локальный поисковый индекс';

  @override
  String get settings_localIndexEnabledKeywords => 'текст страницы, история';

  @override
  String get settings_localIndexEnabledSubtitle =>
      'Индексировать посещённые страницы локально, чтобы браузер мог искать по их содержимому. Метаданные посещений остаются в движке; на устройстве хранится только текст страниц.';

  @override
  String get settings_indexPrivateTabsTitle =>
      'Индексировать приватные вкладки';

  @override
  String get settings_indexPrivateTabsKeywords => 'инкогнито, приватные';

  @override
  String get settings_indexPrivateTabsSubtitle =>
      'Включать в локальный индекс страницы из приватных вкладок. По умолчанию выключено.';

  @override
  String get settings_clearLocalIndexDialogTitle =>
      'Очистить локальный поисковый индекс?';

  @override
  String get settings_clearLocalIndexDialogContent =>
      'Будет удалено всё локально проиндексированное содержимое страниц. История движка (метаданные посещений) не затрагивается.';

  @override
  String get settings_localIndexStatsTitle => 'Проиндексированные страницы';

  @override
  String get settings_localIndexStatsKeywords => 'очистить индекс, статистика';

  @override
  String settings_localIndexPagesIndexed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Проиндексировано $count страницы',
      many: 'Проиндексировано $count страниц',
      few: 'Проиндексировано $count страницы',
      one: 'Проиндексирована $count страница',
    );
    return '$_temp0';
  }

  @override
  String get settings_searchSectionProvidersTitle => 'Поисковые системы';

  @override
  String get settings_searchSectionProvidersKeywords => 'поисковики, системы';

  @override
  String get settings_searchSectionBangShortcutsTitle => 'Бэнги';

  @override
  String get settings_searchSectionBangShortcutsKeywords => 'бэнги, bangs';

  @override
  String get settings_searchSectionHistorySuggestionsTitle =>
      'История и подсказки';

  @override
  String get settings_searchSectionLocalIndexTitle =>
      'Локальный поисковый индекс';

  @override
  String get settings_searchSectionLocalIndexKeywords =>
      'поиск на устройстве, индекс';

  @override
  String get settings_indexDefaultSearchProviderSubtitle =>
      'Выбор поисковой системы по умолчанию';

  @override
  String get settings_indexDefaultAutocompleteProviderSubtitle =>
      'Выбор сервиса поисковых подсказок';

  @override
  String get settings_indexAcceptSuggestionOnSubmitSubtitle =>
      'Принимать встроенную подсказку при нажатии Enter';

  @override
  String get settings_indexHistorySuggestionsSubtitle =>
      'Предлагать посещённые страницы во время ввода';

  @override
  String get settings_indexPrivateSearchSuggestionsSubtitle =>
      'Использовать подсказки и историю в приватных вкладках';

  @override
  String get settings_indexPopularSitesAutocompleteSubtitle =>
      'Дополнять введённый текст известными доменами';

  @override
  String get settings_indexLocalIndexEnabledSubtitle =>
      'Индексировать посещённые страницы локально для поиска по содержимому';

  @override
  String get settings_indexIndexPrivateTabsSubtitle =>
      'Включать приватные вкладки в локальный индекс';

  @override
  String get settings_indexLocalIndexStatsSubtitle =>
      'Просмотр и очистка локального индекса';

  @override
  String get settings_webContentTitle => 'Веб-контент';

  @override
  String get settings_webContentSubtitle =>
      'Отображение текста, режим чтения, PDF и локальные функции ИИ.';

  @override
  String get settings_webFontsTitle => 'Веб-шрифты';

  @override
  String get settings_webFontsKeywords => 'шрифты';

  @override
  String get settings_webFontsSubtitle =>
      'Разрешить сайтам использовать собственные шрифты';

  @override
  String get settings_automaticFontSizeTitle => 'Автоматический размер шрифта';

  @override
  String get settings_automaticFontSizeKeywords => 'размер текста';

  @override
  String get settings_automaticFontSizeSubtitle =>
      'Автоматически подбирать размер шрифта по системным настройкам. Отключите, чтобы вручную управлять коэффициентом размера шрифта и увеличением текста.';

  @override
  String get settings_fontSizeFactorTitle => 'Коэффициент размера шрифта';

  @override
  String get settings_fontSizeFactorKeywords => 'масштаб, текст';

  @override
  String get settings_fontSizeFactorSubtitle =>
      'Масштабировать размер текста веб-страниц';

  @override
  String get settings_disabledWhileAutomaticFontSize =>
      'Недоступно, пока включён автоматический размер шрифта';

  @override
  String get settings_fontInflationTitle => 'Увеличение текста';

  @override
  String get settings_fontInflationKeywords => 'читаемость';

  @override
  String get settings_fontInflationSubtitle =>
      'Увеличивать текст на страницах без мета-тега viewport для мобильных';

  @override
  String get settings_inputAutoZoomTitle => 'Автомасштаб полей ввода';

  @override
  String get settings_inputAutoZoomKeywords => 'формы';

  @override
  String get settings_inputAutoZoomSubtitle =>
      'Автоматически увеличивать масштаб при фокусе на текстовом поле';

  @override
  String get settings_forceUserScalableTitle =>
      'Масштабирование на всех сайтах';

  @override
  String get settings_forceUserScalableKeywords =>
      'щипок, масштаб, доступность';

  @override
  String get settings_forceUserScalableSubtitle =>
      'Разрешить масштабирование жестом даже на сайтах, которые его запрещают';

  @override
  String get settings_pdfViewerTitle => 'Встроенный просмотр PDF';

  @override
  String get settings_pdfViewerKeywords => 'pdf';

  @override
  String get settings_pdfViewerSubtitle =>
      'Открывать PDF-файлы прямо в браузере без загрузки';

  @override
  String get settings_enableReaderModeTitle => 'Включить режим чтения';

  @override
  String get settings_enableReaderModeKeywords => 'чтение, читаемость, reader';

  @override
  String get settings_enableReaderModeSubtitle =>
      'Добавляет в панель браузера необязательный инструмент, который упрощает веб-страницы, убирая рекламу, боковые панели и другие несущественные элементы.';

  @override
  String get settings_enforceReaderModeTitle => 'Принудительный режим чтения';

  @override
  String get settings_enforceReaderModeKeywords => 'чтение, reader';

  @override
  String get settings_enforceReaderModeSubtitle =>
      'Игнорировать оценку читаемости сайта и всегда показывать режим чтения, даже на сайтах, которые могут его не поддерживать.';

  @override
  String get settings_onDeviceAiTitle => 'ИИ на устройстве';

  @override
  String get settings_onDeviceAiKeywords => 'локальный ии, ai, подсказки';

  @override
  String get settings_onDeviceAiSubtitle =>
      'Функции на устройстве, например предложения контейнеров для открытых вкладок и их названий';

  @override
  String get settings_webContentSectionDisplayTitle => 'Отображение';

  @override
  String get settings_webContentSectionContentFeaturesTitle =>
      'Функции контента';

  @override
  String get settings_indexAutomaticFontSizeSubtitle =>
      'Подбирать размер шрифта по системным настройкам';

  @override
  String get settings_indexFontInflationSubtitle =>
      'Увеличивать текст на страницах без мобильного viewport';

  @override
  String get settings_indexInputAutoZoomSubtitle =>
      'Автоматически масштабировать при фокусе на текстовом поле';

  @override
  String get settings_indexPdfViewerSubtitle =>
      'Открывать PDF-файлы прямо в браузере';

  @override
  String get settings_indexEnableReaderModeSubtitle =>
      'Извлекать и упрощать страницы для удобства чтения';

  @override
  String get settings_indexEnforceReaderModeSubtitle =>
      'Всегда показывать возможности режима чтения';

  @override
  String get settings_indexOnDeviceAiSubtitle =>
      'Локальные функции ИИ, включая предложения тем и вкладок';

  @override
  String get settings_ublockListsTitle => 'Списки фильтров uBlock';

  @override
  String get settings_ublockListsSearchHint =>
      'Поиск списков, групп и внешних URL-адресов';

  @override
  String get settings_ublockSectionManagement => 'Управление';

  @override
  String get settings_ublockSectionQuickActions => 'Быстрые действия';

  @override
  String get settings_ublockSectionFilterLists => 'Списки фильтров';

  @override
  String get settings_ublockSectionExternalLists => 'Внешние списки';

  @override
  String get settings_actionApply => 'Применить';

  @override
  String get settings_ublockResetDialogTitle => 'Сбросить по умолчанию?';

  @override
  String get settings_ublockResetDialogMessage =>
      'uBlock Origin вернётся к стандартной конфигурации списков фильтров, а добавленные вами внешние списки будут удалены.';

  @override
  String get settings_ublockApplyHardeningsDialogTitle =>
      'Применить усиление защиты WebLibre?';

  @override
  String get settings_ublockApplyHardeningsDialogMessage =>
      'Будет включён отобранный набор дополнительных списков фильтров, а список легитимных сокращателей ссылок добавлен как внешний список.';

  @override
  String get settings_ublockInfoBannerMessage =>
      'Изменения списков фильтров uBlock Origin вступают в силу после перезапуска приложения. Из-за кеширования некоторым изменениям может понадобиться несколько минут и ещё один перезапуск.';

  @override
  String settings_ublockLoadFailed(String error) {
    return 'Не удалось загрузить ресурсы списков фильтров: $error';
  }

  @override
  String get settings_ublockQuickResetTitle => 'Сбросить по умолчанию';

  @override
  String get settings_ublockQuickResetSubtitle =>
      'Восстановить стандартную конфигурацию списков фильтров uBlock Origin.';

  @override
  String get settings_ublockQuickApplyHardeningsTitle =>
      'Применить усиление защиты WebLibre';

  @override
  String get settings_ublockQuickApplyHardeningsSubtitle =>
      'Включить отобранный набор дополнительных списков фильтров.';

  @override
  String get settings_ublockManageTitle => 'Управлять через WebLibre';

  @override
  String get settings_ublockManageSubtitle =>
      'WebLibre задаёт включённые списки фильтров uBlock Origin при следующем запуске браузера.';

  @override
  String get settings_ublockManageHint =>
      'При включении управления за основу берутся стандартные базовые списки uBO, а «Мои фильтры» сохраняются.';

  @override
  String get settings_ublockAutoSelectTitle => 'Автовыбор языков';

  @override
  String get settings_ublockAutoSelectSubtitle =>
      'Включать региональные списки фильтров для языков устройства.';

  @override
  String get settings_ublockAutoSelectedTooltip =>
      'Выбран автоматически для вашего языка';

  @override
  String get settings_ublockDefaultOnTooltip => 'Включён по умолчанию';

  @override
  String get settings_ublockVisitSupportTooltip => 'Открыть страницу поддержки';

  @override
  String get settings_ublockExternalListsHint =>
      'URL-адреса передаются в uBlock Origin как внешние списки. Описания показываются только здесь, в WebLibre.';

  @override
  String get settings_ublockNoExternalLists => 'Внешние списки не настроены.';

  @override
  String settings_ublockNoExternalListsMatch(String query) {
    return 'Нет внешних списков, соответствующих «$query».';
  }

  @override
  String get settings_ublockAddExternalListButton => 'Добавить внешний список';

  @override
  String get settings_ublockEditListDialogTitle =>
      'Изменить внешний список фильтров';

  @override
  String get settings_ublockAddListDialogTitle =>
      'Добавить внешний список фильтров';

  @override
  String get settings_ublockListUrlLabel => 'URL-адрес списка';

  @override
  String get settings_ublockListUrlAlreadyAdded => 'Уже добавлен';

  @override
  String get settings_ublockDescriptionLabel => 'Описание (необязательно)';

  @override
  String get settings_ublockDescriptionHint =>
      'например, Раздражители — myAuthor';

  @override
  String get settings_ublockGroupDefault => 'По умолчанию';

  @override
  String get settings_ublockGroupAds => 'Реклама';

  @override
  String get settings_ublockGroupPrivacy => 'Приватность';

  @override
  String get settings_ublockGroupMalware => 'Вредоносное ПО';

  @override
  String get settings_ublockGroupAnnoyances => 'Раздражители';

  @override
  String get settings_ublockGroupMultipurpose => 'Многоцелевые';

  @override
  String get settings_ublockGroupRegions => 'Регионы';

  @override
  String get settings_categoryGeneralTitle => 'Общие';

  @override
  String get settings_categoryGeneralKeywords =>
      'тема, масштаб интерфейса, браузер по умолчанию';

  @override
  String get settings_categoryGeneralSubtitle => 'Внешний вид, загрузки';

  @override
  String get settings_categoryBrowsingTitle => 'Просмотр';

  @override
  String get settings_categoryBrowsingKeywords =>
      'вкладки, малый веб, очистка url, разворачивание ссылок';

  @override
  String get settings_categoryBrowsingSubtitle =>
      'Вкладки, навигация, внешние ссылки';

  @override
  String get settings_categoryHomeNewTabTitle =>
      'Домашняя страница и новая вкладка';

  @override
  String get settings_categoryHomeNewTabKeywords =>
      'домашняя, новая вкладка, стартовая страница, разделы, ярлыки, популярные сайты, цитата, обои, фон';

  @override
  String get settings_categoryHomeNewTabSubtitle =>
      'Что показывают домашняя страница и новая вкладка';

  @override
  String get settings_categoryGesturesTitle => 'Жесты';

  @override
  String get settings_categoryGesturesKeywords =>
      'жест, свайп, штрих, панель вкладок, долгое нажатие, щипок';

  @override
  String get settings_categoryGesturesSubtitle =>
      'Свайпы по панели вкладок и вкладкам, рисуемые жесты';

  @override
  String get settings_categoryKeyboardShortcutsTitle => 'Сочетания клавиш';

  @override
  String get settings_categoryKeyboardShortcutsKeywords =>
      'клавиатура, сочетание, горячие клавиши, привязка клавиш';

  @override
  String get settings_categoryKeyboardShortcutsSubtitle =>
      'Клавиши аппаратной клавиатуры для действий браузера';

  @override
  String get settings_categoryToolbarLayoutTitle =>
      'Панель инструментов и макет';

  @override
  String get settings_categoryToolbarLayoutKeywords =>
      'контекстная панель инструментов, быстрый переключатель вкладок';

  @override
  String get settings_categoryToolbarLayoutSubtitle =>
      'Панель вкладок, панель инструментов, быстрый переключатель, обзор вкладок';

  @override
  String get settings_categoryWebContentTitle => 'Веб-контент';

  @override
  String get settings_categoryWebContentKeywords => 'режим чтения, pdf, шрифты';

  @override
  String get settings_categoryWebContentSubtitle =>
      'Отображение страниц, PDF, режим чтения, ИИ';

  @override
  String get settings_categoryNotificationsTitle => 'Уведомления';

  @override
  String get settings_categoryNotificationsKeywords =>
      'push, пуш, unifiedpush, ntfy, дистрибьютор';

  @override
  String get settings_categoryNotificationsSubtitle =>
      'Доставка web push, дистрибьютор, подписки сайтов';

  @override
  String get settings_categorySearchTitle => 'Поиск';

  @override
  String get settings_categorySearchKeywords =>
      'бэнги, подсказки, локальный поисковый индекс';

  @override
  String get settings_categorySearchSubtitle =>
      'Поисковые системы, бэнги, история поиска';

  @override
  String get settings_categoryPrivacySecurityTitle =>
      'Приватность и безопасность';

  @override
  String get settings_categoryPrivacySecurityKeywords =>
      'цифровые отпечатки, https, doh, safe browsing, защита сети';

  @override
  String get settings_categoryPrivacySecuritySubtitle =>
      'Защита от отслеживания, очистка данных';

  @override
  String get settings_categoryProxyTitle => 'Прокси';

  @override
  String get settings_categoryProxyKeywords =>
      'прокси, sing-box, socks, vpn, впн, wireguard, маршрутизация, tor, контейнер';

  @override
  String get settings_categoryProxySubtitle => 'Подключения и маршрутизация';

  @override
  String get settings_categoryExtensionsTitle => 'Расширения';

  @override
  String get settings_categoryExtensionsKeywords =>
      'дополнения, неподписанные расширения, addons';

  @override
  String get settings_categoryExtensionsSubtitle =>
      'Установка расширений и управление их источниками';

  @override
  String get settings_categoryAccountTitle => 'Аккаунт WebLibre';

  @override
  String get settings_categoryAccountKeywords =>
      'аккаунт, подписка, учётная запись';

  @override
  String get settings_categoryAccountSubtitle => 'Вход, синхронизация настроек';

  @override
  String get settings_categorySyncTitle => 'Firefox Sync';

  @override
  String get settings_categorySyncKeywords =>
      'сопряжение, имя устройства, типы данных';

  @override
  String get settings_categorySyncSubtitle =>
      'Аккаунт, синхронизация, выбор данных';

  @override
  String get settings_categoryAdvancedTitle => 'Дополнительно';

  @override
  String get settings_categoryAdvancedKeywords =>
      'экспериментальные, журналы ошибок, javascript';

  @override
  String get settings_categoryAdvancedSubtitle =>
      'JavaScript, user agent, отладка';

  @override
  String get settings_categoryGroupBrowserTitle => 'Браузер';

  @override
  String get settings_categoryGroupServicesAdvancedTitle =>
      'Сервисы и дополнительно';

  @override
  String get settings_privacySectionTrackingProtectionTitle =>
      'Защита от отслеживания';

  @override
  String get settings_privacySectionTrackingProtectionKeywords =>
      'приватность, трекеры';

  @override
  String get settings_indexEnhancedTrackingProtectionSubtitle =>
      'Выбор строгости блокировки трекеров';

  @override
  String get settings_indexContentBlockingDatabaseSubtitle =>
      'Использовать списки блокировки GeckoView для категорий ETP';

  @override
  String get settings_indexBounceTrackingProtectionSubtitle =>
      'Удалять следы отслеживания, оставленные трекерами перенаправлений';

  @override
  String get settings_indexQueryParameterStrippingSubtitle =>
      'Удалять параметры отслеживания из URL-адресов';

  @override
  String get settings_privacySectionFingerprintingTitle => 'Цифровые отпечатки';

  @override
  String get settings_indexBrowserLanguagesSubtitle =>
      'Выбор языков, видимых сайтам';

  @override
  String get settings_privacySectionConnectionSecurityTitle =>
      'Безопасность соединения';

  @override
  String get settings_indexHttpsOnlyModeSubtitle =>
      'Предпочитать HTTPS и блокировать незащищённые соединения';

  @override
  String get settings_indexDnsOverHttpsTitle => 'DNS через HTTPS';

  @override
  String get settings_indexDnsOverHttpsKeywords => 'doh';

  @override
  String get settings_indexDnsOverHttpsSubtitle => 'Шифровать DNS-запросы';

  @override
  String get settings_privacySectionNetworkProtectionTitle => 'Защита сети';

  @override
  String get settings_indexLnaBlockingSubtitle =>
      'Блокировать запросы к устройствам и сервисам локальной сети';

  @override
  String get settings_indexLnaBlockTrackersSubtitle =>
      'Блокировать похожие на трекеры запросы к локальной сети';

  @override
  String get settings_privacySectionSignalsModesTitle =>
      'Сигналы и режимы приватности';

  @override
  String get settings_indexScreenshotProtectionSubtitle =>
      'Не допускать попадания содержимого приложения на снимки экрана';

  @override
  String get settings_indexAllowPrivateTabScreenshotsSubtitle =>
      'Разрешить системе захватывать приватные вкладки';

  @override
  String get settings_indexGlobalPrivacyControlSubtitle =>
      'Отправлять сайтам сигнал о предпочтениях приватности';

  @override
  String get settings_privacySectionAppOpeningProtectionTitle =>
      'Защита от открытия приложениями';

  @override
  String get settings_indexAppOpeningProtectionSubtitle =>
      'Контроль того, какие приложения могут напрямую запускать WebLibre';

  @override
  String get settings_privacySectionDataManagementTitle => 'Управление данными';

  @override
  String get settings_indexDeleteBrowsingDataSubtitle =>
      'Очистка истории, куки и других данных просмотра';

  @override
  String get settings_indexAutoClearHistorySubtitle =>
      'Автоматически очищать историю по истечении выбранного срока';

  @override
  String get settings_indexAutoClearUnassignedTabsSubtitle =>
      'Автоматически закрывать вкладки, не привязанные к контейнеру';

  @override
  String get settings_privacySectionSafeBrowsingTitle => 'Google Safe Browsing';

  @override
  String get settings_indexSafeBrowsingMalwareSubtitle =>
      'Предупреждать о вредоносном ПО и опасных загрузках';

  @override
  String get settings_indexSafeBrowsingPhishingSubtitle =>
      'Предупреждать о мошеннических сайтах и страницах входа';

  @override
  String get settings_privacySectionAdvancedSecurityTitle =>
      'Расширенная безопасность';

  @override
  String get settings_indexWebEngineHardeningSubtitle =>
      'Усилить защиту поведения и настроек движка браузера';

  @override
  String get settings_indexFissionEnabledSubtitle =>
      'Более строгая изоляция сайтов друг от друга';

  @override
  String get settings_indexExtensionsWebAPIEnabledSubtitle =>
      'Разрешить расширениям предоставлять веб-API страницам';

  @override
  String get settings_proxySectionTitle => 'Прокси';

  @override
  String get settings_indexProxyLogsSubtitle =>
      'Чтение журнала прокси и настройка объёма записи';

  @override
  String get settings_saveAndUse => 'Сохранить и использовать';

  @override
  String get settings_replace => 'Заменить';

  @override
  String get settings_later => 'Позже';

  @override
  String get settings_restartNow => 'Перезапустить сейчас';

  @override
  String get settings_sync => 'Синхронизировать';

  @override
  String get settings_chooseSearchProvider => 'Выберите поисковую систему';

  @override
  String get settings_entriesLabel => 'Записи';

  @override
  String get settings_lastSyncLabel => 'Последняя синхронизация';

  @override
  String get settings_notAvailable => 'Н/Д';

  @override
  String get settings_protectionLevelTitle => 'Уровень защиты';

  @override
  String get settings_protectionLevelDescription =>
      'DNS через HTTPS отправляет запросы к доменным именам по зашифрованному соединению. Это защищает запросы и затрудняет другим определение того, какие сайты вы собираетесь посетить.';

  @override
  String get settings_defaultProtectionTitle => 'Стандартная защита';

  @override
  String get settings_defaultProtectionSubtitle =>
      'DoH используется, только если стандартный DNS не работает';

  @override
  String get settings_increasedProtectionTitle => 'Повышенная защита';

  @override
  String get settings_increasedProtectionSubtitle =>
      'Предпочтительно DoH, стандартный DNS как запасной';

  @override
  String get settings_maxProtectionTitle => 'Максимальная защита';

  @override
  String get settings_maxProtectionSubtitle =>
      'Только DoH, без запасного варианта';

  @override
  String get settings_protectionOffTitle => 'Выключено';

  @override
  String get settings_protectionOffSubtitle =>
      'Использовать стандартный DNS-резолвер';

  @override
  String get settings_dohProviderTitle => 'Провайдер DoH';

  @override
  String get settings_yourResolvers => 'Ваши резолверы';

  @override
  String get settings_addCustomResolver => 'Добавить свой резолвер';

  @override
  String get settings_editCustomResolverTitle => 'Изменить свой резолвер';

  @override
  String get settings_resolverUrlLabel => 'URL-адрес резолвера';

  @override
  String get settings_alreadyBuiltInProvider =>
      'Уже есть среди встроенных провайдеров';

  @override
  String get settings_alreadyAdded => 'Уже добавлен';

  @override
  String get settings_resolverNameLabel => 'Название (необязательно)';

  @override
  String get settings_resolverNameHint =>
      'например, dnsforge (блокировка рекламы)';

  @override
  String get settings_searchHint => 'Поиск настроек';

  @override
  String get settings_noSettingsAvailable => 'Нет доступных настроек.';

  @override
  String settings_noSettingsMatch(String query) {
    return 'Нет настроек, соответствующих «$query».';
  }

  @override
  String get settings_stringListEditorEmpty => 'Пока ничего не добавлено.';

  @override
  String get settings_customizeMenu => 'Настроить меню';

  @override
  String get settings_customizeMenuKeywords => 'разделы, строки, порядок';

  @override
  String get settings_customizeMenuSubtitle =>
      'Выберите разделы и строки меню с тремя точками и их порядок';

  @override
  String get settings_tabBarPositionTitle => 'Положение панели вкладок';

  @override
  String get settings_tabBarPositionKeywords => 'вверху, внизу, сбоку';

  @override
  String settings_currentlyResolvesTo(String text, String value) {
    return '$text (сейчас: $value)';
  }

  @override
  String get settings_tabBarPositionAutoLabel => 'Авто';

  @override
  String get settings_tabBarPositionTopLabel => 'Вверху';

  @override
  String get settings_tabBarPositionBottomLabel => 'Внизу';

  @override
  String get settings_tabBarPositionLeftLabel => 'Слева';

  @override
  String get settings_tabBarPositionRightLabel => 'Справа';

  @override
  String get settings_tabBarPositionAutoDescription =>
      'Боковая панель на больших экранах, нижняя панель на телефонах';

  @override
  String get settings_tabBarPositionTopDescription =>
      'Постоянная панель вкладок без автоскрытия';

  @override
  String get settings_tabBarPositionBottomDescription =>
      'Панель вкладок с поддержкой автоскрытия';

  @override
  String get settings_tabBarPositionLeftDescription =>
      'Вертикальная боковая панель, скрывается свайпом';

  @override
  String get settings_tabBarPositionRightDescription =>
      'Вертикальная боковая панель, скрывается свайпом';

  @override
  String get settings_tabBarStyleTitle => 'Стиль панели вкладок';

  @override
  String get settings_tabBarStyleKeywords => 'макет, компактный';

  @override
  String get settings_withTitleOption => 'С заголовком';

  @override
  String get settings_withTitleDescription =>
      'Показывает заголовок страницы и путь URL-адреса';

  @override
  String get settings_compactOption => 'Компактный';

  @override
  String get settings_compactDescription =>
      'URL-адрес по центру без заголовка страницы';

  @override
  String get settings_showContextualToolbarTitle =>
      'Показывать контекстную панель';

  @override
  String get settings_showContextualToolbarKeywords =>
      'нижняя панель инструментов';

  @override
  String get settings_showContextualToolbarSubtitle =>
      'Показывать дополнительную нижнюю панель для навигации и действий';

  @override
  String get settings_customizeToolbarButtons => 'Настроить кнопки панели';

  @override
  String get settings_customizeToolbarButtonsKeywords => 'кнопки';

  @override
  String get settings_customizeSwitcherButtons =>
      'Настроить кнопки переключателя';

  @override
  String get settings_customizeSwitcherButtonsKeywords =>
      'кнопки, новая вкладка, действия, в конце';

  @override
  String get settings_customizeSwitcherButtonsSubtitle =>
      'Кнопки действий, закреплённые в конце панели переключателя (независимо от контекстной панели)';

  @override
  String get settings_tabStackingTitle => 'Группировка вкладок';

  @override
  String get settings_tabStackingKeywords =>
      'недавние вкладки, недавно использованные, вкладки контейнера, аккордеон, два уровня, строки, группировка, группы вкладок, стопки вкладок, дерево вкладок, отключено';

  @override
  String get settings_tabStackingSubtitle =>
      'Как быстрый переключатель вкладок располагает вкладки';

  @override
  String get settings_recentlyUsedTabsOption => 'Недавние вкладки';

  @override
  String get settings_recentlyUsedTabsDescription =>
      'Недавно использованные вкладки из всех контейнеров';

  @override
  String get settings_containerTabsOption => 'Вкладки контейнера';

  @override
  String get settings_containerTabsDescription =>
      'Упорядоченные вкладки выбранного контейнера';

  @override
  String get settings_accordionOption => 'Аккордеон';

  @override
  String get settings_accordionDescription =>
      'Все контейнеры в виде чипов, вкладки выбранного контейнера раскрыты рядом';

  @override
  String get settings_twoRowsOption => 'Две строки';

  @override
  String get settings_twoRowsDescription =>
      'Вкладки выбранного контейнера сверху, недавние вкладки снизу';

  @override
  String get settings_tabGroupsOption => 'Группы вкладок';

  @override
  String get settings_tabGroupsDescription =>
      'Один чип на вкладку вместе с открытыми из неё вкладками, над ними — вкладки текущей группы';

  @override
  String get settings_tabStackingFallbackAccordion =>
      'Нужно больше места, чем есть в этом окне или на боковой панели, поэтому пока показывается «Аккордеон»';

  @override
  String get settings_tabStackingFallbackContainerTabs =>
      'Нужно больше места, чем есть в этом окне или на боковой панели, поэтому пока показываются «Вкладки контейнера»';

  @override
  String get settings_disabledOption => 'Отключено';

  @override
  String get settings_disabledDescription =>
      'Скрыть быстрый переключатель вкладок';

  @override
  String get settings_closeButtonsTitle => 'Кнопки закрытия на чипах вкладок';

  @override
  String get settings_closeButtonsKeywords =>
      'закрыть, кнопка x, крестик, активная вкладка';

  @override
  String get settings_closeButtonsSubtitle =>
      'На каких чипах переключателя показывать кнопку закрытия';

  @override
  String get settings_activeTabOnlyOption => 'Только активная';

  @override
  String get settings_activeTabOnlyDescription =>
      'Только на чипе открытой сейчас вкладки';

  @override
  String get settings_allTabsOption => 'Все вкладки';

  @override
  String get settings_allTabsDescription => 'На всех чипах панели';

  @override
  String get settings_neverOption => 'Никогда';

  @override
  String get settings_neverCloseDescription =>
      'Без кнопок закрытия; закрывайте вкладки через меню долгого нажатия или свайпом по панели';

  @override
  String get settings_titleWidthTitle =>
      'Ширина заголовка в быстром переключателе';

  @override
  String get settings_titleWidthKeywords => 'ширина, заголовок, чип, длина';

  @override
  String get settings_titleWidthSubtitle =>
      'Максимальная ширина заголовков вкладок на чипах переключателя';

  @override
  String get settings_historyFallbackTitle => 'История в быстром переключателе';

  @override
  String get settings_historyFallbackKeywords => 'подсказки, история';

  @override
  String get settings_historyFallbackSubtitle =>
      'Показывать подсказки из истории, когда нет чипов вкладок';

  @override
  String get settings_showTitlesTitle => 'Заголовки в быстром переключателе';

  @override
  String get settings_showTitlesKeywords => 'заголовки страниц';

  @override
  String get settings_showTitlesSubtitle =>
      'Показывать заголовки вкладок рядом со значками в быстром переключателе';

  @override
  String get settings_hierarchyDepthTitle =>
      'Глубина иерархии в быстром переключателе';

  @override
  String get settings_hierarchyDepthKeywords =>
      'иерархия, вложенность, глубина, дерево, шевроны';

  @override
  String get settings_hierarchyDepthSubtitle =>
      'Сколько шевронов вложенности показывать на чипах переключателя, прежде чем свернуть их в счётчик (0 скрывает индикатор)';

  @override
  String settings_hierarchyGlyphsLabel(int glyphs) {
    String _temp0 = intl.Intl.pluralLogic(
      glyphs,
      locale: localeName,
      other: '$glyphs уровня',
      many: '$glyphs уровней',
      few: '$glyphs уровня',
      one: '$glyphs уровень',
      zero: 'Выкл.',
    );
    return '$_temp0';
  }

  @override
  String get settings_autoHideTabBarTitle => 'Автоскрытие панели вкладок';

  @override
  String get settings_autoHideTabBarKeywords => 'прокрутка';

  @override
  String get settings_autoHideTabBarSubtitle =>
      'Скрывать панель вкладок при прокрутке';

  @override
  String get settings_autoHideSidePanelTitle => 'Автоскрытие боковой панели';

  @override
  String get settings_autoHideSidePanelKeywords =>
      'мышь, курсор, наведение, боковая панель';

  @override
  String get settings_autoHideSidePanelSubtitle =>
      'Убирать левую или правую панель вкладок и выдвигать её, когда мышь достигает этого края. Работает только при использовании мыши или тачпада; касание экрана возвращает панель рядом со страницей.';

  @override
  String get settings_bottomSheetTabViewTitle =>
      'Обзор вкладок в нижней панели';

  @override
  String get settings_bottomSheetTabViewKeywords => 'нижняя панель';

  @override
  String get settings_bottomSheetTabViewSubtitle =>
      'Показывать вкладки в нижней панели, а не на весь экран';

  @override
  String get settings_longPressUrlCopyTitle => 'Копировать URL долгим нажатием';

  @override
  String get settings_longPressUrlCopyKeywords =>
      'копировать url, копировать адрес';

  @override
  String get settings_longPressUrlCopySubtitle =>
      'Копировать URL-адрес страницы в буфер обмена при долгом нажатии на адресную строку';

  @override
  String get settings_showFaviconsTitle => 'Значки сайтов в виде списка';

  @override
  String get settings_showFaviconsKeywords => 'значки, фавиконы';

  @override
  String get settings_showFaviconsSubtitle =>
      'Показывать значки сайтов вместо миниатюр страниц в списке вкладок';

  @override
  String get settings_previewPageContent => 'Содержимое страницы';

  @override
  String get settings_previewPageTitle => 'Предпросмотр WebLibre';

  @override
  String get settings_previewTabNews => 'Новости';

  @override
  String get settings_previewTabPrivate => 'Приватная';

  @override
  String get settings_previewTabBank => 'Банк';

  @override
  String get settings_previewTabSearch => 'Поиск';

  @override
  String get settings_livePreviewTitle => 'Предпросмотр';

  @override
  String get settings_livePreviewSubtitle =>
      'Отражает текущие настройки панели инструментов и макета';

  @override
  String get settings_deleteAllExceptionsTitle => 'Удалить все исключения?';

  @override
  String get settings_deleteAllExceptionsContent =>
      'Защита от отслеживания снова будет включена для всех сайтов-исключений.';

  @override
  String get settings_entryCopied => 'Запись скопирована';

  @override
  String get settings_messageLabel => 'Сообщение:';

  @override
  String get settings_errorLabel => 'Ошибка:';

  @override
  String get settings_stackTraceLabel => 'Трассировка стека:';

  @override
  String get settings_importSettingsTitle => 'Импорт настроек';

  @override
  String get settings_importSettingsDescription =>
      'Выбранные разделы заменят то, что сейчас есть в этом профиле. Всё неотмеченное останется как есть.';

  @override
  String settings_unreadableSections(int count, String sections) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count раздела этого файла ($sections) не могут быть прочитаны этой версией WebLibre и будут пропущены.',
      many:
          '$count разделов этого файла ($sections) не могут быть прочитаны этой версией WebLibre и будут пропущены.',
      few:
          '$count раздела этого файла ($sections) не могут быть прочитаны этой версией WebLibre и будут пропущены.',
      one:
          '$count раздел этого файла ($sections) не может быть прочитан этой версией WebLibre и будет пропущен.',
    );
    return '$_temp0';
  }

  @override
  String get settings_exportedLabel => 'Экспортировано';

  @override
  String get settings_appVersionLabel => 'Версия приложения';

  @override
  String get settings_credentialsNotCarried =>
      'Экспорт не включает сохранённые учётные данные и изображение обоев. Это устройство сохраняет свои.';

  @override
  String get settings_geckoPrefsRestartNote =>
      'Некоторые параметры движка вступают в силу только после перезапуска браузера.';

  @override
  String get settings_userAgentChangedTitle => 'User agent изменён';

  @override
  String get settings_userAgentChangedContent =>
      'Чтобы новый user agent вступил в силу, браузер нужно перезапустить.';

  @override
  String get settings_tabBarSectionTitle => 'Панель вкладок';

  @override
  String get settings_contextualToolbarSectionTitle => 'Контекстная панель';

  @override
  String get settings_quickTabSwitcherSectionTitle =>
      'Быстрый переключатель вкладок';

  @override
  String get settings_tabViewSectionTitle => 'Обзор вкладок';

  @override
  String get settings_menuSectionTitle => 'Меню';

  @override
  String get settings_menuSectionKeywords => 'три точки, дополнительное меню';

  @override
  String get settings_indexTabBarPositionSubtitle =>
      'Выбор положения панели вкладок: вверху, внизу или сбоку';

  @override
  String get settings_indexTabBarStyleSubtitle =>
      'Выбор между макетом с заголовком и компактным';

  @override
  String get settings_indexAutoHideTabBarSubtitle =>
      'Скрывать панель вкладок при прокрутке';

  @override
  String get settings_indexAutoHideSidePanelSubtitle =>
      'Показывать боковую панель, когда мышь достигает её края';

  @override
  String get settings_indexLongPressUrlCopySubtitle =>
      'Копировать текущий URL-адрес с панели вкладок';

  @override
  String get settings_indexShowContextualToolbarSubtitle =>
      'Показывать дополнительную панель для навигации и действий';

  @override
  String get settings_indexCustomizeToolbarButtonsSubtitle =>
      'Выбор действий, отображаемых на контекстной панели';

  @override
  String get settings_indexTabStackingSubtitle =>
      'Выбор расположения вкладок в быстром переключателе';

  @override
  String get settings_indexCustomizeSwitcherButtonsSubtitle =>
      'Выбор кнопок действий в конце панели';

  @override
  String get settings_indexHistoryFallbackSubtitle =>
      'Показывать подсказки из истории, когда нет подходящих вкладок';

  @override
  String get settings_indexShowTitlesSubtitle =>
      'Показывать заголовки страниц в списке переключателя';

  @override
  String get settings_indexHierarchyDepthSubtitle =>
      'Сколько шевронов вложенности показывать на чипах переключателя';

  @override
  String get settings_indexBottomSheetTabViewSubtitle =>
      'Открывать переключатель вкладок в нижней панели';

  @override
  String get settings_indexShowFaviconsSubtitle =>
      'Показывать значки сайтов в списке вкладок';

  @override
  String get settings_switcherPlacementTitle => 'Положение переключателя';

  @override
  String get settings_switcherPlacementSubtitle =>
      'Где находится переключатель относительно адресной строки и контекстной панели';

  @override
  String get settings_switcherPlacementKeywords =>
      'положение, порядок, над, под, сверху, снизу, адресная строка, панель вкладок';

  @override
  String get settings_switcherPlacementAutoLabel => 'Автоматически';

  @override
  String get settings_switcherPlacementAutoDescription =>
      'Над адресной строкой, когда она внизу, над контекстной панелью, когда адресная строка вверху';

  @override
  String get settings_switcherPlacementAboveAddressBarLabel =>
      'Над адресной строкой';

  @override
  String get settings_switcherPlacementAboveAddressBarDescription =>
      'Следует за адресной строкой вверх или вниз';

  @override
  String get settings_switcherPlacementBelowAddressBarLabel =>
      'Под адресной строкой';

  @override
  String get settings_switcherPlacementBelowAddressBarDescription =>
      'Следует за адресной строкой вверх или вниз';

  @override
  String get settings_switcherPlacementBelowContextualBarLabel =>
      'Под контекстной панелью';

  @override
  String get settings_switcherPlacementBelowContextualBarDescription =>
      'У нижнего края экрана';

  @override
  String get settings_tabViewActionsAtBottomTitle =>
      'Действия обзора вкладок внизу';

  @override
  String get settings_tabViewActionsAtBottomSubtitle =>
      'Поиск, фильтры и действия с вкладками внизу, кнопка новой вкладки над ними';

  @override
  String get settings_tabViewActionsAtBottomKeywords =>
      'внизу, большой палец, досягаемость, одной рукой, панель, обзор вкладок';

  @override
  String get smallWeb_sheetTitle => 'Малый веб';

  @override
  String get smallWeb_refineCategoryTitle => 'Уточнить категорию';

  @override
  String get smallWeb_allCategoriesChip => 'Все';

  @override
  String smallWeb_searchingModeTitle(String mode) {
    return 'Поиск: $mode';
  }

  @override
  String get smallWeb_discoverButtonLabel => 'Открыть новое';

  @override
  String get smallWeb_browseConsolesButtonLabel => 'Обзор консолей';

  @override
  String get smallWeb_unavailableTitle => 'Малый веб недоступен';

  @override
  String get smallWeb_noConsoleSelectedMessage => 'Консоль не выбрана';

  @override
  String smallWeb_consoleStats(int linkedConsoles, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedConsoles,
      locale: localeName,
      other: '$linkedConsoles связанной консоли',
      many: '$linkedConsoles связанных консолей',
      few: '$linkedConsoles связанные консоли',
      one: '$linkedConsoles связанная консоль',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages страницы',
      many: '$pages страниц',
      few: '$pages страницы',
      one: '$pages страница',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get smallWeb_modeWebLabel => 'Веб';

  @override
  String get smallWeb_modeAppreciatedLabel => 'Отмеченное';

  @override
  String get smallWeb_modeVideosLabel => 'Видео';

  @override
  String get smallWeb_modeCodeLabel => 'Код';

  @override
  String get smallWeb_modeComicsLabel => 'Комиксы';

  @override
  String get smallWeb_modeDescriptionAppreciated =>
      'Тщательно отобранные ссылки, отмеченные сообществом малого веба.';

  @override
  String get smallWeb_modeDescriptionVideos =>
      'Видео от независимых авторов со всего малого веба.';

  @override
  String get smallWeb_modeDescriptionCode =>
      'Фрагменты кода, репозитории и технические статьи с личных сайтов.';

  @override
  String get smallWeb_modeDescriptionComics =>
      'Комиксы и веб-графика независимых иллюстраторов.';

  @override
  String get smallWeb_sourceKagiLabel => 'Kagi';

  @override
  String get smallWeb_sourceKagiDescription => 'Small Web от Kagi Search';

  @override
  String get smallWeb_sourceWanderLabel => 'Wander';

  @override
  String get smallWeb_sourceWanderDescription =>
      'Веб-кольцо на основе консолей';

  @override
  String get smallWeb_noNewItemsFoundMessage =>
      'Ничего нового не найдено. Попробуйте другой режим или категорию.';

  @override
  String get smallWeb_discoveryFailedMessage =>
      'Не удалось найти страницу. Повторите попытку.';

  @override
  String smallWeb_sessionErrorWithDetails(String error) {
    return 'Ошибка малого веба: $error';
  }

  @override
  String get smallWeb_kagiTitle => 'Kagi Small Web';

  @override
  String get smallWeb_kagiAttributionLine =>
      'От Kagi Search — открытый исходный код под лицензией MIT.';

  @override
  String get smallWeb_kagiBlogPostAction => 'Запись в блоге';

  @override
  String get smallWeb_kagiGithubAction => 'GitHub';

  @override
  String get smallWeb_kagiDescriptionWeb =>
      'Kagi Small Web показывает свежие записи с личных сайтов и блогов отдельных авторов со всего малого веба.';

  @override
  String get smallWeb_kagiDescriptionAppreciated =>
      'Этот режим Kagi Small Web показывает отмеченные записи малого веба, отобранные проектом с открытым исходным кодом.';

  @override
  String get smallWeb_kagiDescriptionVideos =>
      'Этот режим Kagi Small Web посвящён видео от небольших независимых авторов и отобранных исходных каналов.';

  @override
  String get smallWeb_kagiDescriptionCode =>
      'Этот режим Kagi Small Web посвящён записям о коде с личных сайтов и других источников малого веба.';

  @override
  String get smallWeb_kagiDescriptionComics =>
      'Этот режим Kagi Small Web посвящён комиксам и иллюстрированным записям, найденным проектом Small Web.';

  @override
  String get smallWeb_wanderTitle => 'Wander';

  @override
  String get smallWeb_wanderDescription =>
      'Wander — сеть личных сайтов, связанных общими консолями, которые помогают просматривать страницы всего сообщества Wander.';

  @override
  String get smallWeb_wanderAttributionLine =>
      'От Susam Pal — открытый исходный код под лицензией MIT.';

  @override
  String get smallWeb_wanderProjectAction => 'Проект';

  @override
  String get smallWeb_wanderSetupConsoleAction => 'Настроить свою консоль';

  @override
  String get smallWeb_menuTooltip => 'Меню';

  @override
  String get smallWeb_removeBookmarkTooltip => 'Удалить закладку';

  @override
  String get smallWeb_addBookmarkTooltip => 'Добавить закладку';

  @override
  String get smallWeb_bookmarkRemovedMessage => 'Закладка удалена';

  @override
  String get smallWeb_bookmarkAddedMessage => 'Закладка добавлена';

  @override
  String get smallWeb_exitTooltip => 'Выйти из малого веба';

  @override
  String get smallWeb_selectConsoleTitle => 'Выбор консоли';

  @override
  String get smallWeb_randomButtonLabel => 'Случайная';

  @override
  String get smallWeb_filterConsolesHint => 'Фильтр консолей…';

  @override
  String get smallWeb_linkedConsolesToggleLabel => 'Связанные';

  @override
  String get smallWeb_allConsolesToggleLabel => 'Все';

  @override
  String get smallWeb_noConsoleSelectedYetMessage =>
      'Консоль ещё не выбрана. Нажмите «Открыть новое».';

  @override
  String get smallWeb_addConsoleByUrlTooltip =>
      'Добавить консоль по URL-адресу';

  @override
  String get smallWeb_couldNotLoadSessionTitle =>
      'Не удалось загрузить сеанс малого веба';

  @override
  String get smallWeb_noLinkedConsolesFound => 'Связанные консоли не найдены.';

  @override
  String smallWeb_noConsolesMatchingQuery(String query) {
    return 'Нет консолей, соответствующих «$query».';
  }

  @override
  String get smallWeb_failedToLoadConsoles => 'Не удалось загрузить консоли.';

  @override
  String smallWeb_pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страницы',
      many: '$count страниц',
      few: '$count страницы',
      one: '$count страница',
    );
    return '$_temp0';
  }

  @override
  String get smallWeb_noConsolesDiscoveredYet => 'Консоли пока не найдены.';

  @override
  String smallWeb_addedConsole(String host) {
    return 'Консоль $host добавлена';
  }

  @override
  String get smallWeb_addConsoleDialogTitle => 'Добавить консоль';

  @override
  String get smallWeb_addConsoleDialogBody =>
      'Введите URL-адрес консоли Wander. Он может указывать на корень сайта или на путь /wander/.';

  @override
  String get smallWeb_urlFieldLabel => 'URL-адрес';

  @override
  String get smallWeb_wanderConsoleFetchFailed =>
      'Не удалось получить wander.js с этой консоли.';

  @override
  String get smallWeb_wanderConsoleEmpty =>
      'Файл wander.js не содержит консолей или страниц';

  @override
  String get smallWeb_wanderConsoleAlreadyAdded => 'Эта консоль уже добавлена';

  @override
  String get smallWeb_recentDiscoveriesTitle => 'Недавние находки';

  @override
  String smallWeb_clearModeHistory(String mode) {
    return 'Очистить: $mode';
  }

  @override
  String get smallWeb_clearAllDiscoveriesConfirmTitle =>
      'Очистить все находки?';

  @override
  String get smallWeb_clearAllDiscoveriesConfirmContent =>
      'Вся история недавних находок во всех режимах и источниках будет безвозвратно удалена.';

  @override
  String get smallWeb_actionClearAll => 'Очистить всё';

  @override
  String get smallWeb_clearAllDiscoveriesMenuItem => 'Очистить все находки';

  @override
  String get smallWeb_noDiscoveriesYetMessage =>
      'Находок пока нет.\nНажмите «Открыть новое», чтобы начать!';

  @override
  String smallWeb_showMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показать ещё $count',
      many: 'Показать ещё $count',
      few: 'Показать ещё $count',
      one: 'Показать ещё $count',
    );
    return '$_temp0';
  }

  @override
  String smallWeb_failedToLoadHistory(String error) {
    return 'Не удалось загрузить историю: $error';
  }

  @override
  String get sync_screenTitle => 'Firefox Sync';

  @override
  String get sync_searchHint => 'Поиск в настройках синхронизации';

  @override
  String get sync_statusSyncing => 'Выполняется синхронизация';

  @override
  String get sync_statusNeverSynced => 'Ещё не синхронизировано';

  @override
  String sync_statusLastSynced(String date) {
    return 'Последняя синхронизация: $date';
  }

  @override
  String get sync_sectionAccount => 'Аккаунт';

  @override
  String get sync_sectionAccountKeywords =>
      'сопряжение, привязка, имя устройства, pairing';

  @override
  String get sync_entrySignedInAccountTitle =>
      'Аккаунт, в который выполнен вход';

  @override
  String get sync_entrySignInTitle => 'Войти';

  @override
  String get sync_entryAccountSubtitle =>
      'Состояние аккаунта, сопряжение по QR-коду и имя устройства';

  @override
  String get sync_signedIn => 'Вход выполнен';

  @override
  String get sync_notSignedIn => 'Вход не выполнен';

  @override
  String get sync_authExpired =>
      'Срок авторизации истёк. Войдите снова, чтобы продолжить синхронизацию.';

  @override
  String get sync_syncingTabsBookmarksHistory =>
      'Синхронизируются вкладки, закладки и история';

  @override
  String get sync_signInPrompt =>
      'Войдите, чтобы синхронизировать вкладки, закладки и историю';

  @override
  String get sync_actionSignOut => 'Выйти';

  @override
  String get sync_scanQrTitle => 'Сканировать QR-код для сопряжения';

  @override
  String get sync_scanQrSubtitle =>
      'Отсканируйте QR-код со страницы firefox.com/pair на компьютере';

  @override
  String get sync_invalidQrCode => 'Недопустимый QR-код: это не URL-адрес';

  @override
  String get sync_deviceNameTitle => 'Имя устройства';

  @override
  String get sync_unknown => 'Неизвестно';

  @override
  String get sync_sectionSynchronization => 'Синхронизация';

  @override
  String get sync_syncNowTitle => 'Синхронизировать сейчас';

  @override
  String get sync_syncNowKeywords =>
      'история, закладки, вкладки, синхронизация';

  @override
  String get sync_syncHistoryTitle => 'Синхронизировать историю';

  @override
  String get sync_syncBookmarksTitle => 'Синхронизировать закладки';

  @override
  String get sync_syncOpenTabsTitle => 'Синхронизировать открытые вкладки';

  @override
  String get sync_sectionServerOverrides => 'Свои серверы';

  @override
  String get sync_entryServerOverridesTitle => 'Свои серверы';

  @override
  String get sync_entryServerOverridesKeywords =>
      'fxa, сервер токенов, token server, собственный сервер';

  @override
  String get sync_entryServerOverridesSubtitle =>
      'Собственные адреса серверов Firefox Account и токенов';

  @override
  String get sync_fxaServerOverrideTitle => 'Свой сервер FxA';

  @override
  String get sync_defaultMozillaServer => 'Стандартный сервер Mozilla';

  @override
  String get sync_tokenServerOverrideTitle =>
      'Свой сервер токенов синхронизации';

  @override
  String get sync_automaticFromFxaServer => 'Автоматически с сервера FxA';

  @override
  String get sync_restartAppNotice =>
      'После изменения серверов перезапустите приложение.';

  @override
  String get sync_signOutDialogTitle => 'Выйти?';

  @override
  String get sync_signOutDialogContent => 'Выйти из Firefox Sync?';

  @override
  String get sync_deviceNameHint => 'Введите имя устройства';

  @override
  String get sync_deviceNameEmpty => 'Имя устройства не может быть пустым';

  @override
  String get sync_deviceNameUpdateFailed =>
      'Не удалось обновить имя устройства';

  @override
  String get sync_mustBeValidHttpsUrl =>
      'Должен быть допустимый URL-адрес HTTPS';

  @override
  String get tor_sectionService => 'Служба';

  @override
  String get tor_sectionServiceKeywords =>
      'питание, запуск, остановка, старт, стоп';

  @override
  String get tor_sectionCircumvention => 'Обход блокировок';

  @override
  String get tor_sectionCircumventionKeywords =>
      'мосты, транспорт, цензура, obfs4, snowflake';

  @override
  String get tor_sectionCountryRestrictions => 'Ограничения по странам';

  @override
  String get tor_sectionCountryRestrictionsKeywords => 'вход, выход, страна';

  @override
  String get tor_sectionAbout => 'О программе';

  @override
  String get tor_sectionAboutKeywords =>
      'товарный знак, юридическая информация';

  @override
  String tor_proxyLabel(String brand) {
    return 'Прокси $brand';
  }

  @override
  String tor_serviceLabel(String brand) {
    return 'Служба $brand';
  }

  @override
  String get tor_serviceLabelKeywords => 'включить, подключиться';

  @override
  String tor_serviceSubtitle(String brand) {
    return 'Запуск или остановка службы $brand';
  }

  @override
  String get tor_startAutomaticallyTitle => 'Запускать автоматически';

  @override
  String get tor_startAutomaticallyKeywords =>
      'автозапуск, запуск, старт, загрузка';

  @override
  String tor_startAutomaticallySectionSubtitle(String brand) {
    return 'Подключать службу $brand при запуске WebLibre';
  }

  @override
  String tor_startAutomaticallySubtitle(String brand) {
    return 'Подключать службу $brand при запуске WebLibre, чтобы использующие её вкладки были готовы без запроса';
  }

  @override
  String get tor_requestNewIdentityTitle => 'Запросить новую личность';

  @override
  String get tor_requestNewIdentityKeywords =>
      'цепочка, новая цепочка, circuit';

  @override
  String get tor_requestNewIdentitySubtitle =>
      'Использовать новую цепочку для новых соединений';

  @override
  String tor_requestingNewIdentityMessage(String brand) {
    return 'Запрос новой личности $brand…';
  }

  @override
  String get tor_autoConfigureTransportTitle => 'Автонастройка транспорта';

  @override
  String get tor_autoConfigureTransportKeywords => 'авто, автоматически';

  @override
  String get tor_autoConfigureSectionSubtitle =>
      'Автоматически выбирать подходящий подключаемый транспорт для вашей сети';

  @override
  String tor_autoConfigureSubtitle(String brand) {
    return 'В некоторых местах для подключения к $brand необходим подключаемый транспорт';
  }

  @override
  String get tor_requireBridgeTitle =>
      'Я уверен(а), что не могу подключиться без моста';

  @override
  String get tor_transportTitle => 'Транспорт';

  @override
  String get tor_transportKeywords =>
      'напрямую, прямое подключение, obfs4, snowflake';

  @override
  String tor_transportSectionSubtitle(String torBrand) {
    return 'Выбор способа подключения к сети $torBrand, если автонастройка отключена';
  }

  @override
  String get tor_transportAutoConfiguredTitle => 'Настроено автоматически';

  @override
  String get tor_transportAutoConfiguredSubtitle =>
      'Отключите автонастройку выше, чтобы выбрать транспорт вручную.';

  @override
  String get tor_transportDirectTitle => 'Прямое подключение';

  @override
  String tor_transportDirectSubtitle(String brand) {
    return 'Лучший способ подключиться к $brand, если $brand не заблокирован';
  }

  @override
  String get tor_transportObfs4Title => 'obfs4';

  @override
  String get tor_transportObfs4Subtitle =>
      'Подходит для сетей с небольшими ограничениями и передачи больших объёмов данных';

  @override
  String get tor_transportSnowflakeTitle => 'Snowflake';

  @override
  String get tor_transportSnowflakeSubtitle => 'Подходит для сильной цензуры';

  @override
  String get tor_fetchFreshBridgesTitle =>
      'Получать свежие мосты перед подключением';

  @override
  String get tor_entryCountryTitle => 'Страна входа';

  @override
  String get tor_entryCountrySubtitle => 'Выбор страны входного узла (guard)';

  @override
  String get tor_entryCountryKeywords => 'guard, входной узел, страж';

  @override
  String get tor_exitCountryTitle => 'Страна выхода';

  @override
  String get tor_exitCountrySubtitle => 'Выбор страны выходного узла';

  @override
  String get tor_exitCountryKeywords => 'выход, выходной узел, exit';

  @override
  String get tor_automaticOption => 'Автоматически';

  @override
  String get tor_trademarkTitle => 'Товарный знак';

  @override
  String get tor_trademarkKeywords =>
      'юридическая информация, правовая информация';

  @override
  String tor_trademarkDisclaimer(String brand) {
    return '$brand — товарный знак The Tor Project; все права защищены. WebLibre не одобрен, не спонсируется и не связан с Tor Project.';
  }

  @override
  String get tor_screenSubtitle =>
      'Луковая маршрутизация, подключаемые транспорты, мосты и ограничения по странам.';

  @override
  String tor_dialogContent(String brand) {
    return 'Этому контейнеру для защищённых соединений нужен прокси $brand, но сейчас он не запущен.';
  }

  @override
  String get tor_actionEnable => 'Включить';

  @override
  String tor_connectingNotification(String proxyLabel) {
    return '$proxyLabel: подключение…';
  }

  @override
  String get tor_countrySearchHint => 'Поиск стран…';

  @override
  String get tor_unnamedCountry => 'Страна без названия';

  @override
  String get user_profilesTitle => 'Профили';

  @override
  String get user_activeProfileLabel => 'Активный';

  @override
  String get user_loadProfilesFailedTitle => 'Не удалось загрузить профили';

  @override
  String get user_askWhichProfileTitle => 'Спрашивать, какой профиль открыть';

  @override
  String get user_askWhichProfileSubtitle =>
      'При запуске, если профилей больше одного';

  @override
  String get user_createBackupTitle => 'Создать резервную копию';

  @override
  String get user_restartingToTakeBackup =>
      'Перезапуск для создания резервной копии';

  @override
  String get user_backupRestartsTitle => 'Для этого WebLibre перезапустится';

  @override
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile) {
    return '$restartClosesCurrentProfile Резервная копия создаётся, пока профиль закрыт, поэтому его содержимое не может измениться во время копирования.';
  }

  @override
  String get user_setPasswordNextTitle => 'Пароль задаётся на следующем шаге';

  @override
  String get user_setPasswordNextSubtitle =>
      'После перезапуска WebLibre запросит пароль файла резервной копии.';

  @override
  String get user_verifyBackupIntegrityTitle => 'Проверять целостность копии';

  @override
  String get user_verifyBackupIntegritySubtitle =>
      'Проверить, что резервную копию можно восстановить';

  @override
  String get user_tempDataSkippedTitle => 'Временные данные пропускаются';

  @override
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain) {
    return 'Файлы кеша и другие данные, которые WebLibre может создать заново, не сохраняются. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataIncludedTitle =>
      'Данные аккаунта WebLibre включены';

  @override
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription) {
    return 'Файл резервной копии содержит следующие данные этого профиля: $profileSecretDataDescription. При замене профиля они восстанавливаются, при создании нового — нет. Используйте надёжный пароль.';
  }

  @override
  String get user_closingToTakeBackup =>
      'Закрытие WebLibre для создания резервной копии…';

  @override
  String get user_actionBackup => 'Создать копию';

  @override
  String get user_backupsTitle => 'Резервные копии';

  @override
  String get user_changeBackupFolderTooltip => 'Изменить папку резервных копий';

  @override
  String get user_chooseBackupFolderPrompt =>
      'Выберите, где хранить резервные копии.';

  @override
  String get user_chooseBackupFolderHint =>
      'Выберите место вне приложения, чтобы копии сохранились после его удаления.';

  @override
  String get user_chooseFolderButtonLabel => 'Выбрать папку';

  @override
  String get user_noBackupsFound => 'Резервные копии не найдены';

  @override
  String get user_loadBackupsFailedTitle =>
      'Не удалось загрузить резервные копии';

  @override
  String get user_authReasonRequireAuth =>
      'Требовать аутентификацию для профиля';

  @override
  String get user_authReasonConfirmUnlock =>
      'Подтвердите, что можете разблокировать этот профиль';

  @override
  String get user_authReasonUnlockProfile => 'Разблокировать профиль';

  @override
  String user_authFailedExisting(String nothingChanged) {
    return 'Не удалось подтвердить вашу личность. $nothingChanged';
  }

  @override
  String get user_authFailedNew =>
      'Не удалось подтвердить вашу личность. Заблокированный профиль создаётся, только если это устройство может его разблокировать.';

  @override
  String get user_editProfileTitle => 'Изменить профиль';

  @override
  String get user_createProfileTitle => 'Создать профиль';

  @override
  String get user_nameFieldLabel => 'Имя';

  @override
  String get user_authenticationSectionTitle => 'Аутентификация';

  @override
  String get user_requireAuthenticationTitle => 'Требовать аутентификацию';

  @override
  String get user_requireAuthenticationSubtitle =>
      'Запрашивать перед открытием этого профиля';

  @override
  String get user_autoLockTitle => 'Автоблокировка';

  @override
  String get user_autoLockSubtitle => 'Когда снова блокировать профиль';

  @override
  String get user_lockInBackgroundTitle => 'Блокировать в фоне';

  @override
  String get user_lockInBackgroundSubtitle =>
      'Как только WebLibre уходит с экрана';

  @override
  String get user_lockAfterTimeoutTitle => 'Блокировать по тайм-ауту';

  @override
  String get user_lockAfterTimeoutSubtitle => 'После периода бездействия';

  @override
  String get user_lockOnStartupTitle => 'Блокировать только при запуске';

  @override
  String get user_lockOnStartupSubtitle =>
      'Разблокировать один раз при запуске и не блокировать, пока WebLibre не будет полностью закрыт';

  @override
  String get user_timeoutFieldTitle => 'Тайм-аут';

  @override
  String get user_timeoutFieldSubtitle => 'Сколько ждать перед блокировкой';

  @override
  String get user_timeoutOneMinute => '1 минута';

  @override
  String get user_timeoutFiveMinutes => '5 минут';

  @override
  String get user_timeoutFifteenMinutes => '15 минут';

  @override
  String get user_timeoutOneHour => '1 час';

  @override
  String get user_profileActionsSectionTitle => 'Действия с профилем';

  @override
  String get user_switchDeleteUnavailableForActive =>
      'Переключение и удаление недоступны для используемого профиля.';

  @override
  String get user_switchToThisProfileLabel => 'Перейти в этот профиль';

  @override
  String user_deleteFailedWithError(String error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String get user_deleteProfileFailedGeneric =>
      'Не удалось удалить этот профиль';

  @override
  String get user_restoreBackupTitle => 'Восстановить резервную копию';

  @override
  String get user_backupRestoredMessage => 'Резервная копия восстановлена';

  @override
  String get user_passwordFieldLabel => 'Пароль';

  @override
  String get user_wrongBackupPassword =>
      'Этот пароль не подходит к файлу резервной копии';

  @override
  String get user_passwordHelperText =>
      'Пароль, с которым был создан этот файл резервной копии.';

  @override
  String get user_createNewProfileTitle => 'Создать новый профиль';

  @override
  String get user_createNewProfileSubtitle =>
      'Сохранить существующие профили и добавить эту резервную копию';

  @override
  String get user_replaceExistingProfileTitle =>
      'Заменить существующий профиль';

  @override
  String get user_replaceExistingProfileSubtitle =>
      'Перезапустить и перезаписать один профиль этой резервной копией';

  @override
  String get user_newProfileNoSignInTitle =>
      'Новый профиль начинается без входа в WebLibre';

  @override
  String get user_newProfileNoSignInSubtitle =>
      'Вкладки, история и закладки восстанавливаются. Данные входа и синхронизации остаются в исходном профиле.';

  @override
  String user_restoringIntoTitle(String profileLabel) {
    return 'Восстановление в «$profileLabel»';
  }

  @override
  String get user_backupKeepsLockConfigured =>
      'Резервная копия сохраняет настроенную вами блокировку.';

  @override
  String get user_profileKeepsNameAndLock =>
      'Профиль сохраняет своё имя и блокировку.';

  @override
  String get user_profileToReplaceLabel => 'Заменяемый профиль';

  @override
  String get user_selectProfileToReplaceValidator =>
      'Выберите профиль для замены';

  @override
  String user_multipleProfilesShareNameTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count профиля называются «$name»',
      many: '$count профилей называются «$name»',
      few: '$count профиля называются «$name»',
      one: '$count профиль называется «$name»',
    );
    return '$_temp0';
  }

  @override
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone) {
    return 'Резервная копия указывает имя профиля, но не может сказать, какого именно, поэтому выберите профиль для замены. $cannotBeUndone';
  }

  @override
  String user_backupTakenFromTitle(String name) {
    return 'Эта резервная копия создана из «$name»';
  }

  @override
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Она заменит «$targetLabel», который сохранит своё имя и блокировку. $shortcutsNeedPinningAgain';
  }

  @override
  String user_profileWillBeCalledTitle(String name) {
    return 'Этот профиль будет называться «$name»';
  }

  @override
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain) {
    return 'Имя берётся из резервной копии. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataRestoredTitle =>
      'Данные аккаунта WebLibre восстанавливаются';

  @override
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  ) {
    return 'При замене из файла резервной копии восстанавливаются следующие данные: $profileSecretDataDescription. $signedInFromBackup $olderBackupKeepsCredentials';
  }

  @override
  String get user_replacesSetupProfileTitle =>
      'Это заменит настраиваемый профиль';

  @override
  String get user_replacesEverythingTitle =>
      'Это заменит всё содержимое того профиля';

  @override
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword) {
    return '$restartsThenAsksPassword Всё, что уже есть в этом профиле, будет заменено, когда начнётся восстановление.';
  }

  @override
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  ) {
    return '$restartsThenAsksPassword Когда начнётся восстановление, в $targetDescription будут заменены текущие данные: $profileDataDescription.';
  }

  @override
  String get user_thatProfileFallbackLabel => 'этом профиле';

  @override
  String get user_restoringBackupProgress => 'Восстановление резервной копии…';

  @override
  String get user_closingToRestoreProgress =>
      'Закрытие WebLibre для восстановления…';

  @override
  String get user_actionRestore => 'Восстановить';

  @override
  String user_switchToProfileTitle(String profileName) {
    return 'Перейти в «$profileName»?';
  }

  @override
  String user_switchClosesReopensAs(String profileName) {
    return 'WebLibre закроется и снова откроется с профилем «$profileName».';
  }

  @override
  String get user_switchConsequencesList =>
      '• Приватные вкладки будут очищены.\n• Веб-уведомления покидаемого профиля будут приостановлены.';

  @override
  String get user_actionNotNow => 'Не сейчас';

  @override
  String get user_actionSwitchAndRestart => 'Перейти и перезапустить';

  @override
  String get user_passwordConfirmationTitle => 'Подтверждение пароля';

  @override
  String get user_actionConfirm => 'Подтвердить';

  @override
  String get user_selectProfileTitle => 'Выбор профиля';

  @override
  String get user_manageProfilesLabel => 'Управление профилями';

  @override
  String get user_profileAvatarHint =>
      'Перейти в этот профиль. Долгое нажатие — изменить.';

  @override
  String user_profileAvatarTooltip(String label) {
    return '$label\nДолгое нажатие — изменить';
  }

  @override
  String get user_addProfileLabel => 'Добавить профиль';

  @override
  String get user_addProfileButtonLabel => 'Добавить';

  @override
  String get user_quitBrowserTitle => 'Выйти из браузера';

  @override
  String get user_quitBrowserContent =>
      'Браузер будет корректно закрыт, а данные приватных вкладок очищены.';

  @override
  String get user_actionQuit => 'Выйти';

  @override
  String get user_quitBrowserDontAskAgain => 'Больше не спрашивать';

  @override
  String get user_quitBrowserDontAskAgainHint =>
      'Это можно снова включить в настройках.';

  @override
  String get user_quitBrowserDontAskAgainSavesQuit =>
      'Отмеченные выше данные будут удаляться при каждом выходе. Оба параметра можно изменить в настройках.';

  @override
  String get user_quitBrowserDontAskAgainSavesQuitAndStart =>
      'Отмеченные выше данные будут удаляться при каждом выходе и при каждом запуске WebLibre. Оба параметра можно изменить в настройках.';

  @override
  String get user_quitBrowserDeleteDataTitle => 'Удалить данные просмотра';

  @override
  String user_quitBrowserDeleteDataSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано: $count',
      zero: 'Ничего не выбрано',
    );
    return '$_temp0';
  }

  @override
  String get user_quitBrowserDeletedAutomatically =>
      'Удаляется автоматически, согласно настройкам';

  @override
  String user_deleteProfileTitle(String profileName) {
    return 'Удалить «$profileName»?';
  }

  @override
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Будут удалены его данные: $profileDataDescription. $cannotBeUndone';
  }

  @override
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile Удаляемый профиль сначала закрывается.';
  }

  @override
  String get user_actionDeleteAndRestart => 'Удалить и перезапустить';

  @override
  String user_replaceProfileTitle(String profileName) {
    return 'Заменить «$profileName» этой резервной копией?';
  }

  @override
  String user_replaceProfilePlaceholderContent(String cannotBeUndone) {
    return 'Резервная копия заменит настраиваемый профиль. Всё, что в нём уже есть, будет потеряно. $cannotBeUndone';
  }

  @override
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Резервная копия заменит всё содержимое «$profileName»: $profileDataDescription. Всё, что добавлено после создания копии, будет потеряно. $cannotBeUndone';
  }

  @override
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  ) {
    return '$signedInFromBackup Из резервной копии также восстанавливаются следующие данные: $profileSecretDataDescription. $olderBackupKeepsCredentials';
  }

  @override
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Профиль будет переименован в «$adoptedName» и сохранит блокировку. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Резервная копия создана из «$sourceProfileName». «$profileName» сохранит своё имя и блокировку. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsThenAsksPassword До этого ничего не заменяется. $restartClosesCurrentProfile';
  }

  @override
  String get user_actionReplaceAndRestart => 'Заменить и перезапустить';

  @override
  String user_backupProfileTitle(String profileName) {
    return 'Создать резервную копию «$profileName»?';
  }

  @override
  String get user_backupProfileContent =>
      'Резервная копия создаётся при закрытом профиле, поэтому ничего в нём не изменится.';

  @override
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile';
  }

  @override
  String get user_actionBackupAndRestart => 'Создать копию и перезапустить';

  @override
  String get user_profileAlreadyActive => 'Этот профиль уже активен';

  @override
  String user_switchProfileFailedWithError(String error) {
    return 'Не удалось сменить профиль: $error';
  }

  @override
  String get user_profileLockedTitle => 'Профиль заблокирован';

  @override
  String get user_unlockingLabel => 'Разблокировка…';

  @override
  String get user_unlockButtonLabel => 'Разблокировать';

  @override
  String user_restartFailedWithError(String error) {
    return 'Не удалось перезапустить: $error';
  }

  @override
  String get user_restartingLabel => 'Перезапуск…';

  @override
  String get user_chooseAnotherProfileLabel => 'Выбрать другой профиль';

  @override
  String get user_searchSuggestionProviderNone => 'Отключено';

  @override
  String get user_searchSuggestionProviderBrave => 'Brave';

  @override
  String get user_searchSuggestionProviderDdg => 'DuckDuckGo';

  @override
  String get user_searchSuggestionProviderKagi => 'Kagi';

  @override
  String get user_searchSuggestionProviderQwant => 'Qwant';

  @override
  String get user_deleteBrowsingDataTypeTabsTitle => 'Открытые вкладки';

  @override
  String get user_deleteBrowsingDataTypeHistoryTitle => 'История просмотра';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesTitle =>
      'Недавние запросы';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesDescription =>
      'Запросы, показываемые на странице поиска';

  @override
  String get user_deleteBrowsingDataTypeCookiesTitle => 'Куки и данные сайтов';

  @override
  String get user_deleteBrowsingDataTypeCookiesDescription =>
      'Вы выйдете из большинства сайтов';

  @override
  String get user_deleteBrowsingDataTypeCacheTitle =>
      'Кешированные изображения и файлы';

  @override
  String get user_deleteBrowsingDataTypeCacheDescription =>
      'Освобождает место в хранилище';

  @override
  String get user_deleteBrowsingDataTypePermissionsTitle => 'Разрешения сайтов';

  @override
  String get user_deleteBrowsingDataTypeDownloadsTitle => 'Загрузки';

  @override
  String get wallpaper_title => 'Обои';

  @override
  String get wallpaper_settingsDescription =>
      'Показываются за домашней страницей во всех контейнерах, где не заданы собственные обои.';

  @override
  String get wallpaper_chooseImage => 'Выбрать изображение';

  @override
  String get wallpaper_replace => 'Заменить';

  @override
  String get wallpaper_blurLabel => 'Размытие';

  @override
  String get wallpaper_dimLabel => 'Затемнение';

  @override
  String get wallpaper_dimDescription =>
      'Затемнение смешивает изображение с фоном приложения, чтобы текст на странице оставался читаемым и в светлой, и в тёмной теме.';

  @override
  String get wallpaper_editorDefaultDescription =>
      'Домашняя страница сохраняет стандартный фон.';

  @override
  String get wallpaper_importErrorUnreadable =>
      'Не удалось прочитать этот файл';

  @override
  String get wallpaper_importErrorTooLarge => 'Это изображение слишком большое';

  @override
  String get wallpaper_importErrorNotAnImage =>
      'Этот файл не является изображением';

  @override
  String get wallpaper_importErrorDecodeFailed =>
      'Не удалось прочитать это изображение';

  @override
  String get webFeed_addFeedTitle => 'Добавить ленту';

  @override
  String get webFeed_fieldUrlLabel => 'URL-адрес';

  @override
  String get webFeed_actionIgnore => 'Игнорировать';

  @override
  String get webFeed_unnamedFeedTitle => 'Лента без названия';

  @override
  String get webFeed_unnamedArticleTitle => 'Статья без названия';

  @override
  String get webFeed_fetchFeedFailedTitle => 'Не удалось получить ленту';

  @override
  String get webFeed_feedsTitle => 'Ленты';

  @override
  String get webFeed_loadFeedsFailedTitle => 'Не удалось загрузить ленты';

  @override
  String get webFeed_feedFabLabel => 'Добавить ленту';

  @override
  String get webFeed_loadFeedFailedTitle => 'Не удалось загрузить ленту';

  @override
  String get webFeed_newFeedTitle => 'Новая лента';

  @override
  String get webFeed_editFeedTitle => 'Изменить ленту';

  @override
  String get webFeed_fetchingFeedMessage => 'Получение ленты…';

  @override
  String get webFeed_fieldTitleLabel => 'Название';

  @override
  String get webFeed_fieldDescriptionLabel => 'Описание';

  @override
  String get webFeed_fieldIconUrlLabel => 'URL-адрес значка';

  @override
  String get webFeed_fieldSiteLinkLabel => 'Ссылка на сайт';

  @override
  String get webFeed_fieldFeedUrlLabel => 'URL-адрес ленты';

  @override
  String get webFeed_deleteFeedTitle => 'Удалить ленту';

  @override
  String get webFeed_deleteFeedConfirm => 'Удалить эту ленту и все её статьи?';

  @override
  String get webFeed_articlesTitle => 'Статьи';

  @override
  String get webFeed_searchLabel => 'Поиск';

  @override
  String get webFeed_loadArticlesFailedTitle => 'Не удалось загрузить статьи';

  @override
  String webFeed_publishedLabel(String date) {
    return 'Опубликовано: $date';
  }

  @override
  String get webFeed_notAvailable => 'Н/Д';

  @override
  String webFeed_updatedLabel(String date) {
    return 'Обновлено: $date';
  }

  @override
  String get webFeed_authorsLabel => 'Авторы:';

  @override
  String get webFeed_tagsLabel => 'Теги:';

  @override
  String get webFeed_readArticleFailedTitle => 'Не удалось загрузить статью';

  @override
  String webFeed_lastFetchedLabel(String date) {
    return 'Последнее получение: $date';
  }

  @override
  String get webFeed_tagsFieldLabel => 'Теги';

  @override
  String get webPush_screenTitle => 'Уведомления';

  @override
  String get webPush_screenSubtitle =>
      'Уведомления сайтов, доставляемые через UnifiedPush';

  @override
  String get webPush_distributorTileTitle => 'Дистрибьютор UnifiedPush';

  @override
  String get webPush_distributorTileKeywords =>
      'уведомления, push, пуш, unifiedpush, ntfy, дистрибьютор';

  @override
  String get webPush_checking => 'Проверка…';

  @override
  String webPush_couldNotReadStatus(String error) {
    return 'Не удалось прочитать состояние push: $error';
  }

  @override
  String get webPush_updatingDistributor => 'Обновление…';

  @override
  String get webPush_registrationRecovering =>
      'Восстановление после ошибки регистрации…';

  @override
  String webPush_lastRegistrationError(String error) {
    return 'Последняя ошибка регистрации: $error';
  }

  @override
  String get webPush_disablingWebPush => 'Отключение…';

  @override
  String get webPush_disableWebPush => 'Отключить web push';

  @override
  String get webPush_statusNoneAvailable => 'Нет доступного дистрибьютора';

  @override
  String get webPush_statusNotSelected => 'Не настроено';

  @override
  String get webPush_statusPending => 'Подключение…';

  @override
  String get webPush_statusReady => 'Активно';

  @override
  String get webPush_statusUnavailable => 'Дистрибьютор недоступен';

  @override
  String get webPush_statusDescNoneAvailable =>
      'Установите приложение-дистрибьютор UnifiedPush, например ntfy, чтобы получать уведомления сайтов.';

  @override
  String get webPush_statusDescNotSelected =>
      'Выберите дистрибьютор ниже, чтобы включить уведомления сайтов.';

  @override
  String get webPush_statusDescPending =>
      'Ожидание подтверждения регистрации от дистрибьютора.';

  @override
  String get webPush_statusDescReady =>
      'Уведомления сайтов доставляются через этот дистрибьютор.';

  @override
  String get webPush_statusDescUnavailable =>
      'Выбранный дистрибьютор больше не установлен. Уведомления сайтов не будут доставляться, пока вы не выберете другой.';

  @override
  String get webPush_noDistributorInstalled =>
      'Дистрибьютор UnifiedPush не установлен. Установите его, например ntfy, и повторите попытку.';

  @override
  String get webPush_chooseDistributorTitle => 'Выбор дистрибьютора';

  @override
  String get webPush_distributorConfigured =>
      'Дистрибьютор UnifiedPush настроен.';

  @override
  String webPush_couldNotConfigureDistributor(String error) {
    return 'Не удалось настроить дистрибьютор: $error';
  }

  @override
  String get webPush_webPushDisabled => 'Web push отключён.';

  @override
  String webPush_couldNotDisableWebPush(String error) {
    return 'Не удалось отключить web push: $error';
  }

  @override
  String get webPush_notificationPermissionTitle => 'Разрешение на уведомления';

  @override
  String get webPush_notificationPermissionKeywords =>
      'уведомления, разрешение, оповещения';

  @override
  String webPush_notificationPermissionCouldNotRead(String error) {
    return 'Не удалось прочитать состояние разрешения: $error';
  }

  @override
  String get webPush_notificationPermissionGranted => 'Предоставлено';

  @override
  String get webPush_notificationPermissionDenied =>
      'Отклонено. Push-сообщения по-прежнему приходят, но уведомления не могут отображаться.';

  @override
  String get webPush_grantAction => 'Предоставить';

  @override
  String webPush_couldNotUpdatePermission(String error) {
    return 'Не удалось обновить разрешение на уведомления: $error';
  }

  @override
  String get webPush_loadingSubscriptions => 'Загрузка подписок…';

  @override
  String get webPush_couldNotReadSubscriptions =>
      'Не удалось прочитать подписки';

  @override
  String get webPush_noSiteSubscriptions => 'Нет подписок сайтов';

  @override
  String get webPush_noSiteSubscriptionsDescription =>
      'Здесь появятся сайты, которым вы разрешите отправлять уведомления.';

  @override
  String get webPush_subscriptionActive => 'Активна';

  @override
  String get webPush_subscriptionDelayedDelivery =>
      'Адрес доставки сохранён; доставка приостановлена, пока дистрибьютор не будет готов';

  @override
  String get webPush_subscriptionWaitingForEndpoint =>
      'Ожидание адреса доставки от дистрибьютора';

  @override
  String get webPush_revokeSubscriptionHint =>
      'Чтобы сайт перестал отправлять уведомления, отзовите его разрешение на уведомления в настройках сайта.';

  @override
  String get webPush_deliverySectionTitle => 'Доставка';

  @override
  String get webPush_indexDistributorSubtitle =>
      'Приложение, доставляющее push-уведомления сайтов';

  @override
  String get webPush_indexNotificationPermissionSubtitle =>
      'Требуется для показа уведомлений сайтов';

  @override
  String get webPush_subscriptionsSectionTitle => 'Подписки';

  @override
  String get webPush_indexSiteSubscriptionsTitle => 'Подписки сайтов';

  @override
  String get webPush_indexSiteSubscriptionsKeywords => 'сайты, подписки';

  @override
  String get webPush_indexSiteSubscriptionsSubtitle =>
      'Сайты, на уведомления которых вы подписаны';

  @override
  String get webSearch_fetchPageDataTitle => 'Получение данных страницы';

  @override
  String get webSearch_downloadFailedTapToRetry =>
      'Ошибка загрузки — нажмите, чтобы повторить';

  @override
  String get webSearch_methodTrafilaturaTitle => 'Извлечённый предпросмотр';

  @override
  String get webSearch_methodSinglefileTitle => 'Полный снимок страницы';

  @override
  String get webSearch_methodPdfTitle => 'Снимок в PDF';

  @override
  String get webSearch_methodPngTitle => 'Снимок-изображение';

  @override
  String get webSearch_methodTrafilaturaSubtitle =>
      'Текст и метаданные, оптимизированные для чтения во встроенном предпросмотре';

  @override
  String get webSearch_methodSinglefileSubtitle =>
      'Сохранить страницу целиком, с разметкой и ресурсами, для последующего использования';

  @override
  String get webSearch_methodPdfSubtitle =>
      'Преобразовать страницу в PDF для чтения офлайн и отправки';

  @override
  String get webSearch_methodPngSubtitle =>
      'Сделать PNG-снимок всей отрисованной страницы';

  @override
  String get webSearch_previewUnavailableTitle => 'Предпросмотр недоступен';

  @override
  String get webSearch_previewUnavailableMessage =>
      'Перед открытием предпросмотра получите страницу из списка результатов.';

  @override
  String get webSearch_openInBrowserTooltip => 'Открыть в браузере';

  @override
  String webSearch_torToggleOn(String brand) {
    return '$brand вкл.';
  }

  @override
  String webSearch_torToggleOff(String brand) {
    return '$brand выкл.';
  }

  @override
  String get webSearch_languageAuto => 'Авто';

  @override
  String get webSearch_languageAutoDeviceDefault => 'Авто (как на устройстве)';

  @override
  String get webSearch_countryAny => 'Любой';

  @override
  String get webSearch_countryAnyRegion => 'Любой регион';

  @override
  String webSearch_countryDeviceDefault(String name) {
    return '$name (устройство)';
  }

  @override
  String get webSearch_safeSearchPillDefault => 'Фильтр: по умолч.';

  @override
  String get webSearch_safeSearchPillOff => 'Фильтр: выкл.';

  @override
  String get webSearch_safeSearchPillModerate => 'Фильтр: умеренный';

  @override
  String get webSearch_safeSearchPillStrict => 'Фильтр: строгий';

  @override
  String get webSearch_safeSearchMenuDefault => 'По умолчанию (умеренный)';

  @override
  String get webSearch_safeSearchMenuOff => 'Выключен';

  @override
  String get webSearch_safeSearchMenuModerate => 'Умеренный';

  @override
  String get webSearch_safeSearchMenuStrict => 'Строгий';

  @override
  String get webSearch_freshnessAnyTime => 'За всё время';

  @override
  String get webSearch_freshnessPastDay => 'За сутки';

  @override
  String get webSearch_freshnessPastWeek => 'За неделю';

  @override
  String get webSearch_freshnessPastMonth => 'За месяц';

  @override
  String get webSearch_freshnessPastYear => 'За год';

  @override
  String get webSearch_modeGeneralLabel => 'Общий';

  @override
  String get webSearch_modeIndependentWebLabel => 'Независимый веб';

  @override
  String get webSearch_modeSmallWebLabel => 'Малый веб';

  @override
  String get webSearch_modeGeneralDescription =>
      'Сбалансированные результаты по всему открытому вебу';

  @override
  String get webSearch_modeIndependentWebDescription =>
      'Предпочитать небольшие и некорпоративные источники';

  @override
  String get webSearch_modeSmallWebDescription =>
      'Независимые, личные и нишевые сайты';

  @override
  String get webSearch_fetchTooltip => 'Получить';

  @override
  String get webSearch_additionalSnippetsHeading => 'Дополнительные фрагменты';

  @override
  String get webSearch_questionPrefix => 'В: ';

  @override
  String get webSearch_snippetsTooltip => 'Фрагменты';

  @override
  String webSearch_showMoreLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показать ещё $count ссылки',
      many: 'Показать ещё $count ссылок',
      few: 'Показать ещё $count ссылки',
      one: 'Показать ещё $count ссылку',
    );
    return '$_temp0';
  }

  @override
  String get webSearch_factsheetHeading => 'Справка';

  @override
  String get webSearch_searchFailedTitle => 'Ошибка поиска';

  @override
  String get webSearch_searchingLabel => 'Поиск в интернете…';

  @override
  String webSearch_noResultsFor(String query) {
    return 'По запросу «$query» ничего не найдено.';
  }

  @override
  String webSearch_creditsTokensStatus(int credits, int tokens) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '$credits кредита',
      many: '$credits кредитов',
      few: '$credits кредита',
      one: '$credits кредит',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tokens,
      locale: localeName,
      other: '$tokens токена',
      many: '$tokens токенов',
      few: '$tokens токена',
      one: '$tokens токен',
    );
    return '$_temp0  |  $_temp1';
  }

  @override
  String get webSearch_needsCreditsMessage =>
      'Для нового веб-поиска нет доступных поисковых кредитов или токенов.';

  @override
  String get webSearch_buySearchPackButton => 'Купить поисковый пакет';

  @override
  String get webSearch_socketConnectionError =>
      'Ошибка соединения с поиском. Повторите попытку.';

  @override
  String get webSearch_closeErrorSessionTimeout =>
      'Время сеанса поиска истекло. Повторите попытку.';

  @override
  String get webSearch_closeErrorCreditInvalid =>
      'Не удалось проверить поисковый кредит. Возможно, он уже израсходован — повторите попытку.';

  @override
  String get webSearch_closeErrorPolicyForbidden =>
      'Запрошенная страница не разрешена политикой поиска.';

  @override
  String get webSearch_closeErrorServerFailed =>
      'Ошибка поиска на сервере. Повторите попытку.';

  @override
  String webSearch_closeErrorUnknown(int code) {
    return 'Соединение с поиском неожиданно закрыто (код $code). Повторите попытку.';
  }

  @override
  String get webSearch_unknownErrorDetail => 'неизвестная ошибка';

  @override
  String webSearch_streamErrorProtocol(String detail) {
    return 'Ошибка протокола поиска. Сеанс завершён — повторите попытку. ($detail)';
  }

  @override
  String webSearch_streamErrorSearchFailed(String detail) {
    return 'Ошибка поиска на сервере. Повторите попытку. ($detail)';
  }

  @override
  String webSearch_streamErrorFetchFailed(String detail) {
    return 'Не удалось получить эту страницу из источника. ($detail)';
  }

  @override
  String webSearch_streamErrorExtractFailed(String detail) {
    return 'Не удалось извлечь читаемый предпросмотр из этой страницы. ($detail)';
  }

  @override
  String webSearch_streamErrorNotAllowed(String detail) {
    return 'Эта страница не разрешена политикой поиска. ($detail)';
  }

  @override
  String webSearch_streamErrorCaptureFailed(String detail) {
    return 'Не удалось сделать снимок страницы. ($detail)';
  }

  @override
  String webSearch_streamErrorGeneric(String detail) {
    return 'Ошибка поиска: $detail';
  }

  @override
  String webSearch_torStartFailed(String torBrand) {
    return 'Не удалось запустить $torBrand для поиска. Отключите переключатель $torBrand или повторите попытку.';
  }

  @override
  String get webSearch_creditCheckFailed =>
      'Не удалось проверить поисковые кредиты. Повторите попытку.';

  @override
  String get webSearch_tokenIssuanceFailed =>
      'Не удалось выдать поисковые токены. Повторите попытку.';

  @override
  String get mainApp_initializationErrorTitle => 'Ошибка инициализации';

  @override
  String get mainApp_initializationErrorMessage =>
      'Не удалось инициализировать приложение';

  @override
  String get mainApp_initStageLoadingFormats => 'Загрузка форматов…';

  @override
  String get mainApp_initStageLoadingPackageInfo =>
      'Загрузка сведений о приложении…';

  @override
  String get mainApp_initStageSyncingBangs => 'Синхронизация бэнгов…';

  @override
  String get mainApp_downloadCompleted => 'Загрузка завершена';

  @override
  String get mainApp_downloadOpenFailed =>
      'Не удалось открыть загруженный файл';

  @override
  String mainApp_downloadFailed(String name) {
    return 'Ошибка загрузки: $name';
  }

  @override
  String mainApp_containerBlockedWithHost(String host) {
    return '$host не назначен этому контейнеру';
  }

  @override
  String get mainApp_containerBlockedNoHost =>
      'Этот сайт не назначен этому контейнеру';

  @override
  String get mainApp_sandboxNoCredits =>
      'Поисковые кредиты закончились. Купите ещё, чтобы продолжить.';

  @override
  String get mainApp_sandboxTokenIssuanceFailed =>
      'Не удалось выдать новые поисковые токены. Проверьте подключение и повторите попытку.';

  @override
  String mainApp_sandboxFetchPolicyRejected(String detail) {
    return 'Снимок заблокирован политикой загрузки: $detail';
  }

  @override
  String get mainApp_sandboxDetailNotAllowed => 'не разрешено';

  @override
  String mainApp_sandboxCaptureFailed(String detail) {
    return 'Не удалось сделать снимок: $detail';
  }

  @override
  String get mainApp_sandboxDetailUnknownError => 'неизвестная ошибка';

  @override
  String get mainApp_sandboxDownloadFailed =>
      'Не удалось загрузить результат снимка.';

  @override
  String mainApp_sandboxUnknownError(String detail) {
    return 'Ошибка снимка в песочнице: $detail';
  }

  @override
  String get mainApp_syncFailed => 'Ошибка синхронизации';

  @override
  String get startup_pickerTitle => 'Выберите профиль';

  @override
  String startup_pickerEachProfileKeepsOwn(String contents) {
    return 'Каждый профиль хранит свои $contents.';
  }

  @override
  String get startup_pickerOpensByDefaultLocked =>
      'Открывается по умолчанию · Заблокирован';

  @override
  String get startup_pickerOpensByDefault => 'Открывается по умолчанию';

  @override
  String get startup_pickerLocked => 'Заблокирован';

  @override
  String get startup_haltMaintenanceTitle =>
      'Незавершённые операции с профилем';

  @override
  String get startup_haltMaintenanceBody =>
      'Резервное копирование, восстановление или удаление, начатое при прошлом запуске, не завершилось. WebLibre должен завершить его, прежде чем откроется любой профиль.';

  @override
  String get startup_haltUnavailableTitle => 'Запуск не готов';

  @override
  String startup_haltUnavailableBody(String reopenToContinue) {
    return 'WebLibre нужно перезапустить, прежде чем он сможет выбрать профиль. $reopenToContinue';
  }

  @override
  String get startup_haltProfileAccessBusyTitle => 'Профиль используется';

  @override
  String get startup_haltProfileAccessBusyBody =>
      'Этот профиль ещё использует другая задача WebLibre. Повторите попытку чуть позже.';

  @override
  String get startup_haltNoProfileTitle => 'Нет доступного профиля';

  @override
  String get startup_haltNoProfileBody =>
      'WebLibre не удалось прочитать существующий профиль или создать новый. Возможно, хранилище заполнено или недоступно.';

  @override
  String get startup_haltArbitrationFailedTitle =>
      'Невозможно определить, какой профиль открыть';

  @override
  String startup_haltArbitrationFailedBody(String reopenToContinue) {
    return 'WebLibre не будет гадать, какой профиль использовать. $reopenToContinue';
  }

  @override
  String get startup_tryAgain => 'Повторить';

  @override
  String get startup_tryingAgain => 'Повторная попытка…';

  @override
  String get startup_closeWebLibre => 'Закрыть WebLibre';

  @override
  String get startup_technicalDetails => 'Технические подробности';

  @override
  String get startup_copyDetails => 'Копировать подробности';

  @override
  String get startup_maintenanceFinishingInterrupted =>
      'Завершение операции, прерванной предыдущим перезапуском…';

  @override
  String get startup_maintenanceNotRunnableUnsupported =>
      'Эта задача создана более новой версией WebLibre и не может быть выполнена здесь.';

  @override
  String get startup_maintenanceNotRunnableNoDestination =>
      'Для этой резервной копии не записана папка назначения.';

  @override
  String get startup_maintenanceNotRunnableNoBackupFile =>
      'Для этого восстановления не записан файл резервной копии.';

  @override
  String get startup_maintenanceNotRunnableRestoreHere =>
      'WebLibre не может выполнить восстановление с этого экрана запуска.';

  @override
  String get startup_maintenanceNotRunnableDeleteHere =>
      'WebLibre не может удалить профиль с этого экрана запуска.';

  @override
  String get startup_maintenanceRecoveredRestore =>
      'Прерванное восстановление завершено.';

  @override
  String get startup_maintenanceRecoveredRestoreRolledBack =>
      'Прерванное восстановление отменено. Профиль остался без изменений.';

  @override
  String get startup_maintenanceRecoveredRestoreReconciled =>
      'Прерванное восстановление приведено в порядок. Проверьте профиль, чтобы узнать, была ли применена резервная копия.';

  @override
  String get startup_maintenanceRecoveredDeletion =>
      'Прерванное удаление завершено.';

  @override
  String get startup_maintenanceTaskDidNotFinish => 'Операция не завершилась.';

  @override
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  ) {
    return 'WebLibre больше не может безопасно работать с этим профилем. $nothingChanged $reopenToContinue';
  }

  @override
  String startup_maintenanceTaskCancelled(String task) {
    return 'Отменено: $task.';
  }

  @override
  String get startup_maintenanceEvidenceDiscarded =>
      'Запись о прерванной операции удалена.';

  @override
  String get startup_maintenanceEvidenceDiscardedKept =>
      'Запись о прерванной операции удалена. WebLibre не смог определить, какому профилю принадлежат сохранённые данные, поэтому оставил их на устройстве, а не удалил.';

  @override
  String startup_maintenanceWrongPassword(String nothingChanged) {
    return 'Этот пароль не подходит к файлу резервной копии. Проверьте его и повторите попытку. $nothingChanged';
  }

  @override
  String startup_maintenanceUnreadableArchive(String nothingChanged) {
    return 'Пароль не подходит к этому файлу резервной копии, или файл повреждён. Проверьте пароль и повторите попытку. $nothingChanged';
  }

  @override
  String startup_maintenanceDamagedArchive(String nothingChanged) {
    return 'Этот файл резервной копии повреждён и не может быть прочитан. $nothingChanged';
  }

  @override
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged) {
    return 'Этот файл резервной копии создан более новой версией WebLibre и не может быть прочитан здесь. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  ) {
    return 'Недостаточно свободного места: нужно около $required, а доступно только $free. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  ) {
    return 'Недостаточно свободного места: нужно около $required. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged) {
    return 'Недостаточно свободного места для этой операции. $nothingChanged';
  }

  @override
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged) {
    return 'Не удалось записать резервную копию в папку. Выберите папку заново и повторите попытку. $nothingChanged';
  }

  @override
  String get startup_maintenanceProfileNoLongerExists =>
      'Этот профиль больше не существует.';

  @override
  String get startup_maintenanceRestoreEvidenceUnresolved =>
      'Предыдущая попытка этого восстановления оставила запись, которая ещё не обработана.';

  @override
  String get startup_maintenanceRestoreWrongProfile =>
      'Эта резервная копия не соответствует профилю, который она должна была заменить.';

  @override
  String get startup_maintenanceRestoreRejected =>
      'Этот файл резервной копии нельзя восстановить.';

  @override
  String get startup_maintenanceRestoreIncomplete =>
      'Файл резервной копии неполон.';

  @override
  String get startup_maintenanceRestoreNoMetadata =>
      'В файле резервной копии нет метаданных профиля.';

  @override
  String get startup_maintenanceRestoreMalformedMetadata =>
      'Не удалось прочитать метаданные профиля в файле резервной копии.';

  @override
  String get startup_maintenanceRestoreNoProfileData =>
      'В файле резервной копии нет данных профиля.';

  @override
  String get startup_maintenanceHeadline => 'Обслуживание профилей';

  @override
  String get startup_maintenanceMustFinish =>
      'Эта задача должна завершиться, прежде чем откроется любой профиль. Пока она выполняется, WebLibre держит профиль закрытым.';

  @override
  String get startup_maintenanceNothingLeft =>
      'Незавершённых задач не осталось.';

  @override
  String get startup_maintenanceCannotReadRecord =>
      'WebLibre обнаружил прерванную операцию с профилем, но не может прочитать её запись.';

  @override
  String get startup_maintenancePasswordLabel => 'Пароль файла резервной копии';

  @override
  String get startup_maintenancePasswordRejected =>
      'Этот пароль не подходит к файлу резервной копии';

  @override
  String get startup_maintenancePasswordHelperRequiredBackup =>
      'Обязательно. Он понадобится для восстановления резервной копии и нигде не сохраняется.';

  @override
  String get startup_maintenancePasswordHelperRequiredRestore =>
      'Обязательно. Введите пароль, с которым был создан этот файл резервной копии.';

  @override
  String get startup_maintenancePasswordHelperBackup =>
      'Он понадобится для восстановления резервной копии. Пароль нигде не сохраняется.';

  @override
  String get startup_maintenancePasswordHelperRestore =>
      'Пароль, с которым был создан этот файл резервной копии.';

  @override
  String get startup_maintenanceTryFinishingAgain =>
      'Попробовать завершить снова';

  @override
  String get startup_maintenanceDiscardAndContinueBlocked =>
      'Удалить запись и продолжить';

  @override
  String get startup_maintenanceDiscardAndContinueNoTasks =>
      'Удалить запись и продолжить';

  @override
  String get startup_maintenanceOpenWebLibreRetry => 'Открыть WebLibre';

  @override
  String get startup_maintenanceOpenWebLibre => 'Открыть WebLibre';

  @override
  String get startup_maintenanceTakesSeveralMinutes =>
      'Это может занять несколько минут. Не закрывайте WebLibre.';

  @override
  String get startup_maintenanceThenAfterThisOne => 'Затем, после этой задачи';

  @override
  String get startup_maintenanceSkipForNow => 'Пропустить пока';

  @override
  String get startup_maintenanceInterruptedMustFinish =>
      'Эта операция была прервана после начала. Она должна завершиться, прежде чем откроется любой профиль.';

  @override
  String get startup_maintenanceInterruptedFinishFailed =>
      'Эта операция была прервана после начала, и завершить её не удалось. Начать её заново можно только после завершения.';

  @override
  String get startup_maintenanceInterruptedUnreadable =>
      'Эта операция была прервана после начала, и WebLibre не может прочитать, что она делала. Запустить её снова можно только после обработки этой записи.';

  @override
  String get startup_maintenanceDiscardDialogTitle =>
      'Удалить запись о прерванной операции?';

  @override
  String get startup_maintenanceDiscardDialogContent =>
      'WebLibre не может прочитать, что делало резервное копирование, восстановление или удаление в момент остановки. Удаление записи позволит браузеру снова открыться, но профиль, который заменялся, возможно, потребуется потом проверить.\n\nЕсли профиль отсутствует, WebLibre восстановит данные, сохранённые перед его заменой. Если профиль на месте, WebLibre удалит эти сохранённые данные. Если WebLibre не может определить, какому профилю принадлежат сохранённые данные, он оставит их, а не удалит.';

  @override
  String get startup_maintenanceDiscardIt => 'Удалить';

  @override
  String get startup_maintenanceBackupVerb => 'Создать копию сейчас';

  @override
  String get startup_maintenanceBackupRetry =>
      'Повторить резервное копирование';

  @override
  String get startup_maintenanceBackupCancel =>
      'Отменить резервное копирование';

  @override
  String startup_maintenanceBackupDescribe(String profileName) {
    return 'Резервная копия «$profileName»';
  }

  @override
  String startup_maintenanceBackupConsequence(String secretDataDescription) {
    return 'Создаёт зашифрованный файл резервной копии этого профиля, включая следующие данные: $secretDataDescription.';
  }

  @override
  String startup_maintenanceBackupActivity(String profileName) {
    return 'Упаковка «$profileName»…';
  }

  @override
  String startup_maintenanceBackupDescribeDone(String profileName) {
    return 'Резервная копия «$profileName» сохранена в выбранную папку.';
  }

  @override
  String get startup_maintenanceRestoreOverVerb => 'Заменить сейчас';

  @override
  String get startup_maintenanceRestoreOverRetry => 'Повторить восстановление';

  @override
  String get startup_maintenanceRestoreOverCancel => 'Отменить восстановление';

  @override
  String startup_maintenanceRestoreOverDescribe(String profileName) {
    return 'Замена «$profileName»';
  }

  @override
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Заменяет всё содержимое этого профиля резервной копией. $signedInFromBackup $olderBackupKeepsCredentials Профиль также получит имя из резервной копии. $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Заменяет всё содержимое этого профиля резервной копией. $signedInFromBackup $olderBackupKeepsCredentials $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverActivity(String profileName) {
    return 'Замена «$profileName»…';
  }

  @override
  String startup_maintenanceRestoreOverDescribeDone(String profileName) {
    return '«$profileName» заменён резервной копией.';
  }

  @override
  String get startup_maintenanceDeleteVerb => 'Удалить сейчас';

  @override
  String get startup_maintenanceDeleteRetry => 'Повторить удаление';

  @override
  String get startup_maintenanceDeleteCancel => 'Отменить удаление';

  @override
  String startup_maintenanceDeleteDescribe(String profileName) {
    return 'Удаление «$profileName»';
  }

  @override
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Удаляет этот профиль и его данные: $profileDataDescription. $cannotBeUndone';
  }

  @override
  String startup_maintenanceDeleteActivity(String profileName) {
    return 'Удаление «$profileName»…';
  }

  @override
  String startup_maintenanceDeleteDescribeDone(String profileName) {
    return '«$profileName» удалён.';
  }

  @override
  String get startup_maintenanceRestoreCloneVerb => 'Невозможно выполнить';

  @override
  String get startup_maintenanceRestoreCloneRetry => 'Повторить восстановление';

  @override
  String get startup_maintenanceRestoreCloneCancel => 'Отменить восстановление';

  @override
  String startup_maintenanceRestoreCloneDescribe(String profileName) {
    return 'Восстановление «$profileName»';
  }

  @override
  String get startup_maintenanceRestoreCloneConsequence =>
      'Это восстановление создано более новой версией WebLibre и не может быть выполнено здесь.';

  @override
  String startup_maintenanceRestoreCloneActivity(String profileName) {
    return 'Восстановление «$profileName»…';
  }

  @override
  String startup_maintenanceRestoreCloneDescribeDone(String profileName) {
    return '«$profileName» восстановлен.';
  }

  @override
  String get startup_maintenanceUnknownVerb => 'Выполнить';

  @override
  String get startup_maintenanceUnknownRetry => 'Повторить задачу';

  @override
  String get startup_maintenanceUnknownCancel => 'Отменить задачу';

  @override
  String startup_maintenanceUnknownDescribe(String taskId) {
    return 'Неизвестная задача $taskId';
  }

  @override
  String get startup_maintenanceUnknownConsequence =>
      'Эта задача создана более новой версией WebLibre и не может быть выполнена.';

  @override
  String get startup_maintenanceUnknownActivity => 'Выполняется…';

  @override
  String get startup_maintenanceUnknownDescribeDone => 'Готово.';

  @override
  String units_bytes(String value) {
    return '$value Б';
  }

  @override
  String units_kilobytes(String value) {
    return '$value КБ';
  }

  @override
  String units_megabytes(String value) {
    return '$value МБ';
  }

  @override
  String units_milliseconds(String value) {
    return '$value мс';
  }

  @override
  String get failureWidget_defaultTitle => 'Что-то пошло не так';

  @override
  String get failureWidget_unknownError => 'Неизвестная ошибка';

  @override
  String get speechToTextButton_serviceNotAvailable =>
      'Распознавание речи недоступно';

  @override
  String get formValidators_urlRequired => 'Требуется URL-адрес';

  @override
  String get formValidators_invalidUrl => 'Недопустимый URL-адрес';

  @override
  String get formValidators_valueRequired => 'Требуется значение';

  @override
  String get formValidators_nameRequired => 'Требуется имя';

  @override
  String get formValidators_nameInvalidCharacters =>
      'Имя содержит недопустимые символы';

  @override
  String uiHelper_findInPageSuggestion(String query) {
    return 'Найти «$query» на этой странице?';
  }

  @override
  String get uiHelper_actionFind => 'Найти';

  @override
  String uiHelper_openedTabsFromAnotherDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыто $count вкладки с другого устройства',
      many: 'Открыто $count вкладок с другого устройства',
      few: 'Открыто $count вкладки с другого устройства',
      one: 'Открыта $count вкладка с другого устройства',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_navigateBackToCloseTab =>
      'Нажмите НАЗАД ещё раз, чтобы закрыть текущую вкладку';

  @override
  String get uiHelper_navigateBackToExitApp =>
      'Нажмите НАЗАД ещё раз, чтобы выйти из приложения';

  @override
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName) {
    return 'Новая вкладка «$tabName» открыта в фоне';
  }

  @override
  String get uiHelper_newTabOpenedInBackground =>
      'Новая вкладка открыта в фоне';

  @override
  String get uiHelper_actionShow => 'Показать';

  @override
  String get uiHelper_wantToOpenLinkFromClipboard =>
      'Открыть ссылку из буфера обмена?';

  @override
  String uiHelper_newTabOpenedNamed(String tabName) {
    return 'Новая вкладка «$tabName» открыта';
  }

  @override
  String get uiHelper_newTabOpened => 'Новая вкладка открыта';

  @override
  String get uiHelper_actionSwitch => 'Перейти';

  @override
  String uiHelper_couldNotLaunchUrl(String url) {
    return 'Не удалось открыть URL-адрес ($url)';
  }

  @override
  String uiHelper_canNotHandleScheme(String scheme) {
    return 'Невозможно обработать «$scheme»';
  }

  @override
  String uiHelper_tabsClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вкладки закрыто',
      many: '$count вкладок закрыто',
      few: '$count вкладки закрыты',
      one: '$count вкладка закрыта',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_closeIsolatedTabsTitle =>
      'Закрыть изолированные вкладки?';

  @override
  String uiHelper_closeIsolatedTabsConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Данные просмотра $count изолированного сеанса будут безвозвратно удалены.',
      many:
          'Данные просмотра $count изолированных сеансов будут безвозвратно удалены.',
      few:
          'Данные просмотра $count изолированных сеансов будут безвозвратно удалены.',
      one:
          'Данные просмотра $count изолированного сеанса будут безвозвратно удалены.',
    );
    return '$_temp0';
  }
}
