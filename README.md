# Kül Çemberi

Kül Çemberi, Flutter ile geliştirilen, çevrimdışı oynanabilen özgün bir mobil arena RPG’sidir. Sıra tabanlı düellolar, rakip niyeti okuma, menzil yönetimi, karakter gelişimi, ekipman ekonomisi ve 32 maçlık bir kampanya içerir. Görseller proje için özgün olarak üretildi; referans oyunun kodu veya sanat dosyaları kullanılmadı.

## İçerik

- 4 devreye yayılan 32 ana karşılaşma ve 4 bölüm finali
- 16 bir defalık ödüllü lig sözleşmesi
- Kampanya sonrası 8 ustalık sınaması
- 6 özgün arena ve bölüm sonu rakipleri için karakter illüstrasyonları
- Silah, zırh, tılsım, büyü ve sarf eşyası ilerlemesi
- Açıklanan rakip niyeti, mesafe kararları, faz geçişleri ve arena tehlikeleri
- Sadece ana kampanya galibiyetlerinde kaydedilen Seyirci Notu ve bölüm armaları
- Cihazda yerel kayıt ve sürüm yükseltmelerinde ilerleme koruma

Tam üretim kapsamı, bölüm tasarımı, ekonomi, görsel yön, içerik manifesti ve kabul ölçütleri için [`docs/mobil-arena-rpg-uretim-plani.md`](docs/mobil-arena-rpg-uretim-plani.md) dosyasına bakın.

## Geliştirme ortamı

Proje Flutter SDK ve `pubspec.yaml` içinde tanımlanan Dart sürümünü gerektirir.

```powershell
flutter pub get
flutter run
```

Bağlı cihazları görmek için `flutter devices` çalıştırın. Android telefonda çalıştırmak için geliştirici seçenekleri ve USB hata ayıklaması açık olmalıdır.

## Doğrulama ve derleme

```powershell
flutter test --no-pub --reporter expanded
dart analyze
```

Windows Android release derlemesi için `tool/build_android.ps1` kaynağı aynı sürücüdeki geçici ASCII klasörüne kopyalar. Bu checkout yolundaki Türkçe karakterler Windows AOT/Gradle araçlarını bozabildiğinden, script APK veya mağaza App Bundle’ını üretip çıktıyı projeye geri kopyalar:

```powershell
.\tool\build_android.ps1 -Format apk
.\tool\build_android.ps1 -Format appbundle
```

Mevcut APK, cihaza yüklenip oynanabilir release modunda bir doğrulama paketidir. Android kimliği hâlâ `com.example.ash_circuit` ve release imzası Flutter şablonundaki debug anahtarıdır; mağaza yayını öncesi benzersiz uygulama kimliği ile özel imzalama anahtarı tanımlanmalıdır.

Web hedefini doğrulamak veya masaüstü tarayıcıda çalıştırmak için:

```powershell
flutter build web --release
flutter run -d chrome
```

iOS derleme ve mağaza imzalama adımları macOS ve Xcode gerektirir.

## Proje yapısı

- `lib/game/domain/`: savaş kuralları, ekonomi, kayıt modeli ve oyun denetleyicisi
- `lib/game/data/`: 32 maç, 16 sözleşme, arena, eşya ve büyü kataloğu
- `lib/game/ui/`: Flutter ekranları, tema, çizim bileşenleri
- `assets/art/`: özgün arena ve karakter görselleri
- `test/`: savaş, kayıt, ekonomi, kampanya ve widget testleri
- `docs/`: üretime dönük oyun tasarım ve içerik planı

Oyun şu anda yerel kayıt için `shared_preferences` kullanır. Bu seçim tek cihazlı, çevrimdışı kampanyaya uygundur; bulut eşitleme veya çevrimiçi özellikler kapsamda değildir.
