/// Stable encounter-ID mapping for opponents with dedicated battle motion art.
///
/// Atlases use the shared 3×2 row-major contract understood by
/// `FighterArt`: idle, wind-up, attack/cast, hit recoil, guard, defeat.
const Map<int, String> rivalMotionAtlasAssetsByEncounter = <int, String>{
  1: 'assets/art/characters/iskele_kabadayisi_motion.webp',
  2: 'assets/art/characters/halat_kosucusu_motion.webp',
  3: 'assets/art/characters/kapi_bekcisi_motion.webp',
  4: 'assets/art/characters/tuz_kahini_motion.webp',
  5: 'assets/art/characters/halatci_sefa_motion.webp',
  6: 'assets/art/characters/pasli_kanca_motion.webp',
  7: 'assets/art/characters/fener_bekcisi_motion.webp',
  8: 'assets/art/characters/fener_champion_motion.webp',
  9: 'assets/art/characters/curuf_tasiyici_motion.webp',
  10: 'assets/art/characters/zincirci_motion.webp',
  11: 'assets/art/characters/ors_muhafizi_motion.webp',
  12: 'assets/art/characters/sozlesmeli_duellocu_motion.webp',
  13: 'assets/art/characters/koz_golgesi_motion.webp',
  14: 'assets/art/characters/kizil_ocak_sefi_motion.webp',
  15: 'assets/art/characters/kukurt_matronu_motion.webp',
  16: 'assets/art/characters/brass_guardian_motion.webp',
  17: 'assets/art/characters/menzil_avcisi_motion.webp',
  18: 'assets/art/characters/ayna_kilic_motion.webp',
  19: 'assets/art/characters/gelgit_muhurcusu_motion.webp',
  20: 'assets/art/characters/firtina_avcisi_motion.webp',
  21: 'assets/art/characters/ruzgar_seyircisi_motion.webp',
  22: 'assets/art/characters/kiyi_orakcisi_motion.webp',
  23: 'assets/art/characters/gelgit_yargici_motion.webp',
  24: 'assets/art/characters/observatory_priest_motion.webp',
  25: 'assets/art/characters/tac_muhafizi_motion.webp',
  26: 'assets/art/characters/golge_duellocu_motion.webp',
  27: 'assets/art/characters/sancak_cadisi_motion.webp',
  28: 'assets/art/characters/demir_cellat_motion.webp',
  29: 'assets/art/characters/tahtsiz_varis_motion.webp',
  30: 'assets/art/characters/kul_komutani_motion.webp',
  31: 'assets/art/characters/muhur_kirici_motion.webp',
  32: 'assets/art/characters/circle_master_motion.webp',
};

String? rivalMotionAtlasAssetForEncounter(int encounterId) =>
    rivalMotionAtlasAssetsByEncounter[encounterId];
