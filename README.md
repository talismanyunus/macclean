# MacClean

macOS için, alanı tüketen gereksiz verileri görünür kılıp kullanıcının onayıyla temizleyen yerel bir SwiftUI uygulaması.

## Ne yapar?

- Uygulama önbelleklerini, günlükleri ve Xcode DerivedData'yı tarar.
- İndirilen kurulum dosyalarını (DMG/PKG/ZIP vb.) ve ana klasörlerdeki eski büyük dosyaları listeler.
- Önbellek, günlük ve geliştirici artıkları için kalıcı silmeden önce açık onay ister.
- Kurulum ve kişisel büyük dosyaları kalıcı silmek yerine önce Çöp Kutusu'na taşır.
- Sistem anlık görüntüleri, Finder Çöp Kutusu ve korumalı uygulama verilerini otomatik olarak silmez.
- macOS'un dosya seçicisinden ana klasör seçimiyle tek seferlik erişim ister; güvenli yer imi saklanır ve menü geçişlerinde yeniden istenmez.
- “Detaylı inceleme” yalnızca kullanıcının ayrıca seçtiği klasörü analiz eder. Örneğin WhatsApp verisini görmek için ilgili klasör açıkça seçilmelidir.

## Çalıştırma

Xcode'da `Package.swift` dosyasını açıp Run'a basabilir ya da Terminal'de şunu çalıştırabilirsin:

```bash
swift run MacClean
```

Finder'dan açılabilen uygulama paketini oluşturmak için:

```bash
./scripts/build-app.sh
```

> Not: Uygulama yalnızca kullanıcının ev klasöründeki açıkça tanımlı yolları tarar. Tarama büyük önbellek klasörlerinde birkaç dakika sürebilir.

## Mac App Store / App Store Connect

Uygulama App Sandbox ile imzalanır. Yalnızca kullanıcının dosya seçicisinden seçtiği klasöre okuma-yazma erişimi ister; Full Disk Access istemez.

App Store Connect paketi için önce şunları hazırla:

1. Apple Developer Program üyeliği, `com.yunussahin.macclean` için açık bir App ID ve App Store Connect'te macOS uygulama kaydı.
2. Mac App Store Connect provisioning profile, uygulama dağıtım sertifikası ve `3rd Party Mac Developer Installer` sertifikası.
3. [Gizlilik politikası](AppStore/PrivacyPolicy.md) metnini gerçek bir destek e-postasıyla tamamlayıp HTTPS üzerinden yayımla. Bu URL'yi App Store Connect'teki **Privacy Policy URL** alanına ekle.

Ardından sertifika/profil değerlerini kendi bilgilerinizle verip paketi üret:

```bash
export MACCLEAN_TEAM_ID="TEAM_ID"
export MAC_APP_STORE_APPLICATION_IDENTITY="Apple Distribution: Ad Soyad (TEAM_ID)"
export MAC_APP_STORE_INSTALLER_IDENTITY="3rd Party Mac Developer Installer: TEAM_ID"
export MAC_APP_STORE_PROVISIONING_PROFILE="/tam/yol/MacClean_AppStore.provisionprofile"
VERSION=1.0.0 BUILD_NUMBER=1 ./scripts/build-appstore-package.sh
```

Betik, doğrulanmış `build/AppStore/MacClean.pkg` üretir. Bu paketi Transporter ile App Store Connect'e yükleyebilirsin. Her yüklemede `BUILD_NUMBER` değerini artır.
