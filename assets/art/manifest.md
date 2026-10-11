# Art asset manifest

All images listed here are original assets generated for the Kül Çemberi project. They are not extracted from or traced over Swords and Sandals. The generated PNG masters remain in `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\`; WebP files in the workspace are the runtime versions. Opaque scene art and other transparent character/atlas art use quality-90 WebP, preserving alpha where present; the 32 rival motion atlases use quality 95 with exact alpha preservation.

## Arenas

| Runtime file | Use | Source file | Brief |
|---|---|---|---|
| `arenas/kul_rihtimi.webp` | First chapter arena | `exec-44631b24-ad46-48eb-9bb0-0a7861958401.png` | Foggy basalt dock, rope rigging, lanterns and salt-worn wood |
| `arenas/kor_ocagi.webp` | Second chapter arena | `exec-55d95338-7ce9-4334-8dfb-5c5056e3869a.png` | Forge amphitheatre, dark slag walls, brass and ember light |
| `arenas/firtina_gozlemevi.webp` | Third chapter arena | `exec-c16a3d96-7b3d-400b-bd5b-369cf8a213bb.png` | Storm observatory, broken measurement rings and copper instruments |
| `arenas/gelgit_amfitiyatrosu.webp` | Third chapter arena | `exec-8f93100a-c68d-426e-97f5-a36150e0d9dc.png` | Tide amphitheatre with water channels and sea-glass mosaics |
| `arenas/tac_kalesi.webp` | Fourth chapter arena | `exec-1c368bd2-8055-4398-a995-a7926fb9c288.png` | Crown fortress, stone buttresses, banners and siege beams |
| `arenas/tac_halkasi.webp` | Final arena | `exec-036f30b2-2817-4fd9-bd45-daa7b2b66ec9.png` | Open-air final ring at sunset with rising spectator tiers |
| `arenas/chapter_heraldry_atlas.png` | Four unique campaign chapter crests for result and chapter UI | `exec-cfacda2d-8bce-4557-b826-9ceb4c3333f3.png` | Transparent RGBA 2×2 heraldry atlas: ember, tide, storm, and crown motifs in chapter order |

## Characters

| Runtime file | Use | Source file | Brief |
|---|---|---|---|
| `characters/hero_kulak.webp` | Player portrait and battle-stage art | `exec-e663517e-aa93-4325-aa38-6c8c4d19ff4b.png` | Original teal-scarfed coastal gladiator in charcoal and brass armor |
| `characters/hero_battle_atlas.png` | Player battle poses | `exec-d4a38097-da3b-48bf-99d0-ced4dbd2039e.png` | Transparent 3×2 pose atlas: idle, attack wind-up, sword slash, hit recoil, guard and victory; cropped row-major |
| `characters/hero_battle_actions.png` | Player action-specific battle poses | `exec-f67517fd-7838-407f-8b64-38ec4d4a6190.png` | Transparent RGBA 4×2 atlas (1774×887); four columns use fractional source bounds and the row crop splits at y=459 through the transparent gap to preserve feet/head silhouettes: strong strike, bow draw, bow release, dodge, consumable, stagger, spell and defeat; row-major cells 0–7 |
| `characters/hero_combat_base_layers.png` | Player appearance and equipped-weapon fallback art | `exec-9300761b-281b-4f79-bb75-ce127ed42c19.png` | Transparent RGBA 1536×1024, 3×1 row-major body atlas; weaponless base with integrated curly hair so weapon silhouettes can be painted per family and separate hair/skin layers cannot float or tint the face |
| `characters/hero_ocak_combat_base_layers.png` | Ocak-origin player appearance | `exec-1fce855d-86bc-417c-bb70-8e0d93e543ca.png` | Transparent RGBA 1536×1024, 3×1 atlas; soot-charcoal armor, restrained copper and ember-red cloth; same three body proportion cells |
| `characters/hero_firtina_combat_base_layers.png` | Fırtına-origin player appearance | `exec-26d8ed02-36f8-4aa1-92e2-977a8aa6ffaf.png` | Transparent RGBA 1536×1024, 3×1 atlas; storm-teal cloth, charcoal layers and pale-silver armor; same three body proportion cells |
| `characters/hero_tac_combat_base_layers.png` | Taç-origin player appearance | `exec-381dfecd-f53d-4853-9e5d-1d58528dbca8.png` | Transparent RGBA 1536×1024, 3×1 atlas; worn ivory cloth, charcoal armor and muted burgundy accents; same three body proportion cells |
| `characters/fener_sampiyonu.webp` | Fener Champion | `exec-82f5bcd7-4d2d-4370-9404-6f192dbd8ff9.png` | Lantern-bearing spear champion with a deep-teal mantle |
| `characters/fener_champion_motion.webp` | Fener Champion battle pose atlas | `exec-650c8231-128e-42d0-9fc0-8218d2c9817e.png` | Transparent 1536×1024 RGBA, 3×2 row-major atlas: idle, spear wind-up, spear thrust, hit recoil, guard, defeat; used by match 8 |
| `characters/pirinc_muhafiz.webp` | Brass Guardian | `exec-a214cf11-bef8-4e42-907a-157bd45dc4c6.png` | Forge champion with a heavy hammer and warm metal palette |
| `characters/brass_guardian_motion.webp` | Brass Guardian battle pose atlas | `exec-e7cf6289-dde2-41f4-880d-23973594314a.png` | Transparent 1536×1024 RGBA, 3×2 row-major atlas: idle, maul wind-up, maul strike, hit recoil, guard, defeat; used by match 16 |
| `characters/gozlemci_basrahip.webp` | Observatory High Priest | `exec-13298b5e-e9b7-4f93-b44d-d55b29cf781f.png` | Storm observatory spellkeeper with ceremonial robes and a staff |
| `characters/observatory_priest_motion.webp` | Observatory High Priest battle pose atlas | `exec-c252458c-e831-4af6-97cb-20390909bf72.png` | Transparent 1536×1024 RGBA, 3×2 row-major atlas: idle, storm charge, spell cast, hit recoil, guard, defeat; used by match 24 |
| `characters/cember_ustasi.webp` | Circle Master, final champion | `exec-910b1614-77a3-4b8e-afd7-c9c5a9f0b399.png` | Veteran arena champion in bone enamel, brass and sea-glass armor; ring-staff |
| `characters/circle_master_motion.webp` | Circle Master battle pose atlas | `exec-ea2d0463-0aac-4697-8429-ebf2b2aa7874.png` | Transparent 1536×1024 RGBA, 3×2 row-major atlas: idle, staff wind-up, staff strike, hit recoil, guard, defeat; registered for match 32 only |
| `characters/ayna_dovuscu.webp` | Mirror Fighter, final Champions Road duel | `exec-848e2530-b4c7-42df-bb07-26b8332bd64f.png` | Original reflection of the coastal gladiator in silvered armor and sea-glass accents; transparent full-body portrait |

Character portraits are 1024×1536 WebP files except `pirinc_muhafiz.webp` (1143×1376). Transparent corners are retained for compositing over arena art. `hero_battle_atlas.png` is 1536×1024 RGBA with six 512×512 row-major cells. Arena dimensions are recorded in the image files; use resolution-aware fitting and avoid stretching.

### Player appearance layers

Active character creation and the appearance editor expose four fixed origin looks and three body proportions. Kıyı uses `hero_combat_base_layers.png`; the other origins use the matching atlas above. Heads, hair and clothing colors are painted into each base image. Separate hair/headwear, facial-hair and palette-color choices are removed from the UI and painter because they produced floating overlays or unnatural color patches. Old `headOptionId`, `skinToneId`, `facialHairId` and accent IDs remain in the save schema for compatibility; the renderer ignores them, and editing the body shape writes their canonical defaults. `HeroWeaponArt` continues to draw the selected weapon family on top of the origin-specific base.

| Runtime file | Dimensions and layout | IDs and mapping | Generated master |
|---|---|---|---|
| `characters/hero_head_layers.png` | 1774×887 RGBA; 4×2 equal transparent cells (443.5×443.5) | Legacy, not used by runtime character UI or painter | `C:\Users\ismai\.codex\generated_images\01a1249b-75c7-7490-977b-0c8360e1f271\exec-14fc6f58-e665-4377-ba09-81d6bb5f0630.png` |
| `characters/hero_body_layers.png` | 1536×1024 RGBA; legacy 3×1 atlas | Historical source, not used at runtime; each cell has a baked sword | `C:\Users\ismai\.codex\generated_images\01a1249b-75c7-7490-977b-0c8360e1f271\exec-102d474f-cc61-4f3b-843f-3a53ed0866de.png` |
| `characters/hero_combat_base_layers.png` | 1536×1024 RGBA; 3×1 equal transparent cells (512×1024) | Left-to-right body proportion IDs `body_01`–`body_03`; natural face/hair included; weapon silhouettes are rendered by `HeroWeaponArt` | `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\exec-9300761b-281b-4f79-bb75-ce127ed42c19.png` |
| `characters/hero_facial_hair_layers.png` | 1536×1024 RGBA; 3×2 equal transparent cells (512×512) | Legacy facial-hair study; not used by runtime character UI or painter | `C:\Users\ismai\.codex\generated_images\01a1249b-75c7-7490-977b-0c8360e1f271\exec-c8d664fa-3f71-494c-99d1-9d444a356809.png` |

Origin atlas masters are listed below; each keeps the same 3×1 body-proportion crop contract as the Kıyı atlas. Atlas previews and combat fallback art select the asset from the saved origin, so the chosen origin remains visible beyond character creation.

| Runtime file | Dimensions and layout | Visual mapping | Generated master |
|---|---|---|---|
| `characters/hero_ocak_combat_base_layers.png` | 1536×1024 RGBA; 3×1 equal transparent cells (512×1024) | `body_01`–`body_03`; Ocak charcoal/copper/ember outfit | `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\exec-1fce855d-86bc-417c-bb70-8e0d93e543ca.png` |
| `characters/hero_firtina_combat_base_layers.png` | 1536×1024 RGBA; 3×1 equal transparent cells (512×1024) | `body_01`–`body_03`; Fırtına teal/silver outfit | `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\exec-26d8ed02-36f8-4aa1-92e2-977a8aa6ffaf.png` |
| `characters/hero_tac_combat_base_layers.png` | 1536×1024 RGBA; 3×1 equal transparent cells (512×1024) | `body_01`–`body_03`; Taç ivory/burgundy outfit | `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\exec-381dfecd-f53d-4853-9e5d-1d58528dbca8.png` |

### Hero combat rig art gate

An original art pass explored replacing the fixed-standing preview layers with a reusable cutout rig. Multiple candidates failed at the 126×156 battle-art size. The round-2 4×4 sheet is 1285×1224 RGBA rather than an integer-cell atlas; all 16 nominal cells touch alpha at crop edges, including both intended blank cells, and the target-size preview shows fragments and clipping. Both new full-figure sheets bake one appearance/gear look and contain no customization layers. **None of the failed candidates is bundled or used at runtime.** The complete existing `hero_battle_atlas.png` and `hero_battle_actions.png` remain the pose sources until replacement art passes fit review. The review packet is kept under `docs/art-review/hero_combat_rig/`.

| File | Layout / source | Status |
|---|---|---|
| `docs/art-review/hero_combat_rig/hero_head_base.png` | 512×512 transparent hairless head/neck, alpha-clean export of `hero_head_base_master.png` | Unaccepted source only; not bundled |
| `docs/art-review/hero_combat_rig/hero_head_skin_mask.png` | 512×512 candidate mask for the standalone head | Tint result not yet reviewed; not bundled |
| `docs/art-review/hero_combat_rig/hero_equipment_layers.png` | 1086×1448 transparent 3×4 atlas, source `hero_equipment_layers_master.png`; columns are helmets, coats, boots; rows are tiers 1–4 | Isolated item art is not pose-fitted; not bundled |
| `docs/art-review/hero_combat_rig/hero_modular_parts_master.png` | 1536×1024 4×4 cutout anatomy experiment | Fit failed; archived source material only |
| `docs/art-review/hero_combat_rig/hero_full_pose_atlas_candidate.png` | 1382×1138 RGBA full-figure concept sheet; intended as a 14-pose review candidate | No dependable frame bounds; not a runtime atlas or customization layer set |
| `docs/art-review/hero_combat_rig/hero_8_pose_full_figure_candidate_round1.png` | 1774×887 RGBA, 4×2 requested action sheet | All eight crops touch cell edges; clipping and single baked appearance; review only |
| `docs/art-review/hero_combat_rig/hero_14_pose_atlas_candidate_round2.png` | 1285×1224 RGBA, 4×4 requested layout; source reference was `hero_battle_atlas.png` | All 16 nominal crops touch cell edges; intended blank cells contain fragments; review only |
| `docs/art-review/hero_combat_rig/hero_14_pose_fit_preview_round2_126x156.png` | Candidate cells previewed at the in-game 126×156 viewport | Shows clipped figures and detached neighboring-cell props; review evidence only |
| `docs/art-review/hero_combat_rig/rig_manifest.json` | Existing 14-pose selector mapping, selection IDs, candidate notes and gate status | No battle pivots, masks, gear sockets, occlusion, or draw placements validated |
| `docs/art-review/hero_combat_rig/fit_audit.md` | Acceptance notes and exact remaining art coverage | Correction pass remains blocked; target-size samples and new candidate reviewed |

## Equipment and spell icons

| Runtime file | Use | Source file | Brief |
|---|---|---|---|
| `items/item_icons.png` | Tier-1 shop weapons, armor, talisman, spells and belt supplies | `exec-51e76b57-b6a2-4782-9c48-9805b522f30c.png` | Transparent RGBA 1254×1254 atlas. Source rectangles are recorded in `design.dart` to crop 16 isolated silhouettes: sword, maul, spear, bow, helmet, cuirass, boots, talisman, six spell icons, salve and tonic. Tiers 2–4 use the separate `tiered_item_icons.png` atlas documented below. |

Tier-specific equipment variants are a separate original transparent atlas. Its PNG master remains at `C:\Users\ismai\.codex\generated_images\01a12457-66d5-70f3-8d6d-dc95f3690194\exec-6a23ca6e-e195-478a-b716-a0c4fb3262d9.png`; the runtime copy is `items/tiered_item_icons.png` (1536×1024 RGBA, 6 columns × 4 rows, 256×256 cells, row-major). Cell IDs are: 0 `sword_2`, 1 `maul_2`, 2 `spear_2`, 3 `bow_2`, 4 `helm_2`, 5 `coat_2`, 6 `boots_2`, 7 `charm_2`; 8 `sword_3`, 9 `maul_3`, 10 `spear_3`, 11 `bow_3`, 12 `helm_3`, 13 `coat_3`, 14 `boots_3`, 15 `charm_3`; 16 `sword_4`, 17 `maul_4`, 18 `spear_4`, 19 `bow_4`, 20 `helm_4`, 21 `coat_4`, 22 `boots_4`, 23 `charm_4`. The tier-1 variants and spell/supply icons continue to use `item_icons.png`.

## Rival atlases

The four campaign rival sheets are original 1536×1024 WebP atlases laid out as four columns by two rows. Runtime crops row-major cells 0–6 for the seven ordinary encounters in each act; cell 7 is a reserve. The act champion keeps its dedicated portrait above. Atlas backgrounds have partial transparency that varies by sheet; preserve the WebP alpha channel. Champions Road uses its separate 1536×1024 RGB PNG atlas for seven unique rematch portraits; its eighth generated portrait is reserved. Crops are fitted into the portrait frame without stretching.

| Runtime file | Source file | Encounter IDs | Cell mapping |
|---|---|---|---|
| `rivals/devre1_atlas.webp` | `exec-786fbe07-1555-41a0-839d-449a24e49213.png` | 1–7 | ID 1→0 through ID 7→6; ID 8 uses Fener champion portrait |
| `rivals/devre2_atlas.webp` | `exec-01b9455d-5022-4822-8d1f-f90c2b3d5a7f.png` | 9–15 | ID 9→0 through ID 15→6; ID 16 uses Brass Guardian portrait |
| `rivals/devre3_atlas.webp` | `exec-d8a09a65-1f71-4d08-aaac-066da05da39c.png` | 17–23 | ID 17→0 through ID 23→6; ID 24 uses Observatory High Priest portrait |
| `rivals/devre4_atlas.webp` | `exec-369c0770-801d-4593-93a1-581c32a9889e.png` | 25–31 | ID 25→0 through ID 31→6; ID 32 uses Circle Master portrait |
| `rivals/champions_road_atlas.png` | `exec-e4919a88-bc70-4f4d-a00b-087ec6f2d825.png` | 33–39 | 1536×1024 RGB, 4×2; postgame stages 1–7 use cells 0–6; cell 7 is reserved |

All 32 campaign opponents now resolve to either one of the seven act-specific atlas cells or a dedicated champion portrait. Contracts that reuse campaign IDs inherit the same art mapping. Preview and battle use the same source selection.

Champions Road encounters 33–39 use the dedicated postgame atlas in stage order, cells 0–6. Its eight original rivals are painted as full-body dark-fantasy portraits against charcoal panels; cell 7 remains reserved for a future challenge or gallery use. Encounter 40 uses the dedicated `characters/ayna_dovuscu.webp` portrait and its dynamic player-build combat data. The atlas follows the existing 4×2 crop contract and is decoded and painted by asset/widget tests.

## Fonts

| Runtime file | Use | License | Notes |
|---|---|---|---|
| `../fonts/NotoSans-Variable.ttf` | Main application typography | SIL Open Font License 1.1 (`assets/fonts/OFL-NotoSans.txt`) | Variable Noto Sans font, bundled locally for consistent offline rendering |

## Contract card illustrations

All 16 contract illustrations are square 1254×1254 RGBA WebP runtime exports. The original PNG masters remain unchanged in `generated_images`.

| Contract ID | Runtime file | Source file |
|---|---|---|
| `C1-A` | `contracts/c1_a_clean_duel.webp` | `exec-a429c620-2de2-415c-b1a0-9bd6dccf25b3.png` |
| `C1-B` | `contracts/c1_b_short_sword_mastery.webp` | `exec-a258c312-9a11-4c50-b15c-ea6625445fba.png` |
| `C1-C` | `contracts/c1_c_defense_trial.webp` | `exec-b0dae0d7-21f4-40cd-b0a7-2adbcf07db16.png` |
| `C1-D` | `contracts/c1_d_lighthouse_shadow.webp` | `exec-8474621c-d3b3-4252-a0a7-c3fde3c2ab22.png` |
| `C2-A` | `contracts/c2_a_ash_control.webp` | `exec-66c82114-ce22-46f2-9cd8-39932be0b614.png` |
| `C2-B` | `contracts/c2_b_armor_breaker.webp` | `exec-9ce16bd4-50e2-4bf6-80f9-6c7776b8944a.png` |
| `C2-C` | `contracts/c2_c_heat_management.webp` | `exec-332f5861-ed0b-44da-a6cc-e7a132511a8d.png` |
| `C2-D` | `contracts/c2_d_matrons_seals.webp` | `exec-2bb92d8b-9596-4643-b127-789beb71f0b3.png` |
| `C3-A` | `contracts/c3_a_range_mastery.webp` | `exec-4cdb431d-6c1b-4dd0-be20-1127034244d9.png` |
| `C3-B` | `contracts/c3_b_seal_breaker.webp` | `exec-5123744b-6691-49d9-bed5-d6a727776d20.png` |
| `C3-C` | `contracts/c3_c_unbroken_tempo.webp` | `exec-354ca1bb-857a-4952-aec7-532a8edc8368.png` |
| `C3-D` | `contracts/c3_d_judges_opening.webp` | `exec-fedc1902-24f3-48b2-b383-fc6110ddd226.png` |
| `C4-A` | `contracts/c4_a_last_preparation.webp` | `exec-16e91994-48ac-4853-9ea4-c5f05f4febc3.png` |
| `C4-B` | `contracts/c4_b_commanders_opening.webp` | `exec-010592d2-ba8b-4f92-9663-854eafcf41bc.png` |
| `C4-C` | `contracts/c4_c_champions_oath.webp` | `exec-a1753621-79b1-41fb-9c5b-fa1d35285a14.png` |
| `C4-D` | `contracts/c4_d_break_the_seal.webp` | `exec-13bdd680-1156-495f-929e-7b5cc4411955.png` |

## Intermission event illustrations

These four landscape illustrations are original scene art for the one-time choice after each chapter's first tournament final. Each is shown in the resumable campaign card and the choice dialog; the source PNG masters remain in `generated_images`.

| Decision ID | Runtime file | Source file | Scene |
|---|---|---|---|
| `I04` | `intermissions/i04_training_offer.webp` | `exec-c4e4804b-4dc0-4b57-aca7-fea27be39e6a.png` | Coach offers training beside the salt-worn harbor arena |
| `I12` | `intermissions/i12_forge_choice.webp` | `exec-34532b3c-d981-45d3-93db-dd12784c5184.png` | Smith-coach offers a lesson in the ember forge |
| `I20` | `intermissions/i20_storm_strategy.webp` | `exec-c587f4c2-892e-4992-bf3f-ffa0a87462ae.png` | Tactical preparation and patron in the storm observatory |
| `I28` | `intermissions/i28_crown_preparation.webp` | `exec-8f7474a0-7985-48f8-b695-754806231cf6.png` | Trainer and sponsor meet at the crown fortress |

## Story-trace evidence cards

Four original text-free evidence illustrations share one transparent 2×2 atlas. Each 627×627 cell is cropped from the same 1254×1254 RGBA image, with no lettering baked into the art so Turkish and English narrative copy stays accessible and localizable.

| Evidence ID | Trigger | Atlas cell | Visual evidence |
|---|---|---|---|
| `E04` | After encounter 4 | 0, top-left | Ash-stained prize ledger with a mismatched seal/count |
| `E12` | After encounter 12 | 1, top-right | Independent results register and dispatch token confirming the mismatch |
| `E20` | After encounter 20 | 2, bottom-left | Three tournament folios bearing the same altered mark |
| `E28` | After encounter 28 | 3, bottom-right | Public evidence board connecting the records |

| Runtime file | Source file | Use |
|---|---|---|
| `evidence/evidence_card_atlas.png` | `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\exec-8a4edccc-5afe-4c48-871b-780cf2158fd2.png` | Cropped by `StoryEvidenceCardArt`; source survives unchanged in the generated-images folder |

## Combat effects

The runtime effect atlas is a transparent 1774×887 RGBA sheet with four columns and two rows of square 443.5 px cells. It is decoded once and cropped by source rectangles in `design.dart`; battle events select the impact, dust, block, arrow, healing, wind, fire, or tide frame. The corrected generated master is retained unchanged in `generated_images`.

| Runtime file | Use | Source file | Brief |
|---|---|---|---|
| `effects/combat_effects_atlas.png` | Combat hit, movement, guard, ranged, healing, and elemental spell feedback | `exec-01af4e14-6428-4c0e-b33a-191568bc0bc6.png` | Transparent 4×2 atlas: metallic impact, ash dust, teal-gold shield arc, arrow trail, healing motes, wind ribbon, ember flare, tide splash |
| `effects/metal_impact_spark.png` | Legacy standalone impact art retained for reference and asset compatibility | `exec-293a6fc7-4c93-430b-972b-ace925032e1c.png` | Compact transparent gold-white metallic impact with sea-glass shards and charcoal flecks |

## App icon and launch artwork

The selected identity is concept A, **Kül Halkası**, from `branding/concepts/ash_ring.svg`. Its final vector master is `branding/kul_halkasi_master.svg`; the ring, opening, and four-point ember retain the approved concept geometry. The mark contains no text, font, raster, or third-party artwork. Platform compositions are direct color/scale treatments of that master.

| Source or runtime file | Use | Treatment |
|---|---|---|
| `branding/kul_halkasi_master.svg` | Canonical mark | One-color charcoal `#17191B`, 256×256 viewBox |
| `branding/exports/kul_halkasi-black.svg`, `kul_halkasi-white.svg`, `kul_halkasi-mono-d6ad68.svg` | Brand mark variants and 16/32/64/256/1024 px PNG proofs | Black, reversed white, and game-palette gold `#D6AD68` |
| `branding/exports/kul_halkasi_app_icon.svg` | Opaque square icon composition master | `#D6AD68` mark on `#101719`, 76% mark scale; used to render the iOS and legacy Android tiles |
| `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` | Legacy Android launcher sizes | Opaque 48/72/96/144/192 px tiles |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` and `drawable-nodpi/ic_launcher_{foreground,monochrome}.png` | Android adaptive and themed icon | Gold and white foregrounds, 432×432 px; mark occupies 58% of the canvas and fits the adaptive safe circle |
| `android/app/src/main/res/drawable{,-v21}/launch_background.xml`, `drawable-nodpi/launch_logo.png` | Android pre-12 and bitmap launch screen | Ink background with the centered gold mark; API 31+ launch theme also references the same launch symbol |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | iPhone, iPad, and marketing AppIcon mappings | All 15 distinct files referenced by `Contents.json` generated from the opaque 1024×1024 icon master; no pre-rounded corners or transparency |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage{,@2x,@3x}.png` | Existing centered iOS launch image set | 1366×1024, 2732×2048, and 4098×3072 px; dark radial field and centered gold mark, sized for standard iPad landscape while keeping the mark centered on phone crops |
| `branding/exports/kul_halkasi_ios_launch.svg` | iOS launch artwork source | Vector source for the three opaque launch PNG scales |

The launch background and mark use existing game UI colors from `GamePalette`: ink `#101719` and gold `#D6AD68`. Gold on ink measures 8.66:1 contrast. The black, white, and gold marks were checked at 16/32 px, in grayscale, reversed, mirrored, and rotated using the logo-design preview sheet. `svg_audit.py` reported no issues for the master and gold one-color variant (100/100 heuristic score each). Android resource XML and iOS asset mappings were checked for parseability, referenced files, alpha behavior, safe-area bounds, and declared dimensions. No Flutter/Gradle/Xcode build or device launch was run in this asset task.

## Arena foreground prop and lighting variant atlases

These original atlases add optional, compact foreground prop clusters to the six existing arena identities. The existing arena backgrounds remain unchanged. These are prop-cluster variants with localized prop lighting, not separate full-scene lighting or atmosphere overlays. Each generated master uses its corresponding arena image as a palette/material reference only; the atlas itself contains no arena background, fighters, text, or UI. Prompts specify four distinct isolated corner-prop clusters per arena, restrained light local to the prop, generous transparent space, and the same painterly dark-fantasy game-art direction. All masters were generated with the built-in ImageGen tool and retained unchanged in the generated-images folder. Each runtime PNG is a byte-for-byte copy of its master.

All six atlases are 1536×1024 RGBA PNGs arranged as equal 2×2 cells, row-major, with 768×512 (3:2) cells. Crop rectangles use integer bounds with exclusive right/bottom edges: cell 0 `(0, 0, 768, 512)`, cell 1 `(768, 0, 1536, 512)`, cell 2 `(0, 512, 768, 1024)`, and cell 3 `(768, 512, 1536, 1024)`. Preserve alpha and aspect ratio when cropping and rendering. The cells are small prop-sprite alternatives, not full-screen overlays; the battle stage renders two encounter-selected cells along the lower outer corners behind fighter art. `ArenaInfo.propAtlas` maps each arena to its atlas, and `ArenaPropSprite` crops the selected 2×2 cell at runtime.

| Arena ID | Runtime atlas | Generated source master | Cell mapping (row-major 0–3) | Runtime file size |
|---|---|---|---|---:|
| `kul` | `arenas/kul_rihtimi_prop_variants.png` | `C:\Users\ismai\.codex\generated_images\01a125ac-7d25-7b93-b4d7-5dc4e90ec98d\exec-faf1b02f-9ec2-4017-a124-cde94e9036f8.png` | 0 lantern post; 1 rope-wrapped mooring bollard; 2 dock crate and sea-glass buoy; 3 teal pennant and small brazier | 1,578,169 bytes |
| `kor` | `arenas/kor_ocagi_prop_variants.png` | `C:\Users\ismai\.codex\generated_images\01a125ac-7d25-7b93-b4d7-5dc4e90ec98d\exec-4503a3e6-413d-4463-8364-4eda9dbb1679.png` | 0 iron slag brazier; 1 anvil and brass hammer; 2 chain coil and iron hook; 3 low ember vent grate | 1,542,436 bytes |
| `firtina` | `arenas/firtina_gozlemevi_prop_variants.png` | `C:\Users\ismai\.codex\generated_images\01a125ac-7d25-7b93-b4d7-5dc4e90ec98d\exec-6be78e04-597f-4824-b049-b068eeae2af2.png` | 0 brass armillary on slate base; 1 brass telescope on tripod; 2 contained storm-glass orb; 3 copper weather vane | 1,712,739 bytes |
| `gelgit` | `arenas/gelgit_amfitiyatrosu_prop_variants.png` | `C:\Users\ismai\.codex\generated_images\01a125ac-7d25-7b93-b4d7-5dc4e90ec98d\exec-3bdf66f2-17be-4152-b522-ed9680d1aa89.png` | 0 shell basin with turquoise water; 1 coral and sea-glass cluster; 2 carved fountain spout; 3 pearl-shell lantern on mosaic base | 1,650,570 bytes |
| `tac` | `arenas/tac_kalesi_prop_variants.png` | `C:\Users\ismai\.codex\generated_images\01a125ac-7d25-7b93-b4d7-5dc4e90ec98d\exec-4fd835e8-aa58-4f24-a25b-3031a034c757.png` | 0 iron torch bracket; 1 battered shield on cracked plinth; 2 iron-bound chest with burgundy cloth; 3 chain and broken timber peg | 1,523,782 bytes |
| `halka` | `arenas/tac_halkasi_prop_variants.png` | `C:\Users\ismai\.codex\generated_images\01a125ac-7d25-7b93-b4d7-5dc4e90ec98d\exec-9630f28b-84b2-41dd-b599-06044b61cf1b.png` | 0 bronze laurel on charcoal plinth; 1 brass victory cup; 2 burgundy-and-teal streamer; 3 paired ceremonial braziers | 1,752,314 bytes |

## Equipment tier display atlas

`items/armor_equipment_atlas.png` is a transparent 1448×1086 RGBA atlas with a 4-column by 3-row square-cell layout (362×362 per cell). Columns map item tiers 1–4; rows map head, body, and boots. The shop and owned-gear cards use these crops for matching equipment, while weapon, bow, and talisman entries keep using the catalog icon atlas. The generated master was corrected to remove a simulated checkerboard and verified to contain a full alpha channel before copying into the runtime asset directory.

| Runtime asset | Generated source master | Cell map | Size |
|---|---|---|---:|
| `items/armor_equipment_atlas.png` | `C:\Users\ismai\.codex\generated_images\01a1227a-fd13-7050-9974-c98c71a09e82\exec-1e95c105-a40b-4948-a7a8-d7f5b493fdf0.png` | row 0 head; row 1 body armor; row 2 boots; columns 0–3 tiers 1–4 | 2,178,819 bytes |

## Early rival motion atlases

Four original transparent PNG masters were generated with the built-in ImageGen tool. They use the existing battle painter's exact 1536×1024, 3×2 row-major contract: idle, wind-up, attack/cast, hit recoil, guard, defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged; no existing portrait or champion atlas was replaced.  `rivalMotionAtlasAssetForEncounter` in `lib/game/ui/rival_motion_assets.dart` registers the stable encounter-ID mapping, and the battle-stage `FighterArt` selects these sheets for encounters 1–4. Across all 32 atlases, the quality-95 lossy WebPs total 17,139,516 bytes, down from 78,412,549 bytes for the former PNG runtime copies; a pixel-exact lossless WebP set measured 53,725,112 bytes. The selected exports retain the alpha channel exactly.

| Encounter | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 1 — İskele Kabadayısı | `characters/iskele_kabadayisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a125ea-b125-7f93-9184-ca34895dafff\exec-e3064b00-89e1-4790-80a4-d634ebc63cfb.png` | Broad salt-dock bruiser with an iron-headed maul | 1536×1024 RGBA; 500,888 bytes |
| 2 — Halat Koşucusu | `characters/halat_kosucusu_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a125ea-b125-7f93-9184-ca34895dafff\exec-94ffe7cf-f435-4e3f-b865-c01d329de840.png` | Agile rope-runner with a curved short sword | 1536×1024 RGBA; 409,120 bytes |
| 3 — Kapı Bekçisi | `characters/kapi_bekcisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a125ea-b125-7f93-9184-ca34895dafff\exec-89c0d0fc-c798-4165-9063-1bf0a50bc52a.png` | Armored gate guard with a tall shield and mace | 1536×1024 RGBA; 471,038 bytes |
| 4 — Tuz Kahini | `characters/tuz_kahini_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a125ea-b125-7f93-9184-ca34895dafff\exec-4a5428dd-4d8d-43b5-8f94-a26636b7cda0.png` | Salt-seer with a crystal-tipped spear | 1536×1024 RGBA; 553,698 bytes |

## Next rival motion atlases

Four original transparent PNG masters extend the same 1536×1024, 3×2 row-major fighter-pose contract. Cells are idle, wind-up, attack/cast, hit recoil, guard, and defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged; stable encounter IDs are registered in `lib/game/ui/rival_motion_assets.dart` and the existing battle-stage `FighterArt` wiring picks them up.

| Encounter | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 5 — Halatçı Sefa | `characters/halatci_sefa_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12621-916d-7e73-89aa-a735c034ae3f\exec-b392f71a-d18d-4cad-84e7-7cb90eb63bab.png` | Teal-clad harbor archer with a recurved bow | 1536×1024 RGBA; 438,738 bytes |
| 6 — Paslı Kanca | `characters/pasli_kanca_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12621-916d-7e73-89aa-a735c034ae3f\exec-4d8d48c2-bcfe-4002-94c4-83cc83f97734.png` | Rust-red harbor counterattacker with a curved short sword and parrying hook | 1536×1024 RGBA; 482,212 bytes |
| 7 — Fener Bekçisi | `characters/fener_bekcisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12621-916d-7e73-89aa-a735c034ae3f\exec-da92f7a9-a62f-4064-91e5-71fc372d9ca9.png` | Hooded lantern keeper with an iron maul | 1536×1024 RGBA; 517,208 bytes |
| 9 — Cüruf Taşıyıcı | `characters/curuf_tasiyici_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12621-916d-7e73-89aa-a735c034ae3f\exec-98f48d4d-71e0-45db-be8c-e36697960045.png` | Forge hauler with a heavy slag maul | 1536×1024 RGBA; 465,728 bytes |

## Rival motion atlases, encounters 10–13

Four original transparent PNG masters extend the same 1536×1024, 3×2 row-major fighter-pose contract. Each sheet contains six 512×512 cells: idle, wind-up, attack/cast, hit recoil, guard, and defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged; stable encounter IDs are registered in `lib/game/ui/rival_motion_assets.dart` and rendered through the existing `FighterArt` path.

| Encounter | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 10 — Zincirci | `characters/zincirci_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126bc-225a-7cc0-b23d-5109dca1c5f4\exec-b76f3036-52e2-4446-9409-969e757b1e5b.png` | Chain-fettered status fighter with a hooked iron spear | 1536×1024 RGBA; 473,106 bytes |
| 11 — Örs Muhafızı | `characters/ors_muhafizi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126bc-225a-7cc0-b23d-5109dca1c5f4\exec-775ac448-00db-4b36-a30d-fd4d39fe5edd.png` | Fully armored maul fighter with a blocky anvil-shaped head | 1536×1024 RGBA; 511,268 bytes |
| 12 — Sözleşmeli Düellocu | `characters/sozlesmeli_duellocu_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126bc-225a-7cc0-b23d-5109dca1c5f4\exec-3843e1e4-05b3-40b6-ad9b-b6e0381daf1d.png` | Bronze-and-charcoal sword-and-buckler duelist with teal contract sash | 1536×1024 RGBA; 463,072 bytes |
| 13 — Köz Gölgesi | `characters/koz_golgesi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126bc-225a-7cc0-b23d-5109dca1c5f4\exec-168b0980-4e75-4af7-b735-92007d505b06.png` | Hooded counterattacker with a narrow curved parrying blade | 1536×1024 RGBA; 457,770 bytes |

## Rival motion atlases, encounters 14–18

Four original transparent PNG masters extend the same 1536×1024 RGBA, 3×2 row-major fighter-pose contract. The six 512×512 cells are idle, wind-up, attack/cast, hit recoil, guard, and defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged. `lib/game/ui/rival_motion_assets.dart` registers the runtime atlases by stable encounter ID.

| Encounter → runtime mapping | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 14 → `characters/kizil_ocak_sefi_motion.webp` | `characters/kizil_ocak_sefi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126ef-bb57-7d41-89b8-d8d9308ec132\exec-d714927c-7e35-42e4-b75d-03d90d6fe5d8.png` | Kızıl Ocak Şefi; soot-armored area-control boss with a heavy iron maul | 1536×1024 RGBA; 688,872 bytes |
| 15 → `characters/kukurt_matronu_motion.webp` | `characters/kukurt_matronu_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126ef-bb57-7d41-89b8-d8d9308ec132\exec-7ca26c18-7e95-48f9-8930-380714147460.png` | Kükürt Matronu; sulfur oracle and spear mage with a spectral phase-two aura | 1536×1024 RGBA; 714,456 bytes |
| 17 → `characters/menzil_avcisi_motion.webp` | `characters/menzil_avcisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126ef-bb57-7d41-89b8-d8d9308ec132\exec-f9f9e0fd-ea7e-4b50-80f6-d74a87ca63a3.png` | Menzil Avcısı; hooded reach fighter with a long steel spear | 1536×1024 RGBA; 428,640 bytes |
| 18 → `characters/ayna_kilic_motion.webp` | `characters/ayna_kilic_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a126ef-bb57-7d41-89b8-d8d9308ec132\exec-b2f0f448-d74c-4f19-ad6b-2d2c01b46267.png` | Ayna Kılıç; silvered counter-duelist with a short sword and parrying dagger | 1536×1024 RGBA; 605,210 bytes |

## Rival motion atlases, encounters 19–22

These four original, transparent masters continue the 1536×1024 RGBA, 3×2 atlas contract. The six 512×512 cells are row-major: idle, wind-up, attack/cast, hit recoil, guard, and defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged; stable encounter IDs are registered in `lib/game/ui/rival_motion_assets.dart`.

| Encounter → runtime mapping | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 19 → `characters/gelgit_muhurcusu_motion.webp` | `characters/gelgit_muhurcusu_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12715-4bc9-7830-a0bb-1a898a2a80a1\exec-45c9304f-b783-4874-8a95-8dbea0cb651c.png` | Gelgit Mührücüsü; slate-and-teal tide caster with a crystal-tipped spear-staff and compact sigil effects | 1536×1024 RGBA; 526,456 bytes |
| 20 → `characters/firtina_avcisi_motion.webp` | `characters/firtina_avcisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12715-4bc9-7830-a0bb-1a898a2a80a1\exec-38f15028-c64b-46d9-b94b-5e07ed1c5ae3.png` | Fırtına Avcısı; charcoal-armored storm boss with a forked spear and phase-two lightning | 1536×1024 RGBA; 460,340 bytes |
| 21 → `characters/ruzgar_seyircisi_motion.webp` | `characters/ruzgar_seyircisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12715-4bc9-7830-a0bb-1a898a2a80a1\exec-8653c2b2-32b5-42de-ad22-b005916e2c2a.png` | Rüzgâr Seyircisi; agile hooded wind duelist with one curved short sword | 1536×1024 RGBA; 419,846 bytes |
| 22 → `characters/kiyi_orakcisi_motion.webp` | `characters/kiyi_orakcisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12715-4bc9-7830-a0bb-1a898a2a80a1\exec-bb0e8a73-b4bc-4e19-a9b3-c5272591dcf0.png` | Kıyı Orakçısı; elite masked coastal champion with shell seals and a hooked spear-polearm | 1536×1024 RGBA; 525,478 bytes |

## Rival motion atlases, encounters 23 and 25–27

Four original transparent PNG masters extend the 1536×1024 RGBA, 3×2 row-major contract. Each 512×512 cell shows the same full-body rival in this pose order: idle, wind-up, attack/cast, hit recoil, guard, defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged. `lib/game/ui/rival_motion_assets.dart` registers each atlas under its encounter ID. Encounter 24 retains its dedicated Observatory High Priest champion portrait.

| Encounter → runtime mapping | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 23 → `characters/gelgit_yargici_motion.webp` | `characters/gelgit_yargici_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a1273d-c1e9-7850-b927-7b9662d220c3\exec-07c45991-b294-48e9-a75f-ded31de449ae.png` | Gelgit Yargıcı; armored tidal judge with a crystal spear-scepter and a clearly awakened phase-two tide aura | 1536×1024 RGBA; 694,210 bytes |
| 25 → `characters/tac_muhafizi_motion.webp` | `characters/tac_muhafizi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a1273d-c1e9-7850-b927-7b9662d220c3\exec-8262a8d5-df4a-4e1f-a28c-45bb4d2051cf.png` | Taç Muhafızı; crown-crested armored sentinel with a broad shield and heavy iron maul | 1536×1024 RGBA; 503,198 bytes |
| 26 → `characters/golge_duellocu_motion.webp` | `characters/golge_duellocu_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a1273d-c1e9-7850-b927-7b9662d220c3\exec-be615e90-9910-4728-98db-a7f70dff90ad.png` | Gölge Düellocu; agile hooded shadow fighter with a short sword and parrying dagger | 1536×1024 RGBA; 511,684 bytes |
| 27 → `characters/sancak_cadisi_motion.webp` | `characters/sancak_cadisi_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a1273d-c1e9-7850-b927-7b9662d220c3\exec-24c0e17c-dd3d-45d6-baef-23b541d67fd3.png` | Sancak Cadısı; arcana-heavy spear mage with a torn burgundy pennant and teal banner-sigil magic | 1536×1024 RGBA; 687,176 bytes |

## Rival motion atlases, encounters 28–31

Four original transparent masters extend the shared 1536×1024 RGBA, 3×2 row-major contract. Each 512×512 cell contains one full-body pose in this order: idle, wind-up, attack, hit recoil, guard, defeat. Runtime atlases are quality-95 lossy WebP exports with exact alpha preservation; source PNG masters remain unchanged. `lib/game/ui/rival_motion_assets.dart` registers them by stable encounter ID. Encounter 24 keeps the Observatory High Priest atlas, and encounter 32 keeps the Circle Master champion atlas.

| Encounter → runtime mapping | Runtime atlas | Generated source master | Character/weapon | Runtime size |
|---|---|---|---|---:|
| 28 → `characters/demir_cellat_motion.webp` | `characters/demir_cellat_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12757-0103-74f0-9a25-9f6dfd5c5562\exec-8698792c-9559-47a7-89a9-dd41b1ab5d4e.png` | Demir Cellat; broad iron executioner with a rust-red tabard and oversized two-handed cleaver | 1536×1024 RGBA; 486,886 bytes |
| 29 → `characters/tahtsiz_varis_motion.webp` | `characters/tahtsiz_varis_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12757-0103-74f0-9a25-9f6dfd5c5562\exec-26360c8c-ceab-41bb-96e1-bf1c09cdd0a0.png` | Tahtsız Varis; lean displaced heir duelist in worn teal court cloth with a slender curved sword | 1536×1024 RGBA; 499,968 bytes |
| 30 → `characters/kul_komutani_motion.webp` | `characters/kul_komutani_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12757-0103-74f0-9a25-9f6dfd5c5562\exec-8b3e9587-8d4c-4278-8dd9-9467748ce9e0.png` | Kül Komutanı; soot-armored officer with burgundy command pennon and a long poleaxe | 1536×1024 RGBA; 425,752 bytes |
| 31 → `characters/muhur_kirici_motion.webp` | `characters/muhur_kirici_motion.webp` | `C:\Users\ismai\.codex\generated_images\01a12757-0103-74f0-9a25-9f6dfd5c5562\exec-68339330-49d6-4018-8838-656bb0137065.png` | Mühür Kırıcı; compact slate-armored breaker with a broad ring-faced breach hammer | 1536×1024 RGBA; 519,750 bytes |
