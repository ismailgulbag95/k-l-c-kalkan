## What I changed

- [`lib/game/domain/game_controller.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/domain/game_controller.dart): Dükkân dışındaki kalıcı mutasyonların (`spendStat`, `createHero`, `updateHeroAppearance`, `buySpell`, `buyConsumable`, `equip`, `updateSettings`, `chooseIntermissionReward`, `markStoryEvidenceSeen`, `redistributeStats`, `unlockMastery`, `resolveBattle`, `resetCampaign`) disk yazma hatasında önceki in-memory durumunu koruma ve hata fırlatma sözleşmesi geri yüklenirken, `buyItem` ve `sellItem` metodlarının atomik geri alma (rollback) davranışı ve FIFO kuyruk sıralaması korundu.
- [`test/save_mutation_concurrency_test.dart`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/save_mutation_concurrency_test.dart): Başarısız `spendStat` test senaryosu, yazma hatasında Future'ın istisna fırlatmasını, bellekteki stat artışının korunmasını, kalıcı depolamanın sonraki başarılı yazmaya kadar eski anlık görüntüyü tutmasını ve kuyruğun kurtarılmasını doğrulayacak şekilde güncellendi.

## How I verified it

1. **Temel Regresyon Kaydı (Baseline)**:
   `test/save_mutation_concurrency_test.dart` içindeki test beklentisi eski sözleşmeyi (bellekte 3 puan, diskte 2 puan) yansıtacak şekilde güncellenip mevcut kod üzerinde çalıştırıldığında regresyon kaydedildi:
   ```powershell
   flutter test test/save_mutation_concurrency_test.dart
   ```
   **Sonuç (Başarısız - Regresyon Doğrulandı)**:
   ```text
   00:00 +5 -1: save mutation FIFO concurrency invariant storage failure on non-shop mutation throws and queue recovers for next mutation [E]
     Expected: <3>
       Actual: <2>
   Failing tests:
     D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant storage failure on non-shop mutation throws and queue recovers for next mutation
   ```

2. **Düzeltme Sonrası Doğrulama (Post-fix)**:
   İstenen üç test komutu sırayla çalıştırıldı:
   ```powershell
   flutter test test/save_mutation_concurrency_test.dart
   flutter test test/shop_settings_concurrency_test.dart
   flutter test test/economy_persistence_atomicity_test.dart
   ```
   **Sonuçlar**:
   - `test/save_mutation_concurrency_test.dart`:
     ```text
     00:00 +6: All tests passed!
     ```
   - `test/shop_settings_concurrency_test.dart`:
     ```text
     00:00 +3: All tests passed!
     ```
   - `test/economy_persistence_atomicity_test.dart`:
     ```text
     00:00 +6: All tests passed!
     ```

## Notes

- `buyItem` ve `sellItem` metodları atomik rollback davranışını korumaktadır: Yazma hatası oluştuğunda `_save` güncellenmez, hata fırlatılmaz ve `'Kayıt yazılamadı: ...'` metni döndürülür.
- Dükkân dışındaki mutasyonlarda (`spendStat` ve diğerleri) `_save` bellekte güncellenip `notifyListeners()` çağrıldıktan sonra depolama yazımı beklenir; yazma başarısız olursa istisna fırlatılır ancak bellekteki değişiklik korunur. Kuyruk `whenComplete` mekanizması sayesinde sonraki mutasyonları çalıştırmaya devam eder ve bir sonraki başarılı yazma bellekteki birikmiş durumu diske kalıcı olarak işler.
- `startEncounter`, `startContract`, `startChampionsRoad`, `persistActiveBattleCheckpoint` ve `performAction` kontrol noktası (checkpoint) yollarındaki mevcut fire-and-forget hata yakalama davranışları aynen korundu.
- Yalnızca izin verilen iki dosya değiştirildi; `screens.dart`, diğer testler ve paylaşılan bileşenler ellenmedi. Git deposu bulunmadığı için git diff veya commit işlemi yapılmadı.
