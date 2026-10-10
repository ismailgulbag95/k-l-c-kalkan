## What I changed

- [lib/game/ui/screens.dart](file:///D:/github/kılıc%20kalkan/lib/game/ui/screens.dart#L1965-L1971): `_optionChip` içerisindeki `Semantics` sarmalayıcısına `enabled: !_saving` ve `onTap: _saving ? null : () => onSelected(optionId)` alanları eklenerek ekran okuyucu butonunun etkinleştirme aksiyonu doğrudan bağlandı.
- [test/appearance_editor_semantics_test.dart](file:///D:/github/kılıc%20kalkan/test/appearance_editor_semantics_test.dart): Görünüş düzenleyici seçenek butonlarının Türkçe/İngilizce etiketlerini, seçilme durumunu, semantik tıklama aksiyonunu ve kaydetme sırasındaki devre dışı kalma durumunu doğrulayan odaklanmış widget testleri eklendi.

## How I verified it

Yalnızca belirtilen test komutu çalıştırıldı:
```powershell
flutter test --no-pub test/appearance_editor_semantics_test.dart
```

Çıktı:
```text
00:00 +0: loading D:/github/kılıc kalkan/test/appearance_editor_semantics_test.dart
00:00 +0: Appearance editor option chip accessibility semantics exposes single button semantics with Turkish localized labels, selected state, and tap action
00:01 +1: Appearance editor option chip accessibility semantics exposes single button semantics with English localized labels, selected state, and tap action
00:01 +2: Appearance editor option chip accessibility semantics updates option selection and persisted appearance when invoking semantic tap action
00:01 +3: Appearance editor option chip accessibility semantics disables semantic button and strips tap action while saving is in progress
00:02 +4: All tests passed!
```

## Notes

- **Kapsam ve Dosya İzolasyonu**: Diğer AGY işinin çalıştığı [lib/game/domain/game_controller.dart](file:///D:/github/kılıc%20kalkan/lib/game/domain/game_controller.dart) ve `test/economy_persistence_atomicity_test.dart` dosyalarına kesinlikle dokunulmadı. Lokalizasyon, modeller, varlıklar ve diğer test dosyaları değiştirilmedi.
- **Kaydetme (Saving) Doğrulaması**: Kaydetme sırasındaki devre dışı kalma durumu, harici hiçbir dosyayı değiştirmeden, test dosyası içinde `SaveStorage` arayüzünü uygulayan ve yazma işlemini bir `Completer` ile bekleten `_ControllableSaveStorage` sınıfı kullanılarak tamamen deterministik biçimde test edildi.
- **Semantik Ağaç Temizliği**: `SemanticsHandle` sızıntısı yaşanmaması için test blokları `try/finally` ile sarılarak `handle.dispose()` ve `controller.dispose()` çağrıları garantiye alındı.
