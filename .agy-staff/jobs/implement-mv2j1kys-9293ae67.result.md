Test komutu arka planda çalıştırılıyor, tamamlanması bekleniyor...
Testler çalıştırılıyor, sonuçlar gelir gelmez analiz adımına geçeceğim.
## What I changed

- [battle_action_semantics_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/battle_action_semantics_test.dart): `dart format` komutu çalıştırılarak dosya standart Dart biçimlendirmesine uyarlandı.
- [screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart) ve [rival_motion_assets_test.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/test/rival_motion_assets_test.dart): `dart format` tarafından kontrol edildi; her ikisi de halihazırda standart biçimlendirmeye uygun olduğundan değişiklik yapılmadı (0 değişiklik).

---

## How I verified it

1. **`dart format` çalıştırıldı:**
   ```powershell
   dart format lib/game/ui/screens.dart test/battle_action_semantics_test.dart test/rival_motion_assets_test.dart
   ```
   **Çıktı:**
   ```text
   Formatted test/battle_action_semantics_test.dart
   Formatted 3 files (1 changed) in 0.34 seconds.
   ```

2. **Testler topluca çalıştırıldı:**
   ```powershell
   flutter test test/battle_action_semantics_test.dart test/rival_motion_assets_test.dart test/next_rival_motion_assets_test.dart
   ```
   **Çıktı:**
   ```text
   Resolving dependencies...
   Downloading packages...
     code_assets 1.2.1 (2.1.0 available)
     cupertino_icons 1.0.9 (2.0.0 available)
     hooks 2.0.2 (2.2.0 available)
     material_color_utilities 0.13.0 (0.13.1 available)
     meta 1.18.3 (1.19.0 available)
     objective_c 9.5.0 (9.6.2 available)
     record_use 0.6.0 (1.1.1 available)
     test_api 0.7.12 (0.7.15 available)
     vector_math 2.4.0 (2.4.3 available)
   Got dependencies!
   9 packages have newer versions incompatible with dependency constraints.
   Try `flutter pub outdated` for more information.
   00:00 +0: loading D:/github/kılıc kalkan/test/battle_action_semantics_test.dart
   00:00 +0: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: early rivals map to stable dedicated motion atlases
   00:00 +1: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
   00:00 +2: D:/github/kılıc kalkan/test/rival_motion_assets_test.dart: each early rival atlas decodes and paints through FighterArt
   00:02 +3: D:/github/kılıc kalkan/test/battle_action_semantics_test.dart: Battle action tile accessibility semantics exposes single button semantics for usable, badged, and disabled actions in Turkish
   00:02 +4: D:/github/kılıc kalkan/test/battle_action_semantics_test.dart: Battle action tile accessibility semantics exposes single button semantics for usable, badged, and disabled actions in Turkish
   00:03 +5: D:/github/kılıc kalkan/test/battle_action_semantics_test.dart: Battle action tile accessibility semantics exposes single button semantics for usable, badged, and disabled actions in English
   00:03 +6: D:/github/kılıc kalkan/test/battle_action_semantics_test.dart: Battle action tile accessibility semantics verifies primary battle action semantics are traversed in the same order as the action Wrap list
   00:03 +7: D:/github/kılıc kalkan/test/battle_action_semantics_test.dart: Battle action tile accessibility semantics reflects enabled and tap state when onTap is null (processing turn) vs non-null
   00:05 +8: All tests passed!
   ```

3. **`dart analyze` çalıştırıldı:**
   ```powershell
   dart analyze lib/game/ui/screens.dart test/battle_action_semantics_test.dart test/rival_motion_assets_test.dart
   ```
   **Çıktı:**
   ```text
   Analyzing screens.dart, battle_action_semantics_test.dart, rival_motion_assets_test.dart...

      info - lib\game\ui\screens.dart:2731:27 - Statements in an if should be enclosed in a block. Try wrapping the statement in a block. - curly_braces_in_flow_control_structures
      info - lib\game\ui\screens.dart:2847:27 - Statements in an if should be enclosed in a block. Try wrapping the statement in a block. - curly_braces_in_flow_control_structures
      info - lib\game\ui\screens.dart:2946:27 - Statements in an if should be enclosed in a block. Try wrapping the statement in a block. - curly_braces_in_flow_control_structures
      info - lib\game\ui\screens.dart:3986:7 - Statements in an if should be enclosed in a block. Try wrapping the statement in a block. - curly_braces_in_flow_control_structures
      info - lib\game\ui\screens.dart:4497:7 - Statements in an if should be enclosed in a block. Try wrapping the statement in a block. - curly_braces_in_flow_control_structures

   5 issues found.
   ```
   *(Hata veya uyarı bulunmamaktadır; listelenen 5 info tanısı `screens.dart` dosyasının dokunulmamış eski kod bloklarına aittir.)*

---

## Notes

- Yalnızca talep edilen üç dosya üzerinde biçimlendirme ve analiz çalıştırılmıştır.
- Çalışma dizininde `.git` bulunmamaktadır; herhangi bir Git işlemi yapılmamıştır. Oynanış veya semantik davranışlarında herhangi bir değişiklik yapılmamış, kapsam genişletilmemiştir.
