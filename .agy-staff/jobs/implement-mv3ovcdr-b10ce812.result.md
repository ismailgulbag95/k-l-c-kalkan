[`lib/game/ui/design.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/design.dart) dosyasında satır 1686'daki `unnecessary_null_comparison` analiz uyarısı düzeltildi.

### Değişiklik Özeti
- **Dosya**: [`lib/game/ui/design.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/design.dart)
- **Açıklama**: `_HeroCustomizationPainter` sınıfındaki `facialHairAtlas` alanı non-nullable `ui.Image` olarak tanımlandığından, `paint` metodu içerisindeki `if (facialHair != null)` kontrolü ve geçici değişken ataması kaldırılarak `facialHairAtlas` doğrudan kullanıldı. Çizim geometrisi ve mantığında hiçbir değişiklik yapılmadan yalnızca gereksiz null kontrolü temizlendi.

Kural gereği test, build veya commit/push/PR yapılmamıştır; son toplu doğrulama kök ajan tarafından gerçekleştirilecektir.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
  ?? .agy-staff/jobs/implement-mv3ovcdr-b10ce812.events.jsonl
  ?? .agy-staff/jobs/implement-mv3ovcdr-b10ce812.progress.json
`git diff --stat`:
.agy-staff/state.json                              |  210 +++-
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
 assets/art/manifest.md                             |  103 +-
 docs/mobil-arena-rpg-uretim-plani.md               |  168 +++-
 lib/game/data/content.dart                         |  174 ++++
 lib/game/data/save_storage.dart                    |  113 ++-
 lib/game/domain/balance.dart                       |   23 +
 lib/game/domain/battle_engine.dart                 |  302 ++++--
 lib/game/domain/game_controller.dart               |  400 +++++---
 lib/game/domain/models.dart                        |   40 +-
 lib/game/l10n/game_localizations.dart              |  237 ++++-
 lib/game/ui/audio_service.dart                     |   11 +-
 lib/game/ui/design.dart                            |  938 +++++++++++++++---
 lib/game/ui/rival_motion_assets.dart               |   64 +-
 lib/game/ui/screens.dart                           | 1035 +++++++++++++++-----
 pubspec.lock                                       |   13 +
 pubspec.yaml                                       |    2 +
 test/appearance_editor_semantics_test.dart         |  249 +++--
 test/appearance_editor_test.dart                   |  160 ++-
 test/campaign_balance_test.dart                    |   39 +-
 test/champions_road_balance_test.dart              |   11 +-
 test/game_domain_test.dart                         |   81 +-
 test/game_regression_test.dart                     |   47 +-
 test/l10n_test.dart                                |   55 ++
 test/next_rival_motion_assets_test.dart            |   72 +-
 test/player_appearance_art_test.dart               |   40 +-
 test/replay_result_ui_test.dart                    |   20 +-
 test/rival_motion_assets_test.dart                 |   68 +-
 test/save_mutation_concurrency_test.dart           |   77 +-
 test/shop_settings_concurrency_test.dart           |    6 +-
 test/widget_test.dart                              |  123 ++-
 62 files changed, 3803 insertions(+), 1078 deletions(-)
New untracked files: .agy-staff/jobs/implement-mv3ovcdr-b10ce812.events.jsonl, .agy-staff/jobs/implement-mv3ovcdr-b10ce812.progress.json
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
