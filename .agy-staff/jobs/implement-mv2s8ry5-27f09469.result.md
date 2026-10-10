Testler arka planda çalıştırıldı, sonuç bekleniyor.
## What I changed

- [`lib/game/ui/game_glyphs.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/game_glyphs.dart): Dört `StatusKind` değeri (`statusStagger`, `statusBleed`, `statusBurn`, `statusBrokenGuard`) ve dört seyirci hedef kriteri (`audienceTactics`, `audienceAnswerAttack`, `audienceAvoidHazard`, `audienceChangeRange`) için 24×24 Canvas vektör glifleri eklendi; glifler için kararlı eşleme (`glyphForStatusKind`, `glyphForStatusId`, `glyphForStatus`, `audienceGlyphForMessageId`, `glyphForAudienceRule`, `tryAudienceGlyphForMessageId`) ve yerelleştirilmiş / statik semantic label çözümleyicileri tanımlandı.
- [`lib/game/ui/screens.dart`](file:///D:/github/kılıc%20kalkan/lib/game/ui/screens.dart): Canlı savaş sahnesinde (`BattlePage` stage Stack) oyuncu ve rakip üzerindeki tüm aktif statüler için glif ve yerelleştirilmiş etiketi tek bir ekran okuyucu duyurusuyla sunan kompakt `_CombatStatusBadge` rozetleri eklendi; sonuç diyaloğundaki seyirci kuralı satırlarına kritere özel glifler, tamamlanma durumunu yalnızca renge bağlı kalmadan ifade eden ikonlar ve erişilebilir `Semantics(checked: ...)` eklendi.
- [`test/battle_status_audience_glyphs_test.dart`](file:///D:/github/kılıc%20kalkan/test/battle_status_audience_glyphs_test.dart): Yeni eklenen 8 glif türünün hatasız çizimi, statü ve seyirci ID eşleme/fallback davranışları, semantik etiketler, canlı savaş sahnesi rozetleri ve seyirci sonuç satırlarının erişilebilir işaretlenme semantikleri için izole edilmiş 10 odaklı test eklendi.

## How I verified it

1. `dart format lib/game/ui/game_glyphs.dart lib/game/ui/screens.dart test/battle_status_audience_glyphs_test.dart` çalıştırıldı ve tüm Dart dosyaları biçimlendirildi.
2. `flutter test --no-pub --reporter compact test/battle_status_audience_glyphs_test.dart` çalıştırıldı.
   - Sonuç: `00:04 +10: All tests passed!` (10/10 test başarılı).

## Notes

- Yeni yerelleştirme dosyası veya sabit metin eklenmeden, mevcut `label.status.<name>` ve `rule.message.id` anahtarları ile bağlam dışı durumlar için Türkçe statik fallback'ler kullanıldı.
- Ekran okuyucu çift anonslarını önlemek adına glifler ve alt metinler `ExcludeSemantics` ile sınırlandırılarak, ana semantic etiket ve `checked` durumu kapsayıcı `Semantics` üzerinden tekil olarak sunuldu.
- Bilinmeyen seyirci mesaj ID'leri için güvenli görsel fallback olarak `GameGlyphKind.arena` ve kontrol ikonları korundu; bilinmeyen statü girdileri için `GameGlyphKind.statusStagger` varsayılan fallback olarak sağlandı.
- Ortak çalışma alanındaki diğer süreçlere ait dosyalar (`assets/art/characters`, `lib/game/ui/rival_motion_assets.dart`, `assets/art/manifest.md`, mevcut testler vb.) korunarak yalnızca talimat kapsamındaki üç dosya üzerinde çalışıldı ve değişiklikler inceleme için uncommitted bırakıldı.

[unrestricted] Working tree is dirty after implement. Existing pre-run changes may be part of the task context.
Status entries that appeared or changed during the run:
  M .agy-staff/jobs/implement-mv2s8ry5-27f09469.events.jsonl
   M .agy-staff/jobs/implement-mv2s8ry5-27f09469.progress.json
   M assets/art/manifest.md
   M lib/game/ui/game_glyphs.dart
   M lib/game/ui/screens.dart
   M test/next_rival_motion_assets_test.dart
  ?? test/battle_status_audience_glyphs_test.dart
`git diff --stat`:
.../jobs/implement-mv2s8ry5-27f09469.events.jsonl  | 413 +++++++++++++++++++++
 .../jobs/implement-mv2s8ry5-27f09469.progress.json |   2 +-
 assets/art/manifest.md                             |  11 +
 lib/game/ui/game_glyphs.dart                       | 382 +++++++++++++++++++
 lib/game/ui/screens.dart                           | 160 ++++++--
 test/next_rival_motion_assets_test.dart            |   5 +-
 6 files changed, 949 insertions(+), 24 deletions(-)
New untracked files: test/battle_status_audience_glyphs_test.dart
ACTION FOR THE CALLING AGENT: inspect the current workspace (`git status --short`, `git diff`) and distinguish pre-run dirty paths from this run's delta. Continue the same agy conversation for follow-up work. If committing or opening a PR, first verify the task explicitly authorized that delivery.
