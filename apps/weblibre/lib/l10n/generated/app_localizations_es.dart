// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_add => 'Añadir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_remove => 'Quitar';

  @override
  String get common_clear => 'Borrar';

  @override
  String get common_copy => 'Copiar';

  @override
  String get common_open => 'Abrir';

  @override
  String get common_reset => 'Restablecer';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_done => 'Hecho';

  @override
  String get common_undo => 'Deshacer';

  @override
  String get common_dismiss => 'Descartar';

  @override
  String get common_discard => 'Descartar';

  @override
  String get common_showLess => 'Mostrar menos';

  @override
  String get common_loading => 'Cargando…';

  @override
  String get profileCopy_pickerContents => 'pestañas, historial y ajustes';

  @override
  String get profileCopy_dataDescription =>
      'pestañas, historial, marcadores, ajustes e inicios de sesión guardados';

  @override
  String get profileCopy_secretDataDescription =>
      'inicio de sesión de la cuenta de WebLibre, configuración de sincronización y datos de proxy';

  @override
  String get profileCopy_cannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String get profileCopy_nothingChanged => 'No se ha modificado nada.';

  @override
  String get profileCopy_restartsToWork =>
      'WebLibre tiene que reiniciarse para hacer esto.';

  @override
  String get profileCopy_asksPasswordAfterRestart =>
      'Tras reiniciarse, WebLibre pide la contraseña del archivo de copia de seguridad.';

  @override
  String get profileCopy_reopenToContinue =>
      'Cierra WebLibre y vuelve a abrirlo.';

  @override
  String get profileCopy_signedInFromBackup =>
      'El perfil restaurado usa la cuenta de WebLibre de la copia de seguridad.';

  @override
  String get profileCopy_olderBackupKeepsCredentials =>
      'Una copia de seguridad creada con una versión anterior de WebLibre no contiene ninguno de estos datos, y el perfil conserva los que tiene ahora.';

  @override
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged) {
    return 'WebLibre no pudo programar el reinicio necesario para esta operación. $nothingChanged';
  }

  @override
  String get profileCopy_shortcutsNeedPinningAgain =>
      'Después de restaurar, vuelve a añadir los accesos directos a la pantalla de inicio.';

  @override
  String get profileCopy_restartClosesCurrentProfile =>
      'También cierra el perfil que estás usando ahora, que no siempre es el perfil indicado aquí.';

  @override
  String get profileCopy_restartKeepsOtherTabs =>
      'Tus demás pestañas se vuelven a abrir después.';

  @override
  String profileCopy_privateTabsClosedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se cierran $count pestañas privadas y se borran sus datos de navegación.',
      one: 'Se cierra 1 pestaña privada y se borran sus datos de navegación.',
    );
    return '$_temp0';
  }

  @override
  String profileCopy_containersClearedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se borran los datos de $count contenedores configurados para borrarlos al salir.',
      one:
          'Se borran los datos de 1 contenedor configurado para borrarlos al salir.',
    );
    return '$_temp0';
  }

  @override
  String get httpErrorHandler_socketError =>
      'No se pudo contactar con el servicio remoto';

  @override
  String get httpErrorHandler_httpError => 'La solicitud web devolvió un error';

  @override
  String get httpErrorHandler_formatError => 'Formato de respuesta incorrecto';

  @override
  String get httpErrorHandler_clientError =>
      'No se pudo contactar con el servicio remoto';

  @override
  String profileDiscovery_recoveredProfileName(String idFragment) {
    return 'Perfil recuperado $idFragment';
  }

  @override
  String get about_copyright => 'Copyright © Fabian Freund, 2024-2026';

  @override
  String get about_geckoVersionTitle => 'Versión de Gecko';

  @override
  String get about_notAvailable => 'N/D';

  @override
  String get about_feedbackTitle => 'Comentarios';

  @override
  String get about_donateTitle => 'Donar';

  @override
  String get about_documentationTitle => 'Documentación';

  @override
  String get about_githubTitle => 'GitHub';

  @override
  String get account_screenTitle => 'Cuenta de WebLibre';

  @override
  String get account_searchHint => 'Buscar en los ajustes de la cuenta';

  @override
  String get account_loadFailed => 'No se pudo cargar la cuenta';

  @override
  String get account_sectionAccount => 'Cuenta';

  @override
  String get account_sectionSubscription => 'Suscripción';

  @override
  String get account_sectionSearchCredits => 'Créditos de búsqueda';

  @override
  String get account_sectionSettingsSnapshots => 'Instantáneas de ajustes';

  @override
  String get account_sectionPreferencesSnapshots =>
      'Instantáneas de preferencias';

  @override
  String get account_sectionEncryptedSync => 'Sincronización cifrada';

  @override
  String get account_signInTitle => 'Iniciar sesión en la cuenta de WebLibre';

  @override
  String get account_signInKeywords =>
      'iniciar sesión, cuenta, autenticación, sign in, login';

  @override
  String get account_signInSyncKeyKeywords =>
      'clave de sincronización, restablecer clave, sync key';

  @override
  String get account_signingInTitle => 'Iniciando sesión';

  @override
  String get account_signedInTitle => 'Cuenta con sesión iniciada';

  @override
  String get account_signInFailedTitle => 'Error al iniciar sesión';

  @override
  String get account_syncAcrossDevicesSubtitle =>
      'Sincroniza tus ajustes entre dispositivos';

  @override
  String get account_signingInSubtitle =>
      'Completa el inicio de sesión en tu navegador';

  @override
  String get account_signedInFallback => 'Sesión iniciada';

  @override
  String get account_entrySupporterSubscriptionTitle => 'Suscripción de apoyo';

  @override
  String get account_entrySupporterSubscriptionKeywords =>
      'facturación, pago, apoyo, supporter, billing';

  @override
  String get account_entrySupporterSubscriptionSubtitle =>
      'Estado, facturación y gestión de la suscripción';

  @override
  String get account_entrySearchCreditsTitle => 'Créditos de búsqueda';

  @override
  String get account_entrySearchCreditsKeywords =>
      'tokens, paquete de búsquedas, search pack';

  @override
  String get account_entrySearchCreditsSubtitle =>
      'Saldo de créditos, emisión de tokens y compras';

  @override
  String get account_entrySettingsSnapshotsTitle => 'Instantáneas de ajustes';

  @override
  String get account_entrySettingsSnapshotsKeywords =>
      'copias de seguridad, sincronizar ajustes, backups, settings sync';

  @override
  String get account_entrySettingsSnapshotsSubtitle =>
      'Guardar y restaurar los ajustes sincronizados de la aplicación';

  @override
  String get account_entryPreferencesSnapshotsTitle =>
      'Instantáneas de preferencias';

  @override
  String get account_entryPreferencesSnapshotsKeywords =>
      'copias de seguridad, sincronizar preferencias, backups, prefs sync';

  @override
  String get account_entryPreferencesSnapshotsSubtitle =>
      'Guardar y restaurar documentos de preferencias sincronizados';

  @override
  String get account_entrySetupEncryptedSyncTitle =>
      'Configurar la sincronización cifrada';

  @override
  String get account_entrySetupEncryptedSyncKeywords =>
      'clave de sincronización, copias de seguridad, instantáneas, sync key, snapshots';

  @override
  String get account_entrySetupEncryptedSyncSubtitle =>
      'Activar la sincronización cifrada de extremo a extremo con la contraseña de tu cuenta';

  @override
  String get account_actionRestore => 'Restaurar';

  @override
  String get account_actionEditLabel => 'Editar etiqueta';

  @override
  String get account_actionStore => 'Guardar';

  @override
  String get account_actionTryAgain => 'Reintentar';

  @override
  String get account_actionSignOut => 'Cerrar sesión';

  @override
  String get account_actionEnableSync => 'Activar sincronización';

  @override
  String get account_adoptTitleUsable =>
      'Aún hay un inicio de sesión antiguo en este dispositivo';

  @override
  String get account_adoptTitleUnusable =>
      'No se puede leer un inicio de sesión antiguo';

  @override
  String account_adoptBodyUsable(String name) {
    return 'WebLibre conservó un inicio de sesión de $name de antes de que los perfiles tuvieran cuentas independientes. No procede de una copia de seguridad y nada en este dispositivo indica a qué perfil pertenecía, así que WebLibre no intentará adivinarlo.';
  }

  @override
  String get account_adoptBodyUnusable =>
      'WebLibre conservó un inicio de sesión de antes de que los perfiles tuvieran cuentas independientes, pero los datos guardados están dañados y no sirven para iniciar sesión. La única forma de recuperarlo es volver a iniciar sesión; al quitarlo desaparece este mensaje.';

  @override
  String get account_adoptRetryError =>
      'No funcionó. Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get account_adoptNotMine => 'No es mío';

  @override
  String get account_adoptRemoveIt => 'Quitarlo';

  @override
  String get account_adoptUseItHere => 'Usarlo aquí';

  @override
  String get account_forgetSignInTitle => '¿Olvidar este inicio de sesión?';

  @override
  String account_forgetSignInContent(String name) {
    return 'La sesión guardada de $name se elimina de este dispositivo. Si pertenecía a otro perfil, tendrás que volver a iniciar sesión allí.';
  }

  @override
  String get account_actionForgetIt => 'Olvidarlo';

  @override
  String get account_previousSignInFallback => 'un inicio de sesión anterior';

  @override
  String account_signInAgainAs(String account) {
    return 'Volver a iniciar sesión como $account';
  }

  @override
  String get account_signInExpiredSubtitle =>
      'El inicio de sesión guardado de este perfil ha caducado. Tu clave de sincronización se conserva.';

  @override
  String get account_signingInEllipsis => 'Iniciando sesión...';

  @override
  String get account_completeSignInInApp =>
      'Completa el inicio de sesión en WebLibre';

  @override
  String get account_tooltipSignOut => 'Cerrar sesión';

  @override
  String get account_signOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get account_signOutConfirmContent =>
      '¿Seguro que quieres cerrar sesión en tu cuenta de WebLibre?';

  @override
  String get account_resetSyncKeyTitle =>
      'Restablecer la clave de sincronización';

  @override
  String get account_resetSyncKeySubtitle =>
      'Vuelve a introducir tu contraseña si la escribiste mal o la cambiaste';

  @override
  String get account_resetSyncKeyConfirmContent =>
      'Tendrás que volver a introducir la contraseña de tu cuenta. Si tu contraseña ha cambiado, las instantáneas cifradas con la contraseña anterior ya no se podrán descifrar.';

  @override
  String get account_subscriptionLoadFailed =>
      'No se pudo cargar la suscripción';

  @override
  String get account_checkConnectionRetry =>
      'Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get account_planFallbackSupporter => 'Supporter';

  @override
  String get account_badgeWillNotRenew => 'No se renovará';

  @override
  String get account_badgeActive => 'Activa';

  @override
  String account_untilDate(String date) {
    return 'Hasta el $date';
  }

  @override
  String get account_actionManageSubscription => 'Gestionar suscripción';

  @override
  String get account_badgePaused => 'En pausa';

  @override
  String get account_pausedNote =>
      'Tu suscripción está en pausa. Reanúdala desde el portal de cliente para recuperar el acceso.';

  @override
  String get account_badgePastDue => 'Pago pendiente';

  @override
  String get account_pastDueNote =>
      'Error en el pago. Actualiza tu método de pago para mantener activa tu suscripción.';

  @override
  String get account_actionUpdatePaymentMethod => 'Actualizar método de pago';

  @override
  String get account_endedNote =>
      'Tu suscripción ha finalizado. Renuévala desde el portal de cliente para continuar.';

  @override
  String get account_actionRenewSubscription => 'Renovar suscripción';

  @override
  String get account_planSupporterSubscription => 'Suscripción Supporter';

  @override
  String get account_subscribeSubtitle =>
      'Suscríbete para desbloquear las funciones de sincronización';

  @override
  String get account_badgeInactive => 'Inactiva';

  @override
  String get account_actionSubscribe => 'Suscribirse';

  @override
  String get account_tooltipRefreshStatus => 'Actualizar estado';

  @override
  String account_subscriptionEndsOn(String date) {
    return 'Tu suscripción finalizará el $date';
  }

  @override
  String get account_bannerTitle => 'Apoya a WebLibre';

  @override
  String get account_bannerBody =>
      'Supporter es una suscripción opcional que financia el desarrollo de WebLibre y ofrece las funciones que necesitan un servicio alojado para funcionar. El navegador y sus funciones de privacidad no requieren suscripción. <learnMore>Más información</learnMore>.';

  @override
  String get account_featureSearchLabel => 'WebLibre Search';

  @override
  String get account_featureSearchDescription =>
      'Una búsqueda privada y sin anuncios integrada en el navegador. Combina resultados de varias fuentes independientes, ofrece modos de búsqueda ajustables, puede enrutarse a través de Tor y permite previsualizar páginas de forma segura. Por diseño, tus búsquedas no se pueden vincular a tu cuenta.';

  @override
  String get account_featureSyncLabel => 'Sincronización cifrada de la cuenta';

  @override
  String get account_featureSyncDescription =>
      'Guarda y restaura tus ajustes y preferencias de WebLibre entre perfiles y dispositivos. Todo se cifra en tu dispositivo antes de subirse, así que solo tú puedes leerlo.';

  @override
  String get account_becomeSupporter => 'Hazte Supporter';

  @override
  String get account_syncSetupEnterPassword => 'Introduce tu contraseña';

  @override
  String get account_syncSetupPasswordsMismatch =>
      'Las contraseñas no coinciden';

  @override
  String get account_syncSetupPasswordMismatchBackup =>
      'La contraseña no coincide con tus copias de seguridad cifradas existentes.';

  @override
  String account_syncSetupFailed(String error) {
    return 'No se pudo configurar la sincronización: $error';
  }

  @override
  String get account_syncSetupTitle => 'Configurar la sincronización cifrada';

  @override
  String get account_syncSetupDescription =>
      'Introduce la contraseña de tu cuenta para activar la sincronización cifrada de extremo a extremo. Tus datos se cifran en el dispositivo antes de subirse: el servidor nunca ve tus ajustes.';

  @override
  String get account_fieldAccountPassword => 'Contraseña de la cuenta';

  @override
  String get account_fieldConfirmPassword => 'Confirmar contraseña';

  @override
  String account_failedLoadSnapshots(String error) {
    return 'No se pudieron cargar las instantáneas: $error';
  }

  @override
  String account_syncKindStored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Ajustes guardados',
      'geckoUserJs': 'Preferencias de Gecko guardadas',
      'other': 'Instantánea guardada',
    });
    return '$_temp0';
  }

  @override
  String account_syncKindSnapshotsTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Instantáneas de ajustes',
      'geckoUserJs': 'Instantáneas de preferencias de Gecko',
      'other': 'Instantáneas',
    });
    return '$_temp0';
  }

  @override
  String get account_storeCurrentTitle => 'Guardar el estado actual';

  @override
  String account_storeCurrentSubtitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Cifrar y subir los ajustes actuales',
      'geckoUserJs': 'Cifrar y subir las preferencias de Gecko actuales',
      'other': 'Cifrar y subir los datos actuales',
    });
    return '$_temp0';
  }

  @override
  String get account_noSnapshotsYet => 'Aún no hay instantáneas guardadas';

  @override
  String account_failedToStore(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String account_syncKindRestored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Ajustes restaurados',
      'geckoUserJs': 'Preferencias de Gecko restauradas',
      'other': 'Instantánea restaurada',
    });
    return '$_temp0';
  }

  @override
  String get account_snapshotNotFound => 'No se encontró la instantánea';

  @override
  String get account_decryptionFailed =>
      'Error al descifrar: contraseña incorrecta o datos dañados. Prueba a restablecer tu clave de sincronización.';

  @override
  String account_failedToRestore(String error) {
    return 'No se pudo restaurar: $error';
  }

  @override
  String account_failedUpdateLabel(String error) {
    return 'No se pudo actualizar la etiqueta: $error';
  }

  @override
  String get account_snapshotDeleted => 'Instantánea eliminada';

  @override
  String account_failedToDelete(String error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get account_untitledSnapshot => 'Sin título';

  @override
  String get account_metaLabel => 'Etiqueta';

  @override
  String get account_metaStored => 'Guardada';

  @override
  String get account_metaAppVersion => 'Versión de la aplicación';

  @override
  String get account_metaDevice => 'Dispositivo';

  @override
  String get account_storeSnapshotTitle => 'Guardar instantánea';

  @override
  String get account_fieldLabelOptional => 'Etiqueta (opcional)';

  @override
  String get account_labelHintExample =>
      'p. ej., «Antes de actualizar», «Configuración de casa»';

  @override
  String get account_fieldLabel => 'Etiqueta';

  @override
  String get account_restoreSnapshotTitle => 'Restaurar instantánea';

  @override
  String get account_restoreOverwriteWarning =>
      'Se sobrescribirán tus ajustes locales actuales.';

  @override
  String get account_thisSnapshotFallback => 'esta instantánea';

  @override
  String get account_deleteSnapshotTitle => 'Eliminar instantánea';

  @override
  String account_deleteSnapshotConfirm(String label) {
    return '¿Seguro que quieres eliminar $label?';
  }

  @override
  String get account_authNetworkError =>
      'Error de red. Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get account_authSessionExpiredWithKey =>
      'Tu inicio de sesión guardado ya no es válido. Vuelve a iniciar sesión para terminar de restaurar esta cuenta; tu clave de sincronización se conserva.';

  @override
  String get account_authSessionExpiredNoKey =>
      'Tu inicio de sesión guardado ya no es válido. Vuelve a iniciar sesión para continuar.';

  @override
  String get account_authRestoreFailedFallback =>
      'No se pudo restaurar la sesión de tu cuenta. Se reintentará en breve.';

  @override
  String get account_authSignInTimedOut =>
      'Se agotó el tiempo para iniciar sesión. Vuelve a intentarlo.';

  @override
  String get account_authSignInOpenPageFailed =>
      'No se pudo abrir la página de inicio de sesión. Vuelve a intentarlo.';

  @override
  String get account_authNoPendingSignIn =>
      'No hay ningún inicio de sesión pendiente. Vuelve a iniciar sesión desde el principio.';

  @override
  String get account_authSignInVerificationFailed =>
      'No se pudo verificar el inicio de sesión. Vuelve a intentarlo.';

  @override
  String get account_authSignInNotCompleted =>
      'No se pudo completar el inicio de sesión. Vuelve a intentarlo.';

  @override
  String get account_authSignInFailedFallback =>
      'Error al iniciar sesión. Vuelve a intentarlo.';

  @override
  String get addons_managerTitle => 'Extensiones';

  @override
  String get addons_tabInstalled => 'Instaladas';

  @override
  String get addons_tabBrowse => 'Explorar';

  @override
  String get addons_loadFailedTitle => 'No se pudieron cargar las extensiones';

  @override
  String get addons_noExtensionsFound => 'No se encontraron extensiones.';

  @override
  String get addons_noneInstalledMessage =>
      'Aún no hay extensiones instaladas.\nExplora la tienda para encontrar alguna.';

  @override
  String get addons_genericTitle => 'Extensión';

  @override
  String get addons_notFound => 'No se pudo encontrar esta extensión.';

  @override
  String get addons_platformAndroid => 'Android';

  @override
  String get addons_platformDesktop => 'Escritorio';

  @override
  String get addons_searchHint => 'Buscar en addons.mozilla.org';

  @override
  String get addons_desktopCompatibilityWarning =>
      'Las extensiones de escritorio no se revisan para móviles. Algunas pueden no funcionar, bloquearse o comportarse de forma inesperada en Android.';

  @override
  String get addons_actionInstall => 'Instalar';

  @override
  String get addons_actionInstallExtension => 'Instalar extensión';

  @override
  String get addons_actionInstallFromFile => 'Instalar desde archivo';

  @override
  String get addons_actionViewPermissions => 'Ver permisos';

  @override
  String get addons_actionRemoveExtension => 'Quitar extensión';

  @override
  String get addons_actionNotNow => 'Ahora no';

  @override
  String get addons_actionUpdate => 'Actualizar';

  @override
  String get addons_actionCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get addons_actionCheckForUpdatesButton => 'Buscar actualizaciones';

  @override
  String get addons_actionCheckingForUpdates => 'Buscando actualizaciones';

  @override
  String get addons_actionLearnMore => 'Más información';

  @override
  String get addons_actionReadMore => 'Leer más';

  @override
  String get addons_sectionEnabled => 'Activadas';

  @override
  String get addons_sectionDisabled => 'Desactivadas';

  @override
  String get addons_sectionUnsupported => 'No compatibles';

  @override
  String get addons_sectionDetails => 'Detalles';

  @override
  String get addons_sectionDescription => 'Descripción';

  @override
  String get addons_sectionManagement => 'Gestión';

  @override
  String get addons_sectionUpdates => 'Actualizaciones';

  @override
  String get addons_sectionAboutExtension => 'Acerca de esta extensión';

  @override
  String get addons_sectionTechnicalPermissions => 'Permisos técnicos';

  @override
  String get addons_sectionMoreInformation => 'Más información';

  @override
  String get addons_requiredDataCollectionTitle =>
      'Recopilación de datos obligatoria';

  @override
  String get addons_tooltipRemoveExtension => 'Quitar extensión';

  @override
  String addons_extensionRemoved(String name) {
    return 'Se quitó $name';
  }

  @override
  String addons_extensionInstalled(String name) {
    return 'Se instaló $name';
  }

  @override
  String addons_installFailed(String error) {
    return 'Error en la instalación: $error';
  }

  @override
  String get addons_updateChecksStarted =>
      'Se inició la búsqueda de actualizaciones en segundo plano para las extensiones instaladas';

  @override
  String get addons_statusInstalled => 'Instalada';

  @override
  String get addons_statusDisabled => 'Desactivada';

  @override
  String get addons_statusAvailable => 'Disponible';

  @override
  String get addons_chipPrivateBrowsing => 'Navegación privada';

  @override
  String get addons_chipRecommended => 'Recomendada';

  @override
  String get addons_removeConfirmTitle => '¿Quitar la extensión?';

  @override
  String addons_removeConfirmContent(String name) {
    return '¿Quitar $name de WebLibre?';
  }

  @override
  String get addons_autoUpdateGloballyDisabled =>
      'Las actualizaciones automáticas globales están desactivadas.';

  @override
  String get addons_autoUpdateNeedsManualRun =>
      'Actualiza manualmente una vez y reinicia la aplicación antes de poder activar las actualizaciones automáticas.';

  @override
  String get addons_autoUpdateAllow =>
      'Permitir que esta extensión reciba actualizaciones en segundo plano.';

  @override
  String get addons_autoUpdateDisabledForExtension =>
      'Las actualizaciones en segundo plano están desactivadas para esta extensión.';

  @override
  String get addons_switchEnabledTitle => 'Activada';

  @override
  String get addons_switchEnabledSubtitleAllow =>
      'Permitir que esta extensión se ejecute en WebLibre.';

  @override
  String get addons_switchEnabledSubtitleCannot =>
      'Esta extensión no se puede activar de forma segura.';

  @override
  String get addons_switchPrivateBrowsingTitle =>
      'Permitir en navegación privada';

  @override
  String get addons_switchPrivateBrowsingSubtitle =>
      'Permitir que esta extensión se ejecute en pestañas de navegación privada.';

  @override
  String get addons_switchAutoUpdateTitle => 'Actualizaciones automáticas';

  @override
  String get addons_switchPinTitle => 'Fijar en la barra de herramientas';

  @override
  String get addons_switchPinSubtitle =>
      'Mostrar esta extensión como icono en la barra de pestañas principal.';

  @override
  String get addons_menuExtensionSettingsTitle => 'Ajustes de la extensión';

  @override
  String get addons_menuExtensionSettingsSubtitleTab =>
      'Abrir la página de opciones de la extensión en una pestaña del navegador';

  @override
  String get addons_menuExtensionSettingsSubtitleInline =>
      'Abrir la página de opciones de la extensión';

  @override
  String get addons_menuFilterListsTitle => 'Listas de filtros y refuerzos';

  @override
  String get addons_menuFilterListsSubtitle =>
      'Gestionar las listas de filtros y aplicar los refuerzos de WebLibre';

  @override
  String get addons_permissionsTitle => 'Permisos';

  @override
  String addons_updateAvailable(String from, String to) {
    return 'Actualización disponible: $from → $to';
  }

  @override
  String get addons_noUpdateAttemptYet =>
      'Aún no hay información sobre intentos de actualización recientes.';

  @override
  String addons_lastChecked(String date) {
    return 'Última comprobación: $date';
  }

  @override
  String get addons_noUpdateAvailable => 'No hay actualizaciones disponibles';

  @override
  String get addons_noRemoteUpdateSource =>
      'Esta extensión instalada localmente no tiene un origen de actualizaciones remoto.';

  @override
  String get addons_updateCheckFailed =>
      'No se pudo iniciar la búsqueda de actualizaciones.';

  @override
  String get addons_updateAvailableDialogTitle => 'Actualización disponible';

  @override
  String addons_updateConfirmContent(String name, String from, String to) {
    return '¿Actualizar $name de $from a $to?';
  }

  @override
  String get addons_noDescriptionProvided =>
      'No se ha proporcionado ninguna descripción.';

  @override
  String get addons_loadingDescription => 'Cargando descripción…';

  @override
  String get addons_fieldAuthor => 'Autor';

  @override
  String get addons_fieldVersion => 'Versión';

  @override
  String get addons_fieldLastUpdated => 'Última actualización';

  @override
  String get addons_fieldLastUpdatedInfo => 'Última actualización';

  @override
  String get addons_fieldHomepage => 'Página principal';

  @override
  String get addons_fieldAddonListing => 'Ficha del complemento';

  @override
  String get addons_fieldSize => 'Tamaño';

  @override
  String get addons_fieldCategories => 'Categorías';

  @override
  String get addons_fieldLicense => 'Licencia';

  @override
  String get addons_fieldSupportSite => 'Sitio de asistencia';

  @override
  String get addons_fieldReviews => 'Reseñas';

  @override
  String get addons_fieldPrivacyPolicy => 'Política de privacidad';

  @override
  String get addons_linkViewOnAmo => 'Ver en addons.mozilla.org';

  @override
  String get addons_settingsTitleGeneric => 'Ajustes de la extensión';

  @override
  String addons_settingsTitleNamed(String name) {
    return 'Ajustes de $name';
  }

  @override
  String addons_settingsLoadFailed(String error) {
    return 'No se pudieron cargar los ajustes de la extensión: $error';
  }

  @override
  String get addons_noSettingsPage =>
      'Esta extensión no ofrece una página de ajustes.';

  @override
  String get addons_permissionsTitleGeneric => 'Permisos de la extensión';

  @override
  String addons_permissionsTitleNamed(String name) {
    return 'Permisos de $name';
  }

  @override
  String addons_permissionsLoadFailed(String error) {
    return 'No se pudieron cargar los permisos de la extensión: $error';
  }

  @override
  String get addons_noSpecialPermissions =>
      'No se indica ningún permiso especial';

  @override
  String get addons_noTranslatedPermissionDetails =>
      'Esta extensión no ofrece actualmente detalles de permisos traducidos.';

  @override
  String addons_versionSentence(String version) {
    return 'Versión $version';
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
      other: '$countString usuarios',
      one: '1 usuario',
    );
    return '$_temp0';
  }

  @override
  String addons_byAuthor(String name) {
    return 'de $name';
  }

  @override
  String get addons_permGroupRequired => 'Obligatorios';

  @override
  String get addons_permGroupWebsites => 'Sitios web';

  @override
  String get addons_permGroupOptional => 'Opcionales';

  @override
  String get addons_permGroupDataCollection => 'Recopilación de datos';

  @override
  String get addons_dateUnknown => 'Desconocida';

  @override
  String get addons_statusUpdatedSuccessfully => 'Actualizada correctamente';

  @override
  String get addons_statusNotInstalled => 'Extensión no instalada';

  @override
  String addons_updateFailedWithMessage(String message) {
    return 'Error al actualizar: $message';
  }

  @override
  String get addons_updateFailedGeneric => 'Error al actualizar';

  @override
  String get addons_noUpdateChecksRecorded =>
      'Aún no hay comprobaciones de actualización registradas';

  @override
  String get addons_statusBlocklisted =>
      'Esta extensión está en la lista de bloqueo y debe permanecer desactivada.';

  @override
  String get addons_statusNotCorrectlySigned =>
      'Esta extensión no está firmada correctamente y no se puede activar de forma segura.';

  @override
  String get addons_statusIncompatible =>
      'Esta extensión no es compatible con la versión actual de la aplicación.';

  @override
  String get addons_statusSoftBlockedEnabled =>
      'Esta extensión tiene un bloqueo leve. Ten cuidado mientras siga activada.';

  @override
  String get addons_statusSoftBlockedDisabled =>
      'Esta extensión tiene un bloqueo leve, pero aún se puede volver a activar.';

  @override
  String get addons_statusUnsupported =>
      'Esta extensión está instalada, pero WebLibre no la admite actualmente.';

  @override
  String get addons_permissionBookmarks => 'Leer y modificar marcadores';

  @override
  String get addons_permissionBrowserSettings =>
      'Leer y modificar ajustes del navegador';

  @override
  String get addons_permissionBrowsingData =>
      'Limpiar el historial de navegación reciente, cookies y datos relacionados';

  @override
  String get addons_permissionClipboardRead => 'Obtener datos del portapapeles';

  @override
  String get addons_permissionClipboardWrite =>
      'Introducir datos en el portapapeles';

  @override
  String get addons_permissionContextualIdentities =>
      'Acceder a las pestañas de contenedores y modificarlas';

  @override
  String get addons_permissionCookies =>
      'Acceder a las cookies de los sitios visitados';

  @override
  String get addons_permissionDownloads =>
      'Descargar archivos y leer y modificar el historial de descargas del navegador';

  @override
  String get addons_permissionDownloadsOpen =>
      'Abrir archivos descargados en tu dispositivo';

  @override
  String get addons_permissionFind =>
      'Leer el texto de todas las pestañas abiertas';

  @override
  String get addons_permissionGeolocation => 'Acceder a tu ubicación';

  @override
  String get addons_permissionHistory => 'Acceder al historial de navegación';

  @override
  String get addons_permissionManagement =>
      'Monitorizar el uso de extensiones y administrar temas';

  @override
  String get addons_permissionNativeMessaging =>
      'Intercambiar mensajes con programas distintos del navegador';

  @override
  String get addons_permissionNotifications => 'Mostrarte notificaciones';

  @override
  String get addons_permissionPkcs11 =>
      'Proporcionar servicios de autenticación criptográfica';

  @override
  String get addons_permissionPrivacy =>
      'Leer y modificar configuración de privacidad';

  @override
  String get addons_permissionProxy =>
      'Controlar la configuración proxy del navegador';

  @override
  String get addons_permissionSessions =>
      'Acceder a las pestañas cerradas recientemente';

  @override
  String get addons_permissionTabs => 'Acceder a las pestañas del navegador';

  @override
  String get addons_permissionTabHide =>
      'Ocultar y mostrar pestañas del navegador';

  @override
  String get addons_permissionTopSites => 'Acceder al historial de navegación';

  @override
  String get addons_permissionWebNavigation =>
      'Acceder a la actividad del navegador durante la navegación';

  @override
  String get addons_permissionAllUrls =>
      'Acceder a tus datos de todos los sitios web';

  @override
  String addons_permissionAccessDataFor(String host) {
    return 'Acceder a tus datos de $host';
  }

  @override
  String appLinks_bannerTitleNamed(String appName) {
    return '¿Abrir este enlace en $appName?';
  }

  @override
  String get appLinks_bannerTitleGeneric =>
      '¿Abrir este enlace en una aplicación?';

  @override
  String appLinks_bannerRememberFor(String scope) {
    return 'Recordar para $scope';
  }

  @override
  String get appLinks_bannerStayInBrowser => 'Seguir en el navegador';

  @override
  String get appLinks_bannerOpenApp => 'Abrir aplicación';

  @override
  String appLinks_dialogTitleNamed(String appName) {
    return '¿Abrir en $appName?';
  }

  @override
  String get appLinks_dialogTitleGeneric => '¿Abrir en otra aplicación?';

  @override
  String get appLinks_dialogBody =>
      'Este enlace lo gestiona una aplicación ajena a WebLibre.';

  @override
  String appLinks_dialogRememberFor(String scope) {
    return 'Recordar mi elección para $scope';
  }

  @override
  String get appLinks_warningProtectedContext =>
      'Este enlace está protegido aquí. La aplicación abre su propia conexión, fuera de las reglas que sigue esta pestaña.';

  @override
  String get appLinks_warningPrivateTab =>
      'Esta es una pestaña privada. La aplicación guarda su propio historial y su estado de inicio de sesión.';

  @override
  String get appLinks_warningWallet =>
      'Este enlace solicita credenciales a una aplicación de cartera. Ábrelo solo si iniciaste tú la solicitud.';

  @override
  String appLinks_settingsTitleWithContainer(String containerName) {
    return 'Enlaces de aplicaciones — $containerName';
  }

  @override
  String get appLinks_settingsTitleDefault =>
      'Enlaces de aplicaciones del contenedor';

  @override
  String get appLinks_settingsIntro =>
      'Estos ajustes solo se aplican a este contenedor y sustituyen por completo los ajustes globales de enlaces de aplicaciones para sus pestañas.';

  @override
  String get appLinks_modeAlwaysTitle => 'Siempre';

  @override
  String get appLinks_modeAlwaysSubtitle =>
      'Abrir siempre los enlaces en sus aplicaciones nativas sin preguntar';

  @override
  String get appLinks_modeAskTitle => 'Preguntar antes de abrir';

  @override
  String get appLinks_modeAskSubtitle =>
      'Mostrar un aviso antes de abrir enlaces en aplicaciones';

  @override
  String get appLinks_modeNeverTitle => 'Nunca';

  @override
  String get appLinks_modeNeverSubtitle =>
      'Abrir siempre los enlaces en el navegador en lugar de en aplicaciones';

  @override
  String get appLinks_rememberedRulesHeader => 'Reglas de sitios recordadas';

  @override
  String get appLinks_ruleAlwaysOpenSubtitle =>
      'Abrir siempre en la aplicación';

  @override
  String get appLinks_ruleAlwaysKeepSubtitle =>
      'Mantener siempre en el navegador';

  @override
  String get appLinks_removeRuleTooltip => 'Quitar regla';

  @override
  String get bangs_menuTitle => 'Bangs';

  @override
  String get bangs_menuManageUserBangs => 'Gestionar bangs propios';

  @override
  String get bangs_menuSearchBangs => 'Buscar bangs';

  @override
  String get bangs_menuBrowseCategories => 'Explorar categorías';

  @override
  String get bangs_categoriesTitle => 'Categorías de bangs';

  @override
  String get bangs_loadCategoriesFailedTitle =>
      'No se pudieron cargar las categorías de bangs';

  @override
  String get bangs_loadBangsFailedTitle => 'No se pudieron cargar los bangs';

  @override
  String get bangs_searchHint => 'Buscar';

  @override
  String get bangs_searchFailedTitle => 'Error al buscar bangs';

  @override
  String get bangs_userBangsTitle => 'Bangs propios';

  @override
  String get bangs_deleteBangTitle => 'Eliminar bang';

  @override
  String get bangs_deleteBangConfirm =>
      '¿Seguro que quieres eliminar este bang?';

  @override
  String get bangs_editTitleCustomize => 'Personalizar bang';

  @override
  String get bangs_editTitleNew => 'Nuevo bang';

  @override
  String get bangs_editTitleEdit => 'Editar bang';

  @override
  String bangs_triggerAlreadyExists(String trigger) {
    return 'Ya existe un bang con el activador «$trigger»';
  }

  @override
  String get bangs_fieldNameLabel => 'Nombre';

  @override
  String get bangs_fieldNameHelper =>
      'El nombre del sitio web asociado al bang';

  @override
  String get bangs_fieldTriggerLabel => 'Activador';

  @override
  String get bangs_fieldTriggerHelper =>
      'La palabra o frase concreta que se usa para invocar el bang.';

  @override
  String get bangs_fieldAdditionalTriggersLabel => 'Activadores adicionales';

  @override
  String get bangs_fieldAdditionalTriggersHelper =>
      'Otras palabras que invocan este bang, separadas por comas o espacios. El ! inicial es opcional.';

  @override
  String get bangs_fieldUrlLabel => 'URL';

  @override
  String bangs_fieldUrlHelper(String token) {
    return 'La plantilla de URL que se usa al invocar el bang, donde `$token` se sustituye por la consulta del usuario.';
  }

  @override
  String bangs_fieldUrlMissingPlaceholder(String token) {
    return 'Debe contener el marcador de la consulta $token';
  }

  @override
  String get bangs_fieldCategoryLabel => 'Categoría';

  @override
  String get bangs_fieldSubCategoryLabel => 'Subcategoría';

  @override
  String get bangs_flagsLabel => 'Opciones';

  @override
  String get bangs_flagOpenBasePathTitle => 'Abrir la ruta base';

  @override
  String get bangs_flagOpenBasePathSubtitle =>
      'Cuando se invoca un bang sin consulta, abre la ruta base de la URL (/) en lugar de la ruta de la plantilla (p. ej., /search)';

  @override
  String get bangs_flagUrlEncodePlaceholderTitle =>
      'Codificar el marcador para URL';

  @override
  String get bangs_flagUrlEncodePlaceholderSubtitle =>
      'Codifica los términos de búsqueda para URL. Algunos sitios no funcionan con términos codificados; desactiva esta opción para ellos.';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusTitle =>
      'Codificar los espacios como +';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle =>
      'Codifica los espacios como + en lugar de %20. Algunos sitios requieren uno u otro formato.';

  @override
  String get bangs_tooltipOfficialSearch => 'Búsqueda oficial de WebLibre';

  @override
  String get bangs_tooltipCustomizeAsOwn => 'Personalizar como bang propio';

  @override
  String get bangs_tooltipUnpin => 'Desfijar de los proveedores de búsqueda';

  @override
  String get bangs_tooltipPin => 'Fijar en los proveedores de búsqueda';

  @override
  String bangs_tooltipTriggers(String triggers) {
    return 'Activadores: $triggers';
  }

  @override
  String get browserActions_categoryNavigation => 'Navegación';

  @override
  String get browserActions_categoryScrolling => 'Desplazamiento';

  @override
  String get browserActions_categoryTabs => 'Pestañas';

  @override
  String get browserActions_categoryPage => 'Página';

  @override
  String get browserActions_categoryOpen => 'Abrir';

  @override
  String get browserActions_categoryApp => 'Aplicación';

  @override
  String get browserActions_focusAddressBarTitle => 'Barra de direcciones';

  @override
  String get browserActions_focusAddressBarDescription =>
      'Editar la dirección o empezar una búsqueda';

  @override
  String get browserActions_backTitle => 'Atrás';

  @override
  String get browserActions_backDescription => 'Retroceder en el historial';

  @override
  String get browserActions_forwardTitle => 'Adelante';

  @override
  String get browserActions_forwardDescription => 'Avanzar en el historial';

  @override
  String get browserActions_reloadTitle => 'Recargar';

  @override
  String get browserActions_reloadDescription => 'Recargar la página actual';

  @override
  String get browserActions_hardReloadTitle => 'Recarga forzada';

  @override
  String get browserActions_hardReloadDescription =>
      'Recargar la página actual sin usar la caché';

  @override
  String get browserActions_scrollTopTitle => 'Ir al principio';

  @override
  String get browserActions_scrollTopDescription =>
      'Saltar al principio de la página';

  @override
  String get browserActions_scrollBottomTitle => 'Ir al final';

  @override
  String get browserActions_scrollBottomDescription =>
      'Saltar al final de la página';

  @override
  String get browserActions_pageUpTitle => 'Retroceder página';

  @override
  String get browserActions_pageUpDescription =>
      'Desplazarse una pantalla hacia arriba';

  @override
  String get browserActions_pageDownTitle => 'Avanzar página';

  @override
  String get browserActions_pageDownDescription =>
      'Desplazarse una pantalla hacia abajo';

  @override
  String get browserActions_newTabTitle => 'Nueva pestaña';

  @override
  String get browserActions_newTabDescription => 'Abrir una pestaña nueva';

  @override
  String get browserActions_newPrivateTabTitle => 'Nueva pestaña privada';

  @override
  String get browserActions_newPrivateTabDescription =>
      'Abrir una pestaña privada nueva';

  @override
  String get browserActions_closeTabTitle => 'Cerrar pestaña';

  @override
  String get browserActions_closeTabDescription => 'Cerrar la pestaña actual';

  @override
  String get browserActions_reopenClosedTabTitle => 'Reabrir pestaña cerrada';

  @override
  String get browserActions_reopenClosedTabDescription =>
      'Recuperar la última pestaña cerrada';

  @override
  String get browserActions_duplicateTabTitle => 'Duplicar pestaña';

  @override
  String get browserActions_duplicateTabDescription =>
      'Abrir una copia de la pestaña actual';

  @override
  String get browserActions_nextTabTitle => 'Pestaña siguiente';

  @override
  String get browserActions_nextTabDescription =>
      'Cambiar a la pestaña siguiente';

  @override
  String get browserActions_previousTabTitle => 'Pestaña anterior';

  @override
  String get browserActions_previousTabDescription =>
      'Cambiar a la pestaña anterior';

  @override
  String get browserActions_lastUsedTabTitle => 'Última pestaña usada';

  @override
  String get browserActions_lastUsedTabDescription =>
      'Cambiar a la pestaña usada anteriormente';

  @override
  String get browserActions_selectTab1Title => 'Pestaña 1';

  @override
  String get browserActions_selectTab1Description =>
      'Cambiar a la primera pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab2Title => 'Pestaña 2';

  @override
  String get browserActions_selectTab2Description =>
      'Cambiar a la segunda pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab3Title => 'Pestaña 3';

  @override
  String get browserActions_selectTab3Description =>
      'Cambiar a la tercera pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab4Title => 'Pestaña 4';

  @override
  String get browserActions_selectTab4Description =>
      'Cambiar a la cuarta pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab5Title => 'Pestaña 5';

  @override
  String get browserActions_selectTab5Description =>
      'Cambiar a la quinta pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab6Title => 'Pestaña 6';

  @override
  String get browserActions_selectTab6Description =>
      'Cambiar a la sexta pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab7Title => 'Pestaña 7';

  @override
  String get browserActions_selectTab7Description =>
      'Cambiar a la séptima pestaña de la barra de pestañas';

  @override
  String get browserActions_selectTab8Title => 'Pestaña 8';

  @override
  String get browserActions_selectTab8Description =>
      'Cambiar a la octava pestaña de la barra de pestañas';

  @override
  String get browserActions_selectLastTabTitle => 'Última pestaña';

  @override
  String get browserActions_selectLastTabDescription =>
      'Cambiar a la última pestaña de la barra de pestañas';

  @override
  String get browserActions_togglePinTabTitle => 'Fijar / desfijar pestaña';

  @override
  String get browserActions_togglePinTabDescription =>
      'Fijar o desfijar la pestaña actual';

  @override
  String get browserActions_moveTabBackwardTitle => 'Mover pestaña atrás';

  @override
  String get browserActions_moveTabBackwardDescription =>
      'Mover la pestaña actual un puesto hacia el principio de la barra de pestañas';

  @override
  String get browserActions_moveTabForwardTitle => 'Mover pestaña adelante';

  @override
  String get browserActions_moveTabForwardDescription =>
      'Mover la pestaña actual un puesto hacia el final de la barra de pestañas';

  @override
  String get browserActions_moveTabToStartTitle => 'Mover pestaña al principio';

  @override
  String get browserActions_moveTabToStartDescription =>
      'Mover la pestaña actual al principio de su grupo en la barra de pestañas';

  @override
  String get browserActions_moveTabToEndTitle => 'Mover pestaña al final';

  @override
  String get browserActions_moveTabToEndDescription =>
      'Mover la pestaña actual al final de su grupo en la barra de pestañas';

  @override
  String get browserActions_nextContainerTitle => 'Contenedor siguiente';

  @override
  String get browserActions_nextContainerDescription =>
      'Cambiar al contenedor siguiente y a su última pestaña usada';

  @override
  String get browserActions_previousContainerTitle => 'Contenedor anterior';

  @override
  String get browserActions_previousContainerDescription =>
      'Cambiar al contenedor anterior y a su última pestaña usada';

  @override
  String get browserActions_toggleReaderModeTitle => 'Vista de lectura';

  @override
  String get browserActions_toggleReaderModeDescription =>
      'Activar o desactivar la vista de lectura en la página actual';

  @override
  String get browserActions_toggleDesktopModeTitle => 'Versión de escritorio';

  @override
  String get browserActions_toggleDesktopModeDescription =>
      'Activar o desactivar la versión de escritorio de la página actual';

  @override
  String get browserActions_findInPageTitle => 'Buscar en la página';

  @override
  String get browserActions_findInPageDescription =>
      'Abrir la búsqueda en la página';

  @override
  String get browserActions_findNextTitle => 'Buscar siguiente';

  @override
  String get browserActions_findNextDescription =>
      'Saltar a la siguiente coincidencia de la última búsqueda';

  @override
  String get browserActions_findPreviousTitle => 'Buscar anterior';

  @override
  String get browserActions_findPreviousDescription =>
      'Saltar a la coincidencia anterior de la última búsqueda';

  @override
  String get browserActions_increaseFontSizeTitle => 'Aumentar letra';

  @override
  String get browserActions_increaseFontSizeDescription =>
      'Aumentar el tamaño de letra de la página';

  @override
  String get browserActions_decreaseFontSizeTitle => 'Reducir letra';

  @override
  String get browserActions_decreaseFontSizeDescription =>
      'Reducir el tamaño de letra de la página';

  @override
  String get browserActions_resetFontSizeTitle => 'Restablecer letra';

  @override
  String get browserActions_resetFontSizeDescription =>
      'Restaurar el tamaño de letra predeterminado de la página';

  @override
  String get browserActions_toggleBookmarkTitle => 'Marcador';

  @override
  String get browserActions_toggleBookmarkDescription =>
      'Añadir o quitar un marcador de la página actual';

  @override
  String get browserActions_sharePageTitle => 'Compartir';

  @override
  String get browserActions_sharePageDescription =>
      'Compartir la página actual';

  @override
  String get browserActions_translatePageTitle => 'Traducir';

  @override
  String get browserActions_translatePageDescription =>
      'Abrir el panel de traducción de la página';

  @override
  String get browserActions_printPageTitle => 'Imprimir';

  @override
  String get browserActions_printPageDescription => 'Imprimir la página actual';

  @override
  String get browserActions_showHomeTitle => 'Inicio';

  @override
  String get browserActions_showHomeDescription =>
      'Abrir la pantalla de inicio';

  @override
  String get browserActions_showHistoryTitle => 'Historial';

  @override
  String get browserActions_showHistoryDescription =>
      'Abrir el historial de navegación';

  @override
  String get browserActions_showBookmarksTitle => 'Marcadores';

  @override
  String get browserActions_showBookmarksDescription => 'Abrir los marcadores';

  @override
  String get browserActions_showContainersTitle => 'Contenedores';

  @override
  String get browserActions_showContainersDescription =>
      'Abrir la lista de contenedores';

  @override
  String get browserActions_showTabViewTitle => 'Vista de pestañas';

  @override
  String get browserActions_showTabViewDescription =>
      'Abrir el resumen de pestañas';

  @override
  String get browserActions_showDownloadsTitle => 'Descargas';

  @override
  String get browserActions_showDownloadsDescription => 'Abrir las descargas';

  @override
  String get browserActions_showAddonsTitle => 'Complementos';

  @override
  String get browserActions_showAddonsDescription => 'Gestionar extensiones';

  @override
  String get browserActions_openSettingsTitle => 'Ajustes';

  @override
  String get browserActions_openSettingsDescription => 'Abrir los ajustes';

  @override
  String get browserActions_showKeyboardShortcutsTitle => 'Atajos de teclado';

  @override
  String get browserActions_showKeyboardShortcutsDescription =>
      'Mostrar las teclas que ejecutan acciones del navegador';

  @override
  String get browserActions_toggleTabBarTitle =>
      'Ocultar / mostrar barra de pestañas';

  @override
  String get browserActions_toggleTabBarDescription =>
      'Ocultar la barra de pestañas o volver a mostrarla';

  @override
  String get browserActions_clearBrowsingDataTitle =>
      'Borrar datos de navegación';

  @override
  String get browserActions_clearBrowsingDataDescription =>
      'Elegir qué datos de navegación eliminar';

  @override
  String get browserActions_moveToBackgroundTitle => 'Minimizar';

  @override
  String get browserActions_moveToBackgroundDescription =>
      'Enviar WebLibre a segundo plano';

  @override
  String get browserActions_quitBrowserTitle => 'Salir';

  @override
  String get browserActions_quitBrowserDescription =>
      'Cerrar todas las pestañas y salir de WebLibre';

  @override
  String get browserActions_categoryCreate => 'Crear';

  @override
  String get browserActions_openInPrivateTabTitle => 'Abrir en pestaña privada';

  @override
  String get browserActions_openInPrivateTabDescription =>
      'Abrir la página actual en una pestaña privada nueva';

  @override
  String get browserActions_moveTabToContainerTitle => 'Mover a contenedor';

  @override
  String get browserActions_moveTabToContainerDescription =>
      'Mover la pestaña actual a otro contenedor';

  @override
  String get browserActions_copyLinkTitle => 'Copiar enlace';

  @override
  String get browserActions_copyLinkDescription =>
      'Copiar la dirección de la página actual';

  @override
  String get browserActions_siteSettingsTitle => 'Ajustes del sitio';

  @override
  String get browserActions_siteSettingsDescription =>
      'Permisos y protección contra el rastreo de este sitio';

  @override
  String get browserActions_addToHomeScreenTitle =>
      'Añadir a la pantalla de inicio';

  @override
  String get browserActions_addToHomeScreenDescription =>
      'Instalar el sitio actual como aplicación o acceso directo';

  @override
  String get browserActions_subscribeToPageFeedTitle =>
      'Suscribirse a la página';

  @override
  String get browserActions_subscribeToPageFeedDescription =>
      'Buscar y seguir las fuentes de la página actual';

  @override
  String get browserActions_showFeedsTitle => 'Fuentes';

  @override
  String get browserActions_showFeedsDescription => 'Abrir tus fuentes';

  @override
  String get browserActions_showProfilesTitle => 'Perfiles';

  @override
  String get browserActions_showProfilesDescription => 'Gestionar tus perfiles';

  @override
  String get browserActions_showProxySettingsTitle => 'Proxy';

  @override
  String get browserActions_showProxySettingsDescription =>
      'Abrir los ajustes del proxy';

  @override
  String get browserActions_showTorTitle => 'Tor';

  @override
  String get browserActions_showTorDescription => 'Abrir los ajustes de Tor';

  @override
  String get browserActions_showSyncSettingsTitle => 'Sincronización';

  @override
  String get browserActions_showSyncSettingsDescription =>
      'Abrir los ajustes de sincronización';

  @override
  String get browserActions_showContentBlockerListsTitle => 'Listas de filtros';

  @override
  String get browserActions_showContentBlockerListsDescription =>
      'Gestionar las listas de filtros del bloqueador de contenido';

  @override
  String get browserActions_showErrorLogsTitle => 'Registros de errores';

  @override
  String get browserActions_showErrorLogsDescription =>
      'Ver los registros de errores de la aplicación';

  @override
  String get browserActions_showAboutTitle => 'Acerca de';

  @override
  String get browserActions_showAboutDescription => 'Acerca de WebLibre';

  @override
  String get browserActions_newContainerTitle => 'Nuevo contenedor';

  @override
  String get browserActions_newContainerDescription => 'Crear un contenedor';

  @override
  String get browserActions_newBookmarkFolderTitle =>
      'Nueva carpeta de marcadores';

  @override
  String get browserActions_newBookmarkFolderDescription =>
      'Crear una carpeta de marcadores';

  @override
  String get browserActions_addFeedTitle => 'Añadir fuente';

  @override
  String get browserActions_addFeedDescription =>
      'Suscribirse a una fuente por su dirección';

  @override
  String get browserActions_newSearchEngineTitle => 'Nuevo atajo de búsqueda';

  @override
  String get browserActions_newSearchEngineDescription =>
      'Crear tu propio atajo de búsqueda bang';

  @override
  String get browserActions_newProfileTitle => 'Nuevo perfil';

  @override
  String get browserActions_newProfileDescription =>
      'Crear un perfil del navegador';

  @override
  String get browserActions_newProxyProfileTitle => 'Nuevo perfil de proxy';

  @override
  String get browserActions_newProxyProfileDescription =>
      'Añadir un servidor proxy';

  @override
  String get browserActions_backupProfileTitle =>
      'Copia de seguridad del perfil';

  @override
  String get browserActions_backupProfileDescription =>
      'Crear una copia de seguridad del perfil actual';

  @override
  String get browserActions_toggleBookmarkKeywords =>
      'favorito, guardar página, estrella, marcador, bookmark';

  @override
  String get browserActions_findInPageKeywords =>
      'buscar en página, buscar texto, encontrar, find';

  @override
  String get browserActions_copyLinkKeywords =>
      'copiar url, copiar dirección, portapapeles';

  @override
  String get browserActions_sharePageKeywords =>
      'enviar, compartir enlace, enviar a, share';

  @override
  String get browserActions_toggleReaderModeKeywords =>
      'vista de lectura, modo lectura, artículo, simplificar página, reader';

  @override
  String get browserActions_toggleDesktopModeKeywords =>
      'versión de escritorio, sitio de escritorio, sitio móvil, user agent, desktop';

  @override
  String get browserActions_translatePageKeywords =>
      'traducción, idioma, traductor, translate';

  @override
  String get browserActions_siteSettingsKeywords =>
      'permisos, cookies, protección contra el rastreo, cámara, micrófono, ubicación, información del sitio';

  @override
  String get browserActions_addToHomeScreenKeywords =>
      'pwa, instalar, aplicación web, acceso directo, lanzador, aplicación, app';

  @override
  String get browserActions_subscribeToPageFeedKeywords =>
      'rss, atom, fuente, feed, suscribirse, seguir, noticias';

  @override
  String get browserActions_printPageKeywords =>
      'pdf, guardar como pdf, impresora, imprimir';

  @override
  String get browserActions_increaseFontSizeKeywords =>
      'ampliar, zoom, texto más grande, letra más grande, tamaño del texto';

  @override
  String get browserActions_decreaseFontSizeKeywords =>
      'reducir, zoom, texto más pequeño, letra más pequeña, tamaño del texto';

  @override
  String get browserActions_resetFontSizeKeywords =>
      'tamaño de texto predeterminado, restablecer zoom, tamaño del texto';

  @override
  String get browserActions_openInPrivateTabKeywords =>
      'incógnito, navegación privada, modo privado, incognito';

  @override
  String get browserActions_moveTabToContainerKeywords =>
      'asignar contenedor, identidad, grupo de pestañas, container';

  @override
  String get browserActions_duplicateTabKeywords =>
      'clonar pestaña, copiar pestaña';

  @override
  String get browserActions_togglePinTabKeywords =>
      'fijar pestaña, desfijar, anclar, pin';

  @override
  String get browserActions_closeTabKeywords => 'cerrar, quitar pestaña';

  @override
  String get browserActions_reopenClosedTabKeywords =>
      'deshacer cierre, restaurar pestaña, cerradas recientemente';

  @override
  String get browserActions_showHistoryKeywords =>
      'páginas visitadas, historial de navegación, visitadas recientemente, history';

  @override
  String get browserActions_showBookmarksKeywords =>
      'favoritos, páginas guardadas, gestor de marcadores, bookmarks';

  @override
  String get browserActions_showDownloadsKeywords =>
      'archivos descargados, archivos, gestor de descargas, downloads';

  @override
  String get browserActions_showTabViewKeywords =>
      'resumen de pestañas, todas las pestañas, selector de pestañas, pestañas abiertas';

  @override
  String get browserActions_showContainersKeywords =>
      'identidades, lista de contenedores, espacios de trabajo, containers';

  @override
  String get browserActions_showFeedsKeywords =>
      'rss, atom, noticias, suscripciones, feeds';

  @override
  String get browserActions_showProfilesKeywords =>
      'usuarios, cuentas, cambiar perfil';

  @override
  String get browserActions_showProxySettingsKeywords =>
      'vpn, sing-box, socks, conexión, red, proxy';

  @override
  String get browserActions_showTorKeywords =>
      'onion, anónimo, puentes, anonimato';

  @override
  String get browserActions_showSyncSettingsKeywords =>
      'cuenta, sincronizar, dispositivos, sync';

  @override
  String get browserActions_showAddonsKeywords =>
      'extensiones, complementos, plugins, webextensions';

  @override
  String get browserActions_showContentBlockerListsKeywords =>
      'ublock, adblock, bloqueador de anuncios, filtros, listas de bloqueo';

  @override
  String get browserActions_openSettingsKeywords =>
      'preferencias, opciones, configuración, ajustes';

  @override
  String get browserActions_showKeyboardShortcutsKeywords =>
      'teclas rápidas, combinaciones de teclas, teclas, hotkeys';

  @override
  String get browserActions_showErrorLogsKeywords =>
      'registros, logs, depuración, fallo, informe de errores';

  @override
  String get browserActions_showAboutKeywords =>
      'versión, licencia, información';

  @override
  String get browserActions_newContainerKeywords =>
      'añadir contenedor, crear identidad, espacio de trabajo';

  @override
  String get browserActions_newBookmarkFolderKeywords =>
      'añadir carpeta, crear carpeta, organizar marcadores';

  @override
  String get browserActions_addFeedKeywords =>
      'rss, atom, suscribirse, añadir suscripción';

  @override
  String get browserActions_newSearchEngineKeywords =>
      'bang, búsqueda personalizada, añadir buscador, atajo de búsqueda';

  @override
  String get browserActions_newProfileKeywords =>
      'añadir usuario, crear perfil, nueva cuenta';

  @override
  String get browserActions_newProxyProfileKeywords =>
      'añadir proxy, vpn, servidor, sing-box, socks';

  @override
  String get browserActions_backupProfileKeywords =>
      'copia de seguridad, exportar, guardar datos, archivar, backup';

  @override
  String get browserActions_clearBrowsingDataKeywords =>
      'borrar historial, borrar caché, cookies, eliminar, limpiar, privacidad';

  @override
  String get bookmarks_title => 'Marcadores';

  @override
  String get bookmarks_filterHint => 'Filtrar marcadores...';

  @override
  String get bookmarks_emptyFolder => 'Vacía';

  @override
  String get bookmarks_searchHiddenByFoldersOnly =>
      'La búsqueda coincide con marcadores ocultos por «Solo carpetas»';

  @override
  String bookmarks_noSearchMatches(String query) {
    return 'Ningún marcador coincide con «$query»';
  }

  @override
  String get bookmarks_loadFailedTitle =>
      'No se pudieron cargar los marcadores';

  @override
  String get bookmarks_loadFoldersFailedTitle =>
      'No se pudieron cargar las carpetas de marcadores';

  @override
  String get bookmarks_folderLabel => 'Carpeta';

  @override
  String get bookmarks_unnamedFolder => 'Carpeta sin nombre';

  @override
  String bookmarks_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_tooltipOpenInBackground => 'Abrir en segundo plano';

  @override
  String get bookmarks_tooltipMoveSelected => 'Mover selección';

  @override
  String get bookmarks_tooltipDeleteSelected => 'Eliminar selección';

  @override
  String get bookmarks_tooltipClearSearch => 'Borrar búsqueda';

  @override
  String get bookmarks_tooltipSearchBookmarks => 'Buscar marcadores';

  @override
  String get bookmarks_tooltipCollapse => 'Contraer';

  @override
  String get bookmarks_tooltipExpand => 'Expandir';

  @override
  String get bookmarks_menuAddBookmarkHere => 'Añadir marcador aquí';

  @override
  String get bookmarks_menuAddSubfolderHere => 'Añadir subcarpeta aquí';

  @override
  String get bookmarks_menuCollapseAll => 'Contraer todo';

  @override
  String get bookmarks_menuShowEmptyFolders => 'Mostrar carpetas vacías';

  @override
  String get bookmarks_menuHideEmptyFolders => 'Ocultar carpetas vacías';

  @override
  String get bookmarks_menuShowBookmarks => 'Mostrar marcadores';

  @override
  String get bookmarks_menuFoldersOnly => 'Solo carpetas';

  @override
  String get bookmarks_menuVisibility => 'Visibilidad';

  @override
  String get bookmarks_menuSort => 'Ordenar';

  @override
  String get bookmarks_menuImport => 'Importar';

  @override
  String get bookmarks_menuExport => 'Exportar';

  @override
  String get bookmarks_formatJson => 'JSON';

  @override
  String get bookmarks_formatHtml => 'HTML';

  @override
  String get bookmarks_actionOpenInNewTab => 'Abrir en una pestaña nueva';

  @override
  String get bookmarks_actionOpenInBackground => 'Abrir en segundo plano';

  @override
  String get bookmarks_actionShare => 'Compartir';

  @override
  String get bookmarks_actionMove => 'Mover';

  @override
  String get bookmarks_actionFlatten => 'Aplanar';

  @override
  String get bookmarks_actionAddSubfolder => 'Añadir subcarpeta';

  @override
  String get bookmarks_actionAddBookmark => 'Añadir marcador';

  @override
  String get bookmarks_actionMerge => 'Combinar';

  @override
  String get bookmarks_actionReplace => 'Reemplazar';

  @override
  String get bookmarks_noEntriesSelected => 'No hay marcadores seleccionados';

  @override
  String bookmarks_openedTabsInBackground(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se abrieron $count pestañas en segundo plano',
      one: 'Se abrió 1 pestaña en segundo plano',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_movedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se movieron $count elementos',
      one: 'Se movió 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_deletedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se eliminaron $count elementos',
      one: 'Se eliminó 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importFailedToReadFile => 'No se pudo leer el archivo';

  @override
  String bookmarks_importSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count marcadores correctamente',
      one: 'Se importó 1 marcador correctamente',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_importFailedWithError(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get bookmarks_exportDialogTitle => 'Exportar marcadores';

  @override
  String get bookmarks_exportSuccess => 'Marcadores exportados correctamente';

  @override
  String bookmarks_exportFailedWithError(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get bookmarks_sortDefault => 'Predeterminado';

  @override
  String get bookmarks_sortTitleAsc => 'Título A-Z';

  @override
  String get bookmarks_sortTitleDesc => 'Título Z-A';

  @override
  String get bookmarks_sortUrlAsc => 'URL A-Z';

  @override
  String get bookmarks_sortUrlDesc => 'URL Z-A';

  @override
  String get bookmarks_sortDateAddedDesc => 'Más recientes primero';

  @override
  String get bookmarks_sortDateAddedAsc => 'Más antiguos primero';

  @override
  String get bookmarks_deleteBookmarkTitle => 'Eliminar marcador';

  @override
  String get bookmarks_deleteBookmarkContent =>
      '¿Seguro que quieres eliminar este marcador?';

  @override
  String get bookmarks_deleteFolderTitle => 'Eliminar carpeta';

  @override
  String get bookmarks_deleteFolderConfirmUnknown =>
      '¿Seguro que quieres eliminar esta carpeta, con todos sus marcadores?';

  @override
  String bookmarks_deleteFolderConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Seguro que quieres eliminar esta carpeta y sus $count marcadores?',
      one: '¿Seguro que quieres eliminar esta carpeta y su único marcador?',
      zero: '¿Seguro que quieres eliminar esta carpeta?',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importDialogTitle => 'Importar marcadores';

  @override
  String get bookmarks_importDialogContent =>
      '¿Quieres borrar todos los marcadores existentes antes de importar?\n\nElige «Reemplazar» para eliminar los marcadores existentes o «Combinar» para conservarlos.';

  @override
  String get bookmarks_importProgressTitle => 'Importando marcadores';

  @override
  String get bookmarks_importPhaseParsing => 'Leyendo el archivo…';

  @override
  String get bookmarks_importPhaseErasing =>
      'Quitando los marcadores existentes…';

  @override
  String bookmarks_importPhaseInsertingProgress(int inserted, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$inserted de $total marcadores',
      one: '$inserted de 1 marcador',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importPhaseInsertingIndeterminate =>
      'Guardando marcadores…';

  @override
  String get bookmarks_moveToFolderTitle => 'Mover a carpeta';

  @override
  String get bookmarks_editBookmarkTitle => 'Editar marcador';

  @override
  String get bookmarks_createBookmarkTitle => 'Crear marcador';

  @override
  String get bookmarks_editFolderTitle => 'Editar carpeta';

  @override
  String get bookmarks_createFolderTitle => 'Crear carpeta';

  @override
  String get bookmarks_fieldNameLabel => 'Nombre';

  @override
  String get bookmarks_fieldUrlLabel => 'URL';

  @override
  String get bookmarks_addToTop => 'Añadir al principio';

  @override
  String get browser_actionSelect => 'Seleccionar';

  @override
  String get browser_actionKeep => 'Conservar';

  @override
  String get browser_actionInstall => 'Instalar';

  @override
  String get browser_bookmarkAllTitle =>
      'Añadir todas las pestañas a marcadores';

  @override
  String get browser_bookmarkAllFastTitle => 'Rápido';

  @override
  String get browser_bookmarkAllFastSubtitle =>
      'Añadir automáticamente todas las pestañas a una carpeta seleccionada';

  @override
  String get browser_bookmarkAllDetailedTitle => 'Detallado';

  @override
  String get browser_bookmarkAllDetailedSubtitle =>
      'Revisar y editar cada marcador por separado';

  @override
  String get browser_clearSiteDataTitle => 'Borrar datos del sitio';

  @override
  String browser_clearSiteDataContent(String formattedTypes, String host) {
    return 'Se borrarán los siguientes datos de $host:\n$formattedTypes\n\nEs posible que tengas que volver a iniciar sesión.';
  }

  @override
  String get browser_contentSelectionExtractedTitle => 'Contenido extraído';

  @override
  String get browser_contentSelectionExtractedSubtitle =>
      'Contenido optimizado para lectura, sin navegación ni anuncios';

  @override
  String get browser_contentSelectionFullTitle => 'Contenido completo';

  @override
  String get browser_contentSelectionFullSubtitle =>
      'La página completa, con todos sus elementos y su estructura';

  @override
  String get browser_deleteDataTitle => 'Eliminar datos de navegación';

  @override
  String get browser_installAddonSheetTitle =>
      'Instalar extensión desde archivo';

  @override
  String get browser_installAddonSelectFileButton => 'Seleccionar archivo XPI';

  @override
  String get browser_installAddonNoFileSelected =>
      'Ningún archivo seleccionado';

  @override
  String get browser_installAddonPinnedNotice =>
      'Las extensiones instaladas desde un XPI local se quedan en esa versión y no se actualizan automáticamente.';

  @override
  String get browser_installAddonNotXpiError => 'Selecciona un archivo .xpi';

  @override
  String browser_installAddonPickFileFailed(String error) {
    return 'No se pudo elegir el archivo: $error';
  }

  @override
  String get browser_installAddonInstalledMessage =>
      'Extensión instalada. Las actualizaciones automáticas están desactivadas para esta versión local.';

  @override
  String get browser_installAddonNotSignedError =>
      'Esta extensión no está firmada por Mozilla. Activa «Permitir extensiones sin firmar» en los ajustes de extensiones para instalarla.';

  @override
  String browser_installAddonInstallFailed(String error) {
    return 'Error en la instalación: $error';
  }

  @override
  String get browser_keepTabTitle => '¿Conservar la pestaña?';

  @override
  String get browser_keepTabContent =>
      '¿Quieres conservar esta pestaña o descartarla?';

  @override
  String get browser_qrCodeTitle => 'Compartir código QR';

  @override
  String get browser_selectFolderTitle => 'Seleccionar carpeta';

  @override
  String get browser_tabTreeCurrentTabNotInTree =>
      'La pestaña actual no forma parte de este árbol';

  @override
  String get browser_menuManageExtensions => 'Gestionar extensiones';

  @override
  String get browser_menuAddRegularTab => 'Añadir pestaña normal';

  @override
  String get browser_menuAddChildTab => 'Añadir pestaña hija';

  @override
  String get browser_menuAddPrivateTab => 'Añadir pestaña privada';

  @override
  String get browser_menuAddIsolatedTab => 'Añadir pestaña aislada';

  @override
  String get browser_fontSizeTitle => 'Tamaño del texto';

  @override
  String get browser_fontSizeAutomaticNotice =>
      'El tamaño de letra automático está activado. Desactívalo en Ajustes para ajustarlo manualmente.';

  @override
  String get browser_fontSizeResetButton => 'Restablecer al 100 %';

  @override
  String get browser_historyNoPreviousPages => 'No hay páginas anteriores';

  @override
  String get browser_historyNoForwardPages => 'No hay páginas siguientes';

  @override
  String get browser_certSandboxedCaptureTitle => 'Captura aislada';

  @override
  String get browser_certSandboxedCaptureSubtitle =>
      'La página se sirve desde una copia archivada, sin conexión en directo.';

  @override
  String get browser_certConnectionNotSecure => 'La conexión no es segura';

  @override
  String get browser_certConnectionSecure => 'La conexión es segura';

  @override
  String browser_certVerifiedBy(String issuer) {
    return 'Verificado por: $issuer';
  }

  @override
  String get browser_containerFallbackName => 'Contenedor';

  @override
  String get browser_actionEnable => 'Activar';

  @override
  String get browser_closeAllPrivateTabsTitle =>
      'Cerrar todas las pestañas privadas';

  @override
  String get browser_closeAllPrivateTabsContent =>
      '¿Seguro que quieres cerrar todas las pestañas privadas mostradas?';

  @override
  String get browser_closeAllTabsTitle => 'Cerrar todas las pestañas';

  @override
  String get browser_closeAllTabsContent =>
      '¿Seguro que quieres cerrar todas las pestañas mostradas?';

  @override
  String get browser_enableAiTabSuggestionsTitle =>
      'Activar sugerencias de pestañas con IA';

  @override
  String get browser_enableAiTabSuggestionsContent =>
      'Activar esta función puede requerir la descarga de modelos de IA. El tamaño y el progreso de la descarga no se pueden determinar de antemano.\n\n¿Quieres continuar?';

  @override
  String get browser_tooltipExpandGroup => 'Expandir grupo';

  @override
  String get browser_tooltipCollapseGroup => 'Contraer grupo';

  @override
  String browser_tabGroupSizeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Grupo de $count pestañas',
      one: 'Grupo de 1 pestaña',
    );
    return '$_temp0';
  }

  @override
  String get browser_searchOrEnterUrl => 'Buscar o escribir una URL';

  @override
  String get browser_tabCannotBeMovedHere =>
      'La pestaña no se puede mover aquí';

  @override
  String get browser_quickActionNewTab => 'Nueva pestaña';

  @override
  String get browser_quickActionNewPrivateTab => 'Nueva pestaña privada';

  @override
  String get browser_quickActionNewIsolatedTab => 'Nueva pestaña aislada';

  @override
  String get browser_shareLink => 'Compartir enlace';

  @override
  String get browser_showQrCode => 'Mostrar código QR';

  @override
  String get browser_exportAsPdf => 'Exportar como PDF';

  @override
  String get browser_failedToPrintPage => 'No se pudo imprimir la página';

  @override
  String get browser_print => 'Imprimir';

  @override
  String get browser_shareScreenshot => 'Compartir captura de pantalla';

  @override
  String get browser_exportAsPng => 'Exportar como PNG';

  @override
  String browser_openInNamedApp(String appName) {
    return 'Abrir en $appName';
  }

  @override
  String get browser_openInApp => 'Abrir en la aplicación';

  @override
  String get browser_copyAddress => 'Copiar dirección';

  @override
  String get browser_noTargetDevices => 'No hay dispositivos de destino';

  @override
  String browser_sentTabToDevice(String deviceName) {
    return 'Pestaña enviada a $deviceName';
  }

  @override
  String get browser_failedToSendTab => 'No se pudo enviar la pestaña';

  @override
  String get browser_loadingDevices => 'Cargando dispositivos...';

  @override
  String get browser_failedToLoadDevices =>
      'No se pudieron cargar los dispositivos';

  @override
  String get browser_sendToDevice => 'Enviar a dispositivo';

  @override
  String get browser_containerMenuNewTab => 'Nueva pestaña';

  @override
  String get browser_unpinContainer => 'Desfijar contenedor';

  @override
  String get browser_pinContainer => 'Fijar contenedor';

  @override
  String get browser_closeSubmenuAllTabs => 'Todas las pestañas';

  @override
  String get browser_closeSubmenuPrivateTabs => 'Pestañas privadas';

  @override
  String get browser_closeSubmenuIsolatedTabs => 'Pestañas aisladas';

  @override
  String get browser_closeSubmenuFilteredTabs => 'Pestañas filtradas';

  @override
  String get browser_menuCloseTabs => 'Cerrar pestañas';

  @override
  String get browser_menuBookmarkAll => 'Añadir todas a marcadores';

  @override
  String get browser_menuAssignedSites => 'Sitios asignados…';

  @override
  String get browser_menuClearContainerData => 'Borrar datos del contenedor';

  @override
  String get browser_menuEditContainer => 'Editar contenedor…';

  @override
  String get browser_menuDeleteContainer => 'Eliminar contenedor';

  @override
  String browser_bookmarksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se añadieron $count marcadores',
      one: 'Se añadió 1 marcador',
    );
    return '$_temp0';
  }

  @override
  String get browser_containerDataClearedSuccess =>
      'Datos del contenedor borrados correctamente';

  @override
  String browser_containerDataClearedWithTabsClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Datos del contenedor borrados. Se cerraron $count pestañas.',
      one: 'Datos del contenedor borrados. Se cerró 1 pestaña.',
    );
    return '$_temp0';
  }

  @override
  String browser_errorClearingData(String error) {
    return 'Error al borrar los datos: $error';
  }

  @override
  String get browser_appLinksSectionTitle => 'Enlaces de aplicaciones';

  @override
  String get browser_openLinksForThisSite => 'Abrir los enlaces de este sitio';

  @override
  String get browser_followsTheDefault => 'Sigue el valor predeterminado';

  @override
  String get browser_followDefault => 'Seguir el valor predeterminado';

  @override
  String get browser_openInAppOption => 'Abrir en la aplicación';

  @override
  String get browser_keepInBrowser => 'Mantener en el navegador';

  @override
  String get browser_noAppFoundForSite =>
      'No se encontró ninguna aplicación para este sitio';

  @override
  String browser_alwaysOpensInApp(String appName) {
    return 'Se abre siempre en $appName';
  }

  @override
  String get browser_theAppFallback => 'la aplicación';

  @override
  String get browser_alwaysStaysInBrowser => 'Se queda siempre en el navegador';

  @override
  String get browser_followsDefaultOpensInApps =>
      'Sigue el valor predeterminado: se abre en aplicaciones';

  @override
  String get browser_followsDefaultNoAppFound =>
      'Sigue el valor predeterminado: no se encontró ninguna aplicación';

  @override
  String get browser_followsDefaultAsksFirst =>
      'Sigue el valor predeterminado: pregunta antes';

  @override
  String get browser_followsDefaultStaysInBrowser =>
      'Sigue el valor predeterminado: se queda en el navegador';

  @override
  String get browser_selectDataTypesToClear =>
      'Selecciona los tipos de datos que quieres borrar';

  @override
  String get browser_cookiesCacheAndSiteData =>
      'Cookies, caché y datos del sitio';

  @override
  String get browser_dataTypeAuthSessions => 'Sesiones de autenticación';

  @override
  String get browser_dataTypeAuthSessionsSubtitle =>
      'Inicios de sesión guardados, sesiones activas';

  @override
  String get browser_dataTypeSiteData => 'Datos del sitio';

  @override
  String get browser_dataTypeSiteDataSubtitle =>
      'Almacenamiento sin conexión, bases de datos, archivos locales';

  @override
  String get browser_dataTypeCookies => 'Cookies';

  @override
  String get browser_dataTypeCookiesSubtitle =>
      'Tokens de inicio de sesión, preferencias, datos de rastreo';

  @override
  String get browser_dataTypeCachedFiles => 'Archivos en caché';

  @override
  String get browser_dataTypeCachedFilesSubtitle =>
      'Imágenes, scripts, hojas de estilo';

  @override
  String get browser_closeTabAfterClearing =>
      'Cerrar la pestaña después de borrar';

  @override
  String get browser_closeTabAfterClearingSubtitle =>
      'Cerrar esta pestaña cuando se hayan borrado los datos';

  @override
  String get browser_clearingEllipsis => 'Borrando...';

  @override
  String get browser_clearNow => 'Borrar ahora';

  @override
  String get browser_selectAtLeastOneDataType =>
      'Selecciona al menos un tipo de datos';

  @override
  String get browser_siteDataCleared => 'Datos del sitio borrados';

  @override
  String browser_failedToClearSiteData(String error) {
    return 'No se pudieron borrar los datos del sitio: $error';
  }

  @override
  String get browser_alwaysUseDesktopSite =>
      'Usar siempre la versión de escritorio';

  @override
  String get browser_unavailableOnThisPage => 'No disponible en esta página';

  @override
  String browser_setByRuleFor(String host) {
    return 'Establecido por una regla para $host';
  }

  @override
  String get browser_siteAlwaysLoadsInDesktopMode =>
      'Este sitio se carga siempre en modo escritorio';

  @override
  String get browser_siteFollowsDefaultMode =>
      'Este sitio sigue el modo predeterminado';

  @override
  String browser_failedToToggleDesktopMode(String error) {
    return 'No se pudo cambiar el modo escritorio: $error';
  }

  @override
  String get browser_gesturesTitle => 'Gestos';

  @override
  String get browser_gesturesTurnedOffGlobally =>
      'Los gestos están desactivados globalmente';

  @override
  String get browser_gesturesUnavailableOnThisPage =>
      'Los gestos no están disponibles en esta página';

  @override
  String browser_gesturesDisabledByRuleFor(String host) {
    return 'Desactivado por una regla para $host';
  }

  @override
  String get browser_gesturesDisabledOnThisSite =>
      'Los gestos están desactivados en este sitio';

  @override
  String get browser_gesturesEnabledOnThisSite =>
      'Los gestos están activados en este sitio';

  @override
  String browser_failedToToggleGestures(String error) {
    return 'No se pudieron cambiar los gestos: $error';
  }

  @override
  String browser_errorLoadingPermissions(String error) {
    return 'Error al cargar los permisos: $error';
  }

  @override
  String get browser_permissionsSectionTitle => 'Permisos';

  @override
  String get browser_showAll => 'Mostrar todo';

  @override
  String get browser_noPermissionsSetForSite =>
      'No hay permisos establecidos para este sitio';

  @override
  String get browser_permissionAsk => 'Preguntar';

  @override
  String get browser_permissionAllow => 'Permitir';

  @override
  String get browser_permissionBlock => 'Bloquear';

  @override
  String get browser_autoplayTitle => 'Reproducción automática';

  @override
  String get browser_autoplayAllowAll => 'Permitir todo';

  @override
  String get browser_autoplayBlockAudible => 'Bloquear con sonido';

  @override
  String get browser_autoplayBlockAll => 'Bloquear todo';

  @override
  String get browser_failedToLoadTrackingProtection =>
      'No se pudo cargar la protección contra el rastreo';

  @override
  String get browser_enhancedTrackingProtection =>
      'Protección mejorada contra el rastreo';

  @override
  String get browser_trackersBeingBlocked =>
      'Se están bloqueando los rastreadores de este sitio';

  @override
  String get browser_trackersAllowed =>
      'Se permiten los rastreadores de este sitio';

  @override
  String browser_failedToToggleTrackingProtection(String error) {
    return 'No se pudo cambiar la protección contra el rastreo: $error';
  }

  @override
  String get browser_resizeSidePanel => 'Cambiar el tamaño del panel lateral';

  @override
  String get browser_unassignedContainerLabel => 'Sin asignar';

  @override
  String get browser_tooltipCloseTab => 'Cerrar pestaña';

  @override
  String get browser_urlCleaned => 'URL limpiada';

  @override
  String get browser_urlPreviewApplied => 'Vista previa de la URL aplicada';

  @override
  String browser_trackingParametersDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se detectaron $count parámetros de rastreo',
      one: 'Se detectó 1 parámetro de rastreo',
    );
    return '$_temp0';
  }

  @override
  String get browser_linkIsClean => 'El enlace no tiene rastreo';

  @override
  String get browser_removeTrackingTooltip => 'Quitar rastreo';

  @override
  String get browser_menuFindInPage => 'Buscar en la página';

  @override
  String get browser_menuReaderMode => 'Vista de lectura';

  @override
  String get browser_menuFetchFeedsOnPage => 'Obtener fuentes de la página';

  @override
  String get browser_menuAddBookmark => 'Añadir marcador';

  @override
  String get browser_cloneRegular => 'Normal';

  @override
  String get browser_clonePrivate => 'Privada';

  @override
  String get browser_cloneIsolated => 'Aislada';

  @override
  String get browser_menuCloneTab => 'Clonar pestaña';

  @override
  String get browser_menuAssignContainer => 'Asignar contenedor';

  @override
  String get browser_menuUrlRelation => 'Vincular URL';

  @override
  String get browser_menuUnassignUrlRelation => 'Desvincular URL';

  @override
  String get browser_menuUnassignContainer => 'Desasignar contenedor';

  @override
  String get browser_menuContainerSubmenu => 'Contenedor';

  @override
  String get browser_menuMoveUp => 'Subir';

  @override
  String get browser_menuMoveDown => 'Bajar';

  @override
  String get browser_menuReorder => 'Reordenar';

  @override
  String get browser_menuShare => 'Compartir';

  @override
  String get browser_menuCopyAsMarkdown => 'Copiar como Markdown';

  @override
  String get browser_markdownCopiedToClipboard =>
      'Markdown copiado al portapapeles';

  @override
  String get browser_menuExportAsMarkdown => 'Exportar como Markdown';

  @override
  String get browser_menuExportSubmenu => 'Exportar';

  @override
  String get browser_menuCloseTab => 'Cerrar pestaña';

  @override
  String get browser_menuReload => 'Recargar';

  @override
  String get browser_menuDesktopMode => 'Modo escritorio';

  @override
  String get browser_menuAddToHomeScreen => 'Añadir a la pantalla de inicio';

  @override
  String get browser_menuChangeParent => 'Cambiar pestaña madre…';

  @override
  String get browser_menuDetachFromParent => 'Separar de la pestaña madre';

  @override
  String get browser_menuHierarchy => 'Jerarquía';

  @override
  String get browser_pageTranslated => 'Traducida';

  @override
  String get browser_menuTranslatePage => 'Traducir página';

  @override
  String get browser_unpinTab => 'Desfijar pestaña';

  @override
  String get browser_pinTab => 'Fijar pestaña';

  @override
  String browser_errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get browser_tabNoLongerExists => 'La pestaña ya no existe';

  @override
  String get browser_chooseAParentTab => 'Elige una pestaña madre';

  @override
  String get browser_makeStandalone => 'Hacer independiente';

  @override
  String get browser_detachFromCurrentParent =>
      'Separar de la pestaña madre actual';

  @override
  String get browser_noCandidateTabsInContainer =>
      'No hay pestañas candidatas en este contenedor.';

  @override
  String get browser_clearContainerDataIntro =>
      'Se borrarán todos los datos de este contenedor:';

  @override
  String get browser_bulletCookies => '• Cookies';

  @override
  String get browser_bulletSiteData => '• Datos de sitios';

  @override
  String get browser_bulletCache => '• Caché';

  @override
  String get browser_bulletPermissions => '• Permisos';

  @override
  String browser_tabsWillBeClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se cerrarán $count pestañas.',
      one: 'Se cerrará 1 pestaña.',
    );
    return '$_temp0';
  }

  @override
  String get browser_recreateTabsAfterClearing =>
      'Volver a crear las pestañas después de borrar';

  @override
  String get browser_actionClearData => 'Borrar datos';

  @override
  String get browser_closeFromSameHost => 'Cerrar las del mismo host';

  @override
  String get browser_closeTabAndDescendants => 'Cerrar pestaña y descendientes';

  @override
  String get browser_tabUnpinned => 'Pestaña desfijada';

  @override
  String browser_createdContainerNamed(String containerName) {
    return 'Contenedor «$containerName» creado';
  }

  @override
  String get browser_newContainerFallback => 'Nuevo contenedor';

  @override
  String get browser_assignedParentTab => 'Pestaña madre asignada';

  @override
  String get browser_couldNotAssignParentTab =>
      'No se pudo asignar la pestaña madre';

  @override
  String get browser_dropTabOntoTabTitle => 'Soltar una pestaña sobre otra';

  @override
  String get browser_chooseHowTabsRelated =>
      'Elige cómo deben relacionarse estas pestañas.';

  @override
  String get browser_createContainerOption => 'Crear contenedor';

  @override
  String get browser_createContainerOptionSubtitle =>
      'Crear un contenedor nuevo con ambas pestañas.';

  @override
  String get browser_assignNewParentOption => 'Asignar nueva pestaña madre';

  @override
  String get browser_assignNewParentOptionSubtitle =>
      'Convertir la pestaña de destino en la madre.';

  @override
  String get browser_tabReorderingOnlyInDefaultMode =>
      'Solo se pueden reordenar las pestañas en el modo manual predeterminado';

  @override
  String get browser_tooltipSearchInsideTabs => 'Buscar dentro de las pestañas';

  @override
  String get browser_filterTabType => 'Tipo de pestaña';

  @override
  String get browser_sortPinnedFirst => 'Fijadas primero';

  @override
  String get browser_filterSort => 'Ordenar';

  @override
  String get browser_hierarchicalView => 'Vista jerárquica';

  @override
  String get browser_filterDate => 'Filtrar por fecha';

  @override
  String get browser_quickInterval => 'Intervalo rápido';

  @override
  String get browser_resetFilter => 'Restablecer filtro';

  @override
  String get browser_tooltipFilterAndSort => 'Filtrar y ordenar';

  @override
  String get browser_tooltipChangeViewMode => 'Cambiar modo de vista';

  @override
  String browser_downloadingAiModelsProgress(int percent) {
    return 'Descargando modelos de IA ($percent %)';
  }

  @override
  String get browser_disableAiTabSuggestions =>
      'Desactivar las sugerencias de pestañas con IA';

  @override
  String get browser_enableAiTabSuggestionsTooltip =>
      'Activar las sugerencias de pestañas con IA';

  @override
  String get browser_disableReorderingMode =>
      'Desactivar el modo de reordenación';

  @override
  String get browser_enableReorderingMode => 'Activar el modo de reordenación';

  @override
  String get browser_reorderingRequiresDefaultManualMode =>
      'Para reordenar se necesita el modo manual predeterminado';

  @override
  String get browser_dragAndDropTabsToReorder =>
      'Arrastra y suelta las pestañas para reordenarlas';

  @override
  String get browser_tooltipTabActions => 'Acciones de pestañas';

  @override
  String get browser_hintSearchTabs => 'Buscar pestañas';

  @override
  String get browser_noSyncedTabsAvailable =>
      'No hay pestañas sincronizadas disponibles';

  @override
  String browser_failedToLoadSyncedTabs(String error) {
    return 'No se pudieron cargar las pestañas sincronizadas: $error';
  }

  @override
  String get browser_translateFromLabel => 'De';

  @override
  String get browser_translateToLabel => 'A';

  @override
  String browser_translationError(String error) {
    return 'Error de traducción: $error';
  }

  @override
  String get browser_failedToRestorePage => 'No se pudo restaurar la página';

  @override
  String get browser_showOriginal => 'Mostrar original';

  @override
  String get browser_failedToTranslatePage => 'No se pudo traducir la página';

  @override
  String get browser_retranslate => 'Volver a traducir';

  @override
  String get browser_translateAction => 'Traducir';

  @override
  String get browser_tabTypeFilterAll => 'Todas las pestañas';

  @override
  String get browser_tabTypeFilterRegular => 'Normales';

  @override
  String get browser_tabTypeFilterPrivate => 'Privadas';

  @override
  String get browser_tabTypeFilterIsolated => 'Aisladas';

  @override
  String get browser_tabSortDefault => 'Predeterminado';

  @override
  String get browser_tabSortTitleAsc => 'Título A-Z';

  @override
  String get browser_tabSortTitleDesc => 'Título Z-A';

  @override
  String get browser_tabSortUrlAsc => 'URL A-Z';

  @override
  String get browser_tabSortUrlDesc => 'URL Z-A';

  @override
  String get browser_tabSortNewestFirst => 'Más recientes primero';

  @override
  String get browser_tabSortOldestFirst => 'Más antiguas primero';

  @override
  String get browser_tabIntervalLastHour => 'Última hora';

  @override
  String get browser_tabIntervalLast3Hours => 'Últimas 3 horas';

  @override
  String get browser_tabIntervalLast8Hours => 'Últimas 8 horas';

  @override
  String get browser_tabIntervalLastDay => 'Último día';

  @override
  String get browser_tabIntervalLast3Days => 'Últimos 3 días';

  @override
  String get browser_tabIntervalLastWeek => 'Última semana';

  @override
  String get browser_tabIntervalLastMonth => 'Último mes';

  @override
  String get browser_tabsViewModeList => 'Lista';

  @override
  String get browser_tabsViewModeGrid => 'Cuadrícula';

  @override
  String get browser_tabsViewModeTree => 'Árbol';

  @override
  String get browser_permissionCamera => 'Cámara';

  @override
  String get browser_permissionMicrophone => 'Micrófono';

  @override
  String get browser_permissionLocation => 'Ubicación';

  @override
  String get browser_permissionNotification => 'Notificaciones';

  @override
  String get browser_permissionPersistentStorage =>
      'Almacenamiento persistente';

  @override
  String get browser_permissionCrossOriginStorage =>
      'Almacenamiento entre orígenes';

  @override
  String get browser_permissionMediaKeySystem =>
      'Sistema de claves multimedia (DRM)';

  @override
  String get browser_tabReorderBlockedMessage =>
      'Borra el filtro o la búsqueda de la vista de pestañas para reordenarlas';

  @override
  String get contextualToolbar_tooltipHome => 'Inicio';

  @override
  String get contextualToolbar_tooltipHideTabBar => 'Ocultar barra de pestañas';

  @override
  String get contextualToolbar_tooltipClearBrowsingData =>
      'Borrar datos de navegación';

  @override
  String get contextualToolbar_tooltipAddBookmark => 'Añadir marcador';

  @override
  String get contextualToolbar_tooltipRemoveBookmark => 'Quitar marcador';

  @override
  String get contextualToolbar_tooltipEnableGestures => 'Activar gestos';

  @override
  String get contextualToolbar_tooltipDisableGestures => 'Desactivar gestos';

  @override
  String get contextualToolbar_actionHardRefresh => 'Recarga forzada';

  @override
  String get contextualToolbar_actionCloseOthers => 'Cerrar las demás';

  @override
  String get contextualToolbar_actionCloseFromSameHost =>
      'Cerrar las del mismo host';

  @override
  String get contextualToolbar_actionCloseTabAndDescendants =>
      'Cerrar pestaña y descendientes';

  @override
  String get contextualToolbar_actionAddBookmark => 'Añadir marcador';

  @override
  String get contextualToolbar_actionRemoveBookmark => 'Quitar marcador';

  @override
  String get contextualToolbar_actionCloneAsRegular => 'Clonar como normal';

  @override
  String get contextualToolbar_actionCloneAsPrivate => 'Clonar como privada';

  @override
  String get contextualToolbar_actionCloneAsIsolated => 'Clonar como aislada';

  @override
  String get contextualToolbar_bookmarkAdded => 'Marcador añadido';

  @override
  String get contextualToolbar_bookmarkRemoved => 'Marcador quitado';

  @override
  String get contextualToolbar_fontSizeAutoAdjustmentHint =>
      'Desactiva el tamaño de letra automático en los ajustes para ajustarlo manualmente';

  @override
  String get contextualToolbar_buttonLabelBack => 'Atrás';

  @override
  String get contextualToolbar_buttonLabelForward => 'Adelante';

  @override
  String get contextualToolbar_buttonLabelHome => 'Inicio';

  @override
  String get contextualToolbar_buttonLabelHistory => 'Historial';

  @override
  String get contextualToolbar_buttonLabelBookmarks => 'Marcadores';

  @override
  String get contextualToolbar_buttonLabelBookmarkToggle => 'Marcador';

  @override
  String get contextualToolbar_buttonLabelShare => 'Compartir';

  @override
  String get contextualToolbar_buttonLabelAddTab => 'Nueva pestaña';

  @override
  String get contextualToolbar_buttonLabelTabsCount => 'Pestañas';

  @override
  String get contextualToolbar_buttonLabelNavigationMenu => 'Menú';

  @override
  String get contextualToolbar_buttonLabelReload => 'Recargar';

  @override
  String get contextualToolbar_buttonLabelReaderMode => 'Vista de lectura';

  @override
  String get contextualToolbar_buttonLabelDesktop => 'Versión de escritorio';

  @override
  String get contextualToolbar_buttonLabelTranslation => 'Traducir';

  @override
  String get contextualToolbar_buttonLabelFindInPage => 'Buscar en la página';

  @override
  String get contextualToolbar_buttonLabelCloseTab => 'Cerrar pestaña';

  @override
  String get contextualToolbar_buttonLabelInputUrl => 'Barra de direcciones';

  @override
  String get contextualToolbar_buttonLabelQrScan => 'Escanear código QR';

  @override
  String get contextualToolbar_buttonLabelVoiceSearch => 'Búsqueda por voz';

  @override
  String get contextualToolbar_buttonLabelDuplicateTab => 'Duplicar pestaña';

  @override
  String get contextualToolbar_buttonLabelIncreaseFont => 'Aumentar letra';

  @override
  String get contextualToolbar_buttonLabelDecreaseFont => 'Reducir letra';

  @override
  String get contextualToolbar_buttonLabelMoveToBackground => 'Segundo plano';

  @override
  String get contextualToolbar_buttonLabelToggleGestures => 'Gestos';

  @override
  String get contextualToolbar_buttonLabelHideTabBar =>
      'Ocultar barra de pestañas';

  @override
  String get contextualToolbar_buttonLabelPageUp => 'Retroceder página';

  @override
  String get contextualToolbar_buttonLabelPageDown => 'Avanzar página';

  @override
  String get contextualToolbar_buttonLabelFont => 'Tamaño del texto';

  @override
  String get contextualToolbar_buttonLabelExtensionShortcut => 'Extensiones';

  @override
  String get contextualToolbar_buttonLabelClearBrowsingData => 'Borrar datos';

  @override
  String get contextualToolbar_buttonLabelQuit => 'Salir';

  @override
  String get contextualToolbar_longPressBackHistoryMenu =>
      'Menú del historial (páginas anteriores)';

  @override
  String get contextualToolbar_longPressForwardHistoryMenu =>
      'Menú del historial (páginas siguientes)';

  @override
  String get contextualToolbar_longPressOpenBookmarks => 'Abrir marcadores';

  @override
  String get contextualToolbar_longPressAddRegularTab =>
      'Añadir pestaña normal';

  @override
  String get contextualToolbar_longPressAddChildTab => 'Añadir pestaña hija';

  @override
  String get contextualToolbar_longPressAddPrivateTab =>
      'Añadir pestaña privada';

  @override
  String get contextualToolbar_longPressAddIsolatedTab =>
      'Añadir pestaña aislada';

  @override
  String get contextualToolbar_longPressOpenSettings => 'Abrir ajustes';

  @override
  String get contextualToolbar_longPressHardRefresh =>
      'Recarga forzada (sin caché)';

  @override
  String get contextualToolbar_longPressShowTranslationOptions =>
      'Mostrar opciones de traducción';

  @override
  String get contextualToolbar_longPressScrollToTop => 'Ir al principio';

  @override
  String get contextualToolbar_longPressScrollToBottom => 'Ir al final';

  @override
  String get contextualToolbar_longPressExtensionsMenu => 'Menú de extensiones';

  @override
  String get contextualToolbar_longPressQuitWithoutConfirmation =>
      'Salir sin confirmación';

  @override
  String get menu_sectionQuickToggles => 'Interruptores rápidos';

  @override
  String get menu_sectionPageActions => 'Acciones de página';

  @override
  String get menu_sectionExtensions => 'Extensiones';

  @override
  String get menu_sectionTabActions => 'Acciones de pestaña';

  @override
  String get menu_sectionQuickLinks => 'Accesos rápidos';

  @override
  String get menu_sectionConnection => 'Conexión';

  @override
  String get menu_sectionProfile => 'Perfil y aplicación';

  @override
  String get menu_sectionAbout => 'Acerca de';

  @override
  String get menu_itemDesktopMode => 'Escritorio';

  @override
  String get menu_itemReaderMode => 'Lectura';

  @override
  String get menu_itemGestures => 'Gestos';

  @override
  String get menu_itemAddBookmark => 'Añadir marcador';

  @override
  String get menu_itemFindInPage => 'Buscar en la página';

  @override
  String get menu_itemTranslatePage => 'Traducir página';

  @override
  String get menu_itemAddToHomeScreen => 'Añadir a la pantalla de inicio';

  @override
  String get menu_itemOpenInApp => 'Abrir en la aplicación';

  @override
  String get menu_itemContainers => 'Contenedores';

  @override
  String get menu_itemManageContainers => 'Gestionar contenedores';

  @override
  String get menu_itemAssignContainer => 'Asignar contenedor';

  @override
  String get menu_itemAssignUrlToContainer => 'Asignar URL al contenedor';

  @override
  String get menu_itemUnassignUrlFromContainer =>
      'Desasignar URL del contenedor';

  @override
  String get menu_itemUnassignContainer => 'Desasignar contenedor';

  @override
  String get menu_itemShare => 'Compartir';

  @override
  String get menu_itemCopyAddress => 'Copiar dirección';

  @override
  String get menu_itemShareScreenshot => 'Compartir captura de pantalla';

  @override
  String get menu_itemShareLink => 'Compartir enlace';

  @override
  String get menu_itemSendToDevice => 'Enviar a dispositivo';

  @override
  String get menu_itemShowQrCode => 'Mostrar código QR';

  @override
  String get menu_itemMoreDisclosure => 'Más';

  @override
  String get menu_itemCloneTab => 'Clonar pestaña';

  @override
  String get menu_itemCloneRegularTab => 'Normal';

  @override
  String get menu_itemClonePrivateTab => 'Privada';

  @override
  String get menu_itemCloneIsolatedTab => 'Aislada';

  @override
  String get menu_itemExport => 'Exportar';

  @override
  String get menu_itemCopyAsMarkdown => 'Copiar como Markdown';

  @override
  String get menu_itemExportAsMarkdown => 'Exportar como Markdown';

  @override
  String get menu_itemExportAsPdf => 'Exportar como PDF';

  @override
  String get menu_itemExportAsPng => 'Exportar como PNG';

  @override
  String get menu_itemPrintPage => 'Imprimir';

  @override
  String get menu_itemPinTopSite => 'Fijar en accesos directos';

  @override
  String get menu_itemFetchFeeds => 'Obtener fuentes';

  @override
  String get menu_itemHistory => 'Historial';

  @override
  String get menu_itemBookmarks => 'Marcadores';

  @override
  String get menu_itemDownloads => 'Descargas';

  @override
  String get menu_itemBangs => 'Bangs';

  @override
  String get menu_itemFeeds => 'Fuentes';

  @override
  String get menu_itemSmallWeb => 'Small Web';

  @override
  String get menu_itemClearData => 'Borrar datos';

  @override
  String get menu_itemProfileSwitch => 'Perfil';

  @override
  String get menu_itemSyncNow => 'Sincronizar ahora';

  @override
  String get menu_itemAppSettings => 'Ajustes';

  @override
  String get menu_itemQuitBrowser => 'Salir del navegador';

  @override
  String get menu_itemAbout => 'Acerca de';

  @override
  String get menu_itemMoreDisclosureDescription =>
      'Agrupa todo lo que hay debajo tras una fila «Más»';

  @override
  String get menu_itemSendToDeviceDescription =>
      'Los dispositivos proceden de tu cuenta';

  @override
  String get menu_reorderHideTooltip => 'Ocultar';

  @override
  String get menu_reorderShowTooltip => 'Mostrar';

  @override
  String menu_reorderRowsShown(int shown, int total) {
    return 'Filas visibles: $shown de $total';
  }

  @override
  String get menu_reorderDefaultTitle => 'Personalizar menú';

  @override
  String get menu_reorderSubtitleSections =>
      'Arrastra para reordenar. Desactiva una sección para ocultarla del menú.';

  @override
  String get menu_reorderSubtitleSectionRows =>
      'Arrastra para reordenar las filas de esta sección.';

  @override
  String get menu_reorderSubtitleItemRows =>
      'Arrastra para reordenar las filas que abre este elemento.';

  @override
  String get menu_reorderBackTooltip => 'Volver a las secciones';

  @override
  String get menu_reorderResetToDefaults =>
      'Restablecer valores predeterminados';

  @override
  String get menu_customizeMenuButton => 'Personalizar menú';

  @override
  String get menu_navStop => 'Detener';

  @override
  String get menu_navBack => 'Atrás';

  @override
  String get menu_navForward => 'Adelante';

  @override
  String get menu_navCloseTab => 'Cerrar pestaña';

  @override
  String get menu_navReload => 'Recargar';

  @override
  String get menu_navCloseOthers => 'Cerrar las demás';

  @override
  String get menu_navCloseFromSameHost => 'Cerrar las del mismo host';

  @override
  String get menu_navCloseTabAndDescendants => 'Cerrar pestaña y descendientes';

  @override
  String get menu_navHardRefresh => 'Recarga forzada';

  @override
  String get menu_profileTapToSwitch => 'Pulsa para cambiar de perfil';

  @override
  String get menu_profileSyncComplete => 'Sincronización completada';

  @override
  String menu_openInApp(String appName) {
    return 'Abrir en $appName';
  }

  @override
  String get menu_pageTranslated => 'Traducida';

  @override
  String get menu_extensionsTitle => 'Extensiones';

  @override
  String get menu_extensionFallbackTitle => 'Extensión';

  @override
  String get menu_extensionsSettingsTooltip => 'Ajustes de la extensión';

  @override
  String get menu_extensionsManage => 'Gestionar extensiones';

  @override
  String get menu_containersExpansionTitle => 'Contenedores';

  @override
  String get menu_containersManage => 'Gestionar contenedores';

  @override
  String get menu_containersAssign => 'Asignar contenedor';

  @override
  String get menu_containersAssignUrl => 'Asignar URL al contenedor';

  @override
  String get menu_containersUnassignUrl => 'Desasignar URL del contenedor';

  @override
  String get menu_containersUnassign => 'Desasignar contenedor';

  @override
  String get menu_shareExpansionTitle => 'Compartir';

  @override
  String get menu_shareUrlCleaned => 'URL limpiada';

  @override
  String get menu_shareUrlPreviewApplied => 'Vista previa de la URL aplicada';

  @override
  String get menu_shareCopyAddress => 'Copiar dirección';

  @override
  String get menu_shareScreenshot => 'Compartir captura de pantalla';

  @override
  String get menu_shareLink => 'Compartir enlace';

  @override
  String get menu_shareShowQrCode => 'Mostrar código QR';

  @override
  String get menu_sendToDeviceExpansionTitle => 'Enviar a dispositivo';

  @override
  String get menu_sendToDeviceNone => 'No hay dispositivos de destino';

  @override
  String get menu_sendToDeviceLoading => 'Cargando dispositivos...';

  @override
  String get menu_sendToDeviceLoadFailed =>
      'No se pudieron cargar los dispositivos';

  @override
  String menu_sendToDeviceSuccess(String deviceName) {
    return 'Pestaña enviada a $deviceName';
  }

  @override
  String get menu_sendToDeviceSendFailed => 'No se pudo enviar la pestaña';

  @override
  String get menu_cloneTabExpansionTitle => 'Clonar pestaña';

  @override
  String get menu_cloneTypeRegular => 'Normal';

  @override
  String get menu_cloneTypePrivate => 'Privada';

  @override
  String get menu_cloneTypeIsolated => 'Aislada';

  @override
  String get menu_exportExpansionTitle => 'Exportar';

  @override
  String get menu_exportCopyAsMarkdown => 'Copiar como Markdown';

  @override
  String get menu_exportAsMarkdown => 'Exportar como Markdown';

  @override
  String get menu_exportAsPdf => 'Exportar como PDF';

  @override
  String get menu_exportAsPng => 'Exportar como PNG';

  @override
  String get menu_exportMarkdownCopied => 'Markdown copiado al portapapeles';

  @override
  String get menu_exportPrint => 'Imprimir';

  @override
  String get menu_exportPrintFailed => 'No se pudo imprimir la página';

  @override
  String get menu_pinUnpinFromShortcuts => 'Desfijar de accesos directos';

  @override
  String get menu_pinPinToShortcuts => 'Fijar en accesos directos';

  @override
  String get menu_pinUnpinnedMessage => 'Desfijado de accesos directos';

  @override
  String get menu_pinPinnedMessage => 'Fijado en accesos directos';

  @override
  String get menu_pinUpdateFailed =>
      'No se pudieron actualizar los accesos directos';

  @override
  String get menu_fetchFeedsTitle => 'Obtener fuentes de la página';

  @override
  String get menu_fetchFeedsNone => 'No se encontraron fuentes web';

  @override
  String get menu_fetchFeedsAvailable => 'Fuentes web disponibles';

  @override
  String get menu_fetchFeedsLoading => 'Obteniendo fuentes web...';

  @override
  String get menu_connectionTitle => 'Conexión';

  @override
  String get menu_connectionRegularTabs => 'Pestañas normales';

  @override
  String get menu_connectionPrivateTabs => 'Pestañas privadas';

  @override
  String menu_connectionAllThrough(String proxyTitle) {
    return 'Todas a través de $proxyTitle';
  }

  @override
  String get menu_connectionPerContainer => 'Por contenedor';

  @override
  String get menu_connectionPerContainerSubtitle =>
      'Solo se enrutan los contenedores con un proxy asignado';

  @override
  String get menu_connectionDirect => 'Directa';

  @override
  String get menu_connectionPrivateNeverInheritSubtitle =>
      'Las pestañas privadas nunca heredan la ruta global';

  @override
  String get menu_connectionThisIsolatedTab => 'Esta pestaña aislada';

  @override
  String get menu_connectionFollowsContainer => 'Sigue a su contenedor';

  @override
  String get menu_connectionFollowContainerOption => 'Seguir a su contenedor';

  @override
  String get menu_connectionFollowContainerOptionSubtitle =>
      'Usar la ruta asignada al contenedor de esta pestaña';

  @override
  String get menu_connectionIsolatedDirectSubtitle =>
      'Omitir la ruta que aplicaría su contenedor';

  @override
  String get menu_connectionThisContainer => 'Este contenedor';

  @override
  String get menu_connectionFollowsGlobalRouting =>
      'Sigue el enrutamiento global';

  @override
  String get menu_connectionContainerFallbackTitle => 'Contenedor';

  @override
  String get menu_connectionFollowGlobalRoutingOption =>
      'Seguir el enrutamiento global';

  @override
  String get menu_connectionFollowGlobalRoutingOptionSubtitle =>
      'Usar la misma ruta que las pestañas normales';

  @override
  String get menu_connectionContainerDirectSubtitle =>
      'Omitir el proxy global para este contenedor';

  @override
  String menu_connectionFailedToChangeRoute(String error) {
    return 'No se pudo cambiar la ruta: $error';
  }

  @override
  String menu_connectionProxyError(String error) {
    return 'Error del proxy: $error';
  }

  @override
  String menu_connectionNotRoutedByContainer(String container) {
    return 'No se enruta por el contenedor «$container»';
  }

  @override
  String get menu_connectionNotRoutedByTabContainer =>
      'No se enruta por el contenedor de esta pestaña';

  @override
  String get menu_connectionCheckingRouting => 'Comprobando el enrutamiento…';

  @override
  String get menu_connectionStartingRouting => 'Iniciando el enrutamiento…';

  @override
  String menu_connectionBlockedNotRunning(String proxyTitle) {
    return 'Bloqueada: $proxyTitle no se está ejecutando';
  }

  @override
  String menu_connectionThisTabVia(String proxyTitle) {
    return 'Esta pestaña: $proxyTitle';
  }

  @override
  String get menu_connectionThisTabDirect => 'Esta pestaña: conexión directa';

  @override
  String menu_connectionStartProxy(String proxyTitle) {
    return 'Iniciar $proxyTitle';
  }

  @override
  String get menu_connectionProxySettings => 'Ajustes del proxy';

  @override
  String get menu_connectionUnused => 'No lo usa ninguna ruta';

  @override
  String menu_connectionUsageContainerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contenedores',
      one: '1 contenedor',
    );
    return '$_temp0';
  }

  @override
  String menu_connectionUsageIsolatedTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pestañas aisladas',
      one: '1 pestaña aislada',
    );
    return '$_temp0';
  }

  @override
  String get menu_connectionUsageBlocked => 'Bloqueado';

  @override
  String get contextmenu_openInNewTab => 'Abrir en una pestaña nueva';

  @override
  String get contextmenu_tooltipOpenInDifferentTabType =>
      'Abrir en otro tipo de pestaña';

  @override
  String get contextmenu_newRegularTab => 'Nueva pestaña normal';

  @override
  String get contextmenu_newPrivateTab => 'Nueva pestaña privada';

  @override
  String get contextmenu_newIsolatedTab => 'Nueva pestaña aislada';

  @override
  String get contextmenu_openImageInNewTab =>
      'Abrir imagen en una pestaña nueva';

  @override
  String get contextmenu_openInContainer => 'Abrir en contenedor';

  @override
  String get contextmenu_selectContainerTitle => 'Seleccionar contenedor';

  @override
  String get contextmenu_loadContainersFailedTitle =>
      'No se pudieron cargar los contenedores';

  @override
  String get contextmenu_newContainer => 'Nuevo contenedor';

  @override
  String get contextmenu_openInApp => 'Abrir en la aplicación';

  @override
  String contextmenu_openInAppNamed(String appName) {
    return 'Abrir en $appName';
  }

  @override
  String get contextmenu_copyLink => 'Copiar enlace';

  @override
  String get contextmenu_copyLinkText => 'Copiar texto del enlace';

  @override
  String get contextmenu_copyImage => 'Copiar imagen';

  @override
  String get contextmenu_copyImageLocation => 'Copiar dirección de la imagen';

  @override
  String get contextmenu_saveFile => 'Guardar archivo';

  @override
  String get contextmenu_saveImage => 'Guardar imagen';

  @override
  String get contextmenu_shareImage => 'Compartir imagen';

  @override
  String get contextmenu_shareEmailAddress => 'Compartir dirección de correo';

  @override
  String get contextmenu_urlCleanedMessage => 'URL limpiada';

  @override
  String get contextmenu_urlPreviewAppliedMessage =>
      'Vista previa de la URL aplicada';

  @override
  String get findInPage_hint => 'Buscar en la página';

  @override
  String findInPage_matchPosition(int current, int total) {
    return '$current de $total';
  }

  @override
  String get findInPage_noMatches => 'No encontrado';

  @override
  String get history_titleHistory => 'Historial';

  @override
  String get history_titleDownloads => 'Descargas';

  @override
  String get history_filterHintHistory => 'Filtrar historial…';

  @override
  String get history_filterHintDownloads => 'Filtrar descargas…';

  @override
  String history_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipClearSearch => 'Borrar búsqueda';

  @override
  String get history_tooltipSearchHistory => 'Buscar en el historial';

  @override
  String get history_tooltipSearchDownloads => 'Buscar en las descargas';

  @override
  String history_tooltipClearContainerHistory(String container) {
    return 'Borrar el historial de «$container»';
  }

  @override
  String get history_filterDate => 'Fecha';

  @override
  String get history_filterContainer => 'Contenedor';

  @override
  String get history_allContainers => 'Todos los contenedores';

  @override
  String get history_unnamedContainer => 'Contenedor sin nombre';

  @override
  String history_containerFilterLabel(String container) {
    return 'Contenedor: $container';
  }

  @override
  String get history_resetFilter => 'Restablecer filtro';

  @override
  String get history_filterTypeFollowedLinks => 'Enlaces seguidos';

  @override
  String get history_filterTypeTypedAddresses => 'Direcciones escritas';

  @override
  String get history_filterTypeEmbeddedPageElements => 'Elementos incrustados';

  @override
  String get history_filterTypePermanentRedirects =>
      'Redirecciones permanentes';

  @override
  String get history_filterTypeTemporaryRedirects => 'Redirecciones temporales';

  @override
  String get history_filterTypeDownloads => 'Descargas';

  @override
  String get history_filterTypeFrames => 'Marcos';

  @override
  String get history_filterTypePageReloads => 'Recargas de página';

  @override
  String get history_filterTypeBookmarks => 'Marcadores';

  @override
  String get history_visitTypeFollowedLink => 'Enlace seguido';

  @override
  String get history_visitTypeTypedAddress => 'Dirección escrita';

  @override
  String get history_visitTypeEmbeddedPageElement => 'Elemento incrustado';

  @override
  String get history_visitTypePermanentRedirect => 'Redirección permanente';

  @override
  String get history_visitTypeTemporaryRedirect => 'Redirección temporal';

  @override
  String get history_visitTypeDownload => 'Descarga';

  @override
  String get history_visitTypeFrame => 'Marco';

  @override
  String get history_visitTypePageReload => 'Recarga de página';

  @override
  String get history_visitTypeBookmark => 'Marcador';

  @override
  String get history_clearContainerHistoryTitle =>
      'Borrar historial del contenedor';

  @override
  String history_clearContainerHistoryContent(String container) {
    return '¿Seguro que quieres borrar todo el historial de «$container»?';
  }

  @override
  String get history_downloadedFileNotFound =>
      'No se encontró el archivo descargado';

  @override
  String get history_couldNotOpenDownloadedFile =>
      'No se pudo abrir el archivo descargado';

  @override
  String get history_loadHistoryFailedTitle => 'No se pudo cargar el historial';

  @override
  String get history_loadDownloadsFailedTitle =>
      'No se pudieron cargar las descargas';

  @override
  String get history_deleteFileTitle => 'Eliminar archivo';

  @override
  String history_deleteFileConfirm(String fileName) {
    return '¿Seguro que quieres eliminar $fileName?';
  }

  @override
  String get history_deleteFileWarning =>
      'El archivo se eliminará de forma permanente de tu dispositivo.';

  @override
  String get history_deleteFileRememberChoice =>
      'Recordar mi elección para los archivos restantes';

  @override
  String get history_deleteFileActionKeep => 'Conservar';

  @override
  String get history_filterDistinctUrls => 'URL únicas';

  @override
  String history_visitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visitas',
      one: '1 visita',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipDeleteHistory => 'Eliminar historial';

  @override
  String get history_deleteMenuTimeRange => 'Eliminar un intervalo de tiempo…';

  @override
  String get history_deleteMenuBrowsingData => 'Eliminar datos de navegación…';

  @override
  String get history_deleteTimeRangeTitle =>
      'Eliminar el historial de un intervalo de tiempo';

  @override
  String get history_deleteTimeRangeFrom => 'Desde';

  @override
  String get history_deleteTimeRangeTo => 'Hasta';

  @override
  String get history_deleteTimeRangeLastHour => 'Última hora';

  @override
  String get history_deleteTimeRangeToday => 'Hoy';

  @override
  String get history_deleteTimeRangeLastWeek => 'Últimos 7 días';

  @override
  String get history_deleteTimeRangeExplanation =>
      'Se eliminan todas las visitas de este intervalo, en todos los contenedores. Las descargas finalizadas y fallidas de este intervalo también desaparecen de la lista de descargas; los archivos se quedan en el dispositivo. Las descargas en curso se conservan.';

  @override
  String get history_deleteTimeRangeInvalid =>
      'El inicio debe ser anterior al final.';

  @override
  String get history_tooltipEntryActions => 'Más acciones';

  @override
  String get history_actionOpenInBackground => 'Abrir en segundo plano';

  @override
  String get history_actionCopyLink => 'Copiar enlace';

  @override
  String get history_actionShareLink => 'Compartir enlace';

  @override
  String get openLinkTools_openLinkTitle => 'Abrir enlace';

  @override
  String get openLinkTools_urlCleanedMessage => 'URL limpiada';

  @override
  String get openLinkTools_urlPreviewAppliedMessage =>
      'Vista previa de la URL aplicada';

  @override
  String get openLinkTools_urlBlockedByClearUrls =>
      'URL bloqueada por ClearURLs';

  @override
  String openLinkTools_unshortenFailedWithError(String error) {
    return 'No se pudo expandir el enlace: $error';
  }

  @override
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit) {
    return 'Solicitudes restantes: $remaining/$limit';
  }

  @override
  String get openLinkTools_unshortenTileTitle => 'Expandir';

  @override
  String get openLinkTools_unshortenTileSubtitle => 'Resolver la URL acortada';

  @override
  String get openLinkTools_unshortenerInfoTooltip =>
      'Información del expansor de enlaces';

  @override
  String openLinkTools_openInAppNamed(String appName) {
    return 'Abrir en $appName';
  }

  @override
  String get openLinkTools_openInAppGeneric => 'Abrir en la aplicación';

  @override
  String get openLinkTools_openInAppSubtitle =>
      'Abrir en una aplicación instalada';

  @override
  String get openLinkTools_couldNotOpenInApp =>
      'No se pudo abrir en la aplicación';

  @override
  String get openLinkTools_openInNewTabTitle => 'Abrir en una pestaña nueva';

  @override
  String get openLinkTools_openInNewTabSubtitle =>
      'Añadir a tus pestañas del navegador';

  @override
  String get openLinkTools_openInCustomTabTitle =>
      'Abrir en una pestaña personalizada';

  @override
  String get openLinkTools_openInCustomTabSubtitle =>
      'Abrir en una ventana aparte';

  @override
  String get openLinkTools_unshortenerAttributionTitle =>
      'Atribución del expansor de enlaces';

  @override
  String openLinkTools_unshortenerAttributionBody(String service) {
    return 'Este módulo resuelve los enlaces acortados enviándolos a $service. El servicio comprueba cada enlace en sus servidores y guarda la redirección para futuras solicitudes. Evita enviar enlaces que contengan datos privados o sensibles.';
  }

  @override
  String get openLinkTools_unshortenerRateLimitNotice =>
      'La API gratuita está limitada a 10 solicitudes por hora para comprobaciones nuevas.';

  @override
  String openLinkTools_privacyPolicyLabel(String link) {
    return 'Política de privacidad: $link';
  }

  @override
  String get openLinkTools_removeTrackingParametersTitle =>
      'Quitar parámetros de rastreo';

  @override
  String get openLinkTools_removeTrackingParametersSubtitle =>
      'Selecciona los parámetros que se quitarán de esta URL.';

  @override
  String get openLinkTools_referralMarketingBadge => 'Marketing de afiliación';

  @override
  String openLinkTools_selectedForRemovalCount(int selected, int total) {
    return '$selected de $total seleccionados para quitar';
  }

  @override
  String get openLinkTools_cleanedUrlLabel => 'URL limpia:';

  @override
  String get openLinkTools_restoreDefaultsTitle =>
      '¿Restaurar los valores predeterminados?';

  @override
  String get openLinkTools_restoreDefaultsContent =>
      'Se restablecerán los ajustes del limpiador de URL y se eliminará el catálogo guardado localmente.';

  @override
  String get openLinkTools_actionRestore => 'Restaurar';

  @override
  String get openLinkTools_actionApplyChanges => 'Aplicar cambios';

  @override
  String openLinkTools_couldNotOpenLink(String url) {
    return 'No se pudo abrir el enlace: $url';
  }

  @override
  String get openLinkTools_tileTitleCleaned => 'URL limpiada';

  @override
  String openLinkTools_tileSubtitleRemovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se quitaron $count parámetros de rastreo',
      one: 'Se quitó 1 parámetro de rastreo',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitlePartiallyCleaned =>
      'URL limpiada parcialmente';

  @override
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total) {
    return 'Parámetros de rastreo quitados: $removed de $total';
  }

  @override
  String get openLinkTools_tileTitleTrackingDetected => 'Rastreo detectado';

  @override
  String openLinkTools_tileSubtitleFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se encontraron $count parámetros de rastreo',
      one: 'Se encontró 1 parámetro de rastreo',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_cleanUrlTooltip => 'Limpiar URL';

  @override
  String get openLinkTools_unshortenerSettingsTitle => 'Expansor de enlaces';

  @override
  String get openLinkTools_unshortenerSettingsSubtitle =>
      'Comportamiento de la resolución de enlaces cortos, configuración del token y atribución.';

  @override
  String get openLinkTools_unshortenerEnabledTitle =>
      'Activar el expansor de enlaces';

  @override
  String get openLinkTools_unshortenerEnabledKeywords =>
      'enlaces cortos, acortador, expandir, short links';

  @override
  String get openLinkTools_unshortenerEnabledSubtitle =>
      'Resolver las URL acortadas a su destino';

  @override
  String get openLinkTools_descriptionLabel => 'Descripción';

  @override
  String get openLinkTools_unshortenerDescriptionBody =>
      'Este módulo resuelve los enlaces acortados enviándolos a unshorten.me. El servicio comprueba cada enlace en sus servidores y guarda la redirección para futuras solicitudes. Evita enviar enlaces que contengan datos privados o sensibles.';

  @override
  String get openLinkTools_attributionServiceLabel => 'Servicio';

  @override
  String get openLinkTools_attributionPrivacyPolicyLabel =>
      'Política de privacidad';

  @override
  String get openLinkTools_apiTokenLabel => 'Token de API';

  @override
  String get openLinkTools_apiTokenLabelKeywords => 'token, clave';

  @override
  String get openLinkTools_apiTokenHint =>
      'Token opcional para límites más altos';

  @override
  String get openLinkTools_urlCleanerSettingsTitle => 'Limpiador de URL';

  @override
  String get openLinkTools_urlCleanerSettingsSubtitle =>
      'Comportamiento de la limpieza de URL, actualizaciones del catálogo de reglas y atribución.';

  @override
  String get openLinkTools_urlCleanerDescriptionBody =>
      'Este módulo quita de las URL los parámetros de rastreo, de referencia y otros innecesarios. También puede resolver sin conexión redirecciones de URL habituales.';

  @override
  String get openLinkTools_urlCleanerEnabledTitle =>
      'Activar el limpiador de URL';

  @override
  String get openLinkTools_urlCleanerEnabledKeywords =>
      'limpiar url, rastreo, clean urls';

  @override
  String get openLinkTools_urlCleanerEnabledSubtitle =>
      'Quitar los parámetros de rastreo de las URL';

  @override
  String get openLinkTools_autoApplyTitle => 'Aplicar automáticamente';

  @override
  String get openLinkTools_autoApplyKeywords =>
      'automático, aplicar, auto apply';

  @override
  String get openLinkTools_autoApplySubtitle =>
      'Sustituir automáticamente la URL por una versión limpia';

  @override
  String get openLinkTools_allowReferralTitle =>
      'Permitir el marketing de afiliación';

  @override
  String get openLinkTools_allowReferralKeywords =>
      'afiliados, referencia, affiliate, referral';

  @override
  String get openLinkTools_allowReferralSubtitle =>
      'Conservar los parámetros de rastreo de referencia y afiliación';

  @override
  String get openLinkTools_autoUpdateCatalogTitle =>
      'Actualizar el catálogo automáticamente';

  @override
  String get openLinkTools_autoUpdateCatalogSubtitle =>
      'Buscar actualizaciones de reglas cada semana';

  @override
  String get openLinkTools_updateCatalogTitle => 'Actualizar catálogo';

  @override
  String get openLinkTools_lastUpdateNotAvailable =>
      'Última actualización: no disponible';

  @override
  String openLinkTools_lastUpdateWithDate(String date) {
    return 'Última actualización: $date';
  }

  @override
  String openLinkTools_lastAutoUpdateWithDate(String date) {
    return 'Última actualización: $date (automática)';
  }

  @override
  String openLinkTools_lastCheckWithDate(String date) {
    return 'Última comprobación: $date';
  }

  @override
  String get openLinkTools_catalogUpdatedMessage => 'Catálogo actualizado';

  @override
  String openLinkTools_updateFailedWithError(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String get openLinkTools_restoreDefaultsButtonTitle =>
      'Restaurar valores predeterminados';

  @override
  String get openLinkTools_restoreDefaultsButtonSubtitle =>
      'Volver al catálogo incluido y a los ajustes predeterminados';

  @override
  String get openLinkTools_clearUrlAttributionText =>
      'Este módulo se basa en las reglas de ClearURL:';

  @override
  String get openLinkTools_urlCleanerOverviewSectionTitle => 'Resumen';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionTitle => 'Descripción';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionKeywords =>
      'parámetros de rastreo, redirecciones, tracking parameters, redirects';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle =>
      'Eliminación de parámetros de rastreo y limpieza de redirecciones sin conexión';

  @override
  String get openLinkTools_urlCleanerBehaviorSectionTitle => 'Comportamiento';

  @override
  String get openLinkTools_urlCleanerCatalogSectionTitle => 'Catálogo';

  @override
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle =>
      'Obtener las reglas más recientes del limpiador de URL';

  @override
  String get openLinkTools_urlCleanerAttributionSectionTitle => 'Atribución';

  @override
  String get openLinkTools_indexUrlCleanerAttributionTitle => 'Atribución';

  @override
  String get openLinkTools_indexUrlCleanerAttributionSubtitle =>
      'Créditos y enlaces a las fuentes';

  @override
  String get openLinkTools_unshortenerOverviewSectionTitle => 'Resumen';

  @override
  String get openLinkTools_indexUnshortenerDescriptionTitle => 'Descripción';

  @override
  String get openLinkTools_indexUnshortenerDescriptionKeywords =>
      'enlaces cortos, redirecciones, short links, redirects';

  @override
  String get openLinkTools_indexUnshortenerDescriptionSubtitle =>
      'Resolver URL acortadas mediante el servicio unshorten.me';

  @override
  String get openLinkTools_unshortenerBehaviorSectionTitle => 'Comportamiento';

  @override
  String get openLinkTools_indexUnshortenerApiTokenSubtitle =>
      'Token opcional para límites de solicitudes más altos';

  @override
  String get openLinkTools_unshortenerAttributionSectionTitle => 'Atribución';

  @override
  String get openLinkTools_indexUnshortenerAttributionTitle =>
      'Atribución del servicio';

  @override
  String get openLinkTools_indexUnshortenerAttributionKeywords =>
      'política de privacidad, límite, privacy policy, rate limit';

  @override
  String get openLinkTools_indexUnshortenerAttributionSubtitle =>
      'Límites de solicitudes, página del servicio y política de privacidad';

  @override
  String get pwa_addToHomeScreenTitle => 'Añadir a la pantalla de inicio';

  @override
  String get pwa_nameFieldLabel => 'Nombre';

  @override
  String get pwa_storageLabel => 'Almacenamiento';

  @override
  String get pwa_defaultContainerLabel => 'Contenedor';

  @override
  String get pwa_installAsAppTitle => 'Instalar como aplicación';

  @override
  String get pwa_installAsAppSubtitle =>
      'Se ejecuta de forma independiente en su propia ventana.';

  @override
  String get pwa_addShortcutTitle => 'Añadir acceso directo';

  @override
  String get pwa_addShortcutSubtitle =>
      'Se abre como una pestaña normal del navegador.';

  @override
  String get pwa_storageDefaultTitle => 'Predeterminado';

  @override
  String get pwa_storageDefaultSubtitle =>
      'Usa el almacenamiento predeterminado del navegador (sin contenedor).';

  @override
  String pwa_storageContainerTitle(String label) {
    return 'Contenedor «$label»';
  }

  @override
  String get pwa_storageContainerSubtitle =>
      'Comparte cookies y datos con el contenedor seleccionado.';

  @override
  String get pwa_storageInheritIsolatedTitle =>
      'Heredar el contexto aislado actual';

  @override
  String get pwa_storageInheritIsolatedSubtitle =>
      'Comparte el almacenamiento con la sesión aislada abierta actualmente.';

  @override
  String get pwa_storageNewIsolatedTitle => 'Nuevo contexto aislado';

  @override
  String get pwa_storageNewIsolatedSubtitle =>
      'Crea un almacenamiento nuevo solo para esta instalación.';

  @override
  String get pwa_defaultWebAppName => 'esta aplicación web';

  @override
  String get pwa_defaultSiteName => 'este sitio';

  @override
  String pwa_addedToHomeScreen(String name) {
    return 'Se añadió $name a la pantalla de inicio';
  }

  @override
  String pwa_installFailedManifestBacked(String name) {
    return 'No se pudo añadir $name. Es posible que el sitio no admita la instalación.';
  }

  @override
  String pwa_installFailedGeneric(String name) {
    return 'No se pudo añadir $name a la pantalla de inicio';
  }

  @override
  String get pwa_noTabSelected =>
      'No hay ninguna pestaña seleccionada. Vuelve a intentarlo.';

  @override
  String get search_moduleLabelRecentSearches => 'Búsquedas recientes';

  @override
  String get search_moduleLabelSearchProviders => 'Proveedores de búsqueda';

  @override
  String get search_moduleLabelSearchSuggestions => 'Sugerencias';

  @override
  String get search_moduleLabelTabs => 'Pestañas';

  @override
  String get search_moduleLabelArticles => 'Artículos';

  @override
  String get search_moduleLabelBookmarks => 'Marcadores';

  @override
  String get search_moduleLabelHistory => 'Historial (motor)';

  @override
  String get search_moduleLabelLocalHistory => 'Contenido local';

  @override
  String get search_moduleLabelCombinedHistory => 'Historial';

  @override
  String get search_moduleLabelPopularSites => 'Sitios populares';

  @override
  String get search_moduleLabelHistoryHighlights => 'Destacados del historial';

  @override
  String get search_moduleLabelTopSites => 'Accesos directos';

  @override
  String get search_moduleLabelRecentHistory => 'Historial reciente';

  @override
  String get search_moduleLabelRecentArticles => 'Artículos recientes';

  @override
  String get search_moduleLabelRecentTabs => 'Pestañas recientes';

  @override
  String get search_moduleLabelContainers => 'Contenedores';

  @override
  String get search_moduleLabelFrequentBangs => 'Bangs frecuentes';

  @override
  String get search_moduleLabelQuote => 'Cita';

  @override
  String get search_moduleLabelQuickActions => 'Acciones rápidas';

  @override
  String get search_moduleLabelActions => 'Acciones';

  @override
  String get search_couldNotLoadHistory => 'No se pudo cargar el historial';

  @override
  String get search_couldNotLoadLocalContent =>
      'No se pudo cargar el contenido local';

  @override
  String get search_failedSearchingArticles => 'Error al buscar artículos';

  @override
  String get search_contentMatchTooltip => 'Coincidencia en el contenido';

  @override
  String get search_tabTypeRegular => 'Normal';

  @override
  String get search_tabTypeChild => 'Hija';

  @override
  String get search_tabTypePrivate => 'Privada';

  @override
  String get search_tabTypeIsolated => 'Aislada';

  @override
  String get search_fillLinkFromClipboard =>
      'Rellenar con el enlace del portapapeles';

  @override
  String get search_actionNewTab => 'Nueva pestaña';

  @override
  String get search_actionViewTabs => 'Ver pestañas';

  @override
  String get search_actionResumeLastTab => 'Volver a la última pestaña';

  @override
  String get search_bangTabAllProviders => 'Todos los proveedores';

  @override
  String get search_bangTabSearchOnThisSite => 'Buscar en este sitio';

  @override
  String get search_editShortcutDialogTitle => 'Editar acceso directo';

  @override
  String get search_addShortcut => 'Añadir acceso directo';

  @override
  String get search_titleFieldLabel => 'Título';

  @override
  String get search_urlFieldLabel => 'URL';

  @override
  String get search_titleCannotBeEmpty => 'El título no puede estar vacío';

  @override
  String get search_urlCannotBeEmpty => 'La URL no puede estar vacía';

  @override
  String get search_enterValidUrl => 'Introduce una URL válida';

  @override
  String get search_actionPin => 'Fijar';

  @override
  String get search_actionUnpin => 'Desfijar';

  @override
  String get search_actionResetFrequency => 'Restablecer frecuencia';

  @override
  String get search_actionEditBang => 'Editar bang';

  @override
  String get search_actionCustomizeAsOwnBang => 'Personalizar como bang propio';

  @override
  String search_resetBangDialogTitle(String triggerName) {
    return '¿Restablecer la frecuencia de uso de $triggerName?';
  }

  @override
  String get search_resetBangDialogContent =>
      'El bang se quitará de la lista de selección rápida.';

  @override
  String get search_customizeSectionsButton => 'Personalizar secciones';

  @override
  String get search_customizeSectionsHeading => 'Personalizar secciones';

  @override
  String get search_resetToDefaults => 'Restablecer valores predeterminados';

  @override
  String search_showAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar los $count',
    );
    return '$_temp0';
  }

  @override
  String get search_disableReorderingMode =>
      'Desactivar el modo de reordenación';

  @override
  String get search_enableReorderingMode => 'Activar el modo de reordenación';

  @override
  String get search_dragDropShortcutsHint =>
      'Arrastra y suelta los accesos directos para reordenarlos';

  @override
  String get search_failedReorderShortcut =>
      'No se pudo reordenar el acceso directo';

  @override
  String search_hideAllFromHost(String host) {
    return 'Ocultar todos los de $host';
  }

  @override
  String search_pinnedSite(String title) {
    return 'Se fijó «$title»';
  }

  @override
  String get search_failedPinSite => 'No se pudo fijar el sitio';

  @override
  String get search_shortcutUpdated => 'Acceso directo actualizado';

  @override
  String get search_failedUpdateShortcut =>
      'No se pudo actualizar el acceso directo';

  @override
  String search_addedSite(String title) {
    return 'Se añadió «$title»';
  }

  @override
  String get search_failedAddShortcut => 'No se pudo añadir el acceso directo';

  @override
  String search_hidAllShortcutsFromHost(String host) {
    return 'Se ocultaron todos los accesos directos de $host';
  }

  @override
  String search_removedSite(String title) {
    return 'Se quitó «$title»';
  }

  @override
  String get search_failedRemoveShortcut =>
      'No se pudo quitar el acceso directo';

  @override
  String get search_quoteCardTitle => 'Una idea para el camino';

  @override
  String get search_refreshQuoteTooltip => 'Otra cita';

  @override
  String get search_quotePlaceholder =>
      'Abre una pestaña nueva y haz tuyo este espacio.';

  @override
  String get search_searchFieldLabel => 'Buscar o escribir una URL';

  @override
  String get search_invalidAddress => 'Dirección no válida';

  @override
  String get search_actionSwitchToContainer => 'Cambiar al contenedor';

  @override
  String get search_actionSwitchToProfile =>
      'Cambiar a este perfil (reinicia el navegador)';

  @override
  String get search_actionOpenFeed => 'Abrir fuente';

  @override
  String search_actionSettingLocation(String category, String section) {
    return 'Ajustes › $category › $section';
  }

  @override
  String search_actionSettingCategory(String category) {
    return 'Ajustes › $category';
  }

  @override
  String get search_actionUnnamedContainer => 'Contenedor sin nombre';

  @override
  String get search_actionUntitledFeed => 'Fuente sin título';

  @override
  String get tabs_actionSelect => 'Seleccionar';

  @override
  String get tabs_actionUnselect => 'Deseleccionar';

  @override
  String get tabs_unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get tabs_unsavedChangesConfirm =>
      'Hay cambios sin guardar. ¿Quieres descartarlos o guardarlos?';

  @override
  String get tabs_deleteContainerTitle => 'Eliminar contenedor';

  @override
  String get tabs_deleteContainerConfirm =>
      '¿Seguro que quieres eliminar este contenedor? Se cerrarán sus pestañas.';

  @override
  String get tabs_deleteContainerAlsoDeleteHistory =>
      'Eliminar también el historial de navegación';

  @override
  String get tabs_deleteContainerHistoryKeptNote =>
      'Si no se marca, las visitas permanecen en el historial pero ya no están asignadas a ningún contenedor.';

  @override
  String get tabs_deleteContainerButton => 'Eliminar contenedor';

  @override
  String get tabs_containersTitle => 'Contenedores';

  @override
  String get tabs_noContainersYet => 'Aún no hay contenedores';

  @override
  String get tabs_loadContainersFailedTitle =>
      'No se pudieron cargar los contenedores';

  @override
  String get tabs_containerFabLabel => 'Nuevo contenedor';

  @override
  String get tabs_untitledContainer => 'Sin título';

  @override
  String get tabs_emptyContainerLabel => 'Vacío';

  @override
  String tabs_tabCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pestañas',
      one: '1 pestaña',
    );
    return '$_temp0';
  }

  @override
  String get tabs_chipPinned => 'Fijado';

  @override
  String get tabs_chipIsolated => 'Aislado';

  @override
  String get tabs_chipDirect => 'Directo';

  @override
  String get tabs_chipClearOnExit => 'Se borra al salir';

  @override
  String get tabs_chipActive => 'Activo';

  @override
  String get tabs_selectContainerTitle => 'Seleccionar contenedor';

  @override
  String get tabs_unassignedTitle => 'Sin asignar';

  @override
  String get tabs_unassignedSubtitle =>
      'Pestañas no asignadas a ningún contenedor';

  @override
  String get tabs_draftContainersTitle => 'Contenedores sugeridos';

  @override
  String get tabs_suggestionsFailedTitle =>
      'No se pudieron cargar las sugerencias';

  @override
  String get tabs_siteAssignmentsTitle => 'Sitios asignados';

  @override
  String get tabs_addSiteLabel => 'Añadir sitio';

  @override
  String get tabs_addSiteHint => 'example.com o *.example.com';

  @override
  String get tabs_addSiteHelperText =>
      'Coincide con un solo sitio, o usa *.example.com para incluir todos sus subdominios';

  @override
  String get tabs_urlMustBeProvided => 'Hay que indicar una URL';

  @override
  String get tabs_invalidUrl => 'URL no válida';

  @override
  String get tabs_siteAlreadyAssigned => 'Este sitio ya está asignado';

  @override
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  ) {
    return '$site ya está asignado a «$containerName»';
  }

  @override
  String tabs_siteAlreadyAssignedToAnotherContainer(String site) {
    return '$site ya está asignado a otro contenedor';
  }

  @override
  String get tabs_newContainerTitle => 'Nuevo contenedor';

  @override
  String get tabs_editContainerTitle => 'Editar contenedor';

  @override
  String get tabs_containerNameHint => 'Nombre del contenedor';

  @override
  String get tabs_changeColor => 'Cambiar color';

  @override
  String get tabs_changeIcon => 'Cambiar icono';

  @override
  String get tabs_sectionDisplay => 'Apariencia';

  @override
  String get tabs_pinContainer => 'Fijar contenedor';

  @override
  String get tabs_pinContainerSubtitle =>
      'Mantener este contenedor al principio de la lista';

  @override
  String get tabs_wallpaperLabel => 'Fondo de pantalla';

  @override
  String get tabs_wallpaperSelectedSubtitle =>
      'Se muestra en la página de inicio mientras este contenedor está seleccionado';

  @override
  String get tabs_wallpaperDefaultSubtitle =>
      'Usa el fondo de pantalla de los ajustes';

  @override
  String get tabs_wallpaperEmptyDescription =>
      'Este contenedor usa el fondo de pantalla configurado en los ajustes.';

  @override
  String get tabs_sectionPrivacySecurity => 'Privacidad y seguridad';

  @override
  String get tabs_cookieIsolation => 'Aislamiento de cookies';

  @override
  String get tabs_proxyConnectionLabel => 'Conexión proxy';

  @override
  String get tabs_proxyConnectionNone => 'Ninguna';

  @override
  String get tabs_bypassGlobalProxy => 'Omitir el proxy global';

  @override
  String get tabs_bypassGlobalProxySubtitle =>
      'Usar la conexión normal para este contenedor cuando el enrutamiento global esté activado';

  @override
  String get tabs_clearDataOnExit => 'Borrar datos al salir';

  @override
  String get tabs_clearDataOnExitSubtitle =>
      'Borrar las cookies y los datos de sitios de las pestañas normales de este contenedor al cerrar la aplicación. Las pestañas aisladas conservan datos independientes.';

  @override
  String get tabs_excludeFromSearchIndex => 'Excluir del índice de búsqueda';

  @override
  String get tabs_excludeFromSearchIndexSubtitle =>
      'No incluir las páginas de este contenedor en el índice de búsqueda local';

  @override
  String get tabs_excludeFromHistory => 'Excluir del historial';

  @override
  String get tabs_excludeFromHistorySubtitle =>
      'No registrar nuevas visitas de las pestañas de este contenedor y quitar sus páginas de la búsqueda local. El historial de navegación existente se conserva.';

  @override
  String get tabs_sectionAssignments => 'Asignaciones';

  @override
  String get tabs_assignedSites => 'Sitios asignados';

  @override
  String tabs_assignedSitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reglas configuradas',
      one: '1 regla configurada',
    );
    return '$_temp0';
  }

  @override
  String get tabs_assignedSitesEmptySubtitle =>
      'Abrir los sitios que coincidan en este contenedor';

  @override
  String get tabs_strictMode => 'Modo estricto';

  @override
  String get tabs_strictModeSubtitle =>
      'Permitir cargar solo los sitios asignados y bloquear todo lo demás';

  @override
  String get tabs_requiresCookieIsolation =>
      'Requiere activar el aislamiento de cookies';

  @override
  String get tabs_sectionAppLinks => 'Enlaces de aplicaciones';

  @override
  String get tabs_isolatedAppLinkSettings =>
      'Ajustes propios de enlaces de aplicaciones';

  @override
  String get tabs_isolatedAppLinkSettingsSubtitle =>
      'Usar un modo de apertura en aplicaciones y unas reglas de sitios recordadas propias para este contenedor en lugar de los ajustes globales';

  @override
  String get tabs_appLinkBehavior =>
      'Comportamiento de los enlaces de aplicaciones';

  @override
  String get tabs_appLinkBehaviorSubtitle =>
      'Configurar el modo de apertura en aplicaciones y los sitios recordados de este contenedor';

  @override
  String get tabs_selectColorTitle => 'Seleccionar color';

  @override
  String get tabs_customColorTitle => 'Color personalizado';

  @override
  String get tabs_hexLabel => 'Hex';

  @override
  String get tabs_hueLabel => 'Tono';

  @override
  String get tabs_saturationLabel => 'Saturación';

  @override
  String get tabs_lightnessLabel => 'Luminosidad';

  @override
  String get tabs_chooseIconTitle => 'Elegir icono';

  @override
  String tabs_iconCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count iconos MDI',
      one: '1 icono MDI',
    );
    return '$_temp0';
  }

  @override
  String get tabs_searchIconsHint => 'Buscar iconos MDI';

  @override
  String get tabs_noIconsFound => 'No se encontraron iconos.';

  @override
  String get gestures_screenTitle => 'Gestos';

  @override
  String get gestures_builtInGestureKeywords =>
      'deslizar, deslizamiento, swipe';

  @override
  String get gestures_resetSwipesToDefaultsAction =>
      'Restablecer deslizamientos predeterminados';

  @override
  String get gestures_twoFingerSwipeTitle => 'Deslizar con dos dedos';

  @override
  String get gestures_twoFingerSwipeKeywords => 'contenedor, container';

  @override
  String get gestures_twoFingerSwipeAction => 'Contenedor siguiente o anterior';

  @override
  String get gestures_pinchTitle => 'Pellizcar';

  @override
  String get gestures_pinchKeywords =>
      'cuadrícula, lista, árbol, diseño, pellizco, zoom';

  @override
  String get gestures_pinchAction => 'Diseño en cuadrícula, lista o árbol';

  @override
  String get gestures_webPagesSectionTitle => 'Páginas web';

  @override
  String get gestures_drawnGesturesTitle => 'Gestos dibujados';

  @override
  String get gestures_drawnGesturesKeywords => 'trazo, dibujar, stroke';

  @override
  String get gestures_drawnGesturesSubtitle =>
      'Dibuja trazos en una página para ejecutar acciones';

  @override
  String get gestures_gestureBindingsTitle => 'Asignaciones de gestos';

  @override
  String get gestures_gestureBindingsSubtitle => 'Trazos asignados a acciones';

  @override
  String get gestures_behaviorTimingTitle => 'Comportamiento y tiempos';

  @override
  String get gestures_behaviorTimingSubtitleShort =>
      'Longitud del trazo, tiempo límite, espera';

  @override
  String get gestures_excludedSitesTitle => 'Sitios excluidos';

  @override
  String get gestures_excludedSitesSubtitle =>
      'Desactivar los gestos por sitio';

  @override
  String get gestures_feedbackTitle => 'Indicaciones visuales';

  @override
  String get gestures_feedbackSubtitleShort =>
      'Superposición en directo y sugerencias';

  @override
  String get gestures_pullToRefreshTitle => 'Deslizar para actualizar';

  @override
  String get gestures_pullToRefreshKeywords => 'recargar, actualizar, reload';

  @override
  String get gestures_pullToRefreshSubtitle =>
      'Desliza hacia abajo en la parte superior de una página para recargarla';

  @override
  String get gestures_toolbarSectionTitle => 'Barra de herramientas';

  @override
  String get gestures_longPressButtonsTitle => 'Mantener pulsados los botones';

  @override
  String get gestures_longPressButtonsSubtitle =>
      'Se elige para cada botón al personalizar la barra de herramientas';

  @override
  String get gestures_builtInCannotBeChangedDescription =>
      'Integrado, no se puede cambiar';

  @override
  String get gestures_doNothingTitle => 'No hacer nada';

  @override
  String get gestures_doNothingSubtitle => 'Se ignora el deslizamiento';

  @override
  String get gestures_restoreDefaultGesturesTooltip =>
      'Restaurar gestos predeterminados';

  @override
  String get gestures_addGestureButtonLabel => 'Añadir gesto';

  @override
  String get gestures_restoreDefaultGesturesConfirmTitle =>
      '¿Restaurar los gestos predeterminados?';

  @override
  String get gestures_restoreDefaultGesturesConfirmContent =>
      'Todos los gestos vuelven a su acción predeterminada. Se perderán tus cambios.';

  @override
  String get gestures_noGesturesAssignedMessage =>
      'Aún no hay gestos asignados.';

  @override
  String get gestures_replaceExistingGestureTitle =>
      '¿Reemplazar el gesto existente?';

  @override
  String gestures_replaceExistingGestureContent(String action) {
    return 'Este trazo ya está asignado a «$action». Al guardar se reemplazará esa asignación.';
  }

  @override
  String get gestures_createGestureTitle => 'Crear gesto';

  @override
  String get gestures_editGestureTitle => 'Editar gesto';

  @override
  String get gestures_targetActionLabel => 'Acción';

  @override
  String get gestures_startPositionLabel => 'Posición inicial';

  @override
  String get gestures_fingersLabel => 'Dedos';

  @override
  String get gestures_strokePatternLabel => 'Patrón de trazos';

  @override
  String get gestures_drawStrokePatternPlaceholder =>
      'Dibuja un patrón de trazos abajo';

  @override
  String get gestures_undoLastAction => 'Deshacer último';

  @override
  String get gestures_replaceGestureButtonLabel => 'Reemplazar gesto';

  @override
  String get gestures_saveGestureButtonLabel => 'Guardar gesto';

  @override
  String gestures_collisionWarning(String action) {
    return 'Ya está asignado a «$action». Al guardar se reemplaza.';
  }

  @override
  String get gestures_chooseActionTitle => 'Elegir acción';

  @override
  String get gestures_behaviorTimingScreenSubtitle =>
      'Longitud del trazo, tiempo límite y espera.';

  @override
  String get gestures_resetToDefaultsTooltip =>
      'Restablecer valores predeterminados';

  @override
  String get gestures_resetBehaviorTimingConfirmTitle =>
      '¿Restablecer comportamiento y tiempos?';

  @override
  String get gestures_resetBehaviorTimingConfirmContent =>
      'La longitud del trazo, el tiempo límite, la espera y el intervalo entre trazos volverán a sus valores predeterminados. Se conservan tus asignaciones de gestos y los demás ajustes.';

  @override
  String get gestures_minStrokeLengthTitle => 'Longitud mínima del trazo';

  @override
  String get gestures_minStrokeLengthKeywords =>
      'tamaño, longitud, sensibilidad';

  @override
  String get gestures_timeoutTitle => 'Tiempo límite';

  @override
  String get gestures_timeoutKeywords => 'retraso, espera, timeout';

  @override
  String get gestures_timeoutDescription =>
      'Un trazo se descarta si no se dibuja una nueva dirección en este tiempo.';

  @override
  String get gestures_cooldownTitle => 'Espera';

  @override
  String get gestures_cooldownKeywords => 'intervalo, pausa, cooldown';

  @override
  String get gestures_cooldownDescription =>
      'Tiempo mínimo entre la activación de dos gestos.';

  @override
  String get gestures_strokeIntervalTitle => 'Intervalo entre trazos';

  @override
  String get gestures_strokeIntervalKeywords =>
      'rebote, temblor, accidental, debounce';

  @override
  String get gestures_strokeIntervalDescription =>
      'Tiempo mínimo entre cambios de dirección dentro de un mismo gesto. Los cambios más rápidos cancelan el gesto, lo que evita activaciones accidentales.';

  @override
  String get gestures_offLabel => 'Desactivado';

  @override
  String get gestures_excludedSitesDescription =>
      'Los gestos están desactivados en estos sitios. Se incluyen los subdominios (p. ej., «example.com» también abarca «m.example.com»).';

  @override
  String get gestures_noSitesExcludedMessage => 'No hay sitios excluidos.';

  @override
  String get gestures_feedbackScreenSubtitle =>
      'Superposición en directo y sugerencias de gestos.';

  @override
  String get gestures_liveFeedbackTitle => 'Indicación en directo';

  @override
  String get gestures_liveFeedbackSubtitle =>
      'Mostrar el trazo y su acción mientras dibujas';

  @override
  String get gestures_suggestNextTitle => 'Sugerir siguiente';

  @override
  String get gestures_suggestNextSubtitle =>
      'Mostrar también los demás gestos que puedes completar';

  @override
  String get gestures_suggestAfterTitle => 'Sugerir después de';

  @override
  String gestures_strokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trazos',
      one: '1 trazo',
    );
    return '$_temp0';
  }

  @override
  String get gestures_suggestAfterDescription =>
      'Número de trazos que hay que dibujar antes de que aparezcan sugerencias.';

  @override
  String get gestures_actionRestore => 'Restaurar';

  @override
  String get gestures_actionReplace => 'Reemplazar';

  @override
  String get gestures_tabBarSurfaceTitle =>
      'Deslizamientos en la barra de pestañas';

  @override
  String get gestures_tabBarSurfaceDescription =>
      'Deslizamientos en la barra de pestañas o en la barra lateral';

  @override
  String get gestures_tabViewSurfaceTitle =>
      'Deslizamientos en la vista de pestañas';

  @override
  String get gestures_tabViewSurfaceDescription =>
      'Deslizamientos sobre una pestaña en la lista o la cuadrícula de pestañas';

  @override
  String get gestures_tabBarSwipeBackwardTitle =>
      'Deslizar a la izquierda por la barra';

  @override
  String get gestures_tabBarSwipeBackwardDescription =>
      'Deslizar hacia arriba en la barra lateral hace lo mismo';

  @override
  String get gestures_tabBarSwipeForwardTitle =>
      'Deslizar a la derecha por la barra';

  @override
  String get gestures_tabBarSwipeForwardDescription =>
      'Deslizar hacia abajo en la barra lateral hace lo mismo';

  @override
  String get gestures_tabBarSwipeOutwardTitle =>
      'Deslizar hacia el borde de la pantalla';

  @override
  String get gestures_tabBarSwipeOutwardDescription =>
      'Hacia abajo en una barra inferior, hacia arriba en una barra superior, hacia fuera en una barra lateral';

  @override
  String get gestures_tabBarSwipeInwardTitle =>
      'Deslizar alejándose del borde de la pantalla';

  @override
  String get gestures_tabBarSwipeInwardDescription =>
      'Hacia arriba en una barra inferior, hacia abajo en una barra superior, hacia la página en una barra lateral';

  @override
  String get gestures_tabSwipeLeftTitle =>
      'Deslizar una pestaña a la izquierda';

  @override
  String get gestures_tabSwipeLeftDescription =>
      'Actúa sobre la pestaña deslizada, no sobre la abierta';

  @override
  String get gestures_tabSwipeRightTitle => 'Deslizar una pestaña a la derecha';

  @override
  String get gestures_tabSwipeRightDescription =>
      'Actúa sobre la pestaña deslizada, no sobre la abierta';

  @override
  String get gestures_startPositionAnywhere => 'En cualquier lugar';

  @override
  String get gestures_startPositionLeftEdge => 'Borde izquierdo';

  @override
  String get gestures_startPositionRightEdge => 'Borde derecho';

  @override
  String get gestures_startPositionTopEdge => 'Borde superior';

  @override
  String get gestures_startPositionBottomEdge => 'Borde inferior';

  @override
  String get gestures_startPositionLeftHalf => 'Mitad izquierda';

  @override
  String get gestures_startPositionRightHalf => 'Mitad derecha';

  @override
  String get gestures_strokesSectionTitle => 'Trazos';

  @override
  String get gestures_indexMinStrokeLengthSubtitle =>
      'Longitud mínima de deslizamiento que se reconoce como dirección';

  @override
  String get gestures_timingSectionTitle => 'Tiempos';

  @override
  String get gestures_indexTimeoutSubtitle =>
      'Descartar un trazo si no se dibuja una nueva dirección';

  @override
  String get gestures_indexCooldownSubtitle =>
      'Tiempo mínimo entre la activación de dos gestos';

  @override
  String get gestures_indexStrokeIntervalSubtitle =>
      'Rechazar un gesto cuando los cambios de dirección son demasiado rápidos';

  @override
  String get gestures_overlaySectionTitle => 'Superposición';

  @override
  String get gestures_indexSuggestAfterSubtitle =>
      'Número de trazos que hay que dibujar antes de que aparezcan sugerencias';

  @override
  String get intentGatekeeper_dialogTitle => '¿Abrir el enlace en WebLibre?';

  @override
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  ) {
    return '$appName intenta abrir un enlace en $browserName.';
  }

  @override
  String get intentGatekeeper_alwaysAllow => 'Permitir siempre';

  @override
  String get intentGatekeeper_allowOnce => 'Permitir una vez';

  @override
  String get intentGatekeeper_blockOnce => 'Bloquear una vez';

  @override
  String get intentGatekeeper_alwaysBlock => 'Bloquear siempre';

  @override
  String get keyboardShortcuts_title => 'Atajos de teclado';

  @override
  String get keyboardShortcuts_searchHint => 'Buscar acciones o teclas';

  @override
  String get keyboardShortcuts_noMatchingActions =>
      'No hay acciones que coincidan.';

  @override
  String get keyboardShortcuts_overviewNoneAssigned =>
      'No hay teclas asignadas a acciones del navegador.';

  @override
  String get keyboardShortcuts_overviewDisabled =>
      'Los atajos de teclado están desactivados.';

  @override
  String get keyboardShortcuts_enableTitle => 'Activar atajos de teclado';

  @override
  String get keyboardShortcuts_enableSubtitle =>
      'Acciones del navegador con un teclado físico, incluso cuando la página tiene el foco';

  @override
  String get keyboardShortcuts_noShortcut => 'Sin atajo';

  @override
  String get keyboardShortcuts_tooltipChange => 'Cambiar';

  @override
  String keyboardShortcuts_tooltipRemoveChord(String chord) {
    return 'Quitar $chord';
  }

  @override
  String get keyboardShortcuts_tooltipResetToDefault =>
      'Restablecer valores predeterminados';

  @override
  String get keyboardShortcuts_addShortcut => 'Añadir atajo';

  @override
  String get keyboardShortcuts_changeShortcutTitle => 'Cambiar atajo';

  @override
  String get keyboardShortcuts_restoreDefaultsTooltip =>
      'Restaurar atajos predeterminados';

  @override
  String get keyboardShortcuts_restoreDefaultsTitle =>
      '¿Restaurar los atajos predeterminados?';

  @override
  String get keyboardShortcuts_restoreDefaultsContent =>
      'Todas las acciones vuelven a sus teclas predeterminadas de Firefox. Se perderán tus cambios.';

  @override
  String keyboardShortcuts_recorderInstructions(String actionTitle) {
    return 'Pulsa la combinación de teclas para «$actionTitle».';
  }

  @override
  String get keyboardShortcuts_recorderWaitingForKeys => 'Esperando teclas…';

  @override
  String get keyboardShortcuts_recorderProblemNotAssignable =>
      'Las páginas web necesitan esta tecla. Mantén pulsada Ctrl, Alt o Meta junto con ella, o usa una tecla de función.';

  @override
  String get keyboardShortcuts_recorderProblemAlreadyBound =>
      'Ya es un atajo de esta acción.';

  @override
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle) {
    return 'Actualmente la usa «$ownerTitle». Al guardar, se mueve aquí.';
  }

  @override
  String get keyboardShortcuts_actionCustomize => 'Personalizar';

  @override
  String get keyboardShortcuts_actionReassign => 'Reasignar';

  @override
  String get keyboardShortcuts_actionRestore => 'Restaurar';

  @override
  String get onboarding_actionPrevious => 'Anterior';

  @override
  String get onboarding_actionNext => 'Siguiente';

  @override
  String get onboarding_actionRestore => 'Restaurar';

  @override
  String get onboarding_restoreTargetUnreadable =>
      'No se pudo leer este perfil, así que no se puede restaurar nada en él.';

  @override
  String get onboarding_welcomeBackTitle => '¡Te damos la bienvenida de nuevo!';

  @override
  String get onboarding_welcomeReadyTitle => 'WebLibre está listo';

  @override
  String get onboarding_chooseExperience => 'Elige cómo quieres empezar:';

  @override
  String get onboarding_modeExpressTitle => 'Inicio rápido';

  @override
  String get onboarding_modeExpressSubtitle =>
      'Usa los valores recomendados y empieza a navegar.';

  @override
  String get onboarding_modeDetailedTitle => 'Configuración personalizada';

  @override
  String get onboarding_modeDetailedSubtitle =>
      'Configura DNS, barra de herramientas, extensiones y más.';

  @override
  String get onboarding_modeRestoreTitle =>
      'Restaurar desde una copia de seguridad';

  @override
  String get onboarding_modeRestoreSubtitle =>
      'Importa un perfil desde un archivo de copia de seguridad cifrado.';

  @override
  String get onboarding_updateNoticeTitle => '¡Han cambiado muchas cosas!';

  @override
  String get onboarding_updateNoticeBody =>
      'Esta actualización incluye cambios importantes que requieren que revises tus ajustes. Recorre las páginas siguientes para comprobar tu configuración.';

  @override
  String get onboarding_updateNoticeExtensions =>
      'Vuelve a comprobar tus extensiones después de esta actualización debido a problemas conocidos de migración.';

  @override
  String get onboarding_updateNoticeSettingsPreserved =>
      'Tus ajustes actuales no se sobrescribirán a menos que los cambies expresamente durante esta configuración.';

  @override
  String get onboarding_eulaAcceptance =>
      'He leído y acepto el <eula>CLUF</eula> y la <privacy>Política de privacidad</privacy>.';

  @override
  String get onboarding_privacyPolicy => 'Política de privacidad';

  @override
  String get onboarding_eulaDocumentTitle =>
      'Contrato de licencia de usuario final';

  @override
  String get onboarding_aiFeaturesTitle => 'Funciones de IA';

  @override
  String get onboarding_aiOnDeviceTitle => 'IA en el dispositivo';

  @override
  String get onboarding_aiOnDeviceSubtitle =>
      'Funciones locales en el dispositivo, como sugerencias de temas de contenedores y de pestañas';

  @override
  String get onboarding_aiWarningTitle => 'Ten en cuenta';

  @override
  String get onboarding_aiWarningPoint1 =>
      'WebLibre usa un modelo de IA local para analizar los títulos de tus pestañas abiertas y sugerir en qué contenedores agruparlas y qué nombre darles. Todo el procesamiento se realiza íntegramente en tu dispositivo.';

  @override
  String get onboarding_aiWarningPoint2 =>
      'Las mejoras de IA funcionan íntegramente dentro del navegador y mantienen todos los datos en tu dispositivo. El procesamiento local de IA respeta tu privacidad y ofrece sugerencias más rápidas de grupos y nombres de contenedores. Puedes controlar este comportamiento en cualquier momento en Ajustes.';

  @override
  String get onboarding_aiWarningPoint3 =>
      'La IA puede equivocarse a veces, así que revisa los nombres de grupo y las pestañas sugeridas.';

  @override
  String get onboarding_searchTitle => 'Búsqueda';

  @override
  String get onboarding_searchDefaultProviderLabel =>
      'Proveedor de búsqueda predeterminado';

  @override
  String get onboarding_searchMore => 'Buscar más';

  @override
  String get onboarding_searchDefaultAutocompleteLabel =>
      'Proveedor de autocompletado predeterminado';

  @override
  String get onboarding_searchLoadFailedTitle =>
      'No se pudieron cargar los motores de búsqueda';

  @override
  String get onboarding_dohTitle => 'DNS sobre HTTPS';

  @override
  String get onboarding_permissionsTitle => 'Permisos';

  @override
  String get onboarding_permissionsNotificationsTitle => 'Notificaciones';

  @override
  String get onboarding_permissionsNotificationsSubtitle =>
      'Necesario para avisarte de las descargas';

  @override
  String get onboarding_permissionsDefaultBrowserTitle =>
      'Navegador predeterminado';

  @override
  String get onboarding_permissionsDefaultBrowserSubtitle =>
      'Establecer WebLibre como navegador predeterminado';

  @override
  String get onboarding_privacyTitle => 'Privacidad y refuerzo';

  @override
  String get onboarding_privacyBrowserLanguagesTitle => 'Idiomas del navegador';

  @override
  String get onboarding_privacyBrowserLanguagesSubtitle =>
      'Configurar las preferencias de idioma que se muestran a los sitios web';

  @override
  String get onboarding_multipleLanguagesDetectedTitle =>
      'Se han detectado varios idiomas';

  @override
  String onboarding_multipleLanguagesWarning(int count, String locales) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu navegador tiene $count idiomas configurados ($locales).',
      one: 'Tu navegador tiene 1 idioma configurado ($locales).',
    );
    return '$_temp0 Los sitios web pueden usar tu combinación única de idiomas para identificarte por huella digital y rastrearte por la web.';
  }

  @override
  String get onboarding_multipleLanguagesSuggestion =>
      'Considera usar un solo idioma en el navegador para reducir la información con la que los sitios pueden identificarte por huella digital.';

  @override
  String get onboarding_reviewLanguages => 'Revisar idiomas';

  @override
  String get onboarding_webEngineHardeningTitle =>
      'Refuerzo completo del motor web';

  @override
  String get onboarding_webEngineHardeningSubtitle =>
      'Aplicar al motor web todas las preferencias de refuerzo de seguridad recomendadas';

  @override
  String get onboarding_fingerprintProtectionTitle =>
      'Protección reforzada contra huellas digitales';

  @override
  String get onboarding_fingerprintProtectionSubtitle =>
      'Cargar valores predeterminados completos de protección contra huellas digitales';

  @override
  String get onboarding_compatibilityWarningTitle => 'Aviso de compatibilidad';

  @override
  String get onboarding_fingerprintWarningPoint1 =>
      'La protección reforzada contra huellas digitales activa más de 60 objetivos de protección, como la aleatorización de canvas, la suplantación de navigator, el enmascaramiento de dispositivos multimedia y más.';

  @override
  String get onboarding_fingerprintWarningPoint2 =>
      'Esto puede hacer que los sitios web fallen o se comporten de forma inesperada. Puedes ajustar cada objetivo en los ajustes.';

  @override
  String get onboarding_localNetworkProtectionTitle =>
      'Protección de la red local';

  @override
  String get onboarding_localNetworkProtectionSubtitle =>
      'Los sitios web pueden intentar acceder a tu dispositivo y a otros dispositivos de tu red doméstica, como routers, impresoras o dispositivos domóticos. De forma predeterminada, se impide automáticamente que los rastreadores conocidos lo hagan.';

  @override
  String get onboarding_blockAllLocalNetworkTitle =>
      'Bloquear todas las solicitudes a la red local';

  @override
  String get onboarding_blockAllLocalNetworkSubtitle =>
      'Pedir permiso antes de que cualquier sitio web acceda a dispositivos de tu red doméstica, no solo los rastreadores conocidos';

  @override
  String get onboarding_toolbarLayoutTitle => 'Barra de herramientas y diseño';

  @override
  String get onboarding_ublockTitle => 'uBlock Origin';

  @override
  String get onboarding_ublockDescription =>
      'uBlock Origin (uBO) es un **bloqueador de contenido de amplio espectro** eficiente en CPU y memoria creado por **Raymond Hill**, disponible como extensión del navegador para WebLibre.\n\nDe forma predeterminada, bloquea anuncios, rastreadores, criptomineros, ventanas emergentes, molestos anti-bloqueadores, sitios de malware y más mediante las **listas de filtros EasyList, EasyPrivacy, Peter Lowe\'s Blocklist, Online Malicious URL Blocklist y uBO**.\n\nHay muchas otras listas disponibles para bloquear contenido adicional.';

  @override
  String get onboarding_ublockInstallTitle =>
      'Instalar la extensión uBlock Origin';

  @override
  String get onboarding_ublockApplyDefaultsTitle =>
      'Aplicar valores optimizados';

  @override
  String get onboarding_ublockApplyDefaultsSubtitle =>
      'Activar las listas de filtros de refuerzo de WebLibre.';

  @override
  String get proxy_actionChange => 'Cambiar';

  @override
  String get proxy_actionFetch => 'Obtener';

  @override
  String get proxy_actionSelectAll => 'Seleccionar todo';

  @override
  String get proxy_actionShare => 'Compartir';

  @override
  String get proxy_actionStart => 'Iniciar';

  @override
  String get proxy_actionStop => 'Detener';

  @override
  String get proxy_actionStopAndDelete => 'Detener y eliminar';

  @override
  String get proxy_actionTestConnection => 'Probar conexión';

  @override
  String get proxy_connectionsTitle => 'Conexiones proxy';

  @override
  String get proxy_addProfile => 'Añadir perfil';

  @override
  String get proxy_viewLogsTooltip => 'Ver registros';

  @override
  String get proxy_profilesSectionTitle => 'Perfiles';

  @override
  String proxy_loadProfilesFailed(String error) {
    return 'No se pudieron cargar los perfiles de proxy:\n$error';
  }

  @override
  String get proxy_statusActive => 'Activo';

  @override
  String get proxy_statusDisconnected => 'Desconectado';

  @override
  String proxy_statusRoutingTraffic(int running, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'En ejecución: $running de $total proxies',
      one: 'En ejecución: $running de 1 proxy',
    );
    return '$_temp0';
  }

  @override
  String get proxy_statusTapToConnect => 'Pulsa un perfil para conectarte';

  @override
  String get proxy_stopAllTooltip => 'Detener todos';

  @override
  String get proxy_onionRoutingLabel => 'Enrutamiento cebolla';

  @override
  String get proxy_autostartLabel => 'Inicio automático';

  @override
  String get proxy_autostartTooltip => 'Se inicia con WebLibre';

  @override
  String proxy_egressIpTooltip(String ip) {
    return 'IP de salida $ip';
  }

  @override
  String get proxy_latencyTesting => 'Probando...';

  @override
  String get proxy_latencyTestRunningTooltip => 'Prueba de latencia en curso';

  @override
  String get proxy_latencyNotRunningTooltip =>
      'El perfil no se está ejecutando';

  @override
  String get proxy_latencyFailed => 'Error';

  @override
  String proxy_latencyMilliseconds(int ms) {
    return '$ms ms';
  }

  @override
  String proxy_latencyHttpStatusTooltip(int statusCode, int ms) {
    return 'HTTP $statusCode en $ms ms';
  }

  @override
  String proxy_startProxyFailed(String error) {
    return 'No se pudo iniciar el proxy: $error';
  }

  @override
  String proxy_stopProxyFailed(String error) {
    return 'No se pudo detener el proxy: $error';
  }

  @override
  String proxy_startBrandFailed(String brand, String error) {
    return 'No se pudo iniciar $brand: $error';
  }

  @override
  String proxy_stopBrandFailed(String brand, String error) {
    return 'No se pudo detener $brand: $error';
  }

  @override
  String get proxy_startConnectionDialogTitle => '¿Iniciar la conexión proxy?';

  @override
  String proxy_startConnectionDialogContent(String proxyTitle) {
    return 'Esta pestaña necesita $proxyTitle, pero esa conexión no se está ejecutando. ¿Iniciarla ahora?';
  }

  @override
  String get proxy_deleteProfileTitle => '¿Eliminar el perfil?';

  @override
  String proxy_deleteProfileConfirm(String name) {
    return '¿Eliminar $name y sus secretos guardados? Las pestañas y los contenedores asignados a este perfil se bloquearán hasta que elijas otro proxy o quites la asignación.';
  }

  @override
  String proxy_deleteProfileConfirmRunning(String name) {
    return '¿Detener $name y después eliminarlo junto con sus secretos guardados? Las pestañas y los contenedores asignados a este perfil se bloquearán hasta que elijas otro proxy o quites la asignación.';
  }

  @override
  String proxy_deleteProfileFailed(String error) {
    return 'No se pudo eliminar el perfil: $error';
  }

  @override
  String proxy_shareDialogTitle(String name) {
    return 'Compartir «$name»';
  }

  @override
  String get proxy_shareDialogWarning =>
      'Este enlace contiene el perfil completo, incluidas las credenciales guardadas. Compártelo con cuidado.';

  @override
  String get proxy_copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get proxy_editProfileTitle => 'Editar perfil';

  @override
  String get proxy_newProfileTitle => 'Nuevo perfil';

  @override
  String get proxy_saveChanges => 'Guardar cambios';

  @override
  String get proxy_createProfile => 'Crear perfil';

  @override
  String get proxy_sectionGeneral => 'General';

  @override
  String get proxy_sectionDnsOverride => 'DNS personalizado';

  @override
  String get proxy_addMenuTip =>
      'Consejo: usa el menú de añadir de la pantalla anterior para importar desde un archivo, pegar un enlace compartido o escanear un código QR.';

  @override
  String proxy_wireGuardTrademarkDisclaimer(String brand) {
    return '$brand es una marca registrada de Jason A. Donenfeld; todos los derechos reservados. WebLibre no está respaldado ni patrocinado por Jason A. Donenfeld, ni afiliado a él.';
  }

  @override
  String proxy_wireGuardConfigLabel(String brand) {
    return 'Configuración de $brand';
  }

  @override
  String get proxy_fieldProfileName => 'Nombre del perfil';

  @override
  String get proxy_fieldProtocol => 'Protocolo';

  @override
  String get proxy_protocolFixedHelper =>
      'El protocolo no se puede cambiar una vez creado el perfil.';

  @override
  String get proxy_customOutboundLabel => 'Outbound personalizado';

  @override
  String get proxy_startAutomaticallyTitle => 'Iniciar automáticamente';

  @override
  String get proxy_startAutomaticallySubtitle =>
      'Conectar este perfil al iniciar WebLibre, para que las pestañas que lo usan estén listas sin preguntar';

  @override
  String proxy_dnsOverrideExplanation(String brand) {
    return 'Resolver nombres mediante un servidor DNS accesible a través de esta conexión (p. ej., un servidor DoH interno detrás de un túnel $brand corporativo). Déjalo desactivado para usar la gestión automática de DNS.';
  }

  @override
  String get proxy_dnsOverrideSwitchTitle =>
      'Usar un resolvedor propio del perfil';

  @override
  String get proxy_fieldDnsServerAddress => 'Dirección del servidor DNS';

  @override
  String get proxy_sectionOutbound => 'Outbound';

  @override
  String get proxy_sectionSecrets => 'Secretos';

  @override
  String get proxy_fieldOutboundJson => 'JSON del outbound';

  @override
  String get proxy_outboundJsonHelper => 'Objeto outbound público de sing-box.';

  @override
  String get proxy_fieldSecretJson => 'JSON de secretos';

  @override
  String get proxy_secretJsonHelper =>
      'Valores opcionales que se combinan con el outbound en tiempo de ejecución.';

  @override
  String get proxy_sectionConnection => 'Conexión';

  @override
  String get proxy_sectionCredentials => 'Credenciales';

  @override
  String get proxy_sectionProtocolOptions => 'Opciones del protocolo';

  @override
  String get proxy_sectionTls => 'TLS';

  @override
  String get proxy_sectionTransport => 'Transporte';

  @override
  String get proxy_sectionMultiplex => 'Multiplexación';

  @override
  String get proxy_sectionDial => 'Dial';

  @override
  String get proxy_advancedOptionsHint =>
      'Las opciones avanzadas del protocolo se pueden introducir igualmente con el JSON de outbound personalizado.';

  @override
  String get proxy_storedInSecureStorage =>
      'Guardado en el almacenamiento seguro.';

  @override
  String get proxy_booleanFieldUnset => 'Sin definir (valor predeterminado)';

  @override
  String get proxy_booleanFieldEnabled => 'Activado';

  @override
  String get proxy_booleanFieldDisabled => 'Desactivado';

  @override
  String get proxy_addConnectionTitle => 'Añadir conexión';

  @override
  String get proxy_addConnectionSubtitle =>
      'Elige cómo quieres añadir un perfil de proxy.';

  @override
  String get proxy_methodClipboardTitle => 'Portapapeles';

  @override
  String get proxy_methodClipboardSubtitle =>
      'Pegar un enlace compartido o una URI';

  @override
  String get proxy_methodScanQrTitle => 'Escanear QR';

  @override
  String get proxy_methodScanQrSubtitle => 'Desde otro dispositivo';

  @override
  String get proxy_methodSubscriptionTitle => 'Suscripción';

  @override
  String get proxy_methodSubscriptionSubtitle => 'Obtener desde una URL';

  @override
  String get proxy_methodImportFileTitle => 'Importar archivo';

  @override
  String get proxy_methodImportFileSubtitle => '.conf o JSON de sing-box';

  @override
  String get proxy_enterManually => 'Introducir manualmente';

  @override
  String get proxy_clipboardEmpty => 'El portapapeles está vacío.';

  @override
  String get proxy_importFromFileTitle => 'Importar desde archivo';

  @override
  String get proxy_importFileWireGuardSubtitle =>
      'Archivo .conf con [Interface]/[Peer]';

  @override
  String get proxy_importFileSingboxJsonTitle => 'JSON de outbound de sing-box';

  @override
  String get proxy_importFileSingboxJsonSubtitle =>
      'Shadowsocks, Trojan, VMess, VLESS, Hysteria, …';

  @override
  String proxy_importedProfileNamed(String name) {
    return 'Perfil «$name» importado';
  }

  @override
  String get proxy_importSubscriptionTitle => 'Importar suscripción';

  @override
  String get proxy_fieldSubscriptionUrl => 'URL de la suscripción';

  @override
  String get proxy_subscriptionUrlRequired =>
      'Introduce una URL de suscripción https:// completa.';

  @override
  String proxy_subscriptionHttpError(int statusCode) {
    return 'El servidor de la suscripción respondió con HTTP $statusCode.';
  }

  @override
  String get proxy_subscriptionTimedOut =>
      'El servidor de la suscripción no respondió a tiempo.';

  @override
  String proxy_subscriptionFetchFailed(String error) {
    return 'No se pudo obtener la suscripción: $error';
  }

  @override
  String get proxy_subscriptionFormatHint =>
      'Admite el formato de estilo v2rayN: una lista codificada en base64 de URI ss://, vless://, vmess://, trojan://, hysteria2://, tuic:// y similares. Las reglas de enrutamiento de la suscripción se ignoran: solo se importan los nodos proxy.';

  @override
  String proxy_importedProfileDefaultName(int n) {
    return 'Importado $n';
  }

  @override
  String proxy_importedProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se importaron $count perfiles',
      one: 'Se importó 1 perfil',
    );
    return '$_temp0';
  }

  @override
  String proxy_importProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count perfiles',
      one: 'Importar 1 perfil',
    );
    return '$_temp0';
  }

  @override
  String proxy_subscriptionNodeSummary(int usable, int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable nodos utilizables, $failed con errores',
      one: '1 nodo utilizable, $failed con errores',
    );
    String _temp1 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable nodos utilizables, 1 con errores',
      one: '1 nodo utilizable, 1 con errores',
    );
    String _temp2 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable nodos utilizables',
      one: '1 nodo utilizable',
    );
    String _temp3 = intl.Intl.pluralLogic(
      failed,
      locale: localeName,
      other: '$_temp0',
      one: '$_temp1',
      zero: '$_temp2',
    );
    return '$_temp3';
  }

  @override
  String get proxy_logsTitle => 'Registros del proxy';

  @override
  String get proxy_logsCopyAllTooltip => 'Copiar todo';

  @override
  String get proxy_logsClearTooltip => 'Borrar registro';

  @override
  String get proxy_logsShareSubject => 'registros del proxy';

  @override
  String get proxy_logsNoLinesMatchFilter =>
      'Ninguna línea del registro coincide con el filtro actual';

  @override
  String proxy_logsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se copiaron $count líneas al portapapeles',
      one: 'Se copió 1 línea al portapapeles',
    );
    return '$_temp0';
  }

  @override
  String get proxy_logsShowAllLevels => 'Mostrar todos los niveles';

  @override
  String get proxy_logsShowErrorsOnly => 'Mostrar solo errores';

  @override
  String get proxy_logsShowWarningsAndAbove => 'Mostrar avisos y superiores';

  @override
  String get proxy_logsShowInfoAndAbove => 'Mostrar información y superiores';

  @override
  String get proxy_logsShowDebugAndAbove => 'Mostrar depuración y superiores';

  @override
  String get proxy_logsShowTraceAndAbove => 'Mostrar traza y superiores';

  @override
  String get proxy_logsLatest => 'Más recientes';

  @override
  String get proxy_logsEmptyFiltered =>
      'No hay líneas de registro en este nivel. Baja el filtro de visualización o aumenta el nivel de registro del proxy.';

  @override
  String proxy_logsEmpty(String brand) {
    return 'Aún no hay líneas de registro. Inicia un proxy o $brand para ver aquí la salida.';
  }

  @override
  String get proxy_recordingLevelWarn => 'Registrando avisos y errores';

  @override
  String get proxy_recordingLevelInfo =>
      'Registrando información: esto ralentiza la navegación';

  @override
  String get proxy_recordingLevelDebug =>
      'Registrando depuración: esto ralentiza la navegación';

  @override
  String get proxy_recordingLevelTrace =>
      'Registrando traza: esto ralentiza la navegación';

  @override
  String get proxy_logLevelAll => 'Todo';

  @override
  String get proxy_logLevelTrace => 'Traza';

  @override
  String get proxy_logLevelDebug => 'Depuración';

  @override
  String get proxy_logLevelInfo => 'Información';

  @override
  String get proxy_logLevelWarnings => 'Avisos';

  @override
  String get proxy_logLevelErrors => 'Errores';

  @override
  String get proxy_logLevelSheetTitle => 'Nivel de registro del proxy';

  @override
  String get proxy_logLevelSheetExplanation =>
      'Súbelo solo mientras diagnosticas un problema y después vuelve a dejarlo como estaba. Al cambiarlo se reinicia cualquier proxy en ejecución.';

  @override
  String get proxy_verboseLoggingWarning =>
      'El registro detallado escribe una línea por cada conexión y consulta DNS, lo que ralentiza notablemente la navegación.';

  @override
  String get proxy_logVerbosityWarnLabel => 'Avisos y errores';

  @override
  String get proxy_logVerbosityInfoLabel => 'Información';

  @override
  String get proxy_logVerbosityDebugLabel => 'Depuración';

  @override
  String get proxy_logVerbosityTraceLabel => 'Traza';

  @override
  String get proxy_logVerbosityWarnDescription =>
      'Funcionamiento normal. Los problemas se siguen registrando.';

  @override
  String get proxy_logVerbosityInfoDescription =>
      'Cada conexión y consulta DNS. Ralentiza la navegación.';

  @override
  String get proxy_logVerbosityDebugDescription =>
      'Información y detalles del protocolo. Ralentiza la navegación.';

  @override
  String get proxy_logVerbosityTraceDescription =>
      'Todo lo que sing-box puede registrar. Ralentiza mucho la navegación.';

  @override
  String get proxy_loadingProxyTitle => 'Cargando proxy...';

  @override
  String proxy_torConnectionSubtitle(String torBrand) {
    return 'Enrutar a través de la red $torBrand';
  }

  @override
  String get proxy_routingTitle => 'Enrutamiento del proxy';

  @override
  String get proxy_routingSubtitle =>
      'Elige qué proxy transporta el tráfico de las pestañas normales y privadas.';

  @override
  String get proxy_routingSectionRegularTabs => 'Pestañas normales';

  @override
  String get proxy_routingSectionRegularTabsKeywords => 'enrutamiento, routing';

  @override
  String get proxy_routingSectionPrivateTabs => 'Pestañas privadas';

  @override
  String get proxy_routingSectionPrivateTabsKeywords =>
      'privada, incógnito, private';

  @override
  String get proxy_routingRegularTabsModeTitle =>
      'Modo de enrutamiento de las pestañas normales';

  @override
  String get proxy_routingRegularTabsModeKeywords => 'contenedor, global';

  @override
  String get proxy_routingRegularTabsModeSubtitle =>
      'Elige cómo se enrutan las pestañas normales a través de proxies';

  @override
  String get proxy_routingGlobalProxyTitle =>
      'Proxy para el enrutamiento global';

  @override
  String get proxy_routingGlobalProxyKeywords => 'proxy';

  @override
  String get proxy_routingGlobalProxySubtitle =>
      'Proxy seleccionado cuando el enrutamiento global está activado';

  @override
  String get proxy_routingPrivateTabsProxyTitle =>
      'Proxy para pestañas privadas';

  @override
  String get proxy_routingPrivateTabsProxyKeywords => 'proxy';

  @override
  String get proxy_routingPrivateTabsProxySubtitle =>
      'Proxy seleccionado que transporta el tráfico de las pestañas privadas';

  @override
  String get proxy_routingContainerBasedTitle => 'Enrutamiento por contenedor';

  @override
  String get proxy_routingContainerBasedSubtitle =>
      'Solo se enrutan las pestañas de contenedores con un proxy asignado.';

  @override
  String get proxy_routingGlobalRoutingTitle => 'Enrutamiento global';

  @override
  String get proxy_routingGlobalRoutingSubtitle =>
      'Enrutar las pestañas normales a través del proxy seleccionado, salvo que un contenedor lo omita.';

  @override
  String get proxy_routingNotUsedTitle =>
      'No se usa en el enrutamiento por contenedor';

  @override
  String get proxy_routingNotUsedSubtitle =>
      'Cambia arriba al enrutamiento global para elegir el proxy que transporta todas las pestañas normales.';

  @override
  String get proxy_routingNoneTitle => 'Ninguno';

  @override
  String get proxy_routingNoneSubtitle =>
      'Usar la conexión normal del navegador';

  @override
  String get proxy_routingUnknownProxySubtitle =>
      'El proxy seleccionado ya no existe.';

  @override
  String get proxy_unknownProxyTitle => 'Proxy desconocido';

  @override
  String get proxy_connectionPickerTitle => 'Conexión proxy';

  @override
  String get proxy_pickerUnknownProxySubtitle =>
      'Este perfil de proxy ya no existe';

  @override
  String get proxy_fieldServerAddress => 'Dirección del servidor';

  @override
  String get proxy_fieldServerPort => 'Puerto del servidor';

  @override
  String get proxy_fieldUsername => 'Nombre de usuario';

  @override
  String get proxy_fieldPassword => 'Contraseña';

  @override
  String get proxy_fieldUuid => 'UUID';

  @override
  String get proxy_fieldTlsEnabled => 'TLS activado';

  @override
  String get proxy_fieldTlsEnabledHelper => 'true o false.';

  @override
  String get proxy_fieldTlsServerName => 'Nombre del servidor TLS';

  @override
  String get proxy_fieldTlsInsecure => 'Permitir certificados TLS no válidos';

  @override
  String get proxy_fieldTlsInsecureHelper => 'true o false.';

  @override
  String get proxy_fieldTlsAlpn => 'TLS ALPN';

  @override
  String get proxy_fieldTlsAlpnHelper =>
      'Separados por comas o un valor por línea.';

  @override
  String get proxy_fieldTransportType => 'Tipo de transporte';

  @override
  String get proxy_fieldTransportTypeHelper =>
      'Por ejemplo ws, http, grpc o quic.';

  @override
  String get proxy_fieldTransportPath => 'Ruta del transporte';

  @override
  String get proxy_fieldGrpcServiceName => 'Nombre del servicio gRPC';

  @override
  String get proxy_fieldMultiplexEnabled => 'Multiplexación activada';

  @override
  String get proxy_fieldMultiplexEnabledHelper => 'true o false.';

  @override
  String get proxy_fieldMultiplexProtocol => 'Protocolo de multiplexación';

  @override
  String get proxy_fieldMultiplexMaxConnections =>
      'Conexiones máximas de multiplexación';

  @override
  String get proxy_fieldDialDetour => 'Dial detour';

  @override
  String get proxy_fieldBindInterface => 'Interfaz de enlace';

  @override
  String get proxy_fieldRoutingMark => 'Marca de enrutamiento';

  @override
  String get proxy_fieldDomainStrategy => 'Estrategia de dominio';

  @override
  String get proxy_fieldDomainStrategyHelper =>
      'Por ejemplo prefer_ipv4 o prefer_ipv6.';

  @override
  String get proxy_fieldConnectTimeout => 'Tiempo de espera de conexión';

  @override
  String get proxy_fieldConnectTimeoutHelper => 'Por ejemplo 5s.';

  @override
  String get proxy_fieldSocksVersion => 'Versión de SOCKS';

  @override
  String get proxy_fieldMethod => 'Método';

  @override
  String get proxy_fieldSecurity => 'Seguridad';

  @override
  String get proxy_fieldAlterId => 'Alter ID';

  @override
  String get proxy_fieldFlow => 'Flow';

  @override
  String get proxy_fieldAuthString => 'Cadena de autenticación';

  @override
  String get proxy_fieldUploadBandwidth => 'Ancho de banda de subida';

  @override
  String get proxy_fieldDownloadBandwidth => 'Ancho de banda de bajada';

  @override
  String get proxy_fieldObfuscation => 'Ofuscación';

  @override
  String get proxy_fieldReceiveWindowConn =>
      'Ventana de recepción por conexión';

  @override
  String get proxy_fieldReceiveWindow => 'Ventana de recepción';

  @override
  String get proxy_fieldDisableMtuDiscovery =>
      'Desactivar descubrimiento de MTU';

  @override
  String get proxy_fieldDisableMtuDiscoveryHelper => 'true o false.';

  @override
  String get proxy_fieldUploadMbps => 'Mbps de subida';

  @override
  String get proxy_fieldDownloadMbps => 'Mbps de bajada';

  @override
  String get proxy_fieldObfuscationType => 'Tipo de ofuscación';

  @override
  String get proxy_fieldObfuscationPassword => 'Contraseña de ofuscación';

  @override
  String get proxy_fieldCongestionControl => 'Control de congestión';

  @override
  String get proxy_fieldUdpRelayMode => 'Modo de retransmisión UDP';

  @override
  String get proxy_fieldZeroRttHandshake => 'Handshake 0-RTT';

  @override
  String get proxy_fieldZeroRttHandshakeHelper => 'true o false.';

  @override
  String get proxy_fieldUser => 'Usuario';

  @override
  String get proxy_fieldPrivateKey => 'Clave privada';

  @override
  String get proxy_fieldPrivateKeyPassphrase =>
      'Frase de contraseña de la clave privada';

  @override
  String get proxy_fieldLocalAddress => 'Dirección local';

  @override
  String get proxy_fieldLocalAddressHelper =>
      'La dirección de este dispositivo dentro del túnel, una por línea; por ejemplo, 10.0.0.2/32. Una dirección sin prefijo se trata como dirección única (/32, o /128 para IPv6).';

  @override
  String get proxy_fieldPeerPublicKey => 'Clave pública del par';

  @override
  String get proxy_fieldWireguardPrivateKey => 'Clave privada';

  @override
  String get proxy_fieldWireguardPrivateKeyHelper =>
      'Guardada en el almacenamiento seguro, no en el JSON del perfil.';

  @override
  String get proxy_fieldPreSharedKey => 'Clave precompartida';

  @override
  String get proxy_fieldPreSharedKeyHelper =>
      'Opcional. Guardada en el almacenamiento seguro.';

  @override
  String get proxy_fieldMtu => 'MTU';

  @override
  String get proxy_fieldMtuHelper =>
      'Redúcelo si el túnel se conecta pero las páginas nunca cargan: los paquetes más grandes de lo que permite la ruta se descartan directamente. Un valor de 1280 es seguro casi en cualquier sitio; usa alrededor de 1200 si ya estás conectado a otra VPN.';

  @override
  String get proxy_fieldPersistentKeepalive => 'Keepalive persistente';

  @override
  String get proxy_fieldPersistentKeepaliveHelper =>
      'Segundos entre paquetes keepalive. Los teléfonos suelen estar detrás de NAT; sin keepalives, la asignación puede caducar mientras están inactivos. Entonces el par ya no puede llegar al teléfono y las conexiones se bloquean hasta el siguiente handshake. Pon 0 para desactivarlo.';

  @override
  String get proxy_fieldReservedBytes => 'Bytes reservados';

  @override
  String get proxy_fieldReservedBytesHelper =>
      'Opcional. Tres números separados por comas, p. ej. 0,0,0.';

  @override
  String get proxy_fieldShadowTlsVersion => 'Versión';

  @override
  String proxy_fieldErrorRequired(String field) {
    return 'El campo «$field» es obligatorio.';
  }

  @override
  String proxy_fieldErrorNotPositiveNumber(String field) {
    return 'El campo «$field» debe ser un número positivo.';
  }

  @override
  String proxy_fieldErrorPortRange(String field) {
    return 'El campo «$field» debe estar entre 1 y 65535.';
  }

  @override
  String proxy_fieldErrorListLength(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'El campo «$field» debe contener $count números.',
      one: 'El campo «$field» debe contener 1 número.',
    );
    return '$_temp0';
  }

  @override
  String proxy_fieldErrorNotAllNumbers(String field) {
    return 'El campo «$field» solo debe contener números.';
  }

  @override
  String proxy_fieldErrorBelowMin(String field, int min) {
    return 'El campo «$field» debe contener números mayores o iguales que $min.';
  }

  @override
  String proxy_fieldErrorAboveMax(String field, int max) {
    return 'El campo «$field» debe contener números menores o iguales que $max.';
  }

  @override
  String proxy_fieldErrorInvalidCidr(String field, String value) {
    return 'El campo «$field» debe contener direcciones IP, opcionalmente con un prefijo tras «/»; «$value» no es una dirección válida.';
  }

  @override
  String proxy_fieldErrorNotBoolean(String field) {
    return 'El campo «$field» debe ser true o false.';
  }

  @override
  String proxy_fieldErrorNotAllowedValue(String field, String values) {
    return 'El campo «$field» debe ser uno de estos valores: $values.';
  }

  @override
  String get proxy_saveErrorAlreadySaving => 'El perfil ya se está guardando.';

  @override
  String get proxy_saveErrorNameRequired =>
      'El nombre del perfil es obligatorio.';

  @override
  String get proxy_saveErrorStillLoading =>
      'El perfil todavía se está cargando. Espera un momento.';

  @override
  String get proxy_saveErrorConfigNotJson =>
      'La configuración debe ser un objeto JSON.';

  @override
  String get proxy_saveErrorSecretsNotJson =>
      'Los secretos deben ser un objeto JSON.';

  @override
  String proxy_saveErrorUnexpected(String error) {
    return 'No se pudo guardar el perfil de proxy: $error';
  }

  @override
  String get proxy_loadErrorNotFound => 'No se encontró el perfil de proxy.';

  @override
  String proxy_loadErrorFailed(String error) {
    return 'No se pudo cargar el perfil de proxy: $error';
  }

  @override
  String get qrScanner_noCameraPermission =>
      'No se ha concedido el permiso de la cámara.';

  @override
  String get qrScanner_scanCodeTitle => 'Escanear código';

  @override
  String get searchCredits_couldNotLoadTitle =>
      'No se pudieron cargar los créditos';

  @override
  String get searchCredits_title => 'Créditos de búsqueda';

  @override
  String get searchCredits_errorSubtitle =>
      'Comprueba tu conexión y pulsa actualizar para reintentarlo.';

  @override
  String get searchCredits_emptySubtitle =>
      'Compra un paquete de búsquedas para empezar';

  @override
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  ) {
    return 'Créditos: $credits / $allowance  ·  Tokens guardados: $stash';
  }

  @override
  String searchCredits_creditsNoAllowance(int credits, int stash) {
    return 'Créditos: $credits  ·  Tokens guardados: $stash';
  }

  @override
  String get searchCredits_tooltipRefresh => 'Actualizar';

  @override
  String searchCredits_resetsOn(String date) {
    return 'Se renueva el $date';
  }

  @override
  String searchCredits_lastIssuance(String relative, String absolute) {
    return 'Última emisión: $relative  ($absolute)';
  }

  @override
  String get searchCredits_requestingTokens => 'Solicitando tokens...';

  @override
  String searchCredits_issuanceFailed(String error) {
    return 'Error al emitir tokens: $error';
  }

  @override
  String get searchCredits_needsReauth =>
      'Vuelve a iniciar sesión para solicitar tokens.';

  @override
  String get searchCredits_buySearchPackTitle =>
      'Comprar un paquete de búsquedas';

  @override
  String get searchCredits_getTokensTitle => 'Obtener tokens';

  @override
  String searchCredits_requestTokensCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solicitar $count tokens',
      one: 'Solicitar 1 token',
    );
    return '$_temp0';
  }

  @override
  String get searchCredits_noCreditsRemaining => 'No quedan créditos';

  @override
  String get searchCredits_buyMoreTitle => 'Comprar más';

  @override
  String get settings_advancedTitle => 'Avanzado';

  @override
  String get settings_advancedSubtitle =>
      'Comportamiento del motor, anulaciones en tiempo de ejecución y herramientas para desarrolladores.';

  @override
  String get settings_javascriptTitle => 'Activar JavaScript';

  @override
  String get settings_javascriptKeywords => 'javascript, js';

  @override
  String get settings_javascriptSubtitle =>
      'Desactivar JavaScript puede mejorar la seguridad, la privacidad y la velocidad, pero puede hacer que algunos sitios no funcionen como deberían.';

  @override
  String get settings_userAgentLabel => 'User agent personalizado';

  @override
  String get settings_userAgentLabelKeywords =>
      'ua, agente de usuario, user agent';

  @override
  String get settings_enterpriseRootsTitle =>
      'Usar certificados de CA de terceros';

  @override
  String get settings_enterpriseRootsKeywords =>
      'certificados, raíces empresariales, ca, enterprise roots';

  @override
  String get settings_enterpriseRootsSubtitle =>
      'Permite usar certificados de terceros del almacén de CA de Android';

  @override
  String get settings_experimentalFeaturesTitle => 'Funciones experimentales';

  @override
  String get settings_experimentalFeaturesKeywords =>
      'tiempo de ejecución, inicio, runtime, startup';

  @override
  String get settings_experimentalFeaturesSubtitle =>
      'Funciones de bajo nivel del tiempo de ejecución y comportamiento al iniciar';

  @override
  String get settings_unmountGeckoViewTitle =>
      'Desmontar el motor fuera de pantalla';

  @override
  String get settings_unmountGeckoViewKeywords =>
      'geckoview, memoria, rendimiento, suspender';

  @override
  String get settings_unmountGeckoViewSubtitle =>
      'Quita el motor web de la memoria mientras hay abierta una vista a pantalla completa (como los ajustes, las pestañas o la búsqueda) y lo reconstruye al volver. Así se liberan recursos mientras tanto. Volver a la página requiere reconectar el motor y puede provocar un parpadeo o una recarga, así que se sacrifica rendimiento para ahorrar memoria en lugar de solucionar un problema. En Android 12 y anteriores, el motor siempre se desmonta.';

  @override
  String get settings_iconCacheTitle => 'Caché de iconos';

  @override
  String get settings_iconCacheKeywords => 'favicons, iconos, caché';

  @override
  String get settings_iconCacheSubtitle => 'Favicons guardados';

  @override
  String get settings_iconCacheSizeLabel => 'Tamaño';

  @override
  String get settings_clearingAction => 'Borrando';

  @override
  String get settings_mlDownloadsTitle => 'Descargas de ML';

  @override
  String get settings_mlDownloadsKeywords => 'ia, ml, modelos, onnx, caché, ai';

  @override
  String get settings_mlDownloadsSubtitle =>
      'Modelos de IA descargados y archivos del tiempo de ejecución';

  @override
  String get settings_mlDownloadsClearDialogTitle =>
      '¿Borrar las descargas de ML?';

  @override
  String get settings_mlDownloadsClearDialogContent =>
      'Se borrarán los modelos de IA descargados y los archivos del tiempo de ejecución ONNX de este perfil. Se volverán a descargar cuando hagan falta. Reinicia WebLibre antes de volver a probar las funciones de ML.';

  @override
  String get settings_mlDownloadsClearedMessage =>
      'Descargas de ML borradas. Reinicia WebLibre antes de volver a intentarlo.';

  @override
  String settings_mlDownloadsClearFailedMessage(String error) {
    return 'No se pudieron borrar las descargas de ML: $error';
  }

  @override
  String get settings_errorLogsTitle => 'Registros de errores';

  @override
  String get settings_errorLogsKeywords => 'registros, logs';

  @override
  String get settings_errorLogsSubtitle =>
      'Ver y copiar registros para informar de problemas';

  @override
  String get settings_dartVmTitle => 'Dart VM';

  @override
  String get settings_dartVmKeywords => 'service url';

  @override
  String get settings_dartVmSubtitle => 'Copiar la URL del servicio de Dart VM';

  @override
  String get settings_dartVmCopyErrorFallback => 'Error';

  @override
  String get settings_serviceUrlCopiedMessage => 'URL del servicio copiada';

  @override
  String get settings_resetUiTitle => 'Restablecer interfaz';

  @override
  String get settings_resetUiKeywords => 'actualizar interfaz, refresh ui';

  @override
  String get settings_resetUiSubtitle =>
      'Reconstruir toda la interfaz del navegador';

  @override
  String get settings_addonCollectionTitle =>
      'Colección de extensiones personalizada';

  @override
  String get settings_addonCollectionSourceSectionTitle =>
      'Origen de la colección';

  @override
  String get settings_addonCollectionConfigTitle =>
      'Configuración de la colección';

  @override
  String get settings_addonCollectionConfigKeywords =>
      'complementos, colección, addons';

  @override
  String get settings_addonCollectionConfigSubtitle =>
      'Servidor de Mozilla, propietario y nombre de la colección';

  @override
  String get settings_addonCollectionServerUrlLabel => 'URL del servidor';

  @override
  String get settings_addonCollectionUserLabel => 'Usuario de la colección';

  @override
  String get settings_addonCollectionNameLabel => 'Nombre de la colección';

  @override
  String get settings_addonCollectionActionsSectionTitle => 'Acciones';

  @override
  String get settings_addonCollectionSaveRestartTitle =>
      'Guardar y reiniciar el navegador';

  @override
  String get settings_addonCollectionSaveRestartKeywords => 'reiniciar';

  @override
  String get settings_addonCollectionSaveRestartSubtitle =>
      'Aplicar la colección personalizada y reiniciar el navegador';

  @override
  String get settings_bangSettingsTitle => 'Ajustes de bangs';

  @override
  String get settings_bangSettingsKeywords => 'atajos, bangs';

  @override
  String get settings_bangSettingsSubtitle =>
      'Uso de los atajos bang, repositorios y sincronización bajo demanda.';

  @override
  String get settings_bangFrequenciesTitle => 'Frecuencia de bangs';

  @override
  String get settings_bangFrequenciesKeywords => 'uso, recomendaciones';

  @override
  String get settings_bangFrequenciesSubtitle =>
      'Uso registrado para recomendar bangs';

  @override
  String get settings_browsingTitle => 'Navegación';

  @override
  String get settings_browsingSubtitle =>
      'Pestañas, navegación, enlaces de aplicaciones y comportamiento de Small Web.';

  @override
  String get settings_newTabDefaultTitle =>
      'Tipo de pestaña nueva predeterminado';

  @override
  String get settings_newTabDefaultKeywords => 'normal, privada, aislada';

  @override
  String get settings_newTabDefaultSubtitle =>
      'Elige el tipo predeterminado de las pestañas creadas manualmente';

  @override
  String get settings_tabTypeRegularLabel => 'Normal';

  @override
  String get settings_tabTypePrivateLabel => 'Privada';

  @override
  String get settings_tabTypeIsolatedLabel => 'Aislada';

  @override
  String get settings_smallWebTabDefaultTitle => 'Tipo de pestaña de Small Web';

  @override
  String get settings_smallWebTabDefaultKeywords => 'normal, privada, aislada';

  @override
  String get settings_smallWebTabDefaultSubtitle =>
      'Elige el tipo de pestaña que se usa al entrar en Small Web';

  @override
  String get settings_externalLinkHandlingTitle => 'Enlaces externos';

  @override
  String get settings_externalLinkHandlingKeywords =>
      'intents, enlaces externos';

  @override
  String get settings_externalLinkHandlingSubtitle =>
      'Elige cómo se abren los enlaces externos en WebLibre';

  @override
  String get settings_promptOptionLabel => 'Preguntar';

  @override
  String get settings_externalLinkPromptSubtitle =>
      'Preguntar cómo deben abrirse los enlaces externos';

  @override
  String get settings_externalLinkRegularSubtitle =>
      'Abrir los enlaces externos en una pestaña normal';

  @override
  String get settings_externalLinkPrivateSubtitle =>
      'Abrir los enlaces externos en una pestaña privada';

  @override
  String get settings_externalLinkIsolatedSubtitle =>
      'Abrir los enlaces externos en una pestaña aislada';

  @override
  String get settings_bookmarkOpenBehaviorTitle => 'Apertura de marcadores';

  @override
  String get settings_bookmarkOpenBehaviorKeywords =>
      'marcadores, abrir, pestaña personalizada, aislada';

  @override
  String get settings_bookmarkOpenBehaviorSubtitle =>
      'Elige cómo se abre un marcador al pulsarlo';

  @override
  String get settings_bookmarkOpenPromptSubtitle =>
      'Preguntar cómo debe abrirse el marcador';

  @override
  String get settings_bookmarkOpenRegularSubtitle =>
      'Abrir el marcador en una pestaña normal';

  @override
  String get settings_bookmarkOpenPrivateSubtitle =>
      'Abrir el marcador en una pestaña privada';

  @override
  String get settings_customTabOptionLabel => 'Pestaña personalizada';

  @override
  String get settings_bookmarkOpenCustomTabSubtitle =>
      'Abrir el marcador en una pestaña personalizada ligera';

  @override
  String get settings_bookmarkOpenIsolatedSubtitle =>
      'Abrir el marcador en una pestaña aislada';

  @override
  String get settings_tabListDirectionTitle => 'Orden de la lista de pestañas';

  @override
  String get settings_tabListDirectionKeywords => 'ordenar, orden';

  @override
  String get settings_tabListDirectionSubtitle =>
      'Elige si la pestaña más reciente aparece arriba o abajo en la lista de pestañas';

  @override
  String get settings_directionNewestFirstLabel => 'Más recientes primero';

  @override
  String get settings_directionOldestFirstLabel => 'Más antiguas primero';

  @override
  String get settings_tabBarDirectionTitle => 'Orden de la barra de pestañas';

  @override
  String get settings_tabBarDirectionKeywords => 'ordenar, orden';

  @override
  String get settings_tabBarDirectionSubtitle =>
      'Elige si la pestaña más reciente aparece a la izquierda o a la derecha del selector rápido';

  @override
  String get settings_childTabPlacementTitle =>
      'Posición de las pestañas hijas nuevas';

  @override
  String get settings_childTabPlacementKeywords =>
      'pestañas hijas, nueva pestaña, posición, orden, final de la lista, después de la madre';

  @override
  String get settings_childTabPlacementSubtitle =>
      'Elige si una pestaña abierta desde otra se coloca detrás de la que la abrió o al final. La pestaña de origen se recuerda en ambos casos, así que la vista en árbol no se ve afectada.';

  @override
  String get settings_childTabAfterOpenerLabel => 'Tras la de origen';

  @override
  String get settings_childTabAtEndLabel => 'Al final';

  @override
  String get settings_createChildTabsTitle => 'Crear pestañas hijas';

  @override
  String get settings_createChildTabsKeywords => 'pestañas hijas';

  @override
  String get settings_createChildTabsSubtitle =>
      'Mostrar un botón para crear una pestaña hija bajo la pestaña actual (solo en la vista en árbol)';

  @override
  String get settings_showContainerUiTitle =>
      'Mostrar la interfaz de contenedores';

  @override
  String get settings_showContainerUiKeywords => 'contenedores';

  @override
  String get settings_showContainerUiSubtitle =>
      'Mostrar selectores, menús y gestión de contenedores';

  @override
  String get settings_showIsolatedTabUiTitle =>
      'Mostrar la interfaz de pestañas aisladas';

  @override
  String get settings_showIsolatedTabUiKeywords => 'pestañas aisladas';

  @override
  String get settings_showIsolatedTabUiSubtitle =>
      'Mostrar en la interfaz las opciones para crear pestañas aisladas';

  @override
  String get settings_backgroundTabBehaviorTitle => 'Pestañas en segundo plano';

  @override
  String get settings_backgroundTabBehaviorKeywords =>
      'cambiar, segundo plano, nueva pestaña, aviso, preguntar';

  @override
  String get settings_backgroundTabBehaviorSubtitle =>
      'Se aplica cuando una acción abre una pestaña nueva en segundo plano, p. ej. «Abrir en una pestaña nueva» o clonar una pestaña';

  @override
  String get settings_backgroundTabPromptTitle =>
      'Quedarse y ofrecer el cambio';

  @override
  String get settings_backgroundTabPromptSubtitle =>
      'Mantener la pestaña actual y mostrar un aviso con la acción Cambiar';

  @override
  String get settings_backgroundTabSwitchTitle => 'Cambiar inmediatamente';

  @override
  String get settings_backgroundTabSwitchSubtitle =>
      'Ir directamente a la pestaña recién abierta';

  @override
  String get settings_tabBarSwipesTitle =>
      'Deslizamientos en la barra de pestañas';

  @override
  String get settings_tabBarSwipesKeywords =>
      'gestos, deslizar, comportamiento del deslizamiento en la barra de pestañas';

  @override
  String get settings_tabBarSwipesSubtitle =>
      'Elige qué hace cada deslizamiento en Gestos';

  @override
  String get settings_sequentialTabNavigationTitle =>
      'Navegación secuencial entre pestañas';

  @override
  String get settings_sequentialTabNavigationKeywords =>
      'gestos, deslizar, pestaña siguiente, pestaña anterior, contenedores, bucle, dar la vuelta';

  @override
  String get settings_sequentialTabNavigationSubtitle =>
      'Se aplica al deslizamiento en la barra de pestañas y a los gestos de pestaña siguiente/anterior';

  @override
  String get settings_continueIntoNextContainerTitle =>
      'Continuar en el siguiente contenedor';

  @override
  String get settings_continueIntoNextContainerSubtitle =>
      'Al pasar de la primera o la última pestaña de un contenedor se entra en el contenedor vecino. Si está desactivado, la navegación se queda dentro del contenedor actual.';

  @override
  String get settings_loopAroundTitle => 'Dar la vuelta';

  @override
  String get settings_loopAroundSubtitle =>
      'Al pasar de la última pestaña se continúa en la primera, y viceversa.';

  @override
  String get settings_openLinksInAppsTitle => 'Abrir enlaces en aplicaciones';

  @override
  String get settings_openLinksInAppsKeywords =>
      'enlaces de aplicaciones, aplicaciones externas, app links';

  @override
  String get settings_openLinksInAppsSubtitle =>
      'Elige cómo se gestionan los enlaces que se pueden abrir en otras aplicaciones';

  @override
  String get settings_appLinksAlwaysTitle => 'Siempre';

  @override
  String get settings_appLinksAlwaysSubtitle =>
      'Abrir siempre los enlaces en sus aplicaciones nativas sin preguntar';

  @override
  String get settings_appLinksAskTitle => 'Preguntar antes de abrir';

  @override
  String get settings_appLinksAskSubtitle =>
      'Mostrar un aviso antes de abrir enlaces en aplicaciones';

  @override
  String get settings_appLinksNeverTitle => 'Nunca';

  @override
  String get settings_appLinksNeverSubtitle =>
      'Abrir siempre los enlaces en el navegador en lugar de en aplicaciones';

  @override
  String get settings_waitForAnswerTitle => 'Esperar tu respuesta';

  @override
  String get settings_waitForAnswerSubtitle =>
      'Retener la página mientras se pregunta en lugar de cargarla en segundo plano. No se contacta con el sitio a menos que te quedes en el navegador.';

  @override
  String get settings_offerAppStoreFallbackTitle =>
      'Ofrecer la tienda de aplicaciones como alternativa';

  @override
  String get settings_offerAppStoreFallbackSubtitle =>
      'Cuando un enlace apunta a una aplicación que no tienes instalada y no hay alternativa web, ofrecer abrir la tienda de aplicaciones';

  @override
  String get settings_allowLoginAppCallbacksTitle =>
      'Permitir retornos de inicio de sesión a aplicaciones';

  @override
  String get settings_allowLoginAppCallbacksSubtitle =>
      'Permitir que las aplicaciones que abrieron una pestaña personalizada reciban el retorno de su inicio de sesión, aunque los enlaces estén configurados para no abrirse nunca en aplicaciones';

  @override
  String get settings_appLinkContainerFallbackName => 'Contenedor';

  @override
  String get settings_appLinkOverrideModeAlways =>
      'Abre siempre en aplicaciones';

  @override
  String get settings_appLinkOverrideModeAsk => 'Pregunta antes de abrir';

  @override
  String get settings_appLinkOverrideModeNever =>
      'Mantiene siempre los enlaces en el navegador';

  @override
  String get settings_appLinkContainerOverridesHeader =>
      'Contenedores con ajustes propios de enlaces de aplicaciones';

  @override
  String settings_appLinkOverrideSummaryWithRules(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reglas recordadas',
      one: '1 regla recordada',
    );
    return '$mode · $_temp0';
  }

  @override
  String get settings_appLinkRememberedRulesHeader =>
      'Reglas de sitios recordadas';

  @override
  String get settings_appLinkRuleAlwaysOpenLabel =>
      'Abrir siempre en la aplicación';

  @override
  String get settings_appLinkRuleAlwaysKeepLabel =>
      'Mantener siempre en el navegador';

  @override
  String get settings_appLinkRuleRemoveTooltip => 'Quitar regla';

  @override
  String get settings_globalDesktopModeTitle =>
      'Solicitar siempre la versión de escritorio';

  @override
  String get settings_globalDesktopModeKeywords =>
      'modo escritorio, user agent, sitio móvil, tableta, desktop';

  @override
  String get settings_globalDesktopModeSubtitle =>
      'Abrir las pestañas nuevas en modo escritorio de forma predeterminada. Puedes seguir cambiando el modo escritorio en cada pestaña desde el menú de la página.';

  @override
  String get settings_desktopModeSitesTitle => 'Sitios en modo escritorio';

  @override
  String get settings_desktopModeSitesKeywords =>
      'modo escritorio, por sitio, user agent, excepciones';

  @override
  String get settings_desktopModeSitesSubtitle =>
      'Sitios que se cargan siempre en modo escritorio';

  @override
  String get settings_pullToRefreshTitle => 'Deslizar para actualizar';

  @override
  String get settings_pullToRefreshKeywords => 'recargar, actualizar, reload';

  @override
  String get settings_pullToRefreshSubtitle =>
      'Desliza hacia abajo en las páginas para recargarlas';

  @override
  String get settings_customTabsTitle => 'Pestañas personalizadas';

  @override
  String get settings_customTabsKeywords =>
      'pestañas personalizadas, navegador integrado, custom tabs, aplicación externa, compartir';

  @override
  String get settings_customTabsSubtitle =>
      'Permitir que otras aplicaciones abran enlaces en una pestaña ligera integrada. Si está desactivado, estos enlaces y las URL compartidas se abren como pestañas normales en el navegador principal.';

  @override
  String get settings_doubleBackCloseTabTitle =>
      'Doble atrás para cerrar la pestaña';

  @override
  String get settings_doubleBackCloseTabKeywords => 'botón atrás, back';

  @override
  String get settings_doubleBackCloseTabSubtitle =>
      'Si está activado, pulsa el botón Atrás dos veces para cerrar la pestaña. Si está desactivado, el botón Atrás solo navega por el historial de la página.';

  @override
  String get settings_allowNonManifestPwaInstallTitle =>
      'Instalar sitios como aplicaciones';

  @override
  String get settings_allowNonManifestPwaInstallKeywords =>
      'pwa, aplicaciones web';

  @override
  String get settings_allowNonManifestPwaInstallSubtitle =>
      'Permitir instalar sitios web sin manifiesto PWA como aplicaciones independientes';

  @override
  String get settings_urlCleanerTitle => 'Limpiador de URL';

  @override
  String get settings_urlCleanerKeywords =>
      'utm, parámetros de rastreo, limpiar';

  @override
  String get settings_urlCleanerSubtitle =>
      'Reglas para quitar el rastreo y actualizaciones del catálogo';

  @override
  String get settings_unshortenerTitle => 'Expansor de enlaces';

  @override
  String get settings_unshortenerKeywords =>
      'enlaces cortos, redirecciones, acortador';

  @override
  String get settings_unshortenerSubtitle =>
      'Resolución de enlaces cortos y token de API';

  @override
  String get settings_contextualToolbarSearchHint =>
      'Buscar botones de la barra de herramientas';

  @override
  String get settings_contextualToolbarTitleDefault =>
      'Personalizar la barra de herramientas';

  @override
  String get settings_contextualToolbarTitleQuickSwitcher =>
      'Personalizar los botones del selector';

  @override
  String get settings_contextualToolbarResetToDefaults =>
      'Restablecer valores predeterminados';

  @override
  String get settings_contextualToolbarEnabledSection => 'Activados';

  @override
  String get settings_contextualToolbarDisabledSection => 'Desactivados';

  @override
  String get settings_contextualToolbarNoEnabledButtons =>
      'No hay botones activados. Activa un botón de abajo.';

  @override
  String settings_contextualToolbarNoEnabledButtonsMatch(String query) {
    return 'Ningún botón activado coincide con «$query».';
  }

  @override
  String get settings_contextualToolbarAllButtonsEnabled =>
      'Todos los botones están activados.';

  @override
  String settings_contextualToolbarNoDisabledButtonsMatch(String query) {
    return 'Ningún botón desactivado coincide con «$query».';
  }

  @override
  String get settings_longPressNoneTitle => 'Nada';

  @override
  String get settings_longPressNoneDescription =>
      'Predeterminado para este botón: mantenerlo pulsado no hace nada más';

  @override
  String get settings_longPressDefaultDescription =>
      'Predeterminado para este botón';

  @override
  String get settings_longPressTitle => 'Mantener pulsado';

  @override
  String get settings_longPressDescription =>
      'Qué hace mantener pulsado el botón';

  @override
  String get settings_fallbackGreyOutLabel => 'Atenuar';

  @override
  String get settings_fallbackIfUnavailableTitle => 'Si no está disponible';

  @override
  String get settings_fallbackIfUnavailableDescription =>
      'Se muestra en su lugar mientras este botón no se puede usar';

  @override
  String get settings_customTrackingProtectionTitle =>
      'Protección contra el rastreo personalizada';

  @override
  String get settings_customTrackingProtectionSubtitle =>
      'Controles personalizados de cookies, contenido, rastreadores y huellas digitales.';

  @override
  String get settings_fixMajorIssuesTitle =>
      'Corregir problemas graves de los sitios';

  @override
  String get settings_fixMajorIssuesSubtitle =>
      'Aplicar las excepciones necesarias para evitar fallos graves en los sitios web (recomendado)';

  @override
  String get settings_fixMinorIssuesTitle =>
      'Corregir problemas menores de los sitios';

  @override
  String get settings_fixMinorIssuesSubtitle =>
      'Aplicar excepciones para corregir problemas menores y activar funciones de comodidad';

  @override
  String get settings_blockCookiesTitle => 'Bloquear cookies';

  @override
  String get settings_blockCookiesSubtitle =>
      'Bloquear cookies según la política de abajo';

  @override
  String get settings_cookiePolicyTitle => 'Política de cookies';

  @override
  String get settings_cookiePolicyTotalProtectionLabel =>
      'Protección total contra las cookies (recomendada)';

  @override
  String get settings_cookiePolicyCrossSiteTrackersLabel =>
      'Rastreadores entre sitios y de redes sociales';

  @override
  String get settings_cookiePolicyUnvisitedLabel => 'Sitios no visitados';

  @override
  String get settings_cookiePolicyThirdPartyLabel =>
      'Todas las cookies de terceros';

  @override
  String get settings_cookiePolicyAllCookiesLabel =>
      'Todas las cookies (puede provocar fallos en los sitios)';

  @override
  String get settings_blockTrackingContentTitle =>
      'Bloquear contenido de rastreo';

  @override
  String get settings_blockTrackingContentSubtitle =>
      'Bloquear scripts y recursos de rastreo incrustados en los sitios web';

  @override
  String get settings_trackingScopeApplyToTitle => 'Aplicar a';

  @override
  String get settings_trackingScopeAllTabsLabel => 'Todas las pestañas';

  @override
  String get settings_trackingScopePrivateOnlyLabel => 'Solo pestañas privadas';

  @override
  String get settings_adsAnalyticsSocialTrackersTitle =>
      'Anuncios, analíticas y rastreadores sociales';

  @override
  String get settings_adsAnalyticsSocialTrackersSubtitle =>
      'Bloquear las categorías de rastreadores de publicidad, analíticas, redes sociales y rastreadores sociales de Mozilla';

  @override
  String get settings_cryptominersTitle => 'Criptomineros';

  @override
  String get settings_cryptominersSubtitle =>
      'Bloquear scripts que usan tu dispositivo para minar criptomonedas';

  @override
  String get settings_knownFingerprintersTitle =>
      'Detectores de huellas digitales conocidos';

  @override
  String get settings_knownFingerprintersSubtitle =>
      'Bloquear scripts que recopilan información para identificar tu dispositivo de forma única';

  @override
  String get settings_redirectTrackersTitle => 'Rastreadores por redirección';

  @override
  String get settings_redirectTrackersSubtitle =>
      'Bloquear rastreadores que recopilan datos mediante redirecciones de URL intermedias';

  @override
  String get settings_suspectedFingerprintersTitle =>
      'Presuntos detectores de huellas digitales';

  @override
  String get settings_suspectedFingerprintersSubtitle =>
      'Bloquear técnicas adicionales de huellas digitales que pueden usarse para rastrearte';

  @override
  String get settings_desktopModeSitesScreenTitle =>
      'Sitios en modo escritorio';

  @override
  String get settings_desktopModeSitesScreenDescription =>
      'Estos sitios se cargan siempre en modo escritorio, en lugar del modo predeterminado. Se incluyen los subdominios (p. ej., «example.com» también abarca «m.example.com»).';

  @override
  String get settings_desktopModeSitesEmptyLabel =>
      'No se ha añadido ningún sitio.';

  @override
  String get settings_dohTitle => 'DNS sobre HTTPS';

  @override
  String get settings_dohSubtitle =>
      'Nivel de protección del DNS cifrado y selección del resolvedor.';

  @override
  String get settings_errorLogsCopiedMessage => 'Registros copiados';

  @override
  String get settings_errorLogsSearchHint =>
      'Buscar en los mensajes del registro';

  @override
  String get settings_errorLogsCopyTooltip => 'Copiar registros';

  @override
  String get settings_errorLogsEmptyLabel => 'No hay registros disponibles';

  @override
  String get settings_experimentalTitle => 'Experimental';

  @override
  String get settings_experimentalSubtitle =>
      'Aislamiento en tiempo de ejecución y comportamiento al iniciar.';

  @override
  String get settings_isolatedContentProcessTitle =>
      'Proceso de contenido aislado';

  @override
  String get settings_isolatedContentProcessKeywords =>
      'reiniciar, proceso aislado';

  @override
  String get settings_isolatedContentProcessSubtitle =>
      'Ejecutar el contenido web en un proceso aislado. Requiere reiniciar la aplicación.';

  @override
  String get settings_appZygoteProcessTitle => 'Proceso App Zygote';

  @override
  String get settings_appZygoteProcessKeywords => 'reiniciar, android 10';

  @override
  String get settings_appZygoteProcessSubtitle =>
      'Precargar el servicio de contenido para que el proceso aislado se inicie más rápido. Requiere Android 10 o superior y reiniciar la aplicación.';

  @override
  String get settings_extensionsTitle => 'Extensiones';

  @override
  String get settings_extensionsSubtitle =>
      'Gestionar complementos, comportamiento de las actualizaciones y seguridad de las extensiones.';

  @override
  String get settings_manageExtensionsTitle => 'Gestionar extensiones';

  @override
  String get settings_manageExtensionsKeywords =>
      'complementos, extensiones del navegador, addons';

  @override
  String get settings_manageExtensionsSubtitle =>
      'Explorar extensiones instaladas, desactivadas, disponibles y no compatibles';

  @override
  String get settings_customCollectionTitle => 'Colección personalizada';

  @override
  String get settings_customCollectionKeywords =>
      'complementos, colección, addons';

  @override
  String get settings_customCollectionSubtitle =>
      'Usar una colección de complementos de Mozilla personalizada';

  @override
  String get settings_automaticUpdatesTitle => 'Actualizaciones automáticas';

  @override
  String get settings_automaticUpdatesKeywords =>
      'complementos, actualizar, addons';

  @override
  String get settings_automaticUpdatesSubtitle =>
      'Buscar e instalar automáticamente actualizaciones de extensiones cada 12 horas';

  @override
  String settings_failedToLoadMessage(String error) {
    return 'No se pudo cargar: $error';
  }

  @override
  String get settings_allowUnsignedExtensionsTitle =>
      'Permitir extensiones sin firmar';

  @override
  String get settings_protectionCoherenceSectionTitle =>
      'Protection coherence';

  @override
  String get settings_monitorExtensionConflictsTitle =>
      'Monitor extension conflicts';

  @override
  String get settings_monitorExtensionConflictsSubtitle =>
      'Warn when an extension and the settings both control a fingerprint surface, or when an extension changes only part of one.';

  @override
  String get settings_followExtensionChangesTitle =>
      'Follow extension changes';

  @override
  String get settings_followExtensionChangesSubtitle =>
      'Update the related protection settings when an extension changes one, so the fingerprint stays coherent instead of half-moved.';

  @override
  String get settings_extensionProtectionClaimsTitle =>
      'Extension protection claims';

  @override
  String get settings_extensionProtectionClaimsLoading =>
      'Reading extension declarations…';

  @override
  String get settings_extensionProtectionClaimsNone =>
      'No built-in extension declares a fingerprint surface.';

  @override
  String get settings_extensionProtectionClaimsControls =>
      'Controls';

  @override
  String get settings_extensionProtectionClaimsIncomplete =>
      'Incomplete';

  @override
  String get settings_allowUnsignedExtensionsKeywords =>
      'complementos, sin firmar, addons';

  @override
  String get settings_allowUnsignedExtensionsSubtitle =>
      'Las extensiones sin firmar no han sido verificadas por Mozilla';

  @override
  String get settings_allowUnsignedWarningText =>
      'Instala extensiones sin firmar solo de fuentes de confianza. Pueden contener código malicioso.';

  @override
  String get settings_allowUnsignedConfirmDialogTitle =>
      '¿Permitir extensiones sin firmar?';

  @override
  String get settings_allowUnsignedConfirmWarningBold =>
      'Aviso: esto debilita considerablemente la seguridad de tu navegador.';

  @override
  String get settings_allowUnsignedConfirmBody =>
      'Las extensiones sin firmar se saltan el proceso de revisión de seguridad de Mozilla. Las extensiones maliciosas pueden:\n\n• Leer y modificar todo lo que ves en cualquier sitio web\n• Robar contraseñas, datos bancarios y datos personales\n• Vigilar tu actividad de navegación sin que lo notes\n• Instalar más malware en tu dispositivo';

  @override
  String get settings_allowUnsignedConfirmFooter =>
      'Actívalo solo si eres desarrollador e instalas tu propia extensión o si confías plenamente en la fuente.';

  @override
  String get settings_allowAction => 'Permitir';

  @override
  String settings_allowActionCountdown(int seconds) {
    return 'Permitir ($seconds)';
  }

  @override
  String get settings_fingerprintProtectionTitle =>
      'Protección contra huellas digitales';

  @override
  String get settings_fingerprintProtectionKeywords =>
      'privacidad, huella digital, fingerprinting';

  @override
  String get settings_fingerprintSearchHint =>
      'Buscar objetivos de protección contra huellas digitales';

  @override
  String get settings_loadDefaultsAction => 'Cargar valores predeterminados';

  @override
  String get settings_loadHardenedDefaultsAction => 'Cargar valores reforzados';

  @override
  String get settings_fingerprintOverrideTargetsSection =>
      'Objetivos de protección';

  @override
  String get settings_fingerprintInvalidOverride =>
      'Las protecciones contra huellas digitales guardadas no tienen un formato válido';

  @override
  String get settings_fingerprintUnknownTarget =>
      'Las protecciones contra huellas digitales guardadas mencionan un objetivo que esta versión no conoce';

  @override
  String get settings_homeAndNewTabTitle => 'Inicio y nueva pestaña';

  @override
  String get settings_homeAndNewTabSubtitle =>
      'Qué muestran la página de inicio y la de nueva pestaña';

  @override
  String get settings_addressFieldLabel => 'Dirección';

  @override
  String get settings_homeTargetUrlEmptyError =>
      'Introduce una dirección o se mostrará la página de inicio';

  @override
  String get settings_homeTargetUrlInvalidError => 'No es una dirección válida';

  @override
  String get settings_applyWhenLastTabClosesTitle =>
      'Aplicar al cerrar la última pestaña';

  @override
  String get settings_applyWhenLastTabClosesKeywords =>
      'cerrar, última pestaña, contenedor';

  @override
  String get settings_applyWhenLastTabClosesSubtitle =>
      'Al cerrar la última pestaña de un contenedor, se queda en él en lugar de abrir una pestaña de otro sitio';

  @override
  String settings_homeSearchBarCurrentlyLabel(String value) {
    return 'Actualmente: $value';
  }

  @override
  String get settings_wallpaperTitle => 'Fondo de pantalla';

  @override
  String get settings_wallpaperKeywords =>
      'fondo de pantalla, fondo, imagen, foto, desenfoque, atenuación, inicio, wallpaper';

  @override
  String get settings_wallpaperSetSubtitle =>
      'Hay una imagen de fondo configurada para la página de inicio';

  @override
  String get settings_wallpaperUnsetSubtitle =>
      'Configura una imagen de fondo para la página de inicio';

  @override
  String get settings_customizeHomeSectionsTitle =>
      'Personalizar las secciones de inicio';

  @override
  String get settings_customizeHomeSectionsKeywords =>
      'inicio, secciones, accesos directos, cita, acciones rápidas, reordenar';

  @override
  String get settings_customizeHomeSectionsSubtitle =>
      'Elige y ordena lo que muestra la página de inicio';

  @override
  String get settings_customizeNewTabSectionsTitle =>
      'Personalizar las secciones de nueva pestaña';

  @override
  String get settings_customizeNewTabSectionsKeywords =>
      'nueva pestaña, secciones, accesos directos, reordenar';

  @override
  String get settings_customizeNewTabSectionsSubtitle =>
      'Elige y ordena lo que muestra la página de nueva pestaña';

  @override
  String get settings_browserLanguagesTitle => 'Idiomas del navegador';

  @override
  String get settings_browserLanguagesKeywords =>
      'idioma, configuración regional, locale';

  @override
  String get settings_browserLanguagesSearchHint =>
      'Buscar configuraciones regionales por código';

  @override
  String get settings_languageRegionSettingsSection =>
      'Ajustes de idioma y región';

  @override
  String get settings_browserLanguagePreferenceLabel =>
      'Preferencia de idioma del navegador';

  @override
  String get settings_customLocaleSection =>
      'Configuración regional personalizada';

  @override
  String get settings_addCustomLocaleTitle =>
      'Añadir configuración regional personalizada';

  @override
  String get settings_addCustomLocaleKeywords => 'código de idioma, locale tag';

  @override
  String get settings_addCustomLocaleSubtitle =>
      'Introduce un código de configuración regional, como en-US';

  @override
  String get settings_customLocaleFieldLabel =>
      'Configuración regional personalizada';

  @override
  String get settings_invalidLocaleError =>
      'Identificador de configuración regional no válido';

  @override
  String get settings_homeTargetHomeLabel => 'Página de inicio';

  @override
  String get settings_homeTargetResumeLastTabLabel => 'Última pestaña abierta';

  @override
  String get settings_homeTargetCustomUrlLabel => 'Dirección personalizada';

  @override
  String get settings_homeTargetHomeDescription =>
      'Mostrar los accesos directos y las secciones que hayas elegido';

  @override
  String get settings_homeTargetResumeLastTabDescription =>
      'Continuar donde lo dejaste';

  @override
  String get settings_homeTargetCustomUrlDescription =>
      'Abrir una página concreta';

  @override
  String get settings_homeSearchBarAutoLabel => 'Seguir la barra de pestañas';

  @override
  String get settings_homeSearchBarTopLabel =>
      'Parte superior de la página de inicio';

  @override
  String get settings_homeSearchBarTabBarLabel => 'En la barra de pestañas';

  @override
  String get settings_homeSearchBarAutoDescription =>
      'En el borde en el que esté la barra de pestañas';

  @override
  String get settings_homeSearchBarTopDescription =>
      'Una barra de búsqueda fija encima de las secciones de inicio';

  @override
  String get settings_homeSearchBarTabBarDescription =>
      'El campo de dirección de la barra de pestañas, con búsqueda por QR y por voz';

  @override
  String get settings_generalTitle => 'General';

  @override
  String get settings_generalSubtitle =>
      'Apariencia, descargas y valores predeterminados del navegador.';

  @override
  String get settings_defaultBrowserTileTitle => 'Navegador predeterminado';

  @override
  String get settings_defaultBrowserTileKeywords =>
      'navegador del sistema, predeterminado';

  @override
  String get settings_defaultBrowserTileSubtitleSet =>
      'WebLibre es tu navegador predeterminado';

  @override
  String get settings_defaultBrowserTileSubtitleNotSet =>
      'Establecer WebLibre como navegador predeterminado';

  @override
  String get settings_defaultBrowserButtonDefault => 'Predeterminado';

  @override
  String get settings_defaultBrowserButtonSet => 'Establecer';

  @override
  String get settings_backupProfileTitle =>
      'Hacer copia de seguridad de este perfil';

  @override
  String get settings_backupProfileKeywords =>
      'copia de seguridad, archivar, exportar, guardar, cifrado, restaurar, backup';

  @override
  String settings_backupProfileSubtitleReady(String name) {
    return 'Guardar «$name» en un archivo de copia de seguridad cifrado';
  }

  @override
  String get settings_backupProfileSubtitleError =>
      'No se pudo leer el perfil activo';

  @override
  String get settings_settingsTransferTileTitle =>
      'Exportar e importar ajustes';

  @override
  String get settings_settingsTransferTileKeywords =>
      'exportar, importar, ajustes, transferir, compartir, portapapeles, json, copiar, migrar';

  @override
  String get settings_settingsTransferTileSubtitle =>
      'Guardar los ajustes en un archivo o en el portapapeles y volver a leerlos';

  @override
  String get settings_uiZoomTitle => 'Zoom de la interfaz';

  @override
  String get settings_uiZoomKeywords => 'escala de la interfaz, zoom, tamaño';

  @override
  String get settings_uiZoomSubtitle =>
      'Hacer la interfaz más pequeña o más grande';

  @override
  String get settings_disableAnimationsTitle => 'Desactivar animaciones';

  @override
  String get settings_disableAnimationsKeywords => 'movimiento, animaciones';

  @override
  String get settings_disableAnimationsSubtitle =>
      'Reducir el movimiento y desactivar las animaciones de la aplicación';

  @override
  String get settings_showModalBarrierTitle =>
      'Oscurecer el fondo de los diálogos';

  @override
  String get settings_showModalBarrierKeywords =>
      'diálogos, paneles inferiores, superposición';

  @override
  String get settings_showModalBarrierSubtitle =>
      'Atenuar el fondo detrás de los diálogos y los paneles inferiores';

  @override
  String get settings_showSearchCloseButtonTitle => 'Mostrar botón de cerrar';

  @override
  String get settings_showSearchCloseButtonKeywords =>
      'atrás, cerrar, descartar, tinta electrónica, e-ink, eink, accesibilidad, nueva pestaña';

  @override
  String get settings_showSearchCloseButtonSubtitle =>
      'Añadir un botón para cerrar la página de búsqueda o de nueva pestaña sin el gesto de atrás. Es útil en dispositivos sin botón de atrás.';

  @override
  String get settings_pureBlackTitle => 'Negro puro (OLED)';

  @override
  String get settings_pureBlackKeywords =>
      'oled, amoled, alto contraste, negro, oscuro';

  @override
  String get settings_pureBlackSubtitle =>
      'Usar superficies de negro puro en el modo oscuro para ahorrar energía en pantallas OLED';

  @override
  String get settings_themeTitle => 'Tema';

  @override
  String get settings_themeKeywords => 'claro, oscuro, modo del tema';

  @override
  String get settings_themeModeSystem => 'Sistema';

  @override
  String get settings_themeModeLight => 'Claro';

  @override
  String get settings_themeModeDark => 'Oscuro';

  @override
  String get settings_appLanguageSystemDefault => 'Predeterminado del sistema';

  @override
  String settings_appLanguageCurrentlyLabel(String language) {
    return 'Actualmente: $language';
  }

  @override
  String get settings_appLanguageTranslationsNote =>
      'Las traducciones son nuevas y pueden estar incompletas o ser inexactas, por eso WebLibre usa el inglés hasta que elijas otro idioma. Elige «Predeterminado del sistema» para usar el idioma de tu dispositivo.';

  @override
  String get settings_refreshRateTitle => 'Frecuencia de actualización';

  @override
  String get settings_refreshRateKeywords =>
      'fps, hz, hercios, frecuencia de fotogramas, 60hz, 90hz, 120hz, fluidez, alta frecuencia, modo de pantalla';

  @override
  String get settings_refreshRateSubtitle =>
      'Elige «Alta» para un desplazamiento y unas animaciones más fluidos en pantallas de 90 o 120 Hz, o «Baja» para ahorrar batería.';

  @override
  String get settings_refreshRateModeSystem => 'Sistema';

  @override
  String get settings_refreshRateModeHigh => 'Alta';

  @override
  String get settings_refreshRateModeLow => 'Baja';

  @override
  String get settings_downloadFolderTitle => 'Carpeta de descargas';

  @override
  String get settings_downloadFolderKeywords =>
      'descargas, carpeta, directorio, almacenamiento, guardar';

  @override
  String get settings_downloadFolderSubtitleDefault =>
      'Guardando en la carpeta Descargas del sistema';

  @override
  String settings_downloadFolderSubtitleUnavailable(String folderName) {
    return 'Ya no está disponible; guardando en la carpeta Descargas del sistema ($folderName)';
  }

  @override
  String get settings_downloadFolderSubtitleExternalManager =>
      'La aplicación gestora de descargas elige dónde se guardan los archivos';

  @override
  String get settings_downloadFolderResetTooltip =>
      'Usar la carpeta Descargas del sistema';

  @override
  String get settings_externalDownloadManagerTitle =>
      'Usar un gestor de descargas externo';

  @override
  String get settings_externalDownloadManagerKeywords => 'descargas, gestor';

  @override
  String get settings_externalDownloadManagerSubtitle =>
      'Gestionar las descargas con otra aplicación';

  @override
  String get settings_preferredDownloadManagerTitle =>
      'Gestor de descargas preferido';

  @override
  String get settings_preferredDownloadManagerKeywords =>
      'descargas, gestor de descargas, usar siempre, aplicación predeterminada, selector, preguntar';

  @override
  String get settings_preferredDownloadManagerSubtitleNotSet =>
      'Sin configurar: marca «Usar siempre esta aplicación» la próxima vez que aparezca el selector';

  @override
  String settings_preferredDownloadManagerSubtitleThisApp(String appName) {
    return '$appName, con una confirmación antes de cada descarga';
  }

  @override
  String settings_preferredDownloadManagerSubtitleUnavailable(
    String packageName,
  ) {
    return 'Ya no está instalado ($packageName); se pregunta cada vez';
  }

  @override
  String get settings_preferredDownloadManagerSubtitleExternalOff =>
      'Sin configurar: solo se usa con un gestor de descargas externo';

  @override
  String settings_preferredDownloadManagerSubtitleInactive(String appName) {
    return '$appName: no se usa mientras el gestor de descargas externo esté desactivado';
  }

  @override
  String get settings_preferredDownloadManagerClearTooltip =>
      'Olvidar el gestor preferido';

  @override
  String get settings_defaultBrowserSectionTitle => 'Navegador predeterminado';

  @override
  String get settings_defaultBrowserSectionKeywords =>
      'navegador predeterminado';

  @override
  String get settings_indexDefaultBrowserSubtitle =>
      'Establecer WebLibre como navegador predeterminado';

  @override
  String get settings_appearanceSectionTitle => 'Apariencia';

  @override
  String get settings_indexThemeSubtitle =>
      'Elegir el modo del sistema, claro u oscuro';

  @override
  String get settings_indexAppLanguageTitle => 'Idioma de la aplicación';

  @override
  String get settings_indexAppLanguageKeywords =>
      'idioma, traducción, idioma de la interfaz, locale';

  @override
  String get settings_indexAppLanguageSubtitle =>
      'Elegir el idioma de la propia interfaz de WebLibre';

  @override
  String get settings_indexRefreshRateSubtitle =>
      'Solicitar una frecuencia de actualización de pantalla alta o baja (Android)';

  @override
  String get settings_indexShowCloseButtonSubtitle =>
      'Añadir un botón para cerrar la página de búsqueda / nueva pestaña sin el gesto de atrás';

  @override
  String get settings_profileSectionTitle => 'Perfil';

  @override
  String get settings_profileSectionKeywords => 'usuario, perfil';

  @override
  String get settings_indexBackupProfileSubtitle =>
      'Crear una copia de seguridad cifrada del perfil que estás usando';

  @override
  String get settings_indexSettingsTransferSubtitle =>
      'Mover los ajustes entre perfiles o dispositivos, o adjuntarlos a un informe de error';

  @override
  String get settings_downloadsSectionTitle => 'Descargas';

  @override
  String get settings_indexDownloadFolderSubtitle =>
      'Elegir dónde se guardan los archivos descargados';

  @override
  String get settings_indexPreferredDownloadManagerSubtitle =>
      'La aplicación a la que van las descargas sin preguntar';

  @override
  String get settings_contentIdentitySectionTitle => 'Contenido e identidad';

  @override
  String get settings_contentIdentitySectionKeywords => 'motor';

  @override
  String get settings_indexJavascriptSubtitle =>
      'Activar o desactivar los scripts de los sitios web';

  @override
  String get settings_indexUserAgentSubtitle =>
      'Sustituir la cadena del user agent del navegador';

  @override
  String get settings_indexEnterpriseRootsSubtitle =>
      'Permitir los certificados del almacén de CA de Android';

  @override
  String get settings_experimentalSectionTitle => 'Experimental';

  @override
  String get settings_developerToolsSectionTitle =>
      'Herramientas para desarrolladores';

  @override
  String get settings_developerToolsSectionKeywords => 'depuración, debug';

  @override
  String get settings_indexUnmountGeckoViewSubtitle =>
      'Reconstruir el motor web tras una superposición en lugar de mantenerlo en memoria';

  @override
  String get settings_tabsSectionTitle => 'Pestañas';

  @override
  String get settings_indexTabListDirectionSubtitle =>
      'Elegir el orden de las pestañas en la vista de lista';

  @override
  String get settings_indexTabBarDirectionSubtitle =>
      'Elegir el orden de las pestañas en la barra de pestañas';

  @override
  String get settings_indexChildTabPlacementSubtitle =>
      'Elegir dónde se insertan las pestañas abiertas desde otra pestaña';

  @override
  String get settings_indexCreateChildTabsSubtitle =>
      'Mostrar un botón que añade una pestaña hija bajo la pestaña actual';

  @override
  String get settings_indexBackgroundTabBehaviorSubtitle =>
      'Elegir qué ocurre después de abrir una pestaña en segundo plano';

  @override
  String get settings_navigationSectionTitle => 'Navegación';

  @override
  String get settings_indexDoubleBackCloseTabSubtitle =>
      'Pulsar dos veces el botón Atrás para cerrar la pestaña actual';

  @override
  String get settings_indexTabBarSwipesSubtitle =>
      'Elegir qué hacen los deslizamientos en la barra de pestañas';

  @override
  String get settings_indexSequentialTabNavigationSubtitle =>
      'Elegir dónde termina el recorrido ordenado por las pestañas';

  @override
  String get settings_indexOpenLinksInAppsSubtitle =>
      'Elegir cómo se abren los enlaces de aplicaciones externas';

  @override
  String get settings_desktopModeSectionTitle => 'Modo escritorio';

  @override
  String get settings_indexGlobalDesktopModeSubtitle =>
      'Abrir las pestañas nuevas en modo escritorio de forma predeterminada';

  @override
  String get settings_homeScreenSectionTitle => 'Pantalla de inicio';

  @override
  String get settings_indexAllowNonManifestPwaInstallSubtitle =>
      'Permitir instalar como aplicaciones sitios web sin manifiesto';

  @override
  String get settings_externalLinksSectionTitle => 'Enlaces externos';

  @override
  String get settings_indexCustomTabsSubtitle =>
      'Permitir que otras aplicaciones abran enlaces en una pestaña ligera integrada en lugar del navegador principal';

  @override
  String get settings_bookmarksSectionTitle => 'Marcadores';

  @override
  String get settings_resolverSettingsSectionTitle => 'Ajustes del resolvedor';

  @override
  String get settings_indexDnsOverHttpsResolverTitle => 'DNS sobre HTTPS';

  @override
  String get settings_indexDnsOverHttpsResolverKeywords =>
      'doh, resolvedor, proveedor de dns, resolvedor personalizado, resolver';

  @override
  String get settings_indexDnsOverHttpsResolverSubtitle =>
      'Nivel de protección, elección del proveedor y resolvedores personalizados guardados';

  @override
  String get settings_runtimeStartupSectionTitle =>
      'Tiempo de ejecución e inicio';

  @override
  String get settings_indexIsolatedContentProcessSubtitle =>
      'Ejecutar el contenido web en un proceso aislado';

  @override
  String get settings_indexAppZygoteProcessSubtitle =>
      'Precargar el servicio de contenido para iniciar más rápido el proceso aislado';

  @override
  String get settings_startupSectionTitle => 'Inicio';

  @override
  String get settings_startupSectionKeywords =>
      'inicio, arranque, reanudar, última pestaña, url personalizada';

  @override
  String get settings_indexHomeTargetTitle =>
      'Cuando no hay ninguna pestaña que mostrar';

  @override
  String get settings_indexHomeTargetKeywords =>
      'inicio, reanudar, última pestaña, url personalizada, página de inicio, homepage';

  @override
  String get settings_indexHomeTargetSubtitle =>
      'Al iniciar y después de cerrar la última pestaña';

  @override
  String get settings_indexHomeTargetOnLastTabClosedSubtitle =>
      'Si no, se abre en su lugar una pestaña de otro contenedor';

  @override
  String get settings_homeAppearanceSectionTitle => 'Apariencia';

  @override
  String get settings_homeAppearanceSectionKeywords =>
      'inicio, fondo de pantalla, fondo, imagen, desenfoque, atenuación';

  @override
  String get settings_indexWallpaperSubtitle =>
      'Una imagen de fondo para la página de inicio';

  @override
  String get settings_layoutSectionTitle => 'Diseño';

  @override
  String get settings_layoutSectionKeywords =>
      'inicio, nueva pestaña, secciones, módulos, diseño';

  @override
  String get settings_indexHomeSearchBarPlacementTitle =>
      'Posición de la barra de búsqueda';

  @override
  String get settings_indexHomeSearchBarPlacementKeywords =>
      'búsqueda, barra, posición, dirección, url, arriba, abajo, barra de pestañas, inicio';

  @override
  String get settings_indexHomeSearchBarPlacementSubtitle =>
      'Dónde ofrece la página de inicio su campo de búsqueda';

  @override
  String get settings_allowlistExceptionsSectionTitle =>
      'Excepciones de la lista de permitidos';

  @override
  String get settings_indexAllowlistExceptionsTitle =>
      'Excepciones de la lista de permitidos';

  @override
  String get settings_indexAllowlistExceptionsSubtitle =>
      'Excepciones de compatibilidad para problemas graves y menores de los sitios web';

  @override
  String get settings_cookiesSectionTitle => 'Cookies';

  @override
  String get settings_indexCookiesSubtitle =>
      'Modo de bloqueo de cookies y selección de la política';

  @override
  String get settings_trackingContentSectionTitle => 'Contenido de rastreo';

  @override
  String get settings_indexTrackingContentTitle => 'Contenido de rastreo';

  @override
  String get settings_indexTrackingContentSubtitle =>
      'Scripts de rastreo y alcance del bloqueo';

  @override
  String get settings_trackersSectionTitle => 'Rastreadores';

  @override
  String get settings_indexTrackersSubtitle =>
      'Criptomineros, detectores de huellas digitales conocidos y rastreadores por redirección';

  @override
  String get settings_advancedFingerprintingProtectionSectionTitle =>
      'Protección avanzada contra huellas digitales';

  @override
  String get settings_indexAdvancedFingerprintingProtectionTitle =>
      'Protección avanzada contra huellas digitales';

  @override
  String get settings_indexAdvancedFingerprintingProtectionSubtitle =>
      'Presuntos detectores de huellas digitales y alcance por pestañas';

  @override
  String get settings_usageDataSectionTitle => 'Datos de uso';

  @override
  String get settings_repositoriesSectionTitle => 'Repositorios';

  @override
  String get settings_indexGeneralBangsSubtitle =>
      'Sincronizar bajo demanda desde GitHub';

  @override
  String get settings_generalBangsTileTitle => 'Bangs generales';

  @override
  String get settings_generalBangsTileKeywords => 'repositorio';

  @override
  String get settings_generalBangsTileSubtitle =>
      'Sincronizar bajo demanda desde GitHub';

  @override
  String get settings_indexKagiBangsSubtitle =>
      'Sincronizar bajo demanda desde GitHub';

  @override
  String get settings_kagiBangsTileTitle => 'Bangs de Kagi';

  @override
  String get settings_kagiBangsTileKeywords => 'repositorio';

  @override
  String get settings_kagiBangsTileSubtitle =>
      'Sincronizar bajo demanda desde GitHub';

  @override
  String get settings_extensionsSectionTitle => 'Extensiones';

  @override
  String get settings_updatesSectionTitle => 'Actualizaciones';

  @override
  String get settings_securitySectionTitle => 'Seguridad';

  @override
  String get settings_actionResetToDefaults =>
      'Restablecer valores predeterminados';

  @override
  String get settings_menuLayoutTitle => 'Personalizar menú';

  @override
  String get settings_menuLayoutHintSections =>
      'Arrastra para reordenar. Desactiva una sección para ocultarla del menú.';

  @override
  String get settings_menuLayoutHintSectionItems =>
      'Arrastra para reordenar las filas de esta sección.';

  @override
  String get settings_menuLayoutHintSubItems =>
      'Arrastra para reordenar las filas que abre este elemento.';

  @override
  String get settings_moduleSurfaceHint =>
      'Arrastra para reordenar. Desactiva una sección para ocultarla aquí sin afectar a la otra página.';

  @override
  String get settings_moduleSurfaceTitleHome => 'Personalizar inicio';

  @override
  String get settings_moduleSurfaceTitleNewTab => 'Personalizar nueva pestaña';

  @override
  String get settings_homeSearchBarRowTitle => 'Barra de búsqueda';

  @override
  String get settings_proxyTitle => 'Proxy';

  @override
  String get settings_proxySubtitle =>
      'Gestionar las conexiones proxy y elegir qué pestañas las usan.';

  @override
  String get settings_proxyConnectionsTitle => 'Conexiones proxy';

  @override
  String get settings_proxyConnectionsKeywords =>
      'sing-box, socks, vpn, wireguard, tor, onion, puentes, obfs4, snowflake';

  @override
  String get settings_proxyConnectionsSubtitle =>
      'Gestionar perfiles y conexiones proxy';

  @override
  String get settings_proxyRoutingTitle => 'Enrutamiento del proxy';

  @override
  String get settings_proxyRoutingKeywords =>
      'enrutamiento, contenedor, routing';

  @override
  String get settings_proxyRoutingSubtitle =>
      'Elegir qué proxy transporta las pestañas normales y privadas';

  @override
  String get settings_proxyLogsTitle => 'Registros del proxy';

  @override
  String get settings_proxyLogsKeywords =>
      'registro, registros, logs, diagnóstico, depuración, traza, detallado, solución de problemas, nivel';

  @override
  String get settings_toolbarLayoutTitle => 'Barra de herramientas y diseño';

  @override
  String get settings_toolbarLayoutSearchHint =>
      'Buscar ajustes de barra de herramientas y diseño';

  @override
  String get settings_privacySecurityTitle => 'Privacidad y seguridad';

  @override
  String get settings_privacySecuritySubtitle =>
      'Protección contra el rastreo, huellas digitales, datos de navegación y refuerzo de la red.';

  @override
  String get settings_trackingProtectionExceptionsTitle =>
      'Excepciones de la protección contra el rastreo';

  @override
  String get settings_trackingProtectionExceptionsKeywords => 'excepciones';

  @override
  String get settings_trackingProtectionExceptionsTileSubtitle =>
      'Sitios en los que la protección contra el rastreo está desactivada';

  @override
  String get settings_autoDeleteBrowsingDataTitle =>
      'Eliminar datos de navegación automáticamente';

  @override
  String get settings_autoDeleteBrowsingDataKeywords =>
      'incógnito, modo privado, salir, cerrar, borrar al salir, eliminar datos, incognito, quit';

  @override
  String get settings_autoDeleteBrowsingDataSubtitle =>
      'Eliminar los datos de navegación seleccionados al salir o cada vez que se inicia WebLibre';

  @override
  String get settings_autoDeleteBrowsingDataQuitOnlySubtitle =>
      'Eliminar los datos de navegación seleccionados al salir de WebLibre';

  @override
  String get settings_autoDeleteOnStartTitle => 'Eliminar también al iniciar';

  @override
  String get settings_autoDeleteOnStartSubtitle =>
      'Cubre las sesiones que terminaron sin «Salir», por ejemplo si deslizaste WebLibre para cerrarlo o Android lo cerró en segundo plano. Si está desactivado, sus datos se conservan hasta la próxima vez que salgas.';

  @override
  String get settings_confirmBeforeQuitTitle => 'Confirmar antes de salir';

  @override
  String get settings_confirmBeforeQuitKeywords =>
      'salir, cerrar, confirmación, diálogo, no volver a preguntar, quit, exit';

  @override
  String get settings_confirmBeforeQuitSubtitle =>
      'Preguntar antes de que «Salir» cierre WebLibre. Mantén pulsado «Salir» para omitir la pregunta.';

  @override
  String get settings_trackingProtectionExceptionsSearchHint =>
      'Buscar URL de excepciones';

  @override
  String get settings_trackingProtectionExceptionsDeleteAll => 'Eliminar todo';

  @override
  String get settings_trackingProtectionExceptionsSectionTitle =>
      'Lista de excepciones';

  @override
  String get settings_trackingProtectionExceptionsEntrySubtitle =>
      'Sitio con la protección contra el rastreo desactivada';

  @override
  String get settings_trackingProtectionExceptionsRemoveTooltip =>
      'Quitar excepción';

  @override
  String get settings_trackingProtectionExceptionsEmptyTitle =>
      'No hay excepciones';

  @override
  String get settings_trackingProtectionExceptionsEmptySubtitle =>
      'Aquí aparecerán los sitios añadidos a las excepciones';

  @override
  String get settings_trackingProtectionExceptionsErrorTitle =>
      'Error al cargar las excepciones';

  @override
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error) {
    return 'No se pudieron eliminar las excepciones: $error';
  }

  @override
  String settings_trackingProtectionExceptionsRemoveFailed(String error) {
    return 'No se pudo quitar la excepción: $error';
  }

  @override
  String get settings_deleteBrowsingDataTileTitle =>
      'Eliminar datos de navegación';

  @override
  String get settings_deleteBrowsingDataTileKeywords => 'borrar datos, limpiar';

  @override
  String get settings_autoClearHistoryTitle =>
      'Borrar el historial automáticamente';

  @override
  String get settings_autoClearHistoryKeywords => 'conservación del historial';

  @override
  String get settings_autoClearHistorySubtitle =>
      'Eliminar automáticamente el historial de navegación anterior al periodo seleccionado';

  @override
  String get settings_autoClearUnassignedTabsTitle =>
      'Cerrar automáticamente las pestañas sin asignar';

  @override
  String get settings_autoClearUnassignedTabsKeywords => 'limpiar pestañas';

  @override
  String get settings_autoClearUnassignedTabsSubtitle =>
      'Cerrar automáticamente las pestañas sin asignar anteriores al periodo seleccionado';

  @override
  String get settings_durationNever => 'Nunca';

  @override
  String get settings_duration1Day => '1 día';

  @override
  String get settings_duration3Days => '3 días';

  @override
  String get settings_duration1Week => '1 semana';

  @override
  String get settings_duration2Weeks => '2 semanas';

  @override
  String get settings_duration1Month => '1 mes';

  @override
  String get settings_duration3Months => '3 meses';

  @override
  String get settings_globalPrivacyControlTitle =>
      'Control Global de Privacidad (GPC)';

  @override
  String get settings_globalPrivacyControlKeywords =>
      'gpc, global privacy control';

  @override
  String get settings_screenshotProtectionTitle =>
      'Protección contra capturas de pantalla';

  @override
  String get settings_screenshotProtectionKeywords =>
      'capturas de pantalla, screenshots';

  @override
  String get settings_screenshotProtectionSubtitle =>
      'Bloquea las capturas y grabaciones de pantalla de esta aplicación en Android.';

  @override
  String get settings_allowPrivateTabScreenshotsTitle =>
      'Permitir capturas de pantalla en pestañas privadas';

  @override
  String get settings_allowPrivateTabScreenshotsKeywords =>
      'capturas de pantalla, incógnito, privada';

  @override
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle =>
      'Anulado por la protección contra capturas de pantalla, que bloquea las capturas en todas las pestañas.';

  @override
  String get settings_allowPrivateTabScreenshotsSubtitle =>
      'Las pestañas privadas se pueden capturar y grabar, y aparecen en la vista previa del selector de aplicaciones.';

  @override
  String get settings_httpsOnlyModeTitle =>
      'Bloquear conexiones HTTP inseguras';

  @override
  String get settings_httpsOnlyModeKeywords => 'solo https, https only';

  @override
  String get settings_httpsOnlyModeDisabledLabel => 'Desactivado';

  @override
  String get settings_httpsOnlyModeEnabledLabel => 'Activado';

  @override
  String get settings_httpsOnlyModePrivateOnlyLabel => 'Solo privado';

  @override
  String get settings_dnsOverHttpsTileTitle => 'DNS sobre HTTPS';

  @override
  String get settings_enhancedTrackingProtectionTitle =>
      'Protección mejorada contra el rastreo';

  @override
  String get settings_enhancedTrackingProtectionKeywords =>
      'etp, estándar, estricta, personalizada, rastreo';

  @override
  String get settings_trackingProtectionDisabledLabel => 'Desactivada';

  @override
  String get settings_trackingProtectionStandardLabel => 'Estándar';

  @override
  String get settings_trackingProtectionStandardSubtitle =>
      'Equilibra la protección y la compatibilidad bloqueando menos categorías de rastreadores.';

  @override
  String get settings_trackingProtectionStrictLabel => 'Estricta';

  @override
  String get settings_trackingProtectionStrictSubtitle =>
      'Bloquea más categorías de rastreadores, incluido el contenido de rastreo, pero puede hacer que fallen algunos sitios.';

  @override
  String get settings_trackingProtectionCustomLabel => 'Personalizada';

  @override
  String get settings_trackingProtectionCustomSubtitle =>
      'Elige qué rastreadores y scripts bloquear.';

  @override
  String get settings_contentBlockingDatabaseTitle =>
      'Base de datos de bloqueo de contenido';

  @override
  String get settings_contentBlockingDatabaseKeywords =>
      'anuncios, rastreadores, bloqueo de contenido';

  @override
  String get settings_contentBlockingDatabaseSubtitle =>
      'Usar las listas de bloqueo de GeckoView para las categorías de la protección mejorada, como anuncios, analíticas y rastreadores sociales. Requiere reiniciar la aplicación.';

  @override
  String get settings_bounceTrackingProtectionTitle =>
      'Protección contra el rastreo por rebote';

  @override
  String get settings_bounceTrackingProtectionKeywords =>
      'rastreadores por redirección, rebote';

  @override
  String get settings_bounceTrackingProtectionSubtitle =>
      'Bloquea los rastreadores por redirección que recopilan datos mediante redirecciones de URL intermedias entre sitios web';

  @override
  String get settings_queryParameterStrippingTitle =>
      'Eliminación de parámetros de consulta';

  @override
  String get settings_queryParameterStrippingKeywords => 'utm, parámetros';

  @override
  String get settings_queryParameterStrippingSubtitle =>
      'Quita los parámetros de rastreo de las URL para evitar el rastreo entre sitios';

  @override
  String get settings_queryParameterStrippingDisabledLabel => 'Desactivado';

  @override
  String get settings_queryParameterStrippingEnabledLabel => 'Activado';

  @override
  String get settings_queryParameterStrippingPrivateOnlyLabel => 'Solo privado';

  @override
  String get settings_uBlockFilterListsTileTitle =>
      'Listas de filtros y refuerzos de uBlock';

  @override
  String get settings_uBlockFilterListsTileKeywords => 'ublock, filtros';

  @override
  String get settings_uBlockFilterListsTileSubtitle =>
      'Gestionar las listas de filtros y aplicar los refuerzos de WebLibre';

  @override
  String get settings_fissionEnabledTitle => 'Fission (aislamiento de sitios)';

  @override
  String get settings_fissionEnabledKeywords =>
      'aislamiento de sitios, site isolation';

  @override
  String get settings_fissionEnabledSubtitle =>
      'Aísla cada sitio en un proceso del sistema operativo independiente para mejorar la seguridad. Requiere reiniciar la aplicación.';

  @override
  String get settings_safeBrowsingMalwareTitle =>
      'Protección contra malware de Safe Browsing';

  @override
  String get settings_safeBrowsingMalwareKeywords =>
      'google safe browsing, malware';

  @override
  String get settings_safeBrowsingMalwareSubtitle =>
      'Avisar de sitios web peligrosos y descargas maliciosas.';

  @override
  String get settings_safeBrowsingPhishingTitle =>
      'Protección contra phishing de Safe Browsing';

  @override
  String get settings_safeBrowsingPhishingKeywords =>
      'google safe browsing, phishing, suplantación';

  @override
  String get settings_safeBrowsingPhishingSubtitle =>
      'Avisar de sitios web y páginas de inicio de sesión engañosos.';

  @override
  String get settings_extensionsWebApiTitle => 'API web de extensiones';

  @override
  String get settings_extensionsWebApiKeywords =>
      'api de extensiones, extension api';

  @override
  String get settings_extensionsWebApiSubtitle =>
      'Exponer la API mozAddonManager al contenido web y a las páginas de extensiones. Requiere reiniciar la aplicación.';

  @override
  String get settings_appOpeningProtectionSectionHeader =>
      'Protección contra la apertura por aplicaciones';

  @override
  String get settings_blockAppsOpeningBrowserTitle =>
      'Impedir que las aplicaciones abran tu navegador';

  @override
  String get settings_blockAppsOpeningBrowserKeywords =>
      'control de intents, aplicaciones externas, intent gatekeeper';

  @override
  String get settings_blockAppsOpeningBrowserSubtitle =>
      'Preguntar antes de abrir enlaces que otras aplicaciones envían a WebLibre.';

  @override
  String get settings_managedAppsSectionHeader => 'Aplicaciones gestionadas';

  @override
  String get settings_managedAppAlwaysAllowedLabel => 'Permitida siempre';

  @override
  String get settings_managedAppAlwaysBlockedLabel => 'Bloqueada siempre';

  @override
  String get settings_managedAppActionAllow => 'Permitir';

  @override
  String get settings_managedAppActionBlock => 'Bloquear';

  @override
  String get settings_browserLanguagesTileTitle => 'Idiomas del navegador';

  @override
  String get settings_browserLanguagesTileSubtitle =>
      'Configurar las preferencias de idioma que se muestran a los sitios web';

  @override
  String get settings_fingerprintProtectionTileTitle =>
      'Protección contra huellas digitales';

  @override
  String get settings_fingerprintProtectionTileSubtitle =>
      'Control detallado de las huellas digitales del navegador';

  @override
  String get settings_resistFingerprintingTileTitle =>
      'Resistencia a huellas digitales';

  @override
  String get settings_resistFingerprintingTileKeywords =>
      'rfp, resist fingerprinting';

  @override
  String get settings_resistFingerprintingTileSubtitle =>
      'Refuerzo avanzado de la protección contra huellas digitales';

  @override
  String get settings_lnaEnabledTitle => 'Acceso a la red local';

  @override
  String get settings_lnaEnabledKeywords => 'lan, red local';

  @override
  String get settings_lnaEnabledSubtitle =>
      'Activar el bloqueo del acceso a la red local y a sus dispositivos';

  @override
  String get settings_lnaBlockingTitle => 'Bloquear solicitudes a la red local';

  @override
  String get settings_lnaBlockingKeywords => 'lan, red local';

  @override
  String get settings_lnaBlockingSubtitle =>
      'Bloquear las solicitudes de las páginas web a direcciones de la red local';

  @override
  String get settings_lnaBlockTrackersTitle =>
      'Bloquear rastreadores en la red local';

  @override
  String get settings_lnaBlockTrackersKeywords => 'lan, red local';

  @override
  String get settings_lnaBlockTrackersSubtitle =>
      'Impedir que los rastreadores accedan a recursos de la red local';

  @override
  String get settings_transferTitle => 'Exportar e importar';

  @override
  String get settings_transferChangeExportFolder =>
      'Cambiar la carpeta de exportación';

  @override
  String get settings_transferIntro =>
      'Mueve los ajustes entre perfiles o dispositivos, o adjúntalos a un informe de error. La exportación solo incluye ajustes: no incluye pestañas, historial, marcadores ni inicios de sesión. Para transferir estos datos, haz una copia de seguridad del perfil completo.';

  @override
  String get settings_transferDeviceOnlyNote =>
      'Las preferencias de búsqueda web, el diseño de inicio y nueva pestaña, el orden del menú y los complementos fijados se quedan en este dispositivo';

  @override
  String get settings_transferExportSectionTitle => 'Exportar';

  @override
  String get settings_transferExportSectionSubtitle =>
      'Exportar las secciones seleccionadas a un archivo legible';

  @override
  String get settings_transferSaveFileButton => 'Guardar archivo';

  @override
  String get settings_transferImportSectionTitle => 'Importar';

  @override
  String get settings_transferImportSectionSubtitle =>
      'Elige qué ajustes aplicar después de abrir el archivo';

  @override
  String get settings_transferOpenFileButton => 'Abrir archivo';

  @override
  String get settings_transferPasteButton => 'Pegar';

  @override
  String settings_transferExportFolderChanged(String name) {
    return 'Las exportaciones se guardarán en $name';
  }

  @override
  String settings_transferSavedAs(String name) {
    return 'Guardado como $name';
  }

  @override
  String get settings_transferExportFolderGone =>
      'La carpeta de exportación ya no existe. Elige otra y vuelve a intentarlo.';

  @override
  String settings_transferSaveFailed(String error) {
    return 'No se pudo guardar la exportación: $error';
  }

  @override
  String get settings_transferCopiedToClipboard =>
      'Ajustes copiados al portapapeles';

  @override
  String settings_transferCopyFailed(String error) {
    return 'No se pudo copiar la exportación: $error';
  }

  @override
  String get settings_transferImportNothingApplicable =>
      'Esta exportación no contiene nada que esta versión de WebLibre pueda aplicar.';

  @override
  String get settings_transferImportedSuccess => 'Ajustes importados';

  @override
  String settings_transferImportFailed(String error) {
    return 'No se pudieron importar los ajustes: $error';
  }

  @override
  String get settings_transferNotASettingsFile =>
      'Ese archivo no es una exportación de ajustes.';

  @override
  String settings_transferReadFileFailed(String error) {
    return 'No se pudo leer el archivo: $error';
  }

  @override
  String get settings_transferClipboardEmpty => 'El portapapeles está vacío.';

  @override
  String settings_transferReadClipboardFailed(String error) {
    return 'No se pudo leer el portapapeles: $error';
  }

  @override
  String get settings_transferSectionAppSettingsTitle =>
      'Ajustes de la aplicación';

  @override
  String settings_transferSectionAppSettingsDescription(String torBrand) {
    return 'Ajustes de apariencia, navegación, pestañas, privacidad, $torBrand y motor web';
  }

  @override
  String get settings_transferSectionGeckoPrefsTitle => 'Preferencias de Gecko';

  @override
  String get settings_transferSectionGeckoPrefsDescription =>
      'Preferencias avanzadas del motor que has cambiado a mano';

  @override
  String get settings_importErrorNotJson => 'No es un archivo JSON.';

  @override
  String get settings_importErrorNotSettingsExport =>
      'No es una exportación de ajustes de WebLibre.';

  @override
  String get settings_importErrorMissingFormatVersion =>
      'La exportación no indica su versión de formato.';

  @override
  String settings_importErrorNewerFormatVersion(int version, int supported) {
    return 'Esta exportación la escribió una versión más reciente de WebLibre (formato $version; esta versión lee hasta el $supported). Actualiza la aplicación y vuelve a intentarlo.';
  }

  @override
  String get settings_importErrorNoSettings =>
      'La exportación no contiene ajustes.';

  @override
  String settings_importErrorMalformedSection(String section) {
    return 'La sección «$section» está mal formada.';
  }

  @override
  String settings_importErrorMalformedField(String field) {
    return 'El campo «$field» de la exportación está mal formado.';
  }

  @override
  String settings_importErrorUnreadablePrefsLine(String section, String line) {
    return 'La sección «$section» tiene una línea que WebLibre no puede leer: «$line». Importarla restablecería las preferencias en lugar de restaurarlas.';
  }

  @override
  String settings_importErrorNotPrefsSnapshot(String section) {
    return 'La sección «$section» no es una instantánea de preferencias de WebLibre.';
  }

  @override
  String settings_importErrorMissingSchemaVersion(String section) {
    return 'La sección «$section» no indica su versión de esquema.';
  }

  @override
  String settings_importErrorUnreadablePref(String section, String pref) {
    return 'La sección «$section» contiene una preferencia que WebLibre no pudo volver a leer: «$pref».';
  }

  @override
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  ) {
    return 'La sección «$section» la escribió una versión más reciente de WebLibre (esquema $version; esta versión lee hasta el $supported). Actualiza la aplicación y vuelve a intentarlo.';
  }

  @override
  String settings_importPartialFailure(String failed, String error) {
    return 'La sección «$failed» se detuvo a medias y puede haberse aplicado solo en parte: $error';
  }

  @override
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  ) {
    return 'Importado: $applied. Después, la sección «$failed» se detuvo a medias y puede haberse aplicado solo en parte: $error';
  }

  @override
  String get settings_webEngineHardeningTitle => 'Refuerzo del motor web';

  @override
  String get settings_webEngineHardeningKeywords =>
      'refuerzo, seguridad, hardening';

  @override
  String get settings_webEngineHardeningSearchHint =>
      'Buscar grupos de refuerzo';

  @override
  String get settings_webEngineHardeningResetAllMenuItem =>
      'Restablecer todas las preferencias';

  @override
  String get settings_webEngineHardeningResetAllDialogTitle =>
      '¿Restablecer todas las preferencias?';

  @override
  String get settings_webEngineHardeningResetAllDialogContent =>
      'Se restablecerán a sus valores predeterminados todas las preferencias del motor web definidas por el usuario.';

  @override
  String get settings_webEngineHardeningOverviewTitle => 'Resumen';

  @override
  String get settings_webEngineHardeningCompleteTitle => 'Refuerzo completo';

  @override
  String get settings_webEngineHardeningCompleteSubtitle =>
      'Aplicar o restablecer todas las preferencias de refuerzo agrupadas';

  @override
  String get settings_webEngineHardeningCompleteToggleHint =>
      'Activar o desactivar a la vez todas las preferencias de refuerzo agrupadas.';

  @override
  String get settings_webEngineHardeningGroupsTitle => 'Grupos de refuerzo';

  @override
  String get settings_webEngineHardeningLoadFailedTitle =>
      'No se pudieron cargar los ajustes de preferencias';

  @override
  String get settings_webEngineHardeningGroupSearchHint =>
      'Buscar ajustes de refuerzo';

  @override
  String get settings_webEngineHardeningGroupControlsTitle =>
      'Controles del grupo';

  @override
  String get settings_webEngineHardeningPreferenceSettingsTitle =>
      'Ajustes de preferencias';

  @override
  String get settings_webEngineHardeningOptionalBadge => 'Opcional';

  @override
  String get settings_settingsHomeTitle => 'Ajustes';

  @override
  String get settings_settingsHomeSearchHint => 'Buscar en todos los ajustes';

  @override
  String get settings_searchTitle => 'Búsqueda';

  @override
  String get settings_searchSubtitle =>
      'Proveedores, bangs, sugerencias del historial y búsqueda en el dispositivo.';

  @override
  String get settings_defaultSearchProviderTitle =>
      'Proveedor de búsqueda predeterminado';

  @override
  String get settings_defaultSearchProviderKeywords =>
      'motor de búsqueda, buscador';

  @override
  String get settings_defaultAutocompleteProviderTitle =>
      'Proveedor de autocompletado predeterminado';

  @override
  String get settings_defaultAutocompleteProviderKeywords =>
      'sugerencias, autocompletar';

  @override
  String get settings_customSearchEnginesTitle =>
      'Motores de búsqueda personalizados';

  @override
  String get settings_customSearchEnginesKeywords =>
      'bangs propios, proveedores';

  @override
  String get settings_customSearchEnginesSubtitle =>
      'Añadir y gestionar tus propios proveedores de búsqueda';

  @override
  String get settings_bangSettingsListTitle => 'Ajustes de bangs';

  @override
  String get settings_bangSettingsListSubtitle =>
      'Gestionar los repositorios de bangs y los datos de uso';

  @override
  String get settings_searchHistoryLimitTitle =>
      'Límite del historial de búsqueda';

  @override
  String get settings_searchHistoryLimitKeywords => 'historial, entradas';

  @override
  String get settings_searchHistoryLimitSubtitle =>
      'Número máximo de búsquedas recientes que se recuerdan';

  @override
  String get settings_searchHistoryLimitSuffix => 'entradas';

  @override
  String get settings_validationEnterValue => 'Introduce un valor';

  @override
  String get settings_validationEnterValidNumber =>
      'Introduce un número válido';

  @override
  String get settings_validationValueBetween0And100 =>
      'El valor debe estar entre 0 y 100';

  @override
  String get settings_allowClipboardAccessTitle =>
      'Permitir el acceso al portapapeles para sugerencias';

  @override
  String get settings_allowClipboardAccessKeywords => 'portapapeles';

  @override
  String get settings_allowClipboardAccessSubtitle =>
      'El navegador puede leer el portapapeles para sugerir URL';

  @override
  String get settings_historySuggestionsTitle => 'Sugerir desde el historial';

  @override
  String get settings_historySuggestionsKeywords =>
      'sugerencias del historial, páginas visitadas, autocompletar, texto fantasma, privacidad';

  @override
  String get settings_historySuggestionsSubtitle =>
      'Mostrar páginas visitadas y completar direcciones a partir de tu historial mientras escribes. Desactivarlo no borra tu historial.';

  @override
  String get settings_privateSearchSuggestionsTitle =>
      'Sugerencias en pestañas privadas';

  @override
  String get settings_privateSearchSuggestionsKeywords =>
      'privada, incógnito, sugerencias de búsqueda, historial, privacidad';

  @override
  String get settings_privateSearchSuggestionsSubtitle =>
      'Usar el proveedor de sugerencias y tu historial al escribir en una pestaña privada. Lo que escribas se envía al proveedor.';

  @override
  String get settings_acceptSuggestionOnSubmitTitle =>
      'Autocompletar al pulsar Intro';

  @override
  String get settings_acceptSuggestionOnSubmitKeywords =>
      'enviar, teclado, sugerencias, enter';

  @override
  String get settings_acceptSuggestionOnSubmitSubtitle =>
      'Aceptar la sugerencia en línea al pulsar Intro en el teclado';

  @override
  String get settings_popularSitesAutocompleteTitle =>
      'Sugerencias de sitios populares';

  @override
  String get settings_popularSitesAutocompleteKeywords =>
      'sitios populares, dominios, texto fantasma, autocompletar';

  @override
  String get settings_popularSitesAutocompleteSubtitle =>
      'Completar el texto escrito con dominios conocidos cuando no haya coincidencias en tu historial ni en tus marcadores';

  @override
  String get settings_localIndexEnabledTitle =>
      'Activar el índice de búsqueda local';

  @override
  String get settings_localIndexEnabledKeywords =>
      'texto de la página, historial';

  @override
  String get settings_localIndexEnabledSubtitle =>
      'Indexar localmente las páginas visitadas para que el navegador pueda buscar en su contenido. Los metadatos de las visitas se quedan en el motor; en el dispositivo solo se guarda el texto de las páginas.';

  @override
  String get settings_indexPrivateTabsTitle => 'Indexar pestañas privadas';

  @override
  String get settings_indexPrivateTabsKeywords => 'incógnito, privadas';

  @override
  String get settings_indexPrivateTabsSubtitle =>
      'Incluir en el índice local las páginas abiertas en pestañas privadas. Desactivado de forma predeterminada.';

  @override
  String get settings_clearLocalIndexDialogTitle =>
      '¿Borrar el índice de búsqueda local?';

  @override
  String get settings_clearLocalIndexDialogContent =>
      'Se eliminará todo el contenido de páginas indexado localmente. El historial del motor (metadatos de las visitas) no se ve afectado.';

  @override
  String get settings_localIndexStatsTitle => 'Páginas indexadas';

  @override
  String get settings_localIndexStatsKeywords => 'borrar índice, estadísticas';

  @override
  String settings_localIndexPagesIndexed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas indexadas',
      one: '1 página indexada',
    );
    return '$_temp0';
  }

  @override
  String get settings_searchSectionProvidersTitle => 'Proveedores';

  @override
  String get settings_searchSectionProvidersKeywords => 'motores, buscadores';

  @override
  String get settings_searchSectionBangShortcutsTitle => 'Atajos bang';

  @override
  String get settings_searchSectionBangShortcutsKeywords => 'bangs, atajos';

  @override
  String get settings_searchSectionHistorySuggestionsTitle =>
      'Historial y sugerencias';

  @override
  String get settings_searchSectionLocalIndexTitle =>
      'Índice de búsqueda local';

  @override
  String get settings_searchSectionLocalIndexKeywords =>
      'búsqueda en el dispositivo, índice';

  @override
  String get settings_indexDefaultSearchProviderSubtitle =>
      'Elegir el motor predeterminado para las búsquedas';

  @override
  String get settings_indexDefaultAutocompleteProviderSubtitle =>
      'Elegir el proveedor de las sugerencias de búsqueda';

  @override
  String get settings_indexAcceptSuggestionOnSubmitSubtitle =>
      'Aceptar la sugerencia en línea al pulsar Intro';

  @override
  String get settings_indexHistorySuggestionsSubtitle =>
      'Sugerir páginas visitadas mientras escribes';

  @override
  String get settings_indexPrivateSearchSuggestionsSubtitle =>
      'Usar sugerencias e historial en pestañas privadas';

  @override
  String get settings_indexPopularSitesAutocompleteSubtitle =>
      'Completar el texto escrito con dominios conocidos';

  @override
  String get settings_indexLocalIndexEnabledSubtitle =>
      'Indexar localmente las páginas visitadas para buscar en su contenido';

  @override
  String get settings_indexIndexPrivateTabsSubtitle =>
      'Incluir las pestañas privadas en el índice local';

  @override
  String get settings_indexLocalIndexStatsSubtitle =>
      'Ver y borrar el índice local';

  @override
  String get settings_webContentTitle => 'Contenido web';

  @override
  String get settings_webContentSubtitle =>
      'Representación del texto, vista de lectura, PDF y funciones de IA locales.';

  @override
  String get settings_webFontsTitle => 'Fuentes web';

  @override
  String get settings_webFontsKeywords => 'fuentes, tipografías';

  @override
  String get settings_webFontsSubtitle =>
      'Permitir que los sitios web usen fuentes personalizadas';

  @override
  String get settings_automaticFontSizeTitle => 'Tamaño de letra automático';

  @override
  String get settings_automaticFontSizeKeywords => 'tamaño del texto';

  @override
  String get settings_automaticFontSizeSubtitle =>
      'Ajustar automáticamente el tamaño de letra según los ajustes del sistema. Desactívalo para controlar manualmente el factor de tamaño de letra y la ampliación de texto.';

  @override
  String get settings_fontSizeFactorTitle => 'Factor de tamaño de letra';

  @override
  String get settings_fontSizeFactorKeywords => 'zoom, texto';

  @override
  String get settings_fontSizeFactorSubtitle =>
      'Escalar el tamaño del texto de las páginas web';

  @override
  String get settings_disabledWhileAutomaticFontSize =>
      'Desactivado mientras el tamaño de letra automático esté activado';

  @override
  String get settings_fontInflationTitle => 'Ampliación de texto';

  @override
  String get settings_fontInflationKeywords => 'legibilidad';

  @override
  String get settings_fontInflationSubtitle =>
      'Ampliar el texto de las páginas que no tienen una etiqueta meta viewport para móviles';

  @override
  String get settings_inputAutoZoomTitle =>
      'Zoom automático en campos de texto';

  @override
  String get settings_inputAutoZoomKeywords => 'formularios';

  @override
  String get settings_inputAutoZoomSubtitle =>
      'Ampliar automáticamente al enfocar campos de texto';

  @override
  String get settings_forceUserScalableTitle => 'Zoom en todos los sitios web';

  @override
  String get settings_forceUserScalableKeywords =>
      'pellizcar, accesibilidad, zoom';

  @override
  String get settings_forceUserScalableSubtitle =>
      'Permitir pellizcar para hacer zoom, incluso en sitios web que impiden este gesto';

  @override
  String get settings_pdfViewerTitle => 'Visor de PDF integrado';

  @override
  String get settings_pdfViewerKeywords => 'pdf';

  @override
  String get settings_pdfViewerSubtitle =>
      'Abrir los archivos PDF directamente en el navegador sin descargarlos';

  @override
  String get settings_enableReaderModeTitle => 'Activar la vista de lectura';

  @override
  String get settings_enableReaderModeKeywords =>
      'lectura, legibilidad, reader';

  @override
  String get settings_enableReaderModeSubtitle =>
      'Añade a la barra del navegador una herramienta opcional que simplifica las páginas web quitando anuncios, barras laterales y otros elementos no esenciales.';

  @override
  String get settings_enforceReaderModeTitle => 'Forzar la vista de lectura';

  @override
  String get settings_enforceReaderModeKeywords => 'lectura, reader';

  @override
  String get settings_enforceReaderModeSubtitle =>
      'Ignorar la puntuación de legibilidad del sitio y mostrar siempre la vista de lectura, incluso en sitios que quizá no la admitan.';

  @override
  String get settings_onDeviceAiTitle => 'IA en el dispositivo';

  @override
  String get settings_onDeviceAiKeywords => 'ia local, sugerencias, ai';

  @override
  String get settings_onDeviceAiSubtitle =>
      'Funciones en el dispositivo, como sugerir contenedores para tus pestañas abiertas y nombres para ellos';

  @override
  String get settings_webContentSectionDisplayTitle => 'Visualización';

  @override
  String get settings_webContentSectionContentFeaturesTitle =>
      'Funciones de contenido';

  @override
  String get settings_indexAutomaticFontSizeSubtitle =>
      'Ajustar el tamaño de letra según los ajustes del sistema';

  @override
  String get settings_indexFontInflationSubtitle =>
      'Ampliar el texto de las páginas sin viewport para móviles';

  @override
  String get settings_indexInputAutoZoomSubtitle =>
      'Ampliar automáticamente al enfocar campos de texto';

  @override
  String get settings_indexPdfViewerSubtitle =>
      'Abrir los archivos PDF directamente en el navegador';

  @override
  String get settings_indexEnableReaderModeSubtitle =>
      'Extraer y simplificar las páginas para facilitar la lectura';

  @override
  String get settings_indexEnforceReaderModeSubtitle =>
      'Mostrar siempre las funciones de la vista de lectura';

  @override
  String get settings_indexOnDeviceAiSubtitle =>
      'Funciones de IA locales, como sugerencias de temas y de pestañas';

  @override
  String get settings_ublockListsTitle => 'Listas de filtros de uBlock';

  @override
  String get settings_ublockListsSearchHint =>
      'Buscar listas, grupos y URL externas';

  @override
  String get settings_ublockSectionManagement => 'Gestión';

  @override
  String get settings_ublockSectionQuickActions => 'Acciones rápidas';

  @override
  String get settings_ublockSectionFilterLists => 'Listas de filtros';

  @override
  String get settings_ublockSectionExternalLists => 'Listas externas';

  @override
  String get settings_actionApply => 'Aplicar';

  @override
  String get settings_ublockResetDialogTitle =>
      '¿Restablecer los valores predeterminados?';

  @override
  String get settings_ublockResetDialogMessage =>
      'Se restaurará la configuración predeterminada de listas de filtros de uBlock Origin y se quitarán las listas externas que hayas añadido.';

  @override
  String get settings_ublockApplyHardeningsDialogTitle =>
      '¿Aplicar los refuerzos de WebLibre?';

  @override
  String get settings_ublockApplyHardeningsDialogMessage =>
      'Se activará una selección de listas de filtros adicionales y se añadirá como lista externa una lista de acortadores de URL legítimos.';

  @override
  String get settings_ublockInfoBannerMessage =>
      'Los cambios en las listas de filtros de uBlock Origin requieren reiniciar la aplicación para aplicarse. Debido a la caché, algunos cambios pueden necesitar unos minutos y otro reinicio para aplicarse por completo.';

  @override
  String settings_ublockLoadFailed(String error) {
    return 'No se pudieron cargar los recursos de las listas de filtros: $error';
  }

  @override
  String get settings_ublockQuickResetTitle =>
      'Restablecer valores predeterminados';

  @override
  String get settings_ublockQuickResetSubtitle =>
      'Restaurar la configuración predeterminada de listas de filtros de uBlock Origin.';

  @override
  String get settings_ublockQuickApplyHardeningsTitle =>
      'Aplicar los refuerzos de WebLibre';

  @override
  String get settings_ublockQuickApplyHardeningsSubtitle =>
      'Activar una selección de listas de filtros adicionales.';

  @override
  String get settings_ublockManageTitle => 'Gestionar con WebLibre';

  @override
  String get settings_ublockManageSubtitle =>
      'WebLibre controla las listas de filtros activadas de uBlock Origin en el siguiente inicio del navegador.';

  @override
  String get settings_ublockManageHint =>
      'Al activar la gestión se parte de las listas básicas comunes de uBO y se conservan «Mis filtros».';

  @override
  String get settings_ublockAutoSelectTitle =>
      'Seleccionar idiomas automáticamente';

  @override
  String get settings_ublockAutoSelectSubtitle =>
      'Activar las listas de filtros regionales que coincidan con los idiomas del dispositivo.';

  @override
  String get settings_ublockAutoSelectedTooltip =>
      'Seleccionada automáticamente para tu idioma';

  @override
  String get settings_ublockDefaultOnTooltip =>
      'Activada de forma predeterminada';

  @override
  String get settings_ublockVisitSupportTooltip =>
      'Visitar la página de asistencia';

  @override
  String get settings_ublockExternalListsHint =>
      'Las URL sin procesar se envían a uBlock Origin como listas externas. Las descripciones solo se muestran aquí, en WebLibre.';

  @override
  String get settings_ublockNoExternalLists =>
      'No hay listas externas configuradas.';

  @override
  String settings_ublockNoExternalListsMatch(String query) {
    return 'Ninguna lista externa coincide con «$query».';
  }

  @override
  String get settings_ublockAddExternalListButton => 'Añadir lista externa';

  @override
  String get settings_ublockEditListDialogTitle =>
      'Editar lista de filtros externa';

  @override
  String get settings_ublockAddListDialogTitle =>
      'Añadir lista de filtros externa';

  @override
  String get settings_ublockListUrlLabel => 'URL de la lista';

  @override
  String get settings_ublockListUrlAlreadyAdded => 'Ya añadida';

  @override
  String get settings_ublockDescriptionLabel => 'Descripción (opcional)';

  @override
  String get settings_ublockDescriptionHint => 'p. ej., Molestias — miAutor';

  @override
  String get settings_ublockGroupDefault => 'Predeterminadas';

  @override
  String get settings_ublockGroupAds => 'Anuncios';

  @override
  String get settings_ublockGroupPrivacy => 'Privacidad';

  @override
  String get settings_ublockGroupMalware => 'Malware';

  @override
  String get settings_ublockGroupAnnoyances => 'Molestias';

  @override
  String get settings_ublockGroupMultipurpose => 'Multipropósito';

  @override
  String get settings_ublockGroupRegions => 'Regiones';

  @override
  String get settings_categoryGeneralTitle => 'General';

  @override
  String get settings_categoryGeneralKeywords =>
      'tema, zoom de la interfaz, navegador predeterminado';

  @override
  String get settings_categoryGeneralSubtitle => 'Apariencia, descargas';

  @override
  String get settings_categoryBrowsingTitle => 'Navegación';

  @override
  String get settings_categoryBrowsingKeywords =>
      'pestañas, small web, limpiador de url, expansor de enlaces';

  @override
  String get settings_categoryBrowsingSubtitle =>
      'Pestañas, navegación, enlaces externos';

  @override
  String get settings_categoryHomeNewTabTitle => 'Inicio y nueva pestaña';

  @override
  String get settings_categoryHomeNewTabKeywords =>
      'inicio, nueva pestaña, página de inicio, secciones, accesos directos, sitios frecuentes, cita, fondo de pantalla, fondo';

  @override
  String get settings_categoryHomeNewTabSubtitle =>
      'Qué muestran la página de inicio y la de nueva pestaña';

  @override
  String get settings_categoryGesturesTitle => 'Gestos';

  @override
  String get settings_categoryGesturesKeywords =>
      'gesto, deslizar, trazo, barra de pestañas, mantener pulsado, pellizcar';

  @override
  String get settings_categoryGesturesSubtitle =>
      'Deslizamientos en la barra de pestañas y las pestañas, gestos dibujados';

  @override
  String get settings_categoryKeyboardShortcutsTitle => 'Atajos de teclado';

  @override
  String get settings_categoryKeyboardShortcutsKeywords =>
      'teclado, atajo, tecla rápida, combinación de teclas, hotkey';

  @override
  String get settings_categoryKeyboardShortcutsSubtitle =>
      'Teclas del teclado físico para acciones del navegador';

  @override
  String get settings_categoryToolbarLayoutTitle =>
      'Barra de herramientas y diseño';

  @override
  String get settings_categoryToolbarLayoutKeywords =>
      'barra de herramientas contextual, selector rápido de pestañas';

  @override
  String get settings_categoryToolbarLayoutSubtitle =>
      'Barra de pestañas, barra de herramientas, selector rápido, vista de pestañas';

  @override
  String get settings_categoryWebContentTitle => 'Contenido web';

  @override
  String get settings_categoryWebContentKeywords =>
      'vista de lectura, pdf, fuentes';

  @override
  String get settings_categoryWebContentSubtitle =>
      'Visualización de páginas, PDF, vista de lectura, IA';

  @override
  String get settings_categoryNotificationsTitle => 'Notificaciones';

  @override
  String get settings_categoryNotificationsKeywords =>
      'push, unifiedpush, ntfy, distribuidor';

  @override
  String get settings_categoryNotificationsSubtitle =>
      'Entrega de web push, distribuidor, suscripciones de sitios';

  @override
  String get settings_categorySearchTitle => 'Búsqueda';

  @override
  String get settings_categorySearchKeywords =>
      'bangs, sugerencias, índice de búsqueda local';

  @override
  String get settings_categorySearchSubtitle =>
      'Proveedores, bangs, historial de búsqueda';

  @override
  String get settings_categoryPrivacySecurityTitle => 'Privacidad y seguridad';

  @override
  String get settings_categoryPrivacySecurityKeywords =>
      'huellas digitales, https, doh, safe browsing, protección de la red';

  @override
  String get settings_categoryPrivacySecuritySubtitle =>
      'Protección contra el rastreo, borrado de datos';

  @override
  String get settings_categoryProxyTitle => 'Proxy';

  @override
  String get settings_categoryProxyKeywords =>
      'proxy, sing-box, socks, vpn, wireguard, enrutamiento, tor, contenedor';

  @override
  String get settings_categoryProxySubtitle => 'Conexiones y enrutamiento';

  @override
  String get settings_categoryExtensionsTitle => 'Extensiones';

  @override
  String get settings_categoryExtensionsKeywords =>
      'complementos, extensiones sin firmar, addons';

  @override
  String get settings_categoryExtensionsSubtitle =>
      'Instalar y gestionar orígenes de extensiones';

  @override
  String get settings_categoryAccountTitle => 'Cuenta de WebLibre';

  @override
  String get settings_categoryAccountKeywords => 'cuenta, suscripción';

  @override
  String get settings_categoryAccountSubtitle =>
      'Inicio de sesión, sincronización de ajustes';

  @override
  String get settings_categorySyncTitle => 'Firefox Sync';

  @override
  String get settings_categorySyncKeywords =>
      'emparejar, nombre del dispositivo, motores, sincronizar';

  @override
  String get settings_categorySyncSubtitle =>
      'Cuenta, sincronizar ahora, selección de datos';

  @override
  String get settings_categoryAdvancedTitle => 'Avanzado';

  @override
  String get settings_categoryAdvancedKeywords =>
      'experimental, registros de errores, javascript';

  @override
  String get settings_categoryAdvancedSubtitle =>
      'JavaScript, user agent, depuración';

  @override
  String get settings_categoryGroupBrowserTitle => 'Navegador';

  @override
  String get settings_categoryGroupServicesAdvancedTitle =>
      'Servicios y avanzado';

  @override
  String get settings_privacySectionTrackingProtectionTitle =>
      'Protección contra el rastreo';

  @override
  String get settings_privacySectionTrackingProtectionKeywords =>
      'privacidad, rastreo';

  @override
  String get settings_indexEnhancedTrackingProtectionSubtitle =>
      'Elegir con qué intensidad se bloquean los rastreadores';

  @override
  String get settings_indexContentBlockingDatabaseSubtitle =>
      'Usar las listas de bloqueo de GeckoView para las categorías de la protección mejorada';

  @override
  String get settings_indexBounceTrackingProtectionSubtitle =>
      'Quitar el estado de rastreo que dejan los rastreadores por redirección';

  @override
  String get settings_indexQueryParameterStrippingSubtitle =>
      'Quitar los parámetros de rastreo de las URL';

  @override
  String get settings_privacySectionFingerprintingTitle => 'Huellas digitales';

  @override
  String get settings_indexBrowserLanguagesSubtitle =>
      'Elegir qué idiomas pueden ver los sitios web';

  @override
  String get settings_privacySectionConnectionSecurityTitle =>
      'Seguridad de la conexión';

  @override
  String get settings_indexHttpsOnlyModeSubtitle =>
      'Preferir HTTPS y bloquear las conexiones inseguras';

  @override
  String get settings_indexDnsOverHttpsTitle => 'DNS sobre HTTPS';

  @override
  String get settings_indexDnsOverHttpsKeywords => 'doh';

  @override
  String get settings_indexDnsOverHttpsSubtitle => 'Cifrar las consultas DNS';

  @override
  String get settings_privacySectionNetworkProtectionTitle =>
      'Protección de la red';

  @override
  String get settings_indexLnaBlockingSubtitle =>
      'Bloquear las solicitudes a dispositivos y servicios de la red local';

  @override
  String get settings_indexLnaBlockTrackersSubtitle =>
      'Bloquear las solicitudes a la red local que parezcan de rastreo';

  @override
  String get settings_privacySectionSignalsModesTitle =>
      'Señales y modos de privacidad';

  @override
  String get settings_indexScreenshotProtectionSubtitle =>
      'Evitar que el contenido de la aplicación aparezca en capturas de pantalla';

  @override
  String get settings_indexAllowPrivateTabScreenshotsSubtitle =>
      'Permitir que el sistema capture las pestañas privadas';

  @override
  String get settings_indexGlobalPrivacyControlSubtitle =>
      'Enviar a los sitios web una señal de preferencia de privacidad';

  @override
  String get settings_privacySectionAppOpeningProtectionTitle =>
      'Protección contra la apertura por aplicaciones';

  @override
  String get settings_indexAppOpeningProtectionSubtitle =>
      'Controlar qué aplicaciones pueden abrir WebLibre directamente';

  @override
  String get settings_privacySectionDataManagementTitle => 'Gestión de datos';

  @override
  String get settings_indexDeleteBrowsingDataSubtitle =>
      'Borrar el historial, las cookies y otros datos de navegación';

  @override
  String get settings_indexAutoClearHistorySubtitle =>
      'Borrar automáticamente el historial tras el periodo elegido';

  @override
  String get settings_indexAutoClearUnassignedTabsSubtitle =>
      'Cerrar automáticamente las pestañas no asignadas a un contenedor';

  @override
  String get settings_privacySectionSafeBrowsingTitle => 'Google Safe Browsing';

  @override
  String get settings_indexSafeBrowsingMalwareSubtitle =>
      'Avisar de malware y descargas dañinas';

  @override
  String get settings_indexSafeBrowsingPhishingSubtitle =>
      'Avisar de sitios web y páginas de inicio de sesión engañosos';

  @override
  String get settings_privacySectionAdvancedSecurityTitle =>
      'Seguridad avanzada';

  @override
  String get settings_indexWebEngineHardeningSubtitle =>
      'Reforzar el comportamiento y los valores predeterminados del motor del navegador';

  @override
  String get settings_indexFissionEnabledSubtitle =>
      'Usar un aislamiento más estricto entre orígenes';

  @override
  String get settings_indexExtensionsWebAPIEnabledSubtitle =>
      'Permitir que las extensiones expongan API web a las páginas';

  @override
  String get settings_proxySectionTitle => 'Proxy';

  @override
  String get settings_indexProxyLogsSubtitle =>
      'Leer el registro del proxy y ajustar cuánto registra';

  @override
  String get settings_saveAndUse => 'Guardar y usar';

  @override
  String get settings_replace => 'Reemplazar';

  @override
  String get settings_later => 'Más tarde';

  @override
  String get settings_restartNow => 'Reiniciar ahora';

  @override
  String get settings_sync => 'Sincronizar';

  @override
  String get settings_chooseSearchProvider => 'Elige un proveedor de búsqueda';

  @override
  String get settings_entriesLabel => 'Entradas';

  @override
  String get settings_lastSyncLabel => 'Última sincronización';

  @override
  String get settings_notAvailable => 'N/D';

  @override
  String get settings_protectionLevelTitle => 'Nivel de protección';

  @override
  String get settings_protectionLevelDescription =>
      'DNS (sistema de nombres de dominio) sobre HTTPS envía las solicitudes de nombres de dominio a través de una conexión cifrada, lo que las protege y hace más difícil que otros vean qué sitios web vas a visitar.';

  @override
  String get settings_defaultProtectionTitle => 'Protección predeterminada';

  @override
  String get settings_defaultProtectionSubtitle =>
      'DoH solo se usa cuando falla el DNS predeterminado';

  @override
  String get settings_increasedProtectionTitle => 'Protección aumentada';

  @override
  String get settings_increasedProtectionSubtitle =>
      'Se prefiere DoH, con el DNS predeterminado como alternativa';

  @override
  String get settings_maxProtectionTitle => 'Protección máxima';

  @override
  String get settings_maxProtectionSubtitle => 'Solo DoH, sin alternativa';

  @override
  String get settings_protectionOffTitle => 'Desactivada';

  @override
  String get settings_protectionOffSubtitle =>
      'Usar tu resolvedor DNS predeterminado';

  @override
  String get settings_dohProviderTitle => 'Proveedor de DoH';

  @override
  String get settings_yourResolvers => 'Tus resolvedores';

  @override
  String get settings_addCustomResolver => 'Añadir resolvedor personalizado';

  @override
  String get settings_editCustomResolverTitle =>
      'Editar resolvedor personalizado';

  @override
  String get settings_resolverUrlLabel => 'URL del resolvedor';

  @override
  String get settings_alreadyBuiltInProvider =>
      'Ya está disponible como proveedor integrado';

  @override
  String get settings_alreadyAdded => 'Ya añadido';

  @override
  String get settings_resolverNameLabel => 'Nombre (opcional)';

  @override
  String get settings_resolverNameHint =>
      'p. ej., dnsforge (bloqueo de anuncios)';

  @override
  String get settings_searchHint => 'Buscar en los ajustes';

  @override
  String get settings_noSettingsAvailable => 'No hay ajustes disponibles.';

  @override
  String settings_noSettingsMatch(String query) {
    return 'Ningún ajuste coincide con «$query».';
  }

  @override
  String get settings_stringListEditorEmpty => 'Aún no se ha añadido nada.';

  @override
  String get settings_customizeMenu => 'Personalizar menú';

  @override
  String get settings_customizeMenuKeywords => 'secciones, filas, reordenar';

  @override
  String get settings_customizeMenuSubtitle =>
      'Elegir y ordenar las secciones y filas del menú de tres puntos';

  @override
  String get settings_tabBarPositionTitle => 'Posición de la barra de pestañas';

  @override
  String get settings_tabBarPositionKeywords => 'arriba, abajo, lateral';

  @override
  String settings_currentlyResolvesTo(String text, String value) {
    return '$text (actualmente: $value)';
  }

  @override
  String get settings_tabBarPositionAutoLabel => 'Automática';

  @override
  String get settings_tabBarPositionTopLabel => 'Arriba';

  @override
  String get settings_tabBarPositionBottomLabel => 'Abajo';

  @override
  String get settings_tabBarPositionLeftLabel => 'Izquierda';

  @override
  String get settings_tabBarPositionRightLabel => 'Derecha';

  @override
  String get settings_tabBarPositionAutoDescription =>
      'Una barra lateral en pantallas grandes y una barra inferior en teléfonos';

  @override
  String get settings_tabBarPositionTopDescription =>
      'Barra de pestañas fija, sin ocultación automática';

  @override
  String get settings_tabBarPositionBottomDescription =>
      'Barra de pestañas con ocultación automática';

  @override
  String get settings_tabBarPositionLeftDescription =>
      'Barra lateral vertical; desliza para ocultarla';

  @override
  String get settings_tabBarPositionRightDescription =>
      'Barra lateral vertical; desliza para ocultarla';

  @override
  String get settings_tabBarStyleTitle => 'Estilo de la barra de pestañas';

  @override
  String get settings_tabBarStyleKeywords => 'diseño, compacto';

  @override
  String get settings_withTitleOption => 'Con título';

  @override
  String get settings_withTitleDescription =>
      'Muestra el título de la página y la ruta de la URL';

  @override
  String get settings_compactOption => 'Compacto';

  @override
  String get settings_compactDescription =>
      'URL centrada en una cápsula, sin el título de la página';

  @override
  String get settings_showContextualToolbarTitle =>
      'Mostrar la barra de herramientas contextual';

  @override
  String get settings_showContextualToolbarKeywords =>
      'barra de herramientas inferior';

  @override
  String get settings_showContextualToolbarSubtitle =>
      'Mostrar una barra de herramientas inferior adicional para navegación y acciones';

  @override
  String get settings_customizeToolbarButtons =>
      'Personalizar los botones de la barra de herramientas';

  @override
  String get settings_customizeToolbarButtonsKeywords => 'botones';

  @override
  String get settings_customizeSwitcherButtons =>
      'Personalizar los botones del selector';

  @override
  String get settings_customizeSwitcherButtonsKeywords =>
      'botones, nueva pestaña, acciones, al final';

  @override
  String get settings_customizeSwitcherButtonsSubtitle =>
      'Botones de acción fijados al final de la barra del selector (independientes de la barra de herramientas contextual)';

  @override
  String get settings_tabStackingTitle => 'Agrupación de pestañas';

  @override
  String get settings_tabStackingKeywords =>
      'pestañas recientes, usadas recientemente, pestañas del contenedor, acordeón, dos niveles, filas, agrupación, grupos de pestañas, pilas de pestañas, árbol de pestañas, tab groups, desactivado';

  @override
  String get settings_tabStackingSubtitle =>
      'Cómo organiza sus pestañas la barra del selector rápido';

  @override
  String get settings_recentlyUsedTabsOption => 'Usadas recientemente';

  @override
  String get settings_recentlyUsedTabsDescription =>
      'Pestañas usadas recientemente de todos los contenedores';

  @override
  String get settings_containerTabsOption => 'Pestañas del contenedor';

  @override
  String get settings_containerTabsDescription =>
      'Pestañas ordenadas del contenedor seleccionado';

  @override
  String get settings_accordionOption => 'Acordeón';

  @override
  String get settings_accordionDescription =>
      'Todos los contenedores como chips, con las pestañas del contenedor seleccionado desplegadas en línea';

  @override
  String get settings_twoRowsOption => 'Dos filas';

  @override
  String get settings_twoRowsDescription =>
      'Pestañas del contenedor seleccionado arriba y pestañas usadas recientemente abajo';

  @override
  String get settings_tabGroupsOption => 'Grupos de pestañas';

  @override
  String get settings_tabGroupsDescription =>
      'Un chip por pestaña junto con las pestañas abiertas desde ella; arriba, las pestañas del grupo actual';

  @override
  String get settings_tabStackingFallbackAccordion =>
      'Necesita más espacio del que tienen esta ventana o el panel lateral, así que por ahora se muestra Acordeón';

  @override
  String get settings_tabStackingFallbackContainerTabs =>
      'Necesita más espacio del que tienen esta ventana o el panel lateral, así que por ahora se muestra Pestañas del contenedor';

  @override
  String get settings_disabledOption => 'Desactivado';

  @override
  String get settings_disabledDescription =>
      'Ocultar la barra del selector rápido de pestañas';

  @override
  String get settings_closeButtonsTitle =>
      'Botones de cerrar en los chips de pestañas';

  @override
  String get settings_closeButtonsKeywords => 'cerrar, botón x, pestaña activa';

  @override
  String get settings_closeButtonsSubtitle =>
      'Qué chips del selector muestran un botón de cerrar';

  @override
  String get settings_activeTabOnlyOption => 'Solo la pestaña activa';

  @override
  String get settings_activeTabOnlyDescription =>
      'Solo el chip de la pestaña abierta';

  @override
  String get settings_allTabsOption => 'Todas las pestañas';

  @override
  String get settings_allTabsDescription => 'Todos los chips de la barra';

  @override
  String get settings_neverOption => 'Nunca';

  @override
  String get settings_neverCloseDescription =>
      'Sin botones de cerrar; cierra las pestañas desde el menú de mantener pulsado o deslizando la barra';

  @override
  String get settings_titleWidthTitle =>
      'Ancho del título en el selector rápido';

  @override
  String get settings_titleWidthKeywords => 'ancho, título, chip, longitud';

  @override
  String get settings_titleWidthSubtitle =>
      'Ancho máximo de los títulos de pestaña en los chips del selector';

  @override
  String get settings_historyFallbackTitle =>
      'Historial como alternativa en el selector rápido';

  @override
  String get settings_historyFallbackKeywords => 'sugerencias, historial';

  @override
  String get settings_historyFallbackSubtitle =>
      'Usar sugerencias del historial de navegación cuando no hay chips de pestañas disponibles';

  @override
  String get settings_showTitlesTitle =>
      'Mostrar títulos en el selector rápido';

  @override
  String get settings_showTitlesKeywords => 'títulos de página';

  @override
  String get settings_showTitlesSubtitle =>
      'Mostrar los títulos de las pestañas junto a los iconos en la barra del selector rápido';

  @override
  String get settings_hierarchyDepthTitle =>
      'Profundidad de jerarquía en el selector rápido';

  @override
  String get settings_hierarchyDepthKeywords =>
      'jerarquía, anidamiento, profundidad, árbol, flechas';

  @override
  String get settings_hierarchyDepthSubtitle =>
      'Cuántas flechas de anidamiento se muestran en los chips del selector antes de agruparse en un contador (0 oculta el indicador)';

  @override
  String settings_hierarchyGlyphsLabel(int glyphs) {
    String _temp0 = intl.Intl.pluralLogic(
      glyphs,
      locale: localeName,
      other: '$glyphs niveles',
      one: '1 nivel',
      zero: 'Desactivado',
    );
    return '$_temp0';
  }

  @override
  String get settings_autoHideTabBarTitle =>
      'Ocultar la barra de pestañas automáticamente';

  @override
  String get settings_autoHideTabBarKeywords => 'desplazamiento, scroll';

  @override
  String get settings_autoHideTabBarSubtitle =>
      'Ocultar la barra de pestañas al desplazarse';

  @override
  String get settings_autoHideSidePanelTitle =>
      'Ocultar el panel lateral automáticamente';

  @override
  String get settings_autoHideSidePanelKeywords =>
      'ratón, cursor, pasar el ratón, barra lateral, sidebar';

  @override
  String get settings_autoHideSidePanelSubtitle =>
      'Ocultar la barra de pestañas lateral y mostrarla cuando el ratón llegue a ese borde. Solo funciona mientras se usa un ratón o un trackpad; al tocar la pantalla, el panel vuelve junto a la página.';

  @override
  String get settings_bottomSheetTabViewTitle =>
      'Vista de pestañas en panel inferior';

  @override
  String get settings_bottomSheetTabViewKeywords => 'panel inferior';

  @override
  String get settings_bottomSheetTabViewSubtitle =>
      'Mostrar las pestañas en un panel inferior en lugar de a pantalla completa';

  @override
  String get settings_longPressUrlCopyTitle =>
      'Mantener pulsada la URL para copiarla';

  @override
  String get settings_longPressUrlCopyKeywords => 'copiar url';

  @override
  String get settings_longPressUrlCopySubtitle =>
      'Copiar la URL de la página al portapapeles al mantener pulsada la barra de direcciones';

  @override
  String get settings_showFaviconsTitle =>
      'Mostrar favicons en la vista de lista';

  @override
  String get settings_showFaviconsKeywords => 'iconos';

  @override
  String get settings_showFaviconsSubtitle =>
      'Mostrar los iconos de los sitios web en lugar de miniaturas de página en la vista de lista de pestañas';

  @override
  String get settings_previewPageContent => 'Contenido de la página';

  @override
  String get settings_previewPageTitle => 'Vista previa de WebLibre';

  @override
  String get settings_previewTabNews => 'Noticias';

  @override
  String get settings_previewTabPrivate => 'Privada';

  @override
  String get settings_previewTabBank => 'Banco';

  @override
  String get settings_previewTabSearch => 'Búsqueda';

  @override
  String get settings_livePreviewTitle => 'Vista previa en directo';

  @override
  String get settings_livePreviewSubtitle =>
      'Refleja tus ajustes actuales de barra de herramientas y diseño';

  @override
  String get settings_deleteAllExceptionsTitle =>
      '¿Eliminar todas las excepciones?';

  @override
  String get settings_deleteAllExceptionsContent =>
      'Se volverá a activar la protección contra el rastreo en todos los sitios de las excepciones.';

  @override
  String get settings_entryCopied => 'Entrada copiada';

  @override
  String get settings_messageLabel => 'Mensaje:';

  @override
  String get settings_errorLabel => 'Error:';

  @override
  String get settings_stackTraceLabel => 'Traza de la pila:';

  @override
  String get settings_importSettingsTitle => 'Importar ajustes';

  @override
  String get settings_importSettingsDescription =>
      'Las secciones que elijas reemplazan lo que tiene ahora este perfil. Lo que dejes sin marcar se queda como está.';

  @override
  String settings_unreadableSections(int count, String sections) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Esta versión de WebLibre no puede leer $count secciones de este archivo ($sections) y se omitirán.',
      one:
          'Esta versión de WebLibre no puede leer 1 sección de este archivo ($sections) y se omitirá.',
    );
    return '$_temp0';
  }

  @override
  String get settings_exportedLabel => 'Exportado';

  @override
  String get settings_appVersionLabel => 'Versión de la aplicación';

  @override
  String get settings_credentialsNotCarried =>
      'Las exportaciones no incluyen las credenciales guardadas ni la imagen de fondo de pantalla. Este dispositivo conserva las suyas.';

  @override
  String get settings_geckoPrefsRestartNote =>
      'Algunas preferencias del motor solo se aplican después de reiniciar el navegador.';

  @override
  String get settings_userAgentChangedTitle => 'User agent cambiado';

  @override
  String get settings_userAgentChangedContent =>
      'El navegador tiene que reiniciarse para que se aplique el nuevo user agent.';

  @override
  String get settings_tabBarSectionTitle => 'Barra de pestañas';

  @override
  String get settings_contextualToolbarSectionTitle =>
      'Barra de herramientas contextual';

  @override
  String get settings_quickTabSwitcherSectionTitle =>
      'Selector rápido de pestañas';

  @override
  String get settings_tabViewSectionTitle => 'Vista de pestañas';

  @override
  String get settings_menuSectionTitle => 'Menú';

  @override
  String get settings_menuSectionKeywords =>
      'tres puntos, desbordamiento, overflow';

  @override
  String get settings_indexTabBarPositionSubtitle =>
      'Elegir si la barra de pestañas va arriba, abajo o en un lateral';

  @override
  String get settings_indexTabBarStyleSubtitle =>
      'Elegir entre el diseño con título y el compacto';

  @override
  String get settings_indexAutoHideTabBarSubtitle =>
      'Ocultar la barra de pestañas al desplazarse';

  @override
  String get settings_indexAutoHideSidePanelSubtitle =>
      'Mostrar el panel lateral cuando el ratón llega a su borde';

  @override
  String get settings_indexLongPressUrlCopySubtitle =>
      'Copiar la URL actual desde la barra de pestañas';

  @override
  String get settings_indexShowContextualToolbarSubtitle =>
      'Mostrar una barra de herramientas adicional para navegación y acciones';

  @override
  String get settings_indexCustomizeToolbarButtonsSubtitle =>
      'Elegir qué acciones aparecen en la barra de herramientas contextual';

  @override
  String get settings_indexTabStackingSubtitle =>
      'Elegir cómo organiza las pestañas la barra del selector rápido';

  @override
  String get settings_indexCustomizeSwitcherButtonsSubtitle =>
      'Elegir qué botones de acción aparecen al final de la barra';

  @override
  String get settings_indexHistoryFallbackSubtitle =>
      'Usar sugerencias del historial cuando no hay pestañas que coincidan';

  @override
  String get settings_indexShowTitlesSubtitle =>
      'Mostrar los títulos de las páginas en la lista del selector';

  @override
  String get settings_indexHierarchyDepthSubtitle =>
      'Cuántas flechas de anidamiento se muestran en los chips del selector';

  @override
  String get settings_indexBottomSheetTabViewSubtitle =>
      'Abrir el selector de pestañas como panel inferior';

  @override
  String get settings_indexShowFaviconsSubtitle =>
      'Mostrar los iconos de los sitios en la lista de pestañas';

  @override
  String get settings_switcherPlacementTitle => 'Posición del selector';

  @override
  String get settings_switcherPlacementSubtitle =>
      'Dónde se sitúa el selector junto a la barra de direcciones y la barra de herramientas contextual';

  @override
  String get settings_switcherPlacementKeywords =>
      'posición, orden, encima, debajo, arriba, abajo, barra de direcciones, barra de pestañas';

  @override
  String get settings_switcherPlacementAutoLabel => 'Automático';

  @override
  String get settings_switcherPlacementAutoDescription =>
      'Encima de la barra de direcciones cuando está abajo, encima de la barra de herramientas contextual cuando está arriba';

  @override
  String get settings_switcherPlacementAboveAddressBarLabel =>
      'Encima de la barra de direcciones';

  @override
  String get settings_switcherPlacementAboveAddressBarDescription =>
      'Sigue a la barra de direcciones arriba o abajo';

  @override
  String get settings_switcherPlacementBelowAddressBarLabel =>
      'Debajo de la barra de direcciones';

  @override
  String get settings_switcherPlacementBelowAddressBarDescription =>
      'Sigue a la barra de direcciones arriba o abajo';

  @override
  String get settings_switcherPlacementBelowContextualBarLabel =>
      'Debajo de la barra de herramientas contextual';

  @override
  String get settings_switcherPlacementBelowContextualBarDescription =>
      'En el borde inferior de la pantalla';

  @override
  String get settings_tabViewActionsAtBottomTitle =>
      'Acciones de la vista de pestañas abajo';

  @override
  String get settings_tabViewActionsAtBottomSubtitle =>
      'Búsqueda, filtros y acciones de pestañas abajo, con el botón de nueva pestaña encima';

  @override
  String get settings_tabViewActionsAtBottomKeywords =>
      'abajo, pulgar, alcance, una mano, barra de herramientas, vista de pestañas';

  @override
  String get smallWeb_sheetTitle => 'Small Web';

  @override
  String get smallWeb_refineCategoryTitle => 'Afinar categoría';

  @override
  String get smallWeb_allCategoriesChip => 'Todas';

  @override
  String smallWeb_searchingModeTitle(String mode) {
    return 'Buscando en $mode';
  }

  @override
  String get smallWeb_discoverButtonLabel => 'Descubrir';

  @override
  String get smallWeb_browseConsolesButtonLabel => 'Explorar consolas';

  @override
  String get smallWeb_unavailableTitle => 'Small Web no disponible';

  @override
  String get smallWeb_noConsoleSelectedMessage =>
      'No hay ninguna consola seleccionada';

  @override
  String smallWeb_consoleStats(int linkedConsoles, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedConsoles,
      locale: localeName,
      other: '$linkedConsoles consolas enlazadas',
      one: '1 consola enlazada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages páginas',
      one: '1 página',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get smallWeb_modeWebLabel => 'Web';

  @override
  String get smallWeb_modeAppreciatedLabel => 'Apreciados';

  @override
  String get smallWeb_modeVideosLabel => 'Vídeos';

  @override
  String get smallWeb_modeCodeLabel => 'Código';

  @override
  String get smallWeb_modeComicsLabel => 'Cómics';

  @override
  String get smallWeb_modeDescriptionAppreciated =>
      'Explora enlaces cuidadosamente seleccionados y valorados por la comunidad de la Small Web.';

  @override
  String get smallWeb_modeDescriptionVideos =>
      'Descubre vídeos de creadores independientes de toda la Small Web.';

  @override
  String get smallWeb_modeDescriptionCode =>
      'Encuentra fragmentos de código, repositorios y artículos técnicos de sitios personales.';

  @override
  String get smallWeb_modeDescriptionComics =>
      'Explora cómics independientes e ilustraciones para la web de artistas independientes.';

  @override
  String get smallWeb_sourceKagiLabel => 'Kagi';

  @override
  String get smallWeb_sourceKagiDescription => 'Small Web de Kagi Search';

  @override
  String get smallWeb_sourceWanderLabel => 'Wander';

  @override
  String get smallWeb_sourceWanderDescription =>
      'Anillo web basado en consolas';

  @override
  String get smallWeb_noNewItemsFoundMessage =>
      'No se encontraron elementos nuevos. Prueba con otro modo u otra categoría.';

  @override
  String get smallWeb_discoveryFailedMessage =>
      'Error al descubrir. Vuelve a intentarlo.';

  @override
  String smallWeb_sessionErrorWithDetails(String error) {
    return 'Error de Small Web: $error';
  }

  @override
  String get smallWeb_kagiTitle => 'Kagi Small Web';

  @override
  String get smallWeb_kagiAttributionLine =>
      'De Kagi Search - código abierto bajo la licencia MIT.';

  @override
  String get smallWeb_kagiBlogPostAction => 'Artículo del blog';

  @override
  String get smallWeb_kagiGithubAction => 'GitHub';

  @override
  String get smallWeb_kagiDescriptionWeb =>
      'Kagi Small Web muestra publicaciones recientes de sitios personales y blogs de autores individuales de toda la Small Web.';

  @override
  String get smallWeb_kagiDescriptionAppreciated =>
      'Este modo de Kagi Small Web destaca publicaciones apreciadas de la Small Web, seleccionadas por el proyecto de código abierto.';

  @override
  String get smallWeb_kagiDescriptionVideos =>
      'Este modo de Kagi Small Web se centra en vídeos de creadores independientes más pequeños y en una selección de canales de partida.';

  @override
  String get smallWeb_kagiDescriptionCode =>
      'Este modo de Kagi Small Web se centra en publicaciones sobre código de sitios personales y otras fuentes de la Small Web.';

  @override
  String get smallWeb_kagiDescriptionComics =>
      'Este modo de Kagi Small Web se centra en cómics y publicaciones ilustradas encontradas a través del proyecto Small Web.';

  @override
  String get smallWeb_wanderTitle => 'Wander';

  @override
  String get smallWeb_wanderDescription =>
      'Wander es una red de sitios web personales conectados mediante consolas compartidas que ayudan a explorar páginas de toda la comunidad Wander.';

  @override
  String get smallWeb_wanderAttributionLine =>
      'De Susam Pal - código abierto bajo la licencia MIT.';

  @override
  String get smallWeb_wanderProjectAction => 'Proyecto';

  @override
  String get smallWeb_wanderSetupConsoleAction => 'Configura tu consola';

  @override
  String get smallWeb_menuTooltip => 'Menú';

  @override
  String get smallWeb_removeBookmarkTooltip => 'Quitar marcador';

  @override
  String get smallWeb_addBookmarkTooltip => 'Añadir marcador';

  @override
  String get smallWeb_bookmarkRemovedMessage => 'Marcador quitado';

  @override
  String get smallWeb_bookmarkAddedMessage => 'Marcador añadido';

  @override
  String get smallWeb_exitTooltip => 'Salir de Small Web';

  @override
  String get smallWeb_selectConsoleTitle => 'Seleccionar consola';

  @override
  String get smallWeb_randomButtonLabel => 'Aleatoria';

  @override
  String get smallWeb_filterConsolesHint => 'Filtrar consolas...';

  @override
  String get smallWeb_linkedConsolesToggleLabel => 'Enlazadas';

  @override
  String get smallWeb_allConsolesToggleLabel => 'Todas';

  @override
  String get smallWeb_noConsoleSelectedYetMessage =>
      'Aún no hay ninguna consola seleccionada. Pulsa Descubrir.';

  @override
  String get smallWeb_addConsoleByUrlTooltip => 'Añadir consola por URL';

  @override
  String get smallWeb_couldNotLoadSessionTitle =>
      'No se pudo cargar la sesión de Small Web';

  @override
  String get smallWeb_noLinkedConsolesFound =>
      'No se encontraron consolas enlazadas.';

  @override
  String smallWeb_noConsolesMatchingQuery(String query) {
    return 'Ninguna consola coincide con «$query».';
  }

  @override
  String get smallWeb_failedToLoadConsoles =>
      'No se pudieron cargar las consolas.';

  @override
  String smallWeb_pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '$_temp0';
  }

  @override
  String get smallWeb_noConsolesDiscoveredYet =>
      'Aún no se ha descubierto ninguna consola.';

  @override
  String smallWeb_addedConsole(String host) {
    return 'Consola $host añadida';
  }

  @override
  String get smallWeb_addConsoleDialogTitle => 'Añadir consola';

  @override
  String get smallWeb_addConsoleDialogBody =>
      'Introduce la URL de una consola de Wander. La URL puede apuntar a la raíz del sitio o a la ruta /wander/.';

  @override
  String get smallWeb_urlFieldLabel => 'URL';

  @override
  String get smallWeb_wanderConsoleFetchFailed =>
      'No se pudo obtener wander.js de esta consola.';

  @override
  String get smallWeb_wanderConsoleEmpty =>
      'El archivo wander.js no contiene consolas ni páginas';

  @override
  String get smallWeb_wanderConsoleAlreadyAdded =>
      'Esta consola ya se ha añadido';

  @override
  String get smallWeb_recentDiscoveriesTitle => 'Descubrimientos recientes';

  @override
  String smallWeb_clearModeHistory(String mode) {
    return 'Borrar $mode';
  }

  @override
  String get smallWeb_clearAllDiscoveriesConfirmTitle =>
      '¿Borrar todos los descubrimientos?';

  @override
  String get smallWeb_clearAllDiscoveriesConfirmContent =>
      'Se eliminará de forma permanente todo el historial de descubrimientos recientes de todos los modos y fuentes.';

  @override
  String get smallWeb_actionClearAll => 'Borrar todo';

  @override
  String get smallWeb_clearAllDiscoveriesMenuItem =>
      'Borrar todos los descubrimientos';

  @override
  String get smallWeb_noDiscoveriesYetMessage =>
      'Aún no hay descubrimientos.\n¡Pulsa Descubrir para empezar a explorar!';

  @override
  String smallWeb_showMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar $count más',
    );
    return '$_temp0';
  }

  @override
  String smallWeb_failedToLoadHistory(String error) {
    return 'No se pudo cargar el historial: $error';
  }

  @override
  String get sync_screenTitle => 'Firefox Sync';

  @override
  String get sync_searchHint => 'Buscar en los ajustes de sincronización';

  @override
  String get sync_statusSyncing => 'Sincronización en curso';

  @override
  String get sync_statusNeverSynced => 'Nunca sincronizado';

  @override
  String sync_statusLastSynced(String date) {
    return 'Última sincronización: $date';
  }

  @override
  String get sync_sectionAccount => 'Cuenta';

  @override
  String get sync_sectionAccountKeywords =>
      'emparejar, emparejamiento, nombre del dispositivo, pairing';

  @override
  String get sync_entrySignedInAccountTitle => 'Cuenta con sesión iniciada';

  @override
  String get sync_entrySignInTitle => 'Iniciar sesión';

  @override
  String get sync_entryAccountSubtitle =>
      'Estado de la cuenta, emparejamiento con QR y nombre del dispositivo';

  @override
  String get sync_signedIn => 'Sesión iniciada';

  @override
  String get sync_notSignedIn => 'Sin sesión iniciada';

  @override
  String get sync_authExpired =>
      'La autenticación ha caducado. Vuelve a iniciar sesión para seguir sincronizando.';

  @override
  String get sync_syncingTabsBookmarksHistory =>
      'Sincronizando pestañas, marcadores e historial';

  @override
  String get sync_signInPrompt =>
      'Inicia sesión para sincronizar pestañas, marcadores e historial';

  @override
  String get sync_actionSignOut => 'Cerrar sesión';

  @override
  String get sync_scanQrTitle => 'Escanear código QR para emparejar';

  @override
  String get sync_scanQrSubtitle =>
      'Escanea un código QR de firefox.com/pair en el ordenador';

  @override
  String get sync_invalidQrCode => 'Código QR no válido: no es una URL válida';

  @override
  String get sync_deviceNameTitle => 'Nombre del dispositivo';

  @override
  String get sync_unknown => 'Desconocido';

  @override
  String get sync_sectionSynchronization => 'Sincronización';

  @override
  String get sync_syncNowTitle => 'Sincronizar ahora';

  @override
  String get sync_syncNowKeywords => 'historial, marcadores, pestañas, sync';

  @override
  String get sync_syncHistoryTitle => 'Sincronizar historial';

  @override
  String get sync_syncBookmarksTitle => 'Sincronizar marcadores';

  @override
  String get sync_syncOpenTabsTitle => 'Sincronizar pestañas abiertas';

  @override
  String get sync_sectionServerOverrides => 'Servidores personalizados';

  @override
  String get sync_entryServerOverridesTitle => 'Servidores personalizados';

  @override
  String get sync_entryServerOverridesKeywords => 'servidor, fxa, token server';

  @override
  String get sync_entryServerOverridesSubtitle =>
      'Direcciones personalizadas de Firefox Account y del servidor de tokens';

  @override
  String get sync_fxaServerOverrideTitle => 'Servidor de FxA personalizado';

  @override
  String get sync_defaultMozillaServer => 'Servidor predeterminado de Mozilla';

  @override
  String get sync_tokenServerOverrideTitle =>
      'Servidor de tokens de Sync personalizado';

  @override
  String get sync_automaticFromFxaServer =>
      'Automático desde el servidor de FxA';

  @override
  String get sync_restartAppNotice =>
      'Reinicia la aplicación después de cambiar los servidores personalizados.';

  @override
  String get sync_signOutDialogTitle => '¿Cerrar sesión?';

  @override
  String get sync_signOutDialogContent =>
      '¿Seguro que quieres cerrar sesión en Firefox Sync?';

  @override
  String get sync_deviceNameHint => 'Introduce el nombre del dispositivo';

  @override
  String get sync_deviceNameEmpty =>
      'El nombre del dispositivo no puede estar vacío';

  @override
  String get sync_deviceNameUpdateFailed =>
      'No se pudo actualizar el nombre del dispositivo';

  @override
  String get sync_mustBeValidHttpsUrl => 'Debe ser una URL HTTPS válida';

  @override
  String get tor_sectionService => 'Servicio';

  @override
  String get tor_sectionServiceKeywords =>
      'encender, iniciar, detener, parar, start, stop';

  @override
  String get tor_sectionCircumvention => 'Elusión de la censura';

  @override
  String get tor_sectionCircumventionKeywords =>
      'puentes, transporte, censura, bridges, obfs4, snowflake';

  @override
  String get tor_sectionCountryRestrictions => 'Restricciones de país';

  @override
  String get tor_sectionCountryRestrictionsKeywords =>
      'entrada, salida, país, entry, exit';

  @override
  String get tor_sectionAbout => 'Acerca de';

  @override
  String get tor_sectionAboutKeywords => 'marca registrada, legal, trademark';

  @override
  String tor_proxyLabel(String brand) {
    return 'Proxy de $brand';
  }

  @override
  String tor_serviceLabel(String brand) {
    return 'Servicio de $brand';
  }

  @override
  String get tor_serviceLabelKeywords => 'activar, conectar, habilitar';

  @override
  String tor_serviceSubtitle(String brand) {
    return 'Iniciar o detener el servicio de $brand';
  }

  @override
  String get tor_startAutomaticallyTitle => 'Iniciar automáticamente';

  @override
  String get tor_startAutomaticallyKeywords =>
      'inicio automático, arranque, iniciar, autostart';

  @override
  String tor_startAutomaticallySectionSubtitle(String brand) {
    return 'Conectar el servicio de $brand al iniciar WebLibre';
  }

  @override
  String tor_startAutomaticallySubtitle(String brand) {
    return 'Conectar el servicio de $brand al iniciar WebLibre, para que las pestañas que lo usan estén listas sin preguntar';
  }

  @override
  String get tor_requestNewIdentityTitle => 'Solicitar nueva identidad';

  @override
  String get tor_requestNewIdentityKeywords => 'circuito, identidad, circuit';

  @override
  String get tor_requestNewIdentitySubtitle =>
      'Usar un circuito nuevo para las nuevas conexiones';

  @override
  String tor_requestingNewIdentityMessage(String brand) {
    return 'Solicitando nueva identidad de $brand...';
  }

  @override
  String get tor_autoConfigureTransportTitle =>
      'Configurar el transporte automáticamente';

  @override
  String get tor_autoConfigureTransportKeywords => 'automático, auto';

  @override
  String get tor_autoConfigureSectionSubtitle =>
      'Elegir automáticamente el transporte conectable adecuado para tu red';

  @override
  String tor_autoConfigureSubtitle(String brand) {
    return 'Desde algunos lugares es necesario usar un transporte conectable para conectarse a $brand';
  }

  @override
  String get tor_requireBridgeTitle =>
      'Estoy seguro de que no puedo conectarme sin un puente';

  @override
  String get tor_transportTitle => 'Transporte';

  @override
  String get tor_transportKeywords => 'directo, transporte, obfs4, snowflake';

  @override
  String tor_transportSectionSubtitle(String torBrand) {
    return 'Elegir cómo llegar a la red $torBrand cuando no se configura automáticamente';
  }

  @override
  String get tor_transportAutoConfiguredTitle => 'Configurado automáticamente';

  @override
  String get tor_transportAutoConfiguredSubtitle =>
      'Desactiva la configuración automática de arriba para elegir un transporte manualmente.';

  @override
  String get tor_transportDirectTitle => 'Conexión directa';

  @override
  String tor_transportDirectSubtitle(String brand) {
    return 'La mejor forma de conectarse a $brand si $brand no está bloqueado';
  }

  @override
  String get tor_transportObfs4Title => 'obfs4';

  @override
  String get tor_transportObfs4Subtitle =>
      'Adecuado para redes con poca censura y un uso intensivo del ancho de banda';

  @override
  String get tor_transportSnowflakeTitle => 'Snowflake';

  @override
  String get tor_transportSnowflakeSubtitle => 'Adecuado para censura fuerte';

  @override
  String get tor_fetchFreshBridgesTitle =>
      'Obtener puentes actualizados antes de conectarse';

  @override
  String get tor_entryCountryTitle => 'País de entrada';

  @override
  String get tor_entryCountrySubtitle =>
      'Elegir el país del guardián de entrada';

  @override
  String get tor_entryCountryKeywords => 'guardián, entrada, guard';

  @override
  String get tor_exitCountryTitle => 'País de salida';

  @override
  String get tor_exitCountrySubtitle => 'Elegir el país del nodo de salida';

  @override
  String get tor_exitCountryKeywords => 'salida, nodo, exit';

  @override
  String get tor_automaticOption => 'Automático';

  @override
  String get tor_trademarkTitle => 'Marca registrada';

  @override
  String get tor_trademarkKeywords => 'legal, marca';

  @override
  String tor_trademarkDisclaimer(String brand) {
    return '$brand es una marca registrada de The Tor Project; todos los derechos reservados. WebLibre no está respaldado ni patrocinado por el Tor Project, ni afiliado a él.';
  }

  @override
  String get tor_screenSubtitle =>
      'Enrutamiento cebolla, transportes conectables, puentes y restricciones de país.';

  @override
  String tor_dialogContent(String brand) {
    return 'Este contenedor requiere un proxy de $brand para las conexiones seguras, y no se está ejecutando.';
  }

  @override
  String get tor_actionEnable => 'Activar';

  @override
  String tor_connectingNotification(String proxyLabel) {
    return '$proxyLabel se está conectando...';
  }

  @override
  String get tor_countrySearchHint => 'Buscar países...';

  @override
  String get tor_unnamedCountry => 'País sin nombre';

  @override
  String get user_profilesTitle => 'Perfiles';

  @override
  String get user_activeProfileLabel => 'Activo';

  @override
  String get user_loadProfilesFailedTitle =>
      'No se pudieron cargar los perfiles';

  @override
  String get user_askWhichProfileTitle => 'Preguntar qué perfil abrir';

  @override
  String get user_askWhichProfileSubtitle =>
      'Al iniciar, si hay más de un perfil';

  @override
  String get user_createBackupTitle => 'Crear copia de seguridad';

  @override
  String get user_restartingToTakeBackup =>
      'Reiniciando para hacer la copia de seguridad';

  @override
  String get user_backupRestartsTitle => 'WebLibre se reinicia para hacer esto';

  @override
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile) {
    return '$restartClosesCurrentProfile La copia de seguridad se hace con el perfil cerrado, así que su contenido no puede cambiar durante la copia.';
  }

  @override
  String get user_setPasswordNextTitle =>
      'La contraseña se establece a continuación';

  @override
  String get user_setPasswordNextSubtitle =>
      'Tras reiniciarse, WebLibre pide la contraseña del archivo de copia de seguridad.';

  @override
  String get user_verifyBackupIntegrityTitle =>
      'Verificar la integridad de la copia';

  @override
  String get user_verifyBackupIntegritySubtitle =>
      'Comprobar que la copia de seguridad se puede restaurar';

  @override
  String get user_tempDataSkippedTitle => 'Los datos temporales se omiten';

  @override
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain) {
    return 'No se guardan los archivos de caché ni otros datos que WebLibre puede regenerar. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataIncludedTitle =>
      'Se incluyen los datos de la cuenta de WebLibre';

  @override
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription) {
    return 'El archivo de copia de seguridad incluye estos datos del perfil: $profileSecretDataDescription. Al reemplazar un perfil se restauran; al crear un perfil nuevo, no. Usa una contraseña segura.';
  }

  @override
  String get user_closingToTakeBackup =>
      'Cerrando WebLibre para hacer la copia de seguridad…';

  @override
  String get user_actionBackup => 'Hacer copia';

  @override
  String get user_backupsTitle => 'Copias de seguridad';

  @override
  String get user_changeBackupFolderTooltip =>
      'Cambiar la carpeta de copias de seguridad';

  @override
  String get user_chooseBackupFolderPrompt =>
      'Elige dónde guardar tus copias de seguridad.';

  @override
  String get user_chooseBackupFolderHint =>
      'Elige una ubicación fuera de la aplicación para que las copias sobrevivan a su desinstalación.';

  @override
  String get user_chooseFolderButtonLabel => 'Elegir carpeta';

  @override
  String get user_noBackupsFound => 'No se encontraron copias de seguridad';

  @override
  String get user_loadBackupsFailedTitle =>
      'No se pudieron cargar las copias de seguridad';

  @override
  String get user_authReasonRequireAuth =>
      'Requerir autenticación para el perfil';

  @override
  String get user_authReasonConfirmUnlock =>
      'Confirma que puedes desbloquear este perfil';

  @override
  String get user_authReasonUnlockProfile => 'Desbloquear perfil';

  @override
  String get user_deviceAuthPromptTitle => 'Confirma tu identidad';

  @override
  String get user_deviceAuthNoScreenLock =>
      'Este dispositivo no tiene bloqueo de pantalla. Configura un PIN, un patrón o una contraseña en los ajustes de Android para desbloquear este perfil.';

  @override
  String get user_deviceAuthLockedOut =>
      'Demasiados intentos. Vuelve a intentarlo más tarde.';

  @override
  String get user_deviceAuthUnavailable =>
      'No se pudo confirmar tu identidad. Vuelve a intentarlo.';

  @override
  String user_authFailedExisting(String nothingChanged) {
    return 'No se pudo confirmar tu identidad. $nothingChanged';
  }

  @override
  String get user_authFailedNew =>
      'No se pudo confirmar tu identidad. Solo se crea un perfil bloqueado si este dispositivo puede desbloquearlo.';

  @override
  String get user_editProfileTitle => 'Editar perfil';

  @override
  String get user_createProfileTitle => 'Crear perfil';

  @override
  String get user_nameFieldLabel => 'Nombre';

  @override
  String get user_authenticationSectionTitle => 'Autenticación';

  @override
  String get user_lockMethodNoneTitle => 'Sin bloqueo';

  @override
  String get user_lockMethodNoneSubtitle =>
      'Cualquiera que use WebLibre en este dispositivo puede abrir este perfil';

  @override
  String get user_lockMethodDeviceTitle => 'Bloqueo del dispositivo';

  @override
  String get user_lockMethodDeviceSubtitle =>
      'Huella, rostro o PIN del dispositivo. Cualquiera que pueda desbloquear este dispositivo puede abrir este perfil.';

  @override
  String get user_lockMethodPasswordTitle => 'Contraseña del perfil';

  @override
  String get user_lockMethodPasswordSubtitle =>
      'Una contraseña solo para este perfil. Las huellas y el PIN del dispositivo no lo abren.';

  @override
  String get user_changeProfilePasswordTitle => 'Cambiar contraseña';

  @override
  String get user_profilePasswordUnrecoverableTitle =>
      'Una contraseña olvidada no se puede recuperar';

  @override
  String get user_profilePasswordUnrecoverableSubtitle =>
      'Sin ella no podrás abrir este perfil, hacer copias de seguridad ni eliminarlo. La contraseña bloquea WebLibre; no cifra los datos del perfil.';

  @override
  String get user_setProfilePasswordTitle => 'Establecer contraseña del perfil';

  @override
  String get user_setProfilePasswordExplanation =>
      'Se pedirá esta contraseña al abrir el perfil y antes de hacer una copia de seguridad, reemplazarlo por una copia, cambiarlo o eliminarlo.';

  @override
  String get user_newProfilePasswordFieldLabel => 'Nueva contraseña';

  @override
  String get user_repeatProfilePasswordFieldLabel => 'Repetir contraseña';

  @override
  String get user_profilePasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get user_profilePasswordCheckFailed =>
      'No se pudo comprobar la contraseña. Vuelve a intentarlo.';

  @override
  String get user_profilePasswordInterrupted =>
      'Saliste de WebLibre durante la comprobación. Vuelve a introducir la contraseña.';

  @override
  String get user_profilePasswordSaveFailed =>
      'No se pudo establecer la contraseña. Vuelve a intentarlo.';

  @override
  String get user_profilePasswordFieldLabel => 'Contraseña del perfil';

  @override
  String get user_wrongProfilePassword => 'Contraseña incorrecta';

  @override
  String user_wrongProfilePasswordWithRetry(String retryHint) {
    return 'Contraseña incorrecta. $retryHint';
  }

  @override
  String user_tooManyPasswordAttempts(String retryHint) {
    return 'Demasiados intentos fallidos. $retryHint';
  }

  @override
  String user_passwordRetryInSeconds(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Vuelve a intentarlo en $seconds segundos.',
      one: 'Vuelve a intentarlo en 1 segundo.',
    );
    return '$_temp0';
  }

  @override
  String user_passwordRetryInMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Vuelve a intentarlo en $minutes minutos.',
      one: 'Vuelve a intentarlo en 1 minuto.',
    );
    return '$_temp0';
  }

  @override
  String user_authReasonEditProfile(String profileName) {
    return 'Cambiar «$profileName»';
  }

  @override
  String user_authReasonBackupProfile(String profileName) {
    return 'Hacer copia de seguridad de «$profileName»';
  }

  @override
  String user_authReasonDeleteProfile(String profileName) {
    return 'Eliminar «$profileName»';
  }

  @override
  String user_authReasonReplaceProfile(String profileName) {
    return 'Reemplazar «$profileName»';
  }

  @override
  String get user_autoLockTitle => 'Bloqueo automático';

  @override
  String get user_autoLockSubtitle => 'Cuándo volver a bloquear el perfil';

  @override
  String get user_lockInBackgroundTitle => 'Bloquear en segundo plano';

  @override
  String get user_lockInBackgroundSubtitle =>
      'En cuanto WebLibre deja de estar en pantalla';

  @override
  String get user_lockAfterTimeoutTitle => 'Bloquear tras un tiempo';

  @override
  String get user_lockAfterTimeoutSubtitle =>
      'Después de un periodo de inactividad';

  @override
  String get user_lockOnStartupTitle => 'Bloquear solo al iniciar';

  @override
  String get user_lockOnStartupSubtitle =>
      'Desbloquear una vez al iniciar y mantenerlo desbloqueado hasta que WebLibre se cierre por completo';

  @override
  String get user_timeoutFieldTitle => 'Tiempo de espera';

  @override
  String get user_timeoutFieldSubtitle => 'Cuánto esperar antes de bloquear';

  @override
  String get user_timeoutOneMinute => '1 minuto';

  @override
  String get user_timeoutFiveMinutes => '5 minutos';

  @override
  String get user_timeoutFifteenMinutes => '15 minutos';

  @override
  String get user_timeoutOneHour => '1 hora';

  @override
  String get user_profileActionsSectionTitle => 'Acciones del perfil';

  @override
  String get user_switchDeleteUnavailableForActive =>
      'No se puede cambiar ni eliminar el perfil que estás usando.';

  @override
  String get user_switchToThisProfileLabel => 'Cambiar a este perfil';

  @override
  String user_deleteFailedWithError(String error) {
    return 'No se pudo eliminar: $error';
  }

  @override
  String get user_deleteProfileFailedGeneric =>
      'No se pudo eliminar este perfil';

  @override
  String get user_restoreBackupTitle => 'Restaurar copia de seguridad';

  @override
  String get user_backupRestoredMessage => 'Copia de seguridad restaurada';

  @override
  String get user_passwordFieldLabel => 'Contraseña';

  @override
  String get user_wrongBackupPassword =>
      'Esta contraseña no abrió el archivo de copia de seguridad';

  @override
  String get user_passwordHelperText =>
      'La contraseña con la que se creó este archivo de copia de seguridad.';

  @override
  String get user_createNewProfileTitle => 'Crear un perfil nuevo';

  @override
  String get user_createNewProfileSubtitle =>
      'Conservar tus perfiles existentes y añadir esta copia de seguridad';

  @override
  String get user_replaceExistingProfileTitle =>
      'Reemplazar un perfil existente';

  @override
  String get user_replaceExistingProfileSubtitle =>
      'Reiniciar y sobrescribir un perfil con esta copia de seguridad';

  @override
  String get user_newProfileNoSignInTitle =>
      'Un perfil nuevo empieza sin sesión iniciada en WebLibre';

  @override
  String get user_newProfileNoSignInSubtitle =>
      'Se restauran las pestañas, el historial y los marcadores. Los datos de inicio de sesión y sincronización se quedan en el perfil original.';

  @override
  String user_restoreDeviceLockUnconfirmed(String nothingChanged) {
    return 'Esta copia de seguridad está protegida con el bloqueo del dispositivo, y este dispositivo no pudo desbloquearla. $nothingChanged';
  }

  @override
  String user_restoringIntoTitle(String profileLabel) {
    return 'Restaurando en «$profileLabel»';
  }

  @override
  String get user_backupKeepsLockConfigured =>
      'La copia de seguridad mantiene el bloqueo que configuraste.';

  @override
  String get user_profileKeepsNameAndLock =>
      'El perfil conserva su nombre y su bloqueo.';

  @override
  String get user_profileToReplaceLabel => 'Perfil que se reemplazará';

  @override
  String get user_selectProfileToReplaceValidator =>
      'Selecciona un perfil para reemplazar';

  @override
  String user_multipleProfilesShareNameTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfiles se llaman «$name»',
    );
    return '$_temp0';
  }

  @override
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone) {
    return 'La copia de seguridad indica un nombre de perfil, pero no cuál de ellos, así que elige el que quieres reemplazar. $cannotBeUndone';
  }

  @override
  String user_backupTakenFromTitle(String name) {
    return 'Esta copia de seguridad se hizo de «$name»';
  }

  @override
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Reemplaza «$targetLabel», que conserva su nombre y su bloqueo. $shortcutsNeedPinningAgain';
  }

  @override
  String user_profileWillBeCalledTitle(String name) {
    return 'Este perfil se llamará «$name»';
  }

  @override
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain) {
    return 'El nombre procede de la copia de seguridad. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataRestoredTitle =>
      'Se restauran los datos de la cuenta de WebLibre';

  @override
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  ) {
    return 'Al reemplazar se restauran estos datos del archivo de copia de seguridad: $profileSecretDataDescription. $signedInFromBackup $olderBackupKeepsCredentials';
  }

  @override
  String get user_replacesSetupProfileTitle =>
      'Esto reemplaza el perfil que estás configurando';

  @override
  String get user_replacesEverythingTitle =>
      'Esto reemplaza todo el contenido de ese perfil';

  @override
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword) {
    return '$restartsThenAsksPassword Todo lo que ya haya en este perfil se reemplazará cuando empiece la restauración.';
  }

  @override
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  ) {
    return '$restartsThenAsksPassword Cuando empiece la restauración, reemplazará los datos actuales ($profileDataDescription) de $targetDescription.';
  }

  @override
  String get user_thatProfileFallbackLabel => 'ese perfil';

  @override
  String get user_restoringBackupProgress => 'Restaurando copia de seguridad…';

  @override
  String get user_closingToRestoreProgress =>
      'Cerrando WebLibre para restaurar…';

  @override
  String get user_actionRestore => 'Restaurar';

  @override
  String user_switchToProfileTitle(String profileName) {
    return '¿Cambiar a «$profileName»?';
  }

  @override
  String user_switchClosesReopensAs(String profileName) {
    return 'WebLibre se cierra y se vuelve a abrir como «$profileName».';
  }

  @override
  String get user_switchConsequencesList =>
      '• Se borran las pestañas privadas.\n• Se pausan las notificaciones web del perfil que dejas.';

  @override
  String get user_actionNotNow => 'Ahora no';

  @override
  String get user_actionSwitchAndRestart => 'Cambiar y reiniciar';

  @override
  String get user_passwordConfirmationTitle => 'Confirmación de contraseña';

  @override
  String get user_actionConfirm => 'Confirmar';

  @override
  String get user_selectProfileTitle => 'Seleccionar perfil';

  @override
  String get user_manageProfilesLabel => 'Gestionar perfiles';

  @override
  String get user_profileAvatarHint =>
      'Cambiar a este perfil. Mantén pulsado para editarlo.';

  @override
  String user_profileAvatarTooltip(String label) {
    return '$label\nMantén pulsado para editar';
  }

  @override
  String get user_addProfileLabel => 'Añadir un perfil';

  @override
  String get user_addProfileButtonLabel => 'Añadir perfil';

  @override
  String get user_quitBrowserTitle => 'Salir del navegador';

  @override
  String get user_quitBrowserContent =>
      'El navegador se cerrará correctamente y se borrarán los datos de las pestañas privadas.';

  @override
  String get user_actionQuit => 'Salir';

  @override
  String get user_quitBrowserDontAskAgain => 'No volver a preguntar';

  @override
  String get user_quitBrowserDontAskAgainHint =>
      'Puedes volver a activarlo en Ajustes.';

  @override
  String get user_quitBrowserDontAskAgainSavesQuit =>
      'Los datos marcados arriba se eliminarán cada vez que salgas. Puedes cambiar ambas cosas en Ajustes.';

  @override
  String get user_quitBrowserDontAskAgainSavesQuitAndStart =>
      'Los datos marcados arriba se eliminarán cada vez que salgas y cada vez que se inicie WebLibre. Puedes cambiar ambas cosas en Ajustes.';

  @override
  String get user_quitBrowserDeleteDataTitle => 'Eliminar datos de navegación';

  @override
  String user_quitBrowserDeleteDataSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
      zero: 'Nada seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get user_quitBrowserDeletedAutomatically =>
      'Se elimina automáticamente, según tus ajustes';

  @override
  String user_deleteProfileTitle(String profileName) {
    return '¿Eliminar «$profileName»?';
  }

  @override
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Se eliminan sus datos: $profileDataDescription. $cannotBeUndone';
  }

  @override
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile Primero se cierra el perfil que se va a eliminar.';
  }

  @override
  String get user_actionDeleteAndRestart => 'Eliminar y reiniciar';

  @override
  String user_replaceProfileTitle(String profileName) {
    return '¿Reemplazar «$profileName» por esta copia de seguridad?';
  }

  @override
  String user_replaceProfilePlaceholderContent(String cannotBeUndone) {
    return 'La copia de seguridad reemplaza el perfil que estás configurando. Se pierde todo lo que ya contenga. $cannotBeUndone';
  }

  @override
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'La copia de seguridad reemplaza todo el contenido de «$profileName»: $profileDataDescription. Se pierde todo lo añadido después de la copia. $cannotBeUndone';
  }

  @override
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  ) {
    return '$signedInFromBackup La restauración también incluye estos datos de la copia de seguridad: $profileSecretDataDescription. $olderBackupKeepsCredentials';
  }

  @override
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'El perfil pasa a llamarse «$adoptedName» y conserva su bloqueo. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'La copia de seguridad procede de «$sourceProfileName». «$profileName» conserva su nombre y su bloqueo. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsThenAsksPassword No se reemplaza nada antes de eso. $restartClosesCurrentProfile';
  }

  @override
  String get user_actionReplaceAndRestart => 'Reemplazar y reiniciar';

  @override
  String user_backupProfileTitle(String profileName) {
    return '¿Hacer copia de seguridad de «$profileName»?';
  }

  @override
  String get user_backupProfileContent =>
      'La copia de seguridad se hace con el perfil cerrado, así que no cambia nada en él.';

  @override
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile';
  }

  @override
  String get user_actionBackupAndRestart => 'Hacer copia y reiniciar';

  @override
  String get user_profileAlreadyActive => 'Este perfil ya está activo';

  @override
  String user_switchProfileFailedWithError(String error) {
    return 'No se pudo cambiar de perfil: $error';
  }

  @override
  String get user_profileLockedTitle => 'El perfil está bloqueado';

  @override
  String get user_unlockingLabel => 'Desbloqueando...';

  @override
  String get user_unlockButtonLabel => 'Desbloquear';

  @override
  String user_restartFailedWithError(String error) {
    return 'No se pudo reiniciar: $error';
  }

  @override
  String get user_restartingLabel => 'Reiniciando…';

  @override
  String get user_chooseAnotherProfileLabel => 'Elegir otro perfil';

  @override
  String get user_searchSuggestionProviderNone => 'Desactivado';

  @override
  String get user_searchSuggestionProviderBrave => 'Brave';

  @override
  String get user_searchSuggestionProviderDdg => 'DuckDuckGo';

  @override
  String get user_searchSuggestionProviderKagi => 'Kagi';

  @override
  String get user_searchSuggestionProviderQwant => 'Qwant';

  @override
  String get user_deleteBrowsingDataTypeTabsTitle => 'Pestañas abiertas';

  @override
  String get user_deleteBrowsingDataTypeHistoryTitle =>
      'Historial de navegación';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesTitle =>
      'Búsquedas recientes';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesDescription =>
      'Consultas que se muestran en la página de búsqueda';

  @override
  String get user_deleteBrowsingDataTypeCookiesTitle =>
      'Cookies y datos de sitios';

  @override
  String get user_deleteBrowsingDataTypeCookiesDescription =>
      'Se cerrará tu sesión en la mayoría de los sitios';

  @override
  String get user_deleteBrowsingDataTypeCacheTitle =>
      'Imágenes y archivos en caché';

  @override
  String get user_deleteBrowsingDataTypeCacheDescription =>
      'Libera espacio de almacenamiento';

  @override
  String get user_deleteBrowsingDataTypePermissionsTitle =>
      'Permisos de sitios';

  @override
  String get user_deleteBrowsingDataTypeDownloadsTitle => 'Descargas';

  @override
  String get wallpaper_title => 'Fondo de pantalla';

  @override
  String get wallpaper_settingsDescription =>
      'Se muestra detrás de la página de inicio en todos los contenedores que no tengan uno propio.';

  @override
  String get wallpaper_chooseImage => 'Elegir imagen';

  @override
  String get wallpaper_replace => 'Reemplazar';

  @override
  String get wallpaper_blurLabel => 'Desenfoque';

  @override
  String get wallpaper_dimLabel => 'Atenuación';

  @override
  String get wallpaper_dimDescription =>
      'La atenuación funde la imagen con el fondo de la aplicación para que el texto siga siendo legible con el tema claro y con el oscuro.';

  @override
  String get wallpaper_editorDefaultDescription =>
      'La página de inicio mantiene su fondo predeterminado.';

  @override
  String get wallpaper_importErrorUnreadable => 'No se pudo leer ese archivo';

  @override
  String get wallpaper_importErrorTooLarge => 'Esa imagen es demasiado grande';

  @override
  String get wallpaper_importErrorNotAnImage => 'Ese archivo no es una imagen';

  @override
  String get wallpaper_importErrorDecodeFailed => 'No se pudo leer esa imagen';

  @override
  String get webFeed_addFeedTitle => 'Añadir fuente';

  @override
  String get webFeed_fieldUrlLabel => 'URL';

  @override
  String get webFeed_actionIgnore => 'Ignorar';

  @override
  String get webFeed_unnamedFeedTitle => 'Fuente sin título';

  @override
  String get webFeed_unnamedArticleTitle => 'Artículo sin título';

  @override
  String get webFeed_fetchFeedFailedTitle => 'No se pudo obtener la fuente';

  @override
  String get webFeed_feedsTitle => 'Fuentes';

  @override
  String get webFeed_loadFeedsFailedTitle =>
      'No se pudieron cargar las fuentes';

  @override
  String get webFeed_feedFabLabel => 'Añadir fuente';

  @override
  String get webFeed_loadFeedFailedTitle => 'No se pudo cargar la fuente';

  @override
  String get webFeed_newFeedTitle => 'Nueva fuente';

  @override
  String get webFeed_editFeedTitle => 'Editar fuente';

  @override
  String get webFeed_fetchingFeedMessage => 'Obteniendo la fuente…';

  @override
  String get webFeed_fieldTitleLabel => 'Título';

  @override
  String get webFeed_fieldDescriptionLabel => 'Descripción';

  @override
  String get webFeed_fieldIconUrlLabel => 'URL del icono';

  @override
  String get webFeed_fieldSiteLinkLabel => 'Enlace del sitio';

  @override
  String get webFeed_fieldFeedUrlLabel => 'URL de la fuente';

  @override
  String get webFeed_deleteFeedTitle => 'Eliminar fuente';

  @override
  String get webFeed_deleteFeedConfirm =>
      '¿Seguro que quieres eliminar esta fuente y todos sus artículos?';

  @override
  String get webFeed_articlesTitle => 'Artículos';

  @override
  String get webFeed_searchLabel => 'Buscar';

  @override
  String get webFeed_loadArticlesFailedTitle =>
      'No se pudieron cargar los artículos';

  @override
  String webFeed_publishedLabel(String date) {
    return 'Publicado: $date';
  }

  @override
  String get webFeed_notAvailable => 'N/D';

  @override
  String webFeed_updatedLabel(String date) {
    return 'Actualizado: $date';
  }

  @override
  String get webFeed_authorsLabel => 'Autores:';

  @override
  String get webFeed_tagsLabel => 'Etiquetas:';

  @override
  String get webFeed_readArticleFailedTitle => 'No se pudo cargar el artículo';

  @override
  String webFeed_lastFetchedLabel(String date) {
    return 'Última obtención: $date';
  }

  @override
  String get webFeed_tagsFieldLabel => 'Etiquetas';

  @override
  String get webPush_screenTitle => 'Notificaciones';

  @override
  String get webPush_screenSubtitle =>
      'Notificaciones de sitios web entregadas mediante UnifiedPush';

  @override
  String get webPush_distributorTileTitle => 'Distribuidor de UnifiedPush';

  @override
  String get webPush_distributorTileKeywords =>
      'notificaciones, push, distribuidor, unifiedpush, ntfy';

  @override
  String get webPush_checking => 'Comprobando…';

  @override
  String webPush_couldNotReadStatus(String error) {
    return 'No se pudo leer el estado de push: $error';
  }

  @override
  String get webPush_updatingDistributor => 'Actualizando…';

  @override
  String get webPush_registrationRecovering =>
      'Recuperándose de un error de registro…';

  @override
  String webPush_lastRegistrationError(String error) {
    return 'Último error de registro: $error';
  }

  @override
  String get webPush_disablingWebPush => 'Desactivando…';

  @override
  String get webPush_disableWebPush => 'Desactivar web push';

  @override
  String get webPush_statusNoneAvailable =>
      'No hay ningún distribuidor disponible';

  @override
  String get webPush_statusNotSelected => 'Sin configurar';

  @override
  String get webPush_statusPending => 'Conectando…';

  @override
  String get webPush_statusReady => 'Activo';

  @override
  String get webPush_statusUnavailable => 'Distribuidor no disponible';

  @override
  String get webPush_statusDescNoneAvailable =>
      'Instala una aplicación distribuidora de UnifiedPush, como ntfy, para recibir notificaciones de sitios web.';

  @override
  String get webPush_statusDescNotSelected =>
      'Elige un distribuidor abajo para activar las notificaciones de sitios web.';

  @override
  String get webPush_statusDescPending =>
      'Esperando a que el distribuidor confirme el registro.';

  @override
  String get webPush_statusDescReady =>
      'Las notificaciones de sitios web se entregan a través de este distribuidor.';

  @override
  String get webPush_statusDescUnavailable =>
      'El distribuidor elegido ya no está instalado. Las notificaciones de sitios web no se entregarán hasta que elijas otro.';

  @override
  String get webPush_noDistributorInstalled =>
      'No hay ningún distribuidor de UnifiedPush instalado. Instala uno, como ntfy, y vuelve a intentarlo.';

  @override
  String get webPush_chooseDistributorTitle => 'Elegir distribuidor';

  @override
  String get webPush_distributorConfigured =>
      'Distribuidor de UnifiedPush configurado.';

  @override
  String webPush_couldNotConfigureDistributor(String error) {
    return 'No se pudo configurar el distribuidor: $error';
  }

  @override
  String get webPush_webPushDisabled => 'Web push desactivado.';

  @override
  String webPush_couldNotDisableWebPush(String error) {
    return 'No se pudo desactivar web push: $error';
  }

  @override
  String get webPush_notificationPermissionTitle => 'Permiso de notificaciones';

  @override
  String get webPush_notificationPermissionKeywords =>
      'notificaciones, permiso, notifications';

  @override
  String webPush_notificationPermissionCouldNotRead(String error) {
    return 'No se pudo leer el estado del permiso: $error';
  }

  @override
  String get webPush_notificationPermissionGranted => 'Concedido';

  @override
  String get webPush_notificationPermissionDenied =>
      'Denegado. Los mensajes push siguen llegando, pero no se puede mostrar ninguna notificación.';

  @override
  String get webPush_grantAction => 'Conceder';

  @override
  String webPush_couldNotUpdatePermission(String error) {
    return 'No se pudo actualizar el permiso de notificaciones: $error';
  }

  @override
  String get webPush_loadingSubscriptions => 'Cargando suscripciones…';

  @override
  String get webPush_couldNotReadSubscriptions =>
      'No se pudieron leer las suscripciones';

  @override
  String get webPush_noSiteSubscriptions => 'No hay suscripciones de sitios';

  @override
  String get webPush_noSiteSubscriptionsDescription =>
      'Aquí aparecerán los sitios web a los que permitas enviar notificaciones.';

  @override
  String get webPush_subscriptionActive => 'Activa';

  @override
  String get webPush_subscriptionDelayedDelivery =>
      'Endpoint guardado; la entrega está en pausa hasta que el distribuidor esté listo';

  @override
  String get webPush_subscriptionWaitingForEndpoint =>
      'Esperando a que el distribuidor asigne un endpoint';

  @override
  String get webPush_revokeSubscriptionHint =>
      'Para que un sitio deje de enviar notificaciones, revoca su permiso de notificaciones en los ajustes del sitio.';

  @override
  String get webPush_deliverySectionTitle => 'Entrega';

  @override
  String get webPush_indexDistributorSubtitle =>
      'La aplicación que entrega las notificaciones push de sitios web';

  @override
  String get webPush_indexNotificationPermissionSubtitle =>
      'Necesario para mostrar notificaciones de sitios web';

  @override
  String get webPush_subscriptionsSectionTitle => 'Suscripciones';

  @override
  String get webPush_indexSiteSubscriptionsTitle => 'Suscripciones de sitios';

  @override
  String get webPush_indexSiteSubscriptionsKeywords =>
      'sitios, suscripciones, subscriptions';

  @override
  String get webPush_indexSiteSubscriptionsSubtitle =>
      'Sitios web con suscripciones a notificaciones push';

  @override
  String get webSearch_fetchPageDataTitle => 'Obtener datos de la página';

  @override
  String get webSearch_downloadFailedTapToRetry =>
      'Error en la descarga: pulsa para reintentar';

  @override
  String get webSearch_methodTrafilaturaTitle => 'Vista previa extraída';

  @override
  String get webSearch_methodSinglefileTitle => 'Captura de página completa';

  @override
  String get webSearch_methodPdfTitle => 'Instantánea en PDF';

  @override
  String get webSearch_methodPngTitle => 'Instantánea como imagen';

  @override
  String get webSearch_methodTrafilaturaSubtitle =>
      'Texto y metadatos optimizados para lectura en la vista previa de la aplicación';

  @override
  String get webSearch_methodSinglefileSubtitle =>
      'Archivar la página completa con su diseño y recursos para usarla más tarde';

  @override
  String get webSearch_methodPdfSubtitle =>
      'Convertir la página en un PDF para leerla sin conexión y compartirla';

  @override
  String get webSearch_methodPngSubtitle =>
      'Capturar la página renderizada completa en una imagen PNG';

  @override
  String get webSearch_previewUnavailableTitle => 'Vista previa no disponible';

  @override
  String get webSearch_previewUnavailableMessage =>
      'Obtén la página desde la lista de resultados antes de abrir una vista previa.';

  @override
  String get webSearch_openInBrowserTooltip => 'Abrir en el navegador';

  @override
  String webSearch_torToggleOn(String brand) {
    return '$brand activado';
  }

  @override
  String webSearch_torToggleOff(String brand) {
    return '$brand desactivado';
  }

  @override
  String get webSearch_languageAuto => 'Automático';

  @override
  String get webSearch_languageAutoDeviceDefault =>
      'Automático (idioma del dispositivo)';

  @override
  String get webSearch_countryAny => 'Cualquiera';

  @override
  String get webSearch_countryAnyRegion => 'Cualquier región';

  @override
  String webSearch_countryDeviceDefault(String name) {
    return '$name (dispositivo)';
  }

  @override
  String get webSearch_safeSearchPillDefault => 'Filtro: predet.';

  @override
  String get webSearch_safeSearchPillOff => 'Filtro: desact.';

  @override
  String get webSearch_safeSearchPillModerate => 'Filtro: moderado';

  @override
  String get webSearch_safeSearchPillStrict => 'Filtro: estricto';

  @override
  String get webSearch_safeSearchMenuDefault => 'Predeterminado (moderado)';

  @override
  String get webSearch_safeSearchMenuOff => 'Desactivado';

  @override
  String get webSearch_safeSearchMenuModerate => 'Moderado';

  @override
  String get webSearch_safeSearchMenuStrict => 'Estricto';

  @override
  String get webSearch_freshnessAnyTime => 'Cualquier fecha';

  @override
  String get webSearch_freshnessPastDay => 'Último día';

  @override
  String get webSearch_freshnessPastWeek => 'Última semana';

  @override
  String get webSearch_freshnessPastMonth => 'Último mes';

  @override
  String get webSearch_freshnessPastYear => 'Último año';

  @override
  String get webSearch_modeGeneralLabel => 'General';

  @override
  String get webSearch_modeIndependentWebLabel => 'Web independiente';

  @override
  String get webSearch_modeSmallWebLabel => 'Small Web';

  @override
  String get webSearch_modeGeneralDescription =>
      'Resultados equilibrados de toda la web abierta';

  @override
  String get webSearch_modeIndependentWebDescription =>
      'Priorizar fuentes más pequeñas y menos corporativas';

  @override
  String get webSearch_modeSmallWebDescription =>
      'Sitios independientes, personales y de nicho';

  @override
  String get webSearch_fetchTooltip => 'Obtener';

  @override
  String get webSearch_additionalSnippetsHeading => 'Fragmentos adicionales';

  @override
  String get webSearch_questionPrefix => 'P: ';

  @override
  String get webSearch_snippetsTooltip => 'Fragmentos';

  @override
  String webSearch_showMoreLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar $count enlaces más',
      one: 'Mostrar 1 enlace más',
    );
    return '$_temp0';
  }

  @override
  String get webSearch_factsheetHeading => 'Ficha';

  @override
  String get webSearch_searchFailedTitle => 'Error en la búsqueda';

  @override
  String get webSearch_searchingLabel => 'Buscando en la web...';

  @override
  String webSearch_noResultsFor(String query) {
    return 'No se encontraron resultados para «$query».';
  }

  @override
  String webSearch_creditsTokensStatus(int credits, int tokens) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '$credits créditos',
      one: '1 crédito',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tokens,
      locale: localeName,
      other: '$tokens tokens',
      one: '1 token',
    );
    return '$_temp0  |  $_temp1';
  }

  @override
  String get webSearch_needsCreditsMessage =>
      'No hay créditos ni tokens de búsqueda disponibles para una nueva búsqueda web.';

  @override
  String get webSearch_buySearchPackButton => 'Comprar un paquete de búsquedas';

  @override
  String get webSearch_socketConnectionError =>
      'Error de conexión de la búsqueda. Vuelve a intentarlo.';

  @override
  String get webSearch_closeErrorSessionTimeout =>
      'La sesión de búsqueda ha caducado. Vuelve a intentarlo.';

  @override
  String get webSearch_closeErrorCreditInvalid =>
      'No se pudo validar tu crédito de búsqueda. Es posible que ya se haya gastado; vuelve a intentarlo.';

  @override
  String get webSearch_closeErrorPolicyForbidden =>
      'La política de búsqueda no permite la página solicitada.';

  @override
  String get webSearch_closeErrorServerFailed =>
      'La búsqueda falló en el servidor. Vuelve a intentarlo.';

  @override
  String webSearch_closeErrorUnknown(int code) {
    return 'La conexión de la búsqueda se cerró inesperadamente (código $code). Vuelve a intentarlo.';
  }

  @override
  String get webSearch_unknownErrorDetail => 'error desconocido';

  @override
  String webSearch_streamErrorProtocol(String detail) {
    return 'Error de protocolo de búsqueda. La sesión ha finalizado; vuelve a intentarlo. ($detail)';
  }

  @override
  String webSearch_streamErrorSearchFailed(String detail) {
    return 'La búsqueda falló en el servidor. Vuelve a intentarlo. ($detail)';
  }

  @override
  String webSearch_streamErrorFetchFailed(String detail) {
    return 'No se pudo obtener esta página de su origen. ($detail)';
  }

  @override
  String webSearch_streamErrorExtractFailed(String detail) {
    return 'No se pudo extraer una vista previa legible de esta página. ($detail)';
  }

  @override
  String webSearch_streamErrorNotAllowed(String detail) {
    return 'La política de búsqueda no permite esta página. ($detail)';
  }

  @override
  String webSearch_streamErrorCaptureFailed(String detail) {
    return 'Error al capturar la página. ($detail)';
  }

  @override
  String webSearch_streamErrorGeneric(String detail) {
    return 'Error de búsqueda: $detail';
  }

  @override
  String webSearch_torStartFailed(String torBrand) {
    return 'No se pudo iniciar $torBrand para la búsqueda. Desactiva el interruptor de $torBrand o vuelve a intentarlo.';
  }

  @override
  String get webSearch_creditCheckFailed =>
      'No se pudieron comprobar los créditos de búsqueda. Vuelve a intentarlo.';

  @override
  String get webSearch_tokenIssuanceFailed =>
      'No se pudieron emitir tokens de búsqueda. Vuelve a intentarlo.';

  @override
  String get mainApp_initializationErrorTitle => 'Error de inicialización';

  @override
  String get mainApp_initializationErrorMessage =>
      'No se pudo inicializar la aplicación';

  @override
  String get mainApp_initStageLoadingFormats => 'Cargando formatos…';

  @override
  String get mainApp_initStageLoadingPackageInfo =>
      'Cargando información de la aplicación…';

  @override
  String get mainApp_initStageSyncingBangs => 'Sincronizando bangs…';

  @override
  String get mainApp_downloadCompleted => 'Descarga completada';

  @override
  String get mainApp_downloadOpenFailed =>
      'No se pudo abrir el archivo descargado';

  @override
  String mainApp_downloadFailed(String name) {
    return 'Error en la descarga: $name';
  }

  @override
  String mainApp_containerBlockedWithHost(String host) {
    return '$host no está asignado a este contenedor';
  }

  @override
  String get mainApp_containerBlockedNoHost =>
      'Este sitio no está asignado a este contenedor';

  @override
  String get mainApp_sandboxNoCredits =>
      'No te quedan créditos de búsqueda. Compra más para continuar.';

  @override
  String get mainApp_sandboxTokenIssuanceFailed =>
      'No se pudieron emitir nuevos tokens de búsqueda. Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String mainApp_sandboxFetchPolicyRejected(String detail) {
    return 'Captura bloqueada por la política de obtención: $detail';
  }

  @override
  String get mainApp_sandboxDetailNotAllowed => 'no permitido';

  @override
  String mainApp_sandboxCaptureFailed(String detail) {
    return 'Error en la captura: $detail';
  }

  @override
  String get mainApp_sandboxDetailUnknownError => 'error desconocido';

  @override
  String get mainApp_sandboxDownloadFailed =>
      'No se pudo descargar el resultado de la captura.';

  @override
  String mainApp_sandboxUnknownError(String detail) {
    return 'Error en la captura aislada: $detail';
  }

  @override
  String get mainApp_syncFailed => 'Error de sincronización';

  @override
  String get startup_pickerTitle => 'Elige un perfil';

  @override
  String startup_pickerEachProfileKeepsOwn(String contents) {
    return 'Cada perfil tiene sus propios datos: $contents.';
  }

  @override
  String get startup_pickerOpensByDefaultLocked =>
      'Se abre de forma predeterminada · Bloqueado';

  @override
  String get startup_pickerOpensByDefault => 'Se abre de forma predeterminada';

  @override
  String get startup_pickerLocked => 'Bloqueado';

  @override
  String get startup_haltMaintenanceTitle => 'Trabajo de perfil sin terminar';

  @override
  String get startup_haltMaintenanceBody =>
      'Una copia de seguridad, restauración o eliminación de una ejecución anterior no terminó. WebLibre debe terminarla antes de poder abrir ningún perfil.';

  @override
  String get startup_haltUnavailableTitle => 'El inicio no está listo';

  @override
  String startup_haltUnavailableBody(String reopenToContinue) {
    return 'WebLibre tiene que reiniciarse antes de poder elegir un perfil. $reopenToContinue';
  }

  @override
  String get startup_haltProfileAccessBusyTitle => 'El perfil está en uso';

  @override
  String get startup_haltProfileAccessBusyBody =>
      'Otra tarea de WebLibre todavía está usando este perfil. Vuelve a intentarlo en un momento.';

  @override
  String get startup_haltNoProfileTitle => 'No hay ningún perfil utilizable';

  @override
  String get startup_haltNoProfileBody =>
      'WebLibre no pudo leer un perfil existente ni crear uno nuevo. Puede que el almacenamiento esté lleno o no esté disponible.';

  @override
  String get startup_haltArbitrationFailedTitle =>
      'No se sabe qué perfil abrir';

  @override
  String startup_haltArbitrationFailedBody(String reopenToContinue) {
    return 'WebLibre no intentará adivinar qué perfil usar. $reopenToContinue';
  }

  @override
  String get startup_tryAgain => 'Reintentar';

  @override
  String get startup_tryingAgain => 'Reintentando…';

  @override
  String get startup_closeWebLibre => 'Cerrar WebLibre';

  @override
  String get startup_technicalDetails => 'Detalles técnicos';

  @override
  String get startup_copyDetails => 'Copiar detalles';

  @override
  String get startup_maintenanceFinishingInterrupted =>
      'Terminando el trabajo interrumpido por un reinicio anterior…';

  @override
  String get startup_maintenanceNotRunnableUnsupported =>
      'Esta tarea la creó una versión más reciente de WebLibre y no se puede ejecutar aquí.';

  @override
  String get startup_maintenanceNotRunnableNoDestination =>
      'Esta copia de seguridad no tiene registrada ninguna carpeta de destino.';

  @override
  String get startup_maintenanceNotRunnableNoBackupFile =>
      'Esta restauración no tiene registrado ningún archivo de copia de seguridad.';

  @override
  String get startup_maintenanceNotRunnableRestoreHere =>
      'WebLibre no puede restaurar desde esta pantalla de inicio.';

  @override
  String get startup_maintenanceNotRunnableDeleteHere =>
      'WebLibre no puede eliminar un perfil desde esta pantalla de inicio.';

  @override
  String get startup_maintenanceRecoveredRestore =>
      'Se completó una restauración interrumpida.';

  @override
  String get startup_maintenanceRecoveredRestoreRolledBack =>
      'Se deshizo una restauración interrumpida. El perfil se dejó como estaba.';

  @override
  String get startup_maintenanceRecoveredRestoreReconciled =>
      'Se resolvió una restauración interrumpida. Revisa el perfil para ver si se aplicó la copia de seguridad.';

  @override
  String get startup_maintenanceRecoveredDeletion =>
      'Se completó una eliminación interrumpida.';

  @override
  String get startup_maintenanceTaskDidNotFinish => 'No se terminó.';

  @override
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  ) {
    return 'WebLibre ya no puede trabajar de forma segura en este perfil. $nothingChanged $reopenToContinue';
  }

  @override
  String startup_maintenanceTaskCancelled(String task) {
    return 'Se canceló la tarea: $task.';
  }

  @override
  String get startup_maintenanceEvidenceDiscarded =>
      'Se descartó el registro interrumpido.';

  @override
  String get startup_maintenanceEvidenceDiscardedKept =>
      'Se descartó el registro interrumpido. WebLibre no pudo saber a qué perfil pertenecían los datos guardados, así que los conservó en el dispositivo en lugar de eliminarlos.';

  @override
  String startup_maintenanceWrongPassword(String nothingChanged) {
    return 'La contraseña no abrió este archivo de copia de seguridad. Compruébala y vuelve a intentarlo. $nothingChanged';
  }

  @override
  String startup_maintenanceUnreadableArchive(String nothingChanged) {
    return 'La contraseña no abrió este archivo de copia de seguridad, o el archivo está dañado. Comprueba la contraseña y vuelve a intentarlo. $nothingChanged';
  }

  @override
  String startup_maintenanceDamagedArchive(String nothingChanged) {
    return 'Este archivo de copia de seguridad está dañado y no se pudo leer. $nothingChanged';
  }

  @override
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged) {
    return 'Este archivo de copia de seguridad lo creó una versión más reciente de WebLibre y no se puede leer aquí. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  ) {
    return 'No hay suficiente espacio libre: se necesitan unos $required, pero solo hay $free disponibles. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  ) {
    return 'No hay suficiente espacio libre: se necesitan unos $required. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged) {
    return 'No hay suficiente espacio libre para hacer esto. $nothingChanged';
  }

  @override
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged) {
    return 'No se pudo escribir la copia de seguridad en la carpeta. Vuelve a elegir la carpeta e inténtalo de nuevo. $nothingChanged';
  }

  @override
  String get startup_maintenanceProfileNoLongerExists =>
      'Ese perfil ya no existe.';

  @override
  String get startup_maintenanceRestoreEvidenceUnresolved =>
      'Un intento anterior de esta restauración dejó un registro que aún no se ha resuelto.';

  @override
  String get startup_maintenanceRestoreWrongProfile =>
      'Esta copia de seguridad no corresponde al perfil que iba a reemplazar.';

  @override
  String get startup_maintenanceRestoreRejected =>
      'Este archivo de copia de seguridad no se puede restaurar.';

  @override
  String get startup_maintenanceRestoreIncomplete =>
      'El archivo de copia de seguridad está incompleto.';

  @override
  String get startup_maintenanceRestoreNoMetadata =>
      'El archivo de copia de seguridad no tiene metadatos del perfil.';

  @override
  String get startup_maintenanceRestoreMalformedMetadata =>
      'No se pudieron leer los metadatos del perfil del archivo de copia de seguridad.';

  @override
  String get startup_maintenanceRestoreNoProfileData =>
      'El archivo de copia de seguridad no contiene datos del perfil.';

  @override
  String get startup_maintenanceHeadline => 'Mantenimiento de perfiles';

  @override
  String get startup_maintenanceMustFinish =>
      'Esta tarea debe terminar antes de poder abrir ningún perfil. WebLibre mantiene el perfil cerrado mientras trabaja.';

  @override
  String get startup_maintenanceNothingLeft => 'No queda nada por terminar.';

  @override
  String get startup_maintenanceCannotReadRecord =>
      'WebLibre encontró trabajo de perfil interrumpido, pero no puede leer su registro.';

  @override
  String get startup_maintenancePasswordLabel =>
      'Contraseña del archivo de copia de seguridad';

  @override
  String get startup_maintenancePasswordRejected =>
      'Esta contraseña no abrió el archivo de copia de seguridad';

  @override
  String get startup_maintenancePasswordHelperRequiredBackup =>
      'Obligatoria. La necesitarás para restaurar la copia de seguridad y no se guarda en ningún sitio.';

  @override
  String get startup_maintenancePasswordHelperRequiredRestore =>
      'Obligatoria. Introduce la contraseña con la que se creó este archivo de copia de seguridad.';

  @override
  String get startup_maintenancePasswordHelperBackup =>
      'La necesitarás para restaurar la copia de seguridad. No se guarda en ningún sitio.';

  @override
  String get startup_maintenancePasswordHelperRestore =>
      'La contraseña con la que se creó este archivo de copia de seguridad.';

  @override
  String get startup_maintenanceTryFinishingAgain =>
      'Intentar terminarla de nuevo';

  @override
  String get startup_maintenanceDiscardAndContinueBlocked =>
      'Descartar el registro y continuar';

  @override
  String get startup_maintenanceDiscardAndContinueNoTasks =>
      'Descartar el registro y continuar';

  @override
  String get startup_maintenanceOpenWebLibreRetry => 'Abrir WebLibre';

  @override
  String get startup_maintenanceOpenWebLibre => 'Abrir WebLibre';

  @override
  String get startup_maintenanceTakesSeveralMinutes =>
      'Esto puede tardar varios minutos. Mantén WebLibre abierto.';

  @override
  String get startup_maintenanceThenAfterThisOne => 'Después de esta';

  @override
  String get startup_maintenanceSkipForNow => 'Omitir por ahora';

  @override
  String get startup_maintenanceInterruptedMustFinish =>
      'Esto se interrumpió después de empezar. Debe terminar antes de poder abrir ningún perfil.';

  @override
  String get startup_maintenanceInterruptedFinishFailed =>
      'Esto se interrumpió después de empezar y no se pudo terminar. No se puede volver a empezar hasta que se haya terminado.';

  @override
  String get startup_maintenanceInterruptedUnreadable =>
      'Esto se interrumpió después de empezar y WebLibre no puede leer lo que estaba haciendo. No se puede volver a ejecutar hasta que se resuelva ese registro.';

  @override
  String get startup_maintenanceDiscardDialogTitle =>
      '¿Descartar el registro interrumpido?';

  @override
  String get startup_maintenanceDiscardDialogContent =>
      'WebLibre no puede leer qué estaba haciendo una copia de seguridad, restauración o eliminación cuando se detuvo. Descartar el registro permite volver a abrir el navegador, pero puede que después haya que revisar un perfil que se estaba reemplazando.\n\nSi falta el perfil, WebLibre restaura los datos que guardó antes de reemplazarlo. Si el perfil existe, WebLibre elimina esos datos guardados. Si WebLibre no puede saber a qué perfil pertenecen los datos guardados, los conserva en lugar de eliminarlos.';

  @override
  String get startup_maintenanceDiscardIt => 'Descartarlo';

  @override
  String get startup_maintenanceBackupVerb => 'Hacer copia ahora';

  @override
  String get startup_maintenanceBackupRetry =>
      'Reintentar la copia de seguridad';

  @override
  String get startup_maintenanceBackupCancel =>
      'Cancelar esta copia de seguridad';

  @override
  String startup_maintenanceBackupDescribe(String profileName) {
    return 'Hacer copia de seguridad de «$profileName»';
  }

  @override
  String startup_maintenanceBackupConsequence(String secretDataDescription) {
    return 'Escribe un archivo cifrado de copia de seguridad de este perfil, que incluye su $secretDataDescription.';
  }

  @override
  String startup_maintenanceBackupActivity(String profileName) {
    return 'Empaquetando «$profileName»…';
  }

  @override
  String startup_maintenanceBackupDescribeDone(String profileName) {
    return 'Se hizo una copia de seguridad de «$profileName» en la carpeta que elegiste.';
  }

  @override
  String get startup_maintenanceRestoreOverVerb => 'Reemplazar ahora';

  @override
  String get startup_maintenanceRestoreOverRetry =>
      'Reintentar la restauración';

  @override
  String get startup_maintenanceRestoreOverCancel =>
      'Cancelar esta restauración';

  @override
  String startup_maintenanceRestoreOverDescribe(String profileName) {
    return 'Reemplazar «$profileName»';
  }

  @override
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Reemplaza todo el contenido de este perfil por la copia de seguridad. $signedInFromBackup $olderBackupKeepsCredentials También adopta el nombre de la copia de seguridad. $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Reemplaza todo el contenido de este perfil por la copia de seguridad. $signedInFromBackup $olderBackupKeepsCredentials $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverActivity(String profileName) {
    return 'Reemplazando «$profileName»…';
  }

  @override
  String startup_maintenanceRestoreOverDescribeDone(String profileName) {
    return '«$profileName» se reemplazó por la copia de seguridad.';
  }

  @override
  String get startup_maintenanceDeleteVerb => 'Eliminar ahora';

  @override
  String get startup_maintenanceDeleteRetry => 'Reintentar la eliminación';

  @override
  String get startup_maintenanceDeleteCancel => 'Cancelar esta eliminación';

  @override
  String startup_maintenanceDeleteDescribe(String profileName) {
    return 'Eliminar «$profileName»';
  }

  @override
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Elimina este perfil y sus datos: $profileDataDescription. $cannotBeUndone';
  }

  @override
  String startup_maintenanceDeleteActivity(String profileName) {
    return 'Eliminando «$profileName»…';
  }

  @override
  String startup_maintenanceDeleteDescribeDone(String profileName) {
    return 'Se eliminó «$profileName».';
  }

  @override
  String get startup_maintenanceRestoreCloneVerb => 'No se puede ejecutar';

  @override
  String get startup_maintenanceRestoreCloneRetry =>
      'Reintentar la restauración';

  @override
  String get startup_maintenanceRestoreCloneCancel =>
      'Cancelar esta restauración';

  @override
  String startup_maintenanceRestoreCloneDescribe(String profileName) {
    return 'Restaurar «$profileName»';
  }

  @override
  String get startup_maintenanceRestoreCloneConsequence =>
      'Esta restauración la creó una versión más reciente de WebLibre y no se puede ejecutar aquí.';

  @override
  String startup_maintenanceRestoreCloneActivity(String profileName) {
    return 'Restaurando «$profileName»…';
  }

  @override
  String startup_maintenanceRestoreCloneDescribeDone(String profileName) {
    return 'Se restauró «$profileName».';
  }

  @override
  String get startup_maintenanceUnknownVerb => 'Ejecutar';

  @override
  String get startup_maintenanceUnknownRetry => 'Reintentar la tarea';

  @override
  String get startup_maintenanceUnknownCancel => 'Cancelar esta tarea';

  @override
  String startup_maintenanceUnknownDescribe(String taskId) {
    return 'Tarea desconocida $taskId';
  }

  @override
  String get startup_maintenanceUnknownConsequence =>
      'Esta tarea la creó una versión más reciente de WebLibre y no se puede ejecutar.';

  @override
  String get startup_maintenanceUnknownActivity => 'Trabajando…';

  @override
  String get startup_maintenanceUnknownDescribeDone => 'Hecho.';

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
    return '$value ms';
  }

  @override
  String get failureWidget_defaultTitle => 'Algo ha salido mal';

  @override
  String get failureWidget_unknownError => 'Error desconocido';

  @override
  String get speechToTextButton_serviceNotAvailable =>
      'El reconocimiento de voz no está disponible';

  @override
  String get formValidators_urlRequired => 'Se necesita una URL';

  @override
  String get formValidators_invalidUrl => 'URL no válida';

  @override
  String get formValidators_valueRequired => 'Valor obligatorio';

  @override
  String get formValidators_nameRequired => 'Nombre obligatorio';

  @override
  String get formValidators_nameInvalidCharacters =>
      'El nombre contiene caracteres no válidos';

  @override
  String uiHelper_findInPageSuggestion(String query) {
    return '¿Buscar «$query» en esta página?';
  }

  @override
  String get uiHelper_actionFind => 'Buscar';

  @override
  String uiHelper_openedTabsFromAnotherDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se abrieron $count pestañas de otro dispositivo',
      one: 'Se abrió 1 pestaña de otro dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_navigateBackToCloseTab =>
      'Pulsa ATRÁS otra vez para cerrar la pestaña actual';

  @override
  String get uiHelper_navigateBackToExitApp =>
      'Pulsa ATRÁS otra vez para salir de la aplicación';

  @override
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName) {
    return 'Nueva pestaña «$tabName» abierta en segundo plano';
  }

  @override
  String get uiHelper_newTabOpenedInBackground =>
      'Nueva pestaña abierta en segundo plano';

  @override
  String get uiHelper_actionShow => 'Mostrar';

  @override
  String get uiHelper_wantToOpenLinkFromClipboard =>
      '¿Abrir el enlace del portapapeles?';

  @override
  String uiHelper_newTabOpenedNamed(String tabName) {
    return 'Nueva pestaña «$tabName» abierta';
  }

  @override
  String get uiHelper_newTabOpened => 'Nueva pestaña abierta';

  @override
  String get uiHelper_actionSwitch => 'Cambiar';

  @override
  String uiHelper_couldNotLaunchUrl(String url) {
    return 'No se pudo abrir la URL ($url)';
  }

  @override
  String uiHelper_canNotHandleScheme(String scheme) {
    return 'No se puede abrir «$scheme»';
  }

  @override
  String uiHelper_tabsClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pestañas cerradas',
      one: 'Pestaña cerrada',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_closeIsolatedTabsTitle =>
      '¿Cerrar las pestañas aisladas?';

  @override
  String uiHelper_closeIsolatedTabsConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se borrarán de forma permanente los datos de navegación de $count sesiones aisladas.',
      one:
          'Se borrarán de forma permanente todos los datos de navegación de esta sesión aislada.',
    );
    return '$_temp0';
  }
}
