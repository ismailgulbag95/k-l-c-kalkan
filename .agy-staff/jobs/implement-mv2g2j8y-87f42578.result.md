Katman analizi ve sanat varlıklarının doğrulanması tamamlanırken arka plan komutunun bitmesi bekleniyor.
Mevcut testlerin çalışması kontrol ediliyor.
## What I changed

- **Hiçbir kod dosyası değiştirilmedi (0 dosya, 0 satır diff).**
  - Görev tanımındaki açık **Quality Gate** şartı gereğince:
    > *"Inspect the actual artwork and the fighter rendering path. Do not ship an arbitrary offset/scale overlay that looks like shop icons pasted onto the fighter. If the provided sprite art cannot be aligned credibly across the battle poses, stop without a hack and report the exact art/rig prerequisite and the smallest viable implementation design."*
  - Varlıklar piksel ve alfa düzeyinde incelenmiş, savaşçı üzerine yerleşim denemesi yapılmış (`test_equipment_overlay.png`) ve mevcut eşya atlasının (`assets/art/items/armor_equipment_atlas.png`) savaş pozları boyunca inandırıcı bir şekilde hizalanamayacağı doğrulanmıştır. Geçici veya görseli bozan bir hile/overlay üretilmeden durulmuş, gerekli önkoşul ve mimari raporlanmıştır.

---

## How I verified it

1. **Görsel Varlıkların İncelenmesi ve Boyut Doğrulaması:**
   - [armor_equipment_atlas.png](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/assets/art/items/armor_equipment_atlas.png): `1448x1086` px, 4 sütun x 3 satır (her hücre `362x362` px).
     - Satır 0 (`head` / miğferler): Tamamen ön cepheden (0° yaw), iç kısımları opak koyu gölgeyle kaplı (alfa değeri 253-255, şeffaf yüz boşluğu yok).
     - Satır 1 (`body` / gövde zırhları): Tamamen ön cepheden düz, simetrik, yeşil kollar/iç tunik zırha yapışık.
     - Satır 2 (`boots` / çizmeler): Tamamen ön cepheden, iki ayak yan yana bitişik duruşta.
     - Bu varlık `assets/art/items/` dizininde yer alan izole mağaza/envanter ikon atlasıdır.
   - [hero_battle_atlas.png](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/assets/art/characters/hero_battle_atlas.png) & [hero_battle_actions.png](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/assets/art/characters/hero_battle_actions.png):
     - Karakter 3/4 dinamik açıda (yaklaşık 45° yaw), bacaklar açık savaş pozunda.
     - Hücumda yatay lunge (bacaklar 120° açık), darbede gövdenin arkaya savrulması, savunmada çömelme, yenilgi pozunda (aksiyon karesi 7) diz çöküp yere iki büklüm kapanma gibi radikal anatomik yer değişimleri içerir.
     - Tüm pozlar tek parça (flattened) çizilmiş tam vücut raster illüstrasyonlarıdır; başlangıç kıyafeti doğrudan piksellerin içine işlenmiştir.
   - [hero_body_layers.png](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/assets/art/characters/hero_body_layers.png) & [hero_head_layers.png](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/assets/art/characters/hero_head_layers.png):
     - `HeroCustomizationPainter` tarafından kullanılan saç ve sakal modelleri, karakterin 3/4 baş yapısına, kulak konumuna ve yüz konturuna göre şeffaf yüz pencereleriyle özel olarak riglenmiştir.

2. **Deneysel Kompozisyon Doğrulaması:**
   - Bir scratch betiği ile `armor_equipment_atlas.png` hücreleri (miğfer 0, zırh 0, çizme 0) karakter modeli üzerine bindirilerek test edilmiş (`test_equipment_overlay.png`):
     - Miğferin içi opak olduğu için kahramanın yüzünü tamamen karartarak yok ettiği,
     - Ön cepheden çizilmiş çizmelerin, karakterin açık duran 3/4 bacaklarının ve dizlerinin üstünde havada asılı kaldığı (karakterin 4 bacaklı gibi göründüğü),
     - Özellikle yenilgi (`defeat`), darbe (`hit`) ve hücum (`attack`) animasyonlarında tek parça statik mağaza ikonlarının karakterin hareketli eklemlerinden tamamen koparak havada asılı kalacağı net şekilde tespit edilmiştir.

3. **Mevcut Proje Sağlık Kontrolü:**
   - Komut: `dart analyze lib/game/ui/design.dart lib/game/ui/screens.dart lib/game/data/content.dart test/widget_test.dart`
     - Sonuç: `0 error` (yalnızca mevcut dokunulmamış dosyalarda 5 adet stil uyarısı).
   - Komut: `flutter test test/widget_test.dart`
     - Sonuç: 17 testin tamamı başarılı (`All tests passed!`).

---

## Notes

### Neden Duruldu (Quality Gate Değerlendirmesi)
- `armor_equipment_atlas.png` varlığı karakter render katmanı için değil, mağaza envanter grid'i için hazırlanmış 12 adet statik eşya illüstrasyonudur.
- Savaşçı görselinin üzerine hardcoded `Transform`/`Positioned` ile yerleştirilecek bir katman, yönergede açıkça yasaklanan *"arbitrary offset/scale overlay that looks like shop icons pasted onto the fighter"* sonucunu doğurmaktadır.
- Karakterin yüzünü kapatmama (Kabul Kriteri 2) ve savaş pozları boyunca (idle, action, hit, guard, defeat) inandırıcı hizalama şartı, mevcut atlas varlıklarıyla teknik ve sanatsal olarak imkansızdır.

### Kesin Sanat ve Rig Önkoşulları (Exact Art/Rig Prerequisites)
1. **3/4 Açılı Katmanlı Ekipman Atlası (Layered Equipment Atlases):**
   - Tıpkı [hero_head_layers.png](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/assets/art/characters/hero_head_layers.png) gibi, karakterin 3/4 açısına ve oranlarına oturan özel katmanlar çizilmelidir:
     - `hero_armor_head_layers.png`: İçi şeffaf boşluklu (yüzü açıkta bırakan) veya yüz maskesi kahramanın göz/burun hizasına oturan 3/4 miğferler.
     - `hero_armor_body_layers.png`: 3/4 göğüs açısına, sağ omuz askısına ve sol omuz pauldronuna göre hizalanmış gövde zırhları.
     - `hero_armor_boots_layers.png`: Bitişik değil; sağ ayak (önde, açılı) ve sol ayak (arkada) için ayrı riglenmiş çizme katmanları.
2. **Animasyon Kareleri Eşlemesi:**
   - Savaş pozları (idle, windup, attack, hit, guard, defeat) için zırhların da poz varyantları çizilmeli ya da [FighterArt](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/design.dart#L1095) içinde özelleştirilmiş kahramanda olduğu gibi prosedürel matris dönüşümlerine dayanan tekil bir katmanlı model standardı benimsenmelidir.

### Uygulanabilir En Küçük Kod Tasarımı (Smallest Viable Implementation Design)
Sanat varlıkları hazır olduğunda izlenecek minimal cerrahi kod yolu:
1. **Eşleme Fonksiyonu:** [content.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/data/content.dart#L998) dosyasındaki mevcut `shopEquipmentAtlasFrame(ShopItem item)` fonksiyonu (`row * 4 + tier - 1`) yeniden kullanılır; yeni model ya da mapping türetilmez.
2. **FighterArt Parametresi:** [FighterArt](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/design.dart#L1095) bileşenine opsiyonel `equippedItems` (veya `equipmentFrames`) parametresi eklenir ve [screens.dart](file:///D:/github/k%C4%B1l%C4%B1c%20kalkan/lib/game/ui/screens.dart#L4740) üzerindeki savaşçı çağrısına `equippedItems: controller.save.equippedItems` aktarılır.
3. **Katmanlama:** `_HeroCustomizationPainter` içine sırasıyla `boots` -> `body` -> `head` çizim adımları eklenerek yüzün ve saçın z-index sırasına uygun şekilde `canvas.drawImageRect` ile tek bir tuvalde (Canvas) birleştirilir. Bu sayede `FighterArt`'ın mevcut `TweenAnimationBuilder` yapısı tüm hareketleri senkronize şekilde zırhla birlikte oynatır.
