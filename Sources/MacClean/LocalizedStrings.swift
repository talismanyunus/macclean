import Foundation

// MARK: - Language

enum Language: String, CaseIterable, Identifiable {
    case turkish = "tr"
    case english = "en"
    case russian = "ru"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        case .russian: return "Русский"
        }
    }

    var flagEmoji: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇬🇧"
        case .russian: return "🇷🇺"
        }
    }

    var shortName: String {
        switch self {
        case .turkish: return "TR"
        case .english: return "EN"
        case .russian: return "RU"
        }
    }
}

// MARK: - Localization function

/// Returns the localized string for the current language.
/// Usage: L(.appSubtitle)
func L(_ key: StringKey) -> String {
    key.string(for: LanguageStore.current)
}

// MARK: - String Keys

enum StringKey {
    // App
    case appName
    case appSubtitle

    // Sidebar section headers
    case sidebarSectionClean
    case sidebarSectionFolderInspect
    case sidebarSectionSystemData

    // Sidebar items
    case sidebarOverview
    case sidebarDetailedInspect
    case sidebarStatusScanning
    case sidebarStatusSetAccess
    case sidebarStatusChooseFolder
    case sidebarStatusInspect

    // Sidebar privacy card
    case privacyCardAppStoreTitle
    case privacyCardDirectTitle
    case privacyCardHomeFolderSaved
    case privacyCardHomeFolderRequired
    case privacyCardChangeHomeFolder
    case privacyCardSelectHomeFolder
    case privacyCardFullDiskEnabled
    case privacyCardFullDiskRequired
    case privacyCardSetAccess
    case privacyCardPrivacy

    // Language switcher
    case sidebarChangeLanguage

    // Overview
    case overviewTitle
    case overviewSubtitle
    case overviewMetricFound
    case overviewMetricSelected
    case overviewMetricSafeMode
    case overviewMetricSafeModeValue
    case overviewCleanupSummary

    // Scanning card
    case scanningCardTitle
    case scanningCardSubtitle

    // System data note
    case systemDataNoteTitle
    case systemDataNoteBodyAppStore
    case systemDataNoteBodyDirect

    // Category detail
    case categorySelectAll
    case categoryDeselectAll
    case categoryItemCount  // %d öğe · %@
    case categoryEmpty
    case categoryEmptyDescription
    case categoryRescan
    case categoryRescanInProgress
    case categoryUpdating

    // Action bar
    case actionBarItemsSelected    // %d öğe seçildi
    case actionBarWillProcess      // %@ işlenecek
    case actionBarCleaning
    case actionBarClean

    // Error alert
    case errorAlertTitle
    case errorAlertOk

    // System data inspector
    case inspectorTitleAppStore
    case inspectorSubtitleAppStore
    case inspectorTitleDirect
    case inspectorSubtitleDirect
    case inspectorRescan
    case inspectorChooseFolder
    case inspectorSetAccess
    case inspectorScanningTitle
    case inspectorScanningSubtitle
    case inspectorNotStartedTitle
    case inspectorNotStartedDescription
    case inspectorSummaryTitle     // %@ ayrıntılı olarak bulundu
    case inspectorSummaryBody
    case inspectorHighlightsTitle
    case inspectorHighlightsSubtitle
    case inspectorChooseFolderButton
    case inspectorRescanButton

    // Cleanup review sheet
    case reviewTitle
    case reviewSubtitle
    case reviewItemCount           // %d öğe · %@
    case reviewWillTrash           // %@ Çöp Kutusu'na taşınacak
    case reviewWillDelete
    case reviewBadgePermanent
    case reviewBadgeTrash
    case reviewBack
    case reviewConfirm
    case reviewProtectedHeader

    // Outcome card
    case outcomeTitle
    case outcomeFailedTitle
    case outcomePermanentlyDeleted // %@ kalıcı olarak silindi
    case outcomeMovedToTrash       // %@ Çöp Kutusu'na taşındı
    case outcomeFailedItems        // %d öğe işlenemedi

    // Folder browser sheet
    case folderBrowserGoUp
    case folderBrowserSelectAll
    case folderBrowserDeselectAll
    case folderBrowserItemCount    // %d öğe · %@
    case folderBrowserLoading
    case folderBrowserEmpty
    case folderBrowserSelectedCount   // %d öğe seçildi
    case folderBrowserWillTrash       // %@ Çöp Kutusu'na taşınacak
    case folderBrowserWillDelete      // %@ kalıcı silinecek
    case folderBrowserClose
    case folderBrowserMoveToTrash
    case folderBrowserRemove
    case folderBrowserAlertTrashTitle
    case folderBrowserAlertDeleteTitle
    case folderBrowserAlertCancel
    case folderBrowserAlertConfirmTrash
    case folderBrowserAlertConfirmDelete
    case folderBrowserAlertTrashMessage   // %d öğe (%@) Çöp Kutusu'na taşınacak...
    case folderBrowserAlertDeleteMessage  // %d öğe (%@) kalıcı olarak silinecek...
    case folderBrowserResultTitle
    case folderBrowserResultSuccessTrash  // %d öğe Çöp Kutusu'na taşındı.
    case folderBrowserResultSuccessDelete // %d öğe kalıcı olarak silindi.
    case folderBrowserResultPartial       // %d öğe işlendi, %d öğe kaldırılamadı.
    case folderBrowserContentRow

    // System storage browser sheet
    case storageBrowserLoading
    case storageBrowserEmpty
    case storageBrowserRemove
    case storageBrowserClose
    case storageBrowserAlertTitle  // Çöp Kutusu'na taşı?
    case storageBrowserAlertCancel
    case storageBrowserAlertConfirm
    case storageBrowserAlertMessage  // %@ (%@) Çöp Kutusu'na taşınacak...
    case storageBrowserResultTitle
    case storageBrowserResultSuccess // Çöp Kutusu'na taşındı: %@.
    case storageBrowserResultFailure // Kaldırılamadı: %@

    // WhatsApp sheet
    case whatsappSheetTitle
    case whatsappSheetSubtitle
    case whatsappSheetPrivacyNote
    case whatsappSheetLoading
    case whatsappSheetEmptyTitle
    case whatsappSheetEmptyDescription
    case whatsappSheetChatCount     // %d sohbet veya medya kaynağı
    case whatsappSheetManage
    case whatsappSheetClose
    case whatsappSheetChatSubtitle  // %@ · %d medya · Ayrıntılar
    case whatsappKindDirect
    case whatsappKindGroup
    case whatsappKindStatus
    case whatsappKindUnknown

    // WhatsApp removal sheet
    case whatsappRemovalMediaCount  // %d yerel medya dosyası
    case whatsappRemovalVerified
    case whatsappRemovalLabel1
    case whatsappRemovalLabel2
    case whatsappRemovalLabel3
    case whatsappRemovalBack
    case whatsappRemovalConfirmButton
    case whatsappRemovalAlertTitle
    case whatsappRemovalAlertCancel
    case whatsappRemovalAlertConfirm
    case whatsappRemovalAlertMessage  // %d medya dosyası (%@) Çöp Kutusu'na taşınacak...
    case whatsappRemovalResultTitle
    case whatsappRemovalResultSuccess // Çöp Kutusu'na taşındı: %d medya dosyası.
    case whatsappRemovalResultFailure // Kaldırılamadı: %@
    case whatsappFallbackStatusMedia
    case whatsappFallbackGroup

    // Setup sheets
    case homeFolderSetupTitle
    case homeFolderSetupCancel
    case homeFolderSetupConfirm

    case fullDiskSetupTitle
    case fullDiskSetupCancel
    case fullDiskSetupOpenSettings
    case fullDiskSetupConfirm

    // Required access placeholder views
    case homeFolderRequiredTitle
    case homeFolderRequiredDescription
    case homeFolderRequiredButton

    case fullDiskRequiredTitle
    case fullDiskRequiredDescription
    case fullDiskRequiredButton

    case systemDataFolderRequiredTitle
    case systemDataFolderRequiredDescription
    case systemDataFolderRequiredButton

    // Privacy policy sheet
    case privacyPolicyTitle
    case privacyPolicyBody
    case privacyPolicyRevokeAccess
    case privacyPolicyClose

    // NSOpenPanel
    case panelHomeFolderTitle
    case panelHomeFolderMessage
    case panelHomeFolderPrompt
    case panelSystemDataTitle
    case panelSystemDataMessage
    case panelSystemDataPrompt

    // ViewModel error messages
    case errorWrongHomeFolder    // %@
    case errorSaveBookmark       // %@
    case errorSaveSystemBookmark // %@

    // Disk usage
    case diskFreeSpace   // %@ boş
    case diskUsedOf      // %@ kullanılıyor · Toplam %@
    case diskUsagePercent // Disk kullanımı %%%d
    case diskFreeSpaceBadge
    case diskOpenSpace   // %@ boş alan
    case diskAccessibilityRing // Disk kullanımı yüzde %d

    // Category model strings
    case categoryCachesTitle
    case categoryCachesSubtitle
    case categoryCachesSafetyNote
    case categoryCachesReviewDesc
    case categoryCachesProtectedNote

    case categoryLogsTitle
    case categoryLogsSubtitle
    case categoryLogsSafetyNote
    case categoryLogsReviewDesc

    case categoryDeveloperTitle
    case categoryDeveloperSubtitle
    case categoryDeveloperSafetyNote
    case categoryDeveloperReviewDesc
    case categoryDeveloperProtectedNote

    case categoryInstallersTitle
    case categoryInstallersSubtitle
    case categoryInstallersSafetyNote
    case categoryInstallersReviewDesc
    case categoryInstallersProtectedNote

    case categoryLargeFilesTitle
    case categoryLargeFilesSubtitle
    case categoryLargeFilesSafetyNote
    case categoryLargeFilesReviewDesc
    case categoryLargeFilesProtectedNote

    case categoryTrashTitle
    case categoryTrashSubtitle
    case categoryTrashSafetyNote
    case categoryTrashReviewDesc

    // StorageAction
    case storageActionManageInAppTitle
    case storageActionManageInAppDetail
    case storageActionManageInXcodeTitle
    case storageActionManageInXcodeDetail
    case storageActionManageInDockerTitle
    case storageActionManageInDockerDetail
    case storageActionRemoveIfUnusedTitle
    case storageActionRemoveIfUnusedDetail
    case storageActionInspectFirstTitle
    case storageActionInspectFirstDetail

    // SystemDataScanner
    case systemAreaSelectedFolder
    case systemAreaSelectedSubtitle
    case systemAreaAppData
    case systemAreaAppDataSubtitle
    case systemAreaSharedAppData
    case systemAreaSharedAppDataSubtitle
    case systemAreaDeveloperData
    case systemAreaDeveloperDataSubtitle
    case systemAreaSandboxData
    case systemAreaSandboxDataSubtitle
    case systemMetaWhatsApp
    case systemMetaWhatsAppSummary
    case systemMetaKiro
    case systemMetaKiroSummary
    case systemMetaCoreSimulator
    case systemMetaCoreSimulatorSummary
    case systemMetaDocker
    case systemMetaDockerSummary
    case systemMetaMuMu
    case systemMetaMuMuSummary
    case systemMetaBrowser
    case systemMetaBrowserSummary
    case systemMetaCodeEditor
    case systemMetaCodeEditorSummary
    case systemMetaGenericApp

    // Storage browser go up (used in SystemStorageBrowserSheet)
    case storageBrowserGoUp

    // Setup sheet step labels
    case fullDiskSetupStep1
    case fullDiskSetupStep2
    case homeFolderSetupStep1
    case homeFolderSetupStep2

    // Privacy policy additional note
    case privacyPolicyAdditionalNote
    case privacyPolicyContact
    case privacyPolicyTermsLink
    case privacyPolicyPolicyLink

    // Onboarding
    case onboardingWelcomeTitle
    case onboardingWelcomeSubtitle
    case onboardingChooseLanguage
    case onboardingContinue
    case onboardingGetStarted
    case onboardingSkip
    case onboardingBack
    case onboardingStep         // %d / %d

    case onboardingSlide2Title
    case onboardingSlide2Body
    case onboardingSlide3Title
    case onboardingSlide3Body
    case onboardingSlide4Title
    case onboardingSlide4Body
}

// MARK: - Translations

extension StringKey {
    // swiftlint:disable cyclomatic_complexity function_body_length
    func string(for language: Language) -> String {
        switch language {
        case .turkish: return turkishString
        case .english: return englishString
        case .russian: return russianString
        }
    }

    private var turkishString: String {
        switch self {
        case .appName: return "MacClean"
        case .appSubtitle: return "Depolama yardımcısı"

        case .sidebarSectionClean: return "TEMİZLENECEKLER"
        case .sidebarSectionFolderInspect: return "KLASÖR İNCELEME"
        case .sidebarSectionSystemData: return "SİSTEM VERİSİ"

        case .sidebarOverview: return "Genel bakış"
        case .sidebarDetailedInspect: return "Detaylı inceleme"
        case .sidebarStatusScanning: return "Taranıyor…"
        case .sidebarStatusSetAccess: return "Erişimi ayarla"
        case .sidebarStatusChooseFolder: return "Klasör seç"
        case .sidebarStatusInspect: return "İncele"

        case .privacyCardAppStoreTitle: return "App Store güvenlik modeli"
        case .privacyCardDirectTitle: return "Tek seferlik sistem erişimi"
        case .privacyCardHomeFolderSaved: return "Ana klasör erişimi saklandı. İstersen seçimi değiştirebilirsin."
        case .privacyCardHomeFolderRequired: return "Temizlik için ana klasörünü bir kez seçmen gerekir."
        case .privacyCardChangeHomeFolder: return "Ana klasörü değiştir"
        case .privacyCardSelectHomeFolder: return "Ana klasörü seç"
        case .privacyCardFullDiskEnabled: return "Tam Disk Erişimi etkin. Uygulama yeniden izin istemez."
        case .privacyCardFullDiskRequired: return "Sistem Verisi için macOS'tan yalnızca bir kez erişim vermen gerekir."
        case .privacyCardSetAccess: return "Erişimi ayarla"
        case .privacyCardPrivacy: return "Gizlilik"

        case .sidebarChangeLanguage: return "Dili değiştir"

        case .overviewTitle: return "Mac'inde yer aç"
        case .overviewSubtitle: return "Neyi temizleyeceğini sen seç; uygulama önce sonuçları gösterir."
        case .overviewMetricFound: return "Bulunan temizlenebilir alan"
        case .overviewMetricSelected: return "Seçili öğeler"
        case .overviewMetricSafeMode: return "Güvenli mod"
        case .overviewMetricSafeModeValue: return "Açık"
        case .overviewCleanupSummary: return "Temizlik özeti"

        case .scanningCardTitle: return "Mac'in taranıyor"
        case .scanningCardSubtitle: return "Önbellekler ve seçili klasörlerdeki büyük dosyalar hesaplanıyor."

        case .systemDataNoteTitle: return "\"Sistem Verisi\" çok büyük görünüyorsa"
        case .systemDataNoteBodyAppStore: return "App Store sürümü, yalnızca senin açıkça seçtiğin ana klasördeki önbellekleri, günlükleri, Xcode artıkları ve büyük dosyaları inceler."
        case .systemDataNoteBodyDirect: return "MacClean, önbellekler ve Xcode artıkları gibi güvenli alanları otomatik tarar. Sistem verisi incelemesi için macOS'tan bir kez Tam Disk Erişimi istenir."

        case .categorySelectAll: return "Tümünü seç"
        case .categoryDeselectAll: return "Tüm seçimi kaldır"
        case .categoryItemCount: return "%d öğe · %@"
        case .categoryEmpty: return "Temizlenecek öğe bulunamadı"
        case .categoryEmptyDescription: return "Bu kategori şu an temiz görünüyor."
        case .categoryRescan: return "Tekrar tara"
        case .categoryRescanInProgress: return "Taranıyor…"
        case .categoryUpdating: return "Güncelleniyor"

        case .actionBarItemsSelected: return "%d öğe seçildi"
        case .actionBarWillProcess: return "%@ işlenecek"
        case .actionBarCleaning: return "Temizleniyor…"
        case .actionBarClean: return "Alan aç"

        case .errorAlertTitle: return "İşlem tamamlanamadı"
        case .errorAlertOk: return "Tamam"

        case .inspectorTitleAppStore: return "Seçili klasörü incele"
        case .inspectorSubtitleAppStore: return "Yalnızca senin seçtiğin klasördeki büyük öğeleri gösterir. Bu ekran hiçbir şeyi otomatik silmez."
        case .inspectorTitleDirect: return "Sistem Verisi incelemesi"
        case .inspectorSubtitleDirect: return "Büyük uygulama verilerinin nerede olduğunu gösterir. Bu ekran hiçbir şeyi otomatik silmez."
        case .inspectorRescan: return "Tekrar tara"
        case .inspectorChooseFolder: return "Klasör seç"
        case .inspectorSetAccess: return "Erişimi ayarla"
        case .inspectorScanningTitle: return "Büyük uygulama klasörleri taranıyor"
        case .inspectorScanningSubtitle: return "WhatsApp, Kiro, iOS simülatörleri, Docker, MuMu ve diğer uygulama verileri ayrı ayrı hesaplanıyor."
        case .inspectorNotStartedTitle: return "İnceleme henüz başlatılmadı"
        case .inspectorNotStartedDescription: return "\"Tekrar tara\" düğmesi uygulama verilerini ve geliştirici verilerini analiz eder."
        case .inspectorSummaryTitle: return "%@ ayrıntılı olarak bulundu"
        case .inspectorSummaryBody: return "Bu toplam; erişebildiğimiz uygulama verileridir. macOS'un Sistem Verisi sayısıyla bire bir aynı olmak zorunda değildir; korumalı sistem dosyaları ve APFS bileşenleri bu ekranda silinmez."
        case .inspectorHighlightsTitle: return "Öne çıkan büyük alanlar"
        case .inspectorHighlightsSubtitle: return "Bu öğeler Sistem Verisi içinde en çok alan kaplayan, uygulama bazlı depolardır."
        case .inspectorChooseFolderButton: return "Klasör seç"
        case .inspectorRescanButton: return "Tekrar tara"

        case .reviewTitle: return "Temizlemeden önce incele"
        case .reviewSubtitle: return "Seçili her kategorinin ne yaptığını aşağıda görebilirsin. Emin olmadığın öğeyi önce geri dönüp seçme."
        case .reviewItemCount: return "%d öğe · %@"
        case .reviewWillTrash: return "%@ Çöp Kutusu'na taşınacak"
        case .reviewWillDelete: return "Seçili veriler kalıcı olarak silinecek"
        case .reviewBadgePermanent: return "Kalıcı silme"
        case .reviewBadgeTrash: return "Çöp Kutusu'na taşı"
        case .reviewBack: return "Geri dön"
        case .reviewConfirm: return "Bu seçimi temizle"
        case .reviewProtectedHeader: return "Bu araç hiçbir zaman şunları taramaz"

        case .outcomeTitle: return "Temizlik tamamlandı"
        case .outcomeFailedTitle: return "Temizlenecek öğe işlenemedi"
        case .outcomePermanentlyDeleted: return "%@ kalıcı olarak silindi"
        case .outcomeMovedToTrash: return "%@ Çöp Kutusu'na taşındı"
        case .outcomeFailedItems: return "%d öğe işlenemedi"

        case .folderBrowserGoUp: return "Üst klasöre dön"
        case .folderBrowserSelectAll: return "Tümünü seç"
        case .folderBrowserDeselectAll: return "Tüm seçimi kaldır"
        case .folderBrowserItemCount: return "%d öğe · %@"
        case .folderBrowserLoading: return "Klasör içeriği hesaplanıyor…"
        case .folderBrowserEmpty: return "Bu klasör boş"
        case .folderBrowserSelectedCount: return "%d öğe seçildi"
        case .folderBrowserWillTrash: return "%@ Çöp Kutusu'na taşınacak"
        case .folderBrowserWillDelete: return "%@ kalıcı silinecek"
        case .folderBrowserClose: return "Kapat"
        case .folderBrowserMoveToTrash: return "Çöp Kutusu'na taşı"
        case .folderBrowserRemove: return "Kaldır"
        case .folderBrowserAlertTrashTitle: return "Seçili öğeler Çöp Kutusu'na taşınsın mı?"
        case .folderBrowserAlertDeleteTitle: return "Seçili öğeler kalıcı silinsin mi?"
        case .folderBrowserAlertCancel: return "Vazgeç"
        case .folderBrowserAlertConfirmTrash: return "Çöp Kutusu'na taşı"
        case .folderBrowserAlertConfirmDelete: return "Kalıcı sil"
        case .folderBrowserAlertTrashMessage: return "%d öğe (%@) Çöp Kutusu'na taşınacak. Alanın gerçekten boşalması için Çöp Kutusu'nu ayrıca boşaltmalısın."
        case .folderBrowserAlertDeleteMessage: return "%d öğe (%@) kalıcı olarak silinecek. Bu işlem geri alınamaz."
        case .folderBrowserResultTitle: return "Kaldırma sonucu"
        case .folderBrowserResultSuccessTrash: return "%d öğe Çöp Kutusu'na taşındı."
        case .folderBrowserResultSuccessDelete: return "%d öğe kalıcı olarak silindi."
        case .folderBrowserResultPartial: return "%d öğe işlendi, %d öğe kaldırılamadı."
        case .folderBrowserContentRow: return "İçeriğini görüntüle"

        case .storageBrowserLoading: return "İçerik hesaplanıyor…"
        case .storageBrowserEmpty: return "İçerik bulunamadı"
        case .storageBrowserRemove: return "Kaldır"
        case .storageBrowserClose: return "Kapat"
        case .storageBrowserAlertTitle: return "Çöp Kutusu'na taşı?"
        case .storageBrowserAlertCancel: return "Vazgeç"
        case .storageBrowserAlertConfirm: return "Kaldır"
        case .storageBrowserAlertMessage: return "%@ (%@) Çöp Kutusu'na taşınacak. Uygulama ya da emülatör açıksa önce kapatman iyi olur. Alanın gerçekten boşalması için Çöp Kutusu'nu ayrıca boşaltmalısın."
        case .storageBrowserResultTitle: return "Kaldırma sonucu"
        case .storageBrowserResultSuccess: return "Çöp Kutusu'na taşındı: %@."
        case .storageBrowserResultFailure: return "Kaldırılamadı: %@"

        case .whatsappSheetTitle: return "WhatsApp medya dökümü"
        case .whatsappSheetSubtitle: return "Sohbet isimleri, WhatsApp'ın yerel sohbet kaydından salt-okunur olarak eşleştirildi."
        case .whatsappSheetPrivacyNote: return "Mesaj içeriklerini okumuyoruz. Bu liste yalnızca sohbet adı, medya sayısı ve kaplanan alanı gösterir."
        case .whatsappSheetLoading: return "Sohbet medyaları eşleştiriliyor…"
        case .whatsappSheetEmptyTitle: return "Medya eşlemesi bulunamadı"
        case .whatsappSheetEmptyDescription: return "WhatsApp medya klasörü veya yerel sohbet kaydı okunamadı."
        case .whatsappSheetChatCount: return "%d sohbet veya medya kaynağı"
        case .whatsappSheetManage: return "Yönet"
        case .whatsappSheetClose: return "Kapat"
        case .whatsappSheetChatSubtitle: return "%@ · %d medya · Ayrıntılar"
        case .whatsappKindDirect: return "Kişisel sohbet"
        case .whatsappKindGroup: return "Grup"
        case .whatsappKindStatus: return "Durum medyaları"
        case .whatsappKindUnknown: return "Sohbet"

        case .whatsappRemovalMediaCount: return "%d yerel medya dosyası"
        case .whatsappRemovalVerified: return "medya klasöründe doğrulandı"
        case .whatsappRemovalLabel1: return "Kaldır seçeneği yalnızca bu sohbete ait yerel medya klasörünü taşır."
        case .whatsappRemovalLabel2: return "Mesaj metinlerine ve WhatsApp'ın sohbet veritabanına dokunmaz. Sohbet WhatsApp'ta kalır; taşınan eski medyalar orada açılamayabilir."
        case .whatsappRemovalLabel3: return "Sohbetin kendisini silmek için WhatsApp'ı kullanmalısın. Alanın gerçekten boşalması için Çöp Kutusu'nu ayrıca boşaltmalısın."
        case .whatsappRemovalBack: return "Geri"
        case .whatsappRemovalConfirmButton: return "Medyayı Çöp Kutusu'na taşı"
        case .whatsappRemovalAlertTitle: return "Bu sohbete ait medyalar taşınsın mı?"
        case .whatsappRemovalAlertCancel: return "Vazgeç"
        case .whatsappRemovalAlertConfirm: return "Çöp Kutusu'na taşı"
        case .whatsappRemovalAlertMessage: return "%d medya dosyası (%@) Çöp Kutusu'na taşınacak. Önce WhatsApp'ı kapatman iyi olur. Bu işlem sohbet metinlerini silmez."
        case .whatsappRemovalResultTitle: return "Kaldırma sonucu"
        case .whatsappRemovalResultSuccess: return "Çöp Kutusu'na taşındı: %d medya dosyası."
        case .whatsappRemovalResultFailure: return "Kaldırılamadı: %@"
        case .whatsappFallbackStatusMedia: return "WhatsApp durum medyaları"
        case .whatsappFallbackGroup: return "Grup sohbeti"

        case .homeFolderSetupTitle: return "Ana klasörünü bir kez seç"
        case .homeFolderSetupCancel: return "Vazgeç"
        case .homeFolderSetupConfirm: return "Ana klasörü seç"

        case .fullDiskSetupTitle: return "Bunu yalnızca bir kez ayarla"
        case .fullDiskSetupCancel: return "Vazgeç"
        case .fullDiskSetupOpenSettings: return "Sistem Ayarlarını aç"
        case .fullDiskSetupConfirm: return "Erişimi etkinleştirdim"

        case .homeFolderRequiredTitle: return "Ana klasör erişimi gerekli"
        case .homeFolderRequiredDescription: return "MacClean, önbellekler ve büyük dosyalar gibi temizlenebilir içerikleri taramak için ana klasörüne ihtiyaç duyar."
        case .homeFolderRequiredButton: return "Ana klasörü seç"

        case .fullDiskRequiredTitle: return "Sistem Verisi erişimi gerekli"
        case .fullDiskRequiredDescription: return "Uygulama verilerini ve geliştirici klasörlerini incelemek için macOS'tan Tam Disk Erişimi izni gerekir."
        case .fullDiskRequiredButton: return "Erişimi ayarla"

        case .systemDataFolderRequiredTitle: return "İncelenecek klasörü seç"
        case .systemDataFolderRequiredDescription: return "App Store sürümü yalnızca seçtiğin klasörü analiz eder."
        case .systemDataFolderRequiredButton: return "Klasör seç"

        case .privacyPolicyTitle: return "Gizlilik"
        case .privacyPolicyBody: return "MacClean dosyalarını, sohbetlerini veya kullanım bilgilerini hiçbir sunucuya göndermez. Reklam ve analitik SDK'sı kullanmaz."
        case .privacyPolicyRevokeAccess: return "Erişimi kaldır"
        case .privacyPolicyClose: return "Kapat"

        case .panelHomeFolderTitle: return "Ana klasörünü seç"
        case .panelHomeFolderMessage: return "MacClean yalnızca seçtiğin ana klasörde temizlik yapar. Erişim sonraki açılışlarda da korunur."
        case .panelHomeFolderPrompt: return "Ana klasörü kullan"
        case .panelSystemDataTitle: return "İncelenecek klasörü seç"
        case .panelSystemDataMessage: return "Yalnızca bu klasörün içeriği analiz edilir; diğer uygulama verileri kendiliğinden taranmaz."
        case .panelSystemDataPrompt: return "Klasörü incele"

        case .errorWrongHomeFolder: return "Temizlik için Finder'da kendi ana klasörünü seçmelisin: %@."
        case .errorSaveBookmark: return "Klasör erişimi kaydedilemedi: %@"
        case .errorSaveSystemBookmark: return "İnceleme klasörü kaydedilemedi: %@"

        case .diskFreeSpace: return "%@ boş"
        case .diskUsedOf: return "%@ kullanılıyor · Toplam %@"
        case .diskUsagePercent: return "Disk kullanımı %%%d"
        case .diskFreeSpaceBadge: return "Alan aç"
        case .diskOpenSpace: return "%@ boş alan"
        case .diskAccessibilityRing: return "Disk kullanımı yüzde %d"

        case .categoryCachesTitle: return "Uygulama önbellekleri"
        case .categoryCachesSubtitle: return "Yeniden oluşturulabilen uygulama verileri"
        case .categoryCachesSafetyNote: return "Bu içerikler yeniden oluşturulabilir. Seçilen öğeler kalıcı olarak silinir."
        case .categoryCachesReviewDesc: return "Uygulamaların geçici olarak indirdiği görseller, güncellemeler ve hızlandırma verileri silinir. Uygulamalar bunları gerektiğinde yeniden oluşturur."
        case .categoryCachesProtectedNote: return "Tarayıcı geçmişi, yer imleri, kayıtlı parolalar ve açık oturumlar uygulamanın profil klasörlerinde tutulur; bu tarama onları kapsamaz. İlk açılışlar kısa süreliğine yavaşlayabilir."

        case .categoryLogsTitle: return "Günlükler ve raporlar"
        case .categoryLogsSubtitle: return "Eski hata kayıtları ve günlükler"
        case .categoryLogsSafetyNote: return "Bu içerikler yeniden oluşturulabilir. Seçilen öğeler kalıcı olarak silinir."
        case .categoryLogsReviewDesc: return "Uygulamaların eski günlükleri ve hata raporları silinir. Bunlar proje dosyası veya uygulama ayarı değildir."

        case .categoryDeveloperTitle: return "Xcode derleme artıkları"
        case .categoryDeveloperSubtitle: return "DerivedData ve simülatör önbellekleri"
        case .categoryDeveloperSafetyNote: return "Bu içerikler yeniden oluşturulabilir. Seçilen öğeler kalıcı olarak silinir."
        case .categoryDeveloperReviewDesc: return "Yalnızca Xcode DerivedData, CoreSimulator önbellekleri ve Xcode önbelleği silinir. Bir sonraki derlemede bazı paketler ve ara çıktılar yeniden oluşturulabilir."
        case .categoryDeveloperProtectedNote: return "`.xcodeproj`, `.xcworkspace`, Swift kaynak kodu, Git depoları, Xcode Archives ve simülatör cihaz verileri bu kategorinin dışında bırakılır."

        case .categoryInstallersTitle: return "İndirilen kurulum dosyaları"
        case .categoryInstallersSubtitle: return "DMG, PKG, ZIP ve benzeri dosyalar"
        case .categoryInstallersSafetyNote: return "Seçilen öğeler Çöp Kutusu'na taşınır; alan açmak için Çöp Kutusu'nu ayrıca boşaltmalısın."
        case .categoryInstallersReviewDesc: return "İndirilen DMG, PKG, ZIP ve benzeri kurulum dosyaları Çöp Kutusu'na taşınır. İçeriklerine veya kurulu uygulamalara dokunulmaz."
        case .categoryInstallersProtectedNote: return "Kurulu uygulamalar silinmez; yalnızca indirilen kurulum paketleri listelenir."

        case .categoryLargeFilesTitle: return "Büyük, eski dosyalar"
        case .categoryLargeFilesSubtitle: return "Ana klasörlerde 500 MB üzeri eski dosyalar"
        case .categoryLargeFilesSafetyNote: return "Seçilen öğeler Çöp Kutusu'na taşınır; alan açmak için Çöp Kutusu'nu ayrıca boşaltmalısın."
        case .categoryLargeFilesReviewDesc: return "İndirilenler, Masaüstü, Belgeler ve Filmler klasörlerinin yalnızca kökündeki 500 MB üzeri, en az 14 günlük dosyalar Çöp Kutusu'na taşınır."
        case .categoryLargeFilesProtectedNote: return "Klasöre tıklayarak içeriğini görebilir, yalnızca seçtiğin dosya veya alt klasörleri Çöp Kutusu'na taşıyabilirsin."

        case .categoryTrashTitle: return "Çöp kutusu"
        case .categoryTrashSubtitle: return "Silmek için bekleyen öğeler"
        case .categoryTrashSafetyNote: return "Çöp Kutusu'ndaki seçilen öğeler kalıcı olarak silinir."
        case .categoryTrashReviewDesc: return "Çöp Kutusu'nda bekleyen öğeler kalıcı olarak silinir. Bu işlem geri alınamaz."

        case .storageActionManageInAppTitle: return "Uygulama içinden yönet"
        case .storageActionManageInAppDetail: return "Bu klasör gerçek uygulama verisi içeriyor olabilir. Uygulamanın kendi depolama yönetimini kullanmak daha güvenli."
        case .storageActionManageInXcodeTitle: return "Xcode içinden yönet"
        case .storageActionManageInXcodeDetail: return "Bu alan projelerini değil, kurulu simülatör cihazlarını içerir. Kullanmadığın cihazları Xcode'dan kaldırabilirsin."
        case .storageActionManageInDockerTitle: return "Docker Desktop içinden yönet"
        case .storageActionManageInDockerDetail: return "Image, container ve volume'lar burada olabilir. Docker Desktop'tan neyi kaldıracağını görerek temizle."
        case .storageActionRemoveIfUnusedTitle: return "Kullanmıyorsan kaldırılabilir"
        case .storageActionRemoveIfUnusedDetail: return "Uygulamayı artık kullanmıyorsan önce uygulamayı kapatıp kaldır; ardından kalan veriyi ayrıca inceleyebilirsin."
        case .storageActionInspectFirstTitle: return "Önce incele"
        case .storageActionInspectFirstDetail: return "Bu klasör uygulama ayarları, profiller veya yerel veriler içerebilir. Ne olduğunu doğrulamadan silme."

        case .systemAreaSelectedFolder: return "Seçili klasör"
        case .systemAreaSelectedSubtitle: return "Kullanıcının seçtiği klasördeki büyük öğeler"
        case .systemAreaAppData: return "Uygulama verileri"
        case .systemAreaAppDataSubtitle: return "Uygulamaların profilleri, yerel verileri ve çalışma alanları"
        case .systemAreaSharedAppData: return "Paylaşılan uygulama verileri"
        case .systemAreaSharedAppDataSubtitle: return "Mesajlaşma, ofis ve ortak uygulama depoları"
        case .systemAreaDeveloperData: return "Geliştirici verileri"
        case .systemAreaDeveloperDataSubtitle: return "Xcode ve iOS simülatör verileri"
        case .systemAreaSandboxData: return "Sandbox uygulama verileri"
        case .systemAreaSandboxDataSubtitle: return "Docker ve sandbox'lı uygulamaların yerel dosyaları"
        case .systemMetaWhatsApp: return "WhatsApp medya ve sohbet verisi"
        case .systemMetaWhatsAppSummary: return "İndirilen sohbet medyaları, mesaj verisi ve uygulama durumu"
        case .systemMetaKiro: return "Kiro"
        case .systemMetaKiroSummary: return "Çalışma alanı, eklenti, günlük ve yerel uygulama verileri"
        case .systemMetaCoreSimulator: return "iOS Simülatörleri"
        case .systemMetaCoreSimulatorSummary: return "Kurulu simülatör cihazları ve içlerindeki uygulama verileri"
        case .systemMetaDocker: return "Docker"
        case .systemMetaDockerSummary: return "Sanal makine, image, container ve volume verileri"
        case .systemMetaMuMu: return "MuMu Android emülatörü"
        case .systemMetaMuMuSummary: return "Android emülatörü, indirilen sistem dosyaları ve uygulama verileri"
        case .systemMetaBrowser: return "Tarayıcı profili"
        case .systemMetaBrowserSummary: return "Tarayıcı profili, indirilen veri ve yerel tarayıcı durumu"
        case .systemMetaCodeEditor: return "Kod editörü / AI uygulaması"
        case .systemMetaCodeEditorSummary: return "Kod editörü veya yapay zekâ uygulamasının yerel verileri"
        case .systemMetaGenericApp: return "Uygulama tarafından oluşturulmuş yerel veri"

        case .storageBrowserGoUp: return "Üst klasöre dön"
        case .fullDiskSetupStep1: return "Açılan Sistem Ayarları ekranında MacClean'i etkinleştir. Görünmüyorsa + düğmesiyle MacClean.app'i ekle."
        case .fullDiskSetupStep2: return "Bu pencereye donup \"Erisimi etkinlestirdim\" dugmesine bas."
        case .homeFolderSetupStep1: return "Açılacak Finder penceresinde kullanıcı adını taşıyan ana klasörünü seç."
        case .homeFolderSetupStep2: return "MacClean bu erişimi güvenli yer imi olarak saklar; menüler arasında yeniden izin istemez."
        case .privacyPolicyAdditionalNote: return "Dosyalar kendiliğinden silinmez. Her silme işlemi açık onayını ister; kurulum dosyaları ve kişisel büyük dosyalar önce Çöp Kutusu'na taşınır."
        case .privacyPolicyContact: return "İletişim: yusahmedia@gmail.com"
        case .privacyPolicyTermsLink: return "Kullanım Koşulları (Apple EULA)"
        case .privacyPolicyPolicyLink: return "Gizlilik Politikası"

        case .onboardingWelcomeTitle: return "MacClean'e Hoş Geldin"
        case .onboardingWelcomeSubtitle: return "Mac'ini temiz ve hızlı tutmana yardımcı olan basit bir araç."
        case .onboardingChooseLanguage: return "Dil seç"
        case .onboardingContinue: return "Devam"
        case .onboardingGetStarted: return "Başla"
        case .onboardingSkip: return "Atla"
        case .onboardingBack: return "Geri"
        case .onboardingStep: return "%d / %d"

        case .onboardingSlide2Title: return "Önce tara, sonra karar ver"
        case .onboardingSlide2Body: return "Uygulama önce tüm temizlenebilir alanları bulur ve sana gösterir. Hiçbir şey onayın olmadan silinmez."
        case .onboardingSlide3Title: return "Kategorilere göre incele"
        case .onboardingSlide3Body: return "Önbellekler, Xcode artıkları, büyük dosyalar ve daha fazlasını ayrı ayrı gör. Her kategoride detaya inebilirsin."
        case .onboardingSlide4Title: return "Güvenli ve şeffaf"
        case .onboardingSlide4Body: return "MacClean hiçbir dosyayı sunucuya göndermez. Her silme işlemi önce onayını ister. Çöp Kutusu'na taşınan öğeleri istersen geri alabilirsin."
        }
    }

    private var englishString: String {
        switch self {
        case .appName: return "MacClean"
        case .appSubtitle: return "Storage assistant"

        case .sidebarSectionClean: return "CLEANABLE"
        case .sidebarSectionFolderInspect: return "FOLDER INSPECT"
        case .sidebarSectionSystemData: return "SYSTEM DATA"

        case .sidebarOverview: return "Overview"
        case .sidebarDetailedInspect: return "Detailed inspect"
        case .sidebarStatusScanning: return "Scanning…"
        case .sidebarStatusSetAccess: return "Set access"
        case .sidebarStatusChooseFolder: return "Choose folder"
        case .sidebarStatusInspect: return "Inspect"

        case .privacyCardAppStoreTitle: return "App Store security model"
        case .privacyCardDirectTitle: return "One-time system access"
        case .privacyCardHomeFolderSaved: return "Home folder access saved. You can change the selection anytime."
        case .privacyCardHomeFolderRequired: return "You need to choose your home folder once to enable cleaning."
        case .privacyCardChangeHomeFolder: return "Change home folder"
        case .privacyCardSelectHomeFolder: return "Select home folder"
        case .privacyCardFullDiskEnabled: return "Full Disk Access enabled. The app will not ask again."
        case .privacyCardFullDiskRequired: return "Full Disk Access is needed once from macOS to inspect System Data."
        case .privacyCardSetAccess: return "Set access"
        case .privacyCardPrivacy: return "Privacy"

        case .sidebarChangeLanguage: return "Change language"

        case .overviewTitle: return "Free up space on your Mac"
        case .overviewSubtitle: return "You decide what to clean — the app shows results before removing anything."
        case .overviewMetricFound: return "Cleanable space found"
        case .overviewMetricSelected: return "Selected items"
        case .overviewMetricSafeMode: return "Safe mode"
        case .overviewMetricSafeModeValue: return "On"
        case .overviewCleanupSummary: return "Cleanup summary"

        case .scanningCardTitle: return "Scanning your Mac"
        case .scanningCardSubtitle: return "Calculating caches and large files in selected folders."

        case .systemDataNoteTitle: return "If \"System Data\" looks too large"
        case .systemDataNoteBodyAppStore: return "The App Store version only inspects the caches, logs, Xcode leftovers, and large files inside the home folder you explicitly select."
        case .systemDataNoteBodyDirect: return "MacClean automatically scans safe areas like caches and Xcode leftovers. Full Disk Access from macOS is needed once for System Data inspection."

        case .categorySelectAll: return "Select all"
        case .categoryDeselectAll: return "Deselect all"
        case .categoryItemCount: return "%d items · %@"
        case .categoryEmpty: return "No items to clean"
        case .categoryEmptyDescription: return "This category looks clean right now."
        case .categoryRescan: return "Re-scan"
        case .categoryRescanInProgress: return "Scanning…"
        case .categoryUpdating: return "Updating"

        case .actionBarItemsSelected: return "%d items selected"
        case .actionBarWillProcess: return "%@ will be processed"
        case .actionBarCleaning: return "Cleaning…"
        case .actionBarClean: return "Free up space"

        case .errorAlertTitle: return "Action could not be completed"
        case .errorAlertOk: return "OK"

        case .inspectorTitleAppStore: return "Inspect selected folder"
        case .inspectorSubtitleAppStore: return "Shows large items in the folder you selected. Nothing is deleted automatically on this screen."
        case .inspectorTitleDirect: return "System Data inspection"
        case .inspectorSubtitleDirect: return "Shows where large app data lives. Nothing is deleted automatically on this screen."
        case .inspectorRescan: return "Re-scan"
        case .inspectorChooseFolder: return "Choose folder"
        case .inspectorSetAccess: return "Set access"
        case .inspectorScanningTitle: return "Scanning large app folders"
        case .inspectorScanningSubtitle: return "WhatsApp, Kiro, iOS Simulators, Docker, MuMu and other app data are being calculated separately."
        case .inspectorNotStartedTitle: return "Inspection not started yet"
        case .inspectorNotStartedDescription: return "The \"Re-scan\" button analyzes app data and developer data."
        case .inspectorSummaryTitle: return "%@ found in detail"
        case .inspectorSummaryBody: return "This total represents app data we can access. It may not match the macOS System Data number exactly — protected system files and APFS components are not deleted on this screen."
        case .inspectorHighlightsTitle: return "Notable large areas"
        case .inspectorHighlightsSubtitle: return "These items are the largest app-based storage areas within System Data."
        case .inspectorChooseFolderButton: return "Choose folder"
        case .inspectorRescanButton: return "Re-scan"

        case .reviewTitle: return "Review before cleaning"
        case .reviewSubtitle: return "See what each selected category does below. Go back to deselect anything you are unsure about."
        case .reviewItemCount: return "%d items · %@"
        case .reviewWillTrash: return "%@ will be moved to Trash"
        case .reviewWillDelete: return "Selected data will be permanently deleted"
        case .reviewBadgePermanent: return "Permanent delete"
        case .reviewBadgeTrash: return "Move to Trash"
        case .reviewBack: return "Go back"
        case .reviewConfirm: return "Clean this selection"
        case .reviewProtectedHeader: return "This tool never scans"

        case .outcomeTitle: return "Cleanup complete"
        case .outcomeFailedTitle: return "Some items could not be processed"
        case .outcomePermanentlyDeleted: return "%@ permanently deleted"
        case .outcomeMovedToTrash: return "%@ moved to Trash"
        case .outcomeFailedItems: return "%d items could not be processed"

        case .folderBrowserGoUp: return "Go up"
        case .folderBrowserSelectAll: return "Select all"
        case .folderBrowserDeselectAll: return "Deselect all"
        case .folderBrowserItemCount: return "%d items · %@"
        case .folderBrowserLoading: return "Calculating folder contents…"
        case .folderBrowserEmpty: return "This folder is empty"
        case .folderBrowserSelectedCount: return "%d items selected"
        case .folderBrowserWillTrash: return "%@ will be moved to Trash"
        case .folderBrowserWillDelete: return "%@ will be permanently deleted"
        case .folderBrowserClose: return "Close"
        case .folderBrowserMoveToTrash: return "Move to Trash"
        case .folderBrowserRemove: return "Remove"
        case .folderBrowserAlertTrashTitle: return "Move selected items to Trash?"
        case .folderBrowserAlertDeleteTitle: return "Permanently delete selected items?"
        case .folderBrowserAlertCancel: return "Cancel"
        case .folderBrowserAlertConfirmTrash: return "Move to Trash"
        case .folderBrowserAlertConfirmDelete: return "Delete permanently"
        case .folderBrowserAlertTrashMessage: return "%d items (%@) will be moved to Trash. Empty the Trash afterwards to actually free up space."
        case .folderBrowserAlertDeleteMessage: return "%d items (%@) will be permanently deleted. This cannot be undone."
        case .folderBrowserResultTitle: return "Removal result"
        case .folderBrowserResultSuccessTrash: return "%d items moved to Trash."
        case .folderBrowserResultSuccessDelete: return "%d items permanently deleted."
        case .folderBrowserResultPartial: return "%d items processed, %d items could not be removed."
        case .folderBrowserContentRow: return "Browse contents"

        case .storageBrowserLoading: return "Calculating contents…"
        case .storageBrowserEmpty: return "No contents found"
        case .storageBrowserRemove: return "Remove"
        case .storageBrowserClose: return "Close"
        case .storageBrowserAlertTitle: return "Move to Trash?"
        case .storageBrowserAlertCancel: return "Cancel"
        case .storageBrowserAlertConfirm: return "Remove"
        case .storageBrowserAlertMessage: return "%@ (%@) will be moved to Trash. If an app or emulator is open, close it first. Empty the Trash to actually free up space."
        case .storageBrowserResultTitle: return "Removal result"
        case .storageBrowserResultSuccess: return "Moved to Trash: %@."
        case .storageBrowserResultFailure: return "Could not remove: %@"

        case .whatsappSheetTitle: return "WhatsApp media breakdown"
        case .whatsappSheetSubtitle: return "Chat names are matched read-only from WhatsApp's local chat database."
        case .whatsappSheetPrivacyNote: return "We do not read message contents. This list only shows chat name, media count, and space used."
        case .whatsappSheetLoading: return "Matching chat media…"
        case .whatsappSheetEmptyTitle: return "No media matches found"
        case .whatsappSheetEmptyDescription: return "Could not read the WhatsApp media folder or local chat database."
        case .whatsappSheetChatCount: return "%d chats or media sources"
        case .whatsappSheetManage: return "Manage"
        case .whatsappSheetClose: return "Close"
        case .whatsappSheetChatSubtitle: return "%@ · %d media · Details"
        case .whatsappKindDirect: return "Direct chat"
        case .whatsappKindGroup: return "Group"
        case .whatsappKindStatus: return "Status media"
        case .whatsappKindUnknown: return "Chat"

        case .whatsappRemovalMediaCount: return "%d local media files"
        case .whatsappRemovalVerified: return "verified in media folder"
        case .whatsappRemovalLabel1: return "Remove only moves the local media folder for this chat."
        case .whatsappRemovalLabel2: return "Does not touch message texts or WhatsApp's chat database. The chat stays in WhatsApp; moved old media may not open there."
        case .whatsappRemovalLabel3: return "To delete the chat itself, use WhatsApp. Empty the Trash to actually free up space."
        case .whatsappRemovalBack: return "Back"
        case .whatsappRemovalConfirmButton: return "Move media to Trash"
        case .whatsappRemovalAlertTitle: return "Move media for this chat?"
        case .whatsappRemovalAlertCancel: return "Cancel"
        case .whatsappRemovalAlertConfirm: return "Move to Trash"
        case .whatsappRemovalAlertMessage: return "%d media files (%@) will be moved to Trash. Close WhatsApp first if it's open. This does not delete chat texts."
        case .whatsappRemovalResultTitle: return "Removal result"
        case .whatsappRemovalResultSuccess: return "Moved to Trash: %d media files."
        case .whatsappRemovalResultFailure: return "Could not remove: %@"
        case .whatsappFallbackStatusMedia: return "WhatsApp status media"
        case .whatsappFallbackGroup: return "Group chat"

        case .homeFolderSetupTitle: return "Select your home folder once"
        case .homeFolderSetupCancel: return "Cancel"
        case .homeFolderSetupConfirm: return "Select home folder"

        case .fullDiskSetupTitle: return "Set this up just once"
        case .fullDiskSetupCancel: return "Cancel"
        case .fullDiskSetupOpenSettings: return "Open System Settings"
        case .fullDiskSetupConfirm: return "I've enabled access"

        case .homeFolderRequiredTitle: return "Home folder access required"
        case .homeFolderRequiredDescription: return "MacClean needs your home folder to scan for cleanable content like caches and large files."
        case .homeFolderRequiredButton: return "Select home folder"

        case .fullDiskRequiredTitle: return "System Data access required"
        case .fullDiskRequiredDescription: return "Full Disk Access permission from macOS is required to inspect app data and developer folders."
        case .fullDiskRequiredButton: return "Set access"

        case .systemDataFolderRequiredTitle: return "Choose a folder to inspect"
        case .systemDataFolderRequiredDescription: return "The App Store version only analyzes the folder you select."
        case .systemDataFolderRequiredButton: return "Choose folder"

        case .privacyPolicyTitle: return "Privacy"
        case .privacyPolicyBody: return "MacClean never sends your files, chats, or usage data to any server. No ads or analytics SDKs are used."
        case .privacyPolicyRevokeAccess: return "Revoke access"
        case .privacyPolicyClose: return "Close"

        case .panelHomeFolderTitle: return "Select your home folder"
        case .panelHomeFolderMessage: return "MacClean only cleans inside the home folder you select. Access is preserved across launches."
        case .panelHomeFolderPrompt: return "Use this folder"
        case .panelSystemDataTitle: return "Choose folder to inspect"
        case .panelSystemDataMessage: return "Only this folder's contents will be analyzed; other app data is not scanned automatically."
        case .panelSystemDataPrompt: return "Inspect folder"

        case .errorWrongHomeFolder: return "You must select your own home folder in Finder: %@."
        case .errorSaveBookmark: return "Could not save folder access: %@"
        case .errorSaveSystemBookmark: return "Could not save inspection folder: %@"

        case .diskFreeSpace: return "%@ free"
        case .diskUsedOf: return "%@ used · Total %@"
        case .diskUsagePercent: return "Disk usage %d%%"
        case .diskFreeSpaceBadge: return "Free up space"
        case .diskOpenSpace: return "%@ free space"
        case .diskAccessibilityRing: return "Disk usage %d percent"

        case .categoryCachesTitle: return "App caches"
        case .categoryCachesSubtitle: return "Regenerable app data"
        case .categoryCachesSafetyNote: return "These can be regenerated. Selected items are permanently deleted."
        case .categoryCachesReviewDesc: return "Temporary images, updates, and acceleration data downloaded by apps are deleted. Apps regenerate them as needed."
        case .categoryCachesProtectedNote: return "Browser history, bookmarks, saved passwords, and active sessions are in the app's profile folders — this scan does not include them. First launches may be slightly slower."

        case .categoryLogsTitle: return "Logs & reports"
        case .categoryLogsSubtitle: return "Old error logs and diagnostic reports"
        case .categoryLogsSafetyNote: return "These can be regenerated. Selected items are permanently deleted."
        case .categoryLogsReviewDesc: return "Old logs and crash reports from apps are deleted. These are not project files or app settings."

        case .categoryDeveloperTitle: return "Xcode build artifacts"
        case .categoryDeveloperSubtitle: return "DerivedData and simulator caches"
        case .categoryDeveloperSafetyNote: return "These can be regenerated. Selected items are permanently deleted."
        case .categoryDeveloperReviewDesc: return "Only Xcode DerivedData, CoreSimulator caches, and Xcode caches are deleted. Some packages and intermediate outputs may be regenerated on the next build."
        case .categoryDeveloperProtectedNote: return "`.xcodeproj`, `.xcworkspace`, Swift source code, Git repos, Xcode Archives, and simulator device data are excluded from this category."

        case .categoryInstallersTitle: return "Downloaded installers"
        case .categoryInstallersSubtitle: return "DMG, PKG, ZIP and similar files"
        case .categoryInstallersSafetyNote: return "Selected items are moved to Trash. Empty the Trash to actually free up space."
        case .categoryInstallersReviewDesc: return "Downloaded DMG, PKG, ZIP, and similar installer files are moved to Trash. Their contents or installed apps are not touched."
        case .categoryInstallersProtectedNote: return "Installed apps are not deleted — only downloaded installer packages are listed."

        case .categoryLargeFilesTitle: return "Large, old files"
        case .categoryLargeFilesSubtitle: return "Files over 500 MB in home folders"
        case .categoryLargeFilesSafetyNote: return "Selected items are moved to Trash. Empty the Trash to actually free up space."
        case .categoryLargeFilesReviewDesc: return "Files over 500 MB that are at least 14 days old, found only in the root of Downloads, Desktop, Documents, and Movies folders, are moved to Trash."
        case .categoryLargeFilesProtectedNote: return "Click a folder to see its contents and move only the files or subfolders you choose to Trash."

        case .categoryTrashTitle: return "Trash"
        case .categoryTrashSubtitle: return "Items waiting to be deleted"
        case .categoryTrashSafetyNote: return "Selected items in Trash will be permanently deleted."
        case .categoryTrashReviewDesc: return "Items waiting in Trash are permanently deleted. This cannot be undone."

        case .storageActionManageInAppTitle: return "Manage in app"
        case .storageActionManageInAppDetail: return "This folder may contain real app data. Using the app's own storage management is safer."
        case .storageActionManageInXcodeTitle: return "Manage in Xcode"
        case .storageActionManageInXcodeDetail: return "This area contains installed simulator devices, not your projects. Remove unused ones from Xcode."
        case .storageActionManageInDockerTitle: return "Manage in Docker Desktop"
        case .storageActionManageInDockerDetail: return "Images, containers, and volumes may be here. Use Docker Desktop to see and clean what to remove."
        case .storageActionRemoveIfUnusedTitle: return "Remove if unused"
        case .storageActionRemoveIfUnusedDetail: return "If you no longer use the app, quit and uninstall it first; then inspect the remaining data separately."
        case .storageActionInspectFirstTitle: return "Inspect first"
        case .storageActionInspectFirstDetail: return "This folder may contain app settings, profiles, or local data. Do not delete without verifying what it is."

        case .systemAreaSelectedFolder: return "Selected folder"
        case .systemAreaSelectedSubtitle: return "Large items in the folder you selected"
        case .systemAreaAppData: return "App data"
        case .systemAreaAppDataSubtitle: return "App profiles, local data, and workspaces"
        case .systemAreaSharedAppData: return "Shared app data"
        case .systemAreaSharedAppDataSubtitle: return "Messaging, office, and shared app stores"
        case .systemAreaDeveloperData: return "Developer data"
        case .systemAreaDeveloperDataSubtitle: return "Xcode and iOS simulator data"
        case .systemAreaSandboxData: return "Sandboxed app data"
        case .systemAreaSandboxDataSubtitle: return "Local files for Docker and sandboxed apps"
        case .systemMetaWhatsApp: return "WhatsApp media & chat data"
        case .systemMetaWhatsAppSummary: return "Downloaded chat media, message data, and app state"
        case .systemMetaKiro: return "Kiro"
        case .systemMetaKiroSummary: return "Workspace, extensions, logs, and local app data"
        case .systemMetaCoreSimulator: return "iOS Simulators"
        case .systemMetaCoreSimulatorSummary: return "Installed simulator devices and their app data"
        case .systemMetaDocker: return "Docker"
        case .systemMetaDockerSummary: return "Virtual machine, images, containers, and volume data"
        case .systemMetaMuMu: return "MuMu Android Emulator"
        case .systemMetaMuMuSummary: return "Android emulator, downloaded system files, and app data"
        case .systemMetaBrowser: return "Browser profile"
        case .systemMetaBrowserSummary: return "Browser profile, downloaded data, and local browser state"
        case .systemMetaCodeEditor: return "Code editor / AI app"
        case .systemMetaCodeEditorSummary: return "Local data for a code editor or AI application"
        case .systemMetaGenericApp: return "Local data created by app"

        case .storageBrowserGoUp: return "Go up"
        case .fullDiskSetupStep1: return "In the System Settings screen that opens, enable MacClean. If it's not listed, add MacClean.app with the + button."
        case .fullDiskSetupStep2: return "Come back to this window and press \"I've enabled access\"."
        case .homeFolderSetupStep1: return "In the Finder window that opens, select the home folder with your username."
        case .homeFolderSetupStep2: return "MacClean saves this access as a secure bookmark; it won't ask again between sessions."
        case .privacyPolicyAdditionalNote: return "Files are never deleted automatically. Every deletion requires your explicit confirmation; installer files and large personal files are moved to Trash first."
        case .privacyPolicyContact: return "Contact: yusahmedia@gmail.com"
        case .privacyPolicyTermsLink: return "Terms of Use (Apple EULA)"
        case .privacyPolicyPolicyLink: return "Privacy Policy"

        case .onboardingWelcomeTitle: return "Welcome to MacClean"
        case .onboardingWelcomeSubtitle: return "A simple tool to help keep your Mac clean and fast."
        case .onboardingChooseLanguage: return "Choose language"
        case .onboardingContinue: return "Continue"
        case .onboardingGetStarted: return "Get started"
        case .onboardingSkip: return "Skip"
        case .onboardingBack: return "Back"
        case .onboardingStep: return "%d / %d"

        case .onboardingSlide2Title: return "Scan first, then decide"
        case .onboardingSlide2Body: return "The app finds all cleanable space first and shows it to you. Nothing is deleted without your approval."
        case .onboardingSlide3Title: return "Browse by category"
        case .onboardingSlide3Body: return "Caches, Xcode artifacts, large files, and more — each in its own category. You can drill down into any item."
        case .onboardingSlide4Title: return "Safe and transparent"
        case .onboardingSlide4Body: return "MacClean never sends any file to a server. Every deletion requires your confirmation. Items moved to Trash can be recovered."
        }
    }

    private var russianString: String {
        switch self {
        case .appName: return "MacClean"
        case .appSubtitle: return "Помощник по хранилищу"

        case .sidebarSectionClean: return "ДЛЯ ОЧИСТКИ"
        case .sidebarSectionFolderInspect: return "ПРОСМОТР ПАПКИ"
        case .sidebarSectionSystemData: return "СИСТЕМНЫЕ ДАННЫЕ"

        case .sidebarOverview: return "Обзор"
        case .sidebarDetailedInspect: return "Детальный осмотр"
        case .sidebarStatusScanning: return "Сканирование…"
        case .sidebarStatusSetAccess: return "Настроить доступ"
        case .sidebarStatusChooseFolder: return "Выбрать папку"
        case .sidebarStatusInspect: return "Осмотреть"

        case .privacyCardAppStoreTitle: return "Модель безопасности App Store"
        case .privacyCardDirectTitle: return "Однократный системный доступ"
        case .privacyCardHomeFolderSaved: return "Доступ к домашней папке сохранён. Вы можете изменить выбор в любое время."
        case .privacyCardHomeFolderRequired: return "Для очистки нужно один раз выбрать домашнюю папку."
        case .privacyCardChangeHomeFolder: return "Изменить домашнюю папку"
        case .privacyCardSelectHomeFolder: return "Выбрать домашнюю папку"
        case .privacyCardFullDiskEnabled: return "Полный доступ к диску включён. Приложение не будет спрашивать снова."
        case .privacyCardFullDiskRequired: return "Для проверки системных данных нужно один раз предоставить полный доступ к диску в macOS."
        case .privacyCardSetAccess: return "Настроить доступ"
        case .privacyCardPrivacy: return "Конфиденциальность"

        case .sidebarChangeLanguage: return "Изменить язык"

        case .overviewTitle: return "Освободите место на Mac"
        case .overviewSubtitle: return "Вы решаете, что очищать — приложение покажет результаты до удаления."
        case .overviewMetricFound: return "Найдено для очистки"
        case .overviewMetricSelected: return "Выбранные элементы"
        case .overviewMetricSafeMode: return "Безопасный режим"
        case .overviewMetricSafeModeValue: return "Включён"
        case .overviewCleanupSummary: return "Сводка очистки"

        case .scanningCardTitle: return "Сканирование вашего Mac"
        case .scanningCardSubtitle: return "Вычисляются кэши и большие файлы в выбранных папках."

        case .systemDataNoteTitle: return "Если «Системные данные» выглядят слишком большими"
        case .systemDataNoteBodyAppStore: return "Версия App Store проверяет только кэши, журналы, остатки Xcode и большие файлы в домашней папке, которую вы явно выбрали."
        case .systemDataNoteBodyDirect: return "MacClean автоматически сканирует безопасные области, такие как кэши и остатки Xcode. Для проверки системных данных macOS запросит полный доступ к диску один раз."

        case .categorySelectAll: return "Выбрать все"
        case .categoryDeselectAll: return "Снять выделение"
        case .categoryItemCount: return "%d элем. · %@"
        case .categoryEmpty: return "Нечего очищать"
        case .categoryEmptyDescription: return "В этой категории сейчас всё чисто."
        case .categoryRescan: return "Повторить сканирование"
        case .categoryRescanInProgress: return "Сканирование…"
        case .categoryUpdating: return "Обновление"

        case .actionBarItemsSelected: return "Выбрано %d эл."
        case .actionBarWillProcess: return "%@ будет обработано"
        case .actionBarCleaning: return "Очистка…"
        case .actionBarClean: return "Освободить место"

        case .errorAlertTitle: return "Не удалось выполнить действие"
        case .errorAlertOk: return "ОК"

        case .inspectorTitleAppStore: return "Осмотреть выбранную папку"
        case .inspectorSubtitleAppStore: return "Показывает большие элементы в выбранной папке. Ничего не удаляется автоматически."
        case .inspectorTitleDirect: return "Проверка системных данных"
        case .inspectorSubtitleDirect: return "Показывает, где находятся большие данные приложений. Ничего не удаляется автоматически."
        case .inspectorRescan: return "Повторить сканирование"
        case .inspectorChooseFolder: return "Выбрать папку"
        case .inspectorSetAccess: return "Настроить доступ"
        case .inspectorScanningTitle: return "Сканирование больших папок приложений"
        case .inspectorScanningSubtitle: return "WhatsApp, Kiro, iOS-симуляторы, Docker, MuMu и другие данные приложений вычисляются отдельно."
        case .inspectorNotStartedTitle: return "Проверка ещё не запущена"
        case .inspectorNotStartedDescription: return "Кнопка «Повторить сканирование» анализирует данные приложений и разработчика."
        case .inspectorSummaryTitle: return "Подробно найдено: %@"
        case .inspectorSummaryBody: return "Это сумма доступных нам данных приложений. Она может не совпадать с числом «Системных данных» в macOS — защищённые системные файлы и компоненты APFS не удаляются на этом экране."
        case .inspectorHighlightsTitle: return "Крупные области"
        case .inspectorHighlightsSubtitle: return "Это элементы с наибольшим объёмом хранилища приложений в системных данных."
        case .inspectorChooseFolderButton: return "Выбрать папку"
        case .inspectorRescanButton: return "Повторить сканирование"

        case .reviewTitle: return "Проверьте перед очисткой"
        case .reviewSubtitle: return "Ниже вы можете увидеть, что делает каждая выбранная категория. Вернитесь, чтобы снять отметку с неуверенных элементов."
        case .reviewItemCount: return "%d эл. · %@"
        case .reviewWillTrash: return "%@ будет перемещено в Корзину"
        case .reviewWillDelete: return "Выбранные данные будут удалены навсегда"
        case .reviewBadgePermanent: return "Постоянное удаление"
        case .reviewBadgeTrash: return "В Корзину"
        case .reviewBack: return "Назад"
        case .reviewConfirm: return "Очистить выбранное"
        case .reviewProtectedHeader: return "Этот инструмент никогда не сканирует"

        case .outcomeTitle: return "Очистка завершена"
        case .outcomeFailedTitle: return "Некоторые элементы не удалось обработать"
        case .outcomePermanentlyDeleted: return "%@ удалено навсегда"
        case .outcomeMovedToTrash: return "%@ перемещено в Корзину"
        case .outcomeFailedItems: return "%d элем. не удалось обработать"

        case .folderBrowserGoUp: return "Перейти вверх"
        case .folderBrowserSelectAll: return "Выбрать все"
        case .folderBrowserDeselectAll: return "Снять выделение"
        case .folderBrowserItemCount: return "%d эл. · %@"
        case .folderBrowserLoading: return "Вычисление содержимого папки…"
        case .folderBrowserEmpty: return "Папка пуста"
        case .folderBrowserSelectedCount: return "Выбрано %d эл."
        case .folderBrowserWillTrash: return "%@ будет перемещено в Корзину"
        case .folderBrowserWillDelete: return "%@ будет удалено навсегда"
        case .folderBrowserClose: return "Закрыть"
        case .folderBrowserMoveToTrash: return "В Корзину"
        case .folderBrowserRemove: return "Удалить"
        case .folderBrowserAlertTrashTitle: return "Переместить выбранные элементы в Корзину?"
        case .folderBrowserAlertDeleteTitle: return "Удалить выбранные элементы навсегда?"
        case .folderBrowserAlertCancel: return "Отмена"
        case .folderBrowserAlertConfirmTrash: return "В Корзину"
        case .folderBrowserAlertConfirmDelete: return "Удалить навсегда"
        case .folderBrowserAlertTrashMessage: return "%d эл. (%@) будут перемещены в Корзину. Очистите Корзину, чтобы место действительно освободилось."
        case .folderBrowserAlertDeleteMessage: return "%d эл. (%@) будут удалены навсегда. Это действие нельзя отменить."
        case .folderBrowserResultTitle: return "Результат удаления"
        case .folderBrowserResultSuccessTrash: return "%d эл. перемещено в Корзину."
        case .folderBrowserResultSuccessDelete: return "%d эл. удалено навсегда."
        case .folderBrowserResultPartial: return "Обработано %d эл., %d эл. не удалось удалить."
        case .folderBrowserContentRow: return "Просмотреть содержимое"

        case .storageBrowserLoading: return "Вычисление содержимого…"
        case .storageBrowserEmpty: return "Содержимое не найдено"
        case .storageBrowserRemove: return "Удалить"
        case .storageBrowserClose: return "Закрыть"
        case .storageBrowserAlertTitle: return "Переместить в Корзину?"
        case .storageBrowserAlertCancel: return "Отмена"
        case .storageBrowserAlertConfirm: return "Удалить"
        case .storageBrowserAlertMessage: return "%@ (%@) будет перемещено в Корзину. Если приложение или эмулятор открыты, сначала закройте их. Очистите Корзину, чтобы место действительно освободилось."
        case .storageBrowserResultTitle: return "Результат удаления"
        case .storageBrowserResultSuccess: return "Перемещено в Корзину: %@."
        case .storageBrowserResultFailure: return "Не удалось удалить: %@"

        case .whatsappSheetTitle: return "Медиа WhatsApp"
        case .whatsappSheetSubtitle: return "Имена чатов сопоставлены в режиме только для чтения из локальной базы данных WhatsApp."
        case .whatsappSheetPrivacyNote: return "Мы не читаем содержимое сообщений. Список показывает только имя чата, количество медиафайлов и занятое место."
        case .whatsappSheetLoading: return "Сопоставление медиафайлов чата…"
        case .whatsappSheetEmptyTitle: return "Совпадения не найдены"
        case .whatsappSheetEmptyDescription: return "Не удалось прочитать папку медиафайлов WhatsApp или локальную базу данных чата."
        case .whatsappSheetChatCount: return "%d чатов или источников медиа"
        case .whatsappSheetManage: return "Управление"
        case .whatsappSheetClose: return "Закрыть"
        case .whatsappSheetChatSubtitle: return "%@ · %d медиа · Подробнее"
        case .whatsappKindDirect: return "Личный чат"
        case .whatsappKindGroup: return "Группа"
        case .whatsappKindStatus: return "Медиа статусов"
        case .whatsappKindUnknown: return "Чат"

        case .whatsappRemovalMediaCount: return "%d локальных медиафайлов"
        case .whatsappRemovalVerified: return "подтверждено в папке медиа"
        case .whatsappRemovalLabel1: return "Удаление переносит только локальную папку медиа этого чата."
        case .whatsappRemovalLabel2: return "Тексты сообщений и база данных чата WhatsApp не затрагиваются. Чат остаётся в WhatsApp; перенесённые старые медиафайлы могут не открываться там."
        case .whatsappRemovalLabel3: return "Для удаления самого чата используйте WhatsApp. Очистите Корзину, чтобы место действительно освободилось."
        case .whatsappRemovalBack: return "Назад"
        case .whatsappRemovalConfirmButton: return "Переместить медиа в Корзину"
        case .whatsappRemovalAlertTitle: return "Переместить медиа этого чата?"
        case .whatsappRemovalAlertCancel: return "Отмена"
        case .whatsappRemovalAlertConfirm: return "В Корзину"
        case .whatsappRemovalAlertMessage: return "%d медиафайлов (%@) будут перемещены в Корзину. Сначала закройте WhatsApp, если он открыт. Тексты чатов не будут удалены."
        case .whatsappRemovalResultTitle: return "Результат удаления"
        case .whatsappRemovalResultSuccess: return "Перемещено в Корзину: %d медиафайлов."
        case .whatsappRemovalResultFailure: return "Не удалось удалить: %@"
        case .whatsappFallbackStatusMedia: return "Медиа статусов WhatsApp"
        case .whatsappFallbackGroup: return "Групповой чат"

        case .homeFolderSetupTitle: return "Выберите домашнюю папку один раз"
        case .homeFolderSetupCancel: return "Отмена"
        case .homeFolderSetupConfirm: return "Выбрать домашнюю папку"

        case .fullDiskSetupTitle: return "Настройте это один раз"
        case .fullDiskSetupCancel: return "Отмена"
        case .fullDiskSetupOpenSettings: return "Открыть настройки системы"
        case .fullDiskSetupConfirm: return "Я включил доступ"

        case .homeFolderRequiredTitle: return "Требуется доступ к домашней папке"
        case .homeFolderRequiredDescription: return "MacClean нужна домашняя папка для сканирования кэшей и больших файлов."
        case .homeFolderRequiredButton: return "Выбрать домашнюю папку"

        case .fullDiskRequiredTitle: return "Требуется доступ к системным данным"
        case .fullDiskRequiredDescription: return "Для проверки данных приложений и папок разработчика необходим полный доступ к диску от macOS."
        case .fullDiskRequiredButton: return "Настроить доступ"

        case .systemDataFolderRequiredTitle: return "Выберите папку для проверки"
        case .systemDataFolderRequiredDescription: return "Версия App Store анализирует только выбранную вами папку."
        case .systemDataFolderRequiredButton: return "Выбрать папку"

        case .privacyPolicyTitle: return "Конфиденциальность"
        case .privacyPolicyBody: return "MacClean никогда не отправляет ваши файлы, чаты или данные об использовании на сервер. Реклама и аналитика не используются."
        case .privacyPolicyRevokeAccess: return "Отозвать доступ"
        case .privacyPolicyClose: return "Закрыть"

        case .panelHomeFolderTitle: return "Выберите домашнюю папку"
        case .panelHomeFolderMessage: return "MacClean очищает только выбранную домашнюю папку. Доступ сохраняется между запусками."
        case .panelHomeFolderPrompt: return "Использовать эту папку"
        case .panelSystemDataTitle: return "Выберите папку для проверки"
        case .panelSystemDataMessage: return "Будет проанализировано только содержимое этой папки; другие данные приложений не сканируются автоматически."
        case .panelSystemDataPrompt: return "Проверить папку"

        case .errorWrongHomeFolder: return "Вам нужно выбрать собственную домашнюю папку в Finder: %@."
        case .errorSaveBookmark: return "Не удалось сохранить доступ к папке: %@"
        case .errorSaveSystemBookmark: return "Не удалось сохранить папку для проверки: %@"

        case .diskFreeSpace: return "%@ свободно"
        case .diskUsedOf: return "%@ использовано · Всего %@"
        case .diskUsagePercent: return "Использование диска %d%%"
        case .diskFreeSpaceBadge: return "Освободить место"
        case .diskOpenSpace: return "%@ свободного места"
        case .diskAccessibilityRing: return "Использование диска %d процентов"

        case .categoryCachesTitle: return "Кэши приложений"
        case .categoryCachesSubtitle: return "Восстанавливаемые данные приложений"
        case .categoryCachesSafetyNote: return "Эти данные можно восстановить. Выбранные элементы удаляются навсегда."
        case .categoryCachesReviewDesc: return "Удаляются временные изображения, обновления и данные ускорения, загруженные приложениями. Приложения восстанавливают их по мере необходимости."
        case .categoryCachesProtectedNote: return "История браузера, закладки, сохранённые пароли и активные сеансы хранятся в папках профиля приложения — это сканирование их не затрагивает. Первые запуски могут быть чуть медленнее."

        case .categoryLogsTitle: return "Журналы и отчёты"
        case .categoryLogsSubtitle: return "Старые журналы ошибок и диагностические отчёты"
        case .categoryLogsSafetyNote: return "Эти данные можно восстановить. Выбранные элементы удаляются навсегда."
        case .categoryLogsReviewDesc: return "Удаляются старые журналы и отчёты о сбоях приложений. Это не файлы проекта и не настройки приложения."

        case .categoryDeveloperTitle: return "Артефакты сборки Xcode"
        case .categoryDeveloperSubtitle: return "DerivedData и кэши симулятора"
        case .categoryDeveloperSafetyNote: return "Эти данные можно восстановить. Выбранные элементы удаляются навсегда."
        case .categoryDeveloperReviewDesc: return "Удаляются только Xcode DerivedData, кэши CoreSimulator и кэш Xcode. При следующей сборке некоторые пакеты и промежуточные результаты могут быть восстановлены."
        case .categoryDeveloperProtectedNote: return "`.xcodeproj`, `.xcworkspace`, исходный код Swift, репозитории Git, архивы Xcode и данные устройств симулятора исключены из этой категории."

        case .categoryInstallersTitle: return "Загруженные установщики"
        case .categoryInstallersSubtitle: return "Файлы DMG, PKG, ZIP и подобные"
        case .categoryInstallersSafetyNote: return "Выбранные элементы перемещаются в Корзину. Очистите Корзину, чтобы место действительно освободилось."
        case .categoryInstallersReviewDesc: return "Загруженные файлы DMG, PKG, ZIP и подобные установщики перемещаются в Корзину. Их содержимое или установленные приложения не затрагиваются."
        case .categoryInstallersProtectedNote: return "Установленные приложения не удаляются — в список включены только загруженные пакеты установщиков."

        case .categoryLargeFilesTitle: return "Большие старые файлы"
        case .categoryLargeFilesSubtitle: return "Файлы от 500 МБ в домашних папках"
        case .categoryLargeFilesSafetyNote: return "Выбранные элементы перемещаются в Корзину. Очистите Корзину, чтобы место действительно освободилось."
        case .categoryLargeFilesReviewDesc: return "Файлы от 500 МБ возрастом не менее 14 дней, найденные только в корне папок «Загрузки», «Рабочий стол», «Документы» и «Фильмы», перемещаются в Корзину."
        case .categoryLargeFilesProtectedNote: return "Нажмите на папку, чтобы увидеть её содержимое, и переместите в Корзину только выбранные файлы или вложенные папки."

        case .categoryTrashTitle: return "Корзина"
        case .categoryTrashSubtitle: return "Элементы, ожидающие удаления"
        case .categoryTrashSafetyNote: return "Выбранные элементы в Корзине будут удалены навсегда."
        case .categoryTrashReviewDesc: return "Элементы, ожидающие в Корзине, удаляются навсегда. Это действие нельзя отменить."

        case .storageActionManageInAppTitle: return "Управлять в приложении"
        case .storageActionManageInAppDetail: return "Эта папка может содержать реальные данные приложения. Безопаснее использовать встроенное управление хранилищем приложения."
        case .storageActionManageInXcodeTitle: return "Управлять в Xcode"
        case .storageActionManageInXcodeDetail: return "Эта область содержит установленные устройства симулятора, а не ваши проекты. Удалите неиспользуемые устройства из Xcode."
        case .storageActionManageInDockerTitle: return "Управлять в Docker Desktop"
        case .storageActionManageInDockerDetail: return "Здесь могут быть образы, контейнеры и тома. Используйте Docker Desktop, чтобы видеть и управлять тем, что удалять."
        case .storageActionRemoveIfUnusedTitle: return "Удалить, если не используется"
        case .storageActionRemoveIfUnusedDetail: return "Если вы больше не используете приложение, сначала закройте и удалите его; затем отдельно проверьте оставшиеся данные."
        case .storageActionInspectFirstTitle: return "Сначала осмотреть"
        case .storageActionInspectFirstDetail: return "Эта папка может содержать настройки приложения, профили или локальные данные. Не удаляйте, не убедившись в содержимом."

        case .systemAreaSelectedFolder: return "Выбранная папка"
        case .systemAreaSelectedSubtitle: return "Большие элементы в выбранной папке"
        case .systemAreaAppData: return "Данные приложений"
        case .systemAreaAppDataSubtitle: return "Профили приложений, локальные данные и рабочие пространства"
        case .systemAreaSharedAppData: return "Общие данные приложений"
        case .systemAreaSharedAppDataSubtitle: return "Мессенджеры, офисные и общие хранилища приложений"
        case .systemAreaDeveloperData: return "Данные разработчика"
        case .systemAreaDeveloperDataSubtitle: return "Данные Xcode и iOS-симулятора"
        case .systemAreaSandboxData: return "Данные изолированных приложений"
        case .systemAreaSandboxDataSubtitle: return "Локальные файлы Docker и изолированных приложений"
        case .systemMetaWhatsApp: return "Медиа и данные чатов WhatsApp"
        case .systemMetaWhatsAppSummary: return "Загруженные медиафайлы чатов, данные сообщений и состояние приложения"
        case .systemMetaKiro: return "Kiro"
        case .systemMetaKiroSummary: return "Рабочее пространство, расширения, журналы и локальные данные приложения"
        case .systemMetaCoreSimulator: return "iOS-симуляторы"
        case .systemMetaCoreSimulatorSummary: return "Установленные устройства симулятора и их данные приложений"
        case .systemMetaDocker: return "Docker"
        case .systemMetaDockerSummary: return "Виртуальная машина, образы, контейнеры и данные томов"
        case .systemMetaMuMu: return "Эмулятор Android MuMu"
        case .systemMetaMuMuSummary: return "Эмулятор Android, загруженные системные файлы и данные приложений"
        case .systemMetaBrowser: return "Профиль браузера"
        case .systemMetaBrowserSummary: return "Профиль браузера, загруженные данные и локальное состояние браузера"
        case .systemMetaCodeEditor: return "Редактор кода / ИИ-приложение"
        case .systemMetaCodeEditorSummary: return "Локальные данные редактора кода или ИИ-приложения"
        case .systemMetaGenericApp: return "Локальные данные, созданные приложением"

        case .storageBrowserGoUp: return "Перейти вверх"
        case .fullDiskSetupStep1: return "В открывшемся экране «Системные настройки» включите MacClean. Если он не отображается, добавьте MacClean.app кнопкой +."
        case .fullDiskSetupStep2: return "Вернитесь в это окно и нажмите «Я включил доступ»."
        case .homeFolderSetupStep1: return "В открывшемся окне Finder выберите домашнюю папку с вашим именем пользователя."
        case .homeFolderSetupStep2: return "MacClean сохранит этот доступ как защищённую закладку; повторный запрос между сеансами не потребуется."
        case .privacyPolicyAdditionalNote: return "Файлы никогда не удаляются автоматически. Каждое удаление требует явного подтверждения; файлы установщиков и большие личные файлы сначала перемещаются в Корзину."
        case .privacyPolicyContact: return "Контакт: yusahmedia@gmail.com"
        case .privacyPolicyTermsLink: return "Условия использования (Apple EULA)"
        case .privacyPolicyPolicyLink: return "Политика конфиденциальности"

        case .onboardingWelcomeTitle: return "Добро пожаловать в MacClean"
        case .onboardingWelcomeSubtitle: return "Простой инструмент для поддержания вашего Mac в чистоте и быстродействии."
        case .onboardingChooseLanguage: return "Выберите язык"
        case .onboardingContinue: return "Продолжить"
        case .onboardingGetStarted: return "Начать"
        case .onboardingSkip: return "Пропустить"
        case .onboardingBack: return "Назад"
        case .onboardingStep: return "%d / %d"

        case .onboardingSlide2Title: return "Сначала сканируй, потом решай"
        case .onboardingSlide2Body: return "Приложение сначала находит всё пространство для очистки и показывает его вам. Ничего не удаляется без вашего подтверждения."
        case .onboardingSlide3Title: return "Просматривайте по категориям"
        case .onboardingSlide3Body: return "Кэши, артефакты Xcode, большие файлы и многое другое — каждое в своей категории. Вы можете детально изучить любой элемент."
        case .onboardingSlide4Title: return "Безопасно и прозрачно"
        case .onboardingSlide4Body: return "MacClean никогда не отправляет файлы на сервер. Каждое удаление требует вашего подтверждения. Элементы в Корзине можно восстановить."
        }
    }
}
