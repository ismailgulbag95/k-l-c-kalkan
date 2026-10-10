Flutter test komutu başlatıldı, sonucunu bekliyorum...
`flutter analyze` komutu çalıştırılıyor...
`dart analyze` çalıştırılıyor...
`next_rival_motion_assets_test.dart` üzerinde `dart analyze` çalıştırılıyor...
## What I changed

- [rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart#L51-L68): Karşılaşma (encounter) 10 için eskiyen `isNull` beklentisi kaldırıldı; 10–13 numaralı karşılaşmalar için güncel atlas beklentileri (`zincirci_motion.png`, `ors_muhafizi_motion.png`, `sozlesmeli_duellocu_motion.png`, `koz_golgesi_motion.png`) eklendi ve haritalanmamış kimlikler (0 ve 14) için `isNull` kontrolleri yerleştirildi.

## How I verified it

1. `dart format` çalıştırıldı:
   ```bash
   dart format test/rival_motion_assets_test.dart test/next_rival_motion_assets_test.dart
   ```
   **Sonuç:** `Formatted 2 files (0 changed) in 0.01 seconds.`

2. Statik analiz yapıldı:
   ```bash
   dart analyze test/rival_motion_assets_test.dart
   dart analyze test/next_rival_motion_assets_test.dart
   ```
   **Sonuç:** `No issues found!` (her iki dosya için).

3. İlgili testler çalıştırıldı:
   ```bash
   flutter test test/rival_motion_assets_test.dart test/next_rival_motion_assets_test.dart
   ```
   **Sonuç:**
   ```
   00:00 +0: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: early rivals map to stable dedicated motion atlases
   00:00 +1: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
   00:00 +2: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
   00:01 +3: D:/github/kılıc kalkan/test/next_rival_motion_assets_test.dart: each next rival motion atlas decodes and paints
   00:01 +4: All tests passed!
   ```

## Notes

- 1–9, 16, 24, 32 numaralı karşılaşmaların mevcut beklentileri ve #8 şampiyon atlas davranışı eksiksiz korundu.
- Haritalanmamış kimlik kontrolleri için sınır değerler olarak 0 ve 10–13 aralığından hemen sonra gelen ilk boş ID olan 14 seçildi ([`rivalMotionAtlasAssetForEncounter`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/rival_motion_assets.dart#L24-L25)).
- Üretim koduna veya başka herhangi bir dosyaya dokunulmadı; yalnızca [rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart) üzerinde cerrahi değişiklik yapıldı.
