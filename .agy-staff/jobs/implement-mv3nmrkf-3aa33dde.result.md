Son tutarlılık ve temizleme düzeltmeleri tamamlanmıştır:

### 1. Tamamlanan Düzeltmeler

1. **`HeroCustomizationArt` ve `_HeroCustomizationPainter` Yükleme Bağımlılığı Temizliği** ([`lib/game/ui/design.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/design.dart#L1594-L1656)):
   - `HeroCustomizationArt` içindeki kullanılmayan ve rafa kaldırılmış olan `assets/art/characters/hero_head_layers.png` görselinin iç içe (nested) `FutureBuilder` ile gereksiz yüklenmesi kaldırıldı. Artık sadece `hero_body_layers.png` ve `hero_facial_hair_layers.png` yüklenmektedir.
   - `_HeroCustomizationPainter` sınıfından kullanılmayan `headAtlas` parametresi, alan tanımı ve `shouldRepaint` içindeki `!identical(headAtlas, oldDelegate.headAtlas)` kontrolü kaldırıldı.
   - Kayıt modelindeki `headOptionId`/`skinToneId` geriye dönük uyumluluğu, gövde, yüz kılı, renk vurguları ve kuşanılan donanım (`gear`) çizimleri ile ilerideki olası tam oturan sanat geliştirmeleri için `hero_head_layers.png` atlas varlığı ve kimlik tanımları aynen korundu.

2. **Wiki Karşılaştırma Satırları ve Tarihsel Notların Hükmü** ([`docs/mobil-arena-rpg-uretim-plani.md`](file:///D:/github/kılıc%20kalkan/docs/mobil-arena-rpg-uretim-plani.md#L32-L46)):
   - Orijinal oyuna ait referans olguları korunarak, ~32 ve ~45. satırlardaki ürün kapsamı yorumları aktif gövde yapısı, yüz kılı ve renk vurgusu kozmetiklerini belirtecek ve kesilmiş saç/başlık ile parçalı ten tonlarının sanat kapısında ertelendiğini açıkça ifade edecek şekilde güncellendi.
   - §13.12 karar metnine, bu kararın saç ve ten kontrollerinin aktif olduğunu belirten önceki §8.4 ve §13.11 tarihli notların yerine geçtiğini (supersede ettiğini) ve söz konusu eski notların tarihlendirilmiş geliştirme geçmişi olarak saklandığını belirten açık cümle eklendi.

3. **Satır Sonu Whitespace Temizliği** ([`docs/mobil-arena-rpg-uretim-plani.md`](file:///D:/github/kılıc%20kalkan/docs/mobil-arena-rpg-uretim-plani.md#L5)):
   - 5. satırdaki (`**Tarih:** 11 Ekim 2026`) satır sonu boşlukları temizlendi; `git diff --check` sıfır uyarı/hata ile doğrulanmıştır.

4. **Önceki Adımların Bütünlüğü**:
   - `HeroAppearanceSelection.isDefault` regresyon testi, `AppearanceEditorPage` ve `CharacterCreator` yokluk (absence) ve semantik kontrolleri, eski kayıt uyumluluğu ve `FighterGearPainter.paintHead` donanım çizimi aynen korunmuştur.

---

### 2. Dokunulan Dosyalar

- [`lib/game/ui/design.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/design.dart)
- [`docs/mobil-arena-rpg-uretim-plani.md`](file:///D:/github/kılıc%20kalkan/docs/mobil-arena-rpg-uretim-plani.md)

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
  ?? .agy-staff/jobs/implement-mv3nmrkf-3aa33dde.events.jsonl
  ?? .agy-staff/jobs/implement-mv3nmrkf-3aa33dde.progress.json
`git diff --stat`:
.agy-staff/state.json                              |  146 ++-
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
 lib/game/ui/design.dart                            |  872 ++++++++++++++---
 lib/game/ui/rival_motion_assets.dart               |   64 +-
 lib/game/ui/screens.dart                           | 1032 +++++++++++++++-----
 pubspec.lock                                       |   13 +
 pubspec.yaml                                       |    2 +
 test/appearance_editor_semantics_test.dart         |  242 ++---
 test/appearance_editor_test.dart                   |  160 ++-
 test/campaign_balance_test.dart                    |   37 +-
 test/champions_road_balance_test.dart              |   11 +-
 test/game_domain_test.dart                         |   81 +-
 test/game_regression_test.dart                     |   47 +-
 test/l10n_test.dart                                |   55 ++
 test/next_rival_motion_assets_test.dart            |   72 +-
 test/player_appearance_art_test.dart               |   37 +-
 test/replay_result_ui_test.dart                    |   20 +-
 test/rival_motion_assets_test.dart                 |   68 +-
 test/save_mutation_concurrency_test.dart           |   77 +-
 test/shop_settings_concurrency_test.dart           |    6 +-
 test/widget_test.dart                              |  123 ++-
 62 files changed, 3684 insertions(+), 1052 deletions(-)
New untracked files: .agy-staff/jobs/implement-mv3nmrkf-3aa33dde.events.jsonl, .agy-staff/jobs/implement-mv3nmrkf-3aa33dde.progress.json
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
