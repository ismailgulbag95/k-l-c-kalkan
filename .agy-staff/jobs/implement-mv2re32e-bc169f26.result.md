Odaklanmış test komutu çalıştırıldı, sonucun tamamlanması bekleniyor.
## What I changed

- [test/rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart#L83-L100): 19, 20, 21 ve 22 numaralı karşılaşmalar için yeni motion atlas eşlemeleri (`gelgit_muhurcusu_motion.png`, `firtina_avcisi_motion.png`, `ruzgar_seyircisi_motion.png`, `kiyi_orakcisi_motion.png`) eklendi, encounter 23'ün eşlenmemiş (`isNull`) olduğu doğrulandı ve önceki tüm test kapsamı ile encounter 0 null doğrulaması korundu.

## How I verified it

1. **Doğrudan dosya incelemesi:**
   - [test/rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart#L75-L108) satırları incelendi; 19-22 eşlemelerinin sırayla eklendiği, encounter 0 ve 23'ün `isNull` olarak doğrulandığı ve alttaki `rivalMotionAtlasFrame` ile `testWidgets` bloklarına dokunulmadığı teyit edildi.

2. **Statik analiz:**
   - Komut: `dart analyze test/rival_motion_assets_test.dart`
   - Sonuç: `Analyzing rival_motion_assets_test.dart... No issues found!` (0 hata/uyarı).

3. **Odaklanmış test çifti (Focused Pair):**
   - Komut: `flutter test --no-pub --reporter compact test/rival_motion_assets_test.dart test/next_rival_motion_assets_test.dart`
   - Sonuç:
     ```
     00:03 +0: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: early rivals map to stable dedicated motion atlases
     00:03 +1: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
     00:04 +3: D:/github/kılıc kalkan/test/next_rival_motion_assets_test.dart: each next rival motion atlas decodes and paints
     00:05 +4: All tests passed!
     ```

## Notes

- **Kapsam:** Yalnızca [test/rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart) üzerinde cerrahi değişiklik yapıldı; çalışma alanındaki diğer dosyalara ([next_rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/next_rival_motion_assets_test.dart), [rival_motion_assets.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/rival_motion_assets.dart) vb.) dokunulmadı ve diğer çalışmalar korundu.
- **Encounter 23 ve 0 sınırları:** Encounter 23 eşlenmemiş sınır olarak `expect(rivalMotionAtlasAssetForEncounter(23), isNull)` ile kontrol edilirken alt sınır olan encounter 0 null beklentisi yerinde tutuldu.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
   M test/rival_motion_assets_test.dart
  ?? .agy-staff/jobs/implement-mv2re32e-bc169f26.events.jsonl
  ?? .agy-staff/jobs/implement-mv2re32e-bc169f26.progress.json
`git diff --stat`:
.agy-staff/state.json              | 30 ++++++++++++++++++++++++++++++
 test/rival_motion_assets_test.dart | 18 +++++++++++++++++-
 2 files changed, 47 insertions(+), 1 deletion(-)
New untracked files: .agy-staff/jobs/implement-mv2re32e-bc169f26.events.jsonl, .agy-staff/jobs/implement-mv2re32e-bc169f26.progress.json
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
