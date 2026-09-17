# MacClean — App Review Notes

## Temel işlev

MacClean, kullanıcının kendi seçtiği klasörlerdeki önbellekleri, günlükleri, Xcode derleme artıklarını ve büyük dosyaları boyutlarıyla gösterir. Uygulama hiçbir şeyi otomatik silmez; her silme işlemi açık onay ister.

## Sandbox ve dosya erişimi

App Store derlemesi `APP_STORE` yapılandırmasıyla üretilir ve App Sandbox ile `com.apple.security.files.user-selected.read-write` yetkisini kullanır. Kullanıcı erişilecek klasörü standart macOS dosya seçicisinden kendisi seçer. Uygulama seçimi security-scoped bookmark olarak yerelde saklar; klasörün dışına tarama yapmaz.

## WhatsApp veya diğer uygulama verileri

Uygulama başka uygulama verilerini kendiliğinden bulmaz ya da taramaz. Kullanıcı WhatsApp gibi bir uygulamanın klasörünü açıkça seçerse, MacClean yalnızca o seçili klasördeki yerel medya dosyalarının boyutunu gösterir. Sohbet metinleri okunmaz, hiçbir veri ağ üzerinden gönderilmez ve WhatsApp veritabanı değiştirilmez. Kullanıcının onayıyla yalnızca seçtiği yerel medya klasörü Çöp Kutusu'na taşınabilir.

## Veri kullanımı

MacClean ağ isteği, hesap, reklam, analitik veya üçüncü taraf SDK kullanmaz. Tüm analiz cihaz üzerinde gerçekleşir. App Store Connect App Privacy yanıtı: **No, we do not collect data from this app**.

## Test adımları

1. Uygulamayı aç.
2. Genel bakıştan **Ana klasörü seç** ile test klasörünü seç.
3. Bir kategorideki öğeyi incele, seç ve onayla.
4. Büyük dosya klasöründe satıra basarak alt öğeleri görüntüle; seçilen öğeyi Çöp Kutusu'na taşı.

İnceleme sırasında gerçek kullanıcı verisine ihtiyaç yoktur; boş veya test dosyası içeren herhangi bir klasör yeterlidir.
