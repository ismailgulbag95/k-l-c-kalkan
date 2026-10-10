## What I changed

- [`test/shop_settings_concurrency_test.dart`](file:///D:/github/kılıc%20kalkan/test/shop_settings_concurrency_test.dart): Dükkân satın alma/satma ve eşzamanlı [`updateSettings`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L850-L872) çağrılarının bellek ve disk durumunu deterministik olarak test eden gerileme (regression) test paketi eklendi.
- [`lib/game/domain/game_controller.dart`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L850-L872): [`updateSettings`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L850-L872) metodu, işlem sırasındaki yarış durumunu (race condition) engellemek için [`_shopTransactionQueue`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L702) zincirine dahil edilerek güvenli bir şekilde sıralandı (serialized).

---

## How I verified it

1. **Temel Yeniden Üretim Doğrulaması (Baseline Reproduction):**
   Önce [`test/shop_settings_concurrency_test.dart`](file:///D:/github/kılıc%20kalkan/test/shop_settings_concurrency_test.dart) oluşturuldu ve mevcut kod tabanında çalıştırıldı:
   ```powershell
   flutter test test/shop_settings_concurrency_test.dart
   ```
   **Sonuç:** Yarış durumu deterministik olarak başarıyla yeniden üretildi ve test başarısız oldu:
   ```text
   00:00 +0 -1: shop and settings persistence concurrency purchase and concurrent updateSettings both survive in memory and storage [E]
     Expected: false
       Actual: <true>
     test\shop_settings_concurrency_test.dart 80:9
   ```
   *Açıklama:* Satın alma işlemi disk yazımında bekletilirken unawaited olarak çağrılan [`updateSettings`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L850-L872), satın alma henüz tamamlanmadığı için eski ekonomi verisini içeren anlık görüntüyü diske yazmış ve ardından satın alma işlemi belleğe adayı (`candidate`) atadığında yeni ayarlar bellekte ezilerek kaybolmuştu.

2. **Düzeltme Sonrası Regresyon Testi:**
   [`updateSettings`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L850-L872) için sıralama düzeltmesi uygulandıktan sonra yeni test paketi tekrar çalıştırıldı:
   ```powershell
   flutter test test/shop_settings_concurrency_test.dart
   ```
   **Sonuç:** Satın alma, satış ve başarısız satın alma senaryolarını içeren tüm 3 test başarıyla geçti (`All tests passed!`).

3. **Mevcut Atomiklik Testlerinin Doğrulanması:**
   Mevcut ekonomi atomiklik test paketi çalıştırıldı:
   ```powershell
   flutter test test/economy_persistence_atomicity_test.dart
   ```
   **Sonuç:** Tüm 6 test hiçbir regresyon veya yazma sayısı (`writeCount`) sapması olmadan başarıyla geçti (`00:00 +6: All tests passed!`).

---

## Notes

- **Kabul Edilen Tasarım / Çözüm:** [`updateSettings`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L850-L872) çağrısı `_shopTransactionQueue` zincirine bağlanarak, aktif bir [`_runShopTransaction`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L704-L733) yazma aşamasındayken ayarların araya girip eski durumu yakalaması engellendi. Kuyruktaki hata izolasyonu `catchError((_) {})` ile korunarak olası bir persist hatasında sonraki işlemlerin kilitlenmemesi sağlandı.
- **Reddedilen Alternatifler:**
  - `_writes` future'ına doğrudan bağlanmak reddedildi çünkü [`_runShopTransaction`](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart#L704-L733) içerisindeki `_save = candidate` ataması `await queuedWrite` sonrasında mikro-görev kuyruğunda gerçekleşmektedir; doğrudan `_writes` dinlenmesi durumunda mikro-adım seviyesinde yarış devam edebilirdi.
  - Geniş kapsamlı bir "tüm metotları kapsayan global kilit/kuyruk" refaktörü, asgari fark (minimal diff) ilkesi ve kapsam kaymasını (scope creep) önlemek amacıyla reddedildi.
- **Dokunulmayan Alanlar:** [`test/economy_persistence_atomicity_test.dart`](file:///D:/github/kılıc%20kalkan/test/economy_persistence_atomicity_test.dart), `models.dart`, `save_storage.dart`, lokalizasyon ve görünüm semantiği dosyalarına kural gereği dokunulmadı.
