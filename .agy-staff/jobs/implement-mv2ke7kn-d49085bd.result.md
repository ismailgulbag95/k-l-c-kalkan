We will now wait for the test task to complete.
I will now wait for the test task notification.
## What I changed

- [lib/game/domain/game_controller.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/domain/game_controller.dart): Ayrık `_writes` ve `_shopTransactionQueue` kuyrukları tek bir FIFO mutasyon kuyruğu (`_mutationQueue`) altında birleştirildi; tüm `GameSave` ve dövüş kontrol noktası mutasyonları kuyruk başındaki güncel durumdan türetilecek şekilde serileştirildi ve hata durumunda kuyruk kuyruğunun kilitlenmemesi sağlandı.
- [lib/game/ui/screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart): Dövüş başlatma çağrılarının (`startEncounter`, `startContract`, `startChampionsRoad`) `_openBattle` ve rövanş (rematch) bloklarında gezinme/çalışma öncesinde `await` edilmesi sağlandı.
- [test/save_mutation_concurrency_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/save_mutation_concurrency_test.dart): Gated storage ile bekleyen dükkân yazmaları sırasında diğer sekmelerden gelen mutasyonlar (`spendStat`, `updateHeroAppearance`, `buySpell`, `buyConsumable`, `equip`, `startEncounter`), atomik ekonomi geri alma ve hata sonrası kuyruk kurtarma davranışlarını doğrulayan kabul testleri eklendi.

---

## How I verified it

### 1. Git Deposu Durumu
Çalışma dizininde herhangi bir Git deposu bulunmamaktadır (`fatal: not a git repository`). Bu nedenle git diff çıktısı yerine doğrudan dosya bazlı değişiklikler doğrulanmıştır.

### 2. Temel Hata Kanıtı (Baseline Failures)
Üretim kodu değiştirilmeden önce yeni gated kabul testleri çalıştırıldı ve beklenen yarış durumları deterministik olarak yakalandı:

Komut:
`flutter test test/save_mutation_concurrency_test.dart`

Sonuç (5 test başarısız oldu):
- `purchase and concurrent spendStat both survive in memory and storage`: `Expected: <3>, Actual: <2>` (Dükkân yazması tamamlandığında aradaki stat artışı ezildi).
- `purchase and concurrent updateHeroAppearance both survive in memory and storage`: `Expected: 'head_02', Actual: 'head_01'` (Karakter görünümü ezildi).
- `purchase interleavings with buySpell, buyConsumable, and equip all survive and agree`: `Expected: null, Actual: 'Eşya envanterinde değil.'` (Kuyruğa alınmadığı için `equip` henüz diske yazılmamış kılıcı bulamadı).
- `shop pending plus startEncounter serializes and battle context has shop change`: `Expected: contains 'sword_1', Actual: Set:[]` (Dövüş motoru bekleyen satın alma öncesindeki eski durumla başlatıldı).
- `storage failure on non-shop mutation throws and queue recovers for next mutation`: `Expected: <2>, Actual: <3>` (Başarısız yazma öncesi bellekte mutasyon yapıldığı için bellek ile depolama uyuşmazlığı oluştu).

### 3. Düzeltme Sonrası Odaklanmış Doğrulama (Post-Fix Verification)
Düzeltmeler uygulandıktan sonra yalnızca etkilenen odaklanmış testler ve ilgili semantik testleri çalıştırıldı:

Komut:
`flutter test test/shop_settings_concurrency_test.dart test/economy_persistence_atomicity_test.dart test/save_mutation_concurrency_test.dart`

Sonuç:
```
00:00 +0: D:/github/kılıc kalkan/test/shop_settings_concurrency_test.dart: shop and settings persistence concurrency purchase and concurrent updateSettings both survive in memory and storage
00:00 +1: D:/github/kılıc kalkan/test/shop_settings_concurrency_test.dart: shop and settings persistence concurrency sale and concurrent updateSettings both survive in memory and storage
00:00 +2: D:/github/kılıc kalkan/test/shop_settings_concurrency_test.dart: shop and settings persistence concurrency failed purchase with concurrent updateSettings preserves economy rollback while saving settings
00:00 +3: D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart: economy persistence atomicity failed purchase preserves gold, inventory, and equipment in memory and storage, and retry succeeds with auto-equip without double charge
00:00 +4: D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart: economy persistence atomicity failed sale preserves gold, inventory, and equipment in memory and storage, and retry succeeds with 50%-floor resale without duplicate resale
00:00 +5: D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart: economy persistence atomicity successful purchase auto-equips when slot is empty, but preserves existing equipment when slot is occupied
00:00 +6: D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart: economy persistence atomicity sale applies 50%-floor resale and clamps negative starting balance to zero
00:00 +7: D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart: economy persistence atomicity concurrent shop transactions do not double charge or allow negative balance
00:00 +8: D:/github/kılıc kalkan/test/economy_persistence_atomicity_test.dart: economy persistence atomicity concurrent shop transaction where first fails persistence does not corrupt the second operation
00:00 +9: D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant purchase and concurrent spendStat both survive in memory and storage
00:00 +10: D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant purchase and concurrent updateHeroAppearance both survive in memory and storage
00:00 +11: D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant purchase interleavings with buySpell, buyConsumable, and equip all survive and agree
00:00 +12: D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant shop pending plus startEncounter serializes and battle context has shop change
00:00 +13: D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant failed purchase preserves economy rollback and allows queue recovery for next mutation
00:00 +14: D:/github/kılıc kalkan/test/save_mutation_concurrency_test.dart: save mutation FIFO concurrency invariant storage failure on non-shop mutation throws and queue recovers for next mutation
00:00 +15: All tests passed!
```

Ek olarak dövüş etkileşim ve UI bileşen testleri de doğrulandı:
`flutter test test/battle_action_semantics_test.dart test/widget_test.dart` (21 test geçti).

---

## Notes

### Senkron API ve Çağrı Noktaları Göçü (Call-Site Migration)
- `startEncounter`, `startContract` ve `startChampionsRoad` fonksiyonları `Future<void>` döndürecek şekilde güncellendi.
- Kuyruk boşken (`_pendingMutations == 0`) `battle` nesnesini, kontrol noktası nesnesini ve doğrulama istisnalarını hemen senkron olarak kurarlar; böylece testlerdeki senkron `controller.battle!` erişimleri ve `expect(() => ..., throwsA(...))` sözleşmeleri korunmuştur.
- Kuyrukta bekleyen başka bir mutasyon varsa (`_pendingMutations > 0`), dövüş bağlamı en öndeki güncel `_save` durumuna kadar ertelenerek serileştirilir.
- `lib/game/ui/screens.dart` içinde `_openBattle` fonksiyonu `FutureOr<void> Function() begin` kabul edecek ve `await begin()` yapacak şekilde güncellendi. Rövanş (rematch) bloklarında da bu çağrılar `await` edildi.

### İstisna ve Başarısızlık Semantiği Korunumu
- `buyItem` ve `sellItem`: Depolama yazma hatasında bellek durumu değişmeden kalır, işlem geri alınır (rollback) ve hata mesajı string olarak döndürülür (asla throw etmez).
- Kontrol noktası yazımları (`persistActiveBattleCheckpoint`, `performAction`, `startEncounter` vs.): Fire-and-forget hatası yakalanır (`catch (_) {}`), fırlatılmaz.
- Diğer mutasyonlar (`spendStat`, `createHero`, `updateHeroAppearance`, `buySpell`, `buyConsumable`, `equip`, `updateSettings`, `resolveBattle`, `resetCampaign`): Başarısız yazmada hata dışarıya fırlatılır, ancak `_save` başarılı yazma tamamlanana kadar güncellenmediği için bellek ve disk senkron kalır; kuyruk tail'ı kurtarılır (`whenComplete`), sonraki operasyonlar kilitlenmez.

### Başlatma / Kurtarma Neden Kuyruk Dışında Bırakıldı?
`initialize()`, şema sürüm yükseltme ve `_restoreActiveBattle()` işlemleri uygulama başlangıcında henüz `ready = false` iken çalıştırılır. `ready` `true` olana kadar UI sekmeleri, butonlar ve kullanıcı etkileşimleri (`MaterialApp` yükleme ekranı arkasında) tamamen kapalı olduğundan, kullanıcı tetiklemeli hiçbir mutasyonla yarışamaz.

### Kalan Riskler
- Kod tabanında Flutter UI dışından doğrudan `GameController`'ı kullanan ve `startEncounter` çağrısını kuyruk meşgulken çağıran ancak `await` etmeyen harici bir tüketici varsa, `battle` nesnesi bir mikrotask gecikmeyle gelecektir. Ancak üretim UI'ındaki tüm yollar `await` ile korunmuştur.
