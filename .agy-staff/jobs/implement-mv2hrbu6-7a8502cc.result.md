Testler arka planda çalıştırılıyor, sonuç bekleniyor.
## What I changed

- `test/rival_motion_assets_test.dart`: Karşılaşma 5 için geçerliliğini yitirmiş `isNull` beklentisi kaldırılarak 5, 6, 7 ve 9 numaralı karşılaşmalar için açık atlas eşleme beklentileri eklendi, karşılaşma 8'in şampiyon atlas eşlemesi korunurken karşılaşma 10'un eşlenmemiş (`isNull`) olduğu doğrulandı.

## How I verified it

1. `test/rival_motion_assets_test.dart` testi çalıştırıldı:
```powershell
flutter test test/rival_motion_assets_test.dart
```
Çıktı:
```text
00:00 +0: loading D:/github/kılıc kalkan/test/rival_motion_assets_test.dart
00:00 +0: early rivals map to stable dedicated motion atlases
00:00 +1: each early rival atlas decodes and paints through FighterArt
00:01 +2: All tests passed!
```

2. `test/next_rival_motion_assets_test.dart` testi çalıştırıldı:
```powershell
flutter test test/next_rival_motion_assets_test.dart
```
Çıktı:
```text
00:00 +0: loading D:/github/kılıc kalkan/test/next_rival_motion_assets_test.dart
00:00 +0: next unregistered ordinary rivals map to stable motion atlases
00:00 +1: each next rival motion atlas decodes and paints
00:01 +2: All tests passed!
```

3. Her iki test birlikte çalıştırıldı:
```powershell
flutter test test/rival_motion_assets_test.dart test/next_rival_motion_assets_test.dart
```
Çıktı:
```text
00:00 +0: loading D:/github/kılıc kalkan/test/rival_motion_assets_test.dart
00:00 +0: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: early rivals map to stable dedicated motion atlases
00:00 +1: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
00:00 +2: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
00:01 +3: D:/github/kılıc kalkan/test/next_rival_motion_assets_test.dart: each next rival motion atlas decodes and paints
00:01 +4: All tests passed!
```

4. Biçimlendirme ve statik analiz doğrulandı:
```powershell
dart format --output=none --set-exit-if-changed test/rival_motion_assets_test.dart
dart analyze test\rival_motion_assets_test.dart
```
Her iki komut da sorunsuz (0 uyarı/hata) tamamlandı.

## Notes

- **Karşılaşma 8**: Karşılaşma 8 zaten testin ilk assertion bloğundaki liste içinde `'assets/art/characters/fener_champion_motion.png'` olarak tanımlı olduğundan, bu blok bozulmadan korundu ve gereksiz mükerrer assertion eklenmeyerek diff minimal tutuldu.
- **Kapsam**: Üretim koduna (`lib/`), varlıklara (`assets/`), diğer test dosyalarına veya UI katmanına hiçbir müdahale yapılmadı. Çalışma alanında `.git` bulunmadığı için commit/push işlemleri yapılmadı.
