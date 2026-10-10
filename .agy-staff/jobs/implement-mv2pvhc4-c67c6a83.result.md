Test komutu çalıştırıldı, sonucun tamamlanması bekleniyor.
`test/next_rival_motion_assets_test.dart` testi çalıştırıldı, sonucun tamamlanması bekleniyor.
`flutter analyze` komutu çalıştırıldı, analiz sonucunun tamamlanması bekleniyor.
Tüm Flutter test paketi (`flutter test`) çalıştırıldı, test sonuçları bekleniyor.
## What I changed

- [test/rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart#L67-L84): Eski encounter 14 null beklentisi güncellenerek 14, 15, 17 ve 18 numaralı karşılaşmalar için yeni kararlı motion atlas eşlemeleri eklendi ve 19 numaralı karşılaşmanın eşlenmemiş (`isNull`) olduğu doğrulandı.

## How I verified it

1. **Statik analiz:**
   - Komut: `dart analyze test/rival_motion_assets_test.dart`
   - Sonuç: `No issues found!` (0 hata/uyarı).

2. **Odaklanmış rakip hareket testleri (Focused Tests):**
   - Komut: `flutter test test/rival_motion_assets_test.dart test/next_rival_motion_assets_test.dart`
   - Sonuç: 4/4 test başarıyla geçti (`All tests passed!`).

3. **Tekil test dosyası:**
   - Komut: `flutter test test/rival_motion_assets_test.dart`
   - Sonuç: 2/2 test başarıyla geçti (`All tests passed!`).

4. **Tüm test paketi regresyon kontrolü:**
   - Komut: `flutter test`
   - Sonuç: 163/163 test başarıyla geçti (`All tests passed!`).

## Notes

- **Kapsam ve minimal diff:** Görev gereği yalnızca [test/rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart) dosyasında cerrahi bir değişiklik yapıldı. [next_rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/next_rival_motion_assets_test.dart) veya üretim kodu olan [rival_motion_assets.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/rival_motion_assets.dart) üzerindeki diğer çalışmalara ve mevcut test kapsamına dokunulmadı.
- **Encounter 16:** Karşılaşma 16 zaten testin başındaki listede (`[1, 2, 3, 4, 8, 16, 24, 32]`) yer aldığı ve `brass_guardian_motion.png` ile eşlendiği için tekrar eden bir tekil assertion eklenmedi; 14, 15, 17 ve 18 ardışık olarak tanımlandı.
- **Encounter 0 ve 19:** Sınır koşulları olarak encounter 0 ve encounter 19'un `isNull` olduğu doğrulandı.
