I have launched the Flutter test command to verify the existing test suite and will wait for it to complete.
Mevcut testlerin tamamlanmasını bekliyorum. Testler sonuçlandığında bildirim otomatik olarak gelecektir.
Statik analiz komutunun tamamlanmasını bekliyorum. Sonuç bildirildiğinde devam edeceğim.
`dart analyze` komutunun tamamlanmasını bekliyorum.
## What I changed

- [`lib/game/ui/design.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/design.dart#L521-L526): [`rivalMotionAtlasFrame`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/design.dart#L521-L526) fonksiyonuna aktif [`FighterMotion.spell`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/design.dart#L473) animasyonunun döküm hücresi 2'ye, tamamlanan hareketin (`progress >= 1`) ise boşta hücresi 0'a eşlenmesi eklendi.
- [`test/rival_motion_assets_test.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart#L40-L41): [`rivalMotionAtlasFrame`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/design.dart#L521-L526) için tamamlanma öncesi büyü hareketinin kare 2'ye, tamamlandığında ise kare 0'a döndüğünü doğrulayan regresyon kontrolleri eklendi.

## How I verified it

1. Odaklanılan test dosyası çalıştırıldı:
   - **Komut:** `flutter test test/rival_motion_assets_test.dart`
   - **Sonuç:**
     ```text
     00:00 +0: loading D:/github/kılıc kalkan/test/rival_motion_assets_test.dart
     00:00 +0: early rivals map to stable dedicated motion atlases
     00:00 +1: each early rival atlas decodes and paints through FighterArt
     00:01 +2: All tests passed!
     ```
2. Değiştirilen dosyalarda statik analiz çalıştırıldı:
   - **Komut:** `dart analyze lib/game/ui/design.dart test/rival_motion_assets_test.dart`
   - **Sonuç:**
     ```text
     Analyzing design.dart, rival_motion_assets_test.dart...
     No issues found!
     ```

## Notes

- Mevcut saldırı (hazırlık ve vuruş), darbe alma, savunma, zafer ve yenilgi kare eşlemeleri aynen korundu.
- `FighterMotion.defeat` için `progress >= 1` durumunda yenilgi karesi (5) döndürülmeye devam etmesi gerektiğinden, büyü kontrolü `defeat` ve `victory` kontrollerinin ardından konumlandırıldı.
- Sahiplik sınırı gözetilerek yalnızca talep edilen iki dosyaya cerrahi dokunuş yapıldı; varlıklar, ekranlar veya oyun alanı mantığına dokunulmadı ve hiçbir değişiklik commit edilmedi.
