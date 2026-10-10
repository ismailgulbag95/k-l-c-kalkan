## What I changed

- [screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart):
  - Aktif savaş statü rozetleri (`CombatStatusBadge`), 228px yüksekliğindeki arena sahnesi (`arena art`) ve portre alanının (`FighterArt`) üzerinden tamamen çıkarıldı.
  - Rozetler, sağlık/efor/mana kaynak çubuklarının altındaki ilgili oyuncu ve rakip sütunlarına (`Expanded` > `Column` > `Wrap`) taşındı (`engine.player.statuses` ve `engine.opponent.statuses`).
  - Böylece statü rozetleri dövüşçülerin (`FighterArt`) üzerini asla örtmeyecek ve merkezdeki mesafe/faz kapsülü ile hiçbir şekilde çakışmayacak şekilde düzenlendi.
- [battle_status_audience_glyphs_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/battle_status_audience_glyphs_test.dart):
  - 360x800 mantıksal piksel mobil viewport testi güncellendi: 4 aktif statü rozetinin hem oyuncu ve rakip `FighterArt` sınırlarıyla (`badgeRect.overlaps(playerFighterRect) == false` ve `badgeRect.overlaps(opponentFighterRect) == false`) hem de merkezdeki `distance/phase pill` ile (`badgeRect.overlaps(pillRect) == false`) örtüşmediği, hiçbir `RenderFlex` veya düzen hatası oluşmadığı ve tekil erişilebilir semantik etiketlerin korunduğu doğrulandı.

---

## How I verified it

1. `dart format lib/game/ui/screens.dart test/battle_status_audience_glyphs_test.dart` çalıştırıldı:
   - İlgili Dart dosyaları formatlandı (`Formatted 2 files (1 changed) in 0.36 seconds`).
2. `flutter test --no-pub --reporter compact test/battle_status_audience_glyphs_test.dart` çalıştırıldı:
   ```text
   00:04 +9: BattlePage live battle stage status badges at 360x800 mobile viewport, both fighters show two active status badges without layout overflow or overlapping FighterArt or distance/phase pill
   00:04 +10: Audience result rule rows glyph selection and accessible semantics renders criterion-specific glyph, completed/incomplete visual icons, and checked semantics
   00:04 +11: All tests passed!
   ```
   11 testin 11'i de başarıyla geçti.
3. `git status --porcelain` ile çalışma alanında diğer çalışanlara ait dosyaların korunduğu ve hiçbir yetkisiz dosyanın değiştirilmediği veya commit edilmediği doğrulandı.

---

## Notes

- Statü rozetleri `GamePanel` içindeki kaynak barlarının altına alındığı için arena sahnesinin (`ClipRRect` > `Stack`) içinden tamamen bağımsız hale gelmiştir; bu sayede dövüşçü animasyonları, görsel efektler ve merkez kapsül dövüşçü sahnesinde temiz kalmaktadır.
- Değişiklikler incelenmek üzere çalışma alanında uncommitted olarak bırakılmıştır.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
  ?? .agy-staff/jobs/implement-mv2tg3ed-6781efa8.events.jsonl
  ?? .agy-staff/jobs/implement-mv2tg3ed-6781efa8.progress.json
`git diff --stat`:
.../jobs/implement-mv2s8ry5-27f09469.events.jsonl  | 413 +++++++++++++++++++++
 .../jobs/implement-mv2s8ry5-27f09469.progress.json |   2 +-
 .agy-staff/state.json                              |  68 +++-
 assets/art/manifest.md                             |  22 ++
 lib/game/ui/game_glyphs.dart                       | 382 +++++++++++++++++++
 lib/game/ui/rival_motion_assets.dart               |   4 +
 lib/game/ui/screens.dart                           | 153 ++++++--
 test/next_rival_motion_assets_test.dart            |  30 +-
 test/rival_motion_assets_test.dart                 |  17 +-
 9 files changed, 1061 insertions(+), 30 deletions(-)
New untracked files: .agy-staff/jobs/implement-mv2tg3ed-6781efa8.events.jsonl, .agy-staff/jobs/implement-mv2tg3ed-6781efa8.progress.json
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
