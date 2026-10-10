Komut arka planda çalıştırıldı, sonucun tamamlanmasını bekliyorum.
## What I changed

- [screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L5062-L5171): [`_BattleActionTile`](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L5062) bileşeni erişilebilirlik (TalkBack/VoiceOver) için tek bir düğme semantik düğümü (`Semantics`) ile sarıldı; mevcut yerelleştirilmiş metinlerden (eylem adı, maliyet, varsa isabet/hasar tahmini ve cephane/stok rozeti) birleşik `label` oluşturuldu, `isEnabled` durumu hem `preview.canUse` hem de `onTap != null` (tur işleme süreci) koşullarını yansıtacak şekilde bağlandı, alt görsel metinler ve `InkWell` kaynaklı mükerrer semantikler `excludeSemantics: true` ve `excludeFromSemantics: true` ile elendi; odaklı birim testi için `@visibleForTesting typedef BattleActionTile = _BattleActionTile;` eklendi.
- [battle_action_semantics_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/battle_action_semantics_test.dart#L1-L260): Kullanılabilir eylem (`quick`), cephane rozetli eylem (`bow`), kural gereği kullanılamayan eylem (yakın mesafede `closeDistance`) ve turun işlenmesi sırasında `onTap == null` olan devre dışı eylem durumlarını hem Türkçe hem İngilizce yerelleştirme kapsamlarında `label`, `value`, `isButton`, `isEnabled`, `hasAction(tap)` ve `childrenCount == 0` seviyesinde doğrulayan yeni odaklı test dosyası oluşturuldu.

---

## How I verified it

Yalnızca yeni test dosyası odaklı olarak çalıştırıldı:

```powershell
flutter test test/battle_action_semantics_test.dart
```

Çıktı özeti:
```text
00:00 +0: loading D:/github/kılıc kalkan/test/battle_action_semantics_test.dart
00:00 +0: Battle action tile accessibility semantics exposes single button semantics for usable, badged, and disabled actions in Turkish
00:01 +1: Battle action tile accessibility semantics exposes single button semantics for usable, badged, and disabled actions in English
00:01 +2: Battle action tile accessibility semantics reflects enabled and tap state when onTap is null (processing turn) vs non-null
00:01 +3: All tests passed!
```

---

## Notes

- **Sıralama ve Etiket Biçimi**: Görev açıklamasında belirtilen bileşen sırasına (eylem adı, güncel maliyet, varsa ilgili isabet/hasar tahmini ve varsa cephane/stok rozeti) tam uyularak metin parçaları `', '` (virgül ve boşluk) ile birleştirildi.
- **Tek Düğme Semantiği & Mükerrerliğin Önlenmesi**: `Material` dışına eklenen `Semantics(button: true, enabled: isEnabled, excludeSemantics: true)` ve `InkWell(excludeFromSemantics: true)` sayesinde ağaçta tam olarak 1 adet düğme semantik düğümü oluşturuldu ve alt metinlerin ekran okuyucuda ayrı ayrı gezinilmesi engellendi (`childrenCount == 0`).
- **Görsel Tasarım ve Dokunma Alanları**: Görsel arayüz (`Text`, padding, boyutlandırma, tema renkleri), dokunma hedefleri (`SizedBox` ve `InkWell` sınırları) ve oyun mekaniği aynen korundu; yeni çeviri anahtarı eklenmeden mevcut `label.action.*`, `costMessage` ve `ui.battle.ammo` dizgileri yeniden kullanıldı.
- **Kapsam ve Dosya Sahipliği**: Sadece belirtilen iki dosya üzerinde çalışıldı; yerelleştirme dosyaları, etki alanı/kayıt kodları, varlıklar veya diğer test dosyaları değiştirilmedi. Tam test paketi, analizci veya derleme komutları çalıştırılmadı. Değişiklikler commit edilmeden bırakıldı.
