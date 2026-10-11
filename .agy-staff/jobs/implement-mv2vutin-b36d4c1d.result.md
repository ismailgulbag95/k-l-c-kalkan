## What I changed

- `lib/game/ui/design.dart`: `BattleEffectVisualVariant` modeli, deterministik arena/silah renk palet eşlemeleri (`kul`, `kor`, `firtina`, `gelgit`, `tac`, `halka` ve `shortSword`, `maul`, `spear`, `bow`), güvenli varsayılan düşüşleri, `BattleImpactEffect` için isteğe bağlı `tint`/`visualVariant`/`arenaId`/`weaponFamily` desteği ve atlas çizicisi `BattleEffectAtlasPainter` eklendi.
- `lib/game/ui/screens.dart`: `BattleImpactEffect` çağrı noktasına mevcut `arena.id` ve `encounter.weaponFamily.name` parametreleri aktarıldı.
- `test/battle_effect_visual_variants_test.dart`: Eşlemeler, determinizm, bilinmeyen kimlikler için güvenli varsayılanlar ve painter renk tonu (tint) aktarımını doğrulayan odaklanmış testler eklendi.

## How I verified it

Doğrulama ve analiz adımları toplu çalıştırma kuralına uygun olarak test/analiz/derleme çalıştırılmadan statik ve diff seviyesinde doğrulandı. Değişiklikleri doğrulamak için çalıştırılacak odak test komutu:

```bash
flutter test test/battle_effect_visual_variants_test.dart
```

## Notes

- Önceki çalışandan kalan `BattleEffectMotionProfile` ve `BattleImpactEffect` animasyon süre/ölçek davranışları, atlas koordinatları, `reducedMotion`, `IgnorePointer` ve `ExcludeSemantics` yapıları eksiksiz korundu.
- Silah öncelikli efektler (`impact`, `block`, `arrow`, `dust`) için silah kimliği dominant (%72) tutulurken arena ortam paletinin katkısı korundu; ortam/elemental efektler (`healing`, `wind`, `fire`, `tide`) için arena paleti dominant tutulurken silah ailesinin sonucu etkilemesi sağlandı.
- Bilinmeyen veya `null` gelen arena/silah kimlikleri için çökmeyi önleyen nötr varsayılan tonlara düşüş sağlandı.
- Hiçbir harici paket eklenmedi ve commit işlemi yapılmadı.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
   M lib/game/domain/game_controller.dart
   M lib/game/ui/screens.dart
  ?? .agy-staff/jobs/implement-mv2vutin-b36d4c1d.events.jsonl
  ?? .agy-staff/jobs/implement-mv2vutin-b36d4c1d.progress.json
  ?? test/battle_effect_visual_variants_test.dart
  ?? test/battle_reward_commit_atomicity_test.dart
  ?? test/controller_save_mutation_atomicity_test.dart
  ?? test/shop_other_purchase_atomicity_test.dart
`git diff --stat`:
.agy-staff/state.json                |  44 ++++-
 docs/mobil-arena-rpg-uretim-plani.md |  14 +-
 lib/game/data/save_storage.dart      |  64 ++++++-
 lib/game/domain/game_controller.dart |  63 ++++---
 lib/game/ui/design.dart              | 332 +++++++++++++++++++++++++++++++++--
 lib/game/ui/screens.dart             |   2 +
 6 files changed, 477 insertions(+), 42 deletions(-)
New untracked files: .agy-staff/jobs/implement-mv2vutin-b36d4c1d.events.jsonl, .agy-staff/jobs/implement-mv2vutin-b36d4c1d.progress.json, test/battle_effect_visual_variants_test.dart, test/battle_reward_commit_atomicity_test.dart, test/controller_save_mutation_atomicity_test.dart, test/shop_other_purchase_atomicity_test.dart
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
