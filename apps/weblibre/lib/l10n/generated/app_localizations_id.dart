// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get common_cancel => 'Batal';

  @override
  String get common_delete => 'Hapus';

  @override
  String get common_close => 'Tutup';

  @override
  String get common_save => 'Simpan';

  @override
  String get common_add => 'Tambah';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_remove => 'Hapus';

  @override
  String get common_clear => 'Bersihkan';

  @override
  String get common_copy => 'Salin';

  @override
  String get common_open => 'Buka';

  @override
  String get common_reset => 'Atur ulang';

  @override
  String get common_retry => 'Coba lagi';

  @override
  String get common_done => 'Selesai';

  @override
  String get common_undo => 'Urungkan';

  @override
  String get common_dismiss => 'Tutup';

  @override
  String get common_discard => 'Buang';

  @override
  String get common_showLess => 'Tampilkan lebih sedikit';

  @override
  String get common_loading => 'Memuat…';

  @override
  String get profileCopy_pickerContents => 'tab, riwayat, dan pengaturan';

  @override
  String get profileCopy_dataDescription =>
      'tab, riwayat, markah, pengaturan, dan info masuk situs yang tersimpan';

  @override
  String get profileCopy_secretDataDescription =>
      'info masuk akun WebLibre, penyiapan sinkronisasi, dan detail proksi';

  @override
  String get profileCopy_cannotBeUndone =>
      'Tindakan ini tidak dapat diurungkan.';

  @override
  String get profileCopy_nothingChanged => 'Tidak ada yang diubah.';

  @override
  String get profileCopy_restartsToWork =>
      'WebLibre harus dimulai ulang untuk melakukan ini.';

  @override
  String get profileCopy_asksPasswordAfterRestart =>
      'Setelah dimulai ulang, WebLibre akan meminta kata sandi berkas cadangan.';

  @override
  String get profileCopy_reopenToContinue =>
      'Tutup WebLibre, lalu buka kembali.';

  @override
  String get profileCopy_signedInFromBackup =>
      'Profil yang dipulihkan menggunakan akun WebLibre dari cadangan.';

  @override
  String get profileCopy_olderBackupKeepsCredentials =>
      'Cadangan yang dibuat oleh versi WebLibre yang lebih lama tidak memuat data tersebut, sehingga profil tetap memakai info masuk dan kredensialnya saat ini.';

  @override
  String profileCopy_restartCouldNotBeScheduled(String nothingChanged) {
    return 'WebLibre tidak dapat menjadwalkan mulai ulang yang diperlukan untuk operasi ini. $nothingChanged';
  }

  @override
  String get profileCopy_shortcutsNeedPinningAgain =>
      'Sematkan kembali pintasan layar utama setelah pemulihan.';

  @override
  String get profileCopy_restartClosesCurrentProfile =>
      'Ini juga menutup profil yang sedang Anda gunakan, yang belum tentu profil yang disebutkan di sini.';

  @override
  String get profileCopy_restartKeepsOtherTabs =>
      'Tab Anda yang lain akan dibuka kembali setelahnya.';

  @override
  String profileCopy_privateTabsClosedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab pribadi ditutup dan data penjelajahannya dihapus.',
      one: '1 tab pribadi ditutup dan data penjelajahannya dihapus.',
    );
    return '$_temp0';
  }

  @override
  String profileCopy_containersClearedByRestart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count kontainer yang diatur untuk menghapus data saat keluar akan dibersihkan.',
      one:
          '1 kontainer yang diatur untuk menghapus data saat keluar akan dibersihkan.',
    );
    return '$_temp0';
  }

  @override
  String get httpErrorHandler_socketError =>
      'Tidak dapat menghubungi layanan jarak jauh';

  @override
  String get httpErrorHandler_httpError => 'Permintaan web mengembalikan galat';

  @override
  String get httpErrorHandler_formatError => 'Format respons tidak valid';

  @override
  String get httpErrorHandler_clientError =>
      'Tidak dapat menghubungi layanan jarak jauh';

  @override
  String profileDiscovery_recoveredProfileName(String idFragment) {
    return 'Profil yang dipulihkan $idFragment';
  }

  @override
  String get about_copyright => 'Hak Cipta © Fabian Freund, 2024-2026';

  @override
  String get about_geckoVersionTitle => 'Versi Gecko';

  @override
  String get about_notAvailable => 'T/A';

  @override
  String get about_feedbackTitle => 'Masukan';

  @override
  String get about_donateTitle => 'Donasi';

  @override
  String get about_documentationTitle => 'Dokumentasi';

  @override
  String get about_githubTitle => 'GitHub';

  @override
  String get account_screenTitle => 'Akun WebLibre';

  @override
  String get account_searchHint => 'Cari pengaturan akun';

  @override
  String get account_loadFailed => 'Gagal memuat akun';

  @override
  String get account_sectionAccount => 'Akun';

  @override
  String get account_sectionSubscription => 'Langganan';

  @override
  String get account_sectionSearchCredits => 'Kredit Pencarian';

  @override
  String get account_sectionSettingsSnapshots => 'Snapshot Pengaturan';

  @override
  String get account_sectionPreferencesSnapshots => 'Snapshot Preferensi';

  @override
  String get account_sectionEncryptedSync => 'Sinkronisasi Terenkripsi';

  @override
  String get account_signInTitle => 'Masuk ke Akun WebLibre';

  @override
  String get account_signInKeywords =>
      'masuk, akun, autentikasi, login, sign in, account';

  @override
  String get account_signInSyncKeyKeywords =>
      'kunci sinkronisasi, atur ulang kunci, sync key, reset sync key';

  @override
  String get account_signingInTitle => 'Sedang masuk';

  @override
  String get account_signedInTitle => 'Akun yang masuk';

  @override
  String get account_signInFailedTitle => 'Gagal masuk';

  @override
  String get account_syncAcrossDevicesSubtitle =>
      'Sinkronkan pengaturan Anda di berbagai perangkat';

  @override
  String get account_signingInSubtitle =>
      'Selesaikan proses masuk di peramban Anda';

  @override
  String get account_signedInFallback => 'Sudah masuk';

  @override
  String get account_entrySupporterSubscriptionTitle => 'Langganan pendukung';

  @override
  String get account_entrySupporterSubscriptionKeywords =>
      'tagihan, pembayaran, pendukung, billing, supporter';

  @override
  String get account_entrySupporterSubscriptionSubtitle =>
      'Status, tagihan, dan pengelolaan langganan';

  @override
  String get account_entrySearchCreditsTitle => 'Kredit pencarian';

  @override
  String get account_entrySearchCreditsKeywords =>
      'token, paket pencarian, search pack';

  @override
  String get account_entrySearchCreditsSubtitle =>
      'Saldo kredit, penerbitan token, dan pembelian';

  @override
  String get account_entrySettingsSnapshotsTitle => 'Snapshot pengaturan';

  @override
  String get account_entrySettingsSnapshotsKeywords =>
      'cadangan, sinkronisasi pengaturan, backups, settings sync';

  @override
  String get account_entrySettingsSnapshotsSubtitle =>
      'Simpan dan pulihkan pengaturan aplikasi yang disinkronkan';

  @override
  String get account_entryPreferencesSnapshotsTitle => 'Snapshot preferensi';

  @override
  String get account_entryPreferencesSnapshotsKeywords =>
      'cadangan, sinkronisasi preferensi, backups, prefs sync';

  @override
  String get account_entryPreferencesSnapshotsSubtitle =>
      'Simpan dan pulihkan dokumen preferensi yang disinkronkan';

  @override
  String get account_entrySetupEncryptedSyncTitle =>
      'Siapkan sinkronisasi terenkripsi';

  @override
  String get account_entrySetupEncryptedSyncKeywords =>
      'kunci sinkronisasi, cadangan, snapshot, sync key, backups';

  @override
  String get account_entrySetupEncryptedSyncSubtitle =>
      'Aktifkan sinkronisasi terenkripsi ujung ke ujung menggunakan kata sandi akun Anda';

  @override
  String get account_actionRestore => 'Pulihkan';

  @override
  String get account_actionEditLabel => 'Edit Label';

  @override
  String get account_actionStore => 'Simpan';

  @override
  String get account_actionTryAgain => 'Coba Lagi';

  @override
  String get account_actionSignOut => 'Keluar';

  @override
  String get account_actionEnableSync => 'Aktifkan Sinkronisasi';

  @override
  String get account_adoptTitleUsable =>
      'Info masuk lama masih ada di perangkat ini';

  @override
  String get account_adoptTitleUnusable => 'Info masuk lama tidak dapat dibaca';

  @override
  String account_adoptBodyUsable(String name) {
    return 'WebLibre menyimpan info masuk untuk $name dari masa sebelum setiap profil memiliki akun terpisah. Info masuk ini bukan dari cadangan, dan tidak ada catatan di perangkat ini tentang profil mana pemiliknya, jadi WebLibre tidak akan menebak.';
  }

  @override
  String get account_adoptBodyUnusable =>
      'WebLibre menyimpan info masuk dari masa sebelum setiap profil memiliki akun terpisah, tetapi data tersimpannya rusak dan tidak dapat digunakan untuk masuk. Satu-satunya cara adalah masuk kembali; menghapusnya akan menghilangkan pesan ini.';

  @override
  String get account_adoptRetryError =>
      'Tidak berhasil. Periksa koneksi Anda, lalu coba lagi.';

  @override
  String get account_adoptNotMine => 'Bukan milik saya';

  @override
  String get account_adoptRemoveIt => 'Hapus';

  @override
  String get account_adoptUseItHere => 'Gunakan di sini';

  @override
  String get account_forgetSignInTitle => 'Lupakan info masuk ini?';

  @override
  String account_forgetSignInContent(String name) {
    return 'Sesi tersimpan untuk $name akan dihapus dari perangkat ini. Jika sesi itu milik profil lain, Anda harus masuk kembali di sana.';
  }

  @override
  String get account_actionForgetIt => 'Lupakan';

  @override
  String get account_previousSignInFallback => 'info masuk sebelumnya';

  @override
  String account_signInAgainAs(String account) {
    return 'Masuk kembali sebagai $account';
  }

  @override
  String get account_signInExpiredSubtitle =>
      'Info masuk tersimpan untuk profil ini telah kedaluwarsa. Kunci sinkronisasi Anda tetap disimpan.';

  @override
  String get account_signingInEllipsis => 'Sedang masuk...';

  @override
  String get account_completeSignInInApp =>
      'Selesaikan proses masuk di WebLibre';

  @override
  String get account_tooltipSignOut => 'Keluar';

  @override
  String get account_signOutConfirmTitle => 'Keluar?';

  @override
  String get account_signOutConfirmContent =>
      'Yakin ingin keluar dari Akun WebLibre Anda?';

  @override
  String get account_resetSyncKeyTitle => 'Atur Ulang Kunci Sinkronisasi';

  @override
  String get account_resetSyncKeySubtitle =>
      'Masukkan ulang kata sandi Anda jika salah ketik atau telah diubah';

  @override
  String get account_resetSyncKeyConfirmContent =>
      'Anda perlu memasukkan ulang kata sandi akun Anda. Jika kata sandi Anda telah berubah, snapshot yang ada yang dienkripsi dengan kata sandi lama tidak dapat didekripsi lagi.';

  @override
  String get account_subscriptionLoadFailed => 'Tidak dapat memuat langganan';

  @override
  String get account_checkConnectionRetry =>
      'Periksa koneksi Anda, lalu coba lagi.';

  @override
  String get account_planFallbackSupporter => 'Pendukung';

  @override
  String get account_badgeWillNotRenew => 'Tidak diperpanjang';

  @override
  String get account_badgeActive => 'Aktif';

  @override
  String account_untilDate(String date) {
    return 'Hingga $date';
  }

  @override
  String get account_actionManageSubscription => 'Kelola Langganan';

  @override
  String get account_badgePaused => 'Dijeda';

  @override
  String get account_pausedNote =>
      'Langganan Anda sedang dijeda. Lanjutkan dari portal pelanggan untuk memulihkan akses.';

  @override
  String get account_badgePastDue => 'Lewat jatuh tempo';

  @override
  String get account_pastDueNote =>
      'Pembayaran gagal. Perbarui metode pembayaran Anda agar langganan tetap aktif.';

  @override
  String get account_actionUpdatePaymentMethod => 'Perbarui Metode Pembayaran';

  @override
  String get account_endedNote =>
      'Langganan Anda telah berakhir. Perpanjang dari portal pelanggan untuk melanjutkan.';

  @override
  String get account_actionRenewSubscription => 'Perpanjang Langganan';

  @override
  String get account_planSupporterSubscription => 'Langganan Pendukung';

  @override
  String get account_subscribeSubtitle =>
      'Berlangganan untuk membuka fitur sinkronisasi';

  @override
  String get account_badgeInactive => 'Tidak aktif';

  @override
  String get account_actionSubscribe => 'Berlangganan';

  @override
  String get account_tooltipRefreshStatus => 'Segarkan status';

  @override
  String account_subscriptionEndsOn(String date) {
    return 'Langganan Anda akan berakhir pada $date';
  }

  @override
  String get account_bannerTitle => 'Dukung WebLibre';

  @override
  String get account_bannerBody =>
      'Langganan Pendukung bersifat opsional, mendanai pengembangan WebLibre, dan menyediakan fitur yang memerlukan layanan terhosting. Peramban dan fitur privasinya tidak memerlukan langganan. <learnMore>Pelajari lebih lanjut</learnMore>.';

  @override
  String get account_featureSearchLabel => 'WebLibre Search';

  @override
  String get account_featureSearchDescription =>
      'Pencarian pribadi tanpa iklan yang terintegrasi dalam peramban. Fitur ini memadukan hasil dari beberapa sumber independen, menawarkan mode pencarian yang dapat disesuaikan, dapat disalurkan melalui Tor, dan memungkinkan Anda meninjau halaman dengan aman. Berkat rancangannya, pencarian Anda tidak dapat dikaitkan dengan akun Anda.';

  @override
  String get account_featureSyncLabel => 'Sinkronisasi akun terenkripsi';

  @override
  String get account_featureSyncDescription =>
      'Simpan dan pulihkan pengaturan dan preferensi WebLibre Anda di berbagai profil dan perangkat. Semuanya dienkripsi di perangkat Anda sebelum diunggah, sehingga hanya Anda yang dapat membacanya.';

  @override
  String get account_becomeSupporter => 'Jadi Pendukung';

  @override
  String get account_syncSetupEnterPassword =>
      'Silakan masukkan kata sandi Anda';

  @override
  String get account_syncSetupPasswordsMismatch => 'Kata sandi tidak cocok';

  @override
  String get account_syncSetupPasswordMismatchBackup =>
      'Kata sandi tidak cocok dengan cadangan terenkripsi Anda yang sudah ada.';

  @override
  String account_syncSetupFailed(String error) {
    return 'Gagal menyiapkan sinkronisasi: $error';
  }

  @override
  String get account_syncSetupTitle => 'Siapkan Sinkronisasi Terenkripsi';

  @override
  String get account_syncSetupDescription =>
      'Masukkan kata sandi akun Anda untuk mengaktifkan sinkronisasi terenkripsi ujung ke ujung. Data Anda dienkripsi di perangkat sebelum diunggah — server tidak pernah melihat pengaturan Anda.';

  @override
  String get account_fieldAccountPassword => 'Kata Sandi Akun';

  @override
  String get account_fieldConfirmPassword => 'Konfirmasi Kata Sandi';

  @override
  String account_failedLoadSnapshots(String error) {
    return 'Gagal memuat snapshot: $error';
  }

  @override
  String account_syncKindStored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Pengaturan disimpan',
      'geckoUserJs': 'Preferensi Gecko disimpan',
      'other': 'Snapshot disimpan',
    });
    return '$_temp0';
  }

  @override
  String account_syncKindSnapshotsTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Snapshot Pengaturan',
      'geckoUserJs': 'Snapshot Preferensi Gecko',
      'other': 'Snapshot',
    });
    return '$_temp0';
  }

  @override
  String get account_storeCurrentTitle => 'Simpan Data Saat Ini';

  @override
  String account_storeCurrentSubtitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Enkripsi dan unggah pengaturan saat ini',
      'geckoUserJs': 'Enkripsi dan unggah preferensi Gecko saat ini',
      'other': 'Enkripsi dan unggah data saat ini',
    });
    return '$_temp0';
  }

  @override
  String get account_noSnapshotsYet => 'Belum ada snapshot yang disimpan';

  @override
  String account_failedToStore(String error) {
    return 'Gagal menyimpan: $error';
  }

  @override
  String account_syncKindRestored(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'weblibreSettings': 'Pengaturan dipulihkan',
      'geckoUserJs': 'Preferensi Gecko dipulihkan',
      'other': 'Snapshot dipulihkan',
    });
    return '$_temp0';
  }

  @override
  String get account_snapshotNotFound => 'Snapshot tidak ditemukan';

  @override
  String get account_decryptionFailed =>
      'Dekripsi gagal — kata sandi salah atau data rusak. Coba atur ulang kunci sinkronisasi Anda.';

  @override
  String account_failedToRestore(String error) {
    return 'Gagal memulihkan: $error';
  }

  @override
  String account_failedUpdateLabel(String error) {
    return 'Gagal memperbarui label: $error';
  }

  @override
  String get account_snapshotDeleted => 'Snapshot dihapus';

  @override
  String account_failedToDelete(String error) {
    return 'Gagal menghapus: $error';
  }

  @override
  String get account_untitledSnapshot => 'Tanpa judul';

  @override
  String get account_metaLabel => 'Label';

  @override
  String get account_metaStored => 'Disimpan';

  @override
  String get account_metaAppVersion => 'Versi aplikasi';

  @override
  String get account_metaDevice => 'Perangkat';

  @override
  String get account_storeSnapshotTitle => 'Simpan Snapshot';

  @override
  String get account_fieldLabelOptional => 'Label (opsional)';

  @override
  String get account_labelHintExample =>
      'mis. \"Sebelum pembaruan\", \"Pengaturan rumah\"';

  @override
  String get account_fieldLabel => 'Label';

  @override
  String get account_restoreSnapshotTitle => 'Pulihkan Snapshot';

  @override
  String get account_restoreOverwriteWarning =>
      'Ini akan menimpa pengaturan lokal Anda saat ini.';

  @override
  String get account_thisSnapshotFallback => 'snapshot ini';

  @override
  String get account_deleteSnapshotTitle => 'Hapus Snapshot';

  @override
  String account_deleteSnapshotConfirm(String label) {
    return 'Yakin ingin menghapus $label?';
  }

  @override
  String get account_authNetworkError =>
      'Galat jaringan. Periksa koneksi Anda, lalu coba lagi.';

  @override
  String get account_authSessionExpiredWithKey =>
      'Info masuk tersimpan Anda sudah tidak berlaku. Masuk kembali untuk menyelesaikan pemulihan akun ini — kunci sinkronisasi Anda tetap disimpan.';

  @override
  String get account_authSessionExpiredNoKey =>
      'Info masuk tersimpan Anda sudah tidak berlaku. Masuk kembali untuk melanjutkan.';

  @override
  String get account_authRestoreFailedFallback =>
      'Tidak dapat memulihkan sesi akun Anda. Akan dicoba lagi sebentar lagi.';

  @override
  String get account_authSignInTimedOut =>
      'Waktu masuk habis. Silakan coba lagi.';

  @override
  String get account_authSignInOpenPageFailed =>
      'Tidak dapat membuka halaman masuk. Silakan coba lagi.';

  @override
  String get account_authNoPendingSignIn =>
      'Tidak ada proses masuk yang tertunda. Silakan mulai masuk lagi.';

  @override
  String get account_authSignInVerificationFailed =>
      'Proses masuk tidak dapat diverifikasi. Silakan coba lagi.';

  @override
  String get account_authSignInNotCompleted =>
      'Proses masuk tidak dapat diselesaikan. Silakan coba lagi.';

  @override
  String get account_authSignInFailedFallback =>
      'Gagal masuk. Silakan coba lagi.';

  @override
  String get addons_managerTitle => 'Ekstensi';

  @override
  String get addons_tabInstalled => 'Terpasang';

  @override
  String get addons_tabBrowse => 'Jelajahi';

  @override
  String get addons_loadFailedTitle => 'Gagal memuat ekstensi';

  @override
  String get addons_noExtensionsFound => 'Ekstensi tidak ditemukan.';

  @override
  String get addons_noneInstalledMessage =>
      'Belum ada ekstensi yang terpasang.\nJelajahi toko untuk menemukannya.';

  @override
  String get addons_genericTitle => 'Ekstensi';

  @override
  String get addons_notFound => 'Ekstensi ini tidak dapat ditemukan.';

  @override
  String get addons_platformAndroid => 'Android';

  @override
  String get addons_platformDesktop => 'Desktop';

  @override
  String get addons_searchHint => 'Cari di addons.mozilla.org';

  @override
  String get addons_desktopCompatibilityWarning =>
      'Ekstensi desktop tidak ditinjau untuk perangkat seluler. Sebagian mungkin tidak berfungsi, mogok, atau berperilaku tidak terduga di Android.';

  @override
  String get addons_actionInstall => 'Pasang';

  @override
  String get addons_actionInstallExtension => 'Pasang Ekstensi';

  @override
  String get addons_actionInstallFromFile => 'Pasang dari berkas';

  @override
  String get addons_actionViewPermissions => 'Lihat Izin';

  @override
  String get addons_actionRemoveExtension => 'Hapus Ekstensi';

  @override
  String get addons_actionNotNow => 'Jangan sekarang';

  @override
  String get addons_actionUpdate => 'Perbarui';

  @override
  String get addons_actionCheckForUpdates => 'Periksa pembaruan';

  @override
  String get addons_actionCheckForUpdatesButton => 'Periksa Pembaruan';

  @override
  String get addons_actionCheckingForUpdates => 'Memeriksa Pembaruan';

  @override
  String get addons_actionLearnMore => 'Pelajari Lebih Lanjut';

  @override
  String get addons_actionReadMore => 'Baca selengkapnya';

  @override
  String get addons_sectionEnabled => 'Aktif';

  @override
  String get addons_sectionDisabled => 'Nonaktif';

  @override
  String get addons_sectionUnsupported => 'Tidak didukung';

  @override
  String get addons_sectionDetails => 'Detail';

  @override
  String get addons_sectionDescription => 'Deskripsi';

  @override
  String get addons_sectionManagement => 'Pengelolaan';

  @override
  String get addons_sectionUpdates => 'Pembaruan';

  @override
  String get addons_sectionAboutExtension => 'Tentang ekstensi ini';

  @override
  String get addons_sectionTechnicalPermissions => 'Izin teknis';

  @override
  String get addons_sectionMoreInformation => 'Informasi lebih lanjut';

  @override
  String get addons_requiredDataCollectionTitle =>
      'Pengumpulan Data yang Diwajibkan';

  @override
  String get addons_tooltipRemoveExtension => 'Hapus ekstensi';

  @override
  String addons_extensionRemoved(String name) {
    return '$name dihapus';
  }

  @override
  String addons_extensionInstalled(String name) {
    return '$name terpasang';
  }

  @override
  String addons_installFailed(String error) {
    return 'Pemasangan gagal: $error';
  }

  @override
  String get addons_updateChecksStarted =>
      'Pemeriksaan pembaruan di latar belakang dimulai untuk ekstensi yang terpasang';

  @override
  String get addons_statusInstalled => 'Terpasang';

  @override
  String get addons_statusDisabled => 'Nonaktif';

  @override
  String get addons_statusAvailable => 'Tersedia';

  @override
  String get addons_chipPrivateBrowsing => 'Penjelajahan Pribadi';

  @override
  String get addons_chipRecommended => 'Direkomendasikan';

  @override
  String get addons_removeConfirmTitle => 'Hapus ekstensi?';

  @override
  String addons_removeConfirmContent(String name) {
    return 'Hapus $name dari WebLibre?';
  }

  @override
  String get addons_autoUpdateGloballyDisabled =>
      'Pembaruan otomatis global dinonaktifkan.';

  @override
  String get addons_autoUpdateNeedsManualRun =>
      'Jalankan pembaruan manual satu kali dan mulai ulang aplikasi sebelum pembaruan otomatis dapat diaktifkan.';

  @override
  String get addons_autoUpdateAllow =>
      'Izinkan ekstensi ini menerima pembaruan di latar belakang.';

  @override
  String get addons_autoUpdateDisabledForExtension =>
      'Pembaruan di latar belakang dinonaktifkan untuk ekstensi ini.';

  @override
  String get addons_switchEnabledTitle => 'Aktif';

  @override
  String get addons_switchEnabledSubtitleAllow =>
      'Izinkan ekstensi ini berjalan di WebLibre.';

  @override
  String get addons_switchEnabledSubtitleCannot =>
      'Ekstensi ini tidak dapat diaktifkan dengan aman.';

  @override
  String get addons_switchPrivateBrowsingTitle =>
      'Izinkan dalam Penjelajahan Pribadi';

  @override
  String get addons_switchPrivateBrowsingSubtitle =>
      'Izinkan ekstensi ini berjalan di tab penjelajahan pribadi.';

  @override
  String get addons_switchAutoUpdateTitle => 'Pembaruan otomatis';

  @override
  String get addons_switchPinTitle => 'Sematkan ke bilah alat';

  @override
  String get addons_switchPinSubtitle =>
      'Tampilkan ekstensi ini sebagai ikon di bilah tab utama.';

  @override
  String get addons_menuExtensionSettingsTitle => 'Pengaturan Ekstensi';

  @override
  String get addons_menuExtensionSettingsSubtitleTab =>
      'Buka halaman opsi ekstensi di tab peramban';

  @override
  String get addons_menuExtensionSettingsSubtitleInline =>
      'Buka halaman opsi ekstensi';

  @override
  String get addons_menuFilterListsTitle => 'Daftar Filter & Pengerasan';

  @override
  String get addons_menuFilterListsSubtitle =>
      'Kelola daftar filter dan terapkan pengerasan WebLibre';

  @override
  String get addons_permissionsTitle => 'Izin';

  @override
  String addons_updateAvailable(String from, String to) {
    return 'Pembaruan tersedia: $from → $to';
  }

  @override
  String get addons_noUpdateAttemptYet =>
      'Belum ada informasi tentang upaya pembaruan terbaru.';

  @override
  String addons_lastChecked(String date) {
    return 'Terakhir diperiksa: $date';
  }

  @override
  String get addons_noUpdateAvailable => 'Tidak ada pembaruan';

  @override
  String get addons_noRemoteUpdateSource =>
      'Ekstensi yang dipasang secara lokal ini tidak memiliki sumber pembaruan daring.';

  @override
  String get addons_updateCheckFailed => 'Gagal memulai pemeriksaan pembaruan.';

  @override
  String get addons_updateAvailableDialogTitle => 'Pembaruan tersedia';

  @override
  String addons_updateConfirmContent(String name, String from, String to) {
    return 'Perbarui $name dari $from ke $to?';
  }

  @override
  String get addons_noDescriptionProvided => 'Tidak ada deskripsi.';

  @override
  String get addons_loadingDescription => 'Memuat deskripsi…';

  @override
  String get addons_fieldAuthor => 'Pembuat';

  @override
  String get addons_fieldVersion => 'Versi';

  @override
  String get addons_fieldLastUpdated => 'Terakhir Diperbarui';

  @override
  String get addons_fieldLastUpdatedInfo => 'Terakhir diperbarui';

  @override
  String get addons_fieldHomepage => 'Beranda';

  @override
  String get addons_fieldAddonListing => 'Halaman Pengaya';

  @override
  String get addons_fieldSize => 'Ukuran';

  @override
  String get addons_fieldCategories => 'Kategori';

  @override
  String get addons_fieldLicense => 'Lisensi';

  @override
  String get addons_fieldSupportSite => 'Situs dukungan';

  @override
  String get addons_fieldReviews => 'Ulasan';

  @override
  String get addons_fieldPrivacyPolicy => 'Kebijakan privasi';

  @override
  String get addons_linkViewOnAmo => 'Lihat di addons.mozilla.org';

  @override
  String get addons_settingsTitleGeneric => 'Pengaturan Ekstensi';

  @override
  String addons_settingsTitleNamed(String name) {
    return 'Pengaturan $name';
  }

  @override
  String addons_settingsLoadFailed(String error) {
    return 'Gagal memuat pengaturan ekstensi: $error';
  }

  @override
  String get addons_noSettingsPage =>
      'Ekstensi ini tidak menyediakan halaman pengaturan.';

  @override
  String get addons_permissionsTitleGeneric => 'Izin Ekstensi';

  @override
  String addons_permissionsTitleNamed(String name) {
    return 'Izin $name';
  }

  @override
  String addons_permissionsLoadFailed(String error) {
    return 'Gagal memuat izin ekstensi: $error';
  }

  @override
  String get addons_noSpecialPermissions =>
      'Tidak ada izin khusus yang tercantum';

  @override
  String get addons_noTranslatedPermissionDetails =>
      'Ekstensi ini saat ini tidak menyediakan detail izin yang diterjemahkan.';

  @override
  String addons_versionSentence(String version) {
    return 'Versi $version';
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
      other: '$countString pengguna',
      one: '1 pengguna',
    );
    return '$_temp0';
  }

  @override
  String addons_byAuthor(String name) {
    return 'oleh $name';
  }

  @override
  String get addons_permGroupRequired => 'Wajib';

  @override
  String get addons_permGroupWebsites => 'Situs web';

  @override
  String get addons_permGroupOptional => 'Opsional';

  @override
  String get addons_permGroupDataCollection => 'Pengumpulan data';

  @override
  String get addons_dateUnknown => 'Tidak diketahui';

  @override
  String get addons_statusUpdatedSuccessfully => 'Berhasil diperbarui';

  @override
  String get addons_statusNotInstalled => 'Ekstensi tidak terpasang';

  @override
  String addons_updateFailedWithMessage(String message) {
    return 'Pembaruan gagal: $message';
  }

  @override
  String get addons_updateFailedGeneric => 'Pembaruan gagal';

  @override
  String get addons_noUpdateChecksRecorded =>
      'Belum ada pemeriksaan pembaruan yang tercatat';

  @override
  String get addons_statusBlocklisted =>
      'Ekstensi ini telah masuk daftar blokir dan sebaiknya tetap dinonaktifkan.';

  @override
  String get addons_statusNotCorrectlySigned =>
      'Ekstensi ini tidak ditandatangani dengan benar dan tidak dapat diaktifkan dengan aman.';

  @override
  String get addons_statusIncompatible =>
      'Ekstensi ini tidak kompatibel dengan versi aplikasi saat ini.';

  @override
  String get addons_statusSoftBlockedEnabled =>
      'Ekstensi ini diblokir sebagian. Berhati-hatilah selama ekstensi ini tetap aktif.';

  @override
  String get addons_statusSoftBlockedDisabled =>
      'Ekstensi ini diblokir sebagian, tetapi masih dapat diaktifkan kembali.';

  @override
  String get addons_statusUnsupported =>
      'Ekstensi ini terpasang, tetapi WebLibre saat ini belum mendukungnya.';

  @override
  String get addons_permissionBookmarks => 'Membaca dan mengubah markah';

  @override
  String get addons_permissionBrowserSettings =>
      'Membaca dan mengubah pengaturan peramban';

  @override
  String get addons_permissionBrowsingData =>
      'Membersihkan riwayat penjelajahan terbaru, kuki, dan data terkait';

  @override
  String get addons_permissionClipboardRead =>
      'Membaca data yang Anda salin dan tempel';

  @override
  String get addons_permissionClipboardWrite => 'Memasukkan data ke papan klip';

  @override
  String get addons_permissionContextualIdentities =>
      'Mengakses dan mengubah tab kontainer';

  @override
  String get addons_permissionCookies =>
      'Mengakses kuki untuk situs yang dikunjungi';

  @override
  String get addons_permissionDownloads =>
      'Mengunduh berkas serta membaca dan mengubah riwayat unduhan';

  @override
  String get addons_permissionDownloadsOpen =>
      'Membuka berkas yang diunduh ke komputer Anda';

  @override
  String get addons_permissionFind =>
      'Membaca teks dari semua tab yang terbuka';

  @override
  String get addons_permissionGeolocation => 'Mengakses lokasi Anda';

  @override
  String get addons_permissionHistory => 'Mengakses riwayat penjelajahan';

  @override
  String get addons_permissionManagement =>
      'Memantau penggunaan ekstensi dan mengelola tema';

  @override
  String get addons_permissionNativeMessaging =>
      'Bertukar pesan dengan program selain peramban';

  @override
  String get addons_permissionNotifications => 'Menampilkan notifikasi';

  @override
  String get addons_permissionPkcs11 =>
      'Menyediakan layanan autentikasi kriptografi';

  @override
  String get addons_permissionPrivacy =>
      'Membaca dan mengubah pengaturan privasi';

  @override
  String get addons_permissionProxy =>
      'Mengendalikan pengaturan proksi peramban';

  @override
  String get addons_permissionSessions =>
      'Mengakses tab yang baru saja ditutup';

  @override
  String get addons_permissionTabs => 'Mengakses tab peramban';

  @override
  String get addons_permissionTabHide =>
      'Menyembunyikan dan menampilkan tab peramban';

  @override
  String get addons_permissionTopSites => 'Mengakses riwayat penjelajahan';

  @override
  String get addons_permissionWebNavigation =>
      'Mengakses aktivitas peramban selama navigasi';

  @override
  String get addons_permissionAllUrls =>
      'Mengakses data Anda untuk semua situs web';

  @override
  String addons_permissionAccessDataFor(String host) {
    return 'Mengakses data Anda untuk $host';
  }

  @override
  String appLinks_bannerTitleNamed(String appName) {
    return 'Buka tautan ini di $appName?';
  }

  @override
  String get appLinks_bannerTitleGeneric => 'Buka tautan ini di aplikasi?';

  @override
  String appLinks_bannerRememberFor(String scope) {
    return 'Ingat untuk $scope';
  }

  @override
  String get appLinks_bannerStayInBrowser => 'Tetap di peramban';

  @override
  String get appLinks_bannerOpenApp => 'Buka aplikasi';

  @override
  String appLinks_dialogTitleNamed(String appName) {
    return 'Buka di $appName?';
  }

  @override
  String get appLinks_dialogTitleGeneric => 'Buka di aplikasi lain?';

  @override
  String get appLinks_dialogBody =>
      'Tautan ini ditangani oleh aplikasi di luar WebLibre.';

  @override
  String appLinks_dialogRememberFor(String scope) {
    return 'Ingat pilihan saya untuk $scope';
  }

  @override
  String get appLinks_warningProtectedContext =>
      'Tautan ini dilindungi di sini. Aplikasi akan membuka koneksinya sendiri, di luar aturan yang diikuti tab ini.';

  @override
  String get appLinks_warningPrivateTab =>
      'Ini adalah tab pribadi. Aplikasi menyimpan riwayat dan status masuknya sendiri.';

  @override
  String get appLinks_warningWallet =>
      'Tautan ini meminta kredensial dari aplikasi dompet. Buka hanya jika Anda yang memulai permintaan ini.';

  @override
  String appLinks_settingsTitleWithContainer(String containerName) {
    return 'Tautan Aplikasi — $containerName';
  }

  @override
  String get appLinks_settingsTitleDefault => 'Tautan Aplikasi Kontainer';

  @override
  String get appLinks_settingsIntro =>
      'Pengaturan ini hanya berlaku untuk kontainer ini dan sepenuhnya menggantikan pengaturan tautan aplikasi global untuk tab-tabnya.';

  @override
  String get appLinks_modeAlwaysTitle => 'Selalu';

  @override
  String get appLinks_modeAlwaysSubtitle =>
      'Selalu buka tautan di aplikasi terkait tanpa bertanya';

  @override
  String get appLinks_modeAskTitle => 'Tanya sebelum membuka';

  @override
  String get appLinks_modeAskSubtitle =>
      'Tampilkan konfirmasi sebelum membuka tautan di aplikasi';

  @override
  String get appLinks_modeNeverTitle => 'Jangan pernah';

  @override
  String get appLinks_modeNeverSubtitle =>
      'Selalu buka tautan di peramban, bukan di aplikasi';

  @override
  String get appLinks_rememberedRulesHeader => 'Aturan situs yang diingat';

  @override
  String get appLinks_ruleAlwaysOpenSubtitle => 'Selalu buka di aplikasi';

  @override
  String get appLinks_ruleAlwaysKeepSubtitle => 'Selalu tetap di peramban';

  @override
  String get appLinks_removeRuleTooltip => 'Hapus aturan';

  @override
  String get bangs_menuTitle => 'Bang';

  @override
  String get bangs_menuManageUserBangs => 'Kelola Bang Pengguna';

  @override
  String get bangs_menuSearchBangs => 'Cari Bang';

  @override
  String get bangs_menuBrowseCategories => 'Jelajahi Kategori';

  @override
  String get bangs_categoriesTitle => 'Kategori Bang';

  @override
  String get bangs_loadCategoriesFailedTitle => 'Gagal memuat kategori bang';

  @override
  String get bangs_loadBangsFailedTitle => 'Gagal memuat bang';

  @override
  String get bangs_searchHint => 'Cari';

  @override
  String get bangs_searchFailedTitle => 'Pencarian bang gagal';

  @override
  String get bangs_userBangsTitle => 'Bang Pengguna';

  @override
  String get bangs_deleteBangTitle => 'Hapus Bang';

  @override
  String get bangs_deleteBangConfirm => 'Yakin ingin menghapus bang ini?';

  @override
  String get bangs_editTitleCustomize => 'Sesuaikan Bang';

  @override
  String get bangs_editTitleNew => 'Bang Baru';

  @override
  String get bangs_editTitleEdit => 'Edit Bang';

  @override
  String bangs_triggerAlreadyExists(String trigger) {
    return 'Bang dengan pemicu \"$trigger\" sudah ada';
  }

  @override
  String get bangs_fieldNameLabel => 'Nama';

  @override
  String get bangs_fieldNameHelper => 'Nama situs web yang terkait dengan bang';

  @override
  String get bangs_fieldTriggerLabel => 'Pemicu';

  @override
  String get bangs_fieldTriggerHelper =>
      'Kata atau frasa pemicu yang digunakan untuk menjalankan bang.';

  @override
  String get bangs_fieldAdditionalTriggersLabel => 'Pemicu tambahan';

  @override
  String get bangs_fieldAdditionalTriggersHelper =>
      'Kata lain yang menjalankan bang ini, dipisahkan dengan koma atau spasi. Tanda ! di depan bersifat opsional.';

  @override
  String get bangs_fieldUrlLabel => 'URL';

  @override
  String bangs_fieldUrlHelper(String token) {
    return 'Templat URL yang digunakan saat bang dijalankan, dengan `$token` diganti oleh kueri pengguna.';
  }

  @override
  String bangs_fieldUrlMissingPlaceholder(String token) {
    return 'Harus berisi penanda kueri $token';
  }

  @override
  String get bangs_fieldCategoryLabel => 'Kategori';

  @override
  String get bangs_fieldSubCategoryLabel => 'Subkategori';

  @override
  String get bangs_flagsLabel => 'Opsi';

  @override
  String get bangs_flagOpenBasePathTitle => 'Buka Jalur Dasar';

  @override
  String get bangs_flagOpenBasePathSubtitle =>
      'Jika bang dijalankan tanpa kueri, buka jalur dasar URL (/) alih-alih jalur di templat (mis., /search)';

  @override
  String get bangs_flagUrlEncodePlaceholderTitle => 'Enkode URL pada Penanda';

  @override
  String get bangs_flagUrlEncodePlaceholderSubtitle =>
      'Enkode istilah pencarian untuk URL. Beberapa situs tidak berfungsi dengan istilah yang dienkode, jadi nonaktifkan opsi ini untuk situs tersebut.';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusTitle => 'Enkode Spasi sebagai Plus';

  @override
  String get bangs_flagUrlEncodeSpaceToPlusSubtitle =>
      'Enkode spasi sebagai + alih-alih %20. Beberapa situs mewajibkan salah satu format.';

  @override
  String get bangs_tooltipOfficialSearch => 'Pencarian resmi WebLibre';

  @override
  String get bangs_tooltipCustomizeAsOwn =>
      'Sesuaikan sebagai bang Anda sendiri';

  @override
  String get bangs_tooltipUnpin => 'Lepas sematan dari penyedia pencarian';

  @override
  String get bangs_tooltipPin => 'Sematkan ke penyedia pencarian';

  @override
  String bangs_tooltipTriggers(String triggers) {
    return 'Pemicu: $triggers';
  }

  @override
  String get browserActions_categoryNavigation => 'Navigasi';

  @override
  String get browserActions_categoryScrolling => 'Gulir';

  @override
  String get browserActions_categoryTabs => 'Tab';

  @override
  String get browserActions_categoryPage => 'Halaman';

  @override
  String get browserActions_categoryOpen => 'Buka';

  @override
  String get browserActions_categoryApp => 'Aplikasi';

  @override
  String get browserActions_focusAddressBarTitle => 'Bilah Alamat';

  @override
  String get browserActions_focusAddressBarDescription =>
      'Edit alamat atau mulai pencarian';

  @override
  String get browserActions_backTitle => 'Kembali';

  @override
  String get browserActions_backDescription => 'Kembali dalam riwayat';

  @override
  String get browserActions_forwardTitle => 'Maju';

  @override
  String get browserActions_forwardDescription => 'Maju dalam riwayat';

  @override
  String get browserActions_reloadTitle => 'Muat Ulang';

  @override
  String get browserActions_reloadDescription => 'Muat ulang halaman saat ini';

  @override
  String get browserActions_hardReloadTitle => 'Muat Ulang Paksa';

  @override
  String get browserActions_hardReloadDescription =>
      'Muat ulang halaman saat ini tanpa memakai cache';

  @override
  String get browserActions_scrollTopTitle => 'Gulir ke Atas';

  @override
  String get browserActions_scrollTopDescription =>
      'Lompat ke bagian atas halaman';

  @override
  String get browserActions_scrollBottomTitle => 'Gulir ke Bawah';

  @override
  String get browserActions_scrollBottomDescription =>
      'Lompat ke bagian bawah halaman';

  @override
  String get browserActions_pageUpTitle => 'Halaman ke Atas';

  @override
  String get browserActions_pageUpDescription =>
      'Gulir ke atas sejauh satu layar';

  @override
  String get browserActions_pageDownTitle => 'Halaman ke Bawah';

  @override
  String get browserActions_pageDownDescription =>
      'Gulir ke bawah sejauh satu layar';

  @override
  String get browserActions_newTabTitle => 'Tab Baru';

  @override
  String get browserActions_newTabDescription => 'Buka tab baru';

  @override
  String get browserActions_newPrivateTabTitle => 'Tab Pribadi Baru';

  @override
  String get browserActions_newPrivateTabDescription => 'Buka tab pribadi baru';

  @override
  String get browserActions_closeTabTitle => 'Tutup Tab';

  @override
  String get browserActions_closeTabDescription => 'Tutup tab saat ini';

  @override
  String get browserActions_reopenClosedTabTitle => 'Buka Lagi Tab Tertutup';

  @override
  String get browserActions_reopenClosedTabDescription =>
      'Kembalikan tab yang paling baru ditutup';

  @override
  String get browserActions_duplicateTabTitle => 'Duplikat Tab';

  @override
  String get browserActions_duplicateTabDescription =>
      'Buka salinan tab saat ini';

  @override
  String get browserActions_nextTabTitle => 'Tab Berikutnya';

  @override
  String get browserActions_nextTabDescription => 'Beralih ke tab berikutnya';

  @override
  String get browserActions_previousTabTitle => 'Tab Sebelumnya';

  @override
  String get browserActions_previousTabDescription =>
      'Beralih ke tab sebelumnya';

  @override
  String get browserActions_lastUsedTabTitle => 'Tab Terakhir Dipakai';

  @override
  String get browserActions_lastUsedTabDescription =>
      'Beralih ke tab yang digunakan sebelumnya';

  @override
  String get browserActions_selectTab1Title => 'Tab 1';

  @override
  String get browserActions_selectTab1Description =>
      'Beralih ke tab pertama di bilah tab';

  @override
  String get browserActions_selectTab2Title => 'Tab 2';

  @override
  String get browserActions_selectTab2Description =>
      'Beralih ke tab kedua di bilah tab';

  @override
  String get browserActions_selectTab3Title => 'Tab 3';

  @override
  String get browserActions_selectTab3Description =>
      'Beralih ke tab ketiga di bilah tab';

  @override
  String get browserActions_selectTab4Title => 'Tab 4';

  @override
  String get browserActions_selectTab4Description =>
      'Beralih ke tab keempat di bilah tab';

  @override
  String get browserActions_selectTab5Title => 'Tab 5';

  @override
  String get browserActions_selectTab5Description =>
      'Beralih ke tab kelima di bilah tab';

  @override
  String get browserActions_selectTab6Title => 'Tab 6';

  @override
  String get browserActions_selectTab6Description =>
      'Beralih ke tab keenam di bilah tab';

  @override
  String get browserActions_selectTab7Title => 'Tab 7';

  @override
  String get browserActions_selectTab7Description =>
      'Beralih ke tab ketujuh di bilah tab';

  @override
  String get browserActions_selectTab8Title => 'Tab 8';

  @override
  String get browserActions_selectTab8Description =>
      'Beralih ke tab kedelapan di bilah tab';

  @override
  String get browserActions_selectLastTabTitle => 'Tab Terakhir';

  @override
  String get browserActions_selectLastTabDescription =>
      'Beralih ke tab terakhir di bilah tab';

  @override
  String get browserActions_togglePinTabTitle => 'Sematkan / Lepas Tab';

  @override
  String get browserActions_togglePinTabDescription =>
      'Ubah status sematan tab saat ini';

  @override
  String get browserActions_moveTabBackwardTitle => 'Pindahkan Tab Mundur';

  @override
  String get browserActions_moveTabBackwardDescription =>
      'Pindahkan tab saat ini satu posisi ke arah awal bilah tab';

  @override
  String get browserActions_moveTabForwardTitle => 'Pindahkan Tab Maju';

  @override
  String get browserActions_moveTabForwardDescription =>
      'Pindahkan tab saat ini satu posisi ke arah akhir bilah tab';

  @override
  String get browserActions_moveTabToStartTitle => 'Pindahkan Tab ke Awal';

  @override
  String get browserActions_moveTabToStartDescription =>
      'Pindahkan tab saat ini ke awal grupnya di bilah tab';

  @override
  String get browserActions_moveTabToEndTitle => 'Pindahkan Tab ke Akhir';

  @override
  String get browserActions_moveTabToEndDescription =>
      'Pindahkan tab saat ini ke akhir grupnya di bilah tab';

  @override
  String get browserActions_nextContainerTitle => 'Kontainer Berikutnya';

  @override
  String get browserActions_nextContainerDescription =>
      'Beralih ke kontainer berikutnya dan tab terakhir yang dipakai di sana';

  @override
  String get browserActions_previousContainerTitle => 'Kontainer Sebelumnya';

  @override
  String get browserActions_previousContainerDescription =>
      'Beralih ke kontainer sebelumnya dan tab terakhir yang dipakai di sana';

  @override
  String get browserActions_toggleReaderModeTitle => 'Mode Pembaca';

  @override
  String get browserActions_toggleReaderModeDescription =>
      'Aktifkan atau nonaktifkan mode pembaca untuk halaman saat ini';

  @override
  String get browserActions_toggleDesktopModeTitle => 'Situs Desktop';

  @override
  String get browserActions_toggleDesktopModeDescription =>
      'Aktifkan atau nonaktifkan situs desktop untuk halaman saat ini';

  @override
  String get browserActions_findInPageTitle => 'Cari di Halaman';

  @override
  String get browserActions_findInPageDescription =>
      'Buka pencarian di halaman';

  @override
  String get browserActions_findNextTitle => 'Cari Berikutnya';

  @override
  String get browserActions_findNextDescription =>
      'Lompat ke hasil berikutnya dari pencarian terakhir';

  @override
  String get browserActions_findPreviousTitle => 'Cari Sebelumnya';

  @override
  String get browserActions_findPreviousDescription =>
      'Lompat ke hasil sebelumnya dari pencarian terakhir';

  @override
  String get browserActions_increaseFontSizeTitle => 'Perbesar Font';

  @override
  String get browserActions_increaseFontSizeDescription =>
      'Perbesar ukuran font halaman';

  @override
  String get browserActions_decreaseFontSizeTitle => 'Perkecil Font';

  @override
  String get browserActions_decreaseFontSizeDescription =>
      'Perkecil ukuran font halaman';

  @override
  String get browserActions_resetFontSizeTitle => 'Atur Ulang Font';

  @override
  String get browserActions_resetFontSizeDescription =>
      'Kembalikan ukuran font halaman ke bawaan';

  @override
  String get browserActions_toggleBookmarkTitle => 'Markahi';

  @override
  String get browserActions_toggleBookmarkDescription =>
      'Markahi atau hapus markah halaman saat ini';

  @override
  String get browserActions_sharePageTitle => 'Bagikan';

  @override
  String get browserActions_sharePageDescription => 'Bagikan halaman saat ini';

  @override
  String get browserActions_translatePageTitle => 'Terjemahkan';

  @override
  String get browserActions_translatePageDescription =>
      'Buka lembar terjemahan halaman';

  @override
  String get browserActions_printPageTitle => 'Cetak';

  @override
  String get browserActions_printPageDescription => 'Cetak halaman saat ini';

  @override
  String get browserActions_showHomeTitle => 'Beranda';

  @override
  String get browserActions_showHomeDescription => 'Buka beranda';

  @override
  String get browserActions_showHistoryTitle => 'Riwayat';

  @override
  String get browserActions_showHistoryDescription =>
      'Buka riwayat penjelajahan';

  @override
  String get browserActions_showBookmarksTitle => 'Markah';

  @override
  String get browserActions_showBookmarksDescription => 'Buka markah';

  @override
  String get browserActions_showContainersTitle => 'Kontainer';

  @override
  String get browserActions_showContainersDescription =>
      'Buka daftar kontainer';

  @override
  String get browserActions_showTabViewTitle => 'Tampilan Tab';

  @override
  String get browserActions_showTabViewDescription => 'Buka ikhtisar tab';

  @override
  String get browserActions_showDownloadsTitle => 'Unduhan';

  @override
  String get browserActions_showDownloadsDescription => 'Buka unduhan';

  @override
  String get browserActions_showAddonsTitle => 'Pengaya';

  @override
  String get browserActions_showAddonsDescription => 'Kelola ekstensi';

  @override
  String get browserActions_openSettingsTitle => 'Pengaturan';

  @override
  String get browserActions_openSettingsDescription => 'Buka pengaturan';

  @override
  String get browserActions_showKeyboardShortcutsTitle => 'Pintasan Keyboard';

  @override
  String get browserActions_showKeyboardShortcutsDescription =>
      'Tampilkan tombol yang menjalankan tindakan peramban';

  @override
  String get browserActions_toggleTabBarTitle =>
      'Sembunyikan / Tampilkan Bilah Tab';

  @override
  String get browserActions_toggleTabBarDescription =>
      'Sembunyikan bilah tab, atau tampilkan lagi';

  @override
  String get browserActions_clearBrowsingDataTitle => 'Hapus Data Penjelajahan';

  @override
  String get browserActions_clearBrowsingDataDescription =>
      'Pilih data penjelajahan yang akan dihapus';

  @override
  String get browserActions_moveToBackgroundTitle => 'Minimalkan';

  @override
  String get browserActions_moveToBackgroundDescription =>
      'Kirim WebLibre ke latar belakang';

  @override
  String get browserActions_quitBrowserTitle => 'Keluar';

  @override
  String get browserActions_quitBrowserDescription =>
      'Tutup semua tab dan keluar dari WebLibre';

  @override
  String get browserActions_categoryCreate => 'Buat';

  @override
  String get browserActions_openInPrivateTabTitle => 'Buka di Tab Pribadi';

  @override
  String get browserActions_openInPrivateTabDescription =>
      'Buka halaman saat ini di tab pribadi baru';

  @override
  String get browserActions_moveTabToContainerTitle => 'Pindahkan ke Kontainer';

  @override
  String get browserActions_moveTabToContainerDescription =>
      'Pindahkan tab saat ini ke kontainer lain';

  @override
  String get browserActions_copyLinkTitle => 'Salin Tautan';

  @override
  String get browserActions_copyLinkDescription =>
      'Salin alamat halaman saat ini';

  @override
  String get browserActions_siteSettingsTitle => 'Pengaturan Situs';

  @override
  String get browserActions_siteSettingsDescription =>
      'Izin dan perlindungan pelacakan untuk situs ini';

  @override
  String get browserActions_addToHomeScreenTitle => 'Tambahkan ke Layar Utama';

  @override
  String get browserActions_addToHomeScreenDescription =>
      'Pasang situs saat ini sebagai aplikasi atau pintasan';

  @override
  String get browserActions_subscribeToPageFeedTitle => 'Berlangganan Halaman';

  @override
  String get browserActions_subscribeToPageFeedDescription =>
      'Temukan dan ikuti umpan halaman saat ini';

  @override
  String get browserActions_showFeedsTitle => 'Umpan';

  @override
  String get browserActions_showFeedsDescription => 'Buka umpan Anda';

  @override
  String get browserActions_showProfilesTitle => 'Profil';

  @override
  String get browserActions_showProfilesDescription => 'Kelola profil Anda';

  @override
  String get browserActions_showProxySettingsTitle => 'Proksi';

  @override
  String get browserActions_showProxySettingsDescription =>
      'Buka pengaturan proksi';

  @override
  String get browserActions_showTorTitle => 'Tor';

  @override
  String get browserActions_showTorDescription => 'Buka pengaturan Tor';

  @override
  String get browserActions_showSyncSettingsTitle => 'Sinkronisasi';

  @override
  String get browserActions_showSyncSettingsDescription =>
      'Buka pengaturan sinkronisasi';

  @override
  String get browserActions_showContentBlockerListsTitle => 'Daftar Filter';

  @override
  String get browserActions_showContentBlockerListsDescription =>
      'Kelola daftar filter pemblokir konten';

  @override
  String get browserActions_showErrorLogsTitle => 'Log Galat';

  @override
  String get browserActions_showErrorLogsDescription =>
      'Lihat log galat aplikasi';

  @override
  String get browserActions_showAboutTitle => 'Tentang';

  @override
  String get browserActions_showAboutDescription => 'Tentang WebLibre';

  @override
  String get browserActions_newContainerTitle => 'Kontainer Baru';

  @override
  String get browserActions_newContainerDescription => 'Buat kontainer';

  @override
  String get browserActions_newBookmarkFolderTitle => 'Folder Markah Baru';

  @override
  String get browserActions_newBookmarkFolderDescription =>
      'Buat folder markah';

  @override
  String get browserActions_addFeedTitle => 'Tambah Umpan';

  @override
  String get browserActions_addFeedDescription =>
      'Berlangganan umpan melalui alamatnya';

  @override
  String get browserActions_newSearchEngineTitle => 'Pintasan Pencarian Baru';

  @override
  String get browserActions_newSearchEngineDescription =>
      'Buat pintasan pencarian bang Anda sendiri';

  @override
  String get browserActions_newProfileTitle => 'Profil Baru';

  @override
  String get browserActions_newProfileDescription => 'Buat profil peramban';

  @override
  String get browserActions_newProxyProfileTitle => 'Profil Proksi Baru';

  @override
  String get browserActions_newProxyProfileDescription =>
      'Tambahkan server proksi';

  @override
  String get browserActions_backupProfileTitle => 'Cadangkan Profil';

  @override
  String get browserActions_backupProfileDescription =>
      'Buat cadangan profil saat ini';

  @override
  String get browserActions_toggleBookmarkKeywords =>
      'favorit, simpan halaman, bintang, markah, bookmark, favorite';

  @override
  String get browserActions_findInPageKeywords =>
      'cari di halaman, cari teks, temukan teks, find, search in page';

  @override
  String get browserActions_copyLinkKeywords =>
      'salin url, salin alamat, papan klip, copy url, clipboard';

  @override
  String get browserActions_sharePageKeywords =>
      'kirim, bagikan tautan, kirim ke, share, send';

  @override
  String get browserActions_toggleReaderModeKeywords =>
      'tampilan pembaca, mode baca, artikel, sederhanakan halaman, reader view';

  @override
  String get browserActions_toggleDesktopModeKeywords =>
      'versi desktop, minta situs desktop, situs seluler, user agent, desktop site';

  @override
  String get browserActions_translatePageKeywords =>
      'terjemahan, bahasa, penerjemah, translate';

  @override
  String get browserActions_siteSettingsKeywords =>
      'izin, kuki, perlindungan pelacakan, kamera, mikrofon, lokasi, info situs, permissions, cookies';

  @override
  String get browserActions_addToHomeScreenKeywords =>
      'pwa, pasang, aplikasi web, pintasan, peluncur, aplikasi, install, shortcut';

  @override
  String get browserActions_subscribeToPageFeedKeywords =>
      'rss, atom, umpan, berlangganan, ikuti, berita, feed, subscribe';

  @override
  String get browserActions_printPageKeywords =>
      'pdf, simpan sebagai pdf, printer, cetak, print';

  @override
  String get browserActions_increaseFontSizeKeywords =>
      'perbesar, teks lebih besar, font lebih besar, ukuran teks, zoom in';

  @override
  String get browserActions_decreaseFontSizeKeywords =>
      'perkecil, teks lebih kecil, font lebih kecil, ukuran teks, zoom out';

  @override
  String get browserActions_resetFontSizeKeywords =>
      'ukuran teks bawaan, atur ulang zoom, ukuran teks, reset zoom';

  @override
  String get browserActions_openInPrivateTabKeywords =>
      'penyamaran, incognito, penjelajahan pribadi, mode pribadi, private';

  @override
  String get browserActions_moveTabToContainerKeywords =>
      'tetapkan kontainer, identitas, grup tab, container';

  @override
  String get browserActions_duplicateTabKeywords =>
      'gandakan tab, salin tab, clone tab, duplicate';

  @override
  String get browserActions_togglePinTabKeywords =>
      'sematkan tab, lepas sematan, pin tab, unpin';

  @override
  String get browserActions_closeTabKeywords => 'tutup, hapus tab, close';

  @override
  String get browserActions_reopenClosedTabKeywords =>
      'urungkan tutup, pulihkan tab, baru ditutup, undo close, restore tab';

  @override
  String get browserActions_showHistoryKeywords =>
      'halaman yang dikunjungi, riwayat penjelajahan, baru dikunjungi, history';

  @override
  String get browserActions_showBookmarksKeywords =>
      'favorit, halaman tersimpan, pengelola markah, bookmarks';

  @override
  String get browserActions_showDownloadsKeywords =>
      'berkas unduhan, berkas, pengelola unduhan, downloads';

  @override
  String get browserActions_showTabViewKeywords =>
      'ikhtisar tab, semua tab, pengalih tab, tab terbuka, tab switcher';

  @override
  String get browserActions_showContainersKeywords =>
      'identitas, daftar kontainer, ruang kerja, containers';

  @override
  String get browserActions_showFeedsKeywords =>
      'rss, atom, berita, langganan, feeds';

  @override
  String get browserActions_showProfilesKeywords =>
      'pengguna, akun, beralih profil, profiles';

  @override
  String get browserActions_showProxySettingsKeywords =>
      'vpn, sing-box, socks, koneksi, jaringan, proxy';

  @override
  String get browserActions_showTorKeywords =>
      'onion, anonim, jembatan, anonimitas, bridges';

  @override
  String get browserActions_showSyncSettingsKeywords =>
      'akun, sinkronkan, perangkat, sync';

  @override
  String get browserActions_showAddonsKeywords =>
      'ekstensi, plugin, pengaya, webextensions, add-ons';

  @override
  String get browserActions_showContentBlockerListsKeywords =>
      'ublock, adblock, pemblokir iklan, filter, daftar blokir';

  @override
  String get browserActions_openSettingsKeywords =>
      'preferensi, opsi, konfigurasi, settings';

  @override
  String get browserActions_showKeyboardShortcutsKeywords =>
      'tombol pintas, pemetaan tombol, tombol, hotkeys, shortcuts';

  @override
  String get browserActions_showErrorLogsKeywords =>
      'log, debug, mogok, laporan bug, crash';

  @override
  String get browserActions_showAboutKeywords => 'versi, lisensi, info, about';

  @override
  String get browserActions_newContainerKeywords =>
      'tambah kontainer, buat identitas, ruang kerja, container';

  @override
  String get browserActions_newBookmarkFolderKeywords =>
      'tambah folder, buat folder, atur markah';

  @override
  String get browserActions_addFeedKeywords =>
      'rss, atom, berlangganan, tambah langganan, feed';

  @override
  String get browserActions_newSearchEngineKeywords =>
      'bang, pencarian kustom, tambah mesin pencari, pintasan pencarian';

  @override
  String get browserActions_newProfileKeywords =>
      'tambah pengguna, buat profil, akun baru, profile';

  @override
  String get browserActions_newProxyProfileKeywords =>
      'tambah proksi, vpn, server, sing-box, socks, proxy';

  @override
  String get browserActions_backupProfileKeywords =>
      'cadangan, ekspor, simpan data, arsip, backup';

  @override
  String get browserActions_clearBrowsingDataKeywords =>
      'hapus riwayat, bersihkan cache, kuki, hapus, bersihkan, privasi, cookies';

  @override
  String get bookmarks_title => 'Markah';

  @override
  String get bookmarks_filterHint => 'Saring markah...';

  @override
  String get bookmarks_emptyFolder => 'Kosong';

  @override
  String get bookmarks_searchHiddenByFoldersOnly =>
      'Ada markah yang cocok, tetapi tersembunyi oleh \"Hanya Folder\"';

  @override
  String bookmarks_noSearchMatches(String query) {
    return 'Tidak ada markah yang cocok dengan \"$query\"';
  }

  @override
  String get bookmarks_loadFailedTitle => 'Gagal memuat markah';

  @override
  String get bookmarks_loadFoldersFailedTitle => 'Gagal memuat folder markah';

  @override
  String get bookmarks_folderLabel => 'Folder';

  @override
  String get bookmarks_unnamedFolder => 'Folder Tanpa Nama';

  @override
  String bookmarks_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 dipilih',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_tooltipOpenInBackground => 'Buka di latar belakang';

  @override
  String get bookmarks_tooltipMoveSelected => 'Pindahkan yang dipilih';

  @override
  String get bookmarks_tooltipDeleteSelected => 'Hapus yang dipilih';

  @override
  String get bookmarks_tooltipClearSearch => 'Bersihkan pencarian';

  @override
  String get bookmarks_tooltipSearchBookmarks => 'Cari markah';

  @override
  String get bookmarks_tooltipCollapse => 'Ciutkan';

  @override
  String get bookmarks_tooltipExpand => 'Luaskan';

  @override
  String get bookmarks_menuAddBookmarkHere => 'Tambah Markah di Sini';

  @override
  String get bookmarks_menuAddSubfolderHere => 'Tambah Subfolder di Sini';

  @override
  String get bookmarks_menuCollapseAll => 'Ciutkan Semua';

  @override
  String get bookmarks_menuShowEmptyFolders => 'Tampilkan Folder Kosong';

  @override
  String get bookmarks_menuHideEmptyFolders => 'Sembunyikan Folder Kosong';

  @override
  String get bookmarks_menuShowBookmarks => 'Tampilkan Markah';

  @override
  String get bookmarks_menuFoldersOnly => 'Hanya Folder';

  @override
  String get bookmarks_menuVisibility => 'Visibilitas';

  @override
  String get bookmarks_menuSort => 'Urutkan';

  @override
  String get bookmarks_menuImport => 'Impor';

  @override
  String get bookmarks_menuExport => 'Ekspor';

  @override
  String get bookmarks_formatJson => 'JSON';

  @override
  String get bookmarks_formatHtml => 'HTML';

  @override
  String get bookmarks_actionOpenInNewTab => 'Buka di Tab Baru';

  @override
  String get bookmarks_actionOpenInBackground => 'Buka di Latar Belakang';

  @override
  String get bookmarks_actionShare => 'Bagikan';

  @override
  String get bookmarks_actionMove => 'Pindahkan';

  @override
  String get bookmarks_actionFlatten => 'Ratakan';

  @override
  String get bookmarks_actionAddSubfolder => 'Tambah Subfolder';

  @override
  String get bookmarks_actionAddBookmark => 'Tambah Markah';

  @override
  String get bookmarks_actionMerge => 'Gabungkan';

  @override
  String get bookmarks_actionReplace => 'Ganti';

  @override
  String get bookmarks_noEntriesSelected => 'Tidak ada markah yang dipilih';

  @override
  String bookmarks_openedTabsInBackground(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab dibuka di latar belakang',
      one: '1 tab dibuka di latar belakang',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_movedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dipindahkan',
      one: '1 item dipindahkan',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_deletedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dihapus',
      one: '1 item dihapus',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importFailedToReadFile => 'Gagal membaca berkas';

  @override
  String bookmarks_importSuccessCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Berhasil mengimpor $count markah',
      one: 'Berhasil mengimpor 1 markah',
    );
    return '$_temp0';
  }

  @override
  String bookmarks_importFailedWithError(String error) {
    return 'Impor gagal: $error';
  }

  @override
  String get bookmarks_exportDialogTitle => 'Ekspor Markah';

  @override
  String get bookmarks_exportSuccess => 'Markah berhasil diekspor';

  @override
  String bookmarks_exportFailedWithError(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get bookmarks_sortDefault => 'Bawaan';

  @override
  String get bookmarks_sortTitleAsc => 'Judul A-Z';

  @override
  String get bookmarks_sortTitleDesc => 'Judul Z-A';

  @override
  String get bookmarks_sortUrlAsc => 'URL A-Z';

  @override
  String get bookmarks_sortUrlDesc => 'URL Z-A';

  @override
  String get bookmarks_sortDateAddedDesc => 'Terbaru Dahulu';

  @override
  String get bookmarks_sortDateAddedAsc => 'Terlama Dahulu';

  @override
  String get bookmarks_deleteBookmarkTitle => 'Hapus Markah';

  @override
  String get bookmarks_deleteBookmarkContent =>
      'Yakin ingin menghapus markah ini?';

  @override
  String get bookmarks_deleteFolderTitle => 'Hapus Folder';

  @override
  String get bookmarks_deleteFolderConfirmUnknown =>
      'Yakin ingin menghapus folder ini beserta semua markahnya?';

  @override
  String bookmarks_deleteFolderConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yakin ingin menghapus folder ini beserta $count markahnya?',
      one: 'Yakin ingin menghapus folder ini beserta satu markahnya?',
      zero: 'Yakin ingin menghapus folder ini?',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importDialogTitle => 'Impor Markah';

  @override
  String get bookmarks_importDialogContent =>
      'Hapus semua markah yang ada sebelum mengimpor?\n\nPilih \"Ganti\" untuk menghapus markah yang ada, atau \"Gabungkan\" untuk menyimpannya.';

  @override
  String get bookmarks_importProgressTitle => 'Mengimpor markah';

  @override
  String get bookmarks_importPhaseParsing => 'Membaca berkas…';

  @override
  String get bookmarks_importPhaseErasing => 'Menghapus markah yang ada…';

  @override
  String bookmarks_importPhaseInsertingProgress(int inserted, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$inserted dari $total markah',
      one: '$inserted dari 1 markah',
    );
    return '$_temp0';
  }

  @override
  String get bookmarks_importPhaseInsertingIndeterminate => 'Menyimpan markah…';

  @override
  String get bookmarks_moveToFolderTitle => 'Pindahkan ke Folder';

  @override
  String get bookmarks_editBookmarkTitle => 'Edit Markah';

  @override
  String get bookmarks_createBookmarkTitle => 'Buat Markah';

  @override
  String get bookmarks_editFolderTitle => 'Edit Folder';

  @override
  String get bookmarks_createFolderTitle => 'Buat Folder';

  @override
  String get bookmarks_fieldNameLabel => 'Nama';

  @override
  String get bookmarks_fieldUrlLabel => 'URL';

  @override
  String get bookmarks_addToTop => 'Tambahkan di atas';

  @override
  String get browser_actionSelect => 'Pilih';

  @override
  String get browser_actionKeep => 'Pertahankan';

  @override
  String get browser_actionInstall => 'Pasang';

  @override
  String get browser_bookmarkAllTitle => 'Markahi Semua Tab';

  @override
  String get browser_bookmarkAllFastTitle => 'Cepat';

  @override
  String get browser_bookmarkAllFastSubtitle =>
      'Tambahkan semua tab ke folder yang dipilih secara otomatis';

  @override
  String get browser_bookmarkAllDetailedTitle => 'Terperinci';

  @override
  String get browser_bookmarkAllDetailedSubtitle =>
      'Tinjau dan edit setiap markah satu per satu';

  @override
  String get browser_clearSiteDataTitle => 'Hapus Data Situs';

  @override
  String browser_clearSiteDataContent(String formattedTypes, String host) {
    return 'Ini akan menghapus data berikut untuk $host:\n$formattedTypes\n\nAnda mungkin perlu masuk kembali.';
  }

  @override
  String get browser_contentSelectionExtractedTitle => 'Konten yang Diekstrak';

  @override
  String get browser_contentSelectionExtractedSubtitle =>
      'Konten yang dioptimalkan untuk pembaca tanpa navigasi dan iklan';

  @override
  String get browser_contentSelectionFullTitle => 'Konten Lengkap';

  @override
  String get browser_contentSelectionFullSubtitle =>
      'Halaman lengkap termasuk semua elemen dan strukturnya';

  @override
  String get browser_deleteDataTitle => 'Hapus Data Penjelajahan';

  @override
  String get browser_installAddonSheetTitle => 'Pasang Ekstensi dari Berkas';

  @override
  String get browser_installAddonSelectFileButton => 'Pilih Berkas XPI';

  @override
  String get browser_installAddonNoFileSelected =>
      'Tidak ada berkas yang dipilih';

  @override
  String get browser_installAddonPinnedNotice =>
      'Ekstensi yang dipasang dari XPI lokal tetap pada versi tersebut dan tidak akan diperbarui secara otomatis.';

  @override
  String get browser_installAddonNotXpiError => 'Silakan pilih berkas .xpi';

  @override
  String browser_installAddonPickFileFailed(String error) {
    return 'Gagal memilih berkas: $error';
  }

  @override
  String get browser_installAddonInstalledMessage =>
      'Ekstensi terpasang. Pembaruan otomatis dinonaktifkan untuk versi lokal ini.';

  @override
  String get browser_installAddonNotSignedError =>
      'Ekstensi ini tidak ditandatangani oleh Mozilla. Aktifkan \"Izinkan ekstensi tanpa tanda tangan\" di pengaturan Ekstensi untuk memasangnya.';

  @override
  String browser_installAddonInstallFailed(String error) {
    return 'Pemasangan gagal: $error';
  }

  @override
  String get browser_keepTabTitle => 'Pertahankan tab?';

  @override
  String get browser_keepTabContent => 'Pertahankan atau buang tab ini?';

  @override
  String get browser_qrCodeTitle => 'Bagikan Kode QR';

  @override
  String get browser_selectFolderTitle => 'Pilih folder';

  @override
  String get browser_tabTreeCurrentTabNotInTree =>
      'Tab saat ini bukan bagian dari pohon ini';

  @override
  String get browser_menuManageExtensions => 'Kelola ekstensi';

  @override
  String get browser_menuAddRegularTab => 'Tambah Tab Biasa';

  @override
  String get browser_menuAddChildTab => 'Tambah Tab Anak';

  @override
  String get browser_menuAddPrivateTab => 'Tambah Tab Pribadi';

  @override
  String get browser_menuAddIsolatedTab => 'Tambah Tab Terisolasi';

  @override
  String get browser_fontSizeTitle => 'Ukuran Teks';

  @override
  String get browser_fontSizeAutomaticNotice =>
      'Ukuran font otomatis diaktifkan. Nonaktifkan di Pengaturan untuk menyesuaikan secara manual.';

  @override
  String get browser_fontSizeResetButton => 'Atur ulang ke 100%';

  @override
  String get browser_historyNoPreviousPages => 'Tidak ada halaman sebelumnya';

  @override
  String get browser_historyNoForwardPages => 'Tidak ada halaman berikutnya';

  @override
  String get browser_certSandboxedCaptureTitle => 'Tangkapan sandbox';

  @override
  String get browser_certSandboxedCaptureSubtitle =>
      'Halaman ini disajikan dari arsip luring — tanpa koneksi langsung.';

  @override
  String get browser_certConnectionNotSecure => 'Koneksi tidak aman';

  @override
  String get browser_certConnectionSecure => 'Koneksi aman';

  @override
  String browser_certVerifiedBy(String issuer) {
    return 'Diverifikasi oleh: $issuer';
  }

  @override
  String get browser_containerFallbackName => 'Kontainer';

  @override
  String get browser_actionEnable => 'Aktifkan';

  @override
  String get browser_closeAllPrivateTabsTitle => 'Tutup Semua Tab Pribadi';

  @override
  String get browser_closeAllPrivateTabsContent =>
      'Yakin ingin menutup semua tab pribadi yang ditampilkan?';

  @override
  String get browser_closeAllTabsTitle => 'Tutup Semua Tab';

  @override
  String get browser_closeAllTabsContent =>
      'Yakin ingin menutup semua tab yang ditampilkan?';

  @override
  String get browser_enableAiTabSuggestionsTitle => 'Aktifkan Saran Tab AI';

  @override
  String get browser_enableAiTabSuggestionsContent =>
      'Mengaktifkan fitur ini mungkin memerlukan pengunduhan model AI. Ukuran dan progres unduhan tidak dapat ditentukan sebelumnya.\n\nLanjutkan?';

  @override
  String get browser_tooltipExpandGroup => 'Luaskan grup';

  @override
  String get browser_tooltipCollapseGroup => 'Ciutkan grup';

  @override
  String browser_tabGroupSizeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Grup berisi $count tab',
    );
    return '$_temp0';
  }

  @override
  String get browser_searchOrEnterUrl => 'Cari atau masukkan URL';

  @override
  String get browser_tabCannotBeMovedHere =>
      'Tab tidak dapat dipindahkan ke sini';

  @override
  String get browser_quickActionNewTab => 'Tab Baru';

  @override
  String get browser_quickActionNewPrivateTab => 'Tab Pribadi Baru';

  @override
  String get browser_quickActionNewIsolatedTab => 'Tab Terisolasi Baru';

  @override
  String get browser_shareLink => 'Bagikan Tautan';

  @override
  String get browser_showQrCode => 'Tampilkan Kode QR';

  @override
  String get browser_exportAsPdf => 'Ekspor sebagai PDF';

  @override
  String get browser_failedToPrintPage => 'Gagal mencetak halaman';

  @override
  String get browser_print => 'Cetak';

  @override
  String get browser_shareScreenshot => 'Bagikan Tangkapan Layar';

  @override
  String get browser_exportAsPng => 'Ekspor sebagai PNG';

  @override
  String browser_openInNamedApp(String appName) {
    return 'Buka di $appName';
  }

  @override
  String get browser_openInApp => 'Buka di Aplikasi';

  @override
  String get browser_copyAddress => 'Salin Alamat';

  @override
  String get browser_noTargetDevices => 'Tidak ada perangkat tujuan';

  @override
  String browser_sentTabToDevice(String deviceName) {
    return 'Tab dikirim ke $deviceName';
  }

  @override
  String get browser_failedToSendTab => 'Gagal mengirim tab';

  @override
  String get browser_loadingDevices => 'Memuat perangkat...';

  @override
  String get browser_failedToLoadDevices => 'Gagal memuat perangkat';

  @override
  String get browser_sendToDevice => 'Kirim ke Perangkat';

  @override
  String get browser_containerMenuNewTab => 'Tab Baru';

  @override
  String get browser_unpinContainer => 'Lepas Sematan Kontainer';

  @override
  String get browser_pinContainer => 'Sematkan Kontainer';

  @override
  String get browser_closeSubmenuAllTabs => 'Semua Tab';

  @override
  String get browser_closeSubmenuPrivateTabs => 'Tab Pribadi';

  @override
  String get browser_closeSubmenuIsolatedTabs => 'Tab Terisolasi';

  @override
  String get browser_closeSubmenuFilteredTabs => 'Tab yang Disaring';

  @override
  String get browser_menuCloseTabs => 'Tutup Tab';

  @override
  String get browser_menuBookmarkAll => 'Markahi semua';

  @override
  String get browser_menuAssignedSites => 'Situs yang Ditetapkan…';

  @override
  String get browser_menuClearContainerData => 'Hapus Data Kontainer';

  @override
  String get browser_menuEditContainer => 'Edit Kontainer…';

  @override
  String get browser_menuDeleteContainer => 'Hapus Kontainer';

  @override
  String browser_bookmarksAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count markah ditambahkan',
      one: '1 markah ditambahkan',
    );
    return '$_temp0';
  }

  @override
  String get browser_containerDataClearedSuccess =>
      'Data kontainer berhasil dihapus';

  @override
  String browser_containerDataClearedWithTabsClosed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Data kontainer dihapus. $count tab ditutup.',
      one: 'Data kontainer dihapus. 1 tab ditutup.',
    );
    return '$_temp0';
  }

  @override
  String browser_errorClearingData(String error) {
    return 'Galat saat menghapus data: $error';
  }

  @override
  String get browser_appLinksSectionTitle => 'Tautan Aplikasi';

  @override
  String get browser_openLinksForThisSite => 'Buka tautan untuk situs ini';

  @override
  String get browser_followsTheDefault => 'Mengikuti bawaan';

  @override
  String get browser_followDefault => 'Ikuti bawaan';

  @override
  String get browser_openInAppOption => 'Buka di aplikasi';

  @override
  String get browser_keepInBrowser => 'Tetap di peramban';

  @override
  String get browser_noAppFoundForSite => 'Tidak ada aplikasi untuk situs ini';

  @override
  String browser_alwaysOpensInApp(String appName) {
    return 'Selalu dibuka di $appName';
  }

  @override
  String get browser_theAppFallback => 'aplikasi';

  @override
  String get browser_alwaysStaysInBrowser => 'Selalu tetap di peramban';

  @override
  String get browser_followsDefaultOpensInApps =>
      'Mengikuti bawaan: dibuka di aplikasi';

  @override
  String get browser_followsDefaultNoAppFound =>
      'Mengikuti bawaan: tidak ada aplikasi';

  @override
  String get browser_followsDefaultAsksFirst =>
      'Mengikuti bawaan: bertanya dulu';

  @override
  String get browser_followsDefaultStaysInBrowser =>
      'Mengikuti bawaan: tetap di peramban';

  @override
  String get browser_selectDataTypesToClear =>
      'Pilih jenis data yang akan dihapus';

  @override
  String get browser_cookiesCacheAndSiteData => 'Kuki, cache, dan data situs';

  @override
  String get browser_dataTypeAuthSessions => 'Sesi Autentikasi';

  @override
  String get browser_dataTypeAuthSessionsSubtitle =>
      'Info masuk tersimpan, sesi aktif';

  @override
  String get browser_dataTypeSiteData => 'Data Situs';

  @override
  String get browser_dataTypeSiteDataSubtitle =>
      'Penyimpanan luring, basis data, berkas lokal';

  @override
  String get browser_dataTypeCookies => 'Kuki';

  @override
  String get browser_dataTypeCookiesSubtitle =>
      'Token masuk, preferensi, data pelacakan';

  @override
  String get browser_dataTypeCachedFiles => 'Berkas Cache';

  @override
  String get browser_dataTypeCachedFilesSubtitle =>
      'Gambar, skrip, lembar gaya';

  @override
  String get browser_closeTabAfterClearing => 'Tutup tab setelah data dihapus';

  @override
  String get browser_closeTabAfterClearingSubtitle =>
      'Tutup tab ini setelah data dihapus';

  @override
  String get browser_clearingEllipsis => 'Menghapus...';

  @override
  String get browser_clearNow => 'Hapus Sekarang';

  @override
  String get browser_selectAtLeastOneDataType =>
      'Pilih setidaknya satu jenis data';

  @override
  String get browser_siteDataCleared => 'Data situs dihapus';

  @override
  String browser_failedToClearSiteData(String error) {
    return 'Gagal menghapus data situs: $error';
  }

  @override
  String get browser_alwaysUseDesktopSite => 'Selalu gunakan situs desktop';

  @override
  String get browser_unavailableOnThisPage => 'Tidak tersedia di halaman ini';

  @override
  String browser_setByRuleFor(String host) {
    return 'Diatur oleh aturan untuk $host';
  }

  @override
  String get browser_siteAlwaysLoadsInDesktopMode =>
      'Situs ini selalu dimuat dalam mode desktop';

  @override
  String get browser_siteFollowsDefaultMode =>
      'Situs ini mengikuti mode bawaan';

  @override
  String browser_failedToToggleDesktopMode(String error) {
    return 'Gagal mengubah mode desktop: $error';
  }

  @override
  String get browser_gesturesTitle => 'Gestur';

  @override
  String get browser_gesturesTurnedOffGlobally =>
      'Gestur dinonaktifkan secara global';

  @override
  String get browser_gesturesUnavailableOnThisPage =>
      'Gestur tidak tersedia di halaman ini';

  @override
  String browser_gesturesDisabledByRuleFor(String host) {
    return 'Dinonaktifkan oleh aturan untuk $host';
  }

  @override
  String get browser_gesturesDisabledOnThisSite =>
      'Gestur dinonaktifkan di situs ini';

  @override
  String get browser_gesturesEnabledOnThisSite =>
      'Gestur diaktifkan di situs ini';

  @override
  String browser_failedToToggleGestures(String error) {
    return 'Gagal mengubah gestur: $error';
  }

  @override
  String browser_errorLoadingPermissions(String error) {
    return 'Galat saat memuat izin: $error';
  }

  @override
  String get browser_permissionsSectionTitle => 'Izin';

  @override
  String get browser_showAll => 'Tampilkan semua';

  @override
  String get browser_noPermissionsSetForSite =>
      'Tidak ada izin yang diatur untuk situs ini';

  @override
  String get browser_permissionAsk => 'Tanya';

  @override
  String get browser_permissionAllow => 'Izinkan';

  @override
  String get browser_permissionBlock => 'Blokir';

  @override
  String get browser_autoplayTitle => 'Putar otomatis';

  @override
  String get browser_autoplayAllowAll => 'Izinkan Semua';

  @override
  String get browser_autoplayBlockAudible => 'Blokir yang Bersuara';

  @override
  String get browser_autoplayBlockAll => 'Blokir Semua';

  @override
  String get browser_failedToLoadTrackingProtection =>
      'Gagal memuat perlindungan pelacakan';

  @override
  String get browser_enhancedTrackingProtection =>
      'Perlindungan Pelacakan yang Ditingkatkan';

  @override
  String get browser_trackersBeingBlocked =>
      'Pelacak di situs ini sedang diblokir';

  @override
  String get browser_trackersAllowed => 'Pelacak di situs ini diizinkan';

  @override
  String browser_failedToToggleTrackingProtection(String error) {
    return 'Gagal mengubah perlindungan pelacakan: $error';
  }

  @override
  String get browser_resizeSidePanel => 'Ubah ukuran panel samping';

  @override
  String get browser_unassignedContainerLabel => 'Tanpa Kontainer';

  @override
  String get browser_tooltipCloseTab => 'Tutup tab';

  @override
  String get browser_urlCleaned => 'URL dibersihkan';

  @override
  String get browser_urlPreviewApplied => 'Pratinjau URL diterapkan';

  @override
  String browser_trackingParametersDetected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameter pelacakan terdeteksi',
      one: '1 parameter pelacakan terdeteksi',
    );
    return '$_temp0';
  }

  @override
  String get browser_linkIsClean => 'Tautan tidak perlu dibersihkan';

  @override
  String get browser_removeTrackingTooltip => 'Hapus pelacakan';

  @override
  String get browser_menuFindInPage => 'Cari di Halaman';

  @override
  String get browser_menuReaderMode => 'Mode Pembaca';

  @override
  String get browser_menuFetchFeedsOnPage => 'Ambil Umpan di Halaman';

  @override
  String get browser_menuAddBookmark => 'Tambah Markah';

  @override
  String get browser_cloneRegular => 'Biasa';

  @override
  String get browser_clonePrivate => 'Pribadi';

  @override
  String get browser_cloneIsolated => 'Terisolasi';

  @override
  String get browser_menuCloneTab => 'Duplikat Tab';

  @override
  String get browser_menuAssignContainer => 'Tetapkan Kontainer';

  @override
  String get browser_menuUrlRelation => 'Relasi URL';

  @override
  String get browser_menuUnassignUrlRelation => 'Lepaskan Relasi URL';

  @override
  String get browser_menuUnassignContainer => 'Lepaskan Kontainer';

  @override
  String get browser_menuContainerSubmenu => 'Kontainer';

  @override
  String get browser_menuMoveUp => 'Pindah ke atas';

  @override
  String get browser_menuMoveDown => 'Pindah ke bawah';

  @override
  String get browser_menuReorder => 'Urutkan Ulang';

  @override
  String get browser_menuShare => 'Bagikan';

  @override
  String get browser_menuCopyAsMarkdown => 'Salin sebagai Markdown';

  @override
  String get browser_markdownCopiedToClipboard =>
      'Markdown disalin ke papan klip';

  @override
  String get browser_menuExportAsMarkdown => 'Ekspor sebagai Markdown';

  @override
  String get browser_menuExportSubmenu => 'Ekspor';

  @override
  String get browser_menuCloseTab => 'Tutup Tab';

  @override
  String get browser_menuReload => 'Muat Ulang';

  @override
  String get browser_menuDesktopMode => 'Mode Desktop';

  @override
  String get browser_menuAddToHomeScreen => 'Tambahkan ke Layar Utama';

  @override
  String get browser_menuChangeParent => 'Ubah induk…';

  @override
  String get browser_menuDetachFromParent => 'Lepaskan dari induk';

  @override
  String get browser_menuHierarchy => 'Hierarki';

  @override
  String get browser_pageTranslated => 'Diterjemahkan';

  @override
  String get browser_menuTranslatePage => 'Terjemahkan Halaman';

  @override
  String get browser_unpinTab => 'Lepas sematan tab';

  @override
  String get browser_pinTab => 'Sematkan tab';

  @override
  String browser_errorGeneric(String error) {
    return 'Galat: $error';
  }

  @override
  String get browser_tabNoLongerExists => 'Tab sudah tidak ada';

  @override
  String get browser_chooseAParentTab => 'Pilih tab induk';

  @override
  String get browser_makeStandalone => 'Jadikan mandiri';

  @override
  String get browser_detachFromCurrentParent => 'Lepaskan dari induk saat ini';

  @override
  String get browser_noCandidateTabsInContainer =>
      'Tidak ada tab yang dapat dipilih di kontainer ini.';

  @override
  String get browser_clearContainerDataIntro =>
      'Ini akan menghapus semua data untuk kontainer ini:';

  @override
  String get browser_bulletCookies => '• Kuki';

  @override
  String get browser_bulletSiteData => '• Data situs';

  @override
  String get browser_bulletCache => '• Cache';

  @override
  String get browser_bulletPermissions => '• Izin';

  @override
  String browser_tabsWillBeClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab akan ditutup.',
      one: '1 tab akan ditutup.',
    );
    return '$_temp0';
  }

  @override
  String get browser_recreateTabsAfterClearing =>
      'Buat ulang tab setelah data dihapus';

  @override
  String get browser_actionClearData => 'Hapus Data';

  @override
  String get browser_closeFromSameHost => 'Tutup dari Host yang Sama';

  @override
  String get browser_closeTabAndDescendants => 'Tutup Tab dan Turunannya';

  @override
  String get browser_tabUnpinned => 'Sematan tab dilepas';

  @override
  String browser_createdContainerNamed(String containerName) {
    return 'Kontainer \"$containerName\" dibuat';
  }

  @override
  String get browser_newContainerFallback => 'Kontainer Baru';

  @override
  String get browser_assignedParentTab => 'Tab induk ditetapkan';

  @override
  String get browser_couldNotAssignParentTab =>
      'Tidak dapat menetapkan tab induk';

  @override
  String get browser_dropTabOntoTabTitle => 'Letakkan tab di atas tab';

  @override
  String get browser_chooseHowTabsRelated =>
      'Pilih bagaimana tab-tab ini saling terkait.';

  @override
  String get browser_createContainerOption => 'Buat kontainer';

  @override
  String get browser_createContainerOptionSubtitle =>
      'Buat kontainer baru berisi kedua tab.';

  @override
  String get browser_assignNewParentOption => 'Tetapkan induk baru';

  @override
  String get browser_assignNewParentOptionSubtitle =>
      'Jadikan tab tujuan sebagai induk.';

  @override
  String get browser_tabReorderingOnlyInDefaultMode =>
      'Penataan ulang tab hanya tersedia dalam mode manual bawaan';

  @override
  String get browser_tooltipSearchInsideTabs => 'Cari di dalam tab';

  @override
  String get browser_filterTabType => 'Jenis Tab';

  @override
  String get browser_sortPinnedFirst => 'Urutkan yang Disematkan Dahulu';

  @override
  String get browser_filterSort => 'Urutkan';

  @override
  String get browser_hierarchicalView => 'Tampilan Hierarki';

  @override
  String get browser_filterDate => 'Saring Tanggal';

  @override
  String get browser_quickInterval => 'Interval Cepat';

  @override
  String get browser_resetFilter => 'Atur Ulang Filter';

  @override
  String get browser_tooltipFilterAndSort => 'Saring & Urutkan';

  @override
  String get browser_tooltipChangeViewMode => 'Ubah mode tampilan';

  @override
  String browser_downloadingAiModelsProgress(int percent) {
    return 'Mengunduh model AI ($percent%)';
  }

  @override
  String get browser_disableAiTabSuggestions => 'Nonaktifkan saran tab AI';

  @override
  String get browser_enableAiTabSuggestionsTooltip => 'Aktifkan saran tab AI';

  @override
  String get browser_disableReorderingMode => 'Nonaktifkan mode penataan ulang';

  @override
  String get browser_enableReorderingMode => 'Aktifkan mode penataan ulang';

  @override
  String get browser_reorderingRequiresDefaultManualMode =>
      'Penataan ulang memerlukan mode manual bawaan';

  @override
  String get browser_dragAndDropTabsToReorder =>
      'Seret dan lepas tab untuk menata ulang';

  @override
  String get browser_tooltipTabActions => 'Tindakan tab';

  @override
  String get browser_hintSearchTabs => 'Cari tab';

  @override
  String get browser_noSyncedTabsAvailable =>
      'Tidak ada tab tersinkron yang tersedia';

  @override
  String browser_failedToLoadSyncedTabs(String error) {
    return 'Gagal memuat tab tersinkron: $error';
  }

  @override
  String get browser_translateFromLabel => 'Dari';

  @override
  String get browser_translateToLabel => 'Ke';

  @override
  String browser_translationError(String error) {
    return 'Galat terjemahan: $error';
  }

  @override
  String get browser_failedToRestorePage => 'Gagal memulihkan halaman';

  @override
  String get browser_showOriginal => 'Tampilkan Asli';

  @override
  String get browser_failedToTranslatePage => 'Gagal menerjemahkan halaman';

  @override
  String get browser_retranslate => 'Terjemahkan Ulang';

  @override
  String get browser_translateAction => 'Terjemahkan';

  @override
  String get browser_tabTypeFilterAll => 'Semua Tab';

  @override
  String get browser_tabTypeFilterRegular => 'Biasa';

  @override
  String get browser_tabTypeFilterPrivate => 'Pribadi';

  @override
  String get browser_tabTypeFilterIsolated => 'Terisolasi';

  @override
  String get browser_tabSortDefault => 'Bawaan';

  @override
  String get browser_tabSortTitleAsc => 'Judul A-Z';

  @override
  String get browser_tabSortTitleDesc => 'Judul Z-A';

  @override
  String get browser_tabSortUrlAsc => 'URL A-Z';

  @override
  String get browser_tabSortUrlDesc => 'URL Z-A';

  @override
  String get browser_tabSortNewestFirst => 'Terbaru Dahulu';

  @override
  String get browser_tabSortOldestFirst => 'Terlama Dahulu';

  @override
  String get browser_tabIntervalLastHour => 'Satu Jam Terakhir';

  @override
  String get browser_tabIntervalLast3Hours => '3 Jam Terakhir';

  @override
  String get browser_tabIntervalLast8Hours => '8 Jam Terakhir';

  @override
  String get browser_tabIntervalLastDay => '24 Jam Terakhir';

  @override
  String get browser_tabIntervalLast3Days => '3 Hari Terakhir';

  @override
  String get browser_tabIntervalLastWeek => '7 Hari Terakhir';

  @override
  String get browser_tabIntervalLastMonth => 'Sebulan Terakhir';

  @override
  String get browser_tabsViewModeList => 'Daftar';

  @override
  String get browser_tabsViewModeGrid => 'Kisi';

  @override
  String get browser_tabsViewModeTree => 'Pohon';

  @override
  String get browser_permissionCamera => 'Kamera';

  @override
  String get browser_permissionMicrophone => 'Mikrofon';

  @override
  String get browser_permissionLocation => 'Lokasi';

  @override
  String get browser_permissionNotification => 'Notifikasi';

  @override
  String get browser_permissionPersistentStorage => 'Penyimpanan Persisten';

  @override
  String get browser_permissionCrossOriginStorage => 'Penyimpanan Lintas Asal';

  @override
  String get browser_permissionMediaKeySystem => 'Sistem Kunci Media (DRM)';

  @override
  String get browser_tabReorderBlockedMessage =>
      'Hapus filter atau pencarian tampilan tab untuk menata ulang tab';

  @override
  String get contextualToolbar_tooltipHome => 'Beranda';

  @override
  String get contextualToolbar_tooltipHideTabBar => 'Sembunyikan bilah tab';

  @override
  String get contextualToolbar_tooltipClearBrowsingData =>
      'Hapus data penjelajahan';

  @override
  String get contextualToolbar_tooltipAddBookmark => 'Tambah markah';

  @override
  String get contextualToolbar_tooltipRemoveBookmark => 'Hapus markah';

  @override
  String get contextualToolbar_tooltipEnableGestures => 'Aktifkan gestur';

  @override
  String get contextualToolbar_tooltipDisableGestures => 'Nonaktifkan gestur';

  @override
  String get contextualToolbar_actionHardRefresh => 'Muat Ulang Paksa';

  @override
  String get contextualToolbar_actionCloseOthers => 'Tutup yang Lain';

  @override
  String get contextualToolbar_actionCloseFromSameHost =>
      'Tutup dari Host yang Sama';

  @override
  String get contextualToolbar_actionCloseTabAndDescendants =>
      'Tutup Tab dan Turunannya';

  @override
  String get contextualToolbar_actionAddBookmark => 'Tambah Markah';

  @override
  String get contextualToolbar_actionRemoveBookmark => 'Hapus Markah';

  @override
  String get contextualToolbar_actionCloneAsRegular => 'Duplikat sebagai Biasa';

  @override
  String get contextualToolbar_actionCloneAsPrivate =>
      'Duplikat sebagai Pribadi';

  @override
  String get contextualToolbar_actionCloneAsIsolated =>
      'Duplikat sebagai Terisolasi';

  @override
  String get contextualToolbar_bookmarkAdded => 'Markah ditambahkan';

  @override
  String get contextualToolbar_bookmarkRemoved => 'Markah dihapus';

  @override
  String get contextualToolbar_fontSizeAutoAdjustmentHint =>
      'Nonaktifkan ukuran font otomatis di pengaturan untuk menyesuaikan secara manual';

  @override
  String get contextualToolbar_buttonLabelBack => 'Kembali';

  @override
  String get contextualToolbar_buttonLabelForward => 'Maju';

  @override
  String get contextualToolbar_buttonLabelHome => 'Beranda';

  @override
  String get contextualToolbar_buttonLabelHistory => 'Riwayat';

  @override
  String get contextualToolbar_buttonLabelBookmarks => 'Markah';

  @override
  String get contextualToolbar_buttonLabelBookmarkToggle => 'Markahi';

  @override
  String get contextualToolbar_buttonLabelShare => 'Bagikan';

  @override
  String get contextualToolbar_buttonLabelAddTab => 'Tab Baru';

  @override
  String get contextualToolbar_buttonLabelTabsCount => 'Tab';

  @override
  String get contextualToolbar_buttonLabelNavigationMenu => 'Menu';

  @override
  String get contextualToolbar_buttonLabelReload => 'Muat Ulang';

  @override
  String get contextualToolbar_buttonLabelReaderMode => 'Mode Pembaca';

  @override
  String get contextualToolbar_buttonLabelDesktop => 'Situs Desktop';

  @override
  String get contextualToolbar_buttonLabelTranslation => 'Terjemahkan';

  @override
  String get contextualToolbar_buttonLabelFindInPage => 'Cari di Halaman';

  @override
  String get contextualToolbar_buttonLabelCloseTab => 'Tutup Tab';

  @override
  String get contextualToolbar_buttonLabelInputUrl => 'Bilah Alamat';

  @override
  String get contextualToolbar_buttonLabelQrScan => 'Pindai Kode QR';

  @override
  String get contextualToolbar_buttonLabelVoiceSearch => 'Pencarian Suara';

  @override
  String get contextualToolbar_buttonLabelDuplicateTab => 'Duplikat Tab';

  @override
  String get contextualToolbar_buttonLabelIncreaseFont => 'Perbesar Font';

  @override
  String get contextualToolbar_buttonLabelDecreaseFont => 'Perkecil Font';

  @override
  String get contextualToolbar_buttonLabelMoveToBackground => 'Latar Belakang';

  @override
  String get contextualToolbar_buttonLabelToggleGestures => 'Gestur';

  @override
  String get contextualToolbar_buttonLabelHideTabBar => 'Sembunyikan Bilah Tab';

  @override
  String get contextualToolbar_buttonLabelPageUp => 'Halaman ke Atas';

  @override
  String get contextualToolbar_buttonLabelPageDown => 'Halaman ke Bawah';

  @override
  String get contextualToolbar_buttonLabelFont => 'Ukuran Teks';

  @override
  String get contextualToolbar_buttonLabelExtensionShortcut => 'Ekstensi';

  @override
  String get contextualToolbar_buttonLabelClearBrowsingData => 'Hapus Data';

  @override
  String get contextualToolbar_buttonLabelQuit => 'Keluar';

  @override
  String get contextualToolbar_longPressBackHistoryMenu =>
      'Menu Riwayat (Halaman sebelumnya)';

  @override
  String get contextualToolbar_longPressForwardHistoryMenu =>
      'Menu Riwayat (Halaman berikutnya)';

  @override
  String get contextualToolbar_longPressOpenBookmarks => 'Buka Markah';

  @override
  String get contextualToolbar_longPressAddRegularTab => 'Tambah Tab Biasa';

  @override
  String get contextualToolbar_longPressAddChildTab => 'Tambah Tab Anak';

  @override
  String get contextualToolbar_longPressAddPrivateTab => 'Tambah Tab Pribadi';

  @override
  String get contextualToolbar_longPressAddIsolatedTab =>
      'Tambah Tab Terisolasi';

  @override
  String get contextualToolbar_longPressOpenSettings => 'Buka Pengaturan';

  @override
  String get contextualToolbar_longPressHardRefresh =>
      'Muat Ulang Paksa (lewati cache)';

  @override
  String get contextualToolbar_longPressShowTranslationOptions =>
      'Tampilkan Opsi Terjemahan';

  @override
  String get contextualToolbar_longPressScrollToTop => 'Gulir ke Atas';

  @override
  String get contextualToolbar_longPressScrollToBottom => 'Gulir ke Bawah';

  @override
  String get contextualToolbar_longPressExtensionsMenu => 'Menu Ekstensi';

  @override
  String get contextualToolbar_longPressQuitWithoutConfirmation =>
      'Keluar tanpa konfirmasi';

  @override
  String get menu_sectionQuickToggles => 'Sakelar Cepat';

  @override
  String get menu_sectionPageActions => 'Tindakan Halaman';

  @override
  String get menu_sectionExtensions => 'Ekstensi';

  @override
  String get menu_sectionTabActions => 'Tindakan Tab';

  @override
  String get menu_sectionQuickLinks => 'Tautan Cepat';

  @override
  String get menu_sectionConnection => 'Koneksi';

  @override
  String get menu_sectionProfile => 'Profil & Aplikasi';

  @override
  String get menu_sectionAbout => 'Tentang';

  @override
  String get menu_itemDesktopMode => 'Desktop';

  @override
  String get menu_itemReaderMode => 'Pembaca';

  @override
  String get menu_itemGestures => 'Gestur';

  @override
  String get menu_itemAddBookmark => 'Tambah Markah';

  @override
  String get menu_itemFindInPage => 'Cari di Halaman';

  @override
  String get menu_itemTranslatePage => 'Terjemahkan Halaman';

  @override
  String get menu_itemAddToHomeScreen => 'Tambahkan ke Layar Utama';

  @override
  String get menu_itemOpenInApp => 'Buka di Aplikasi';

  @override
  String get menu_itemContainers => 'Kontainer';

  @override
  String get menu_itemManageContainers => 'Kelola Kontainer';

  @override
  String get menu_itemAssignContainer => 'Tetapkan Kontainer';

  @override
  String get menu_itemAssignUrlToContainer => 'Tetapkan URL ke Kontainer';

  @override
  String get menu_itemUnassignUrlFromContainer => 'Lepaskan URL dari Kontainer';

  @override
  String get menu_itemUnassignContainer => 'Lepaskan Kontainer';

  @override
  String get menu_itemShare => 'Bagikan';

  @override
  String get menu_itemCopyAddress => 'Salin Alamat';

  @override
  String get menu_itemShareScreenshot => 'Bagikan Tangkapan Layar';

  @override
  String get menu_itemShareLink => 'Bagikan Tautan';

  @override
  String get menu_itemSendToDevice => 'Kirim ke Perangkat';

  @override
  String get menu_itemShowQrCode => 'Tampilkan Kode QR';

  @override
  String get menu_itemMoreDisclosure => 'Lainnya';

  @override
  String get menu_itemCloneTab => 'Duplikat Tab';

  @override
  String get menu_itemCloneRegularTab => 'Biasa';

  @override
  String get menu_itemClonePrivateTab => 'Pribadi';

  @override
  String get menu_itemCloneIsolatedTab => 'Terisolasi';

  @override
  String get menu_itemExport => 'Ekspor';

  @override
  String get menu_itemCopyAsMarkdown => 'Salin sebagai Markdown';

  @override
  String get menu_itemExportAsMarkdown => 'Ekspor sebagai Markdown';

  @override
  String get menu_itemExportAsPdf => 'Ekspor sebagai PDF';

  @override
  String get menu_itemExportAsPng => 'Ekspor sebagai PNG';

  @override
  String get menu_itemPrintPage => 'Cetak';

  @override
  String get menu_itemPinTopSite => 'Sematkan ke Pintasan';

  @override
  String get menu_itemFetchFeeds => 'Ambil Umpan';

  @override
  String get menu_itemHistory => 'Riwayat';

  @override
  String get menu_itemBookmarks => 'Markah';

  @override
  String get menu_itemDownloads => 'Unduhan';

  @override
  String get menu_itemBangs => 'Bang';

  @override
  String get menu_itemFeeds => 'Umpan';

  @override
  String get menu_itemSmallWeb => 'Small Web';

  @override
  String get menu_itemClearData => 'Hapus Data';

  @override
  String get menu_itemProfileSwitch => 'Profil';

  @override
  String get menu_itemSyncNow => 'Sinkronkan Sekarang';

  @override
  String get menu_itemAppSettings => 'Pengaturan';

  @override
  String get menu_itemQuitBrowser => 'Keluar dari Peramban';

  @override
  String get menu_itemAbout => 'Tentang';

  @override
  String get menu_itemMoreDisclosureDescription =>
      'Kelompokkan semua baris di bawahnya dalam baris \"Lainnya\"';

  @override
  String get menu_itemSendToDeviceDescription =>
      'Daftar perangkat berasal dari akun Anda';

  @override
  String get menu_reorderHideTooltip => 'Sembunyikan';

  @override
  String get menu_reorderShowTooltip => 'Tampilkan';

  @override
  String menu_reorderRowsShown(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$shown dari $total baris ditampilkan',
      one: '$shown dari 1 baris ditampilkan',
    );
    return '$_temp0';
  }

  @override
  String get menu_reorderDefaultTitle => 'Sesuaikan Menu';

  @override
  String get menu_reorderSubtitleSections =>
      'Seret untuk menata ulang. Matikan bagian untuk menyembunyikannya dari menu.';

  @override
  String get menu_reorderSubtitleSectionRows =>
      'Seret untuk menata ulang baris di bagian ini.';

  @override
  String get menu_reorderSubtitleItemRows =>
      'Seret untuk menata ulang baris yang dibuka oleh baris ini.';

  @override
  String get menu_reorderBackTooltip => 'Kembali ke bagian';

  @override
  String get menu_reorderResetToDefaults => 'Atur Ulang ke Bawaan';

  @override
  String get menu_customizeMenuButton => 'Sesuaikan menu';

  @override
  String get menu_navStop => 'Berhenti';

  @override
  String get menu_navBack => 'Kembali';

  @override
  String get menu_navForward => 'Maju';

  @override
  String get menu_navCloseTab => 'Tutup Tab';

  @override
  String get menu_navReload => 'Muat Ulang';

  @override
  String get menu_navCloseOthers => 'Tutup yang Lain';

  @override
  String get menu_navCloseFromSameHost => 'Tutup dari Host yang Sama';

  @override
  String get menu_navCloseTabAndDescendants => 'Tutup Tab dan Turunannya';

  @override
  String get menu_navHardRefresh => 'Muat Ulang Paksa';

  @override
  String get menu_profileTapToSwitch => 'Ketuk untuk beralih profil';

  @override
  String get menu_profileSyncComplete => 'Sinkronisasi selesai';

  @override
  String menu_openInApp(String appName) {
    return 'Buka di $appName';
  }

  @override
  String get menu_pageTranslated => 'Diterjemahkan';

  @override
  String get menu_extensionsTitle => 'Ekstensi';

  @override
  String get menu_extensionFallbackTitle => 'Ekstensi';

  @override
  String get menu_extensionsSettingsTooltip => 'Pengaturan ekstensi';

  @override
  String get menu_extensionsManage => 'Kelola Ekstensi';

  @override
  String get menu_containersExpansionTitle => 'Kontainer';

  @override
  String get menu_containersManage => 'Kelola Kontainer';

  @override
  String get menu_containersAssign => 'Tetapkan Kontainer';

  @override
  String get menu_containersAssignUrl => 'Tetapkan URL ke Kontainer';

  @override
  String get menu_containersUnassignUrl => 'Lepaskan URL dari Kontainer';

  @override
  String get menu_containersUnassign => 'Lepaskan Kontainer';

  @override
  String get menu_shareExpansionTitle => 'Bagikan';

  @override
  String get menu_shareUrlCleaned => 'URL dibersihkan';

  @override
  String get menu_shareUrlPreviewApplied => 'Pratinjau URL diterapkan';

  @override
  String get menu_shareCopyAddress => 'Salin Alamat';

  @override
  String get menu_shareScreenshot => 'Bagikan Tangkapan Layar';

  @override
  String get menu_shareLink => 'Bagikan Tautan';

  @override
  String get menu_shareShowQrCode => 'Tampilkan Kode QR';

  @override
  String get menu_sendToDeviceExpansionTitle => 'Kirim ke Perangkat';

  @override
  String get menu_sendToDeviceNone => 'Tidak ada perangkat tujuan';

  @override
  String get menu_sendToDeviceLoading => 'Memuat perangkat...';

  @override
  String get menu_sendToDeviceLoadFailed => 'Gagal memuat perangkat';

  @override
  String menu_sendToDeviceSuccess(String deviceName) {
    return 'Tab dikirim ke $deviceName';
  }

  @override
  String get menu_sendToDeviceSendFailed => 'Gagal mengirim tab';

  @override
  String get menu_cloneTabExpansionTitle => 'Duplikat Tab';

  @override
  String get menu_cloneTypeRegular => 'Biasa';

  @override
  String get menu_cloneTypePrivate => 'Pribadi';

  @override
  String get menu_cloneTypeIsolated => 'Terisolasi';

  @override
  String get menu_exportExpansionTitle => 'Ekspor';

  @override
  String get menu_exportCopyAsMarkdown => 'Salin sebagai Markdown';

  @override
  String get menu_exportAsMarkdown => 'Ekspor sebagai Markdown';

  @override
  String get menu_exportAsPdf => 'Ekspor sebagai PDF';

  @override
  String get menu_exportAsPng => 'Ekspor sebagai PNG';

  @override
  String get menu_exportMarkdownCopied => 'Markdown disalin ke papan klip';

  @override
  String get menu_exportPrint => 'Cetak';

  @override
  String get menu_exportPrintFailed => 'Gagal mencetak halaman';

  @override
  String get menu_pinUnpinFromShortcuts => 'Lepas Sematan dari Pintasan';

  @override
  String get menu_pinPinToShortcuts => 'Sematkan ke Pintasan';

  @override
  String get menu_pinUnpinnedMessage => 'Sematan dilepas dari Pintasan';

  @override
  String get menu_pinPinnedMessage => 'Disematkan ke Pintasan';

  @override
  String get menu_pinUpdateFailed => 'Gagal memperbarui Pintasan';

  @override
  String get menu_fetchFeedsTitle => 'Ambil Umpan di Halaman';

  @override
  String get menu_fetchFeedsNone => 'Tidak Ada Umpan Web';

  @override
  String get menu_fetchFeedsAvailable => 'Umpan Web yang Tersedia';

  @override
  String get menu_fetchFeedsLoading => 'Mengambil Umpan Web...';

  @override
  String get menu_connectionTitle => 'Koneksi';

  @override
  String get menu_connectionRegularTabs => 'Tab biasa';

  @override
  String get menu_connectionPrivateTabs => 'Tab pribadi';

  @override
  String menu_connectionAllThrough(String proxyTitle) {
    return 'Semua melalui $proxyTitle';
  }

  @override
  String get menu_connectionPerContainer => 'Per kontainer';

  @override
  String get menu_connectionPerContainerSubtitle =>
      'Hanya kontainer yang ditetapkan ke proksi yang dirutekan';

  @override
  String get menu_connectionDirect => 'Langsung';

  @override
  String get menu_connectionPrivateNeverInheritSubtitle =>
      'Tab pribadi tidak pernah mewarisi rute global';

  @override
  String get menu_connectionThisIsolatedTab => 'Tab terisolasi ini';

  @override
  String get menu_connectionFollowsContainer => 'Mengikuti kontainernya';

  @override
  String get menu_connectionFollowContainerOption => 'Ikuti kontainernya';

  @override
  String get menu_connectionFollowContainerOptionSubtitle =>
      'Gunakan rute yang ditetapkan untuk kontainer tab ini';

  @override
  String get menu_connectionIsolatedDirectSubtitle =>
      'Lewati rute yang akan diterapkan kontainernya';

  @override
  String get menu_connectionThisContainer => 'Kontainer ini';

  @override
  String get menu_connectionFollowsGlobalRouting => 'Mengikuti perutean global';

  @override
  String get menu_connectionContainerFallbackTitle => 'Kontainer';

  @override
  String get menu_connectionFollowGlobalRoutingOption =>
      'Ikuti perutean global';

  @override
  String get menu_connectionFollowGlobalRoutingOptionSubtitle =>
      'Gunakan rute yang sama dengan tab biasa';

  @override
  String get menu_connectionContainerDirectSubtitle =>
      'Lewati proksi global untuk kontainer ini';

  @override
  String menu_connectionFailedToChangeRoute(String error) {
    return 'Gagal mengubah rute: $error';
  }

  @override
  String menu_connectionProxyError(String error) {
    return 'Galat proksi: $error';
  }

  @override
  String menu_connectionNotRoutedByContainer(String container) {
    return 'Tidak dirutekan oleh kontainer \"$container\"';
  }

  @override
  String get menu_connectionNotRoutedByTabContainer =>
      'Tidak dirutekan oleh kontainer tab ini';

  @override
  String get menu_connectionCheckingRouting => 'Memeriksa perutean…';

  @override
  String get menu_connectionStartingRouting => 'Memulai perutean…';

  @override
  String menu_connectionBlockedNotRunning(String proxyTitle) {
    return 'Diblokir — $proxyTitle tidak berjalan';
  }

  @override
  String menu_connectionThisTabVia(String proxyTitle) {
    return 'Tab ini: $proxyTitle';
  }

  @override
  String get menu_connectionThisTabDirect => 'Tab ini: koneksi langsung';

  @override
  String menu_connectionStartProxy(String proxyTitle) {
    return 'Mulai $proxyTitle';
  }

  @override
  String get menu_connectionProxySettings => 'Pengaturan Proksi';

  @override
  String get menu_connectionUnused => 'Tidak digunakan oleh rute mana pun';

  @override
  String menu_connectionUsageContainerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kontainer',
      one: '1 kontainer',
    );
    return '$_temp0';
  }

  @override
  String menu_connectionUsageIsolatedTabCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab terisolasi',
      one: '1 tab terisolasi',
    );
    return '$_temp0';
  }

  @override
  String get menu_connectionUsageBlocked => 'Diblokir';

  @override
  String get contextmenu_openInNewTab => 'Buka di tab baru';

  @override
  String get contextmenu_tooltipOpenInDifferentTabType =>
      'Buka di jenis tab lain';

  @override
  String get contextmenu_newRegularTab => 'Tab biasa baru';

  @override
  String get contextmenu_newPrivateTab => 'Tab pribadi baru';

  @override
  String get contextmenu_newIsolatedTab => 'Tab terisolasi baru';

  @override
  String get contextmenu_openImageInNewTab => 'Buka gambar di tab baru';

  @override
  String get contextmenu_openInContainer => 'Buka di kontainer';

  @override
  String get contextmenu_selectContainerTitle => 'Pilih Kontainer';

  @override
  String get contextmenu_loadContainersFailedTitle => 'Gagal memuat kontainer';

  @override
  String get contextmenu_newContainer => 'Kontainer Baru';

  @override
  String get contextmenu_openInApp => 'Buka di Aplikasi';

  @override
  String contextmenu_openInAppNamed(String appName) {
    return 'Buka di $appName';
  }

  @override
  String get contextmenu_copyLink => 'Salin tautan';

  @override
  String get contextmenu_copyLinkText => 'Salin teks tautan';

  @override
  String get contextmenu_copyImage => 'Salin gambar';

  @override
  String get contextmenu_copyImageLocation => 'Salin lokasi gambar';

  @override
  String get contextmenu_saveFile => 'Simpan berkas';

  @override
  String get contextmenu_saveImage => 'Simpan gambar';

  @override
  String get contextmenu_shareImage => 'Bagikan gambar';

  @override
  String get contextmenu_shareEmailAddress => 'Bagikan alamat email';

  @override
  String get contextmenu_urlCleanedMessage => 'URL dibersihkan';

  @override
  String get contextmenu_urlPreviewAppliedMessage => 'Pratinjau URL diterapkan';

  @override
  String get findInPage_hint => 'Cari di halaman';

  @override
  String findInPage_matchPosition(int current, int total) {
    return '$current dari $total';
  }

  @override
  String get findInPage_noMatches => 'Tidak ditemukan';

  @override
  String get history_titleHistory => 'Riwayat';

  @override
  String get history_titleDownloads => 'Unduhan';

  @override
  String get history_filterHintHistory => 'Saring riwayat…';

  @override
  String get history_filterHintDownloads => 'Saring unduhan…';

  @override
  String history_selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 dipilih',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipClearSearch => 'Bersihkan pencarian';

  @override
  String get history_tooltipSearchHistory => 'Cari riwayat';

  @override
  String get history_tooltipSearchDownloads => 'Cari unduhan';

  @override
  String history_tooltipClearContainerHistory(String container) {
    return 'Hapus riwayat untuk \"$container\"';
  }

  @override
  String get history_filterDate => 'Tanggal';

  @override
  String get history_filterContainer => 'Kontainer';

  @override
  String get history_allContainers => 'Semua Kontainer';

  @override
  String get history_unnamedContainer => 'Kontainer Tanpa Nama';

  @override
  String history_containerFilterLabel(String container) {
    return 'Kontainer: $container';
  }

  @override
  String get history_resetFilter => 'Atur Ulang Filter';

  @override
  String get history_filterTypeFollowedLinks => 'Tautan yang Diikuti';

  @override
  String get history_filterTypeTypedAddresses => 'Alamat yang Diketik';

  @override
  String get history_filterTypeEmbeddedPageElements =>
      'Elemen Halaman Tersemat';

  @override
  String get history_filterTypePermanentRedirects => 'Pengalihan Permanen';

  @override
  String get history_filterTypeTemporaryRedirects => 'Pengalihan Sementara';

  @override
  String get history_filterTypeDownloads => 'Unduhan';

  @override
  String get history_filterTypeFrames => 'Bingkai';

  @override
  String get history_filterTypePageReloads => 'Muat Ulang Halaman';

  @override
  String get history_filterTypeBookmarks => 'Markah';

  @override
  String get history_visitTypeFollowedLink => 'Tautan yang diikuti';

  @override
  String get history_visitTypeTypedAddress => 'Alamat yang diketik';

  @override
  String get history_visitTypeEmbeddedPageElement => 'Elemen halaman tersemat';

  @override
  String get history_visitTypePermanentRedirect => 'Pengalihan permanen';

  @override
  String get history_visitTypeTemporaryRedirect => 'Pengalihan sementara';

  @override
  String get history_visitTypeDownload => 'Unduhan';

  @override
  String get history_visitTypeFrame => 'Bingkai';

  @override
  String get history_visitTypePageReload => 'Muat ulang halaman';

  @override
  String get history_visitTypeBookmark => 'Markah';

  @override
  String get history_clearContainerHistoryTitle => 'Hapus Riwayat Kontainer';

  @override
  String history_clearContainerHistoryContent(String container) {
    return 'Yakin ingin menghapus semua riwayat untuk \"$container\"?';
  }

  @override
  String get history_downloadedFileNotFound =>
      'Berkas yang diunduh tidak ditemukan';

  @override
  String get history_couldNotOpenDownloadedFile =>
      'Tidak dapat membuka berkas yang diunduh';

  @override
  String get history_loadHistoryFailedTitle => 'Gagal memuat riwayat';

  @override
  String get history_loadDownloadsFailedTitle => 'Gagal memuat unduhan';

  @override
  String get history_deleteFileTitle => 'Hapus Berkas';

  @override
  String history_deleteFileConfirm(String fileName) {
    return 'Yakin ingin menghapus $fileName?';
  }

  @override
  String get history_deleteFileWarning =>
      'Ini akan menghapus berkas secara permanen dari perangkat Anda.';

  @override
  String get history_deleteFileRememberChoice =>
      'Ingat pilihan saya untuk berkas yang tersisa';

  @override
  String get history_deleteFileActionKeep => 'Simpan';

  @override
  String get history_filterDistinctUrls => 'URL Unik';

  @override
  String history_visitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kunjungan',
      one: '1 kunjungan',
    );
    return '$_temp0';
  }

  @override
  String get history_tooltipDeleteHistory => 'Hapus riwayat';

  @override
  String get history_deleteMenuTimeRange => 'Hapus Rentang Waktu…';

  @override
  String get history_deleteMenuBrowsingData => 'Hapus Data Penjelajahan…';

  @override
  String get history_deleteTimeRangeTitle =>
      'Hapus Riwayat untuk Rentang Waktu';

  @override
  String get history_deleteTimeRangeFrom => 'Dari';

  @override
  String get history_deleteTimeRangeTo => 'Sampai';

  @override
  String get history_deleteTimeRangeLastHour => 'Satu jam terakhir';

  @override
  String get history_deleteTimeRangeToday => 'Hari ini';

  @override
  String get history_deleteTimeRangeLastWeek => '7 hari terakhir';

  @override
  String get history_deleteTimeRangeExplanation =>
      'Setiap kunjungan dalam rentang ini dihapus, di semua kontainer. Unduhan yang selesai dan gagal dari rentang ini juga dihapus dari daftar unduhan; berkasnya tetap ada di perangkat. Unduhan yang masih berjalan tetap disimpan.';

  @override
  String get history_deleteTimeRangeInvalid => 'Awal harus sebelum akhir.';

  @override
  String get history_tooltipEntryActions => 'Tindakan lainnya';

  @override
  String get history_actionOpenInBackground => 'Buka di Latar Belakang';

  @override
  String get history_actionCopyLink => 'Salin tautan';

  @override
  String get history_actionShareLink => 'Bagikan tautan';

  @override
  String get openLinkTools_openLinkTitle => 'Buka tautan';

  @override
  String get openLinkTools_urlCleanedMessage => 'URL dibersihkan';

  @override
  String get openLinkTools_urlPreviewAppliedMessage =>
      'Pratinjau URL diterapkan';

  @override
  String get openLinkTools_urlBlockedByClearUrls =>
      'URL diblokir oleh ClearURLs';

  @override
  String openLinkTools_unshortenFailedWithError(String error) {
    return 'Tidak dapat mengurai tautan pendek: $error';
  }

  @override
  String openLinkTools_unshortenRemainingCalls(int remaining, int limit) {
    return 'Sisa permintaan: $remaining/$limit';
  }

  @override
  String get openLinkTools_unshortenTileTitle => 'Urai tautan pendek';

  @override
  String get openLinkTools_unshortenTileSubtitle =>
      'Temukan tujuan URL yang dipendekkan';

  @override
  String get openLinkTools_unshortenerInfoTooltip =>
      'Info pengurai tautan pendek';

  @override
  String openLinkTools_openInAppNamed(String appName) {
    return 'Buka di $appName';
  }

  @override
  String get openLinkTools_openInAppGeneric => 'Buka di Aplikasi';

  @override
  String get openLinkTools_openInAppSubtitle =>
      'Buka di aplikasi yang terpasang';

  @override
  String get openLinkTools_couldNotOpenInApp =>
      'Tidak dapat membuka di aplikasi';

  @override
  String get openLinkTools_openInNewTabTitle => 'Buka di tab baru';

  @override
  String get openLinkTools_openInNewTabSubtitle =>
      'Tambahkan ke tab peramban Anda';

  @override
  String get openLinkTools_openInCustomTabTitle => 'Buka di tab kustom';

  @override
  String get openLinkTools_openInCustomTabSubtitle =>
      'Buka di jendela terpisah';

  @override
  String get openLinkTools_unshortenerAttributionTitle =>
      'Atribusi Pengurai Tautan Pendek';

  @override
  String openLinkTools_unshortenerAttributionBody(String service) {
    return 'Modul ini mengurai tautan pendek dengan mengirimkannya ke $service. Layanan tersebut memeriksa setiap tautan di servernya dan menyimpan pengalihannya untuk permintaan berikutnya. Hindari mengirim tautan yang berisi data pribadi atau sensitif.';
  }

  @override
  String get openLinkTools_unshortenerRateLimitNotice =>
      'API gratis dibatasi hingga 10 permintaan per jam untuk pemeriksaan baru.';

  @override
  String openLinkTools_privacyPolicyLabel(String link) {
    return 'Kebijakan privasi: $link';
  }

  @override
  String get openLinkTools_removeTrackingParametersTitle =>
      'Hapus Parameter Pelacakan';

  @override
  String get openLinkTools_removeTrackingParametersSubtitle =>
      'Pilih parameter yang akan dihapus dari URL ini.';

  @override
  String get openLinkTools_referralMarketingBadge => 'Pemasaran rujukan';

  @override
  String openLinkTools_selectedForRemovalCount(int selected, int total) {
    return '$selected dari $total dipilih untuk dihapus';
  }

  @override
  String get openLinkTools_cleanedUrlLabel => 'URL yang dibersihkan:';

  @override
  String get openLinkTools_restoreDefaultsTitle => 'Pulihkan bawaan?';

  @override
  String get openLinkTools_restoreDefaultsContent =>
      'Ini akan mengatur ulang pengaturan pembersih URL dan menghapus katalog yang tersimpan secara lokal.';

  @override
  String get openLinkTools_actionRestore => 'Pulihkan';

  @override
  String get openLinkTools_actionApplyChanges => 'Terapkan Perubahan';

  @override
  String openLinkTools_couldNotOpenLink(String url) {
    return 'Tidak dapat membuka tautan: $url';
  }

  @override
  String get openLinkTools_tileTitleCleaned => 'URL dibersihkan';

  @override
  String openLinkTools_tileSubtitleRemovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameter pelacakan dihapus',
      one: '1 parameter pelacakan dihapus',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitlePartiallyCleaned =>
      'URL dibersihkan sebagian';

  @override
  String openLinkTools_tileSubtitlePartiallyCleaned(int removed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$removed dari $total parameter pelacakan dihapus',
      one: '$removed dari 1 parameter pelacakan dihapus',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_tileTitleTrackingDetected => 'Pelacakan terdeteksi';

  @override
  String openLinkTools_tileSubtitleFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameter pelacakan ditemukan',
      one: '1 parameter pelacakan ditemukan',
    );
    return '$_temp0';
  }

  @override
  String get openLinkTools_cleanUrlTooltip => 'Bersihkan URL';

  @override
  String get openLinkTools_unshortenerSettingsTitle => 'Pengurai Tautan Pendek';

  @override
  String get openLinkTools_unshortenerSettingsSubtitle =>
      'Perilaku penguraian tautan pendek, konfigurasi token, dan atribusi.';

  @override
  String get openLinkTools_unshortenerEnabledTitle =>
      'Aktifkan Pengurai Tautan Pendek';

  @override
  String get openLinkTools_unshortenerEnabledKeywords =>
      'tautan pendek, pemendek, short links, unshorten';

  @override
  String get openLinkTools_unshortenerEnabledSubtitle =>
      'Urai URL yang dipendekkan ke tujuannya';

  @override
  String get openLinkTools_descriptionLabel => 'Deskripsi';

  @override
  String get openLinkTools_unshortenerDescriptionBody =>
      'Modul ini mengurai tautan pendek dengan mengirimkannya ke unshorten.me. Layanan tersebut memeriksa setiap tautan di servernya dan menyimpan pengalihannya untuk permintaan berikutnya. Hindari mengirim tautan yang berisi data pribadi atau sensitif.';

  @override
  String get openLinkTools_attributionServiceLabel => 'Layanan';

  @override
  String get openLinkTools_attributionPrivacyPolicyLabel => 'Kebijakan privasi';

  @override
  String get openLinkTools_apiTokenLabel => 'Token API';

  @override
  String get openLinkTools_apiTokenLabelKeywords => 'token, kunci';

  @override
  String get openLinkTools_apiTokenHint =>
      'Token opsional untuk batas yang lebih tinggi';

  @override
  String get openLinkTools_urlCleanerSettingsTitle => 'Pembersih URL';

  @override
  String get openLinkTools_urlCleanerSettingsSubtitle =>
      'Perilaku pembersihan URL, pembaruan katalog aturan, dan atribusi.';

  @override
  String get openLinkTools_urlCleanerDescriptionBody =>
      'Modul ini menghapus parameter pelacakan, perujuk, dan parameter lain yang tidak perlu dari URL. Modul ini juga dapat mengurai pengalihan URL umum secara luring.';

  @override
  String get openLinkTools_urlCleanerEnabledTitle => 'Aktifkan Pembersih URL';

  @override
  String get openLinkTools_urlCleanerEnabledKeywords =>
      'bersihkan url, pelacakan, clean urls, clearurls';

  @override
  String get openLinkTools_urlCleanerEnabledSubtitle =>
      'Hapus parameter pelacakan dari URL';

  @override
  String get openLinkTools_autoApplyTitle => 'Terapkan otomatis';

  @override
  String get openLinkTools_autoApplyKeywords => 'otomatis, auto apply';

  @override
  String get openLinkTools_autoApplySubtitle =>
      'Ganti URL secara otomatis dengan versi yang sudah dibersihkan';

  @override
  String get openLinkTools_allowReferralTitle => 'Izinkan pemasaran rujukan';

  @override
  String get openLinkTools_allowReferralKeywords =>
      'afiliasi, rujukan, affiliate, referral';

  @override
  String get openLinkTools_allowReferralSubtitle =>
      'Pertahankan parameter pelacakan rujukan dan afiliasi';

  @override
  String get openLinkTools_autoUpdateCatalogTitle =>
      'Perbarui katalog otomatis';

  @override
  String get openLinkTools_autoUpdateCatalogSubtitle =>
      'Periksa pembaruan aturan setiap minggu';

  @override
  String get openLinkTools_updateCatalogTitle => 'Perbarui katalog';

  @override
  String get openLinkTools_lastUpdateNotAvailable =>
      'Pembaruan terakhir: tidak tersedia';

  @override
  String openLinkTools_lastUpdateWithDate(String date) {
    return 'Pembaruan terakhir: $date';
  }

  @override
  String openLinkTools_lastAutoUpdateWithDate(String date) {
    return 'Pembaruan terakhir: $date (otomatis)';
  }

  @override
  String openLinkTools_lastCheckWithDate(String date) {
    return 'Pemeriksaan terakhir: $date';
  }

  @override
  String get openLinkTools_catalogUpdatedMessage => 'Katalog diperbarui';

  @override
  String openLinkTools_updateFailedWithError(String error) {
    return 'Pembaruan gagal: $error';
  }

  @override
  String get openLinkTools_restoreDefaultsButtonTitle => 'Pulihkan bawaan';

  @override
  String get openLinkTools_restoreDefaultsButtonSubtitle =>
      'Kembalikan ke katalog bawaan aplikasi dan pengaturan bawaan';

  @override
  String get openLinkTools_clearUrlAttributionText =>
      'Modul ini didasarkan pada aturan ClearURL:';

  @override
  String get openLinkTools_urlCleanerOverviewSectionTitle => 'Ikhtisar';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionTitle => 'Deskripsi';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionKeywords =>
      'parameter pelacakan, pengalihan, tracking parameters, redirects';

  @override
  String get openLinkTools_indexUrlCleanerDescriptionSubtitle =>
      'Penghapusan parameter pelacakan dan pembersihan pengalihan secara luring';

  @override
  String get openLinkTools_urlCleanerBehaviorSectionTitle => 'Perilaku';

  @override
  String get openLinkTools_urlCleanerCatalogSectionTitle => 'Katalog';

  @override
  String get openLinkTools_indexUrlCleanerUpdateCatalogSubtitle =>
      'Ambil aturan pembersih URL terbaru';

  @override
  String get openLinkTools_urlCleanerAttributionSectionTitle => 'Atribusi';

  @override
  String get openLinkTools_indexUrlCleanerAttributionTitle => 'Atribusi';

  @override
  String get openLinkTools_indexUrlCleanerAttributionSubtitle =>
      'Kredit dan tautan sumber';

  @override
  String get openLinkTools_unshortenerOverviewSectionTitle => 'Ikhtisar';

  @override
  String get openLinkTools_indexUnshortenerDescriptionTitle => 'Deskripsi';

  @override
  String get openLinkTools_indexUnshortenerDescriptionKeywords =>
      'tautan pendek, pengalihan, short links, redirects';

  @override
  String get openLinkTools_indexUnshortenerDescriptionSubtitle =>
      'Urai URL yang dipendekkan menggunakan layanan unshorten.me';

  @override
  String get openLinkTools_unshortenerBehaviorSectionTitle => 'Perilaku';

  @override
  String get openLinkTools_indexUnshortenerApiTokenSubtitle =>
      'Token opsional untuk batas permintaan yang lebih tinggi';

  @override
  String get openLinkTools_unshortenerAttributionSectionTitle => 'Atribusi';

  @override
  String get openLinkTools_indexUnshortenerAttributionTitle =>
      'Atribusi layanan';

  @override
  String get openLinkTools_indexUnshortenerAttributionKeywords =>
      'kebijakan privasi, batas permintaan, privacy policy, rate limit';

  @override
  String get openLinkTools_indexUnshortenerAttributionSubtitle =>
      'Batas permintaan, beranda layanan, dan kebijakan privasi';

  @override
  String get pwa_addToHomeScreenTitle => 'Tambahkan ke Layar Utama';

  @override
  String get pwa_nameFieldLabel => 'Nama';

  @override
  String get pwa_storageLabel => 'Penyimpanan';

  @override
  String get pwa_defaultContainerLabel => 'Kontainer';

  @override
  String get pwa_installAsAppTitle => 'Pasang sebagai Aplikasi';

  @override
  String get pwa_installAsAppSubtitle =>
      'Berjalan mandiri dengan jendelanya sendiri.';

  @override
  String get pwa_addShortcutTitle => 'Tambahkan Pintasan';

  @override
  String get pwa_addShortcutSubtitle => 'Dibuka sebagai tab biasa di peramban.';

  @override
  String get pwa_storageDefaultTitle => 'Bawaan';

  @override
  String get pwa_storageDefaultSubtitle =>
      'Menggunakan penyimpanan peramban bawaan (tanpa kontainer).';

  @override
  String pwa_storageContainerTitle(String label) {
    return 'Kontainer \"$label\"';
  }

  @override
  String get pwa_storageContainerSubtitle =>
      'Berbagi kuki dan data dengan kontainer yang dipilih.';

  @override
  String get pwa_storageInheritIsolatedTitle =>
      'Warisi konteks terisolasi saat ini';

  @override
  String get pwa_storageInheritIsolatedSubtitle =>
      'Berbagi penyimpanan dengan sesi terisolasi yang sedang terbuka.';

  @override
  String get pwa_storageNewIsolatedTitle => 'Konteks terisolasi baru';

  @override
  String get pwa_storageNewIsolatedSubtitle =>
      'Membuat wadah penyimpanan baru khusus untuk pemasangan ini.';

  @override
  String get pwa_defaultWebAppName => 'aplikasi web ini';

  @override
  String get pwa_defaultSiteName => 'situs ini';

  @override
  String pwa_addedToHomeScreen(String name) {
    return '$name ditambahkan ke layar utama';
  }

  @override
  String pwa_installFailedManifestBacked(String name) {
    return 'Gagal menambahkan $name. Situs ini mungkin tidak mendukung pemasangan.';
  }

  @override
  String pwa_installFailedGeneric(String name) {
    return 'Gagal menambahkan $name ke layar utama';
  }

  @override
  String get pwa_noTabSelected =>
      'Tidak ada tab yang dipilih. Silakan coba lagi.';

  @override
  String get search_moduleLabelRecentSearches => 'Pencarian Terbaru';

  @override
  String get search_moduleLabelSearchProviders => 'Penyedia Pencarian';

  @override
  String get search_moduleLabelSearchSuggestions => 'Saran';

  @override
  String get search_moduleLabelTabs => 'Tab';

  @override
  String get search_moduleLabelArticles => 'Artikel';

  @override
  String get search_moduleLabelBookmarks => 'Markah';

  @override
  String get search_moduleLabelHistory => 'Riwayat (mesin)';

  @override
  String get search_moduleLabelLocalHistory => 'Konten lokal';

  @override
  String get search_moduleLabelCombinedHistory => 'Riwayat';

  @override
  String get search_moduleLabelPopularSites => 'Situs Populer';

  @override
  String get search_moduleLabelHistoryHighlights => 'Sorotan Riwayat';

  @override
  String get search_moduleLabelTopSites => 'Pintasan';

  @override
  String get search_moduleLabelRecentHistory => 'Riwayat Terbaru';

  @override
  String get search_moduleLabelRecentArticles => 'Artikel Terbaru';

  @override
  String get search_moduleLabelRecentTabs => 'Tab Terbaru';

  @override
  String get search_moduleLabelContainers => 'Kontainer';

  @override
  String get search_moduleLabelFrequentBangs => 'Bang yang Sering Dipakai';

  @override
  String get search_moduleLabelQuote => 'Kutipan';

  @override
  String get search_moduleLabelQuickActions => 'Tindakan Cepat';

  @override
  String get search_moduleLabelActions => 'Tindakan';

  @override
  String get search_couldNotLoadHistory => 'Tidak dapat memuat riwayat';

  @override
  String get search_couldNotLoadLocalContent =>
      'Tidak dapat memuat konten lokal';

  @override
  String get search_failedSearchingArticles => 'Pencarian artikel gagal';

  @override
  String get search_contentMatchTooltip => 'Cocok dengan konten';

  @override
  String get search_tabTypeRegular => 'Biasa';

  @override
  String get search_tabTypeChild => 'Anak';

  @override
  String get search_tabTypePrivate => 'Pribadi';

  @override
  String get search_tabTypeIsolated => 'Terisolasi';

  @override
  String get search_fillLinkFromClipboard => 'Isi tautan dari papan klip';

  @override
  String get search_actionNewTab => 'Tab baru';

  @override
  String get search_actionViewTabs => 'Lihat tab';

  @override
  String get search_actionResumeLastTab => 'Lanjutkan tab terakhir';

  @override
  String get search_bangTabAllProviders => 'Semua Penyedia';

  @override
  String get search_bangTabSearchOnThisSite => 'Cari di Situs Ini';

  @override
  String get search_editShortcutDialogTitle => 'Edit Pintasan';

  @override
  String get search_addShortcut => 'Tambahkan pintasan';

  @override
  String get search_titleFieldLabel => 'Judul';

  @override
  String get search_urlFieldLabel => 'URL';

  @override
  String get search_titleCannotBeEmpty => 'Judul tidak boleh kosong';

  @override
  String get search_urlCannotBeEmpty => 'URL tidak boleh kosong';

  @override
  String get search_enterValidUrl => 'Masukkan URL yang valid';

  @override
  String get search_actionPin => 'Sematkan';

  @override
  String get search_actionUnpin => 'Lepas sematan';

  @override
  String get search_actionResetFrequency => 'Atur ulang frekuensi';

  @override
  String get search_actionEditBang => 'Edit bang';

  @override
  String get search_actionCustomizeAsOwnBang =>
      'Sesuaikan sebagai bang Anda sendiri';

  @override
  String search_resetBangDialogTitle(String triggerName) {
    return 'Atur ulang frekuensi penggunaan $triggerName?';
  }

  @override
  String get search_resetBangDialogContent =>
      'Ini akan menghapus bang dari daftar pilihan cepat.';

  @override
  String get search_customizeSectionsButton => 'Sesuaikan bagian';

  @override
  String get search_customizeSectionsHeading => 'Sesuaikan Bagian';

  @override
  String get search_resetToDefaults => 'Atur Ulang ke Bawaan';

  @override
  String search_showAllCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tampilkan semua $count',
    );
    return '$_temp0';
  }

  @override
  String get search_disableReorderingMode => 'Nonaktifkan mode penataan ulang';

  @override
  String get search_enableReorderingMode => 'Aktifkan mode penataan ulang';

  @override
  String get search_dragDropShortcutsHint =>
      'Seret dan lepas pintasan untuk menata ulang';

  @override
  String get search_failedReorderShortcut => 'Gagal menata ulang pintasan';

  @override
  String search_hideAllFromHost(String host) {
    return 'Sembunyikan semua dari $host';
  }

  @override
  String search_pinnedSite(String title) {
    return '\"$title\" disematkan';
  }

  @override
  String get search_failedPinSite => 'Gagal menyematkan situs';

  @override
  String get search_shortcutUpdated => 'Pintasan diperbarui';

  @override
  String get search_failedUpdateShortcut => 'Gagal memperbarui pintasan';

  @override
  String search_addedSite(String title) {
    return '\"$title\" ditambahkan';
  }

  @override
  String get search_failedAddShortcut => 'Gagal menambahkan pintasan';

  @override
  String search_hidAllShortcutsFromHost(String host) {
    return 'Semua pintasan dari $host disembunyikan';
  }

  @override
  String search_removedSite(String title) {
    return '\"$title\" dihapus';
  }

  @override
  String get search_failedRemoveShortcut => 'Gagal menghapus pintasan';

  @override
  String get search_quoteCardTitle => 'Renungan untuk perjalanan';

  @override
  String get search_refreshQuoteTooltip => 'Muat kutipan lain';

  @override
  String get search_quotePlaceholder =>
      'Buka tab baru dan jadikan ruang ini milik Anda.';

  @override
  String get search_searchFieldLabel => 'Cari atau masukkan URL';

  @override
  String get search_invalidAddress => 'Alamat tidak valid';

  @override
  String get search_actionSwitchToContainer => 'Beralih ke kontainer';

  @override
  String get search_actionSwitchToProfile =>
      'Beralih ke profil ini (memulai ulang peramban)';

  @override
  String get search_actionOpenFeed => 'Buka umpan';

  @override
  String search_actionSettingLocation(String category, String section) {
    return 'Pengaturan › $category › $section';
  }

  @override
  String search_actionSettingCategory(String category) {
    return 'Pengaturan › $category';
  }

  @override
  String get search_actionUnnamedContainer => 'Kontainer tanpa nama';

  @override
  String get search_actionUntitledFeed => 'Umpan tanpa judul';

  @override
  String get tabs_actionSelect => 'Pilih';

  @override
  String get tabs_actionUnselect => 'Batalkan pilihan';

  @override
  String get tabs_unsavedChangesTitle => 'Perubahan Belum Disimpan';

  @override
  String get tabs_unsavedChangesConfirm =>
      'Ada perubahan yang belum disimpan. Buang atau simpan perubahan tersebut?';

  @override
  String get tabs_deleteContainerTitle => 'Hapus Kontainer';

  @override
  String get tabs_deleteContainerConfirm =>
      'Yakin ingin menghapus kontainer ini? Tab-tabnya akan ditutup.';

  @override
  String get tabs_deleteContainerAlsoDeleteHistory =>
      'Hapus juga riwayat penjelajahan';

  @override
  String get tabs_deleteContainerHistoryKeptNote =>
      'Jika tidak dicentang, kunjungan tetap ada di riwayat tetapi tidak lagi ditetapkan ke kontainer.';

  @override
  String get tabs_deleteContainerButton => 'Hapus Kontainer';

  @override
  String get tabs_containersTitle => 'Kontainer';

  @override
  String get tabs_noContainersYet => 'Belum ada kontainer';

  @override
  String get tabs_loadContainersFailedTitle => 'Gagal memuat kontainer';

  @override
  String get tabs_containerFabLabel => 'Kontainer Baru';

  @override
  String get tabs_untitledContainer => 'Tanpa judul';

  @override
  String get tabs_emptyContainerLabel => 'Kosong';

  @override
  String tabs_tabCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab',
      one: '1 tab',
    );
    return '$_temp0';
  }

  @override
  String get tabs_chipPinned => 'Disematkan';

  @override
  String get tabs_chipIsolated => 'Terisolasi';

  @override
  String get tabs_chipDirect => 'Langsung';

  @override
  String get tabs_chipClearOnExit => 'Dihapus saat Keluar';

  @override
  String get tabs_chipActive => 'Aktif';

  @override
  String get tabs_selectContainerTitle => 'Pilih Kontainer';

  @override
  String get tabs_unassignedTitle => 'Tanpa Kontainer';

  @override
  String get tabs_unassignedSubtitle =>
      'Tab yang tidak ditetapkan ke kontainer';

  @override
  String get tabs_draftContainersTitle => 'Saran Kontainer';

  @override
  String get tabs_suggestionsFailedTitle => 'Gagal memuat saran';

  @override
  String get tabs_siteAssignmentsTitle => 'Penetapan Situs';

  @override
  String get tabs_addSiteLabel => 'Tambah situs';

  @override
  String get tabs_addSiteHint => 'example.com atau *.example.com';

  @override
  String get tabs_addSiteHelperText =>
      'Cocokkan satu situs, atau gunakan *.example.com untuk mencocokkan semua subdomainnya';

  @override
  String get tabs_urlMustBeProvided => 'URL wajib diisi';

  @override
  String get tabs_invalidUrl => 'URL tidak valid';

  @override
  String get tabs_siteAlreadyAssigned => 'Situs ini sudah ditetapkan';

  @override
  String tabs_siteAlreadyAssignedToNamedContainer(
    String site,
    String containerName,
  ) {
    return '$site sudah ditetapkan ke \"$containerName\"';
  }

  @override
  String tabs_siteAlreadyAssignedToAnotherContainer(String site) {
    return '$site sudah ditetapkan ke kontainer lain';
  }

  @override
  String get tabs_newContainerTitle => 'Kontainer Baru';

  @override
  String get tabs_editContainerTitle => 'Edit Kontainer';

  @override
  String get tabs_containerNameHint => 'Nama Kontainer';

  @override
  String get tabs_changeColor => 'Ubah Warna';

  @override
  String get tabs_changeIcon => 'Ubah Ikon';

  @override
  String get tabs_sectionDisplay => 'Tampilan';

  @override
  String get tabs_pinContainer => 'Sematkan Kontainer';

  @override
  String get tabs_pinContainerSubtitle =>
      'Pertahankan kontainer ini di bagian atas daftar';

  @override
  String get tabs_wallpaperLabel => 'Wallpaper';

  @override
  String get tabs_wallpaperSelectedSubtitle =>
      'Ditampilkan di beranda saat kontainer ini dipilih';

  @override
  String get tabs_wallpaperDefaultSubtitle =>
      'Menggunakan wallpaper dari pengaturan';

  @override
  String get tabs_wallpaperEmptyDescription =>
      'Kontainer ini memakai wallpaper yang diatur di pengaturan.';

  @override
  String get tabs_sectionPrivacySecurity => 'Privasi & Keamanan';

  @override
  String get tabs_cookieIsolation => 'Isolasi Kuki';

  @override
  String get tabs_proxyConnectionLabel => 'Koneksi Proksi';

  @override
  String get tabs_proxyConnectionNone => 'Tidak ada';

  @override
  String get tabs_bypassGlobalProxy => 'Lewati Proksi Global';

  @override
  String get tabs_bypassGlobalProxySubtitle =>
      'Gunakan koneksi biasa untuk kontainer ini saat perutean global diaktifkan';

  @override
  String get tabs_clearDataOnExit => 'Hapus Data saat Keluar';

  @override
  String get tabs_clearDataOnExitSubtitle =>
      'Hapus kuki dan data situs untuk tab biasa di kontainer ini saat aplikasi ditutup. Tab terisolasi menyimpan data terpisah.';

  @override
  String get tabs_excludeFromSearchIndex => 'Kecualikan dari Indeks Pencarian';

  @override
  String get tabs_excludeFromSearchIndexSubtitle =>
      'Jangan masukkan halaman dari kontainer ini ke indeks pencarian lokal';

  @override
  String get tabs_excludeFromHistory => 'Kecualikan dari Riwayat';

  @override
  String get tabs_excludeFromHistorySubtitle =>
      'Jangan catat kunjungan baru dari tab kontainer ini, dan hapus halamannya dari pencarian lokal. Riwayat penjelajahan yang ada tetap disimpan.';

  @override
  String get tabs_sectionAssignments => 'Penetapan';

  @override
  String get tabs_assignedSites => 'Situs yang Ditetapkan';

  @override
  String tabs_assignedSitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aturan dikonfigurasi',
      one: '1 aturan dikonfigurasi',
    );
    return '$_temp0';
  }

  @override
  String get tabs_assignedSitesEmptySubtitle =>
      'Arahkan situs yang cocok ke kontainer ini';

  @override
  String get tabs_strictMode => 'Mode Ketat';

  @override
  String get tabs_strictModeSubtitle =>
      'Hanya izinkan situs yang ditetapkan untuk dimuat; blokir yang lainnya';

  @override
  String get tabs_requiresCookieIsolation =>
      'Memerlukan isolasi kuki untuk diaktifkan';

  @override
  String get tabs_sectionAppLinks => 'Tautan Aplikasi';

  @override
  String get tabs_isolatedAppLinkSettings =>
      'Pengaturan Tautan Aplikasi Terpisah';

  @override
  String get tabs_isolatedAppLinkSettingsSubtitle =>
      'Gunakan mode buka-di-aplikasi dan aturan situs yang diingat secara terpisah untuk kontainer ini, alih-alih pengaturan global';

  @override
  String get tabs_appLinkBehavior => 'Perilaku Tautan Aplikasi';

  @override
  String get tabs_appLinkBehaviorSubtitle =>
      'Atur mode buka-di-aplikasi dan situs yang diingat untuk kontainer ini';

  @override
  String get tabs_selectColorTitle => 'Pilih Warna';

  @override
  String get tabs_customColorTitle => 'Warna Kustom';

  @override
  String get tabs_hexLabel => 'Hex';

  @override
  String get tabs_hueLabel => 'Rona';

  @override
  String get tabs_saturationLabel => 'Saturasi';

  @override
  String get tabs_lightnessLabel => 'Kecerahan';

  @override
  String get tabs_chooseIconTitle => 'Pilih Ikon';

  @override
  String tabs_iconCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ikon MDI',
      one: '1 ikon MDI',
    );
    return '$_temp0';
  }

  @override
  String get tabs_searchIconsHint => 'Cari ikon MDI';

  @override
  String get tabs_noIconsFound => 'Ikon tidak ditemukan.';

  @override
  String get gestures_screenTitle => 'Gestur';

  @override
  String get gestures_builtInGestureKeywords => 'usap, geser, swipe';

  @override
  String get gestures_resetSwipesToDefaultsAction =>
      'Atur Ulang Usapan ke Bawaan';

  @override
  String get gestures_twoFingerSwipeTitle => 'Usap dua jari';

  @override
  String get gestures_twoFingerSwipeKeywords => 'kontainer, container';

  @override
  String get gestures_twoFingerSwipeAction =>
      'Kontainer berikutnya atau sebelumnya';

  @override
  String get gestures_pinchTitle => 'Cubit';

  @override
  String get gestures_pinchKeywords =>
      'kisi, daftar, pohon, tata letak, grid, list, tree, layout';

  @override
  String get gestures_pinchAction => 'Tata letak kisi, daftar, atau pohon';

  @override
  String get gestures_webPagesSectionTitle => 'Halaman Web';

  @override
  String get gestures_drawnGesturesTitle => 'Gestur gambar';

  @override
  String get gestures_drawnGesturesKeywords => 'goresan, stroke';

  @override
  String get gestures_drawnGesturesSubtitle =>
      'Gambar goresan di halaman untuk menjalankan tindakan';

  @override
  String get gestures_gestureBindingsTitle => 'Pemetaan gestur';

  @override
  String get gestures_gestureBindingsSubtitle =>
      'Goresan yang dipetakan ke tindakan';

  @override
  String get gestures_behaviorTimingTitle => 'Perilaku & waktu';

  @override
  String get gestures_behaviorTimingSubtitleShort =>
      'Panjang goresan, batas waktu, jeda';

  @override
  String get gestures_excludedSitesTitle => 'Situs yang dikecualikan';

  @override
  String get gestures_excludedSitesSubtitle => 'Nonaktifkan gestur per situs';

  @override
  String get gestures_feedbackTitle => 'Umpan balik';

  @override
  String get gestures_feedbackSubtitleShort => 'Overlay langsung dan saran';

  @override
  String get gestures_pullToRefreshTitle => 'Tarik untuk menyegarkan';

  @override
  String get gestures_pullToRefreshKeywords => 'muat ulang, segarkan, reload';

  @override
  String get gestures_pullToRefreshSubtitle =>
      'Usap ke bawah di bagian atas halaman untuk memuat ulang';

  @override
  String get gestures_toolbarSectionTitle => 'Bilah Alat';

  @override
  String get gestures_longPressButtonsTitle => 'Tekan lama pada tombol';

  @override
  String get gestures_longPressButtonsSubtitle =>
      'Dipilih per tombol saat menyesuaikan bilah alat';

  @override
  String get gestures_builtInCannotBeChangedDescription =>
      'Bawaan, tidak dapat diubah';

  @override
  String get gestures_doNothingTitle => 'Tidak melakukan apa pun';

  @override
  String get gestures_doNothingSubtitle => 'Usapan diabaikan';

  @override
  String get gestures_restoreDefaultGesturesTooltip => 'Pulihkan gestur bawaan';

  @override
  String get gestures_addGestureButtonLabel => 'Tambah gestur';

  @override
  String get gestures_restoreDefaultGesturesConfirmTitle =>
      'Pulihkan gestur bawaan?';

  @override
  String get gestures_restoreDefaultGesturesConfirmContent =>
      'Setiap gestur kembali ke tindakan bawaannya. Perubahan Anda akan hilang.';

  @override
  String get gestures_noGesturesAssignedMessage =>
      'Belum ada gestur yang ditetapkan.';

  @override
  String get gestures_replaceExistingGestureTitle => 'Ganti gestur yang ada?';

  @override
  String gestures_replaceExistingGestureContent(String action) {
    return 'Goresan ini sudah ditetapkan ke \"$action\". Menyimpan akan menggantikan pemetaan tersebut.';
  }

  @override
  String get gestures_createGestureTitle => 'Buat gestur';

  @override
  String get gestures_editGestureTitle => 'Edit gestur';

  @override
  String get gestures_targetActionLabel => 'Tindakan tujuan';

  @override
  String get gestures_startPositionLabel => 'Posisi awal';

  @override
  String get gestures_fingersLabel => 'Jari';

  @override
  String get gestures_strokePatternLabel => 'Pola goresan';

  @override
  String get gestures_drawStrokePatternPlaceholder =>
      'Gambar pola goresan di bawah';

  @override
  String get gestures_undoLastAction => 'Urungkan terakhir';

  @override
  String get gestures_replaceGestureButtonLabel => 'Ganti gestur';

  @override
  String get gestures_saveGestureButtonLabel => 'Simpan gestur';

  @override
  String gestures_collisionWarning(String action) {
    return 'Sudah ditetapkan ke \"$action\". Menyimpan akan menggantikannya.';
  }

  @override
  String get gestures_chooseActionTitle => 'Pilih tindakan';

  @override
  String get gestures_behaviorTimingScreenSubtitle =>
      'Panjang goresan, batas waktu, dan jeda.';

  @override
  String get gestures_resetToDefaultsTooltip => 'Atur ulang ke bawaan';

  @override
  String get gestures_resetBehaviorTimingConfirmTitle =>
      'Atur ulang perilaku & waktu?';

  @override
  String get gestures_resetBehaviorTimingConfirmContent =>
      'Panjang goresan, batas waktu, jeda, dan interval goresan akan dikembalikan ke bawaannya. Pemetaan gestur dan pengaturan lainnya tetap disimpan.';

  @override
  String get gestures_minStrokeLengthTitle => 'Panjang goresan minimum';

  @override
  String get gestures_minStrokeLengthKeywords =>
      'ukuran, panjang, sensitivitas, size, length, sensitivity';

  @override
  String get gestures_timeoutTitle => 'Batas waktu';

  @override
  String get gestures_timeoutKeywords => 'tunda, jeda, delay, timeout';

  @override
  String get gestures_timeoutDescription =>
      'Goresan dibatalkan jika tidak ada arah baru yang digambar dalam waktu ini.';

  @override
  String get gestures_cooldownTitle => 'Jeda';

  @override
  String get gestures_cooldownKeywords => 'interval, cooldown';

  @override
  String get gestures_cooldownDescription =>
      'Jeda minimum antara dua gestur yang dijalankan.';

  @override
  String get gestures_strokeIntervalTitle => 'Interval goresan';

  @override
  String get gestures_strokeIntervalKeywords =>
      'debounce, jitter, tidak sengaja, accidental';

  @override
  String get gestures_strokeIntervalDescription =>
      'Waktu minimum antara perubahan arah dalam satu gestur. Perubahan yang lebih cepat membatalkan gestur, untuk mencegah pemicuan yang tidak disengaja.';

  @override
  String get gestures_offLabel => 'Nonaktif';

  @override
  String get gestures_excludedSitesDescription =>
      'Gestur dinonaktifkan di situs-situs ini. Subdomain juga termasuk (mis. \"example.com\" juga mencakup \"m.example.com\").';

  @override
  String get gestures_noSitesExcludedMessage =>
      'Tidak ada situs yang dikecualikan.';

  @override
  String get gestures_feedbackScreenSubtitle =>
      'Overlay langsung dan saran gestur.';

  @override
  String get gestures_liveFeedbackTitle => 'Umpan balik langsung';

  @override
  String get gestures_liveFeedbackSubtitle =>
      'Tampilkan goresan dan tindakannya saat Anda menggambar';

  @override
  String get gestures_suggestNextTitle => 'Sarankan berikutnya';

  @override
  String get gestures_suggestNextSubtitle =>
      'Tampilkan juga gestur lain yang dapat Anda selesaikan';

  @override
  String get gestures_suggestAfterTitle => 'Sarankan setelah';

  @override
  String gestures_strokeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goresan',
      one: '1 goresan',
    );
    return '$_temp0';
  }

  @override
  String get gestures_suggestAfterDescription =>
      'Jumlah goresan yang digambar sebelum saran muncul.';

  @override
  String get gestures_actionRestore => 'Pulihkan';

  @override
  String get gestures_actionReplace => 'Ganti';

  @override
  String get gestures_tabBarSurfaceTitle => 'Usapan Bilah Tab';

  @override
  String get gestures_tabBarSurfaceDescription =>
      'Usapan pada bilah tab atau rel samping';

  @override
  String get gestures_tabViewSurfaceTitle => 'Usapan Tampilan Tab';

  @override
  String get gestures_tabViewSurfaceDescription =>
      'Usapan pada tab di daftar atau kisi tab';

  @override
  String get gestures_tabBarSwipeBackwardTitle =>
      'Usap ke kiri sepanjang bilah';

  @override
  String get gestures_tabBarSwipeBackwardDescription =>
      'Usap ke atas pada rel samping melakukan hal yang sama';

  @override
  String get gestures_tabBarSwipeForwardTitle =>
      'Usap ke kanan sepanjang bilah';

  @override
  String get gestures_tabBarSwipeForwardDescription =>
      'Usap ke bawah pada rel samping melakukan hal yang sama';

  @override
  String get gestures_tabBarSwipeOutwardTitle => 'Usap ke arah tepi layar';

  @override
  String get gestures_tabBarSwipeOutwardDescription =>
      'Ke bawah pada bilah bawah, ke atas pada bilah atas, ke samping keluar dari rel';

  @override
  String get gestures_tabBarSwipeInwardTitle => 'Usap menjauhi tepi layar';

  @override
  String get gestures_tabBarSwipeInwardDescription =>
      'Ke atas pada bilah bawah, ke bawah pada bilah atas, ke samping masuk ke halaman pada rel';

  @override
  String get gestures_tabSwipeLeftTitle => 'Usap tab ke kiri';

  @override
  String get gestures_tabSwipeLeftDescription =>
      'Berlaku untuk tab yang diusap, bukan tab yang terbuka';

  @override
  String get gestures_tabSwipeRightTitle => 'Usap tab ke kanan';

  @override
  String get gestures_tabSwipeRightDescription =>
      'Berlaku untuk tab yang diusap, bukan tab yang terbuka';

  @override
  String get gestures_startPositionAnywhere => 'Di mana saja';

  @override
  String get gestures_startPositionLeftEdge => 'Tepi kiri';

  @override
  String get gestures_startPositionRightEdge => 'Tepi kanan';

  @override
  String get gestures_startPositionTopEdge => 'Tepi atas';

  @override
  String get gestures_startPositionBottomEdge => 'Tepi bawah';

  @override
  String get gestures_startPositionLeftHalf => 'Separuh kiri';

  @override
  String get gestures_startPositionRightHalf => 'Separuh kanan';

  @override
  String get gestures_strokesSectionTitle => 'Goresan';

  @override
  String get gestures_indexMinStrokeLengthSubtitle =>
      'Panjang usapan minimum yang dikenali sebagai arah';

  @override
  String get gestures_timingSectionTitle => 'Waktu';

  @override
  String get gestures_indexTimeoutSubtitle =>
      'Batalkan goresan jika tidak ada arah baru yang digambar';

  @override
  String get gestures_indexCooldownSubtitle =>
      'Jeda minimum antara dua gestur yang dijalankan';

  @override
  String get gestures_indexStrokeIntervalSubtitle =>
      'Tolak gestur jika perubahan arah terlalu cepat';

  @override
  String get gestures_overlaySectionTitle => 'Overlay';

  @override
  String get gestures_indexSuggestAfterSubtitle =>
      'Jumlah goresan yang digambar sebelum saran muncul';

  @override
  String get intentGatekeeper_dialogTitle => 'Buka tautan di WebLibre?';

  @override
  String intentGatekeeper_appIsTryingToOpenLink(
    String appName,
    String browserName,
  ) {
    return '$appName mencoba membuka tautan di $browserName.';
  }

  @override
  String get intentGatekeeper_alwaysAllow => 'Selalu izinkan';

  @override
  String get intentGatekeeper_allowOnce => 'Izinkan sekali';

  @override
  String get intentGatekeeper_blockOnce => 'Blokir sekali';

  @override
  String get intentGatekeeper_alwaysBlock => 'Selalu blokir';

  @override
  String get keyboardShortcuts_title => 'Pintasan Keyboard';

  @override
  String get keyboardShortcuts_searchHint => 'Cari tindakan atau tombol';

  @override
  String get keyboardShortcuts_noMatchingActions =>
      'Tidak ada tindakan yang cocok.';

  @override
  String get keyboardShortcuts_overviewNoneAssigned =>
      'Tidak ada tombol yang ditetapkan untuk tindakan peramban.';

  @override
  String get keyboardShortcuts_overviewDisabled =>
      'Pintasan keyboard dinonaktifkan.';

  @override
  String get keyboardShortcuts_enableTitle => 'Aktifkan Pintasan Keyboard';

  @override
  String get keyboardShortcuts_enableSubtitle =>
      'Tindakan peramban lewat keyboard fisik, bahkan saat halaman sedang difokuskan';

  @override
  String get keyboardShortcuts_noShortcut => 'Tanpa pintasan';

  @override
  String get keyboardShortcuts_tooltipChange => 'Ubah';

  @override
  String keyboardShortcuts_tooltipRemoveChord(String chord) {
    return 'Hapus $chord';
  }

  @override
  String get keyboardShortcuts_tooltipResetToDefault => 'Atur ulang ke bawaan';

  @override
  String get keyboardShortcuts_addShortcut => 'Tambahkan pintasan';

  @override
  String get keyboardShortcuts_changeShortcutTitle => 'Ubah pintasan';

  @override
  String get keyboardShortcuts_restoreDefaultsTooltip =>
      'Pulihkan pintasan bawaan';

  @override
  String get keyboardShortcuts_restoreDefaultsTitle =>
      'Pulihkan pintasan bawaan?';

  @override
  String get keyboardShortcuts_restoreDefaultsContent =>
      'Setiap tindakan kembali ke tombol bawaan Firefox. Perubahan Anda akan hilang.';

  @override
  String keyboardShortcuts_recorderInstructions(String actionTitle) {
    return 'Tekan kombinasi tombol untuk \"$actionTitle\".';
  }

  @override
  String get keyboardShortcuts_recorderWaitingForKeys => 'Menunggu tombol…';

  @override
  String get keyboardShortcuts_recorderProblemNotAssignable =>
      'Halaman web memerlukan tombol ini. Tahan Ctrl, Alt, atau Meta bersamanya, atau gunakan tombol fungsi.';

  @override
  String get keyboardShortcuts_recorderProblemAlreadyBound =>
      'Ini sudah menjadi pintasan untuk tindakan ini.';

  @override
  String keyboardShortcuts_recorderTakesFromOther(String ownerTitle) {
    return 'Saat ini digunakan oleh \"$ownerTitle\". Menyimpan akan memindahkannya ke sini.';
  }

  @override
  String get keyboardShortcuts_actionCustomize => 'Sesuaikan';

  @override
  String get keyboardShortcuts_actionReassign => 'Tetapkan ulang';

  @override
  String get keyboardShortcuts_actionRestore => 'Pulihkan';

  @override
  String get onboarding_actionPrevious => 'Sebelumnya';

  @override
  String get onboarding_actionNext => 'Berikutnya';

  @override
  String get onboarding_actionRestore => 'Pulihkan';

  @override
  String get onboarding_restoreTargetUnreadable =>
      'Profil ini tidak dapat dibaca, jadi tidak ada yang dapat dipulihkan ke dalamnya.';

  @override
  String get onboarding_welcomeBackTitle => 'Selamat datang kembali!';

  @override
  String get onboarding_welcomeReadyTitle => 'WebLibre sudah siap';

  @override
  String get onboarding_chooseExperience => 'Pilih cara memulai:';

  @override
  String get onboarding_modeExpressTitle => 'Mulai Cepat';

  @override
  String get onboarding_modeExpressSubtitle =>
      'Gunakan pengaturan bawaan yang disarankan dan langsung menjelajah.';

  @override
  String get onboarding_modeDetailedTitle => 'Penyiapan Kustom';

  @override
  String get onboarding_modeDetailedSubtitle =>
      'Atur DNS, bilah alat, ekstensi, dan lainnya.';

  @override
  String get onboarding_modeRestoreTitle => 'Pulihkan dari Cadangan';

  @override
  String get onboarding_modeRestoreSubtitle =>
      'Impor profil dari berkas cadangan terenkripsi.';

  @override
  String get onboarding_updateNoticeTitle => 'Banyak yang telah berubah!';

  @override
  String get onboarding_updateNoticeBody =>
      'Pembaruan ini membawa perubahan besar yang mengharuskan Anda meninjau pengaturan. Silakan telusuri halaman-halaman berikut untuk memeriksa konfigurasi Anda.';

  @override
  String get onboarding_updateNoticeExtensions =>
      'Harap periksa kembali ekstensi Anda setelah pembaruan ini karena ada masalah migrasi yang diketahui.';

  @override
  String get onboarding_updateNoticeSettingsPreserved =>
      'Pengaturan Anda yang ada tidak akan ditimpa kecuali Anda sengaja mengubahnya selama penyiapan ini.';

  @override
  String get onboarding_eulaAcceptance =>
      'Saya telah membaca dan menerima <eula>EULA</eula> dan <privacy>Kebijakan Privasi</privacy>.';

  @override
  String get onboarding_privacyPolicy => 'Kebijakan Privasi';

  @override
  String get onboarding_eulaDocumentTitle =>
      'Perjanjian Lisensi Pengguna Akhir';

  @override
  String get onboarding_aiFeaturesTitle => 'Fitur AI';

  @override
  String get onboarding_aiOnDeviceTitle => 'AI di perangkat';

  @override
  String get onboarding_aiOnDeviceSubtitle =>
      'Fitur lokal di perangkat, termasuk saran topik kontainer dan tab';

  @override
  String get onboarding_aiWarningTitle => 'Hal yang perlu diperhatikan';

  @override
  String get onboarding_aiWarningPoint1 =>
      'WebLibre menggunakan model AI lokal untuk menganalisis judul tab yang terbuka dan menyarankan kontainer untuk mengelompokkan tab tersebut serta nama untuk kontainer itu. Semua pemrosesan berlangsung sepenuhnya di perangkat Anda.';

  @override
  String get onboarding_aiWarningPoint2 =>
      'Peningkatan AI bekerja sepenuhnya di dalam peramban Anda, sehingga semua data tetap berada di perangkat. Pemrosesan AI lokal menghormati privasi Anda dan memberikan saran kelompok dan nama kontainer yang lebih cepat. Anda dapat mengatur perilaku ini kapan saja di Pengaturan.';

  @override
  String get onboarding_aiWarningPoint3 =>
      'AI terkadang bisa keliru, jadi harap tinjau nama kelompok dan pilihan tab yang disarankan.';

  @override
  String get onboarding_searchTitle => 'Pencarian';

  @override
  String get onboarding_searchDefaultProviderLabel =>
      'Penyedia Pencarian Bawaan';

  @override
  String get onboarding_searchMore => 'Cari lainnya';

  @override
  String get onboarding_searchDefaultAutocompleteLabel =>
      'Penyedia Pelengkapan Otomatis Bawaan';

  @override
  String get onboarding_searchLoadFailedTitle =>
      'Tidak dapat memuat mesin pencari';

  @override
  String get onboarding_dohTitle => 'DNS over HTTPS';

  @override
  String get onboarding_permissionsTitle => 'Izin';

  @override
  String get onboarding_permissionsNotificationsTitle => 'Notifikasi';

  @override
  String get onboarding_permissionsNotificationsSubtitle =>
      'Diperlukan untuk memberi tahu Anda tentang unduhan';

  @override
  String get onboarding_permissionsDefaultBrowserTitle => 'Peramban Bawaan';

  @override
  String get onboarding_permissionsDefaultBrowserSubtitle =>
      'Jadikan WebLibre sebagai peramban bawaan Anda';

  @override
  String get onboarding_privacyTitle => 'Privasi & Pengerasan';

  @override
  String get onboarding_privacyBrowserLanguagesTitle => 'Bahasa Peramban';

  @override
  String get onboarding_privacyBrowserLanguagesSubtitle =>
      'Atur preferensi bahasa yang diperlihatkan ke situs web';

  @override
  String get onboarding_multipleLanguagesDetectedTitle =>
      'Beberapa Bahasa Terdeteksi';

  @override
  String onboarding_multipleLanguagesWarning(int count, String locales) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Peramban Anda dikonfigurasi dengan $count bahasa ($locales).',
    );
    return '$_temp0 Situs web dapat menggunakan kombinasi bahasa Anda yang unik untuk membuat sidik jari dan melacak Anda di seluruh web.';
  }

  @override
  String get onboarding_multipleLanguagesSuggestion =>
      'Pertimbangkan untuk mengurangi bahasa peramban menjadi satu bahasa saja untuk memperkecil permukaan sidik jari Anda.';

  @override
  String get onboarding_reviewLanguages => 'Tinjau Bahasa';

  @override
  String get onboarding_webEngineHardeningTitle =>
      'Pengerasan Mesin Web Lengkap';

  @override
  String get onboarding_webEngineHardeningSubtitle =>
      'Terapkan semua preferensi pengerasan keamanan yang disarankan ke mesin web';

  @override
  String get onboarding_fingerprintProtectionTitle =>
      'Perlindungan Sidik Jari yang Diperketat';

  @override
  String get onboarding_fingerprintProtectionSubtitle =>
      'Muat pengaturan bawaan perlindungan sidik jari yang menyeluruh';

  @override
  String get onboarding_compatibilityWarningTitle =>
      'Peringatan Kompatibilitas';

  @override
  String get onboarding_fingerprintWarningPoint1 =>
      'Perlindungan sidik jari yang diperketat mengaktifkan lebih dari 60 target perlindungan, termasuk pengacakan canvas, pemalsuan navigator, penyamaran perangkat media, dan lainnya.';

  @override
  String get onboarding_fingerprintWarningPoint2 =>
      'Hal ini dapat membuat situs web rusak atau berperilaku tidak terduga. Anda dapat menyesuaikan setiap target di pengaturan.';

  @override
  String get onboarding_localNetworkProtectionTitle =>
      'Perlindungan Jaringan Lokal';

  @override
  String get onboarding_localNetworkProtectionSubtitle =>
      'Situs web dapat mencoba menjangkau perangkat Anda dan perangkat lain di jaringan rumah, seperti router, printer, atau perangkat rumah pintar. Secara bawaan, pelacak yang dikenal otomatis diblokir agar tidak dapat melakukannya.';

  @override
  String get onboarding_blockAllLocalNetworkTitle =>
      'Blokir Semua Permintaan Jaringan Lokal';

  @override
  String get onboarding_blockAllLocalNetworkSubtitle =>
      'Minta izin sebelum situs web mana pun mengakses perangkat di jaringan rumah Anda, bukan hanya pelacak yang dikenal';

  @override
  String get onboarding_toolbarLayoutTitle => 'Bilah Alat & Tata Letak';

  @override
  String get onboarding_ublockTitle => 'uBlock Origin';

  @override
  String get onboarding_ublockDescription =>
      'uBlock Origin (uBO) adalah **pemblokir konten spektrum luas** yang hemat CPU dan memori buatan **Raymond Hill**, dan tersedia sebagai ekstensi peramban untuk WebLibre.\n\nSecara bawaan, uBO memblokir iklan, pelacak, penambang kripto, pop-up, anti-pemblokir yang mengganggu, situs malware, dan lainnya menggunakan **EasyList, EasyPrivacy, Peter Lowe\'s Blocklist, Online Malicious URL Blocklist, dan daftar filter uBO**.\n\nBanyak daftar lain yang tersedia untuk memblokir konten tambahan.';

  @override
  String get onboarding_ublockInstallTitle => 'Pasang Ekstensi uBlock Origin';

  @override
  String get onboarding_ublockApplyDefaultsTitle =>
      'Terapkan pengaturan bawaan yang dioptimalkan';

  @override
  String get onboarding_ublockApplyDefaultsSubtitle =>
      'Aktifkan daftar filter pengerasan WebLibre.';

  @override
  String get proxy_actionChange => 'Ubah';

  @override
  String get proxy_actionFetch => 'Ambil';

  @override
  String get proxy_actionSelectAll => 'Pilih semua';

  @override
  String get proxy_actionShare => 'Bagikan';

  @override
  String get proxy_actionStart => 'Mulai';

  @override
  String get proxy_actionStop => 'Hentikan';

  @override
  String get proxy_actionStopAndDelete => 'Hentikan dan Hapus';

  @override
  String get proxy_actionTestConnection => 'Uji koneksi';

  @override
  String get proxy_connectionsTitle => 'Koneksi Proksi';

  @override
  String get proxy_addProfile => 'Tambah Profil';

  @override
  String get proxy_viewLogsTooltip => 'Lihat log';

  @override
  String get proxy_profilesSectionTitle => 'Profil';

  @override
  String proxy_loadProfilesFailed(String error) {
    return 'Gagal memuat profil proksi:\n$error';
  }

  @override
  String get proxy_statusActive => 'Aktif';

  @override
  String get proxy_statusDisconnected => 'Terputus';

  @override
  String proxy_statusRoutingTraffic(int running, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$running dari $total proksi berjalan',
      one: '$running dari 1 proksi berjalan',
    );
    return '$_temp0';
  }

  @override
  String get proxy_statusTapToConnect => 'Ketuk profil untuk terhubung';

  @override
  String get proxy_stopAllTooltip => 'Hentikan semua';

  @override
  String get proxy_onionRoutingLabel => 'Onion routing';

  @override
  String get proxy_autostartLabel => 'Mulai otomatis';

  @override
  String get proxy_autostartTooltip => 'Dimulai bersama WebLibre';

  @override
  String proxy_egressIpTooltip(String ip) {
    return 'IP keluar $ip';
  }

  @override
  String get proxy_latencyTesting => 'Menguji...';

  @override
  String get proxy_latencyTestRunningTooltip => 'Uji latensi sedang berjalan';

  @override
  String get proxy_latencyNotRunningTooltip => 'Profil tidak sedang berjalan';

  @override
  String get proxy_latencyFailed => 'Gagal';

  @override
  String proxy_latencyMilliseconds(int ms) {
    return '$ms ms';
  }

  @override
  String proxy_latencyHttpStatusTooltip(int statusCode, int ms) {
    return 'HTTP $statusCode dalam $ms ms';
  }

  @override
  String proxy_startProxyFailed(String error) {
    return 'Gagal memulai proksi: $error';
  }

  @override
  String proxy_stopProxyFailed(String error) {
    return 'Gagal menghentikan proksi: $error';
  }

  @override
  String proxy_startBrandFailed(String brand, String error) {
    return 'Gagal memulai $brand: $error';
  }

  @override
  String proxy_stopBrandFailed(String brand, String error) {
    return 'Gagal menghentikan $brand: $error';
  }

  @override
  String get proxy_startConnectionDialogTitle => 'Mulai Koneksi Proksi?';

  @override
  String proxy_startConnectionDialogContent(String proxyTitle) {
    return 'Tab ini memerlukan $proxyTitle, tetapi koneksi tersebut tidak berjalan. Mulai sekarang?';
  }

  @override
  String get proxy_deleteProfileTitle => 'Hapus Profil?';

  @override
  String proxy_deleteProfileConfirm(String name) {
    return 'Hapus $name beserta rahasia yang tersimpan? Tab dan kontainer yang ditetapkan ke profil ini akan diblokir sampai Anda memilih proksi lain atau menghapus penetapannya.';
  }

  @override
  String proxy_deleteProfileConfirmRunning(String name) {
    return 'Hentikan $name, lalu hapus beserta rahasia yang tersimpan? Tab dan kontainer yang ditetapkan ke profil ini akan diblokir sampai Anda memilih proksi lain atau menghapus penetapannya.';
  }

  @override
  String proxy_deleteProfileFailed(String error) {
    return 'Gagal menghapus profil: $error';
  }

  @override
  String proxy_shareDialogTitle(String name) {
    return 'Bagikan \"$name\"';
  }

  @override
  String get proxy_shareDialogWarning =>
      'Tautan ini berisi profil lengkap, termasuk kredensial yang tersimpan. Bagikan dengan hati-hati.';

  @override
  String get proxy_copiedToClipboard => 'Disalin ke papan klip';

  @override
  String get proxy_editProfileTitle => 'Edit Profil';

  @override
  String get proxy_newProfileTitle => 'Profil Baru';

  @override
  String get proxy_saveChanges => 'Simpan Perubahan';

  @override
  String get proxy_createProfile => 'Buat Profil';

  @override
  String get proxy_sectionGeneral => 'Umum';

  @override
  String get proxy_sectionDnsOverride => 'DNS Kustom';

  @override
  String get proxy_addMenuTip =>
      'Tips: Gunakan menu tambah di layar sebelumnya untuk mengimpor dari berkas, menempelkan tautan berbagi, atau memindai kode QR.';

  @override
  String proxy_wireGuardTrademarkDisclaimer(String brand) {
    return '$brand adalah merek dagang terdaftar milik Jason A. Donenfeld; semua hak dilindungi undang-undang. WebLibre tidak didukung, disponsori, atau berafiliasi dengan Jason A. Donenfeld.';
  }

  @override
  String proxy_wireGuardConfigLabel(String brand) {
    return 'Konfigurasi $brand';
  }

  @override
  String get proxy_fieldProfileName => 'Nama Profil';

  @override
  String get proxy_fieldProtocol => 'Protokol';

  @override
  String get proxy_protocolFixedHelper =>
      'Protokol tidak dapat diubah setelah profil dibuat.';

  @override
  String get proxy_customOutboundLabel => 'Outbound Kustom';

  @override
  String get proxy_startAutomaticallyTitle => 'Mulai Otomatis';

  @override
  String get proxy_startAutomaticallySubtitle =>
      'Hubungkan profil ini saat WebLibre dimulai, sehingga tab yang menggunakannya langsung siap tanpa konfirmasi';

  @override
  String proxy_dnsOverrideExplanation(String brand) {
    return 'Uraikan nama domain melalui server DNS yang dapat dijangkau lewat koneksi ini (mis., server DoH internal di balik terowongan $brand perusahaan). Biarkan nonaktif untuk menggunakan penanganan DNS otomatis.';
  }

  @override
  String get proxy_dnsOverrideSwitchTitle => 'Gunakan resolver khusus profil';

  @override
  String get proxy_fieldDnsServerAddress => 'Alamat server DNS';

  @override
  String get proxy_sectionOutbound => 'Outbound';

  @override
  String get proxy_sectionSecrets => 'Rahasia';

  @override
  String get proxy_fieldOutboundJson => 'JSON Outbound';

  @override
  String get proxy_outboundJsonHelper => 'Objek outbound sing-box publik.';

  @override
  String get proxy_fieldSecretJson => 'JSON Rahasia';

  @override
  String get proxy_secretJsonHelper =>
      'Nilai opsional yang digabungkan ke outbound saat dijalankan.';

  @override
  String get proxy_sectionConnection => 'Koneksi';

  @override
  String get proxy_sectionCredentials => 'Kredensial';

  @override
  String get proxy_sectionProtocolOptions => 'Opsi Protokol';

  @override
  String get proxy_sectionTls => 'TLS';

  @override
  String get proxy_sectionTransport => 'Transport';

  @override
  String get proxy_sectionMultiplex => 'Multiplex';

  @override
  String get proxy_sectionDial => 'Dial';

  @override
  String get proxy_advancedOptionsHint =>
      'Opsi protokol lanjutan tetap dapat dimasukkan melalui JSON Outbound Kustom.';

  @override
  String get proxy_storedInSecureStorage => 'Disimpan di penyimpanan aman.';

  @override
  String get proxy_booleanFieldUnset => 'Tidak diatur (memakai bawaan)';

  @override
  String get proxy_booleanFieldEnabled => 'Aktif';

  @override
  String get proxy_booleanFieldDisabled => 'Nonaktif';

  @override
  String get proxy_addConnectionTitle => 'Tambah Koneksi';

  @override
  String get proxy_addConnectionSubtitle =>
      'Pilih cara menambahkan profil proksi.';

  @override
  String get proxy_methodClipboardTitle => 'Papan Klip';

  @override
  String get proxy_methodClipboardSubtitle => 'Tempel tautan berbagi atau URI';

  @override
  String get proxy_methodScanQrTitle => 'Pindai QR';

  @override
  String get proxy_methodScanQrSubtitle => 'Dari perangkat lain';

  @override
  String get proxy_methodSubscriptionTitle => 'Langganan';

  @override
  String get proxy_methodSubscriptionSubtitle => 'Ambil dari URL';

  @override
  String get proxy_methodImportFileTitle => 'Impor berkas';

  @override
  String get proxy_methodImportFileSubtitle => '.conf atau sing-box JSON';

  @override
  String get proxy_enterManually => 'Masukkan secara manual';

  @override
  String get proxy_clipboardEmpty => 'Papan klip kosong.';

  @override
  String get proxy_importFromFileTitle => 'Impor dari berkas';

  @override
  String get proxy_importFileWireGuardSubtitle =>
      'Berkas .conf dengan [Interface]/[Peer]';

  @override
  String get proxy_importFileSingboxJsonTitle => 'JSON outbound sing-box';

  @override
  String get proxy_importFileSingboxJsonSubtitle =>
      'Shadowsocks, Trojan, VMess, VLESS, Hysteria, …';

  @override
  String proxy_importedProfileNamed(String name) {
    return 'Profil \"$name\" diimpor';
  }

  @override
  String get proxy_importSubscriptionTitle => 'Impor Langganan';

  @override
  String get proxy_fieldSubscriptionUrl => 'URL Langganan';

  @override
  String get proxy_subscriptionUrlRequired =>
      'Masukkan URL langganan https:// yang lengkap.';

  @override
  String proxy_subscriptionHttpError(int statusCode) {
    return 'Server langganan merespons dengan HTTP $statusCode.';
  }

  @override
  String get proxy_subscriptionTimedOut =>
      'Server langganan tidak merespons tepat waktu.';

  @override
  String proxy_subscriptionFetchFailed(String error) {
    return 'Tidak dapat mengambil langganan: $error';
  }

  @override
  String get proxy_subscriptionFormatHint =>
      'Mendukung format gaya v2rayN: daftar URI ss://, vless://, vmess://, trojan://, hysteria2://, tuic://, dan sejenisnya yang dienkode base64. Aturan perutean dari langganan diabaikan — hanya node proksi yang diimpor.';

  @override
  String proxy_importedProfileDefaultName(int n) {
    return 'Impor $n';
  }

  @override
  String proxy_importedProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profil diimpor',
      one: '1 profil diimpor',
    );
    return '$_temp0';
  }

  @override
  String proxy_importProfilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impor $count profil',
      one: 'Impor 1 profil',
    );
    return '$_temp0';
  }

  @override
  String proxy_subscriptionNodeSummary(int usable, int failed) {
    String _temp0 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable node dapat digunakan, $failed gagal',
      one: '1 node dapat digunakan, $failed gagal',
    );
    String _temp1 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable node dapat digunakan, 1 gagal',
      one: '1 node dapat digunakan, 1 gagal',
    );
    String _temp2 = intl.Intl.pluralLogic(
      usable,
      locale: localeName,
      other: '$usable node dapat digunakan',
      one: '1 node dapat digunakan',
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
  String get proxy_logsTitle => 'Log Proksi';

  @override
  String get proxy_logsCopyAllTooltip => 'Salin semua';

  @override
  String get proxy_logsClearTooltip => 'Bersihkan log';

  @override
  String get proxy_logsShareSubject => 'log proksi';

  @override
  String get proxy_logsNoLinesMatchFilter =>
      'Tidak ada baris log yang cocok dengan filter saat ini';

  @override
  String proxy_logsCopiedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baris disalin ke papan klip',
      one: '1 baris disalin ke papan klip',
    );
    return '$_temp0';
  }

  @override
  String get proxy_logsShowAllLevels => 'Tampilkan semua level';

  @override
  String get proxy_logsShowErrorsOnly => 'Tampilkan galat saja';

  @override
  String get proxy_logsShowWarningsAndAbove =>
      'Tampilkan peringatan dan di atasnya';

  @override
  String get proxy_logsShowInfoAndAbove => 'Tampilkan info dan di atasnya';

  @override
  String get proxy_logsShowDebugAndAbove => 'Tampilkan debug dan di atasnya';

  @override
  String get proxy_logsShowTraceAndAbove => 'Tampilkan trace dan di atasnya';

  @override
  String get proxy_logsLatest => 'Terbaru';

  @override
  String get proxy_logsEmptyFiltered =>
      'Tidak ada baris log pada level ini. Turunkan filter tampilan atau naikkan level log proksi.';

  @override
  String proxy_logsEmpty(String brand) {
    return 'Belum ada baris log. Mulai proksi atau $brand untuk melihat keluarannya di sini.';
  }

  @override
  String get proxy_recordingLevelWarn => 'Mencatat peringatan dan galat';

  @override
  String get proxy_recordingLevelInfo =>
      'Mencatat info — ini memperlambat penjelajahan';

  @override
  String get proxy_recordingLevelDebug =>
      'Mencatat debug — ini memperlambat penjelajahan';

  @override
  String get proxy_recordingLevelTrace =>
      'Mencatat trace — ini memperlambat penjelajahan';

  @override
  String get proxy_logLevelAll => 'Semua';

  @override
  String get proxy_logLevelTrace => 'Trace';

  @override
  String get proxy_logLevelDebug => 'Debug';

  @override
  String get proxy_logLevelInfo => 'Info';

  @override
  String get proxy_logLevelWarnings => 'Peringatan';

  @override
  String get proxy_logLevelErrors => 'Galat';

  @override
  String get proxy_logLevelSheetTitle => 'Level log proksi';

  @override
  String get proxy_logLevelSheetExplanation =>
      'Naikkan hanya saat mendiagnosis masalah, lalu kembalikan. Mengubahnya akan memulai ulang proksi yang sedang berjalan.';

  @override
  String get proxy_verboseLoggingWarning =>
      'Log terperinci menulis satu baris untuk setiap koneksi dan pencarian DNS, yang memperlambat penjelajahan secara nyata.';

  @override
  String get proxy_logVerbosityWarnLabel => 'Peringatan dan galat';

  @override
  String get proxy_logVerbosityInfoLabel => 'Info';

  @override
  String get proxy_logVerbosityDebugLabel => 'Debug';

  @override
  String get proxy_logVerbosityTraceLabel => 'Trace';

  @override
  String get proxy_logVerbosityWarnDescription =>
      'Operasi normal. Masalah tetap dicatat.';

  @override
  String get proxy_logVerbosityInfoDescription =>
      'Setiap koneksi dan pencarian DNS. Memperlambat penjelajahan.';

  @override
  String get proxy_logVerbosityDebugDescription =>
      'Info ditambah detail protokol. Memperlambat penjelajahan.';

  @override
  String get proxy_logVerbosityTraceDescription =>
      'Semua yang dapat dilaporkan sing-box. Sangat memperlambat penjelajahan.';

  @override
  String get proxy_loadingProxyTitle => 'Memuat proksi...';

  @override
  String proxy_torConnectionSubtitle(String torBrand) {
    return 'Rutekan melalui jaringan $torBrand';
  }

  @override
  String get proxy_routingTitle => 'Perutean Proksi';

  @override
  String get proxy_routingSubtitle =>
      'Pilih proksi yang membawa lalu lintas tab biasa dan tab pribadi.';

  @override
  String get proxy_routingSectionRegularTabs => 'Tab Biasa';

  @override
  String get proxy_routingSectionRegularTabsKeywords => 'perutean, routing';

  @override
  String get proxy_routingSectionPrivateTabs => 'Tab Pribadi';

  @override
  String get proxy_routingSectionPrivateTabsKeywords =>
      'pribadi, penyamaran, private, incognito';

  @override
  String get proxy_routingRegularTabsModeTitle => 'Mode Perutean Tab Biasa';

  @override
  String get proxy_routingRegularTabsModeKeywords =>
      'kontainer, global, container';

  @override
  String get proxy_routingRegularTabsModeSubtitle =>
      'Pilih cara tab biasa dirutekan melalui proksi';

  @override
  String get proxy_routingGlobalProxyTitle => 'Proksi untuk perutean global';

  @override
  String get proxy_routingGlobalProxyKeywords => 'proksi, proxy';

  @override
  String get proxy_routingGlobalProxySubtitle =>
      'Proksi yang dipilih saat perutean global diaktifkan';

  @override
  String get proxy_routingPrivateTabsProxyTitle => 'Proksi untuk tab pribadi';

  @override
  String get proxy_routingPrivateTabsProxyKeywords => 'proksi, proxy';

  @override
  String get proxy_routingPrivateTabsProxySubtitle =>
      'Proksi yang dipilih untuk membawa lalu lintas tab pribadi';

  @override
  String get proxy_routingContainerBasedTitle => 'Perutean Berbasis Kontainer';

  @override
  String get proxy_routingContainerBasedSubtitle =>
      'Hanya tab di kontainer yang ditetapkan ke proksi yang dirutekan.';

  @override
  String get proxy_routingGlobalRoutingTitle => 'Perutean Global';

  @override
  String get proxy_routingGlobalRoutingSubtitle =>
      'Rutekan tab biasa melalui proksi yang dipilih kecuali kontainer melewatinya.';

  @override
  String get proxy_routingNotUsedTitle =>
      'Tidak digunakan dalam perutean berbasis kontainer';

  @override
  String get proxy_routingNotUsedSubtitle =>
      'Beralih ke perutean global di atas untuk memilih proksi yang membawa setiap tab biasa.';

  @override
  String get proxy_routingNoneTitle => 'Tidak ada';

  @override
  String get proxy_routingNoneSubtitle => 'Gunakan koneksi peramban biasa';

  @override
  String get proxy_routingUnknownProxySubtitle =>
      'Proksi yang dipilih sudah tidak ada.';

  @override
  String get proxy_unknownProxyTitle => 'Proksi tidak dikenal';

  @override
  String get proxy_connectionPickerTitle => 'Koneksi Proksi';

  @override
  String get proxy_pickerUnknownProxySubtitle =>
      'Profil proksi ini sudah tidak ada';

  @override
  String get proxy_fieldServerAddress => 'Alamat Server';

  @override
  String get proxy_fieldServerPort => 'Port Server';

  @override
  String get proxy_fieldUsername => 'Nama Pengguna';

  @override
  String get proxy_fieldPassword => 'Kata Sandi';

  @override
  String get proxy_fieldUuid => 'UUID';

  @override
  String get proxy_fieldTlsEnabled => 'TLS Aktif';

  @override
  String get proxy_fieldTlsEnabledHelper => 'true atau false.';

  @override
  String get proxy_fieldTlsServerName => 'Nama Server TLS';

  @override
  String get proxy_fieldTlsInsecure => 'Izinkan Sertifikat TLS Tidak Valid';

  @override
  String get proxy_fieldTlsInsecureHelper => 'true atau false.';

  @override
  String get proxy_fieldTlsAlpn => 'TLS ALPN';

  @override
  String get proxy_fieldTlsAlpnHelper =>
      'Dipisahkan koma atau satu nilai per baris.';

  @override
  String get proxy_fieldTransportType => 'Jenis Transport';

  @override
  String get proxy_fieldTransportTypeHelper =>
      'Misalnya ws, http, grpc, atau quic.';

  @override
  String get proxy_fieldTransportPath => 'Jalur Transport';

  @override
  String get proxy_fieldGrpcServiceName => 'Nama Layanan gRPC';

  @override
  String get proxy_fieldMultiplexEnabled => 'Multiplex Aktif';

  @override
  String get proxy_fieldMultiplexEnabledHelper => 'true atau false.';

  @override
  String get proxy_fieldMultiplexProtocol => 'Protokol Multiplex';

  @override
  String get proxy_fieldMultiplexMaxConnections => 'Maks. Koneksi Multiplex';

  @override
  String get proxy_fieldDialDetour => 'Dial Detour';

  @override
  String get proxy_fieldBindInterface => 'Bind Interface';

  @override
  String get proxy_fieldRoutingMark => 'Routing Mark';

  @override
  String get proxy_fieldDomainStrategy => 'Strategi Domain';

  @override
  String get proxy_fieldDomainStrategyHelper =>
      'Misalnya prefer_ipv4 atau prefer_ipv6.';

  @override
  String get proxy_fieldConnectTimeout => 'Batas Waktu Koneksi';

  @override
  String get proxy_fieldConnectTimeoutHelper => 'Misalnya 5s.';

  @override
  String get proxy_fieldSocksVersion => 'Versi SOCKS';

  @override
  String get proxy_fieldMethod => 'Metode';

  @override
  String get proxy_fieldSecurity => 'Keamanan';

  @override
  String get proxy_fieldAlterId => 'Alter ID';

  @override
  String get proxy_fieldFlow => 'Flow';

  @override
  String get proxy_fieldAuthString => 'String Autentikasi';

  @override
  String get proxy_fieldUploadBandwidth => 'Bandwidth Unggah';

  @override
  String get proxy_fieldDownloadBandwidth => 'Bandwidth Unduh';

  @override
  String get proxy_fieldObfuscation => 'Obfuskasi';

  @override
  String get proxy_fieldReceiveWindowConn => 'Receive Window Conn';

  @override
  String get proxy_fieldReceiveWindow => 'Receive Window';

  @override
  String get proxy_fieldDisableMtuDiscovery => 'Nonaktifkan MTU Discovery';

  @override
  String get proxy_fieldDisableMtuDiscoveryHelper => 'true atau false.';

  @override
  String get proxy_fieldUploadMbps => 'Unggah Mbps';

  @override
  String get proxy_fieldDownloadMbps => 'Unduh Mbps';

  @override
  String get proxy_fieldObfuscationType => 'Jenis Obfuskasi';

  @override
  String get proxy_fieldObfuscationPassword => 'Kata Sandi Obfuskasi';

  @override
  String get proxy_fieldCongestionControl => 'Kontrol Kongesti';

  @override
  String get proxy_fieldUdpRelayMode => 'Mode UDP Relay';

  @override
  String get proxy_fieldZeroRttHandshake => 'Handshake Zero RTT';

  @override
  String get proxy_fieldZeroRttHandshakeHelper => 'true atau false.';

  @override
  String get proxy_fieldUser => 'Pengguna';

  @override
  String get proxy_fieldPrivateKey => 'Kunci Privat';

  @override
  String get proxy_fieldPrivateKeyPassphrase => 'Frasa Sandi Kunci Privat';

  @override
  String get proxy_fieldLocalAddress => 'Alamat Lokal';

  @override
  String get proxy_fieldLocalAddressHelper =>
      'Alamat perangkat ini di dalam terowongan, satu per baris — misalnya, 10.0.0.2/32. Alamat tanpa prefiks diperlakukan sebagai satu alamat (/32, atau /128 untuk IPv6).';

  @override
  String get proxy_fieldPeerPublicKey => 'Kunci Publik Peer';

  @override
  String get proxy_fieldWireguardPrivateKey => 'Kunci Privat';

  @override
  String get proxy_fieldWireguardPrivateKeyHelper =>
      'Disimpan di penyimpanan aman, bukan di JSON profil.';

  @override
  String get proxy_fieldPreSharedKey => 'Pre-shared Key';

  @override
  String get proxy_fieldPreSharedKeyHelper =>
      'Opsional. Disimpan di penyimpanan aman.';

  @override
  String get proxy_fieldMtu => 'MTU';

  @override
  String get proxy_fieldMtuHelper =>
      'Turunkan nilai ini jika terowongan terhubung tetapi halaman tidak kunjung dimuat: paket yang melebihi batas ukuran pada jalur akan langsung dibuang. Nilai 1280 aman hampir di mana saja; gunakan sekitar 1200 jika sudah terhubung ke VPN lain.';

  @override
  String get proxy_fieldPersistentKeepalive => 'Persistent Keepalive';

  @override
  String get proxy_fieldPersistentKeepaliveHelper =>
      'Detik di antara paket keepalive. Ponsel sering berada di balik NAT; tanpa keepalive, pemetaannya dapat kedaluwarsa saat tidak aktif. Peer lalu tidak dapat menjangkau ponsel, sehingga koneksi macet hingga handshake berikutnya. Atur ke 0 untuk menonaktifkan.';

  @override
  String get proxy_fieldReservedBytes => 'Byte Cadangan';

  @override
  String get proxy_fieldReservedBytesHelper =>
      'Opsional. Tiga angka dipisahkan koma, mis. 0,0,0.';

  @override
  String get proxy_fieldShadowTlsVersion => 'Versi';

  @override
  String proxy_fieldErrorRequired(String field) {
    return '\"$field\" wajib diisi.';
  }

  @override
  String proxy_fieldErrorNotPositiveNumber(String field) {
    return '\"$field\" harus berupa angka positif.';
  }

  @override
  String proxy_fieldErrorPortRange(String field) {
    return '\"$field\" harus antara 1 dan 65535.';
  }

  @override
  String proxy_fieldErrorListLength(String field, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '\"$field\" harus berisi $count angka.',
      one: '\"$field\" harus berisi 1 angka.',
    );
    return '$_temp0';
  }

  @override
  String proxy_fieldErrorNotAllNumbers(String field) {
    return '\"$field\" hanya boleh berisi angka.';
  }

  @override
  String proxy_fieldErrorBelowMin(String field, int min) {
    return '\"$field\" harus berisi angka yang lebih besar dari atau sama dengan $min.';
  }

  @override
  String proxy_fieldErrorAboveMax(String field, int max) {
    return '\"$field\" harus berisi angka yang lebih kecil dari atau sama dengan $max.';
  }

  @override
  String proxy_fieldErrorInvalidCidr(String field, String value) {
    return '\"$field\" harus berisi alamat IP, opsional dengan /prefiks — \"$value\" tidak valid.';
  }

  @override
  String proxy_fieldErrorNotBoolean(String field) {
    return '\"$field\" harus true atau false.';
  }

  @override
  String proxy_fieldErrorNotAllowedValue(String field, String values) {
    return '\"$field\" harus salah satu dari: $values.';
  }

  @override
  String get proxy_saveErrorAlreadySaving => 'Profil sedang disimpan.';

  @override
  String get proxy_saveErrorNameRequired => 'Nama profil wajib diisi.';

  @override
  String get proxy_saveErrorStillLoading =>
      'Profil masih dimuat. Harap tunggu.';

  @override
  String get proxy_saveErrorConfigNotJson =>
      'Konfigurasi harus berupa objek JSON.';

  @override
  String get proxy_saveErrorSecretsNotJson =>
      'Rahasia harus berupa objek JSON.';

  @override
  String proxy_saveErrorUnexpected(String error) {
    return 'Gagal menyimpan profil proksi: $error';
  }

  @override
  String get proxy_loadErrorNotFound => 'Profil proksi tidak ditemukan.';

  @override
  String proxy_loadErrorFailed(String error) {
    return 'Gagal memuat profil proksi: $error';
  }

  @override
  String get qrScanner_noCameraPermission => 'Izin kamera belum diberikan.';

  @override
  String get qrScanner_scanCodeTitle => 'Pindai kode';

  @override
  String get searchCredits_couldNotLoadTitle => 'Tidak dapat memuat kredit';

  @override
  String get searchCredits_title => 'Kredit pencarian';

  @override
  String get searchCredits_errorSubtitle =>
      'Periksa koneksi Anda, lalu ketuk segarkan untuk mencoba lagi.';

  @override
  String get searchCredits_emptySubtitle =>
      'Beli paket pencarian untuk memulai';

  @override
  String searchCredits_creditsWithAllowance(
    int credits,
    int allowance,
    int stash,
  ) {
    return 'Kredit: $credits / $allowance  ·  Token tersimpan: $stash';
  }

  @override
  String searchCredits_creditsNoAllowance(int credits, int stash) {
    return 'Kredit: $credits  ·  Token tersimpan: $stash';
  }

  @override
  String get searchCredits_tooltipRefresh => 'Segarkan';

  @override
  String searchCredits_resetsOn(String date) {
    return 'Diatur ulang pada $date';
  }

  @override
  String searchCredits_lastIssuance(String relative, String absolute) {
    return 'Penerbitan terakhir: $relative  ($absolute)';
  }

  @override
  String get searchCredits_requestingTokens => 'Meminta token...';

  @override
  String searchCredits_issuanceFailed(String error) {
    return 'Penerbitan token gagal: $error';
  }

  @override
  String get searchCredits_needsReauth =>
      'Silakan masuk kembali untuk meminta token.';

  @override
  String get searchCredits_buySearchPackTitle => 'Beli paket pencarian';

  @override
  String get searchCredits_getTokensTitle => 'Dapatkan token';

  @override
  String searchCredits_requestTokensCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minta $count token',
      one: 'Minta 1 token',
    );
    return '$_temp0';
  }

  @override
  String get searchCredits_noCreditsRemaining => 'Kredit sudah habis';

  @override
  String get searchCredits_buyMoreTitle => 'Beli lagi';

  @override
  String get settings_advancedTitle => 'Lanjutan';

  @override
  String get settings_advancedSubtitle =>
      'Perilaku mesin, penyesuaian saat aplikasi berjalan, dan alat pengembang.';

  @override
  String get settings_javascriptTitle => 'Aktifkan JavaScript';

  @override
  String get settings_javascriptKeywords => 'javascript, js, skrip';

  @override
  String get settings_javascriptSubtitle =>
      'Menonaktifkan JavaScript dapat meningkatkan keamanan, privasi, dan kecepatan, tetapi dapat membuat beberapa situs tidak berfungsi sebagaimana mestinya.';

  @override
  String get settings_userAgentLabel => 'User Agent Kustom';

  @override
  String get settings_userAgentLabelKeywords => 'ua, user agent, agen pengguna';

  @override
  String get settings_enterpriseRootsTitle =>
      'Gunakan sertifikat CA pihak ketiga';

  @override
  String get settings_enterpriseRootsKeywords =>
      'sertifikat, enterprise roots, ca, certificates';

  @override
  String get settings_enterpriseRootsSubtitle =>
      'Mengizinkan penggunaan sertifikat pihak ketiga dari penyimpanan CA Android';

  @override
  String get settings_experimentalFeaturesTitle => 'Fitur Eksperimental';

  @override
  String get settings_experimentalFeaturesKeywords =>
      'runtime, startup, saat mulai';

  @override
  String get settings_experimentalFeaturesSubtitle =>
      'Fitur runtime tingkat rendah dan perilaku saat memulai';

  @override
  String get settings_unmountGeckoViewTitle =>
      'Lepas Mesin Saat Tidak Terlihat';

  @override
  String get settings_unmountGeckoViewKeywords =>
      'geckoview, memori, kinerja, tangguhkan, memory, performance';

  @override
  String get settings_unmountGeckoViewSubtitle =>
      'Lepaskan mesin web dari memori saat tampilan layar penuh (seperti pengaturan, tab, atau pencarian) terbuka, lalu bangun ulang saat Anda kembali. Ini membebaskan sumber daya selama itu. Kembali ke halaman memerlukan pemasangan ulang mesin dan dapat menyebabkan kedipan atau pemuatan ulang, jadi ini mengorbankan kinerja demi menghemat memori, bukan memperbaiki masalah. Di Android 12 dan versi sebelumnya, mesin selalu dilepas.';

  @override
  String get settings_iconCacheTitle => 'Cache Ikon';

  @override
  String get settings_iconCacheKeywords => 'favicon, cache, ikon';

  @override
  String get settings_iconCacheSubtitle => 'Favicon yang tersimpan';

  @override
  String get settings_iconCacheSizeLabel => 'Ukuran';

  @override
  String get settings_clearingAction => 'Menghapus';

  @override
  String get settings_mlDownloadsTitle => 'Unduhan ML';

  @override
  String get settings_mlDownloadsKeywords => 'ai, ml, model, onnx, cache';

  @override
  String get settings_mlDownloadsSubtitle =>
      'Model AI dan berkas runtime yang diunduh';

  @override
  String get settings_mlDownloadsClearDialogTitle => 'Hapus unduhan ML?';

  @override
  String get settings_mlDownloadsClearDialogContent =>
      'Ini menghapus model AI dan berkas runtime ONNX yang diunduh untuk profil ini. Berkas tersebut akan diunduh lagi saat diperlukan. Mulai ulang WebLibre sebelum mencoba fitur ML lagi.';

  @override
  String get settings_mlDownloadsClearedMessage =>
      'Unduhan ML dihapus. Mulai ulang WebLibre sebelum mencoba lagi.';

  @override
  String settings_mlDownloadsClearFailedMessage(String error) {
    return 'Gagal menghapus unduhan ML: $error';
  }

  @override
  String get settings_errorLogsTitle => 'Log Galat';

  @override
  String get settings_errorLogsKeywords => 'log, galat, logs';

  @override
  String get settings_errorLogsSubtitle =>
      'Lihat dan salin log untuk melaporkan masalah';

  @override
  String get settings_dartVmTitle => 'Dart VM';

  @override
  String get settings_dartVmKeywords => 'service url, url layanan';

  @override
  String get settings_dartVmSubtitle => 'Salin URL layanan Dart VM';

  @override
  String get settings_dartVmCopyErrorFallback => 'Galat';

  @override
  String get settings_serviceUrlCopiedMessage => 'URL layanan disalin';

  @override
  String get settings_resetUiTitle => 'Atur Ulang UI';

  @override
  String get settings_resetUiKeywords => 'segarkan ui, refresh ui, antarmuka';

  @override
  String get settings_resetUiSubtitle => 'Bangun ulang seluruh UI peramban';

  @override
  String get settings_addonCollectionTitle => 'Koleksi Ekstensi Kustom';

  @override
  String get settings_addonCollectionSourceSectionTitle => 'Sumber Koleksi';

  @override
  String get settings_addonCollectionConfigTitle => 'Konfigurasi koleksi';

  @override
  String get settings_addonCollectionConfigKeywords =>
      'pengaya, koleksi, addons, collection';

  @override
  String get settings_addonCollectionConfigSubtitle =>
      'Server Mozilla, pemilik koleksi, dan nama koleksi';

  @override
  String get settings_addonCollectionServerUrlLabel => 'URL Server';

  @override
  String get settings_addonCollectionUserLabel => 'Pengguna Koleksi';

  @override
  String get settings_addonCollectionNameLabel => 'Nama Koleksi';

  @override
  String get settings_addonCollectionActionsSectionTitle => 'Tindakan';

  @override
  String get settings_addonCollectionSaveRestartTitle =>
      'Simpan & Mulai Ulang Peramban';

  @override
  String get settings_addonCollectionSaveRestartKeywords =>
      'mulai ulang, restart';

  @override
  String get settings_addonCollectionSaveRestartSubtitle =>
      'Terapkan koleksi kustom dan mulai ulang peramban';

  @override
  String get settings_bangSettingsTitle => 'Pengaturan Bang';

  @override
  String get settings_bangSettingsKeywords =>
      'pintasan, bang, shortcuts, bangs';

  @override
  String get settings_bangSettingsSubtitle =>
      'Penggunaan pintasan bang, repositori, dan sinkronisasi sesuai permintaan.';

  @override
  String get settings_bangFrequenciesTitle => 'Frekuensi Bang';

  @override
  String get settings_bangFrequenciesKeywords =>
      'penggunaan, rekomendasi, usage, recommendations';

  @override
  String get settings_bangFrequenciesSubtitle =>
      'Penggunaan yang dicatat untuk rekomendasi bang';

  @override
  String get settings_browsingTitle => 'Penjelajahan';

  @override
  String get settings_browsingSubtitle =>
      'Perilaku tab, navigasi, tautan aplikasi, dan Small Web.';

  @override
  String get settings_newTabDefaultTitle => 'Jenis Tab Baru Bawaan';

  @override
  String get settings_newTabDefaultKeywords =>
      'biasa, pribadi, terisolasi, regular, private, isolated';

  @override
  String get settings_newTabDefaultSubtitle =>
      'Pilih jenis bawaan untuk tab yang dibuat secara manual';

  @override
  String get settings_tabTypeRegularLabel => 'Biasa';

  @override
  String get settings_tabTypePrivateLabel => 'Pribadi';

  @override
  String get settings_tabTypeIsolatedLabel => 'Terisolasi';

  @override
  String get settings_smallWebTabDefaultTitle => 'Jenis Tab Small Web Bawaan';

  @override
  String get settings_smallWebTabDefaultKeywords =>
      'biasa, pribadi, terisolasi, regular, private, isolated';

  @override
  String get settings_smallWebTabDefaultSubtitle =>
      'Pilih jenis tab yang digunakan saat memasuki Small Web';

  @override
  String get settings_externalLinkHandlingTitle =>
      'Penanganan Tautan Eksternal';

  @override
  String get settings_externalLinkHandlingKeywords =>
      'intent, tautan eksternal, intents';

  @override
  String get settings_externalLinkHandlingSubtitle =>
      'Pilih cara tautan eksternal dibuka di WebLibre';

  @override
  String get settings_promptOptionLabel => 'Tanya';

  @override
  String get settings_externalLinkPromptSubtitle =>
      'Tanyakan cara membuka tautan eksternal';

  @override
  String get settings_externalLinkRegularSubtitle =>
      'Buka tautan eksternal di tab biasa';

  @override
  String get settings_externalLinkPrivateSubtitle =>
      'Buka tautan eksternal di tab pribadi';

  @override
  String get settings_externalLinkIsolatedSubtitle =>
      'Buka tautan eksternal di tab terisolasi';

  @override
  String get settings_bookmarkOpenBehaviorTitle => 'Perilaku Membuka Markah';

  @override
  String get settings_bookmarkOpenBehaviorKeywords =>
      'markah, buka, tab kustom, terisolasi, bookmarks, custom tab';

  @override
  String get settings_bookmarkOpenBehaviorSubtitle =>
      'Pilih cara markah dibuka saat diketuk';

  @override
  String get settings_bookmarkOpenPromptSubtitle =>
      'Tanyakan cara membuka markah';

  @override
  String get settings_bookmarkOpenRegularSubtitle => 'Buka markah di tab biasa';

  @override
  String get settings_bookmarkOpenPrivateSubtitle =>
      'Buka markah di tab pribadi';

  @override
  String get settings_customTabOptionLabel => 'Tab Kustom';

  @override
  String get settings_bookmarkOpenCustomTabSubtitle =>
      'Buka markah di tab kustom yang ringan';

  @override
  String get settings_bookmarkOpenIsolatedSubtitle =>
      'Buka markah di tab terisolasi';

  @override
  String get settings_tabListDirectionTitle => 'Arah Daftar Tab';

  @override
  String get settings_tabListDirectionKeywords =>
      'pengurutan, urutan, sorting, order';

  @override
  String get settings_tabListDirectionSubtitle =>
      'Pilih apakah tab terbaru muncul di bagian atas atau bawah daftar tab';

  @override
  String get settings_directionNewestFirstLabel => 'Terbaru dahulu';

  @override
  String get settings_directionOldestFirstLabel => 'Terlama dahulu';

  @override
  String get settings_tabBarDirectionTitle => 'Arah Bilah Tab';

  @override
  String get settings_tabBarDirectionKeywords =>
      'pengurutan, urutan, sorting, order';

  @override
  String get settings_tabBarDirectionSubtitle =>
      'Pilih apakah tab terbaru muncul di sebelah kiri atau kanan pengalih cepat';

  @override
  String get settings_childTabPlacementTitle => 'Posisi Tab Anak Baru';

  @override
  String get settings_childTabPlacementKeywords =>
      'tab anak, tab baru, posisi, urutan, akhir daftar, setelah induk, child tabs';

  @override
  String get settings_childTabPlacementSubtitle =>
      'Pilih apakah tab yang dibuka dari tab lain ditempatkan setelah tab pembukanya atau di akhir. Tab pembuka tetap diingat dalam kedua pilihan, sehingga tampilan pohon tidak terpengaruh.';

  @override
  String get settings_childTabAfterOpenerLabel => 'Setelah pembuka';

  @override
  String get settings_childTabAtEndLabel => 'Di akhir';

  @override
  String get settings_createChildTabsTitle => 'Buat Tab Anak';

  @override
  String get settings_createChildTabsKeywords => 'tab anak, child tabs';

  @override
  String get settings_createChildTabsSubtitle =>
      'Tampilkan tombol untuk membuat tab anak di bawah tab saat ini (hanya tampilan pohon)';

  @override
  String get settings_showContainerUiTitle => 'Tampilkan UI Kontainer';

  @override
  String get settings_showContainerUiKeywords => 'kontainer, containers';

  @override
  String get settings_showContainerUiSubtitle =>
      'Tampilkan pemilih, menu, dan pengelolaan kontainer';

  @override
  String get settings_showIsolatedTabUiTitle => 'Tampilkan UI Tab Terisolasi';

  @override
  String get settings_showIsolatedTabUiKeywords =>
      'tab terisolasi, isolated tabs';

  @override
  String get settings_showIsolatedTabUiSubtitle =>
      'Tampilkan opsi pembuatan tab terisolasi di UI';

  @override
  String get settings_backgroundTabBehaviorTitle =>
      'Perilaku Tab Latar Belakang';

  @override
  String get settings_backgroundTabBehaviorKeywords =>
      'beralih, latar belakang, tab baru, snackbar, tanya, switch, background';

  @override
  String get settings_backgroundTabBehaviorSubtitle =>
      'Berlaku saat suatu tindakan membuka tab baru di latar belakang, mis. \"Buka di tab baru\" atau menduplikat tab';

  @override
  String get settings_backgroundTabPromptTitle => 'Tetap dan Tawarkan Beralih';

  @override
  String get settings_backgroundTabPromptSubtitle =>
      'Tetap di tab saat ini dan tampilkan pemberitahuan dengan tindakan Beralih';

  @override
  String get settings_backgroundTabSwitchTitle => 'Langsung Beralih';

  @override
  String get settings_backgroundTabSwitchSubtitle =>
      'Langsung pindah ke tab yang baru dibuka';

  @override
  String get settings_tabBarSwipesTitle => 'Usapan Bilah Tab';

  @override
  String get settings_tabBarSwipesKeywords =>
      'gestur, usap, perilaku usapan bilah tab, gestures, swipe';

  @override
  String get settings_tabBarSwipesSubtitle =>
      'Pilih fungsi setiap usapan di Gestur';

  @override
  String get settings_sequentialTabNavigationTitle => 'Navigasi Tab Berurutan';

  @override
  String get settings_sequentialTabNavigationKeywords =>
      'gestur, usap, tab berikutnya, tab sebelumnya, kontainer, berputar, gestures, swipe, loop';

  @override
  String get settings_sequentialTabNavigationSubtitle =>
      'Berlaku untuk usapan bilah tab dan gestur tab berikutnya/sebelumnya';

  @override
  String get settings_continueIntoNextContainerTitle =>
      'Lanjut ke Kontainer Berikutnya';

  @override
  String get settings_continueIntoNextContainerSubtitle =>
      'Melewati tab pertama atau terakhir suatu kontainer akan pindah ke kontainer di sebelahnya. Jika nonaktif, navigasi tetap di dalam kontainer saat ini.';

  @override
  String get settings_loopAroundTitle => 'Berputar';

  @override
  String get settings_loopAroundSubtitle =>
      'Melewati tab terakhir akan berlanjut ke tab pertama, dan sebaliknya.';

  @override
  String get settings_openLinksInAppsTitle => 'Buka Tautan di Aplikasi';

  @override
  String get settings_openLinksInAppsKeywords =>
      'tautan aplikasi, aplikasi eksternal, app links';

  @override
  String get settings_openLinksInAppsSubtitle =>
      'Pilih cara menangani tautan yang dapat dibuka di aplikasi lain';

  @override
  String get settings_appLinksAlwaysTitle => 'Selalu';

  @override
  String get settings_appLinksAlwaysSubtitle =>
      'Selalu buka tautan di aplikasi terkait tanpa bertanya';

  @override
  String get settings_appLinksAskTitle => 'Tanya sebelum membuka';

  @override
  String get settings_appLinksAskSubtitle =>
      'Tampilkan konfirmasi sebelum membuka tautan di aplikasi';

  @override
  String get settings_appLinksNeverTitle => 'Jangan pernah';

  @override
  String get settings_appLinksNeverSubtitle =>
      'Selalu buka tautan di peramban, bukan di aplikasi';

  @override
  String get settings_waitForAnswerTitle => 'Tunggu jawaban Anda';

  @override
  String get settings_waitForAnswerSubtitle =>
      'Tahan halaman selama bertanya, alih-alih memuatnya di latar belakang. Situs tidak dihubungi kecuali Anda memilih tetap di peramban.';

  @override
  String get settings_offerAppStoreFallbackTitle =>
      'Tawarkan toko aplikasi sebagai alternatif';

  @override
  String get settings_offerAppStoreFallbackSubtitle =>
      'Jika tautan mengarah ke aplikasi yang tidak terpasang dan tidak ada alternatif web, tawarkan untuk membuka toko aplikasi';

  @override
  String get settings_allowLoginAppCallbacksTitle =>
      'Izinkan callback masuk aplikasi';

  @override
  String get settings_allowLoginAppCallbacksSubtitle =>
      'Izinkan aplikasi yang membuka Tab Kustom menerima callback masuknya, bahkan jika tautan diatur untuk tidak pernah dibuka di aplikasi';

  @override
  String get settings_appLinkContainerFallbackName => 'Kontainer';

  @override
  String get settings_appLinkOverrideModeAlways => 'Selalu buka di aplikasi';

  @override
  String get settings_appLinkOverrideModeAsk => 'Bertanya sebelum membuka';

  @override
  String get settings_appLinkOverrideModeNever => 'Selalu tetap di peramban';

  @override
  String get settings_appLinkContainerOverridesHeader =>
      'Kontainer dengan pengaturan tautan aplikasi sendiri';

  @override
  String settings_appLinkOverrideSummaryWithRules(String mode, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aturan diingat',
      one: '1 aturan diingat',
    );
    return '$mode · $_temp0';
  }

  @override
  String get settings_appLinkRememberedRulesHeader =>
      'Aturan situs yang diingat';

  @override
  String get settings_appLinkRuleAlwaysOpenLabel => 'Selalu buka di aplikasi';

  @override
  String get settings_appLinkRuleAlwaysKeepLabel => 'Selalu tetap di peramban';

  @override
  String get settings_appLinkRuleRemoveTooltip => 'Hapus aturan';

  @override
  String get settings_globalDesktopModeTitle => 'Selalu Minta Situs Desktop';

  @override
  String get settings_globalDesktopModeKeywords =>
      'mode desktop, user agent, situs seluler, tablet, desktop mode';

  @override
  String get settings_globalDesktopModeSubtitle =>
      'Buka tab baru dalam mode desktop secara bawaan. Anda tetap dapat mengubah mode desktop per tab dari menu halaman.';

  @override
  String get settings_desktopModeSitesTitle => 'Situs Mode Desktop';

  @override
  String get settings_desktopModeSitesKeywords =>
      'mode desktop, per situs, user agent, pengecualian, desktop mode';

  @override
  String get settings_desktopModeSitesSubtitle =>
      'Situs yang selalu dimuat dalam mode desktop';

  @override
  String get settings_pullToRefreshTitle => 'Tarik untuk Menyegarkan';

  @override
  String get settings_pullToRefreshKeywords => 'muat ulang, segarkan, reload';

  @override
  String get settings_pullToRefreshSubtitle =>
      'Usap ke bawah pada halaman untuk memuat ulang';

  @override
  String get settings_customTabsTitle => 'Tab Kustom';

  @override
  String get settings_customTabsKeywords =>
      'tab kustom, peramban dalam aplikasi, chrome custom tabs, aplikasi eksternal, bagikan, custom tabs';

  @override
  String get settings_customTabsSubtitle =>
      'Izinkan aplikasi lain membuka tautan di tab dalam aplikasi yang ringan. Jika nonaktif, tautan tersebut dan URL yang dibagikan dibuka sebagai tab biasa di peramban utama.';

  @override
  String get settings_doubleBackCloseTabTitle =>
      'Kembali Dua Kali untuk Menutup Tab';

  @override
  String get settings_doubleBackCloseTabKeywords =>
      'tombol kembali, back button';

  @override
  String get settings_doubleBackCloseTabSubtitle =>
      'Jika diaktifkan, tekan tombol Kembali dua kali untuk menutup tab. Jika dinonaktifkan, tombol Kembali hanya bernavigasi dalam riwayat halaman.';

  @override
  String get settings_allowNonManifestPwaInstallTitle =>
      'Pasang Situs sebagai Aplikasi';

  @override
  String get settings_allowNonManifestPwaInstallKeywords =>
      'pwa, aplikasi web, web apps';

  @override
  String get settings_allowNonManifestPwaInstallSubtitle =>
      'Izinkan pemasangan situs web tanpa manifes PWA sebagai aplikasi mandiri';

  @override
  String get settings_urlCleanerTitle => 'Pembersih URL';

  @override
  String get settings_urlCleanerKeywords =>
      'utm, parameter pelacakan, tracking parameters';

  @override
  String get settings_urlCleanerSubtitle =>
      'Aturan penghapusan pelacakan dan pembaruan katalog';

  @override
  String get settings_unshortenerTitle => 'Pengurai Tautan Pendek';

  @override
  String get settings_unshortenerKeywords =>
      'tautan pendek, pengalihan, short links, redirects';

  @override
  String get settings_unshortenerSubtitle =>
      'Pengurai tautan pendek dan token API';

  @override
  String get settings_contextualToolbarSearchHint => 'Cari tombol bilah alat';

  @override
  String get settings_contextualToolbarTitleDefault => 'Sesuaikan Bilah Alat';

  @override
  String get settings_contextualToolbarTitleQuickSwitcher =>
      'Sesuaikan Tombol Pengalih';

  @override
  String get settings_contextualToolbarResetToDefaults =>
      'Atur Ulang ke Bawaan';

  @override
  String get settings_contextualToolbarEnabledSection => 'Aktif';

  @override
  String get settings_contextualToolbarDisabledSection => 'Nonaktif';

  @override
  String get settings_contextualToolbarNoEnabledButtons =>
      'Tidak ada tombol yang aktif. Aktifkan salah satu tombol di bawah.';

  @override
  String settings_contextualToolbarNoEnabledButtonsMatch(String query) {
    return 'Tidak ada tombol aktif yang cocok dengan \"$query\".';
  }

  @override
  String get settings_contextualToolbarAllButtonsEnabled =>
      'Semua tombol aktif.';

  @override
  String settings_contextualToolbarNoDisabledButtonsMatch(String query) {
    return 'Tidak ada tombol nonaktif yang cocok dengan \"$query\".';
  }

  @override
  String get settings_longPressNoneTitle => 'Tidak ada';

  @override
  String get settings_longPressNoneDescription =>
      'Bawaan untuk tombol ini: menahannya tidak melakukan apa pun';

  @override
  String get settings_longPressDefaultDescription => 'Bawaan untuk tombol ini';

  @override
  String get settings_longPressTitle => 'Tekan lama';

  @override
  String get settings_longPressDescription => 'Fungsi saat tombol ditahan';

  @override
  String get settings_fallbackGreyOutLabel => 'Buat abu-abu';

  @override
  String get settings_fallbackIfUnavailableTitle => 'Jika tidak tersedia';

  @override
  String get settings_fallbackIfUnavailableDescription =>
      'Ditampilkan sebagai pengganti saat tombol ini tidak dapat digunakan';

  @override
  String get settings_customTrackingProtectionTitle =>
      'Perlindungan Pelacakan Kustom';

  @override
  String get settings_customTrackingProtectionSubtitle =>
      'Kontrol kustom untuk kuki, konten, pelacak, dan sidik jari.';

  @override
  String get settings_fixMajorIssuesTitle => 'Perbaiki masalah besar situs web';

  @override
  String get settings_fixMajorIssuesSubtitle =>
      'Terapkan pengecualian yang diperlukan agar situs web tidak rusak parah (disarankan)';

  @override
  String get settings_fixMinorIssuesTitle => 'Perbaiki masalah kecil situs web';

  @override
  String get settings_fixMinorIssuesSubtitle =>
      'Terapkan pengecualian untuk memperbaiki masalah kecil dan mengaktifkan fitur kenyamanan';

  @override
  String get settings_blockCookiesTitle => 'Blokir Kuki';

  @override
  String get settings_blockCookiesSubtitle =>
      'Blokir kuki berdasarkan kebijakan di bawah';

  @override
  String get settings_cookiePolicyTitle => 'Kebijakan Kuki';

  @override
  String get settings_cookiePolicyTotalProtectionLabel =>
      'Perlindungan Kuki Total (Disarankan)';

  @override
  String get settings_cookiePolicyCrossSiteTrackersLabel =>
      'Pelacak lintas situs dan media sosial';

  @override
  String get settings_cookiePolicyUnvisitedLabel =>
      'Situs yang belum dikunjungi';

  @override
  String get settings_cookiePolicyThirdPartyLabel => 'Semua kuki pihak ketiga';

  @override
  String get settings_cookiePolicyAllCookiesLabel =>
      'Semua kuki (dapat merusak situs)';

  @override
  String get settings_blockTrackingContentTitle => 'Blokir Konten Pelacak';

  @override
  String get settings_blockTrackingContentSubtitle =>
      'Blokir skrip dan sumber daya pelacak yang tertanam di situs web';

  @override
  String get settings_trackingScopeApplyToTitle => 'Terapkan ke';

  @override
  String get settings_trackingScopeAllTabsLabel => 'Semua tab';

  @override
  String get settings_trackingScopePrivateOnlyLabel => 'Hanya tab pribadi';

  @override
  String get settings_adsAnalyticsSocialTrackersTitle =>
      'Pelacak Iklan, Analitik, dan Sosial';

  @override
  String get settings_adsAnalyticsSocialTrackersSubtitle =>
      'Blokir kategori pelacak iklan, analitik, sosial, dan pelacak sosial Mozilla';

  @override
  String get settings_cryptominersTitle => 'Penambang Kripto';

  @override
  String get settings_cryptominersSubtitle =>
      'Blokir skrip yang menggunakan perangkat Anda untuk menambang mata uang kripto';

  @override
  String get settings_knownFingerprintersTitle =>
      'Pembuat Sidik Jari yang Dikenal';

  @override
  String get settings_knownFingerprintersSubtitle =>
      'Blokir skrip yang mengumpulkan informasi untuk mengidentifikasi perangkat Anda secara unik';

  @override
  String get settings_redirectTrackersTitle => 'Pelacak Pengalihan';

  @override
  String get settings_redirectTrackersSubtitle =>
      'Blokir pelacak yang mengumpulkan data melalui pengalihan URL perantara';

  @override
  String get settings_suspectedFingerprintersTitle =>
      'Terduga Pembuat Sidik Jari';

  @override
  String get settings_suspectedFingerprintersSubtitle =>
      'Blokir teknik pembuatan sidik jari tambahan yang dapat digunakan untuk melacak Anda';

  @override
  String get settings_desktopModeSitesScreenTitle => 'Situs mode desktop';

  @override
  String get settings_desktopModeSitesScreenDescription =>
      'Situs-situs ini selalu dimuat dalam mode desktop, mengesampingkan bawaan. Subdomain juga termasuk (mis. \"example.com\" juga mencakup \"m.example.com\").';

  @override
  String get settings_desktopModeSitesEmptyLabel =>
      'Belum ada situs yang ditambahkan.';

  @override
  String get settings_dohTitle => 'DNS over HTTPS';

  @override
  String get settings_dohSubtitle =>
      'Tingkat perlindungan DNS terenkripsi dan pilihan resolver.';

  @override
  String get settings_errorLogsCopiedMessage => 'Log disalin';

  @override
  String get settings_errorLogsSearchHint => 'Cari pesan log';

  @override
  String get settings_errorLogsCopyTooltip => 'Salin log';

  @override
  String get settings_errorLogsEmptyLabel => 'Tidak ada log';

  @override
  String get settings_experimentalTitle => 'Eksperimental';

  @override
  String get settings_experimentalSubtitle =>
      'Isolasi runtime dan perilaku saat memulai.';

  @override
  String get settings_isolatedContentProcessTitle => 'Proses Konten Terisolasi';

  @override
  String get settings_isolatedContentProcessKeywords => 'mulai ulang, restart';

  @override
  String get settings_isolatedContentProcessSubtitle =>
      'Jalankan konten web dalam proses terisolasi. Memerlukan mulai ulang aplikasi.';

  @override
  String get settings_appZygoteProcessTitle => 'Proses App Zygote';

  @override
  String get settings_appZygoteProcessKeywords =>
      'mulai ulang, restart, android 10';

  @override
  String get settings_appZygoteProcessSubtitle =>
      'Muat awal layanan konten agar proses terisolasi dimulai lebih cepat. Memerlukan Android 10+ dan mulai ulang aplikasi.';

  @override
  String get settings_extensionsTitle => 'Ekstensi';

  @override
  String get settings_extensionsSubtitle =>
      'Kelola pengaya, perilaku pembaruan, dan keamanan ekstensi.';

  @override
  String get settings_manageExtensionsTitle => 'Kelola Ekstensi';

  @override
  String get settings_manageExtensionsKeywords =>
      'pengaya, ekstensi peramban, addons, browser extensions';

  @override
  String get settings_manageExtensionsSubtitle =>
      'Jelajahi ekstensi yang terpasang, nonaktif, tersedia, dan tidak didukung';

  @override
  String get settings_customCollectionTitle => 'Koleksi Kustom';

  @override
  String get settings_customCollectionKeywords => 'pengaya, koleksi, addons';

  @override
  String get settings_customCollectionSubtitle =>
      'Gunakan koleksi pengaya Mozilla kustom';

  @override
  String get settings_automaticUpdatesTitle => 'Pembaruan otomatis';

  @override
  String get settings_automaticUpdatesKeywords =>
      'pengaya, pembaruan, addons, updates';

  @override
  String get settings_automaticUpdatesSubtitle =>
      'Periksa dan pasang pembaruan ekstensi secara otomatis setiap 12 jam';

  @override
  String settings_failedToLoadMessage(String error) {
    return 'Gagal memuat: $error';
  }

  @override
  String get settings_allowUnsignedExtensionsTitle =>
      'Izinkan ekstensi tanpa tanda tangan';

  @override
  String get settings_allowUnsignedExtensionsKeywords =>
      'pengaya, tanpa tanda tangan, addons, unsigned';

  @override
  String get settings_allowUnsignedExtensionsSubtitle =>
      'Ekstensi tanpa tanda tangan belum diverifikasi oleh Mozilla';

  @override
  String get settings_allowUnsignedWarningText =>
      'Pasang ekstensi tanpa tanda tangan hanya dari sumber yang Anda percayai. Ekstensi tersebut dapat berisi kode berbahaya.';

  @override
  String get settings_allowUnsignedConfirmDialogTitle =>
      'Izinkan ekstensi tanpa tanda tangan?';

  @override
  String get settings_allowUnsignedConfirmWarningBold =>
      'Peringatan: Ini sangat melemahkan keamanan peramban Anda.';

  @override
  String get settings_allowUnsignedConfirmBody =>
      'Ekstensi tanpa tanda tangan melewati proses peninjauan keamanan Mozilla. Ekstensi berbahaya dapat:\n\n• Membaca dan mengubah semua yang Anda lihat di situs web mana pun\n• Mencuri kata sandi, detail perbankan, dan data pribadi\n• Memantau aktivitas penjelajahan Anda diam-diam\n• Memasang malware tambahan di perangkat Anda';

  @override
  String get settings_allowUnsignedConfirmFooter =>
      'Aktifkan ini hanya jika Anda pengembang yang memasang ekstensi sendiri atau benar-benar memercayai sumbernya.';

  @override
  String get settings_allowAction => 'Izinkan';

  @override
  String settings_allowActionCountdown(int seconds) {
    return 'Izinkan ($seconds)';
  }

  @override
  String get settings_fingerprintProtectionTitle => 'Perlindungan Sidik Jari';

  @override
  String get settings_fingerprintProtectionKeywords =>
      'privasi, sidik jari, privacy, fingerprint';

  @override
  String get settings_fingerprintSearchHint =>
      'Cari target penggantian sidik jari';

  @override
  String get settings_loadDefaultsAction => 'Muat Bawaan';

  @override
  String get settings_loadHardenedDefaultsAction =>
      'Muat Bawaan yang Diperketat';

  @override
  String get settings_fingerprintOverrideTargetsSection => 'Target Penggantian';

  @override
  String get settings_fingerprintInvalidOverride =>
      'Penggantian sidik jari yang tersimpan tidak dalam format yang valid';

  @override
  String get settings_fingerprintUnknownTarget =>
      'Penggantian sidik jari yang tersimpan menyebut target yang tidak dikenal versi ini';

  @override
  String get settings_homeAndNewTabTitle => 'Beranda & Tab Baru';

  @override
  String get settings_homeAndNewTabSubtitle =>
      'Yang ditampilkan di beranda dan halaman tab baru';

  @override
  String get settings_addressFieldLabel => 'Alamat';

  @override
  String get settings_homeTargetUrlEmptyError =>
      'Masukkan alamat, atau beranda akan ditampilkan sebagai gantinya';

  @override
  String get settings_homeTargetUrlInvalidError => 'Alamat tidak valid';

  @override
  String get settings_applyWhenLastTabClosesTitle =>
      'Terapkan saat tab terakhir ditutup';

  @override
  String get settings_applyWhenLastTabClosesKeywords =>
      'tutup, tab terakhir, kontainer, close, last tab, container';

  @override
  String get settings_applyWhenLastTabClosesSubtitle =>
      'Menutup tab terakhir di suatu kontainer akan tetap di sana, alih-alih membuka tab dari tempat lain';

  @override
  String settings_homeSearchBarCurrentlyLabel(String value) {
    return 'Saat ini: $value';
  }

  @override
  String get settings_wallpaperTitle => 'Wallpaper';

  @override
  String get settings_wallpaperKeywords =>
      'wallpaper, latar belakang, gambar, foto, buram, redup, beranda, background';

  @override
  String get settings_wallpaperSetSubtitle =>
      'Gambar latar belakang telah diatur untuk beranda';

  @override
  String get settings_wallpaperUnsetSubtitle =>
      'Atur gambar latar belakang untuk beranda';

  @override
  String get settings_customizeHomeSectionsTitle => 'Sesuaikan bagian beranda';

  @override
  String get settings_customizeHomeSectionsKeywords =>
      'beranda, bagian, pintasan, kutipan, tindakan cepat, urutkan ulang, home, sections';

  @override
  String get settings_customizeHomeSectionsSubtitle =>
      'Pilih dan urutkan yang ditampilkan di beranda';

  @override
  String get settings_customizeNewTabSectionsTitle =>
      'Sesuaikan bagian tab baru';

  @override
  String get settings_customizeNewTabSectionsKeywords =>
      'tab baru, bagian, pintasan, urutkan ulang, new tab, sections';

  @override
  String get settings_customizeNewTabSectionsSubtitle =>
      'Pilih dan urutkan yang ditampilkan di halaman tab baru';

  @override
  String get settings_browserLanguagesTitle => 'Bahasa Peramban';

  @override
  String get settings_browserLanguagesKeywords =>
      'lokal, bahasa, locale, language';

  @override
  String get settings_browserLanguagesSearchHint =>
      'Cari lokal berdasarkan tag bahasa';

  @override
  String get settings_languageRegionSettingsSection =>
      'Pengaturan Bahasa & Wilayah';

  @override
  String get settings_browserLanguagePreferenceLabel =>
      'Preferensi bahasa peramban';

  @override
  String get settings_customLocaleSection => 'Lokal Kustom';

  @override
  String get settings_addCustomLocaleTitle => 'Tambah lokal kustom';

  @override
  String get settings_addCustomLocaleKeywords => 'tag lokal, locale tag';

  @override
  String get settings_addCustomLocaleSubtitle =>
      'Masukkan tag lokal seperti en-US';

  @override
  String get settings_customLocaleFieldLabel => 'Lokal Kustom';

  @override
  String get settings_invalidLocaleError => 'Pengenal lokal tidak valid';

  @override
  String get settings_homeTargetHomeLabel => 'Beranda';

  @override
  String get settings_homeTargetResumeLastTabLabel =>
      'Tab yang terakhir dibuka';

  @override
  String get settings_homeTargetCustomUrlLabel => 'Alamat kustom';

  @override
  String get settings_homeTargetHomeDescription =>
      'Tampilkan pintasan dan bagian yang Anda pilih';

  @override
  String get settings_homeTargetResumeLastTabDescription =>
      'Lanjutkan dari tempat terakhir Anda';

  @override
  String get settings_homeTargetCustomUrlDescription => 'Buka halaman tertentu';

  @override
  String get settings_homeSearchBarAutoLabel => 'Ikuti bilah tab';

  @override
  String get settings_homeSearchBarTopLabel => 'Bagian atas beranda';

  @override
  String get settings_homeSearchBarTabBarLabel => 'Di bilah tab';

  @override
  String get settings_homeSearchBarAutoDescription =>
      'Di tepi mana pun bilah tab berada';

  @override
  String get settings_homeSearchBarTopDescription =>
      'Bilah pencarian tetap di atas bagian-bagian beranda';

  @override
  String get settings_homeSearchBarTabBarDescription =>
      'Kolom alamat di bilah tab, dengan QR dan pencarian suara';

  @override
  String get settings_generalTitle => 'Umum';

  @override
  String get settings_generalSubtitle =>
      'Tampilan, unduhan, dan bawaan peramban.';

  @override
  String get settings_defaultBrowserTileTitle => 'Peramban Bawaan';

  @override
  String get settings_defaultBrowserTileKeywords =>
      'peramban sistem, peramban default, system browser, default browser';

  @override
  String get settings_defaultBrowserTileSubtitleSet =>
      'WebLibre adalah peramban bawaan Anda';

  @override
  String get settings_defaultBrowserTileSubtitleNotSet =>
      'Jadikan WebLibre sebagai peramban bawaan Anda';

  @override
  String get settings_defaultBrowserButtonDefault => 'Bawaan';

  @override
  String get settings_defaultBrowserButtonSet => 'Atur';

  @override
  String get settings_backupProfileTitle => 'Cadangkan profil ini';

  @override
  String get settings_backupProfileKeywords =>
      'cadangan, arsip, ekspor, simpan, terenkripsi, pulihkan, backup, restore';

  @override
  String settings_backupProfileSubtitleReady(String name) {
    return 'Tulis \"$name\" ke berkas cadangan terenkripsi';
  }

  @override
  String get settings_backupProfileSubtitleError =>
      'Tidak dapat membaca profil aktif';

  @override
  String get settings_settingsTransferTileTitle => 'Ekspor & Impor Pengaturan';

  @override
  String get settings_settingsTransferTileKeywords =>
      'ekspor, impor, pengaturan, transfer, bagikan, papan klip, json, salin, migrasi, export, import';

  @override
  String get settings_settingsTransferTileSubtitle =>
      'Tulis pengaturan ke berkas atau papan klip, dan baca kembali';

  @override
  String get settings_uiZoomTitle => 'Zoom Antarmuka Pengguna';

  @override
  String get settings_uiZoomKeywords => 'skala ui, zoom, ukuran, ui scale';

  @override
  String get settings_uiZoomSubtitle =>
      'Perkecil atau perbesar antarmuka pengguna';

  @override
  String get settings_disableAnimationsTitle => 'Nonaktifkan Animasi';

  @override
  String get settings_disableAnimationsKeywords => 'gerakan, animasi, motion';

  @override
  String get settings_disableAnimationsSubtitle =>
      'Kurangi gerakan dan matikan animasi aplikasi';

  @override
  String get settings_showModalBarrierTitle => 'Tampilkan Latar Modal';

  @override
  String get settings_showModalBarrierKeywords =>
      'dialog, lembar bawah, overlay, bottom sheets';

  @override
  String get settings_showModalBarrierSubtitle =>
      'Redupkan latar belakang di balik dialog dan lembar bawah';

  @override
  String get settings_showSearchCloseButtonTitle => 'Tampilkan Tombol Tutup';

  @override
  String get settings_showSearchCloseButtonKeywords =>
      'kembali, tutup, e-ink, eink, aksesibilitas, tab baru, back, close';

  @override
  String get settings_showSearchCloseButtonSubtitle =>
      'Tambahkan tombol untuk menutup halaman pencarian atau tab baru tanpa gestur kembali. Berguna di perangkat tanpa tombol kembali.';

  @override
  String get settings_pureBlackTitle => 'Hitam Pekat (OLED)';

  @override
  String get settings_pureBlackKeywords =>
      'oled, amoled, kontras tinggi, hitam, gelap, black, dark';

  @override
  String get settings_pureBlackSubtitle =>
      'Gunakan permukaan hitam pekat dalam mode gelap untuk menghemat daya di layar OLED';

  @override
  String get settings_themeTitle => 'Tema';

  @override
  String get settings_themeKeywords =>
      'terang, gelap, mode tema, light, dark, theme';

  @override
  String get settings_themeModeSystem => 'Sistem';

  @override
  String get settings_themeModeLight => 'Terang';

  @override
  String get settings_themeModeDark => 'Gelap';

  @override
  String get settings_appLanguageSystemDefault => 'Bawaan sistem';

  @override
  String settings_appLanguageCurrentlyLabel(String language) {
    return 'Saat ini: $language';
  }

  @override
  String get settings_appLanguageTranslationsNote =>
      'Terjemahan masih baru dan mungkin belum lengkap atau kurang akurat, jadi WebLibre menggunakan bahasa Inggris sampai Anda memilih bahasa lain. Pilih \"Bawaan sistem\" untuk mengikuti bahasa perangkat Anda.';

  @override
  String get settings_refreshRateTitle => 'Kecepatan Refresh';

  @override
  String get settings_refreshRateKeywords =>
      'fps, hz, hertz, frame rate, framerate, 60hz, 90hz, 120hz, mulus, refresh tinggi, mode layar, refresh rate';

  @override
  String get settings_refreshRateSubtitle =>
      'Pilih \"Tinggi\" untuk guliran dan animasi paling mulus di layar 90/120Hz, atau \"Rendah\" untuk menghemat baterai.';

  @override
  String get settings_refreshRateModeSystem => 'Sistem';

  @override
  String get settings_refreshRateModeHigh => 'Tinggi';

  @override
  String get settings_refreshRateModeLow => 'Rendah';

  @override
  String get settings_downloadFolderTitle => 'Folder unduhan';

  @override
  String get settings_downloadFolderKeywords =>
      'unduhan, folder, direktori, penyimpanan, simpan, downloads';

  @override
  String get settings_downloadFolderSubtitleDefault =>
      'Menyimpan ke folder Download sistem';

  @override
  String settings_downloadFolderSubtitleUnavailable(String folderName) {
    return 'Tidak lagi tersedia — menyimpan ke folder Download sistem ($folderName)';
  }

  @override
  String get settings_downloadFolderSubtitleExternalManager =>
      'Aplikasi pengelola unduhan yang menentukan lokasi penyimpanan berkas';

  @override
  String get settings_downloadFolderResetTooltip =>
      'Gunakan folder Download sistem';

  @override
  String get settings_externalDownloadManagerTitle =>
      'Gunakan pengelola unduhan eksternal';

  @override
  String get settings_externalDownloadManagerKeywords =>
      'unduhan, pengelola unduhan, downloads';

  @override
  String get settings_externalDownloadManagerSubtitle =>
      'Kelola unduhan dengan aplikasi lain';

  @override
  String get settings_preferredDownloadManagerTitle =>
      'Pengelola unduhan pilihan';

  @override
  String get settings_preferredDownloadManagerKeywords =>
      'unduhan, pengelola unduhan, selalu gunakan, aplikasi bawaan, pemilih, tanya, downloads, download manager';

  @override
  String get settings_preferredDownloadManagerSubtitleNotSet =>
      'Belum diatur — centang “Selalu gunakan aplikasi ini” saat pemilih muncul berikutnya';

  @override
  String settings_preferredDownloadManagerSubtitleThisApp(String appName) {
    return '$appName, dengan konfirmasi sebelum setiap unduhan';
  }

  @override
  String settings_preferredDownloadManagerSubtitleUnavailable(
    String packageName,
  ) {
    return 'Tidak lagi terpasang ($packageName) — bertanya setiap kali';
  }

  @override
  String get settings_preferredDownloadManagerSubtitleExternalOff =>
      'Belum diatur — hanya digunakan dengan pengelola unduhan eksternal';

  @override
  String settings_preferredDownloadManagerSubtitleInactive(String appName) {
    return '$appName — tidak digunakan selama pengelola unduhan eksternal nonaktif';
  }

  @override
  String get settings_preferredDownloadManagerClearTooltip =>
      'Hapus pengelola pilihan';

  @override
  String get settings_defaultBrowserSectionTitle => 'Peramban Bawaan';

  @override
  String get settings_defaultBrowserSectionKeywords =>
      'bawaan peramban, browser defaults';

  @override
  String get settings_indexDefaultBrowserSubtitle =>
      'Jadikan WebLibre sebagai peramban bawaan Anda';

  @override
  String get settings_appearanceSectionTitle => 'Tampilan';

  @override
  String get settings_indexThemeSubtitle =>
      'Pilih mode sistem, terang, atau gelap';

  @override
  String get settings_indexAppLanguageTitle => 'Bahasa Aplikasi';

  @override
  String get settings_indexAppLanguageKeywords =>
      'lokal, terjemahan, bahasa ui, bahasa, locale, language';

  @override
  String get settings_indexAppLanguageSubtitle =>
      'Pilih bahasa untuk antarmuka WebLibre sendiri';

  @override
  String get settings_indexRefreshRateSubtitle =>
      'Minta kecepatan refresh layar tinggi atau rendah (Android)';

  @override
  String get settings_indexShowCloseButtonSubtitle =>
      'Tambahkan tombol untuk menutup halaman pencarian / tab baru tanpa gestur kembali';

  @override
  String get settings_profileSectionTitle => 'Profil';

  @override
  String get settings_profileSectionKeywords =>
      'pengguna, profil, user, profile';

  @override
  String get settings_indexBackupProfileSubtitle =>
      'Buat cadangan terenkripsi dari profil yang sedang Anda gunakan';

  @override
  String get settings_indexSettingsTransferSubtitle =>
      'Pindahkan pengaturan antarprofil atau antarperangkat, atau lampirkan ke laporan bug';

  @override
  String get settings_downloadsSectionTitle => 'Unduhan';

  @override
  String get settings_indexDownloadFolderSubtitle =>
      'Pilih lokasi penyimpanan berkas yang diunduh';

  @override
  String get settings_indexPreferredDownloadManagerSubtitle =>
      'Aplikasi yang menerima unduhan tanpa konfirmasi';

  @override
  String get settings_contentIdentitySectionTitle => 'Konten & Identitas';

  @override
  String get settings_contentIdentitySectionKeywords => 'mesin, engine';

  @override
  String get settings_indexJavascriptSubtitle =>
      'Aktifkan atau nonaktifkan skrip situs web';

  @override
  String get settings_indexUserAgentSubtitle =>
      'Ganti string user agent peramban';

  @override
  String get settings_indexEnterpriseRootsSubtitle =>
      'Izinkan sertifikat dari penyimpanan CA Android';

  @override
  String get settings_experimentalSectionTitle => 'Eksperimental';

  @override
  String get settings_developerToolsSectionTitle => 'Alat Pengembang';

  @override
  String get settings_developerToolsSectionKeywords => 'debug, pengembang';

  @override
  String get settings_indexUnmountGeckoViewSubtitle =>
      'Bangun ulang mesin web setelah overlay, alih-alih tetap menyiagakannya';

  @override
  String get settings_tabsSectionTitle => 'Tab';

  @override
  String get settings_indexTabListDirectionSubtitle =>
      'Pilih urutan tab di tampilan daftar';

  @override
  String get settings_indexTabBarDirectionSubtitle =>
      'Pilih urutan tab di bilah tab';

  @override
  String get settings_indexChildTabPlacementSubtitle =>
      'Pilih posisi tab yang dibuka dari tab lain';

  @override
  String get settings_indexCreateChildTabsSubtitle =>
      'Tampilkan tombol yang menambahkan tab anak di bawah tab saat ini';

  @override
  String get settings_indexBackgroundTabBehaviorSubtitle =>
      'Pilih yang terjadi setelah tab dibuka di latar belakang';

  @override
  String get settings_navigationSectionTitle => 'Navigasi';

  @override
  String get settings_indexDoubleBackCloseTabSubtitle =>
      'Wajibkan dua kali tekan tombol Kembali untuk menutup tab saat ini';

  @override
  String get settings_indexTabBarSwipesSubtitle =>
      'Pilih fungsi usapan pada bilah tab';

  @override
  String get settings_indexSequentialTabNavigationSubtitle =>
      'Pilih di mana perpindahan tab berurutan berakhir';

  @override
  String get settings_indexOpenLinksInAppsSubtitle =>
      'Pilih cara tautan aplikasi eksternal dibuka';

  @override
  String get settings_desktopModeSectionTitle => 'Mode Desktop';

  @override
  String get settings_indexGlobalDesktopModeSubtitle =>
      'Buka tab baru dalam mode desktop secara bawaan';

  @override
  String get settings_homeScreenSectionTitle => 'Layar Utama';

  @override
  String get settings_indexAllowNonManifestPwaInstallSubtitle =>
      'Izinkan situs web tanpa manifes dipasang sebagai aplikasi';

  @override
  String get settings_externalLinksSectionTitle => 'Tautan Eksternal';

  @override
  String get settings_indexCustomTabsSubtitle =>
      'Izinkan aplikasi lain membuka tautan di tab dalam aplikasi yang ringan, bukan di peramban utama';

  @override
  String get settings_bookmarksSectionTitle => 'Markah';

  @override
  String get settings_resolverSettingsSectionTitle => 'Pengaturan Resolver';

  @override
  String get settings_indexDnsOverHttpsResolverTitle => 'DNS over HTTPS';

  @override
  String get settings_indexDnsOverHttpsResolverKeywords =>
      'doh, resolver, penyedia dns, resolver kustom, dns provider';

  @override
  String get settings_indexDnsOverHttpsResolverSubtitle =>
      'Tingkat perlindungan, pilihan penyedia, dan resolver kustom yang tersimpan';

  @override
  String get settings_runtimeStartupSectionTitle => 'Runtime & Saat Mulai';

  @override
  String get settings_indexIsolatedContentProcessSubtitle =>
      'Jalankan konten web dalam proses terisolasi';

  @override
  String get settings_indexAppZygoteProcessSubtitle =>
      'Muat awal layanan konten agar proses terisolasi dimulai lebih cepat';

  @override
  String get settings_startupSectionTitle => 'Saat Mulai';

  @override
  String get settings_startupSectionKeywords =>
      'saat mulai, beranda, lanjutkan, tab terakhir, url kustom, startup, home';

  @override
  String get settings_indexHomeTargetTitle =>
      'Saat tidak ada tab untuk ditampilkan';

  @override
  String get settings_indexHomeTargetKeywords =>
      'saat mulai, lanjutkan, tab terakhir, url kustom, beranda, startup, homepage';

  @override
  String get settings_indexHomeTargetSubtitle =>
      'Saat memulai dan setelah menutup tab terakhir';

  @override
  String get settings_indexHomeTargetOnLastTabClosedSubtitle =>
      'Jika tidak, tab dari kontainer lain akan dibuka sebagai gantinya';

  @override
  String get settings_homeAppearanceSectionTitle => 'Tampilan';

  @override
  String get settings_homeAppearanceSectionKeywords =>
      'beranda, wallpaper, latar belakang, gambar, buram, redup, home';

  @override
  String get settings_indexWallpaperSubtitle =>
      'Gambar latar belakang untuk beranda';

  @override
  String get settings_layoutSectionTitle => 'Tata Letak';

  @override
  String get settings_layoutSectionKeywords =>
      'beranda, tab baru, bagian, modul, tata letak, home, layout';

  @override
  String get settings_indexHomeSearchBarPlacementTitle =>
      'Posisi bilah pencarian';

  @override
  String get settings_indexHomeSearchBarPlacementKeywords =>
      'cari, bilah, posisi, alamat, url, atas, bawah, bilah tab, beranda, search bar';

  @override
  String get settings_indexHomeSearchBarPlacementSubtitle =>
      'Tempat beranda menampilkan kolom pencariannya';

  @override
  String get settings_allowlistExceptionsSectionTitle =>
      'Pengecualian Daftar Izin';

  @override
  String get settings_indexAllowlistExceptionsTitle =>
      'Pengecualian daftar izin';

  @override
  String get settings_indexAllowlistExceptionsSubtitle =>
      'Pengecualian kompatibilitas untuk masalah besar dan kecil situs web';

  @override
  String get settings_cookiesSectionTitle => 'Kuki';

  @override
  String get settings_indexCookiesSubtitle =>
      'Mode pemblokiran kuki dan pilihan kebijakan';

  @override
  String get settings_trackingContentSectionTitle => 'Konten Pelacak';

  @override
  String get settings_indexTrackingContentTitle => 'Konten pelacak';

  @override
  String get settings_indexTrackingContentSubtitle =>
      'Skrip pelacak dan cakupan pemblokiran';

  @override
  String get settings_trackersSectionTitle => 'Pelacak';

  @override
  String get settings_indexTrackersSubtitle =>
      'Penambang kripto, pembuat sidik jari yang dikenal, dan pelacak pengalihan';

  @override
  String get settings_advancedFingerprintingProtectionSectionTitle =>
      'Perlindungan Sidik Jari Lanjutan';

  @override
  String get settings_indexAdvancedFingerprintingProtectionTitle =>
      'Perlindungan sidik jari lanjutan';

  @override
  String get settings_indexAdvancedFingerprintingProtectionSubtitle =>
      'Terduga pembuat sidik jari dan cakupan tab';

  @override
  String get settings_usageDataSectionTitle => 'Data Penggunaan';

  @override
  String get settings_repositoriesSectionTitle => 'Repositori';

  @override
  String get settings_indexGeneralBangsSubtitle =>
      'Sinkronkan sesuai permintaan dari GitHub';

  @override
  String get settings_generalBangsTileTitle => 'Bang Umum';

  @override
  String get settings_generalBangsTileKeywords => 'repositori, repository';

  @override
  String get settings_generalBangsTileSubtitle =>
      'Sinkronkan sesuai permintaan dari GitHub';

  @override
  String get settings_indexKagiBangsSubtitle =>
      'Sinkronkan sesuai permintaan dari GitHub';

  @override
  String get settings_kagiBangsTileTitle => 'Bang Kagi';

  @override
  String get settings_kagiBangsTileKeywords => 'repositori, repository';

  @override
  String get settings_kagiBangsTileSubtitle =>
      'Sinkronkan sesuai permintaan dari GitHub';

  @override
  String get settings_extensionsSectionTitle => 'Ekstensi';

  @override
  String get settings_updatesSectionTitle => 'Pembaruan';

  @override
  String get settings_securitySectionTitle => 'Keamanan';

  @override
  String get settings_actionResetToDefaults => 'Atur Ulang ke Bawaan';

  @override
  String get settings_menuLayoutTitle => 'Sesuaikan Menu';

  @override
  String get settings_menuLayoutHintSections =>
      'Seret untuk menata ulang. Matikan bagian untuk menyembunyikannya dari menu.';

  @override
  String get settings_menuLayoutHintSectionItems =>
      'Seret untuk menata ulang baris di bagian ini.';

  @override
  String get settings_menuLayoutHintSubItems =>
      'Seret untuk menata ulang baris yang dibuka dari item ini.';

  @override
  String get settings_moduleSurfaceHint =>
      'Seret untuk menata ulang. Matikan bagian untuk menyembunyikannya di sini tanpa memengaruhi halaman lainnya.';

  @override
  String get settings_moduleSurfaceTitleHome => 'Sesuaikan Beranda';

  @override
  String get settings_moduleSurfaceTitleNewTab => 'Sesuaikan Tab Baru';

  @override
  String get settings_homeSearchBarRowTitle => 'Bilah pencarian';

  @override
  String get settings_proxyTitle => 'Proksi';

  @override
  String get settings_proxySubtitle =>
      'Kelola koneksi proksi dan pilih tab yang menggunakannya.';

  @override
  String get settings_proxyConnectionsTitle => 'Koneksi Proksi';

  @override
  String get settings_proxyConnectionsKeywords =>
      'sing-box, socks, vpn, wireguard, tor, onion, jembatan, bridges, obfs4, snowflake, proksi, proxy';

  @override
  String get settings_proxyConnectionsSubtitle =>
      'Kelola profil dan koneksi proksi';

  @override
  String get settings_proxyRoutingTitle => 'Perutean Proksi';

  @override
  String get settings_proxyRoutingKeywords =>
      'perutean, kontainer, routing, container';

  @override
  String get settings_proxyRoutingSubtitle =>
      'Pilih proksi yang membawa tab biasa dan tab pribadi';

  @override
  String get settings_proxyLogsTitle => 'Log Proksi';

  @override
  String get settings_proxyLogsKeywords =>
      'log, pencatatan, diagnostik, debug, trace, verbose, pemecahan masalah, level, logging, troubleshoot';

  @override
  String get settings_toolbarLayoutTitle => 'Bilah Alat & Tata Letak';

  @override
  String get settings_toolbarLayoutSearchHint =>
      'Cari pengaturan bilah alat dan tata letak';

  @override
  String get settings_privacySecurityTitle => 'Privasi & Keamanan';

  @override
  String get settings_privacySecuritySubtitle =>
      'Perlindungan pelacakan, sidik jari, data penjelajahan, dan pengerasan jaringan.';

  @override
  String get settings_trackingProtectionExceptionsTitle =>
      'Pengecualian Perlindungan Pelacakan';

  @override
  String get settings_trackingProtectionExceptionsKeywords =>
      'pengecualian, exceptions';

  @override
  String get settings_trackingProtectionExceptionsTileSubtitle =>
      'Situs yang perlindungan pelacakannya dinonaktifkan';

  @override
  String get settings_autoDeleteBrowsingDataTitle =>
      'Hapus Data Penjelajahan Otomatis';

  @override
  String get settings_autoDeleteBrowsingDataKeywords =>
      'penyamaran, mode pribadi, keluar, tutup, hapus saat keluar, hapus data, incognito, private mode, quit';

  @override
  String get settings_autoDeleteBrowsingDataSubtitle =>
      'Hapus data penjelajahan yang dipilih saat keluar atau setiap kali WebLibre dimulai';

  @override
  String get settings_confirmBeforeQuitTitle => 'Konfirmasi Sebelum Keluar';

  @override
  String get settings_confirmBeforeQuitKeywords =>
      'keluar, tutup, konfirmasi, dialog, jangan tanya lagi, quit, exit';

  @override
  String get settings_confirmBeforeQuitSubtitle =>
      'Tanyakan sebelum \"Keluar\" menutup WebLibre. Tekan lama \"Keluar\" untuk melewati pertanyaan ini.';

  @override
  String get settings_trackingProtectionExceptionsSearchHint =>
      'Cari URL pengecualian';

  @override
  String get settings_trackingProtectionExceptionsDeleteAll => 'Hapus Semua';

  @override
  String get settings_trackingProtectionExceptionsSectionTitle =>
      'Daftar Pengecualian';

  @override
  String get settings_trackingProtectionExceptionsEntrySubtitle =>
      'Situs dengan perlindungan pelacakan dinonaktifkan';

  @override
  String get settings_trackingProtectionExceptionsRemoveTooltip =>
      'Hapus pengecualian';

  @override
  String get settings_trackingProtectionExceptionsEmptyTitle =>
      'Tidak ada pengecualian';

  @override
  String get settings_trackingProtectionExceptionsEmptySubtitle =>
      'Situs yang ditambahkan ke pengecualian akan muncul di sini';

  @override
  String get settings_trackingProtectionExceptionsErrorTitle =>
      'Galat saat memuat pengecualian';

  @override
  String settings_trackingProtectionExceptionsDeleteAllFailed(String error) {
    return 'Gagal menghapus pengecualian: $error';
  }

  @override
  String settings_trackingProtectionExceptionsRemoveFailed(String error) {
    return 'Gagal menghapus pengecualian: $error';
  }

  @override
  String get settings_deleteBrowsingDataTileTitle => 'Hapus Data Penjelajahan';

  @override
  String get settings_deleteBrowsingDataTileKeywords =>
      'hapus data, bersihkan data, clear data';

  @override
  String get settings_autoClearHistoryTitle => 'Hapus Riwayat Otomatis';

  @override
  String get settings_autoClearHistoryKeywords =>
      'penyimpanan riwayat, riwayat, history retention';

  @override
  String get settings_autoClearHistorySubtitle =>
      'Hapus otomatis riwayat penjelajahan yang lebih lama dari jangka waktu yang dipilih';

  @override
  String get settings_autoClearUnassignedTabsTitle =>
      'Tutup Otomatis Tab Tanpa Kontainer';

  @override
  String get settings_autoClearUnassignedTabsKeywords =>
      'bersihkan tab, cleanup tabs';

  @override
  String get settings_autoClearUnassignedTabsSubtitle =>
      'Tutup otomatis tab tanpa kontainer yang lebih lama dari jangka waktu yang dipilih';

  @override
  String get settings_durationNever => 'Jangan pernah';

  @override
  String get settings_duration1Day => '1 Hari';

  @override
  String get settings_duration3Days => '3 Hari';

  @override
  String get settings_duration1Week => '1 Minggu';

  @override
  String get settings_duration2Weeks => '2 Minggu';

  @override
  String get settings_duration1Month => '1 Bulan';

  @override
  String get settings_duration3Months => '3 Bulan';

  @override
  String get settings_globalPrivacyControlTitle =>
      'Global Privacy Control (GPC)';

  @override
  String get settings_globalPrivacyControlKeywords => 'gpc, kontrol privasi';

  @override
  String get settings_screenshotProtectionTitle =>
      'Perlindungan tangkapan layar';

  @override
  String get settings_screenshotProtectionKeywords =>
      'tangkapan layar, screenshot, screenshots';

  @override
  String get settings_screenshotProtectionSubtitle =>
      'Memblokir tangkapan layar dan rekaman layar untuk aplikasi ini di Android.';

  @override
  String get settings_allowPrivateTabScreenshotsTitle =>
      'Izinkan tangkapan layar di tab pribadi';

  @override
  String get settings_allowPrivateTabScreenshotsKeywords =>
      'tangkapan layar, penyamaran, pribadi, screenshots, incognito, private';

  @override
  String get settings_allowPrivateTabScreenshotsOverriddenSubtitle =>
      'Dikesampingkan oleh perlindungan tangkapan layar, yang memblokir tangkapan di semua tab.';

  @override
  String get settings_allowPrivateTabScreenshotsSubtitle =>
      'Tab pribadi dapat ditangkap layar dan direkam, dan muncul di pratinjau pengalih aplikasi.';

  @override
  String get settings_httpsOnlyModeTitle =>
      'Blokir koneksi HTTP yang tidak aman';

  @override
  String get settings_httpsOnlyModeKeywords => 'hanya https, https only';

  @override
  String get settings_httpsOnlyModeDisabledLabel => 'Nonaktif';

  @override
  String get settings_httpsOnlyModeEnabledLabel => 'Aktif';

  @override
  String get settings_httpsOnlyModePrivateOnlyLabel => 'Hanya pribadi';

  @override
  String get settings_dnsOverHttpsTileTitle => 'DNS over HTTPS';

  @override
  String get settings_enhancedTrackingProtectionTitle =>
      'Perlindungan Pelacakan yang Ditingkatkan';

  @override
  String get settings_enhancedTrackingProtectionKeywords =>
      'etp, standar, ketat, kustom, standard, strict, custom';

  @override
  String get settings_trackingProtectionDisabledLabel => 'Nonaktif';

  @override
  String get settings_trackingProtectionStandardLabel => 'Standar';

  @override
  String get settings_trackingProtectionStandardSubtitle =>
      'Menyeimbangkan perlindungan dan kompatibilitas dengan memblokir lebih sedikit kategori pelacak.';

  @override
  String get settings_trackingProtectionStrictLabel => 'Ketat';

  @override
  String get settings_trackingProtectionStrictSubtitle =>
      'Memblokir lebih banyak kategori pelacak, termasuk konten pelacak, tetapi dapat merusak beberapa situs.';

  @override
  String get settings_trackingProtectionCustomLabel => 'Kustom';

  @override
  String get settings_trackingProtectionCustomSubtitle =>
      'Pilih pelacak dan skrip yang akan diblokir.';

  @override
  String get settings_contentBlockingDatabaseTitle =>
      'Basis Data Pemblokiran Konten';

  @override
  String get settings_contentBlockingDatabaseKeywords =>
      'iklan, pelacak, pemblokiran konten, ads, trackers, content blocking';

  @override
  String get settings_contentBlockingDatabaseSubtitle =>
      'Gunakan daftar pemblokir GeckoView untuk kategori ETP seperti iklan, analitik, dan pelacak media sosial. Memerlukan mulai ulang aplikasi.';

  @override
  String get settings_bounceTrackingProtectionTitle =>
      'Perlindungan Pelacakan Pantulan';

  @override
  String get settings_bounceTrackingProtectionKeywords =>
      'pelacak pengalihan, bounce tracking, redirect trackers';

  @override
  String get settings_bounceTrackingProtectionSubtitle =>
      'Memblokir pelacak pengalihan yang mengumpulkan data melalui pengalihan URL perantara antarsitus web';

  @override
  String get settings_queryParameterStrippingTitle =>
      'Penghapusan Parameter Kueri';

  @override
  String get settings_queryParameterStrippingKeywords =>
      'utm, parameter pelacakan';

  @override
  String get settings_queryParameterStrippingSubtitle =>
      'Menghapus parameter pelacakan dari URL untuk mencegah pelacakan pengguna lintas situs';

  @override
  String get settings_queryParameterStrippingDisabledLabel => 'Nonaktif';

  @override
  String get settings_queryParameterStrippingEnabledLabel => 'Aktif';

  @override
  String get settings_queryParameterStrippingPrivateOnlyLabel =>
      'Hanya pribadi';

  @override
  String get settings_uBlockFilterListsTileTitle =>
      'Daftar Filter & Pengerasan uBlock';

  @override
  String get settings_uBlockFilterListsTileKeywords =>
      'ublock, filter, filters';

  @override
  String get settings_uBlockFilterListsTileSubtitle =>
      'Kelola daftar filter dan terapkan pengerasan WebLibre';

  @override
  String get settings_fissionEnabledTitle => 'Fission (Isolasi Situs)';

  @override
  String get settings_fissionEnabledKeywords => 'isolasi situs, site isolation';

  @override
  String get settings_fissionEnabledSubtitle =>
      'Mengisolasi setiap situs dalam proses OS terpisah untuk keamanan yang lebih baik. Memerlukan mulai ulang aplikasi.';

  @override
  String get settings_safeBrowsingMalwareTitle =>
      'Perlindungan Malware Safe Browsing';

  @override
  String get settings_safeBrowsingMalwareKeywords =>
      'google safe browsing, malware';

  @override
  String get settings_safeBrowsingMalwareSubtitle =>
      'Peringatkan tentang situs web berbahaya dan unduhan jahat.';

  @override
  String get settings_safeBrowsingPhishingTitle =>
      'Perlindungan Phishing Safe Browsing';

  @override
  String get settings_safeBrowsingPhishingKeywords =>
      'google safe browsing, phishing';

  @override
  String get settings_safeBrowsingPhishingSubtitle =>
      'Peringatkan tentang situs web dan halaman masuk yang menipu.';

  @override
  String get settings_extensionsWebApiTitle => 'Web API Ekstensi';

  @override
  String get settings_extensionsWebApiKeywords => 'api ekstensi, extension api';

  @override
  String get settings_extensionsWebApiSubtitle =>
      'Aktifkan paparan API mozAddonManager untuk konten web dan halaman ekstensi. Memerlukan mulai ulang aplikasi.';

  @override
  String get settings_appOpeningProtectionSectionHeader =>
      'Perlindungan Pembukaan oleh Aplikasi';

  @override
  String get settings_blockAppsOpeningBrowserTitle =>
      'Blokir aplikasi membuka peramban Anda';

  @override
  String get settings_blockAppsOpeningBrowserKeywords =>
      'intent gatekeeper, aplikasi eksternal, external apps';

  @override
  String get settings_blockAppsOpeningBrowserSubtitle =>
      'Tanya sebelum membuka tautan yang dikirim aplikasi lain ke WebLibre.';

  @override
  String get settings_managedAppsSectionHeader => 'Aplikasi yang dikelola';

  @override
  String get settings_managedAppAlwaysAllowedLabel => 'Selalu diizinkan';

  @override
  String get settings_managedAppAlwaysBlockedLabel => 'Selalu diblokir';

  @override
  String get settings_managedAppActionAllow => 'Izinkan';

  @override
  String get settings_managedAppActionBlock => 'Blokir';

  @override
  String get settings_browserLanguagesTileTitle => 'Bahasa Peramban';

  @override
  String get settings_browserLanguagesTileSubtitle =>
      'Atur preferensi bahasa yang diperlihatkan ke situs web';

  @override
  String get settings_fingerprintProtectionTileTitle =>
      'Perlindungan Sidik Jari';

  @override
  String get settings_fingerprintProtectionTileSubtitle =>
      'Kontrol terperinci atas sidik jari peramban';

  @override
  String get settings_resistFingerprintingTileTitle =>
      'Tangkal Pembuatan Sidik Jari';

  @override
  String get settings_resistFingerprintingTileKeywords =>
      'rfp, resist fingerprinting';

  @override
  String get settings_resistFingerprintingTileSubtitle =>
      'Pengerasan perlindungan sidik jari lanjutan';

  @override
  String get settings_lnaEnabledTitle => 'Akses Jaringan Lokal';

  @override
  String get settings_lnaEnabledKeywords => 'lan, jaringan lokal';

  @override
  String get settings_lnaEnabledSubtitle =>
      'Aktifkan pemblokiran akses ke jaringan lokal dan perangkat';

  @override
  String get settings_lnaBlockingTitle => 'Blokir Permintaan Jaringan Lokal';

  @override
  String get settings_lnaBlockingKeywords => 'lan, jaringan lokal';

  @override
  String get settings_lnaBlockingSubtitle =>
      'Blokir permintaan halaman web ke alamat jaringan lokal';

  @override
  String get settings_lnaBlockTrackersTitle => 'Blokir Pelacak Jaringan Lokal';

  @override
  String get settings_lnaBlockTrackersKeywords => 'lan, jaringan lokal';

  @override
  String get settings_lnaBlockTrackersSubtitle =>
      'Blokir pelacak agar tidak mengakses sumber daya jaringan lokal';

  @override
  String get settings_transferTitle => 'Ekspor & Impor';

  @override
  String get settings_transferChangeExportFolder => 'Ubah folder ekspor';

  @override
  String get settings_transferIntro =>
      'Pindahkan pengaturan antarprofil atau antarperangkat, atau lampirkan ke laporan bug. Ini hanya membawa pengaturan — tanpa tab, riwayat, markah, atau info masuk. Untuk memindahkannya, cadangkan seluruh profil.';

  @override
  String get settings_transferDeviceOnlyNote =>
      'Preferensi pencarian web, tata letak beranda dan tab baru, urutan menu, serta pengaya yang disematkan tetap di perangkat ini';

  @override
  String get settings_transferExportSectionTitle => 'Ekspor';

  @override
  String get settings_transferExportSectionSubtitle =>
      'Ekspor bagian yang dipilih ke berkas yang dapat dibaca';

  @override
  String get settings_transferSaveFileButton => 'Simpan berkas';

  @override
  String get settings_transferImportSectionTitle => 'Impor';

  @override
  String get settings_transferImportSectionSubtitle =>
      'Pilih pengaturan yang akan diterapkan setelah membuka berkas';

  @override
  String get settings_transferOpenFileButton => 'Buka berkas';

  @override
  String get settings_transferPasteButton => 'Tempel';

  @override
  String settings_transferExportFolderChanged(String name) {
    return 'Ekspor akan disimpan ke $name';
  }

  @override
  String settings_transferSavedAs(String name) {
    return 'Disimpan sebagai $name';
  }

  @override
  String get settings_transferExportFolderGone =>
      'Folder ekspor sudah tidak ada. Pilih lagi, lalu coba ulang.';

  @override
  String settings_transferSaveFailed(String error) {
    return 'Tidak dapat menyimpan ekspor: $error';
  }

  @override
  String get settings_transferCopiedToClipboard =>
      'Pengaturan disalin ke papan klip';

  @override
  String settings_transferCopyFailed(String error) {
    return 'Tidak dapat menyalin ekspor: $error';
  }

  @override
  String get settings_transferImportNothingApplicable =>
      'Ekspor ini tidak berisi apa pun yang dapat diterapkan oleh versi WebLibre ini.';

  @override
  String get settings_transferImportedSuccess => 'Pengaturan diimpor';

  @override
  String settings_transferImportFailed(String error) {
    return 'Tidak dapat mengimpor pengaturan: $error';
  }

  @override
  String get settings_transferNotASettingsFile =>
      'Berkas tersebut bukan ekspor pengaturan.';

  @override
  String settings_transferReadFileFailed(String error) {
    return 'Tidak dapat membaca berkas: $error';
  }

  @override
  String get settings_transferClipboardEmpty => 'Papan klip kosong.';

  @override
  String settings_transferReadClipboardFailed(String error) {
    return 'Tidak dapat membaca papan klip: $error';
  }

  @override
  String get settings_transferSectionAppSettingsTitle => 'Pengaturan aplikasi';

  @override
  String settings_transferSectionAppSettingsDescription(String torBrand) {
    return 'Pengaturan tampilan, penjelajahan, tab, privasi, $torBrand, dan mesin web';
  }

  @override
  String get settings_transferSectionGeckoPrefsTitle => 'Preferensi Gecko';

  @override
  String get settings_transferSectionGeckoPrefsDescription =>
      'Preferensi mesin lanjutan yang Anda ubah secara manual';

  @override
  String get settings_importErrorNotJson => 'Ini bukan berkas JSON.';

  @override
  String get settings_importErrorNotSettingsExport =>
      'Ini bukan ekspor pengaturan WebLibre.';

  @override
  String get settings_importErrorMissingFormatVersion =>
      'Ekspor tidak menyebutkan versi formatnya.';

  @override
  String settings_importErrorNewerFormatVersion(int version, int supported) {
    return 'Ekspor ini ditulis oleh versi WebLibre yang lebih baru (format $version, versi ini hanya dapat membaca hingga $supported). Perbarui aplikasi, lalu coba lagi.';
  }

  @override
  String get settings_importErrorNoSettings =>
      'Ekspor tidak berisi pengaturan.';

  @override
  String settings_importErrorMalformedSection(String section) {
    return 'Bagian \"$section\" tidak valid.';
  }

  @override
  String settings_importErrorMalformedField(String field) {
    return 'Kolom \"$field\" pada ekspor tidak valid.';
  }

  @override
  String settings_importErrorUnreadablePrefsLine(String section, String line) {
    return 'Bagian \"$section\" memiliki baris yang tidak dapat dibaca WebLibre: \"$line\". Mengimpornya akan mengatur ulang preferensi alih-alih memulihkannya.';
  }

  @override
  String settings_importErrorNotPrefsSnapshot(String section) {
    return 'Bagian \"$section\" bukan snapshot preferensi WebLibre.';
  }

  @override
  String settings_importErrorMissingSchemaVersion(String section) {
    return 'Bagian \"$section\" tidak menyebutkan versi skemanya.';
  }

  @override
  String settings_importErrorUnreadablePref(String section, String pref) {
    return 'Bagian \"$section\" berisi preferensi yang tidak dapat dibaca kembali oleh WebLibre: \"$pref\".';
  }

  @override
  String settings_importErrorNewerSectionSchema(
    String section,
    int version,
    int supported,
  ) {
    return 'Bagian \"$section\" ditulis oleh versi WebLibre yang lebih baru (skema $version, versi ini hanya dapat membaca hingga $supported). Perbarui aplikasi, lalu coba lagi.';
  }

  @override
  String settings_importPartialFailure(String failed, String error) {
    return 'Bagian \"$failed\" terhenti di tengah jalan dan mungkin hanya diterapkan sebagian: $error';
  }

  @override
  String settings_importPartialFailureAfterApplied(
    String applied,
    String failed,
    String error,
  ) {
    return 'Diimpor: $applied. Bagian \"$failed\" kemudian terhenti di tengah jalan dan mungkin hanya diterapkan sebagian: $error';
  }

  @override
  String get settings_webEngineHardeningTitle => 'Pengerasan Mesin Web';

  @override
  String get settings_webEngineHardeningKeywords =>
      'pengerasan, keamanan, hardening';

  @override
  String get settings_webEngineHardeningSearchHint => 'Cari grup pengerasan';

  @override
  String get settings_webEngineHardeningResetAllMenuItem =>
      'Atur ulang semua preferensi';

  @override
  String get settings_webEngineHardeningResetAllDialogTitle =>
      'Atur ulang semua preferensi?';

  @override
  String get settings_webEngineHardeningResetAllDialogContent =>
      'Ini akan mengatur ulang semua preferensi mesin web yang Anda tetapkan ke bawaannya.';

  @override
  String get settings_webEngineHardeningOverviewTitle => 'Ikhtisar';

  @override
  String get settings_webEngineHardeningCompleteTitle => 'Pengerasan Lengkap';

  @override
  String get settings_webEngineHardeningCompleteSubtitle =>
      'Terapkan atau atur ulang semua preferensi pengerasan yang dikelompokkan';

  @override
  String get settings_webEngineHardeningCompleteToggleHint =>
      'Aktifkan atau nonaktifkan semua preferensi pengerasan yang dikelompokkan sekaligus.';

  @override
  String get settings_webEngineHardeningGroupsTitle => 'Grup Pengerasan';

  @override
  String get settings_webEngineHardeningLoadFailedTitle =>
      'Tidak dapat memuat pengaturan preferensi';

  @override
  String get settings_webEngineHardeningGroupSearchHint =>
      'Cari pengaturan pengerasan';

  @override
  String get settings_webEngineHardeningGroupControlsTitle => 'Kontrol Grup';

  @override
  String get settings_webEngineHardeningPreferenceSettingsTitle =>
      'Pengaturan Preferensi';

  @override
  String get settings_webEngineHardeningOptionalBadge => 'Opsional';

  @override
  String get settings_settingsHomeTitle => 'Pengaturan';

  @override
  String get settings_settingsHomeSearchHint => 'Cari semua pengaturan';

  @override
  String get settings_searchTitle => 'Pencarian';

  @override
  String get settings_searchSubtitle =>
      'Penyedia, bang, saran riwayat, dan pencarian di perangkat.';

  @override
  String get settings_defaultSearchProviderTitle => 'Penyedia Pencarian Bawaan';

  @override
  String get settings_defaultSearchProviderKeywords =>
      'mesin pencari, search engine';

  @override
  String get settings_defaultAutocompleteProviderTitle =>
      'Penyedia Pelengkapan Otomatis Bawaan';

  @override
  String get settings_defaultAutocompleteProviderKeywords =>
      'saran, pelengkapan otomatis, suggestions, autocomplete';

  @override
  String get settings_customSearchEnginesTitle => 'Mesin Pencari Kustom';

  @override
  String get settings_customSearchEnginesKeywords =>
      'bang pengguna, penyedia, user bangs, providers';

  @override
  String get settings_customSearchEnginesSubtitle =>
      'Tambahkan dan kelola penyedia pencarian Anda sendiri';

  @override
  String get settings_bangSettingsListTitle => 'Pengaturan Bang';

  @override
  String get settings_bangSettingsListSubtitle =>
      'Kelola repositori bang dan data penggunaan';

  @override
  String get settings_searchHistoryLimitTitle => 'Batas Riwayat Pencarian';

  @override
  String get settings_searchHistoryLimitKeywords =>
      'riwayat, entri, history, entries';

  @override
  String get settings_searchHistoryLimitSubtitle =>
      'Jumlah maksimum pencarian terbaru yang diingat';

  @override
  String get settings_searchHistoryLimitSuffix => 'entri';

  @override
  String get settings_validationEnterValue => 'Silakan masukkan nilai';

  @override
  String get settings_validationEnterValidNumber =>
      'Silakan masukkan angka yang valid';

  @override
  String get settings_validationValueBetween0And100 =>
      'Nilai harus antara 0 dan 100';

  @override
  String get settings_allowClipboardAccessTitle =>
      'Izinkan akses papan klip untuk saran';

  @override
  String get settings_allowClipboardAccessKeywords => 'papan klip, clipboard';

  @override
  String get settings_allowClipboardAccessSubtitle =>
      'Peramban dapat membaca papan klip untuk menyarankan URL';

  @override
  String get settings_historySuggestionsTitle => 'Sarankan dari riwayat';

  @override
  String get settings_historySuggestionsKeywords =>
      'saran riwayat, halaman yang dikunjungi, pelengkapan otomatis, teks bayangan, privasi, autocomplete';

  @override
  String get settings_historySuggestionsSubtitle =>
      'Tampilkan halaman yang pernah dikunjungi dan lengkapi alamat dari riwayat Anda saat mengetik. Menonaktifkan ini tidak menghapus riwayat Anda.';

  @override
  String get settings_privateSearchSuggestionsTitle => 'Saran di tab pribadi';

  @override
  String get settings_privateSearchSuggestionsKeywords =>
      'pribadi, penyamaran, saran pencarian, riwayat, privasi, private, incognito';

  @override
  String get settings_privateSearchSuggestionsSubtitle =>
      'Gunakan penyedia saran dan riwayat Anda saat mengetik di tab pribadi. Yang Anda ketik akan dikirim ke penyedia.';

  @override
  String get settings_acceptSuggestionOnSubmitTitle =>
      'Lengkapi Otomatis saat Enter';

  @override
  String get settings_acceptSuggestionOnSubmitKeywords =>
      'kirim, keyboard, saran, submit, suggestions';

  @override
  String get settings_acceptSuggestionOnSubmitSubtitle =>
      'Terima saran sebaris saat menekan Enter di keyboard';

  @override
  String get settings_popularSitesAutocompleteTitle => 'Saran situs populer';

  @override
  String get settings_popularSitesAutocompleteKeywords =>
      'situs populer, domain, teks bayangan, pelengkapan otomatis, popular sites, autocomplete';

  @override
  String get settings_popularSitesAutocompleteSubtitle =>
      'Lengkapi teks yang diketik dengan domain terkenal jika riwayat dan markah Anda tidak memiliki kecocokan';

  @override
  String get settings_localIndexEnabledTitle =>
      'Aktifkan indeks pencarian lokal';

  @override
  String get settings_localIndexEnabledKeywords =>
      'teks halaman, riwayat, page text, history';

  @override
  String get settings_localIndexEnabledSubtitle =>
      'Indekskan halaman yang dikunjungi secara lokal agar peramban dapat mencari isinya. Metadata kunjungan tetap di mesin; hanya teks halaman yang disimpan di perangkat.';

  @override
  String get settings_indexPrivateTabsTitle => 'Indeks tab pribadi';

  @override
  String get settings_indexPrivateTabsKeywords =>
      'penyamaran, pribadi, incognito';

  @override
  String get settings_indexPrivateTabsSubtitle =>
      'Sertakan halaman yang dibuka di tab pribadi dalam indeks lokal. Nonaktif secara bawaan.';

  @override
  String get settings_clearLocalIndexDialogTitle =>
      'Hapus indeks pencarian lokal?';

  @override
  String get settings_clearLocalIndexDialogContent =>
      'Ini menghapus semua konten halaman yang diindeks secara lokal. Riwayat mesin (metadata kunjungan) tidak terpengaruh.';

  @override
  String get settings_localIndexStatsTitle => 'Halaman terindeks';

  @override
  String get settings_localIndexStatsKeywords =>
      'hapus indeks, statistik, clear index, stats';

  @override
  String settings_localIndexPagesIndexed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count halaman terindeks',
      one: '1 halaman terindeks',
    );
    return '$_temp0';
  }

  @override
  String get settings_searchSectionProvidersTitle => 'Penyedia';

  @override
  String get settings_searchSectionProvidersKeywords =>
      'mesin, mesin pencari, engines';

  @override
  String get settings_searchSectionBangShortcutsTitle => 'Pintasan Bang';

  @override
  String get settings_searchSectionBangShortcutsKeywords => 'bang, bangs';

  @override
  String get settings_searchSectionHistorySuggestionsTitle => 'Riwayat & Saran';

  @override
  String get settings_searchSectionLocalIndexTitle => 'Indeks Pencarian Lokal';

  @override
  String get settings_searchSectionLocalIndexKeywords =>
      'pencarian di perangkat, indeks, on device search, index';

  @override
  String get settings_indexDefaultSearchProviderSubtitle =>
      'Pilih mesin bawaan untuk pencarian';

  @override
  String get settings_indexDefaultAutocompleteProviderSubtitle =>
      'Pilih penyedia saran pencarian';

  @override
  String get settings_indexAcceptSuggestionOnSubmitSubtitle =>
      'Terima saran sebaris saat menekan Enter';

  @override
  String get settings_indexHistorySuggestionsSubtitle =>
      'Sarankan halaman yang pernah dikunjungi saat mengetik';

  @override
  String get settings_indexPrivateSearchSuggestionsSubtitle =>
      'Gunakan saran dan riwayat di tab pribadi';

  @override
  String get settings_indexPopularSitesAutocompleteSubtitle =>
      'Lengkapi teks yang diketik dengan domain terkenal';

  @override
  String get settings_indexLocalIndexEnabledSubtitle =>
      'Indekskan halaman yang dikunjungi secara lokal untuk pencarian konten';

  @override
  String get settings_indexIndexPrivateTabsSubtitle =>
      'Sertakan tab pribadi dalam indeks lokal';

  @override
  String get settings_indexLocalIndexStatsSubtitle =>
      'Lihat dan hapus indeks lokal';

  @override
  String get settings_webContentTitle => 'Konten Web';

  @override
  String get settings_webContentSubtitle =>
      'Rendering teks, mode pembaca, PDF, dan fitur AI lokal.';

  @override
  String get settings_webFontsTitle => 'Font Web';

  @override
  String get settings_webFontsKeywords => 'font, huruf, fonts';

  @override
  String get settings_webFontsSubtitle =>
      'Izinkan situs web menggunakan font kustom';

  @override
  String get settings_automaticFontSizeTitle => 'Ukuran Font Otomatis';

  @override
  String get settings_automaticFontSizeKeywords => 'ukuran teks, text size';

  @override
  String get settings_automaticFontSizeSubtitle =>
      'Sesuaikan ukuran font secara otomatis berdasarkan pengaturan sistem. Nonaktifkan untuk mengatur faktor ukuran font dan pembesaran font secara manual.';

  @override
  String get settings_fontSizeFactorTitle => 'Faktor Ukuran Font';

  @override
  String get settings_fontSizeFactorKeywords => 'zoom, teks, text';

  @override
  String get settings_fontSizeFactorSubtitle =>
      'Skalakan ukuran teks halaman web';

  @override
  String get settings_disabledWhileAutomaticFontSize =>
      'Dinonaktifkan selama ukuran font otomatis aktif';

  @override
  String get settings_fontInflationTitle => 'Pembesaran Font';

  @override
  String get settings_fontInflationKeywords =>
      'keterbacaan, readability, font inflation';

  @override
  String get settings_fontInflationSubtitle =>
      'Perbesar teks pada halaman yang tidak memiliki meta tag viewport seluler';

  @override
  String get settings_inputAutoZoomTitle => 'Zoom Otomatis pada Input';

  @override
  String get settings_inputAutoZoomKeywords => 'formulir, forms';

  @override
  String get settings_inputAutoZoomSubtitle =>
      'Perbesar otomatis saat memfokuskan kolom input teks';

  @override
  String get settings_forceUserScalableTitle => 'Zoom di Semua Situs Web';

  @override
  String get settings_forceUserScalableKeywords =>
      'cubit, aksesibilitas, pinch, accessibility';

  @override
  String get settings_forceUserScalableSubtitle =>
      'Izinkan cubit dan zoom, bahkan di situs web yang mencegah gestur ini';

  @override
  String get settings_pdfViewerTitle => 'Penampil PDF Bawaan';

  @override
  String get settings_pdfViewerKeywords => 'pdf';

  @override
  String get settings_pdfViewerSubtitle =>
      'Buka berkas PDF langsung di peramban tanpa mengunduh';

  @override
  String get settings_enableReaderModeTitle => 'Aktifkan Mode Pembaca';

  @override
  String get settings_enableReaderModeKeywords =>
      'pembaca, keterbacaan, reader, readability';

  @override
  String get settings_enableReaderModeSubtitle =>
      'Menambahkan alat opsional ke bilah aplikasi peramban yang menyederhanakan halaman web dengan menghapus iklan, bilah samping, dan elemen lain yang tidak penting.';

  @override
  String get settings_enforceReaderModeTitle => 'Paksa Mode Pembaca';

  @override
  String get settings_enforceReaderModeKeywords => 'pembaca, reader';

  @override
  String get settings_enforceReaderModeSubtitle =>
      'Abaikan skor keterbacaan situs dan selalu tampilkan Mode Pembaca, bahkan di situs yang mungkin tidak mendukungnya.';

  @override
  String get settings_onDeviceAiTitle => 'AI di perangkat';

  @override
  String get settings_onDeviceAiKeywords =>
      'ai lokal, saran, local ai, suggestions';

  @override
  String get settings_onDeviceAiSubtitle =>
      'Fitur di perangkat seperti menyarankan kontainer untuk tab terbuka Anda beserta namanya';

  @override
  String get settings_webContentSectionDisplayTitle => 'Tampilan';

  @override
  String get settings_webContentSectionContentFeaturesTitle => 'Fitur Konten';

  @override
  String get settings_indexAutomaticFontSizeSubtitle =>
      'Sesuaikan ukuran font berdasarkan pengaturan sistem';

  @override
  String get settings_indexFontInflationSubtitle =>
      'Perbesar teks pada halaman tanpa viewport seluler';

  @override
  String get settings_indexInputAutoZoomSubtitle =>
      'Perbesar otomatis saat memfokuskan input teks';

  @override
  String get settings_indexPdfViewerSubtitle =>
      'Buka berkas PDF langsung di peramban';

  @override
  String get settings_indexEnableReaderModeSubtitle =>
      'Ekstrak dan sederhanakan halaman agar mudah dibaca';

  @override
  String get settings_indexEnforceReaderModeSubtitle =>
      'Selalu tampilkan kemampuan Mode Pembaca';

  @override
  String get settings_indexOnDeviceAiSubtitle =>
      'Fitur AI lokal termasuk saran topik dan tab';

  @override
  String get settings_ublockListsTitle => 'Daftar Filter uBlock';

  @override
  String get settings_ublockListsSearchHint =>
      'Cari daftar, grup, dan URL eksternal';

  @override
  String get settings_ublockSectionManagement => 'Pengelolaan';

  @override
  String get settings_ublockSectionQuickActions => 'Tindakan Cepat';

  @override
  String get settings_ublockSectionFilterLists => 'Daftar Filter';

  @override
  String get settings_ublockSectionExternalLists => 'Daftar Eksternal';

  @override
  String get settings_actionApply => 'Terapkan';

  @override
  String get settings_ublockResetDialogTitle => 'Atur ulang ke bawaan?';

  @override
  String get settings_ublockResetDialogMessage =>
      'Ini akan mengembalikan uBlock Origin ke konfigurasi daftar filter bawaannya dan menghapus semua daftar eksternal yang Anda tambahkan.';

  @override
  String get settings_ublockApplyHardeningsDialogTitle =>
      'Terapkan Pengerasan WebLibre?';

  @override
  String get settings_ublockApplyHardeningsDialogMessage =>
      'Ini akan mengaktifkan sekumpulan daftar filter tambahan pilihan dan menambahkan daftar pemendek URL yang sah sebagai daftar eksternal.';

  @override
  String get settings_ublockInfoBannerMessage =>
      'Perubahan pada daftar filter uBlock Origin memerlukan mulai ulang aplikasi agar berlaku. Karena cache, beberapa perubahan mungkin memerlukan beberapa menit dan mulai ulang tambahan agar diterapkan sepenuhnya.';

  @override
  String settings_ublockLoadFailed(String error) {
    return 'Gagal memuat aset daftar filter: $error';
  }

  @override
  String get settings_ublockQuickResetTitle => 'Atur ulang ke bawaan';

  @override
  String get settings_ublockQuickResetSubtitle =>
      'Kembalikan konfigurasi daftar filter bawaan uBlock Origin.';

  @override
  String get settings_ublockQuickApplyHardeningsTitle =>
      'Terapkan Pengerasan WebLibre';

  @override
  String get settings_ublockQuickApplyHardeningsSubtitle =>
      'Aktifkan sekumpulan daftar filter tambahan pilihan.';

  @override
  String get settings_ublockManageTitle => 'Kelola dengan WebLibre';

  @override
  String get settings_ublockManageSubtitle =>
      'WebLibre mengatur daftar filter uBlock Origin yang aktif pada saat peramban dimulai berikutnya.';

  @override
  String get settings_ublockManageHint =>
      'Saat pengelolaan diaktifkan, daftar dasar umum uBO digunakan dan \'My filters\' tetap dipertahankan.';

  @override
  String get settings_ublockAutoSelectTitle => 'Pilih bahasa otomatis';

  @override
  String get settings_ublockAutoSelectSubtitle =>
      'Aktifkan daftar filter regional yang sesuai dengan bahasa perangkat Anda.';

  @override
  String get settings_ublockAutoSelectedTooltip =>
      'Dipilih otomatis untuk bahasa Anda';

  @override
  String get settings_ublockDefaultOnTooltip => 'Aktif secara bawaan';

  @override
  String get settings_ublockVisitSupportTooltip => 'Kunjungi halaman dukungan';

  @override
  String get settings_ublockExternalListsHint =>
      'URL mentah diteruskan ke uBlock Origin sebagai daftar eksternal. Deskripsi hanya ditampilkan di sini, di WebLibre.';

  @override
  String get settings_ublockNoExternalLists =>
      'Belum ada daftar eksternal yang dikonfigurasi.';

  @override
  String settings_ublockNoExternalListsMatch(String query) {
    return 'Tidak ada daftar eksternal yang cocok dengan \"$query\".';
  }

  @override
  String get settings_ublockAddExternalListButton => 'Tambah daftar eksternal';

  @override
  String get settings_ublockEditListDialogTitle =>
      'Edit daftar filter eksternal';

  @override
  String get settings_ublockAddListDialogTitle =>
      'Tambah daftar filter eksternal';

  @override
  String get settings_ublockListUrlLabel => 'URL Daftar';

  @override
  String get settings_ublockListUrlAlreadyAdded => 'Sudah ditambahkan';

  @override
  String get settings_ublockDescriptionLabel => 'Deskripsi (opsional)';

  @override
  String get settings_ublockDescriptionHint => 'mis. Gangguan — penulis';

  @override
  String get settings_ublockGroupDefault => 'Bawaan';

  @override
  String get settings_ublockGroupAds => 'Iklan';

  @override
  String get settings_ublockGroupPrivacy => 'Privasi';

  @override
  String get settings_ublockGroupMalware => 'Malware';

  @override
  String get settings_ublockGroupAnnoyances => 'Gangguan';

  @override
  String get settings_ublockGroupMultipurpose => 'Serbaguna';

  @override
  String get settings_ublockGroupRegions => 'Wilayah';

  @override
  String get settings_categoryGeneralTitle => 'Umum';

  @override
  String get settings_categoryGeneralKeywords =>
      'tema, zoom ui, peramban bawaan, theme, default browser';

  @override
  String get settings_categoryGeneralSubtitle => 'Tampilan, unduhan';

  @override
  String get settings_categoryBrowsingTitle => 'Penjelajahan';

  @override
  String get settings_categoryBrowsingKeywords =>
      'tab, small web, pembersih url, pengurai tautan pendek, url cleaner, unshortener';

  @override
  String get settings_categoryBrowsingSubtitle =>
      'Tab, navigasi, tautan eksternal';

  @override
  String get settings_categoryHomeNewTabTitle => 'Beranda & Tab Baru';

  @override
  String get settings_categoryHomeNewTabKeywords =>
      'beranda, tab baru, halaman awal, bagian, pintasan, situs teratas, kutipan, wallpaper, latar belakang, home, new tab';

  @override
  String get settings_categoryHomeNewTabSubtitle =>
      'Yang ditampilkan di beranda dan halaman tab baru';

  @override
  String get settings_categoryGesturesTitle => 'Gestur';

  @override
  String get settings_categoryGesturesKeywords =>
      'gestur, usap, goresan, bilah tab, tekan lama, cubit, gesture, swipe';

  @override
  String get settings_categoryGesturesSubtitle =>
      'Usapan pada bilah tab dan tab, gestur gambar';

  @override
  String get settings_categoryKeyboardShortcutsTitle => 'Pintasan Keyboard';

  @override
  String get settings_categoryKeyboardShortcutsKeywords =>
      'keyboard, pintasan, tombol pintas, pemetaan tombol, shortcut, hotkey';

  @override
  String get settings_categoryKeyboardShortcutsSubtitle =>
      'Tombol keyboard fisik untuk tindakan peramban';

  @override
  String get settings_categoryToolbarLayoutTitle => 'Bilah Alat & Tata Letak';

  @override
  String get settings_categoryToolbarLayoutKeywords =>
      'bilah alat kontekstual, pengalih tab cepat, toolbar';

  @override
  String get settings_categoryToolbarLayoutSubtitle =>
      'Bilah tab, bilah alat, pengalih cepat, tampilan tab';

  @override
  String get settings_categoryWebContentTitle => 'Konten Web';

  @override
  String get settings_categoryWebContentKeywords =>
      'mode pembaca, pdf, font, reader mode';

  @override
  String get settings_categoryWebContentSubtitle =>
      'Tampilan halaman, PDF, mode pembaca, AI';

  @override
  String get settings_categoryNotificationsTitle => 'Notifikasi';

  @override
  String get settings_categoryNotificationsKeywords =>
      'push, unifiedpush, ntfy, distributor, notifikasi';

  @override
  String get settings_categoryNotificationsSubtitle =>
      'Pengiriman web push, distributor, langganan situs';

  @override
  String get settings_categorySearchTitle => 'Pencarian';

  @override
  String get settings_categorySearchKeywords =>
      'bang, saran, indeks pencarian lokal, bangs, suggestions';

  @override
  String get settings_categorySearchSubtitle =>
      'Penyedia, bang, riwayat pencarian';

  @override
  String get settings_categoryPrivacySecurityTitle => 'Privasi & Keamanan';

  @override
  String get settings_categoryPrivacySecurityKeywords =>
      'sidik jari, https, doh, safe browsing, perlindungan jaringan, fingerprinting';

  @override
  String get settings_categoryPrivacySecuritySubtitle =>
      'Perlindungan pelacakan, penghapusan data';

  @override
  String get settings_categoryProxyTitle => 'Proksi';

  @override
  String get settings_categoryProxyKeywords =>
      'proksi, proxy, sing-box, socks, vpn, wireguard, perutean, routing, tor, kontainer';

  @override
  String get settings_categoryProxySubtitle => 'Koneksi dan perutean';

  @override
  String get settings_categoryExtensionsTitle => 'Ekstensi';

  @override
  String get settings_categoryExtensionsKeywords =>
      'pengaya, ekstensi tanpa tanda tangan, addons, unsigned extensions';

  @override
  String get settings_categoryExtensionsSubtitle =>
      'Pasang dan kelola sumber ekstensi';

  @override
  String get settings_categoryAccountTitle => 'Akun WebLibre';

  @override
  String get settings_categoryAccountKeywords =>
      'akun, langganan, account, subscription';

  @override
  String get settings_categoryAccountSubtitle =>
      'Masuk, sinkronisasi pengaturan';

  @override
  String get settings_categorySyncTitle => 'Firefox Sync';

  @override
  String get settings_categorySyncKeywords =>
      'pasangkan, nama perangkat, mesin, pair, device name';

  @override
  String get settings_categorySyncSubtitle =>
      'Akun, sinkronkan sekarang, pilihan data';

  @override
  String get settings_categoryAdvancedTitle => 'Lanjutan';

  @override
  String get settings_categoryAdvancedKeywords =>
      'eksperimental, log galat, javascript, experimental, error logs';

  @override
  String get settings_categoryAdvancedSubtitle =>
      'JavaScript, user agent, debugging';

  @override
  String get settings_categoryGroupBrowserTitle => 'Peramban';

  @override
  String get settings_categoryGroupServicesAdvancedTitle =>
      'Layanan & Lanjutan';

  @override
  String get settings_privacySectionTrackingProtectionTitle =>
      'Perlindungan Pelacakan';

  @override
  String get settings_privacySectionTrackingProtectionKeywords =>
      'privasi, pelacakan, privacy';

  @override
  String get settings_indexEnhancedTrackingProtectionSubtitle =>
      'Pilih seberapa ketat pelacak diblokir';

  @override
  String get settings_indexContentBlockingDatabaseSubtitle =>
      'Gunakan daftar pemblokir GeckoView untuk kategori ETP';

  @override
  String get settings_indexBounceTrackingProtectionSubtitle =>
      'Hapus status pelacakan yang ditinggalkan pelacak berbasis pengalihan';

  @override
  String get settings_indexQueryParameterStrippingSubtitle =>
      'Hapus parameter pelacakan dari URL';

  @override
  String get settings_privacySectionFingerprintingTitle => 'Sidik Jari';

  @override
  String get settings_indexBrowserLanguagesSubtitle =>
      'Pilih bahasa yang dapat dilihat situs web';

  @override
  String get settings_privacySectionConnectionSecurityTitle =>
      'Keamanan Koneksi';

  @override
  String get settings_indexHttpsOnlyModeSubtitle =>
      'Utamakan HTTPS dan blokir koneksi yang tidak aman';

  @override
  String get settings_indexDnsOverHttpsTitle => 'DNS over HTTPS';

  @override
  String get settings_indexDnsOverHttpsKeywords => 'doh, dns';

  @override
  String get settings_indexDnsOverHttpsSubtitle => 'Enkripsi pencarian DNS';

  @override
  String get settings_privacySectionNetworkProtectionTitle =>
      'Perlindungan Jaringan';

  @override
  String get settings_indexLnaBlockingSubtitle =>
      'Blokir permintaan ke perangkat dan layanan jaringan lokal';

  @override
  String get settings_indexLnaBlockTrackersSubtitle =>
      'Blokir permintaan jaringan lokal yang menyerupai pelacak';

  @override
  String get settings_privacySectionSignalsModesTitle =>
      'Sinyal & Mode Privasi';

  @override
  String get settings_indexScreenshotProtectionSubtitle =>
      'Cegah konten aplikasi muncul di tangkapan layar';

  @override
  String get settings_indexAllowPrivateTabScreenshotsSubtitle =>
      'Izinkan sistem menangkap tab pribadi';

  @override
  String get settings_indexGlobalPrivacyControlSubtitle =>
      'Kirim sinyal preferensi privasi ke situs web';

  @override
  String get settings_privacySectionAppOpeningProtectionTitle =>
      'Perlindungan Pembukaan oleh Aplikasi';

  @override
  String get settings_indexAppOpeningProtectionSubtitle =>
      'Atur aplikasi mana yang boleh membuka WebLibre secara langsung';

  @override
  String get settings_privacySectionDataManagementTitle => 'Pengelolaan Data';

  @override
  String get settings_indexDeleteBrowsingDataSubtitle =>
      'Hapus riwayat, kuki, dan data penjelajahan lainnya';

  @override
  String get settings_indexAutoClearHistorySubtitle =>
      'Hapus riwayat secara otomatis setelah jangka waktu yang dipilih';

  @override
  String get settings_indexAutoClearUnassignedTabsSubtitle =>
      'Tutup otomatis tab yang tidak ditetapkan ke kontainer';

  @override
  String get settings_privacySectionSafeBrowsingTitle => 'Google Safe Browsing';

  @override
  String get settings_indexSafeBrowsingMalwareSubtitle =>
      'Peringatkan tentang malware dan unduhan berbahaya';

  @override
  String get settings_indexSafeBrowsingPhishingSubtitle =>
      'Peringatkan tentang situs web dan halaman masuk yang menipu';

  @override
  String get settings_privacySectionAdvancedSecurityTitle =>
      'Keamanan Lanjutan';

  @override
  String get settings_indexWebEngineHardeningSubtitle =>
      'Perketat perilaku dan bawaan mesin peramban';

  @override
  String get settings_indexFissionEnabledSubtitle =>
      'Gunakan isolasi situs yang lebih kuat antar-asal';

  @override
  String get settings_indexExtensionsWebAPIEnabledSubtitle =>
      'Izinkan ekstensi memaparkan API web ke halaman';

  @override
  String get settings_proxySectionTitle => 'Proksi';

  @override
  String get settings_indexProxyLogsSubtitle =>
      'Baca log proksi dan atur seberapa banyak yang dicatat';

  @override
  String get settings_saveAndUse => 'Simpan dan gunakan';

  @override
  String get settings_replace => 'Ganti';

  @override
  String get settings_later => 'Nanti';

  @override
  String get settings_restartNow => 'Mulai Ulang Sekarang';

  @override
  String get settings_sync => 'Sinkronkan';

  @override
  String get settings_chooseSearchProvider => 'Pilih penyedia pencarian';

  @override
  String get settings_entriesLabel => 'Entri';

  @override
  String get settings_lastSyncLabel => 'Sinkronisasi Terakhir';

  @override
  String get settings_notAvailable => 'T/A';

  @override
  String get settings_protectionLevelTitle => 'Tingkat Perlindungan';

  @override
  String get settings_protectionLevelDescription =>
      'Domain Name System (DNS) over HTTPS mengirim permintaan nama domain melalui koneksi terenkripsi, sehingga melindunginya dan mempersulit orang lain melihat situs web mana yang akan Anda kunjungi.';

  @override
  String get settings_defaultProtectionTitle => 'Perlindungan Bawaan';

  @override
  String get settings_defaultProtectionSubtitle =>
      'DoH hanya digunakan jika DNS bawaan gagal';

  @override
  String get settings_increasedProtectionTitle => 'Perlindungan Ditingkatkan';

  @override
  String get settings_increasedProtectionSubtitle =>
      'DoH diutamakan, DNS bawaan sebagai cadangan';

  @override
  String get settings_maxProtectionTitle => 'Perlindungan Maksimum';

  @override
  String get settings_maxProtectionSubtitle => 'Hanya DoH, tanpa cadangan';

  @override
  String get settings_protectionOffTitle => 'Nonaktif';

  @override
  String get settings_protectionOffSubtitle =>
      'Gunakan resolver DNS bawaan Anda';

  @override
  String get settings_dohProviderTitle => 'Penyedia DoH';

  @override
  String get settings_yourResolvers => 'Resolver Anda';

  @override
  String get settings_addCustomResolver => 'Tambah resolver kustom';

  @override
  String get settings_editCustomResolverTitle => 'Edit resolver kustom';

  @override
  String get settings_resolverUrlLabel => 'URL Resolver';

  @override
  String get settings_alreadyBuiltInProvider =>
      'Sudah tersedia sebagai penyedia bawaan';

  @override
  String get settings_alreadyAdded => 'Sudah ditambahkan';

  @override
  String get settings_resolverNameLabel => 'Nama (opsional)';

  @override
  String get settings_resolverNameHint => 'mis. dnsforge (adblock)';

  @override
  String get settings_searchHint => 'Cari pengaturan';

  @override
  String get settings_noSettingsAvailable =>
      'Tidak ada pengaturan yang tersedia.';

  @override
  String settings_noSettingsMatch(String query) {
    return 'Tidak ada pengaturan yang cocok dengan \"$query\".';
  }

  @override
  String get settings_stringListEditorEmpty => 'Belum ada yang ditambahkan.';

  @override
  String get settings_customizeMenu => 'Sesuaikan Menu';

  @override
  String get settings_customizeMenuKeywords =>
      'bagian, baris, urutkan ulang, sections, rows, reorder';

  @override
  String get settings_customizeMenuSubtitle =>
      'Pilih dan urutkan bagian dan baris menu titik tiga';

  @override
  String get settings_tabBarPositionTitle => 'Posisi Bilah Tab';

  @override
  String get settings_tabBarPositionKeywords => 'atas, bawah, top, bottom';

  @override
  String settings_currentlyResolvesTo(String text, String value) {
    return '$text (saat ini: $value)';
  }

  @override
  String get settings_tabBarPositionAutoLabel => 'Otomatis';

  @override
  String get settings_tabBarPositionTopLabel => 'Atas';

  @override
  String get settings_tabBarPositionBottomLabel => 'Bawah';

  @override
  String get settings_tabBarPositionLeftLabel => 'Kiri';

  @override
  String get settings_tabBarPositionRightLabel => 'Kanan';

  @override
  String get settings_tabBarPositionAutoDescription =>
      'Rel samping di layar besar, bilah bawah di ponsel';

  @override
  String get settings_tabBarPositionTopDescription =>
      'Bilah tab tetap tanpa sembunyi otomatis';

  @override
  String get settings_tabBarPositionBottomDescription =>
      'Bilah tab dengan dukungan sembunyi otomatis';

  @override
  String get settings_tabBarPositionLeftDescription =>
      'Rel samping vertikal, usap untuk menyembunyikan';

  @override
  String get settings_tabBarPositionRightDescription =>
      'Rel samping vertikal, usap untuk menyembunyikan';

  @override
  String get settings_tabBarStyleTitle => 'Gaya Bilah Tab';

  @override
  String get settings_tabBarStyleKeywords =>
      'tata letak, ringkas, layout, compact';

  @override
  String get settings_withTitleOption => 'Dengan Judul';

  @override
  String get settings_withTitleDescription =>
      'Menampilkan judul halaman dan jejak URL';

  @override
  String get settings_compactOption => 'Ringkas';

  @override
  String get settings_compactDescription =>
      'Kapsul URL di tengah tanpa judul halaman';

  @override
  String get settings_showContextualToolbarTitle =>
      'Tampilkan Bilah Alat Kontekstual';

  @override
  String get settings_showContextualToolbarKeywords =>
      'bilah alat bawah, bottom toolbar';

  @override
  String get settings_showContextualToolbarSubtitle =>
      'Tampilkan bilah alat bawah tambahan untuk navigasi dan tindakan';

  @override
  String get settings_customizeToolbarButtons => 'Sesuaikan Tombol Bilah Alat';

  @override
  String get settings_customizeToolbarButtonsKeywords => 'tombol, buttons';

  @override
  String get settings_customizeSwitcherButtons => 'Sesuaikan Tombol Pengalih';

  @override
  String get settings_customizeSwitcherButtonsKeywords =>
      'tombol, tab baru, tindakan, buttons, new tab, actions';

  @override
  String get settings_customizeSwitcherButtonsSubtitle =>
      'Tombol tindakan yang disematkan di ujung bilah pengalih (terpisah dari bilah alat kontekstual)';

  @override
  String get settings_tabStackingTitle => 'Penumpukan Tab';

  @override
  String get settings_tabStackingKeywords =>
      'tab terbaru, baru dipakai, tab kontainer, akordeon, dua tingkat, baris, penumpukan, grup tab, tumpukan tab, pohon tab, nonaktif, accordion, stacking, tab groups';

  @override
  String get settings_tabStackingSubtitle =>
      'Cara bilah pengalih tab cepat menata tabnya';

  @override
  String get settings_recentlyUsedTabsOption => 'Tab Terakhir Dipakai';

  @override
  String get settings_recentlyUsedTabsDescription =>
      'Tab yang terakhir dipakai di semua kontainer';

  @override
  String get settings_containerTabsOption => 'Tab Kontainer';

  @override
  String get settings_containerTabsDescription =>
      'Tab berurutan dari kontainer yang dipilih';

  @override
  String get settings_accordionOption => 'Akordeon';

  @override
  String get settings_accordionDescription =>
      'Semua kontainer sebagai chip, dengan tab kontainer yang dipilih dibentangkan sebaris';

  @override
  String get settings_twoRowsOption => 'Dua Baris';

  @override
  String get settings_twoRowsDescription =>
      'Tab kontainer yang dipilih di atas, tab yang terakhir dipakai di bawah';

  @override
  String get settings_tabGroupsOption => 'Grup Tab';

  @override
  String get settings_tabGroupsDescription =>
      'Satu chip per tab beserta tab yang dibuka darinya, dengan tab grup saat ini di baris atasnya';

  @override
  String get settings_tabStackingFallbackAccordion =>
      'Membutuhkan ruang lebih besar daripada jendela atau panel samping ini, jadi Akordeon ditampilkan untuk sementara';

  @override
  String get settings_tabStackingFallbackContainerTabs =>
      'Membutuhkan ruang lebih besar daripada jendela atau panel samping ini, jadi Tab Kontainer ditampilkan untuk sementara';

  @override
  String get settings_disabledOption => 'Nonaktif';

  @override
  String get settings_disabledDescription =>
      'Sembunyikan bilah pengalih tab cepat';

  @override
  String get settings_closeButtonsTitle => 'Tombol Tutup pada Chip Tab';

  @override
  String get settings_closeButtonsKeywords =>
      'tutup, tombol x, tab aktif, close, active tab';

  @override
  String get settings_closeButtonsSubtitle =>
      'Chip pengalih mana yang menampilkan tombol tutup';

  @override
  String get settings_activeTabOnlyOption => 'Hanya Tab Aktif';

  @override
  String get settings_activeTabOnlyDescription =>
      'Hanya chip tab yang sedang terbuka';

  @override
  String get settings_allTabsOption => 'Semua Tab';

  @override
  String get settings_allTabsDescription => 'Setiap chip di bilah';

  @override
  String get settings_neverOption => 'Jangan pernah';

  @override
  String get settings_neverCloseDescription =>
      'Tanpa tombol tutup; tutup tab dari menu tekan lama atau dengan mengusap bilah';

  @override
  String get settings_titleWidthTitle => 'Lebar Judul di Pengalih Tab Cepat';

  @override
  String get settings_titleWidthKeywords =>
      'lebar, judul, chip, panjang, width, title';

  @override
  String get settings_titleWidthSubtitle =>
      'Lebar maksimum judul tab pada chip pengalih';

  @override
  String get settings_historyFallbackTitle =>
      'Riwayat sebagai Cadangan di Pengalih Tab Cepat';

  @override
  String get settings_historyFallbackKeywords => 'saran, riwayat, suggestions';

  @override
  String get settings_historyFallbackSubtitle =>
      'Gunakan saran dari riwayat penjelajahan jika tidak ada chip tab';

  @override
  String get settings_showTitlesTitle =>
      'Tampilkan Judul di Pengalih Tab Cepat';

  @override
  String get settings_showTitlesKeywords => 'judul halaman, page titles';

  @override
  String get settings_showTitlesSubtitle =>
      'Tampilkan judul tab di samping ikon pada bilah pengalih tab cepat';

  @override
  String get settings_hierarchyDepthTitle =>
      'Kedalaman Hierarki di Pengalih Tab Cepat';

  @override
  String get settings_hierarchyDepthKeywords =>
      'hierarki, bersarang, kedalaman, pohon, chevron, hierarchy, nesting';

  @override
  String get settings_hierarchyDepthSubtitle =>
      'Berapa banyak chevron bersarang yang ditampilkan pada chip pengalih sebelum diringkas menjadi lencana jumlah (0 menyembunyikan indikator)';

  @override
  String settings_hierarchyGlyphsLabel(int glyphs) {
    String _temp0 = intl.Intl.pluralLogic(
      glyphs,
      locale: localeName,
      other: '$glyphs tingkat',
      one: '1 tingkat',
      zero: 'Nonaktif',
    );
    return '$_temp0';
  }

  @override
  String get settings_autoHideTabBarTitle => 'Sembunyikan Bilah Tab Otomatis';

  @override
  String get settings_autoHideTabBarKeywords => 'gulir, scroll';

  @override
  String get settings_autoHideTabBarSubtitle =>
      'Sembunyikan bilah tab saat menggulir';

  @override
  String get settings_autoHideSidePanelTitle =>
      'Sembunyikan Panel Samping Otomatis';

  @override
  String get settings_autoHideSidePanelKeywords =>
      'mouse, kursor, arahkan, rel, bilah samping, cursor, hover, sidebar';

  @override
  String get settings_autoHideSidePanelSubtitle =>
      'Sembunyikan bilah tab kiri atau kanan dan munculkan saat mouse mencapai tepi tersebut. Ini hanya berfungsi selama mouse atau trackpad digunakan; menyentuh layar akan mengembalikan panel ke samping halaman.';

  @override
  String get settings_bottomSheetTabViewTitle => 'Tampilan Tab Lembar Bawah';

  @override
  String get settings_bottomSheetTabViewKeywords => 'lembar, sheet';

  @override
  String get settings_bottomSheetTabViewSubtitle =>
      'Tampilkan tab di lembar bawah, bukan layar penuh';

  @override
  String get settings_longPressUrlCopyTitle => 'Tekan Lama URL untuk Menyalin';

  @override
  String get settings_longPressUrlCopyKeywords => 'salin url, copy url';

  @override
  String get settings_longPressUrlCopySubtitle =>
      'Salin URL halaman ke papan klip saat menekan lama bilah alamat';

  @override
  String get settings_showFaviconsTitle =>
      'Tampilkan Favicon di Tampilan Daftar';

  @override
  String get settings_showFaviconsKeywords => 'ikon, favicon, icons';

  @override
  String get settings_showFaviconsSubtitle =>
      'Tampilkan ikon situs web alih-alih gambar mini halaman di tampilan daftar tab';

  @override
  String get settings_previewPageContent => 'Konten Halaman';

  @override
  String get settings_previewPageTitle => 'Pratinjau WebLibre';

  @override
  String get settings_previewTabNews => 'Berita';

  @override
  String get settings_previewTabPrivate => 'Pribadi';

  @override
  String get settings_previewTabBank => 'Bank';

  @override
  String get settings_previewTabSearch => 'Cari';

  @override
  String get settings_livePreviewTitle => 'Pratinjau Langsung';

  @override
  String get settings_livePreviewSubtitle =>
      'Mencerminkan pengaturan bilah alat dan tata letak Anda saat ini';

  @override
  String get settings_deleteAllExceptionsTitle => 'Hapus Semua Pengecualian?';

  @override
  String get settings_deleteAllExceptionsContent =>
      'Ini akan mengaktifkan kembali perlindungan pelacakan untuk semua situs pengecualian.';

  @override
  String get settings_entryCopied => 'Entri disalin';

  @override
  String get settings_messageLabel => 'Pesan:';

  @override
  String get settings_errorLabel => 'Galat:';

  @override
  String get settings_stackTraceLabel => 'Stack Trace:';

  @override
  String get settings_importSettingsTitle => 'Impor pengaturan';

  @override
  String get settings_importSettingsDescription =>
      'Bagian yang Anda pilih akan menggantikan yang dimiliki profil ini sekarang. Yang tidak dicentang tetap seperti semula.';

  @override
  String settings_unreadableSections(int count, String sections) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count bagian dalam berkas ini ($sections) tidak dapat dibaca oleh versi WebLibre ini dan akan dilewati.',
      one:
          '1 bagian dalam berkas ini ($sections) tidak dapat dibaca oleh versi WebLibre ini dan akan dilewati.',
    );
    return '$_temp0';
  }

  @override
  String get settings_exportedLabel => 'Diekspor';

  @override
  String get settings_appVersionLabel => 'Versi aplikasi';

  @override
  String get settings_credentialsNotCarried =>
      'Ekspor tidak menyertakan kredensial tersimpan atau gambar wallpaper. Perangkat ini tetap memakai miliknya sendiri.';

  @override
  String get settings_geckoPrefsRestartNote =>
      'Beberapa preferensi mesin baru berlaku setelah peramban dimulai ulang.';

  @override
  String get settings_userAgentChangedTitle => 'User Agent Diubah';

  @override
  String get settings_userAgentChangedContent =>
      'Peramban perlu dimulai ulang agar user agent baru berlaku.';

  @override
  String get settings_tabBarSectionTitle => 'Bilah Tab';

  @override
  String get settings_contextualToolbarSectionTitle => 'Bilah Alat Kontekstual';

  @override
  String get settings_quickTabSwitcherSectionTitle => 'Pengalih Tab Cepat';

  @override
  String get settings_tabViewSectionTitle => 'Tampilan Tab';

  @override
  String get settings_menuSectionTitle => 'Menu';

  @override
  String get settings_menuSectionKeywords =>
      'titik tiga, menu lainnya, three dot, overflow';

  @override
  String get settings_indexTabBarPositionSubtitle =>
      'Pilih apakah bilah tab berada di atas, di bawah, atau di samping';

  @override
  String get settings_indexTabBarStyleSubtitle =>
      'Pilih antara tata letak dengan judul dan ringkas';

  @override
  String get settings_indexAutoHideTabBarSubtitle =>
      'Sembunyikan bilah tab saat menggulir';

  @override
  String get settings_indexAutoHideSidePanelSubtitle =>
      'Munculkan panel samping saat mouse mencapai tepinya';

  @override
  String get settings_indexLongPressUrlCopySubtitle =>
      'Salin URL saat ini dari bilah tab';

  @override
  String get settings_indexShowContextualToolbarSubtitle =>
      'Tampilkan bilah alat tambahan untuk navigasi dan tindakan';

  @override
  String get settings_indexCustomizeToolbarButtonsSubtitle =>
      'Pilih tindakan yang muncul di bilah alat kontekstual';

  @override
  String get settings_indexTabStackingSubtitle =>
      'Pilih cara bilah pengalih tab cepat menata tab';

  @override
  String get settings_indexCustomizeSwitcherButtonsSubtitle =>
      'Pilih tombol tindakan yang muncul di ujung bilah';

  @override
  String get settings_indexHistoryFallbackSubtitle =>
      'Gunakan saran riwayat jika tidak ada tab yang cocok';

  @override
  String get settings_indexShowTitlesSubtitle =>
      'Tampilkan judul halaman di daftar pengalih';

  @override
  String get settings_indexHierarchyDepthSubtitle =>
      'Berapa banyak chevron bersarang yang ditampilkan pada chip pengalih';

  @override
  String get settings_indexBottomSheetTabViewSubtitle =>
      'Buka pengalih tab sebagai lembar bawah';

  @override
  String get settings_indexShowFaviconsSubtitle =>
      'Tampilkan ikon situs di daftar tab';

  @override
  String get settings_switcherPlacementTitle => 'Posisi Pengalih';

  @override
  String get settings_switcherPlacementSubtitle =>
      'Letak pengalih di samping bilah alamat dan bilah alat kontekstual';

  @override
  String get settings_switcherPlacementKeywords =>
      'posisi, urutan, di atas, di bawah, atas, bawah, bilah alamat, bilah tab';

  @override
  String get settings_switcherPlacementAutoLabel => 'Otomatis';

  @override
  String get settings_switcherPlacementAutoDescription =>
      'Di atas bilah alamat saat berada di bawah, di atas bilah alat kontekstual saat bilah alamat berada di atas';

  @override
  String get settings_switcherPlacementAboveAddressBarLabel =>
      'Di atas bilah alamat';

  @override
  String get settings_switcherPlacementAboveAddressBarDescription =>
      'Mengikuti bilah alamat ke atas atau ke bawah';

  @override
  String get settings_switcherPlacementBelowAddressBarLabel =>
      'Di bawah bilah alamat';

  @override
  String get settings_switcherPlacementBelowAddressBarDescription =>
      'Mengikuti bilah alamat ke atas atau ke bawah';

  @override
  String get settings_switcherPlacementBelowContextualBarLabel =>
      'Di bawah bilah alat kontekstual';

  @override
  String get settings_switcherPlacementBelowContextualBarDescription =>
      'Di tepi bawah layar';

  @override
  String get smallWeb_sheetTitle => 'Small Web';

  @override
  String get smallWeb_refineCategoryTitle => 'Persempit Kategori';

  @override
  String get smallWeb_allCategoriesChip => 'Semua';

  @override
  String smallWeb_searchingModeTitle(String mode) {
    return 'Mencari $mode';
  }

  @override
  String get smallWeb_discoverButtonLabel => 'Temukan';

  @override
  String get smallWeb_browseConsolesButtonLabel => 'Jelajahi Konsol';

  @override
  String get smallWeb_unavailableTitle => 'Small Web tidak tersedia';

  @override
  String get smallWeb_noConsoleSelectedMessage =>
      'Tidak ada konsol yang dipilih';

  @override
  String smallWeb_consoleStats(int linkedConsoles, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      linkedConsoles,
      locale: localeName,
      other: '$linkedConsoles konsol tertaut',
      one: '1 konsol tertaut',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pages,
      locale: localeName,
      other: '$pages halaman',
      one: '1 halaman',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get smallWeb_modeWebLabel => 'Web';

  @override
  String get smallWeb_modeAppreciatedLabel => 'Diapresiasi';

  @override
  String get smallWeb_modeVideosLabel => 'Video';

  @override
  String get smallWeb_modeCodeLabel => 'Kode';

  @override
  String get smallWeb_modeComicsLabel => 'Komik';

  @override
  String get smallWeb_modeDescriptionAppreciated =>
      'Jelajahi tautan pilihan yang diapresiasi pengguna dari komunitas small web.';

  @override
  String get smallWeb_modeDescriptionVideos =>
      'Temukan konten video dari kreator independen di seluruh small web.';

  @override
  String get smallWeb_modeDescriptionCode =>
      'Temukan cuplikan kode, repositori, dan artikel teknis dari situs pribadi.';

  @override
  String get smallWeb_modeDescriptionComics =>
      'Jelajahi komik indie dan grafis web karya ilustrator independen.';

  @override
  String get smallWeb_sourceKagiLabel => 'Kagi';

  @override
  String get smallWeb_sourceKagiDescription => 'Small Web oleh Kagi Search';

  @override
  String get smallWeb_sourceWanderLabel => 'Wander';

  @override
  String get smallWeb_sourceWanderDescription => 'Cincin web berbasis konsol';

  @override
  String get smallWeb_noNewItemsFoundMessage =>
      'Tidak ada item baru. Coba mode atau kategori lain.';

  @override
  String get smallWeb_discoveryFailedMessage =>
      'Penemuan gagal. Silakan coba lagi.';

  @override
  String smallWeb_sessionErrorWithDetails(String error) {
    return 'Galat Small Web: $error';
  }

  @override
  String get smallWeb_kagiTitle => 'Kagi Small Web';

  @override
  String get smallWeb_kagiAttributionLine =>
      'Oleh Kagi Search - sumber terbuka di bawah Lisensi MIT.';

  @override
  String get smallWeb_kagiBlogPostAction => 'Artikel Blog';

  @override
  String get smallWeb_kagiGithubAction => 'GitHub';

  @override
  String get smallWeb_kagiDescriptionWeb =>
      'Kagi Small Web menampilkan artikel terbaru dari situs pribadi dan blog para penulis individu di seluruh small web.';

  @override
  String get smallWeb_kagiDescriptionAppreciated =>
      'Mode Kagi Small Web ini menyoroti artikel small web yang diapresiasi, sebagaimana dikurasi oleh proyek sumber terbuka tersebut.';

  @override
  String get smallWeb_kagiDescriptionVideos =>
      'Mode Kagi Small Web ini berfokus pada video dari kreator independen yang lebih kecil dan daftar awal saluran yang dikurasi.';

  @override
  String get smallWeb_kagiDescriptionCode =>
      'Mode Kagi Small Web ini berfokus pada artikel seputar kode dari situs pribadi dan sumber small web lainnya.';

  @override
  String get smallWeb_kagiDescriptionComics =>
      'Mode Kagi Small Web ini berfokus pada komik dan artikel bergambar yang ditampilkan melalui proyek Small Web.';

  @override
  String get smallWeb_wanderTitle => 'Wander';

  @override
  String get smallWeb_wanderDescription =>
      'Wander adalah jaringan situs web pribadi yang terhubung melalui konsol bersama, yang membantu orang menjelajahi halaman di seluruh komunitas Wander.';

  @override
  String get smallWeb_wanderAttributionLine =>
      'Oleh Susam Pal - sumber terbuka di bawah Lisensi MIT.';

  @override
  String get smallWeb_wanderProjectAction => 'Proyek';

  @override
  String get smallWeb_wanderSetupConsoleAction => 'Siapkan Konsol Anda';

  @override
  String get smallWeb_menuTooltip => 'Menu';

  @override
  String get smallWeb_removeBookmarkTooltip => 'Hapus markah';

  @override
  String get smallWeb_addBookmarkTooltip => 'Tambah markah';

  @override
  String get smallWeb_bookmarkRemovedMessage => 'Markah dihapus';

  @override
  String get smallWeb_bookmarkAddedMessage => 'Markah ditambahkan';

  @override
  String get smallWeb_exitTooltip => 'Keluar dari Small Web';

  @override
  String get smallWeb_selectConsoleTitle => 'Pilih Konsol';

  @override
  String get smallWeb_randomButtonLabel => 'Acak';

  @override
  String get smallWeb_filterConsolesHint => 'Saring konsol...';

  @override
  String get smallWeb_linkedConsolesToggleLabel => 'Tertaut';

  @override
  String get smallWeb_allConsolesToggleLabel => 'Semua';

  @override
  String get smallWeb_noConsoleSelectedYetMessage =>
      'Belum ada konsol yang dipilih. Tekan Temukan.';

  @override
  String get smallWeb_addConsoleByUrlTooltip => 'Tambah konsol lewat URL';

  @override
  String get smallWeb_couldNotLoadSessionTitle =>
      'Tidak dapat memuat sesi Small Web';

  @override
  String get smallWeb_noLinkedConsolesFound => 'Tidak ada konsol tertaut.';

  @override
  String smallWeb_noConsolesMatchingQuery(String query) {
    return 'Tidak ada konsol yang cocok dengan \"$query\".';
  }

  @override
  String get smallWeb_failedToLoadConsoles => 'Gagal memuat konsol.';

  @override
  String smallWeb_pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count halaman',
      one: '1 halaman',
    );
    return '$_temp0';
  }

  @override
  String get smallWeb_noConsolesDiscoveredYet =>
      'Belum ada konsol yang ditemukan.';

  @override
  String smallWeb_addedConsole(String host) {
    return 'Konsol $host ditambahkan';
  }

  @override
  String get smallWeb_addConsoleDialogTitle => 'Tambah Konsol';

  @override
  String get smallWeb_addConsoleDialogBody =>
      'Masukkan URL konsol Wander. URL dapat mengarah ke akar situs atau ke jalur /wander/.';

  @override
  String get smallWeb_urlFieldLabel => 'URL';

  @override
  String get smallWeb_wanderConsoleFetchFailed =>
      'Tidak dapat mengambil wander.js dari konsol ini.';

  @override
  String get smallWeb_wanderConsoleEmpty =>
      'Berkas wander.js tidak berisi konsol atau halaman';

  @override
  String get smallWeb_wanderConsoleAlreadyAdded =>
      'Konsol ini sudah ditambahkan';

  @override
  String get smallWeb_recentDiscoveriesTitle => 'Penemuan Terbaru';

  @override
  String smallWeb_clearModeHistory(String mode) {
    return 'Hapus $mode';
  }

  @override
  String get smallWeb_clearAllDiscoveriesConfirmTitle =>
      'Hapus semua penemuan?';

  @override
  String get smallWeb_clearAllDiscoveriesConfirmContent =>
      'Ini akan menghapus permanen seluruh riwayat penemuan terbaru di semua mode dan sumber.';

  @override
  String get smallWeb_actionClearAll => 'Hapus Semua';

  @override
  String get smallWeb_clearAllDiscoveriesMenuItem => 'Hapus semua penemuan';

  @override
  String get smallWeb_noDiscoveriesYetMessage =>
      'Belum ada penemuan.\nKetuk Temukan untuk mulai menjelajah!';

  @override
  String smallWeb_showMoreCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tampilkan $count lagi',
    );
    return '$_temp0';
  }

  @override
  String smallWeb_failedToLoadHistory(String error) {
    return 'Gagal memuat riwayat: $error';
  }

  @override
  String get sync_screenTitle => 'Firefox Sync';

  @override
  String get sync_searchHint => 'Cari pengaturan sinkronisasi';

  @override
  String get sync_statusSyncing => 'Sinkronisasi sedang berlangsung';

  @override
  String get sync_statusNeverSynced => 'Belum pernah disinkronkan';

  @override
  String sync_statusLastSynced(String date) {
    return 'Terakhir disinkronkan: $date';
  }

  @override
  String get sync_sectionAccount => 'Akun';

  @override
  String get sync_sectionAccountKeywords =>
      'penyandingan, pasangkan, nama perangkat, pairing, device name';

  @override
  String get sync_entrySignedInAccountTitle => 'Akun yang masuk';

  @override
  String get sync_entrySignInTitle => 'Masuk';

  @override
  String get sync_entryAccountSubtitle =>
      'Status akun, penyandingan melalui kode QR, dan nama perangkat';

  @override
  String get sync_signedIn => 'Sudah masuk';

  @override
  String get sync_notSignedIn => 'Belum masuk';

  @override
  String get sync_authExpired =>
      'Autentikasi kedaluwarsa. Masuk kembali untuk melanjutkan sinkronisasi.';

  @override
  String get sync_syncingTabsBookmarksHistory =>
      'Menyinkronkan tab, markah, dan riwayat';

  @override
  String get sync_signInPrompt =>
      'Masuk untuk menyinkronkan tab, markah, dan riwayat';

  @override
  String get sync_actionSignOut => 'Keluar';

  @override
  String get sync_scanQrTitle => 'Pindai kode QR untuk menyandingkan perangkat';

  @override
  String get sync_scanQrSubtitle =>
      'Pindai kode QR dari firefox.com/pair di komputer';

  @override
  String get sync_invalidQrCode => 'Kode QR tidak valid: bukan URL yang valid';

  @override
  String get sync_deviceNameTitle => 'Nama Perangkat';

  @override
  String get sync_unknown => 'Tidak diketahui';

  @override
  String get sync_sectionSynchronization => 'Sinkronisasi';

  @override
  String get sync_syncNowTitle => 'Sinkronkan Sekarang';

  @override
  String get sync_syncNowKeywords =>
      'riwayat, markah, tab, history, bookmarks, tabs';

  @override
  String get sync_syncHistoryTitle => 'Sinkronkan Riwayat';

  @override
  String get sync_syncBookmarksTitle => 'Sinkronkan Markah';

  @override
  String get sync_syncOpenTabsTitle => 'Sinkronkan Tab Terbuka';

  @override
  String get sync_sectionServerOverrides => 'Server Kustom';

  @override
  String get sync_entryServerOverridesTitle => 'Server kustom';

  @override
  String get sync_entryServerOverridesKeywords =>
      'fxa, token server, server token, server';

  @override
  String get sync_entryServerOverridesSubtitle =>
      'Alamat server Firefox Account dan server token kustom';

  @override
  String get sync_fxaServerOverrideTitle => 'Server FxA Kustom';

  @override
  String get sync_defaultMozillaServer => 'Server Mozilla bawaan';

  @override
  String get sync_tokenServerOverrideTitle => 'Server Token Sync Kustom';

  @override
  String get sync_automaticFromFxaServer => 'Otomatis dari server FxA';

  @override
  String get sync_restartAppNotice =>
      'Mulai ulang aplikasi setelah mengubah server kustom.';

  @override
  String get sync_signOutDialogTitle => 'Keluar?';

  @override
  String get sync_signOutDialogContent =>
      'Yakin ingin keluar dari Firefox Sync?';

  @override
  String get sync_deviceNameHint => 'Masukkan nama perangkat';

  @override
  String get sync_deviceNameEmpty => 'Nama perangkat tidak boleh kosong';

  @override
  String get sync_deviceNameUpdateFailed => 'Gagal memperbarui nama perangkat';

  @override
  String get sync_mustBeValidHttpsUrl => 'Harus berupa URL HTTPS yang valid';

  @override
  String get tor_sectionService => 'Layanan';

  @override
  String get tor_sectionServiceKeywords =>
      'daya, mulai, hentikan, power, start, stop';

  @override
  String get tor_sectionCircumvention => 'Menghindari Sensor';

  @override
  String get tor_sectionCircumventionKeywords =>
      'jembatan, bridge, transport, obfs4, snowflake, sensor';

  @override
  String get tor_sectionCountryRestrictions => 'Pembatasan Negara';

  @override
  String get tor_sectionCountryRestrictionsKeywords =>
      'masuk, keluar, negara, entry, exit, country';

  @override
  String get tor_sectionAbout => 'Tentang';

  @override
  String get tor_sectionAboutKeywords =>
      'merek dagang, hukum, trademark, legal';

  @override
  String tor_proxyLabel(String brand) {
    return 'Proksi $brand';
  }

  @override
  String tor_serviceLabel(String brand) {
    return 'Layanan $brand';
  }

  @override
  String get tor_serviceLabelKeywords => 'aktifkan, hubungkan, enable, connect';

  @override
  String tor_serviceSubtitle(String brand) {
    return 'Mulai atau hentikan layanan $brand';
  }

  @override
  String get tor_startAutomaticallyTitle => 'Mulai Otomatis';

  @override
  String get tor_startAutomaticallyKeywords =>
      'mulai otomatis, jalankan, saat mulai, autostart, startup, boot';

  @override
  String tor_startAutomaticallySectionSubtitle(String brand) {
    return 'Hubungkan layanan $brand saat WebLibre dimulai';
  }

  @override
  String tor_startAutomaticallySubtitle(String brand) {
    return 'Hubungkan layanan $brand saat WebLibre dimulai, sehingga tab yang menggunakannya langsung siap tanpa konfirmasi';
  }

  @override
  String get tor_requestNewIdentityTitle => 'Minta Identitas Baru';

  @override
  String get tor_requestNewIdentityKeywords => 'sirkuit, circuit';

  @override
  String get tor_requestNewIdentitySubtitle =>
      'Gunakan sirkuit baru untuk koneksi baru';

  @override
  String tor_requestingNewIdentityMessage(String brand) {
    return 'Meminta identitas $brand baru...';
  }

  @override
  String get tor_autoConfigureTransportTitle =>
      'Konfigurasi Transport Otomatis';

  @override
  String get tor_autoConfigureTransportKeywords => 'otomatis, auto';

  @override
  String get tor_autoConfigureSectionSubtitle =>
      'Pilih pluggable transport yang tepat untuk jaringan Anda secara otomatis';

  @override
  String tor_autoConfigureSubtitle(String brand) {
    return 'Dari beberapa lokasi, pluggable transport diperlukan untuk terhubung ke $brand';
  }

  @override
  String get tor_requireBridgeTitle =>
      'Saya yakin tidak bisa terhubung tanpa jembatan';

  @override
  String get tor_transportTitle => 'Transport';

  @override
  String get tor_transportKeywords => 'langsung, direct, obfs4, snowflake';

  @override
  String tor_transportSectionSubtitle(String torBrand) {
    return 'Pilih cara menjangkau jaringan $torBrand saat tidak dikonfigurasi otomatis';
  }

  @override
  String get tor_transportAutoConfiguredTitle => 'Dikonfigurasi otomatis';

  @override
  String get tor_transportAutoConfiguredSubtitle =>
      'Nonaktifkan konfigurasi otomatis di atas untuk memilih transport secara manual.';

  @override
  String get tor_transportDirectTitle => 'Koneksi Langsung';

  @override
  String tor_transportDirectSubtitle(String brand) {
    return 'Cara terbaik untuk terhubung ke $brand jika $brand tidak diblokir';
  }

  @override
  String get tor_transportObfs4Title => 'obfs4';

  @override
  String get tor_transportObfs4Subtitle =>
      'Cocok untuk jaringan dengan penyensoran ringan dan penggunaan bandwidth tinggi';

  @override
  String get tor_transportSnowflakeTitle => 'Snowflake';

  @override
  String get tor_transportSnowflakeSubtitle =>
      'Cocok untuk jaringan dengan penyensoran ketat';

  @override
  String get tor_fetchFreshBridgesTitle =>
      'Ambil jembatan terbaru sebelum menghubungkan';

  @override
  String get tor_entryCountryTitle => 'Negara Masuk';

  @override
  String get tor_entryCountrySubtitle => 'Pilih negara untuk entry guard';

  @override
  String get tor_entryCountryKeywords => 'guard, penjaga, masuk';

  @override
  String get tor_exitCountryTitle => 'Negara Keluar';

  @override
  String get tor_exitCountrySubtitle => 'Pilih negara untuk node keluar';

  @override
  String get tor_exitCountryKeywords => 'keluar, exit';

  @override
  String get tor_automaticOption => 'Otomatis';

  @override
  String get tor_trademarkTitle => 'Merek Dagang';

  @override
  String get tor_trademarkKeywords => 'hukum, legal';

  @override
  String tor_trademarkDisclaimer(String brand) {
    return '$brand adalah merek dagang dari The Tor Project; semua hak dilindungi undang-undang. WebLibre tidak didukung, disponsori, atau berafiliasi dengan Tor Project.';
  }

  @override
  String get tor_screenSubtitle =>
      'Onion routing, pluggable transport, jembatan, dan pembatasan negara.';

  @override
  String tor_dialogContent(String brand) {
    return 'Kontainer ini memerlukan proksi $brand untuk koneksi aman, tetapi proksi tersebut sedang tidak berjalan.';
  }

  @override
  String get tor_actionEnable => 'Aktifkan';

  @override
  String tor_connectingNotification(String proxyLabel) {
    return '$proxyLabel sedang menghubungkan...';
  }

  @override
  String get tor_countrySearchHint => 'Cari negara...';

  @override
  String get tor_unnamedCountry => 'Negara Tanpa Nama';

  @override
  String get user_profilesTitle => 'Profil';

  @override
  String get user_activeProfileLabel => 'Aktif';

  @override
  String get user_loadProfilesFailedTitle => 'Tidak dapat memuat profil';

  @override
  String get user_askWhichProfileTitle => 'Tanyakan profil yang akan dibuka';

  @override
  String get user_askWhichProfileSubtitle =>
      'Saat memulai, jika ada lebih dari satu profil';

  @override
  String get user_createBackupTitle => 'Buat Cadangan';

  @override
  String get user_restartingToTakeBackup =>
      'Memulai ulang untuk membuat cadangan';

  @override
  String get user_backupRestartsTitle =>
      'WebLibre dimulai ulang untuk melakukan ini';

  @override
  String user_backupRestartsSubtitle(String restartClosesCurrentProfile) {
    return '$restartClosesCurrentProfile Cadangan dibuat saat profil ditutup, sehingga isinya tidak dapat berubah selama pencadangan.';
  }

  @override
  String get user_setPasswordNextTitle =>
      'Anda mengatur kata sandi di langkah berikutnya';

  @override
  String get user_setPasswordNextSubtitle =>
      'Setelah dimulai ulang, WebLibre akan meminta kata sandi berkas cadangan.';

  @override
  String get user_verifyBackupIntegrityTitle =>
      'Verifikasi integritas cadangan';

  @override
  String get user_verifyBackupIntegritySubtitle =>
      'Periksa bahwa cadangan dapat dipulihkan';

  @override
  String get user_tempDataSkippedTitle => 'Data sementara dilewati';

  @override
  String user_tempDataSkippedSubtitle(String shortcutsNeedPinningAgain) {
    return 'Berkas cache dan data lain yang dapat dibuat ulang oleh WebLibre tidak disimpan. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataIncludedTitle => 'Data akun WebLibre disertakan';

  @override
  String user_accountDataIncludedSubtitle(String profileSecretDataDescription) {
    return 'Berkas cadangan menyertakan $profileSecretDataDescription milik profil ini. Mengganti profil akan memulihkannya; membuat profil baru tidak. Gunakan kata sandi yang kuat.';
  }

  @override
  String get user_closingToTakeBackup =>
      'Menutup WebLibre untuk membuat cadangan…';

  @override
  String get user_actionBackup => 'Cadangkan';

  @override
  String get user_backupsTitle => 'Cadangan';

  @override
  String get user_changeBackupFolderTooltip => 'Ubah folder cadangan';

  @override
  String get user_chooseBackupFolderPrompt =>
      'Pilih lokasi penyimpanan cadangan Anda.';

  @override
  String get user_chooseBackupFolderHint =>
      'Pilih lokasi di luar aplikasi, agar cadangan tetap ada meskipun aplikasi dicopot.';

  @override
  String get user_chooseFolderButtonLabel => 'Pilih folder';

  @override
  String get user_noBackupsFound => 'Tidak ada cadangan';

  @override
  String get user_loadBackupsFailedTitle => 'Tidak dapat memuat cadangan';

  @override
  String get user_authReasonRequireAuth => 'Wajibkan autentikasi untuk profil';

  @override
  String get user_authReasonConfirmUnlock =>
      'Konfirmasi bahwa Anda dapat membuka kunci profil ini';

  @override
  String get user_authReasonUnlockProfile => 'Buka kunci profil';

  @override
  String user_authFailedExisting(String nothingChanged) {
    return 'Tidak dapat mengonfirmasi identitas Anda. $nothingChanged';
  }

  @override
  String get user_authFailedNew =>
      'Tidak dapat mengonfirmasi identitas Anda. Profil terkunci hanya dibuat setelah perangkat ini dapat membuka kuncinya.';

  @override
  String get user_editProfileTitle => 'Edit Profil';

  @override
  String get user_createProfileTitle => 'Buat Profil';

  @override
  String get user_nameFieldLabel => 'Nama';

  @override
  String get user_authenticationSectionTitle => 'Autentikasi';

  @override
  String get user_requireAuthenticationTitle => 'Wajibkan autentikasi';

  @override
  String get user_requireAuthenticationSubtitle =>
      'Minta konfirmasi sebelum profil ini dapat dibuka';

  @override
  String get user_autoLockTitle => 'Kunci otomatis';

  @override
  String get user_autoLockSubtitle => 'Kapan profil dikunci kembali';

  @override
  String get user_lockInBackgroundTitle => 'Kunci di latar belakang';

  @override
  String get user_lockInBackgroundSubtitle =>
      'Segera setelah WebLibre meninggalkan layar';

  @override
  String get user_lockAfterTimeoutTitle => 'Kunci setelah batas waktu';

  @override
  String get user_lockAfterTimeoutSubtitle =>
      'Setelah tidak aktif selama beberapa waktu';

  @override
  String get user_lockOnStartupTitle => 'Kunci hanya saat memulai';

  @override
  String get user_lockOnStartupSubtitle =>
      'Buka kunci sekali saat memulai, lalu tetap terbuka hingga WebLibre ditutup sepenuhnya';

  @override
  String get user_timeoutFieldTitle => 'Batas waktu';

  @override
  String get user_timeoutFieldSubtitle =>
      'Berapa lama menunggu sebelum mengunci';

  @override
  String get user_timeoutOneMinute => '1 menit';

  @override
  String get user_timeoutFiveMinutes => '5 menit';

  @override
  String get user_timeoutFifteenMinutes => '15 menit';

  @override
  String get user_timeoutOneHour => '1 jam';

  @override
  String get user_profileActionsSectionTitle => 'Tindakan profil';

  @override
  String get user_switchDeleteUnavailableForActive =>
      'Beralih dan menghapus tidak tersedia untuk profil yang sedang Anda gunakan.';

  @override
  String get user_switchToThisProfileLabel => 'Beralih ke profil ini';

  @override
  String user_deleteFailedWithError(String error) {
    return 'Tidak dapat menghapus: $error';
  }

  @override
  String get user_deleteProfileFailedGeneric =>
      'Tidak dapat menghapus profil ini';

  @override
  String get user_restoreBackupTitle => 'Pulihkan Cadangan';

  @override
  String get user_backupRestoredMessage => 'Cadangan dipulihkan';

  @override
  String get user_passwordFieldLabel => 'Kata sandi';

  @override
  String get user_wrongBackupPassword =>
      'Kata sandi ini tidak dapat membuka berkas cadangan';

  @override
  String get user_passwordHelperText =>
      'Kata sandi yang digunakan saat membuat berkas cadangan ini.';

  @override
  String get user_createNewProfileTitle => 'Buat profil baru';

  @override
  String get user_createNewProfileSubtitle =>
      'Pertahankan profil yang ada dan tambahkan cadangan ini';

  @override
  String get user_replaceExistingProfileTitle => 'Ganti profil yang ada';

  @override
  String get user_replaceExistingProfileSubtitle =>
      'Mulai ulang dan timpa satu profil dengan cadangan ini';

  @override
  String get user_newProfileNoSignInTitle =>
      'Profil baru dimulai tanpa info masuk WebLibre';

  @override
  String get user_newProfileNoSignInSubtitle =>
      'Tab, riwayat, dan markah dipulihkan. Info masuk dan data sinkronisasi tetap berada di profil asli.';

  @override
  String user_restoringIntoTitle(String profileLabel) {
    return 'Memulihkan ke \"$profileLabel\"';
  }

  @override
  String get user_backupKeepsLockConfigured =>
      'Cadangan mempertahankan pengaturan penguncian yang Anda buat.';

  @override
  String get user_profileKeepsNameAndLock =>
      'Profil tetap memakai nama dan pengaturan pengunciannya.';

  @override
  String get user_profileToReplaceLabel => 'Profil yang akan diganti';

  @override
  String get user_selectProfileToReplaceValidator =>
      'Pilih profil yang akan diganti';

  @override
  String user_multipleProfilesShareNameTitle(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ada $count profil bernama \"$name\"',
    );
    return '$_temp0';
  }

  @override
  String user_multipleProfilesShareNameSubtitle(String cannotBeUndone) {
    return 'Cadangan menyebutkan nama profil tetapi tidak dapat memastikan yang mana, jadi pilih profil yang akan diganti. $cannotBeUndone';
  }

  @override
  String user_backupTakenFromTitle(String name) {
    return 'Cadangan ini dibuat dari \"$name\"';
  }

  @override
  String user_backupTakenFromSubtitle(
    String targetLabel,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Cadangan ini menggantikan \"$targetLabel\", yang tetap memakai nama dan pengaturan pengunciannya. $shortcutsNeedPinningAgain';
  }

  @override
  String user_profileWillBeCalledTitle(String name) {
    return 'Profil ini akan bernama \"$name\"';
  }

  @override
  String user_profileWillBeCalledSubtitle(String shortcutsNeedPinningAgain) {
    return 'Nama ini berasal dari cadangan. $shortcutsNeedPinningAgain';
  }

  @override
  String get user_accountDataRestoredTitle => 'Data akun WebLibre dipulihkan';

  @override
  String user_accountDataRestoredSubtitle(
    String profileSecretDataDescription,
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
  ) {
    return 'Penggantian akan memulihkan $profileSecretDataDescription dari berkas cadangan. $signedInFromBackup $olderBackupKeepsCredentials';
  }

  @override
  String get user_replacesSetupProfileTitle =>
      'Ini menggantikan profil yang sedang Anda siapkan';

  @override
  String get user_replacesEverythingTitle =>
      'Ini menggantikan semua isi profil tersebut';

  @override
  String user_replacesSetupProfileSubtitle(String restartsThenAsksPassword) {
    return '$restartsThenAsksPassword Apa pun yang sudah ada di profil ini akan diganti saat pemulihan dimulai.';
  }

  @override
  String user_replacesEverythingSubtitle(
    String restartsThenAsksPassword,
    String profileDataDescription,
    String targetDescription,
  ) {
    return '$restartsThenAsksPassword Saat pemulihan dimulai, $profileDataDescription yang ada di $targetDescription akan diganti.';
  }

  @override
  String get user_thatProfileFallbackLabel => 'profil tersebut';

  @override
  String get user_restoringBackupProgress => 'Memulihkan cadangan…';

  @override
  String get user_closingToRestoreProgress =>
      'Menutup WebLibre untuk memulihkan…';

  @override
  String get user_actionRestore => 'Pulihkan';

  @override
  String user_switchToProfileTitle(String profileName) {
    return 'Beralih ke \"$profileName\"?';
  }

  @override
  String user_switchClosesReopensAs(String profileName) {
    return 'WebLibre akan ditutup dan dibuka kembali sebagai \"$profileName\".';
  }

  @override
  String get user_switchConsequencesList =>
      '• Tab pribadi dihapus.\n• Notifikasi web untuk profil yang Anda tinggalkan dijeda.';

  @override
  String get user_actionNotNow => 'Jangan sekarang';

  @override
  String get user_actionSwitchAndRestart => 'Beralih dan mulai ulang';

  @override
  String get user_passwordConfirmationTitle => 'Konfirmasi Kata Sandi';

  @override
  String get user_actionConfirm => 'Konfirmasi';

  @override
  String get user_selectProfileTitle => 'Pilih profil';

  @override
  String get user_manageProfilesLabel => 'Kelola profil';

  @override
  String get user_profileAvatarHint =>
      'Beralih ke profil ini. Tekan lama untuk mengeditnya.';

  @override
  String user_profileAvatarTooltip(String label) {
    return '$label\nTekan lama untuk mengedit';
  }

  @override
  String get user_addProfileLabel => 'Tambah profil';

  @override
  String get user_addProfileButtonLabel => 'Tambah profil';

  @override
  String get user_quitBrowserTitle => 'Keluar dari Peramban';

  @override
  String get user_quitBrowserContent =>
      'Ini akan menutup peramban dengan benar dan menghapus data tab pribadi.';

  @override
  String get user_actionQuit => 'Keluar';

  @override
  String get user_quitBrowserDontAskAgain => 'Jangan tanya lagi';

  @override
  String get user_quitBrowserDontAskAgainHint =>
      'Anda dapat mengaktifkannya kembali di pengaturan.';

  @override
  String get user_quitBrowserDeleteDataTitle => 'Hapus data penjelajahan';

  @override
  String user_quitBrowserDeleteDataSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      zero: 'Tidak ada yang dipilih',
    );
    return '$_temp0';
  }

  @override
  String get user_quitBrowserDeletedAutomatically =>
      'Dihapus otomatis, sesuai pengaturan';

  @override
  String user_deleteProfileTitle(String profileName) {
    return 'Hapus \"$profileName\"?';
  }

  @override
  String user_deleteProfileContent(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return '$profileDataDescription miliknya akan dihapus. $cannotBeUndone';
  }

  @override
  String user_deleteProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile Profil yang dihapus akan ditutup terlebih dahulu.';
  }

  @override
  String get user_actionDeleteAndRestart => 'Hapus dan mulai ulang';

  @override
  String user_replaceProfileTitle(String profileName) {
    return 'Ganti \"$profileName\" dengan cadangan ini?';
  }

  @override
  String user_replaceProfilePlaceholderContent(String cannotBeUndone) {
    return 'Cadangan menggantikan profil yang sedang Anda siapkan. Apa pun yang sudah ada di dalamnya akan hilang. $cannotBeUndone';
  }

  @override
  String user_replaceProfileContent(
    String profileName,
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Cadangan menggantikan semua isi \"$profileName\" — $profileDataDescription miliknya. Apa pun yang ditambahkan setelah cadangan dibuat akan hilang. $cannotBeUndone';
  }

  @override
  String user_replaceProfileAccountNote(
    String signedInFromBackup,
    String profileSecretDataDescription,
    String olderBackupKeepsCredentials,
  ) {
    return '$signedInFromBackup Pemulihan juga menyertakan $profileSecretDataDescription dari cadangan. $olderBackupKeepsCredentials';
  }

  @override
  String user_replaceProfileRenamedNote(
    String adoptedName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Profil diganti namanya menjadi \"$adoptedName\" dan tetap memakai pengaturan pengunciannya. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileFromSourceNote(
    String sourceProfileName,
    String profileName,
    String shortcutsNeedPinningAgain,
  ) {
    return 'Cadangan ini berasal dari \"$sourceProfileName\". \"$profileName\" tetap memakai nama dan pengaturan pengunciannya. $shortcutsNeedPinningAgain';
  }

  @override
  String user_replaceProfileRestartNote(
    String restartsThenAsksPassword,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsThenAsksPassword Tidak ada yang diganti sebelum itu. $restartClosesCurrentProfile';
  }

  @override
  String get user_actionReplaceAndRestart => 'Ganti dan mulai ulang';

  @override
  String user_backupProfileTitle(String profileName) {
    return 'Cadangkan \"$profileName\"?';
  }

  @override
  String get user_backupProfileContent =>
      'Cadangan dibuat saat profil ditutup, sehingga tidak ada isinya yang berubah.';

  @override
  String user_backupProfileRestartNote(
    String restartsToWork,
    String restartClosesCurrentProfile,
  ) {
    return '$restartsToWork $restartClosesCurrentProfile';
  }

  @override
  String get user_actionBackupAndRestart => 'Cadangkan dan mulai ulang';

  @override
  String get user_profileAlreadyActive => 'Profil ini sudah aktif';

  @override
  String user_switchProfileFailedWithError(String error) {
    return 'Tidak dapat beralih profil: $error';
  }

  @override
  String get user_profileLockedTitle => 'Profil terkunci';

  @override
  String get user_unlockingLabel => 'Membuka kunci...';

  @override
  String get user_unlockButtonLabel => 'Buka kunci';

  @override
  String user_restartFailedWithError(String error) {
    return 'Tidak dapat memulai ulang: $error';
  }

  @override
  String get user_restartingLabel => 'Memulai ulang…';

  @override
  String get user_chooseAnotherProfileLabel => 'Pilih profil lain';

  @override
  String get user_searchSuggestionProviderNone => 'Nonaktif';

  @override
  String get user_searchSuggestionProviderBrave => 'Brave';

  @override
  String get user_searchSuggestionProviderDdg => 'DuckDuckGo';

  @override
  String get user_searchSuggestionProviderKagi => 'Kagi';

  @override
  String get user_searchSuggestionProviderQwant => 'Qwant';

  @override
  String get user_deleteBrowsingDataTypeTabsTitle => 'Tab terbuka';

  @override
  String get user_deleteBrowsingDataTypeHistoryTitle => 'Riwayat penjelajahan';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesTitle =>
      'Pencarian terbaru';

  @override
  String get user_deleteBrowsingDataTypeRecentSearchesDescription =>
      'Kueri yang ditampilkan di halaman pencarian';

  @override
  String get user_deleteBrowsingDataTypeCookiesTitle => 'Kuki dan data situs';

  @override
  String get user_deleteBrowsingDataTypeCookiesDescription =>
      'Anda akan keluar dari sebagian besar situs';

  @override
  String get user_deleteBrowsingDataTypeCacheTitle =>
      'Gambar dan berkas dalam cache';

  @override
  String get user_deleteBrowsingDataTypeCacheDescription =>
      'Mengosongkan ruang penyimpanan';

  @override
  String get user_deleteBrowsingDataTypePermissionsTitle => 'Izin situs';

  @override
  String get user_deleteBrowsingDataTypeDownloadsTitle => 'Unduhan';

  @override
  String get wallpaper_title => 'Wallpaper';

  @override
  String get wallpaper_settingsDescription =>
      'Ditampilkan di belakang beranda, di setiap kontainer yang tidak mengatur wallpaper sendiri.';

  @override
  String get wallpaper_chooseImage => 'Pilih gambar';

  @override
  String get wallpaper_replace => 'Ganti';

  @override
  String get wallpaper_blurLabel => 'Buram';

  @override
  String get wallpaper_dimLabel => 'Redupkan';

  @override
  String get wallpaper_dimDescription =>
      'Peredupan memadukan gambar dengan latar belakang aplikasi, sehingga teks halaman tetap terbaca dalam tema terang maupun gelap.';

  @override
  String get wallpaper_editorDefaultDescription =>
      'Beranda tetap memakai latar bawaannya.';

  @override
  String get wallpaper_importErrorUnreadable =>
      'Berkas tersebut tidak dapat dibaca';

  @override
  String get wallpaper_importErrorTooLarge => 'Gambar tersebut terlalu besar';

  @override
  String get wallpaper_importErrorNotAnImage => 'Berkas tersebut bukan gambar';

  @override
  String get wallpaper_importErrorDecodeFailed =>
      'Gambar tersebut tidak dapat dibaca';

  @override
  String get webFeed_addFeedTitle => 'Tambah Umpan';

  @override
  String get webFeed_fieldUrlLabel => 'URL';

  @override
  String get webFeed_actionIgnore => 'Abaikan';

  @override
  String get webFeed_unnamedFeedTitle => 'Umpan Tanpa Judul';

  @override
  String get webFeed_unnamedArticleTitle => 'Artikel Tanpa Judul';

  @override
  String get webFeed_fetchFeedFailedTitle => 'Gagal mengambil umpan';

  @override
  String get webFeed_feedsTitle => 'Umpan';

  @override
  String get webFeed_loadFeedsFailedTitle => 'Gagal memuat umpan';

  @override
  String get webFeed_feedFabLabel => 'Tambah Umpan';

  @override
  String get webFeed_loadFeedFailedTitle => 'Gagal memuat umpan';

  @override
  String get webFeed_newFeedTitle => 'Umpan Baru';

  @override
  String get webFeed_editFeedTitle => 'Edit Umpan';

  @override
  String get webFeed_fetchingFeedMessage => 'Mengambil umpan…';

  @override
  String get webFeed_fieldTitleLabel => 'Judul';

  @override
  String get webFeed_fieldDescriptionLabel => 'Deskripsi';

  @override
  String get webFeed_fieldIconUrlLabel => 'URL Ikon';

  @override
  String get webFeed_fieldSiteLinkLabel => 'Tautan Situs';

  @override
  String get webFeed_fieldFeedUrlLabel => 'URL Umpan';

  @override
  String get webFeed_deleteFeedTitle => 'Hapus Umpan';

  @override
  String get webFeed_deleteFeedConfirm =>
      'Yakin ingin menghapus umpan ini beserta semua artikelnya?';

  @override
  String get webFeed_articlesTitle => 'Artikel';

  @override
  String get webFeed_searchLabel => 'Cari';

  @override
  String get webFeed_loadArticlesFailedTitle => 'Gagal memuat artikel';

  @override
  String webFeed_publishedLabel(String date) {
    return 'Diterbitkan: $date';
  }

  @override
  String get webFeed_notAvailable => 'T/A';

  @override
  String webFeed_updatedLabel(String date) {
    return 'Diperbarui: $date';
  }

  @override
  String get webFeed_authorsLabel => 'Penulis:';

  @override
  String get webFeed_tagsLabel => 'Tag:';

  @override
  String get webFeed_readArticleFailedTitle => 'Gagal memuat artikel';

  @override
  String webFeed_lastFetchedLabel(String date) {
    return 'Terakhir diambil: $date';
  }

  @override
  String get webFeed_tagsFieldLabel => 'Tag';

  @override
  String get webPush_screenTitle => 'Notifikasi';

  @override
  String get webPush_screenSubtitle =>
      'Notifikasi situs web yang dikirim melalui UnifiedPush';

  @override
  String get webPush_distributorTileTitle => 'Distributor UnifiedPush';

  @override
  String get webPush_distributorTileKeywords =>
      'notifikasi, push, unifiedpush, ntfy, pemberitahuan';

  @override
  String get webPush_checking => 'Memeriksa…';

  @override
  String webPush_couldNotReadStatus(String error) {
    return 'Tidak dapat membaca status push: $error';
  }

  @override
  String get webPush_updatingDistributor => 'Memperbarui…';

  @override
  String get webPush_registrationRecovering =>
      'Memulihkan dari galat pendaftaran…';

  @override
  String webPush_lastRegistrationError(String error) {
    return 'Galat pendaftaran terakhir: $error';
  }

  @override
  String get webPush_disablingWebPush => 'Menonaktifkan…';

  @override
  String get webPush_disableWebPush => 'Nonaktifkan web push';

  @override
  String get webPush_statusNoneAvailable =>
      'Tidak ada distributor yang tersedia';

  @override
  String get webPush_statusNotSelected => 'Belum dikonfigurasi';

  @override
  String get webPush_statusPending => 'Menghubungkan…';

  @override
  String get webPush_statusReady => 'Aktif';

  @override
  String get webPush_statusUnavailable => 'Distributor tidak tersedia';

  @override
  String get webPush_statusDescNoneAvailable =>
      'Pasang aplikasi distributor UnifiedPush, misalnya ntfy, untuk menerima notifikasi situs web.';

  @override
  String get webPush_statusDescNotSelected =>
      'Pilih distributor di bawah untuk mengaktifkan notifikasi situs web.';

  @override
  String get webPush_statusDescPending =>
      'Menunggu distributor mengonfirmasi pendaftaran.';

  @override
  String get webPush_statusDescReady =>
      'Notifikasi situs web dikirim melalui distributor ini.';

  @override
  String get webPush_statusDescUnavailable =>
      'Distributor yang dipilih sudah tidak terpasang. Notifikasi situs web tidak akan dikirim sampai Anda memilih yang lain.';

  @override
  String get webPush_noDistributorInstalled =>
      'Tidak ada distributor UnifiedPush yang terpasang. Pasang salah satunya, misalnya ntfy, lalu coba lagi.';

  @override
  String get webPush_chooseDistributorTitle => 'Pilih distributor';

  @override
  String get webPush_distributorConfigured =>
      'Distributor UnifiedPush telah dikonfigurasi.';

  @override
  String webPush_couldNotConfigureDistributor(String error) {
    return 'Tidak dapat mengonfigurasi distributor: $error';
  }

  @override
  String get webPush_webPushDisabled => 'Web push dinonaktifkan.';

  @override
  String webPush_couldNotDisableWebPush(String error) {
    return 'Tidak dapat menonaktifkan web push: $error';
  }

  @override
  String get webPush_notificationPermissionTitle => 'Izin Notifikasi';

  @override
  String get webPush_notificationPermissionKeywords =>
      'notifikasi, izin, pemberitahuan, notifications, permission';

  @override
  String webPush_notificationPermissionCouldNotRead(String error) {
    return 'Tidak dapat membaca status izin: $error';
  }

  @override
  String get webPush_notificationPermissionGranted => 'Diizinkan';

  @override
  String get webPush_notificationPermissionDenied =>
      'Ditolak. Pesan push tetap diterima, tetapi notifikasi tidak dapat ditampilkan.';

  @override
  String get webPush_grantAction => 'Izinkan';

  @override
  String webPush_couldNotUpdatePermission(String error) {
    return 'Tidak dapat memperbarui izin notifikasi: $error';
  }

  @override
  String get webPush_loadingSubscriptions => 'Memuat langganan…';

  @override
  String get webPush_couldNotReadSubscriptions =>
      'Tidak dapat membaca langganan';

  @override
  String get webPush_noSiteSubscriptions => 'Tidak ada langganan situs';

  @override
  String get webPush_noSiteSubscriptionsDescription =>
      'Situs web yang Anda izinkan mengirim notifikasi akan muncul di sini.';

  @override
  String get webPush_subscriptionActive => 'Aktif';

  @override
  String get webPush_subscriptionDelayedDelivery =>
      'Endpoint tersimpan; pengiriman dijeda sampai distributor siap';

  @override
  String get webPush_subscriptionWaitingForEndpoint =>
      'Menunggu distributor menetapkan endpoint';

  @override
  String get webPush_revokeSubscriptionHint =>
      'Untuk menghentikan notifikasi dari suatu situs, cabut izin notifikasinya di pengaturan situs.';

  @override
  String get webPush_deliverySectionTitle => 'Pengiriman';

  @override
  String get webPush_indexDistributorSubtitle =>
      'Aplikasi yang mengirimkan notifikasi push situs web';

  @override
  String get webPush_indexNotificationPermissionSubtitle =>
      'Diperlukan untuk menampilkan notifikasi situs web';

  @override
  String get webPush_subscriptionsSectionTitle => 'Langganan';

  @override
  String get webPush_indexSiteSubscriptionsTitle => 'Langganan Situs';

  @override
  String get webPush_indexSiteSubscriptionsKeywords =>
      'situs, langganan, sites, subscriptions';

  @override
  String get webPush_indexSiteSubscriptionsSubtitle =>
      'Situs web yang Anda ikuti untuk menerima notifikasi push';

  @override
  String get webSearch_fetchPageDataTitle => 'Ambil Data Halaman';

  @override
  String get webSearch_downloadFailedTapToRetry =>
      'Unduhan gagal — ketuk untuk mencoba lagi';

  @override
  String get webSearch_methodTrafilaturaTitle => 'Pratinjau Hasil Ekstraksi';

  @override
  String get webSearch_methodSinglefileTitle => 'Tangkapan Halaman Penuh';

  @override
  String get webSearch_methodPdfTitle => 'Snapshot PDF';

  @override
  String get webSearch_methodPngTitle => 'Snapshot Gambar';

  @override
  String get webSearch_methodTrafilaturaSubtitle =>
      'Teks dan metadata yang dioptimalkan untuk pembaca, untuk pratinjau di aplikasi';

  @override
  String get webSearch_methodSinglefileSubtitle =>
      'Arsipkan halaman lengkap dengan tata letak dan asetnya untuk digunakan nanti';

  @override
  String get webSearch_methodPdfSubtitle =>
      'Render halaman menjadi PDF untuk dibaca secara luring dan dibagikan';

  @override
  String get webSearch_methodPngSubtitle =>
      'Ambil tangkapan layar PNG satu halaman penuh dari halaman yang dirender';

  @override
  String get webSearch_previewUnavailableTitle => 'Pratinjau tidak tersedia';

  @override
  String get webSearch_previewUnavailableMessage =>
      'Ambil halaman dari daftar hasil sebelum membuka pratinjau.';

  @override
  String get webSearch_openInBrowserTooltip => 'Buka di peramban';

  @override
  String webSearch_torToggleOn(String brand) {
    return '$brand aktif';
  }

  @override
  String webSearch_torToggleOff(String brand) {
    return '$brand nonaktif';
  }

  @override
  String get webSearch_languageAuto => 'Otomatis';

  @override
  String get webSearch_languageAutoDeviceDefault =>
      'Otomatis (bawaan perangkat)';

  @override
  String get webSearch_countryAny => 'Semua';

  @override
  String get webSearch_countryAnyRegion => 'Semua wilayah';

  @override
  String webSearch_countryDeviceDefault(String name) {
    return '$name (perangkat)';
  }

  @override
  String get webSearch_safeSearchPillDefault => 'Aman: bawaan';

  @override
  String get webSearch_safeSearchPillOff => 'Aman: nonaktif';

  @override
  String get webSearch_safeSearchPillModerate => 'Aman: sedang';

  @override
  String get webSearch_safeSearchPillStrict => 'Aman: ketat';

  @override
  String get webSearch_safeSearchMenuDefault => 'Bawaan (sedang)';

  @override
  String get webSearch_safeSearchMenuOff => 'Nonaktif';

  @override
  String get webSearch_safeSearchMenuModerate => 'Sedang';

  @override
  String get webSearch_safeSearchMenuStrict => 'Ketat';

  @override
  String get webSearch_freshnessAnyTime => 'Kapan saja';

  @override
  String get webSearch_freshnessPastDay => '24 jam terakhir';

  @override
  String get webSearch_freshnessPastWeek => 'Seminggu terakhir';

  @override
  String get webSearch_freshnessPastMonth => 'Sebulan terakhir';

  @override
  String get webSearch_freshnessPastYear => 'Setahun terakhir';

  @override
  String get webSearch_modeGeneralLabel => 'Umum';

  @override
  String get webSearch_modeIndependentWebLabel => 'Web Independen';

  @override
  String get webSearch_modeSmallWebLabel => 'Small Web';

  @override
  String get webSearch_modeGeneralDescription =>
      'Hasil seimbang dari seluruh web terbuka';

  @override
  String get webSearch_modeIndependentWebDescription =>
      'Utamakan sumber yang lebih kecil dan kurang korporat';

  @override
  String get webSearch_modeSmallWebDescription =>
      'Situs independen, pribadi, dan bertema khusus';

  @override
  String get webSearch_fetchTooltip => 'Ambil';

  @override
  String get webSearch_additionalSnippetsHeading => 'Cuplikan Tambahan';

  @override
  String get webSearch_questionPrefix => 'T: ';

  @override
  String get webSearch_snippetsTooltip => 'Cuplikan';

  @override
  String webSearch_showMoreLinks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tampilkan $count tautan lagi',
      one: 'Tampilkan 1 tautan lagi',
    );
    return '$_temp0';
  }

  @override
  String get webSearch_factsheetHeading => 'Lembar Fakta';

  @override
  String get webSearch_searchFailedTitle => 'Pencarian gagal';

  @override
  String get webSearch_searchingLabel => 'Mencari di web...';

  @override
  String webSearch_noResultsFor(String query) {
    return 'Tidak ada hasil untuk \"$query\".';
  }

  @override
  String webSearch_creditsTokensStatus(int credits, int tokens) {
    String _temp0 = intl.Intl.pluralLogic(
      credits,
      locale: localeName,
      other: '$credits kredit',
      one: '1 kredit',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tokens,
      locale: localeName,
      other: '$tokens token',
      one: '1 token',
    );
    return '$_temp0  |  $_temp1';
  }

  @override
  String get webSearch_needsCreditsMessage =>
      'Tidak ada kredit atau token pencarian yang tersedia untuk pencarian web baru.';

  @override
  String get webSearch_buySearchPackButton => 'Beli paket pencarian';

  @override
  String get webSearch_socketConnectionError =>
      'Galat koneksi pencarian. Silakan coba lagi.';

  @override
  String get webSearch_closeErrorSessionTimeout =>
      'Sesi pencarian habis waktu. Silakan coba lagi.';

  @override
  String get webSearch_closeErrorCreditInvalid =>
      'Kredit pencarian Anda tidak dapat divalidasi. Kredit mungkin sudah terpakai — silakan coba lagi.';

  @override
  String get webSearch_closeErrorPolicyForbidden =>
      'Halaman yang diminta tidak diizinkan oleh kebijakan pencarian.';

  @override
  String get webSearch_closeErrorServerFailed =>
      'Pencarian gagal di server. Silakan coba lagi.';

  @override
  String webSearch_closeErrorUnknown(int code) {
    return 'Koneksi pencarian tertutup secara tak terduga (kode $code). Silakan coba lagi.';
  }

  @override
  String get webSearch_unknownErrorDetail => 'galat tidak dikenal';

  @override
  String webSearch_streamErrorProtocol(String detail) {
    return 'Galat protokol pencarian. Sesi telah berakhir — silakan coba lagi. ($detail)';
  }

  @override
  String webSearch_streamErrorSearchFailed(String detail) {
    return 'Pencarian gagal di server. Silakan coba lagi. ($detail)';
  }

  @override
  String webSearch_streamErrorFetchFailed(String detail) {
    return 'Tidak dapat mengambil halaman ini dari sumbernya. ($detail)';
  }

  @override
  String webSearch_streamErrorExtractFailed(String detail) {
    return 'Tidak dapat mengekstrak pratinjau yang dapat dibaca dari halaman ini. ($detail)';
  }

  @override
  String webSearch_streamErrorNotAllowed(String detail) {
    return 'Halaman ini tidak diizinkan oleh kebijakan pencarian. ($detail)';
  }

  @override
  String webSearch_streamErrorCaptureFailed(String detail) {
    return 'Tangkapan halaman gagal. ($detail)';
  }

  @override
  String webSearch_streamErrorGeneric(String detail) {
    return 'Galat pencarian: $detail';
  }

  @override
  String webSearch_torStartFailed(String torBrand) {
    return 'Tidak dapat memulai $torBrand untuk pencarian. Nonaktifkan tombol $torBrand atau coba lagi.';
  }

  @override
  String get webSearch_creditCheckFailed =>
      'Tidak dapat memeriksa kredit pencarian. Silakan coba lagi.';

  @override
  String get webSearch_tokenIssuanceFailed =>
      'Tidak dapat menerbitkan token pencarian. Silakan coba lagi.';

  @override
  String get mainApp_initializationErrorTitle => 'Galat Inisialisasi';

  @override
  String get mainApp_initializationErrorMessage =>
      'Tidak dapat menginisialisasi aplikasi';

  @override
  String get mainApp_initStageLoadingFormats => 'Memuat format…';

  @override
  String get mainApp_initStageLoadingPackageInfo =>
      'Memuat informasi aplikasi…';

  @override
  String get mainApp_initStageSyncingBangs => 'Menyinkronkan bang…';

  @override
  String get mainApp_downloadCompleted => 'Unduhan selesai';

  @override
  String get mainApp_downloadOpenFailed =>
      'Tidak dapat membuka berkas yang diunduh';

  @override
  String mainApp_downloadFailed(String name) {
    return 'Unduhan gagal: $name';
  }

  @override
  String mainApp_containerBlockedWithHost(String host) {
    return '$host tidak ditetapkan ke kontainer ini';
  }

  @override
  String get mainApp_containerBlockedNoHost =>
      'Situs ini tidak ditetapkan ke kontainer ini';

  @override
  String get mainApp_sandboxNoCredits =>
      'Kredit pencarian Anda sudah habis. Beli lagi untuk melanjutkan.';

  @override
  String get mainApp_sandboxTokenIssuanceFailed =>
      'Tidak dapat menerbitkan token pencarian baru. Periksa koneksi Anda, lalu coba lagi.';

  @override
  String mainApp_sandboxFetchPolicyRejected(String detail) {
    return 'Tangkapan diblokir oleh kebijakan pengambilan: $detail';
  }

  @override
  String get mainApp_sandboxDetailNotAllowed => 'tidak diizinkan';

  @override
  String mainApp_sandboxCaptureFailed(String detail) {
    return 'Tangkapan gagal: $detail';
  }

  @override
  String get mainApp_sandboxDetailUnknownError => 'galat tidak dikenal';

  @override
  String get mainApp_sandboxDownloadFailed =>
      'Gagal mengunduh hasil tangkapan.';

  @override
  String mainApp_sandboxUnknownError(String detail) {
    return 'Galat tangkapan sandbox: $detail';
  }

  @override
  String get mainApp_syncFailed => 'Sinkronisasi gagal';

  @override
  String get startup_pickerTitle => 'Pilih profil';

  @override
  String startup_pickerEachProfileKeepsOwn(String contents) {
    return 'Setiap profil menyimpan $contents miliknya sendiri.';
  }

  @override
  String get startup_pickerOpensByDefaultLocked => 'Profil bawaan · Terkunci';

  @override
  String get startup_pickerOpensByDefault => 'Profil bawaan';

  @override
  String get startup_pickerLocked => 'Terkunci';

  @override
  String get startup_haltMaintenanceTitle => 'Pekerjaan profil belum selesai';

  @override
  String get startup_haltMaintenanceBody =>
      'Pencadangan, pemulihan, atau penghapusan dari sesi sebelumnya belum selesai. WebLibre harus menyelesaikannya sebelum profil apa pun dapat dibuka.';

  @override
  String get startup_haltUnavailableTitle => 'Proses awal belum siap';

  @override
  String startup_haltUnavailableBody(String reopenToContinue) {
    return 'WebLibre perlu dimulai ulang sebelum dapat memilih profil. $reopenToContinue';
  }

  @override
  String get startup_haltProfileAccessBusyTitle => 'Profil sedang digunakan';

  @override
  String get startup_haltProfileAccessBusyBody =>
      'Tugas WebLibre lain masih menggunakan profil ini. Coba lagi sebentar lagi.';

  @override
  String get startup_haltNoProfileTitle =>
      'Tidak ada profil yang dapat digunakan';

  @override
  String get startup_haltNoProfileBody =>
      'WebLibre tidak dapat membaca profil yang ada atau membuat profil baru. Penyimpanan mungkin penuh atau tidak tersedia.';

  @override
  String get startup_haltArbitrationFailedTitle =>
      'Tidak dapat menentukan profil yang akan dibuka';

  @override
  String startup_haltArbitrationFailedBody(String reopenToContinue) {
    return 'WebLibre tidak akan menebak profil mana yang digunakan. $reopenToContinue';
  }

  @override
  String get startup_tryAgain => 'Coba lagi';

  @override
  String get startup_tryingAgain => 'Mencoba lagi…';

  @override
  String get startup_closeWebLibre => 'Tutup WebLibre';

  @override
  String get startup_technicalDetails => 'Detail teknis';

  @override
  String get startup_copyDetails => 'Salin detail';

  @override
  String get startup_maintenanceFinishingInterrupted =>
      'Menyelesaikan pekerjaan yang terputus oleh mulai ulang sebelumnya…';

  @override
  String get startup_maintenanceNotRunnableUnsupported =>
      'Tugas ini dibuat oleh versi WebLibre yang lebih baru dan tidak dapat dijalankan di sini.';

  @override
  String get startup_maintenanceNotRunnableNoDestination =>
      'Cadangan ini tidak memiliki folder tujuan yang tercatat.';

  @override
  String get startup_maintenanceNotRunnableNoBackupFile =>
      'Pemulihan ini tidak memiliki berkas cadangan yang tercatat.';

  @override
  String get startup_maintenanceNotRunnableRestoreHere =>
      'WebLibre tidak dapat memulihkan dari layar awal ini.';

  @override
  String get startup_maintenanceNotRunnableDeleteHere =>
      'WebLibre tidak dapat menghapus profil dari layar awal ini.';

  @override
  String get startup_maintenanceRecoveredRestore =>
      'Pemulihan yang terputus telah diselesaikan.';

  @override
  String get startup_maintenanceRecoveredRestoreRolledBack =>
      'Pemulihan yang terputus telah dibatalkan. Profil dibiarkan seperti semula.';

  @override
  String get startup_maintenanceRecoveredRestoreReconciled =>
      'Pemulihan yang terputus telah dirapikan. Periksa profil untuk melihat apakah cadangan sudah diterapkan.';

  @override
  String get startup_maintenanceRecoveredDeletion =>
      'Penghapusan yang terputus telah diselesaikan.';

  @override
  String get startup_maintenanceTaskDidNotFinish => 'Tugas tidak selesai.';

  @override
  String startup_maintenanceLeaseLost(
    String nothingChanged,
    String reopenToContinue,
  ) {
    return 'WebLibre tidak dapat lagi bekerja dengan aman pada profil ini. $nothingChanged $reopenToContinue';
  }

  @override
  String startup_maintenanceTaskCancelled(String task) {
    return '$task dibatalkan.';
  }

  @override
  String get startup_maintenanceEvidenceDiscarded =>
      'Catatan tugas yang terputus telah dibuang.';

  @override
  String get startup_maintenanceEvidenceDiscardedKept =>
      'Catatan tugas yang terputus telah dibuang. WebLibre tidak dapat menentukan milik profil mana data yang tersimpan, sehingga data tersebut tetap disimpan di perangkat alih-alih dihapus.';

  @override
  String startup_maintenanceWrongPassword(String nothingChanged) {
    return 'Kata sandi tidak dapat membuka berkas cadangan ini. Periksa, lalu coba lagi. $nothingChanged';
  }

  @override
  String startup_maintenanceUnreadableArchive(String nothingChanged) {
    return 'Kata sandi tidak dapat membuka berkas cadangan ini, atau berkasnya rusak. Periksa kata sandi, lalu coba lagi. $nothingChanged';
  }

  @override
  String startup_maintenanceDamagedArchive(String nothingChanged) {
    return 'Berkas cadangan ini rusak dan tidak dapat dibaca. $nothingChanged';
  }

  @override
  String startup_maintenanceUnsupportedArchiveVersion(String nothingChanged) {
    return 'Berkas cadangan ini dibuat oleh versi WebLibre yang lebih baru dan tidak dapat dibaca di sini. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageWithFree(
    String required,
    String free,
    String nothingChanged,
  ) {
    return 'Ruang kosong tidak cukup: diperlukan sekitar $required, tetapi hanya tersedia $free. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageKnown(
    String required,
    String nothingChanged,
  ) {
    return 'Ruang kosong tidak cukup: diperlukan sekitar $required. $nothingChanged';
  }

  @override
  String startup_maintenanceNotEnoughStorageUnknown(String nothingChanged) {
    return 'Ruang kosong tidak cukup untuk melakukan ini. $nothingChanged';
  }

  @override
  String startup_maintenanceBackupFolderUnavailable(String nothingChanged) {
    return 'Cadangan tidak dapat ditulis ke folder. Pilih folder lagi, lalu coba ulang. $nothingChanged';
  }

  @override
  String get startup_maintenanceProfileNoLongerExists =>
      'Profil tersebut sudah tidak ada.';

  @override
  String get startup_maintenanceRestoreEvidenceUnresolved =>
      'Upaya sebelumnya untuk pemulihan ini meninggalkan catatan yang belum diselesaikan.';

  @override
  String get startup_maintenanceRestoreWrongProfile =>
      'Cadangan ini tidak cocok dengan profil yang akan digantikannya.';

  @override
  String get startup_maintenanceRestoreRejected =>
      'Berkas cadangan ini tidak dapat dipulihkan.';

  @override
  String get startup_maintenanceRestoreIncomplete =>
      'Berkas cadangan tidak lengkap.';

  @override
  String get startup_maintenanceRestoreNoMetadata =>
      'Berkas cadangan tidak memiliki metadata profil.';

  @override
  String get startup_maintenanceRestoreMalformedMetadata =>
      'Metadata profil pada berkas cadangan tidak dapat dibaca.';

  @override
  String get startup_maintenanceRestoreNoProfileData =>
      'Berkas cadangan tidak berisi data profil.';

  @override
  String get startup_maintenanceHeadline => 'Pemeliharaan profil';

  @override
  String get startup_maintenanceMustFinish =>
      'Tugas ini harus selesai sebelum profil apa pun dapat dibuka. WebLibre menjaga profil tetap tertutup selama proses berlangsung.';

  @override
  String get startup_maintenanceNothingLeft =>
      'Tidak ada lagi yang perlu diselesaikan.';

  @override
  String get startup_maintenanceCannotReadRecord =>
      'WebLibre menemukan pekerjaan profil yang terputus, tetapi tidak dapat membaca catatannya.';

  @override
  String get startup_maintenancePasswordLabel => 'Kata sandi berkas cadangan';

  @override
  String get startup_maintenancePasswordRejected =>
      'Kata sandi ini tidak dapat membuka berkas cadangan';

  @override
  String get startup_maintenancePasswordHelperRequiredBackup =>
      'Wajib diisi. Anda memerlukannya untuk memulihkan cadangan, dan kata sandi ini tidak disimpan di mana pun.';

  @override
  String get startup_maintenancePasswordHelperRequiredRestore =>
      'Wajib diisi. Masukkan kata sandi yang digunakan saat membuat berkas cadangan ini.';

  @override
  String get startup_maintenancePasswordHelperBackup =>
      'Anda memerlukannya untuk memulihkan cadangan. Kata sandi ini tidak disimpan di mana pun.';

  @override
  String get startup_maintenancePasswordHelperRestore =>
      'Kata sandi yang digunakan saat membuat berkas cadangan ini.';

  @override
  String get startup_maintenanceTryFinishingAgain => 'Coba selesaikan lagi';

  @override
  String get startup_maintenanceDiscardAndContinueBlocked =>
      'Buang catatan dan lanjutkan';

  @override
  String get startup_maintenanceDiscardAndContinueNoTasks =>
      'Buang catatan dan lanjutkan';

  @override
  String get startup_maintenanceOpenWebLibreRetry => 'Buka WebLibre';

  @override
  String get startup_maintenanceOpenWebLibre => 'Buka WebLibre';

  @override
  String get startup_maintenanceTakesSeveralMinutes =>
      'Ini dapat memakan waktu beberapa menit. Biarkan WebLibre tetap terbuka.';

  @override
  String get startup_maintenanceThenAfterThisOne =>
      'Selanjutnya, setelah yang ini';

  @override
  String get startup_maintenanceSkipForNow => 'Lewati untuk saat ini';

  @override
  String get startup_maintenanceInterruptedMustFinish =>
      'Tugas ini terputus setelah dimulai. Tugas ini harus selesai sebelum profil apa pun dapat dibuka.';

  @override
  String get startup_maintenanceInterruptedFinishFailed =>
      'Tugas ini terputus setelah dimulai, dan upaya menyelesaikannya tidak berhasil. Tugas ini tidak dapat dimulai ulang sebelum diselesaikan.';

  @override
  String get startup_maintenanceInterruptedUnreadable =>
      'Tugas ini terputus setelah dimulai, dan WebLibre tidak dapat membaca apa yang sedang dikerjakannya. Tugas ini tidak dapat dijalankan lagi sebelum catatan tersebut ditangani.';

  @override
  String get startup_maintenanceDiscardDialogTitle =>
      'Buang catatan tugas yang terputus?';

  @override
  String get startup_maintenanceDiscardDialogContent =>
      'WebLibre tidak dapat membaca apa yang sedang dilakukan oleh pencadangan, pemulihan, atau penghapusan saat terhenti. Membuang catatan memungkinkan peramban dibuka lagi, tetapi profil yang sedang digantikan mungkin perlu diperiksa setelahnya.\n\nJika profil tersebut hilang, WebLibre memulihkan data yang disimpannya sebelum penggantian. Jika profil tersebut ada, WebLibre menghapus data tersimpan itu. Jika WebLibre tidak dapat menentukan milik profil mana data tersimpan tersebut, data itu tetap disimpan alih-alih dihapus.';

  @override
  String get startup_maintenanceDiscardIt => 'Buang';

  @override
  String get startup_maintenanceBackupVerb => 'Cadangkan sekarang';

  @override
  String get startup_maintenanceBackupRetry => 'Coba cadangkan lagi';

  @override
  String get startup_maintenanceBackupCancel => 'Batalkan pencadangan ini';

  @override
  String startup_maintenanceBackupDescribe(String profileName) {
    return 'Cadangkan \"$profileName\"';
  }

  @override
  String startup_maintenanceBackupConsequence(String secretDataDescription) {
    return 'Menulis berkas cadangan terenkripsi dari profil ini, termasuk $secretDataDescription.';
  }

  @override
  String startup_maintenanceBackupActivity(String profileName) {
    return 'Mengemas \"$profileName\"…';
  }

  @override
  String startup_maintenanceBackupDescribeDone(String profileName) {
    return '\"$profileName\" telah dicadangkan ke folder yang Anda pilih.';
  }

  @override
  String get startup_maintenanceRestoreOverVerb => 'Ganti sekarang';

  @override
  String get startup_maintenanceRestoreOverRetry => 'Coba pulihkan lagi';

  @override
  String get startup_maintenanceRestoreOverCancel => 'Batalkan pemulihan ini';

  @override
  String startup_maintenanceRestoreOverDescribe(String profileName) {
    return 'Ganti \"$profileName\"';
  }

  @override
  String startup_maintenanceRestoreOverConsequenceWithRename(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Mengganti semua isi profil ini dengan cadangan. $signedInFromBackup $olderBackupKeepsCredentials Profil ini juga akan memakai nama dari cadangan. $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverConsequencePlain(
    String signedInFromBackup,
    String olderBackupKeepsCredentials,
    String cannotBeUndone,
  ) {
    return 'Mengganti semua isi profil ini dengan cadangan. $signedInFromBackup $olderBackupKeepsCredentials $cannotBeUndone';
  }

  @override
  String startup_maintenanceRestoreOverActivity(String profileName) {
    return 'Mengganti \"$profileName\"…';
  }

  @override
  String startup_maintenanceRestoreOverDescribeDone(String profileName) {
    return '\"$profileName\" telah diganti dengan cadangan.';
  }

  @override
  String get startup_maintenanceDeleteVerb => 'Hapus sekarang';

  @override
  String get startup_maintenanceDeleteRetry => 'Coba hapus lagi';

  @override
  String get startup_maintenanceDeleteCancel => 'Batalkan penghapusan ini';

  @override
  String startup_maintenanceDeleteDescribe(String profileName) {
    return 'Hapus \"$profileName\"';
  }

  @override
  String startup_maintenanceDeleteConsequence(
    String profileDataDescription,
    String cannotBeUndone,
  ) {
    return 'Menghapus profil ini beserta $profileDataDescription. $cannotBeUndone';
  }

  @override
  String startup_maintenanceDeleteActivity(String profileName) {
    return 'Menghapus \"$profileName\"…';
  }

  @override
  String startup_maintenanceDeleteDescribeDone(String profileName) {
    return '\"$profileName\" telah dihapus.';
  }

  @override
  String get startup_maintenanceRestoreCloneVerb => 'Tidak dapat dijalankan';

  @override
  String get startup_maintenanceRestoreCloneRetry => 'Coba pulihkan lagi';

  @override
  String get startup_maintenanceRestoreCloneCancel => 'Batalkan pemulihan ini';

  @override
  String startup_maintenanceRestoreCloneDescribe(String profileName) {
    return 'Pulihkan \"$profileName\"';
  }

  @override
  String get startup_maintenanceRestoreCloneConsequence =>
      'Pemulihan ini dibuat oleh versi WebLibre yang lebih baru dan tidak dapat dijalankan di sini.';

  @override
  String startup_maintenanceRestoreCloneActivity(String profileName) {
    return 'Memulihkan \"$profileName\"…';
  }

  @override
  String startup_maintenanceRestoreCloneDescribeDone(String profileName) {
    return '\"$profileName\" telah dipulihkan.';
  }

  @override
  String get startup_maintenanceUnknownVerb => 'Jalankan';

  @override
  String get startup_maintenanceUnknownRetry => 'Coba jalankan tugas lagi';

  @override
  String get startup_maintenanceUnknownCancel => 'Batalkan tugas ini';

  @override
  String startup_maintenanceUnknownDescribe(String taskId) {
    return 'Tugas tidak dikenal $taskId';
  }

  @override
  String get startup_maintenanceUnknownConsequence =>
      'Tugas ini dibuat oleh versi WebLibre yang lebih baru dan tidak dapat dijalankan.';

  @override
  String get startup_maintenanceUnknownActivity => 'Sedang bekerja…';

  @override
  String get startup_maintenanceUnknownDescribeDone => 'Selesai.';

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
  String get failureWidget_defaultTitle => 'Terjadi kesalahan';

  @override
  String get failureWidget_unknownError => 'Galat tidak dikenal';

  @override
  String get speechToTextButton_serviceNotAvailable =>
      'Pengenalan suara tidak tersedia';

  @override
  String get formValidators_urlRequired => 'URL wajib diisi';

  @override
  String get formValidators_invalidUrl => 'URL tidak valid';

  @override
  String get formValidators_valueRequired => 'Nilai wajib diisi';

  @override
  String get formValidators_nameRequired => 'Nama wajib diisi';

  @override
  String get formValidators_nameInvalidCharacters =>
      'Nama berisi karakter yang tidak valid';

  @override
  String uiHelper_findInPageSuggestion(String query) {
    return 'Cari \"$query\" di halaman ini?';
  }

  @override
  String get uiHelper_actionFind => 'Cari';

  @override
  String uiHelper_openedTabsFromAnotherDevice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab dari perangkat lain dibuka',
      one: '1 tab dari perangkat lain dibuka',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_navigateBackToCloseTab =>
      'Tekan KEMBALI sekali lagi untuk menutup tab saat ini';

  @override
  String get uiHelper_navigateBackToExitApp =>
      'Tekan KEMBALI sekali lagi untuk keluar dari aplikasi';

  @override
  String uiHelper_newTabOpenedInBackgroundNamed(String tabName) {
    return 'Tab baru \"$tabName\" dibuka di latar belakang';
  }

  @override
  String get uiHelper_newTabOpenedInBackground =>
      'Tab baru dibuka di latar belakang';

  @override
  String get uiHelper_actionShow => 'Tampilkan';

  @override
  String get uiHelper_wantToOpenLinkFromClipboard =>
      'Buka tautan dari papan klip Anda?';

  @override
  String uiHelper_newTabOpenedNamed(String tabName) {
    return 'Tab baru \"$tabName\" dibuka';
  }

  @override
  String get uiHelper_newTabOpened => 'Tab baru dibuka';

  @override
  String get uiHelper_actionSwitch => 'Beralih';

  @override
  String uiHelper_couldNotLaunchUrl(String url) {
    return 'Tidak dapat membuka URL ($url)';
  }

  @override
  String uiHelper_canNotHandleScheme(String scheme) {
    return 'Tidak dapat menangani \"$scheme\"';
  }

  @override
  String uiHelper_tabsClosedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tab ditutup',
      one: 'Tab ditutup',
    );
    return '$_temp0';
  }

  @override
  String get uiHelper_closeIsolatedTabsTitle => 'Tutup tab terisolasi?';

  @override
  String uiHelper_closeIsolatedTabsConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ini akan menghapus permanen data penjelajahan untuk $count sesi terisolasi.',
      one:
          'Ini akan menghapus permanen semua data penjelajahan untuk sesi terisolasi ini.',
    );
    return '$_temp0';
  }
}
