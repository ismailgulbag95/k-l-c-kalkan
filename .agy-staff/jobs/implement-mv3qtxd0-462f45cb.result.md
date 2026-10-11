## What I changed

- [game_localizations.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/l10n/game_localizations.dart): Savaş statü rozetleri için kalan tur (`ui.battle.status.turns`) ile ekran okuyucu Türkçe ve İngilizce semantik etiketleri (`ui.battle.status.semantics.full`, `ui.battle.status.semantics.turns`) eklendi.
- [screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart): [CombatStatusBadge](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L4111) bileşenine kademe (`stacks`) ve kalan tur (`remainingTurns`) parametreleri, kompakt görsel sunum (`×2 · 1 tur` / `×2 · 1 turn`), ekran okuyucu semantiği ve savaş çağrı noktalarında (`engine.player.statuses` / `engine.opponent.statuses`) durum sürelerini çözümleyen `_statusRemainingTurns` bağlandı.
- [combat_status_badge_details_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/combat_status_badge_details_test.dart): Çoklu kademe ve 1 tur kalan statü rozetlerinin görsel detaylarını, Türkçe/İngilizce ekran okuyucu semantiklerini ve 360×800 mobil ekranda `BattlePage` çağrı noktalarının taşma olmaksızın çalıştığını doğrulayan odaklanmış widget testleri oluşturuldu.

---

## How I verified it

Kullanıcının talimatı gereği (`"Do not run tests, analyzer, formatter, pub get, or build; the root agent will run the final batch after coding"`) çalışma zamanında test veya derleme komutu çalıştırılmadı. Kök ajan veya proje sahibi nihai toplu doğrulama sırasında şu komutları çalıştırabilir:

```powershell
flutter test test/combat_status_badge_details_test.dart
flutter test test/battle_status_audience_glyphs_test.dart
flutter test test/l10n_test.dart
flutter analyze lib/game/ui/screens.dart lib/game/l10n/game_localizations.dart test/combat_status_badge_details_test.dart
```

---

## Notes

- **Kompakt Görsel Biçim**: Mobil ekranın dar genişliği (360×800) ve sütun başına düşen sınırlı alan göz önünde bulundurularak, çoklu kademe ve kalan tur gösterimi `screens.dart` içerisindeki mevcut sözleşmeye uygun biçimde `×{stacks} · {turns} tur` (Türkçe) ve `×{stacks} · {turns} turn` (İngilizce) olarak kompakt tutuldu; tek kademeli durumlarda gereksiz `×1` gösterilmeyip sadece kalan tur vurgulandı.
- **Ekran Okuyucu Erişilebilirliği**: [CombatStatusBadge](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L4111) dış `Semantics` konteynerında Türkçe için `"{status}, {stacks} kademe, {turns} tur kaldı"`, İngilizce için `"{status}, {stacks} stacks, {turns} turn remaining"` formatı kullanıldı; rozet içi elemanlar `ExcludeSemantics` içinde tutularak çift seslendirme engellendi.
- **Mevcut Testlerle Geriye Dönük Uyumluluk**: [CombatStatusBadge](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L4111), `remainingTurns` belirtilmediğinde veya null olduğunda semantik etiketi temel statü adına (`localizedLabel`) düşürerek önceki sentetik testlerin (`test/battle_status_audience_glyphs_test.dart`) kırılmasını önleyecek şekilde korundu.
- **Kapsam Korunması**: Seyirci, arma, sonuç ekranı bileşenleri, tema/tipografi ve diğer ajanların çalışma ağacındaki uncommitted değişiklikleri eksiksiz muhafaza edildi. Git commit veya harici bir işlem yapılmadı.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
  ?? .agy-staff/jobs/implement-mv3qtxd0-462f45cb.events.jsonl
  ?? .agy-staff/jobs/implement-mv3qtxd0-462f45cb.progress.json
  ?? assets/art/arenas/chapter_heraldry_atlas.png
  ?? assets/art/characters/hero_body_weaponless_layers.png
  ?? assets/art/characters/hero_combat_base_layers.png
  ?? assets/fonts/
  ?? lib/game/ui/audience_emblems.dart
  ?? lib/game/ui/hero_weapon_art.dart
  ?? test/audience_emblems_test.dart
  ?? test/combat_status_badge_details_test.dart
`git diff --stat`:
.agy-staff/state.json                              |  248 +++-
 assets/art/characters/ayna_kilic_motion.png        |  Bin 2582642 -> 0 bytes
 assets/art/characters/brass_guardian_motion.png    |  Bin 2814619 -> 0 bytes
 assets/art/characters/circle_master_motion.png     |  Bin 2821779 -> 0 bytes
 assets/art/characters/curuf_tasiyici_motion.png    |  Bin 2323526 -> 0 bytes
 assets/art/characters/demir_cellat_motion.png      |  Bin 2402631 -> 0 bytes
 assets/art/characters/fener_bekcisi_motion.png     |  Bin 2448313 -> 0 bytes
 assets/art/characters/fener_champion_motion.png    |  Bin 2636228 -> 0 bytes
 assets/art/characters/firtina_avcisi_motion.png    |  Bin 2175462 -> 0 bytes
 assets/art/characters/gelgit_muhurcusu_motion.png  |  Bin 2342643 -> 0 bytes
 assets/art/characters/gelgit_yargici_motion.png    |  Bin 2617318 -> 0 bytes
 assets/art/characters/golge_duellocu_motion.png    |  Bin 2327797 -> 0 bytes
 assets/art/characters/halat_kosucusu_motion.png    |  Bin 2184193 -> 0 bytes
 assets/art/characters/halatci_sefa_motion.png      |  Bin 2224227 -> 0 bytes
 assets/art/characters/iskele_kabadayisi_motion.png |  Bin 2426898 -> 0 bytes
 assets/art/characters/kapi_bekcisi_motion.png      |  Bin 2431494 -> 0 bytes
 assets/art/characters/kiyi_orakcisi_motion.png     |  Bin 2424238 -> 0 bytes
 assets/art/characters/kizil_ocak_sefi_motion.png   |  Bin 2737968 -> 0 bytes
 assets/art/characters/koz_golgesi_motion.png       |  Bin 2277219 -> 0 bytes
 assets/art/characters/kukurt_matronu_motion.png    |  Bin 2809399 -> 0 bytes
 assets/art/characters/kul_komutani_motion.png      |  Bin 2198052 -> 0 bytes
 assets/art/characters/menzil_avcisi_motion.png     |  Bin 2157597 -> 0 bytes
 assets/art/characters/muhur_kirici_motion.png      |  Bin 2483789 -> 0 bytes
 .../art/characters/observatory_priest_motion.png   |  Bin 3065512 -> 0 bytes
 assets/art/characters/ors_muhafizi_motion.png      |  Bin 2447726 -> 0 bytes
 assets/art/characters/pasli_kanca_motion.png       |  Bin 2316616 -> 0 bytes
 assets/art/characters/ruzgar_seyircisi_motion.png  |  Bin 2159004 -> 0 bytes
 assets/art/characters/sancak_cadisi_motion.png     |  Bin 2648476 -> 0 bytes
 .../art/characters/sozlesmeli_duellocu_motion.png  |  Bin 2318382 -> 0 bytes
 assets/art/characters/tac_muhafizi_motion.png      |  Bin 2467031 -> 0 bytes
 assets/art/characters/tahtsiz_varis_motion.png     |  Bin 2377992 -> 0 bytes
 assets/art/characters/tuz_kahini_motion.png        |  Bin 2468958 -> 0 bytes
 assets/art/characters/zincirci_motion.png          |  Bin 2294820 -> 0 bytes
 assets/art/manifest.md                             |  112 +-
 docs/mobil-arena-rpg-uretim-plani.md               |  168 ++-
 lib/game/data/content.dart                         |  174 +++
 lib/game/data/save_storage.dart                    |  113 +-
 lib/game/domain/balance.dart                       |   23 +
 lib/game/domain/battle_engine.dart                 |  302 ++++-
 lib/game/domain/game_controller.dart               |  400 ++++---
 lib/game/domain/models.dart                        |   40 +-
 lib/game/l10n/game_localizations.dart              |  267 ++++-
 lib/game/ui/audio_service.dart                     |   11 +-
 lib/game/ui/design.dart                            | 1041 +++++++++++++---
 lib/game/ui/rival_motion_assets.dart               |   64 +-
 lib/game/ui/screens.dart                           | 1250 ++++++++++++++++----
 pubspec.lock                                       |   13 +
 pubspec.yaml                                       |    6 +
 test/appearance_editor_semantics_test.dart         |  249 ++--
 test/appearance_editor_test.dart                   |  160 ++-
 test/campaign_balance_test.dart                    |   39 +-
 test/champions_road_balance_test.dart              |   11 +-
 test/game_domain_test.dart                         |   81 +-
 test/game_regression_test.dart                     |   47 +-
 test/l10n_test.dart                                |   55 +
 test/next_rival_motion_assets_test.dart            |   72 +-
 test/player_appearance_art_test.dart               |   83 +-
 test/replay_result_ui_test.dart                    |   20 +-
 test/rival_motion_assets_test.dart                 |   68 +-
 test/save_mutation_concurrency_test.dart           |   77 +-
 test/shop_settings_concurrency_test.dart           |    6 +-
 test/widget_test.dart                              |  123 +-
 62 files changed, 4215 insertions(+), 1108 deletions(-)
New untracked files: .agy-staff/jobs/implement-mv3qtxd0-462f45cb.events.jsonl, .agy-staff/jobs/implement-mv3qtxd0-462f45cb.progress.json, assets/art/arenas/chapter_heraldry_atlas.png, assets/art/characters/hero_body_weaponless_layers.png, assets/art/characters/hero_combat_base_layers.png, assets/fonts/, lib/game/ui/audience_emblems.dart, lib/game/ui/hero_weapon_art.dart, test/audience_emblems_test.dart, test/combat_status_badge_details_test.dart
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
