# Hero combat rig art fit audit

## Gate result

**Blocked. No candidate is approved for battle integration.** The review target is the game's 126×156 player sprite viewport. The new candidates are full-figure concept sheets: neither has renderable customization/equipment layers, validated masks, per-pose anchors, or clean crop boundaries. No runtime asset was staged.

The fit previews use the battle painter's bottom-centered square presentation: each source pose is drawn into a 126×126 square at the bottom of the 126×156 viewport. Red frames mark source crops whose nontransparent alpha touches a cell edge.

## Round 2: 14-pose 4×4 candidate

- Candidate: [hero_14_pose_atlas_candidate_round2.png](hero_14_pose_atlas_candidate_round2.png)
- Target-size diagnostic: [hero_14_pose_fit_preview_round2_126x156.png](hero_14_pose_fit_preview_round2_126x156.png)
- Source: 1285×1224 RGBA. Equal-fraction 4×4 cells would be 321.25×306 px. The diagnostic's rounded x edges are 0, 321, 642, 964, 1285; row edges are 0, 306, 612, 918, 1224.
- Alpha bounds: [0, 0, 1284, 1224]. All 16 diagnostic cells contain nontransparent alpha, and all 16 have alpha on at least one cell edge. The two nominally blank cells 14 and 15 contain visible fragments.
- At 126×156, crops show detached boot/weapon/armor fragments along the top of neighboring cells and figures or props touching crop boundaries. The outer atlas also has alpha on its top and bottom edges. The candidate is not crop-safe; fixed 4×4 sampling mixes or clips content.
- This sheet is 4×4 at 1285×1224, while the accepted action atlas contract is 1774×887 with four 443.5 px columns and a y=459 row split. It does not fit the current action-atlas crop contract.
- It bakes one head, skin tone, body build, clothing and weapon look into each figure. It contains no independent art or masks for customization, gear or weapon swaps.

## Round 1: 8-action full-figure candidate

- Candidate: [hero_8_pose_full_figure_candidate_round1.png](hero_8_pose_full_figure_candidate_round1.png)
- Target-size diagnostic: [hero_8_pose_full_figure_preview_round1_126x156.png](hero_8_pose_full_figure_preview_round1_126x156.png)
- Source is 1774×887 RGBA and uses the accepted action atlas dimensions. Sampling with the accepted y=459 split yields eight cells; all eight contain nontransparent pixels on one or more cell edges.
- The 126×156 preview shows props/limbs cut at crop edges and stray pieces in adjacent row crops. The candidate therefore fails the no-clipping/no-cross-cell-bleed requirement even though its canvas dimensions match.
- The requested unarmored base was not produced: the output is still a complete figure with hair, face, tunic, belt, wraps, skirt, weapons and potion baked together. It has no exposed-skin mask, alternate proportion art, equipment layer, pose socket or occlusion mask. Keep it as review-only concept art.

## Earlier review candidates

- [hero_full_pose_atlas_candidate.png](hero_full_pose_atlas_candidate.png) has no stable 4×4 source cells. Weapons and effects cross implied cell bounds; it is not an atlas.
- [hero_pose_fit_preview.png](hero_pose_fit_preview.png) and [preview_idle_4x.png](preview_idle_4x.png) show the earlier modular anatomy experiment at target size. Visible elbow/wrist, pelvis/thigh and shin/boot seams remain; the tier-4 overlay has floating and doubled contours.
- [hero_equipment_layers_master.png](hero_equipment_layers_master.png) contains standalone gear only. [hero_head_base_master.png](hero_head_base_master.png), [hero_head_base.png](hero_head_base.png), and [hero_head_skin_mask.png](hero_head_skin_mask.png) are standalone head material only. [hero_modular_parts_master.png](hero_modular_parts_master.png) contains combined/asymmetric parts without stable shared pivots. None fit the battle poses as-is.

## Required source art and socket data for the 8 action poses

Every layer sheet and mask must use the accepted action atlas frame contract: 1774×887 source pixels, four columns of 443.5 px, top row y=0..459, bottom row y=459..887, with the same eight pose assignments. Alpha must remain inside each pose crop with transparent filtering margin. The game presents each crop bottom-centered in a 126×126 square inside the 126×156 viewport.

| Frame | Pose | Pose-specific source art / sockets still needed |
|---:|---|---|
| 0 | `strongAttack` | Skin-safe body base; main-hand weapon grip, off-hand/weapon occlusion and blade front/back split. |
| 1 | `bowDraw` | Separate bow, draw hand and arrow; bow grip, nock/string alignment and hand-over-bow occlusion. |
| 2 | `bowRelease` | Bow/arrow art separated from body; release-hand and bow-grip anchors with front/back ordering. |
| 3 | `dodge` | Skin-safe low-pose body and grounded foot placement; hand/weapon attachment and silhouette-safe gear layers. |
| 4 | `consumable` | Body base plus independent potion art; hand grip and mouth/face overlap anchor. |
| 5 | `stagger` | Bent-body base; separate held weapon/arm occlusion and stable head/gear placement through the recoil silhouette. |
| 6 | `spell` | Body/skin mask and separate held weapon; casting-hand anchor and effect origin kept outside the body mask. |
| 7 | `defeat` | Defeated-body base, face/head placement, grounded weapon art and floor-contact alignment. |

Shared layers/data required across those eight poses:

1. A complete body base for each pose with transparent background and exposed-skin masks for face, neck, arms, hands and legs. Either author each of the three body proportions per pose or supply a repeatable, fit-validated proportion transform.
2. Pose-aligned head/hair options for all eight `head_*` IDs, facial-hair options `facial_hair_00`–`facial_hair_04`, and a face/skin recolor mask compatible with all eight `skin_*` IDs.
3. Independent, pose-fitted overlays for helmets `helm_1`–`helm_4`, body gear `coat_1`–`coat_4`, and boots `boots_1`–`boots_4`. Each needs front/back pieces or masks wherever limbs, hair or weapons pass in front of it.
4. Weapon-family art and per-pose hand/grip anchors for the current melee and bow equipment, plus a separate potion layer for `consumable`. The accepted atlas currently bakes these props into the figure.
5. Per-pose normalized pivots/sockets for head, hair, facial hair, helmet, body gear, both boots, each hand and active prop; explicit z-order and front/back occlusion masks; exact source rectangles and destination transforms.
6. In-engine target-size previews for default and varied appearance/equipment selections across all eight poses. Check seams, double contours, floating gear, clipping, alpha fringes, hand grips and ground contact before publishing any placements.

## Runtime status

`assets/art/characters/hero_battle_atlas.png`, `hero_battle_actions.png`, and all other accepted runtime atlases remain unchanged. Candidates and previews in this review directory are not bundled. Do not copy any candidate into a runtime path until the missing layer art and socket/occlusion fit review pass.
