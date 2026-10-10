I have started the tests in the background and will continue as soon as they complete.
I'll wait for the tests to finish.
Arka plan testleri devam ediyor, tamamlanmasını bekliyorum.
Testlerin çalışmasını bekliyorum.
Analiz komutunun tamamlanmasını bekliyorum.
## What I changed

- [`lib/game/ui/design.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/design.dart): Yeniden kullanılabilir `EquippedGearAppearance` DTO'su, tunç/çelik/turkuaz paletinde 3/4 pozuna oturan `FighterGearPainter` vektör katmanları ve `FighterArt` / `HeroCustomizationArt` donanım katmanı entegrasyonu eklendi.
- [`lib/game/ui/screens.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/screens.dart): Yalnızca `BattlePage` içerisindeki oyuncu `FighterArt` çağrı noktasına `gear: EquippedGearAppearance.fromMap(controller.save.equippedItems)` parametresi bağlandı; başka hiçbir ekran veya navigasyon bileşenine dokunulmadı.
- [`test/equipped_gear_appearance_test.dart`](file:///D:/github/kılıc%20kalkan/test/equipped_gear_appearance_test.dart): Boş/bilinmeyen ID güvenliği, DTO dönüşümleri, her slot ve seviye için görsel piksel farkları ve `BattlePage` canlı çağrı noktası entegrasyonu için 8 adet odaklanmış test eklendi.

## How I verified it

1. **Biçimlendirme Doğrulaması**:
   ```pwsh
   dart format lib/game/ui/design.dart lib/game/ui/screens.dart test/equipped_gear_appearance_test.dart
   ```
   *Sonuç*: İlgili 3 dosya başarıyla biçimlendirildi (kod stili korundu).

2. **Statik Kod Analizi**:
   ```pwsh
   dart analyze lib/game/ui/design.dart lib/game/ui/screens.dart test/equipped_gear_appearance_test.dart
   ```
   *Sonuç*: Eklenen ve güncellenen satırlarda hiçbir hata veya uyarı üretilmedi (mevcut `screens.dart` dosyası içindeki dokunulmamış eski bloklardaki 5 info haricinde temiz).

3. **Birim ve Widget Testleri**:
   ```pwsh
   flutter test --no-pub test/equipped_gear_appearance_test.dart
   ```
   *Sonuç*: 8 testin tamamı hatasız geçti (`00:03 +8: All tests passed!`).
   - `EquippedGearAppearance` DTO yapısı, `fromMap` ile yalnızca `head`, `body`, `boots` filtrelemesi ve eşitlik (`==`, `hashCode`) sözleşmesi.
   - Bilinmeyen (`helm_unknown`, `random_item_99`) veya boş (`{}`) donanımlarda güvenli ve istisnasız çizim.
   - `FighterGearPainter.shouldRepaint` mantığının donanım durumuna duyarlılığı.
   - Her donanım yuvası (`head`, `body`, `boots`) ve seviye (tier 1–4) için tuval üzerinde piksel düzeyinde görsel farklılaşma.
   - `BattlePage` üzerinde kuşanılan eşyaların dövüşçüye yansıması ve rakip kartlarının/kozmetiklerin etkilenmemesi.

## Notes

- **Varlık (Atlas) ve Oran Ayrımı**: `assets/art/items/armor_equipment_atlas.png` dosyasındaki önden görünümlü dükkan ikonları 3/4 açılı dövüşçü gövdesine doğrudan yapıştırılmamıştır. Bunun yerine `_HeroCustomizationPainter` anatomik sınırları (`headSize`, gövde ve bacak oranları) baz alınarak oyunun tunç/turkuaz/çelik paletinde hafif vektörel zırh katmanları (`FighterGearPainter`) oluşturulmuştur.
- **Geriye Dönük Uyumluluk ve Yalıtım**:
  - `equippedItems` boş olduğunda veya oyuncu varsayılan görünümdeyken mevcut atlas portresi sıfır ek yükle korunur.
  - Rakip dövüşçülerde (`isPlayer == false`) oyuncunun donanımları asla çizilmez.
  - `models.dart`, `game_controller.dart`, `content.dart` veya kayıt şemalarına dokunulmamış, salt görsel bir DTO arayüzü kurulmuştur.
- **Kapsam Sınırı**: Bu değişiklik sadece dövüş ekranındaki oyuncu görsel katmanını kapsar; oyunun tamamının prodüksiyona hazır olduğu iddia edilmemektedir. İnceleme için değişiklikler commit edilmeden bırakılmıştır.
