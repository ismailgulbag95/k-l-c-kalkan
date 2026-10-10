## What I changed

- [`lib/game/domain/game_controller.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/domain/game_controller.dart#L702-L788): [`GameController.buyItem`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/domain/game_controller.dart#L735-L763) ve [`GameController.sellItem`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/domain/game_controller.dart#L765-L788) işlemlerini sıralı çalışan bir `_runShopTransaction` kuyruk yardımcısına taşıyarak kalıcılık (persistence) ile atomik hale getirdim; depolama yazma hatasında bellek içi kayıt, bakiye, envanter ve kuşanma haritasını değiştirmeden hata metnini döndürdüm.
- [`test/economy_persistence_atomicity_test.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/economy_persistence_atomicity_test.dart): `FailOnceSaveStorage` sahte sınıfı ile başarısız satın alma/satış sonrası durumun korunması, başarılı tekrar denemede tek seferlik düşüm/kazanç, ilk eşyada otomatik kuşanma, %50 taban satış fiyatı ve eşzamanlı çağrı senaryolarını doğrulayan yeni birim testleri eklendi.

## How I verified it

Yalnızca belirtilen yeni test dosyası çalıştırıldı:

```powershell
flutter test test/economy_persistence_atomicity_test.dart
```

Sonuç:
```text
00:00 +0: loading D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart
00:00 +0: economy persistence atomicity failed purchase preserves gold, inventory, and equipment in memory and storage, and retry succeeds with auto-equip without double charge
00:00 +1: economy persistence atomicity failed sale preserves gold, inventory, and equipment in memory and storage, and retry succeeds with 50%-floor resale without duplicate resale
00:00 +2: economy persistence atomicity successful purchase auto-equips when slot is empty, but preserves existing equipment when slot is occupied
00:00 +3: economy persistence atomicity sale applies 50%-floor resale and clamps negative starting balance to zero
00:00 +4: economy persistence atomicity concurrent shop transactions do not double charge or allow negative balance
00:00 +5: economy persistence atomicity concurrent shop transaction where first fails persistence does not corrupt the second operation
00:00 +6: All tests passed!
```

Tüm 6 test başarıyla geçti (`exited with code 0`).

## Notes

- **Hata Yönetimi ve UI Uyumluluğu:** Arayüz katmanındaki çağrı yerleri ([`lib/game/ui/screens.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L2567-L2576) ve [#L2729-L2732](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L2729-L2732)) `Future<String?>` sonucunu beklediğinden ve `try/catch` sarmalaması içermediğinden, kalıcılık hatasında istisna fırlatmak (rethrow) yerine hata metni (`lastError ?? 'Kayıt yazılamadı: $error'`) döndürüldü; böylece arayüz çökmesi engellendi ve başarı sessizce bildirilmedi.
- **Eşzamanlılık (Concurrency):** `_shopTransactionQueue` aracılığıyla peş peşe veya paralel gelen dükkân işlemleri sıralandı; böylece önceki işlem tamamlanmadan (yazma başarılıysa `_save` güncellenip, başarısızsa dokunulmadan) sonraki işlem başlamaz, çifte harcama ya da yeni durumun ezilmesi engellenir.
- **Kapsam Korunması:** Global `_persist` metodu, göç (migration) mantığı, cephane yenileme düzeltmeleri ve dükkân dışı diğer metodlar tamamen korundu; hiçbir mevcut dosya veya test değiştirilmedi. Çalışma kuralları gereği commit atılmadı.
