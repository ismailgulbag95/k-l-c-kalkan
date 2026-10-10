Testlerin tamamlanması bekleniyor...
## What I changed

- [screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart):
  - Canlı savaş sahnesinde aktif statü rozetleri (`CombatStatusBadge`) üstteki mesafe/faz kapsülü (`top: 10`, yükseklik ~28px) ile 360px mobil genişlikte çakışmaması ve örtüşmemesi için `top: 44` konumuna yerleştirildi ve dikey `Column` yapısıyla hizalandı.
  - `CombatStatusBadge` içindeki `Row` çocuk metni (`Text`) `Flexible` ve `TextOverflow.ellipsis` ile sarılarak mobil dar görünümde ve küçük kısıtlamalarda olası `RenderFlex` taşma hataları önlendi; tekil ekran okuyucu semantiği (`ExcludeSemantics` + `Semantics(label: ...)`) korundu.
- [battle_status_audience_glyphs_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/battle_status_audience_glyphs_test.dart):
  - 360x800 mantıksal piksel mobil viewport testi eklendi: Her iki dövüşçünün de ikişer aktif statüye sahip olduğu durumda hiçbir `RenderFlex`/düzen hatası oluşmadığı (`tester.takeException() == null`), 4 rozetin de yer aldığı, etiketlerin görünür olduğu, ekran okuyucu duyurularının tekilleştirildiği ve `badgeRect.overlaps(pillRect) == false` ile mesafe/faz kapsülünü örtmediği/kesişmediği widget testiyle doğrulandı.
  - Küçük ekran görünümünde düello brifing ekranında başlat butonunun görünür alana kaydırılabilmesi için `_startBattle` test yardımcısı güncellendi.

---

## How I verified it

1. `dart format lib/game/ui/screens.dart test/battle_status_audience_glyphs_test.dart lib/game/ui/game_glyphs.dart` çalıştırıldı:
   - Tüm sahiplenilen Dart dosyaları standartlara uygun şekilde biçimlendirildi.
2. `flutter test --no-pub --reporter compact test/battle_status_audience_glyphs_test.dart` çalıştırıldı:
   ```text
   00:04 +11: All tests passed!
   ```
   11/11 odaklı testin tamamı (360x800 mobil viewport testi, rozet çizimleri, semantik etiketler ve seyirci hedef glifleri) başarıyla geçti.
3. `git status --porcelain` ile çalışma alanındaki diğer çalışanlara ait dosyaların (`assets/art/characters/*`, `rival_motion_assets.dart` vb.) korunduğu ve hiçbir yetkisiz dosyanın değiştirilmediği veya commit edilmediği doğrulandı.

---

## Notes

- 360px genişliğinde arena dolgusu (`padding: 14`) sonrası sahne genişliği 332px olmaktadır. Merkezdeki mesafe/faz kapsülü dikeyde `top: 10` ile `bottom: ~38` arasında yer almaktadır. Statü rozetleri `top: 44` konumuna alınarak dikey eksende kapsülden tamamen ayrılmış, yatayda ise sol ve sağ kenarlara yaslanarak dövüşçülerin üzerinde ve kapsülle kesişmeyecek şekilde konumlandırılmıştır.
- Tüm değişiklikler çalışma alanında incelenmek üzere uncommitted olarak bırakılmıştır.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
   M lib/game/ui/rival_motion_assets.dart
   M test/rival_motion_assets_test.dart
  ?? .agy-staff/jobs/implement-mv2t3jxo-6b374744.events.jsonl
  ?? .agy-staff/jobs/implement-mv2t3jxo-6b374744.progress.json
  ?? assets/art/characters/demir_cellat_motion.png
  ?? assets/art/characters/kul_komutani_motion.png
  ?? assets/art/characters/muhur_kirici_motion.png
  ?? assets/art/characters/tahtsiz_varis_motion.png
`git diff --stat`:
.../jobs/implement-mv2s8ry5-27f09469.events.jsonl  | 413 +++++++++++++++++++++
 .../jobs/implement-mv2s8ry5-27f09469.progress.json |   2 +-
 .agy-staff/state.json                              |  36 +-
 assets/art/manifest.md                             |  22 ++
 lib/game/ui/game_glyphs.dart                       | 382 +++++++++++++++++++
 lib/game/ui/rival_motion_assets.dart               |   4 +
 lib/game/ui/screens.dart                           | 161 ++++++--
 test/next_rival_motion_assets_test.dart            |  30 +-
 test/rival_motion_assets_test.dart                 |  17 +-
 9 files changed, 1037 insertions(+), 30 deletions(-)
New untracked files: .agy-staff/jobs/implement-mv2t3jxo-6b374744.events.jsonl, .agy-staff/jobs/implement-mv2t3jxo-6b374744.progress.json, assets/art/characters/demir_cellat_motion.png, assets/art/characters/kul_komutani_motion.png, assets/art/characters/muhur_kirici_motion.png, assets/art/characters/tahtsiz_varis_motion.png
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
