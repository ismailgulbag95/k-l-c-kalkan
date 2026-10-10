## What I changed

- [`lib/game/ui/game_glyphs.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/game_glyphs.dart): Harici görsel veya emoji bağımlılığı olmadan, Flutter `Canvas`/`CustomPainter` ile Kül Çemberi paleti ve çizgi ağırlığına uygun, ölçeklenebilir ve erişilebilir 14 özel vektör glif (`campaign`, `arena`, `fighter`, `shop`, `champions`, `settings`, `coin`, `health`, `stamina`, `weapon`, `armor`, `guard`, `magic`, `supply`) tanımlayan `GameGlyph` bileşeni eklendi.
- [`lib/game/ui/screens.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart): `GameHub` alt `NavigationBar` hedeflerinin ikonları (sefer, dövüşçü, dükkân, sözleşme, ayarlar) ve doğrudan ilişkili güvenli yakın arayüz yuvaları (`GameHub` başlık kalkanı, bölüm derecesi kalkanı, dövüşçü sayfası ikmal ikonu, şampiyonlar serisi kupası ve sözleşme görseli alternatifi) etiket ve seçim semantikleri korunarak `GameGlyph` ile bağlandı.
- [`test/game_glyphs_test.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/game_glyphs_test.dart): Tüm gliflerin hatasız çizilmesini, boyutlandırma ve tema davranışlarını, bağımsız semantik etiketlerini, `excludeFromSemantics` özelliğini ve `GameHub` navigasyon entegrasyonunun etiket/seçim bütünlüğünü doğrulayan odaklanmış widget testleri eklendi.

## How I verified it

Çalıştırılan komutlar ve sonuçları:

1. **Glif Test Paketi**:
   ```pwsh
   flutter test --no-pub test/game_glyphs_test.dart
   ```
   *Sonuç*: 7 testin tamamı başarılı oldu (`00:03 +7: All tests passed!`).

2. **Mevcut Widget Entegrasyon Testleri**:
   ```pwsh
   flutter test --no-pub test/widget_test.dart
   ```
   *Sonuç*: Tüm 17 entegrasyon testi başarılı oldu (`00:06 +17: All tests passed!`).

3. **Mevcut Semantik ve Eşzamanlılık Testleri**:
   ```pwsh
   flutter test --no-pub test/battle_action_semantics_test.dart
   flutter test --no-pub test/appearance_editor_semantics_test.dart
   flutter test --no-pub test/save_mutation_concurrency_test.dart
   ```
   *Sonuç*: Tüm testler sıfır hata ile geçti.

4. **Kod Formatı ve Statik Analiz**:
   ```pwsh
   dart format lib/game/ui/game_glyphs.dart lib/game/ui/screens.dart test/game_glyphs_test.dart
   dart analyze lib/game/ui/game_glyphs.dart lib/game/ui/screens.dart
   ```
   *Sonuç*: Değiştirilen dosyalarda 0 hata ve 0 uyarı.

## Notes

- **Kasıtlı Olarak Dokunulmayan İkon Yuvaları**:
  - `ValuePill` (`Icons.monetization_on_outlined`, `Icons.monetization_on`, `Icons.add_circle`): `lib/game/ui/design.dart` dosyası içinde tanımlı olup arayüzü yalnızca `IconData` kabul etmektedir. Paylaşılan çalışma alanı kuralları gereği `design.dart` dosyasını değiştirmemek ve ekran düzeninde kırılma yaratmamak için bu alanlar bilinçli olarak `IconData` olarak bırakılmıştır.
  - `GameButton` ikonları (`Icons.sports_martial_arts`, `Icons.emoji_events`, vb.): `design.dart` içerisindeki `GameButton` bileşeni `final IconData? icon` imzasını kullandığından doğrudan dokunulmamıştır.
  - Sistem/navigasyon kontrolleri (`Icons.arrow_back`, `Icons.close`, `Icons.chevron_right`, `Icons.add`, `Icons.remove`, `Icons.edit_outlined`): Standart form ve gezinme kontrolleri olarak korunmuştur.
  - Durum seçim indikatörleri (`Icons.check_circle`, `Icons.radio_button_unchecked`, `Icons.lock_outline`): Form durum belirteçleri oldukları için değiştirilmemiştir.
- **Erişilebilirlik ve Ekran Okuyucu Uyumu**: `GameHub` alt `NavigationBar` içerisindeki glifler `excludeFromSemantics: true` ile verilmiştir; böylece `NavigationDestination` tarafından sağlanan orijinal hedef etiketleri ("Lig", "Dövüşçü", "Dükkân", "Sözleşme", "Ayarlar") ekran okuyucular için tek ve yetkili etiket olmaya devam eder ve çift anons oluşmaz. Glifler bağımsız kullanıldığında ise (`excludeFromSemantics: false`) yerelleştirilmiş kararlı semantik etiketler sunar.
- **Paylaşılan Çalışma Alanı Uyumu**: Rakip görseli çalışanının dosyalarına (`assets/art/characters/`, `lib/game/ui/rival_motion_assets.dart`, vb.) veya etki alanı dosyalarına (`content.dart`, `models.dart`, `battle_engine.dart`) dokunulmamış; diğer eşzamanlı çalışanların düzenlemeleriyle çakışma yaşanmayacak şekilde cerrahi bir diff uygulanmıştır. Değişiklikler inceleme için uncommitted bırakılmıştır.
