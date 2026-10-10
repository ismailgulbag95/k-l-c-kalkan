## What I changed

- [test/battle_action_semantics_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/battle_action_semantics_test.dart) — `controller.battle` okunmadan ve widget oluşturulmadan önce üç `startEncounter` çağrısı `await` ile beklendi.
- [test/campaign_balance_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/campaign_balance_test.dart) — `_run` simülasyon döngüsünde `controller.battle!` erişilmeden önce `startEncounter` çağrısı `await` ile beklendi.
- [test/champions_road_balance_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/champions_road_balance_test.dart) — `_runRoad` fonksiyonunda dövüş adımları işletilmeden önce `startChampionsRoad` çağrısı `await` ile beklendi.
- [test/game_domain_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/game_domain_test.dart) — `_winFirstEncounter` ve seyirci/ödül kontrolleri öncesinde yer alan tüm `startEncounter` ve `startContract` çağrıları `await` ile beklendi.
- [test/game_regression_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/game_regression_test.dart) — Geçerli tüm başlangıçlar `await` ile beklendi; geçersiz asenkron başlangıçlar için senkron matcher'lar `await expectLater(..., throwsA(...))` ile güncellendi.
- [test/l10n_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/l10n_test.dart) — BattlePage widget'ı render edilmeden önce `startEncounter` çağrısı `await` ile beklendi.
- [test/mechanics_regression_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/mechanics_regression_test.dart) — Çift çözümleme testinde `game.battle!` okunmadan önce `startEncounter` çağrısı `await` ile beklendi.
- [test/min_attribute_shop_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/min_attribute_shop_test.dart) — Sıfırlanan kontrolcüde dövüş başlatılırken `restored.startEncounter` çağrısı `await` ile beklendi.
- [test/replay_result_ui_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/replay_result_ui_test.dart) — `_seedForCampaignWin` ve `_seedForContractLoss` yardımcı fonksiyonları `Future<int>` asenkron yapıya dönüştürüldü ve tüm çağrı noktalarıyla birlikte `await` edildi.
- [test/widget_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/widget_test.dart) — Checkpoint saklama ve UI render işlemlerinden önce `startEncounter` çağrıları `await` ile beklendi.
- [test/save_mutation_concurrency_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/save_mutation_concurrency_test.dart) — Artık kullanılmayan `BattleEngine` import'u kaldırıldı ve dosya formatlandı; eşzamanlı Future sıralaması aynen korundu.

## How I verified it

1. `dart format` çalıştırıldı:
   ```powershell
   dart format test/battle_action_semantics_test.dart test/campaign_balance_test.dart test/champions_road_balance_test.dart test/game_domain_test.dart test/game_regression_test.dart test/l10n_test.dart test/mechanics_regression_test.dart test/min_attribute_shop_test.dart test/replay_result_ui_test.dart test/widget_test.dart test/save_mutation_concurrency_test.dart
   ```
   Sonuç: Tüm 11 dosya başarıyla formatlandı (0 exit code).

2. Odaklı testler çalıştırıldı:
   - `flutter test test/replay_result_ui_test.dart`: 2/2 test geçti (önceki 2 hata giderildi).
   - `flutter test test/battle_action_semantics_test.dart test/l10n_test.dart test/mechanics_regression_test.dart test/min_attribute_shop_test.dart test/save_mutation_concurrency_test.dart`: 29/29 test geçti.
   - `flutter test test/game_domain_test.dart test/widget_test.dart`: 47/47 test geçti.

3. Tüm test paketi çalıştırıldı:
   ```powershell
   flutter test --no-pub --reporter compact
   ```
   **Sonuç:** Toplam 148 testten **147 test geçti, 1 test başarısız oldu** (`00:24 +147 -1: Some tests failed.`).
   Önceki 4 hatadan 3'ü (asenkron battle start kaynaklı olanlar) tamamen çözüldü.

## Notes

- **Kalan Tek Hata ve Teşhisi:**
  - Başarısız olan test: `test/game_regression_test.dart` -> `offline persistence a failed schema migration keeps the recovered campaign in memory` (Satır 602).
  - Beklenen: `contains 'Kayıt yazılamadı'` | Gerçekleşen: `<null>`
  - Teşhis: [lib/game/domain/game_controller.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/domain/game_controller.dart#L136-L143) dosyasındaki `initialize()` fonksiyonunda, şema yükseltmesi (`schemaVersion < 9`) yapıldığında `await _storage.write(_save)` doğrudan çağrılmakta ve hata `on Object {}` bloğu ile sessizce yakalanmaktadır. `_writeStorage(save)` kullanılmadığı için `lastError` atanmamakta ve `null` kalmaktadır.
  - Alınan Karar: "Production code is off limits" ve "do not modify source to satisfy tests" kuralları gereğince üretim koduna müdahale edilmemiş, test dosyaları içinde de görevin kapsamı dışındaki beklentilere dokunulmamıştır.
- `test/save_mutation_concurrency_test.dart` içindeki kasıtlı ertelenmiş Future ve `writeGate` sıralaması bozulmadan korunmuş, sadece kullanılmayan import temizlenmiştir.
