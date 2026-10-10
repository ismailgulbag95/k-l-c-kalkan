/// Stable encounter-ID mapping for opponents with dedicated battle motion art.
///
/// Atlases use the shared 3×2 row-major contract understood by
/// `FighterArt`: idle, wind-up, attack/cast, hit recoil, guard, defeat.
const Map<int, String> rivalMotionAtlasAssetsByEncounter = <int, String>{
  1: 'assets/art/characters/iskele_kabadayisi_motion.png',
  2: 'assets/art/characters/halat_kosucusu_motion.png',
  3: 'assets/art/characters/kapi_bekcisi_motion.png',
  4: 'assets/art/characters/tuz_kahini_motion.png',
  5: 'assets/art/characters/halatci_sefa_motion.png',
  6: 'assets/art/characters/pasli_kanca_motion.png',
  7: 'assets/art/characters/fener_bekcisi_motion.png',
  8: 'assets/art/characters/fener_champion_motion.png',
  9: 'assets/art/characters/curuf_tasiyici_motion.png',
  10: 'assets/art/characters/zincirci_motion.png',
  11: 'assets/art/characters/ors_muhafizi_motion.png',
  12: 'assets/art/characters/sozlesmeli_duellocu_motion.png',
  13: 'assets/art/characters/koz_golgesi_motion.png',
  14: 'assets/art/characters/kizil_ocak_sefi_motion.png',
  15: 'assets/art/characters/kukurt_matronu_motion.png',
  16: 'assets/art/characters/brass_guardian_motion.png',
  17: 'assets/art/characters/menzil_avcisi_motion.png',
  18: 'assets/art/characters/ayna_kilic_motion.png',
  19: 'assets/art/characters/gelgit_muhurcusu_motion.png',
  20: 'assets/art/characters/firtina_avcisi_motion.png',
  21: 'assets/art/characters/ruzgar_seyircisi_motion.png',
  22: 'assets/art/characters/kiyi_orakcisi_motion.png',
  23: 'assets/art/characters/gelgit_yargici_motion.png',
  24: 'assets/art/characters/observatory_priest_motion.png',
  25: 'assets/art/characters/tac_muhafizi_motion.png',
  26: 'assets/art/characters/golge_duellocu_motion.png',
  27: 'assets/art/characters/sancak_cadisi_motion.png',
  28: 'assets/art/characters/demir_cellat_motion.png',
  29: 'assets/art/characters/tahtsiz_varis_motion.png',
  30: 'assets/art/characters/kul_komutani_motion.png',
  31: 'assets/art/characters/muhur_kirici_motion.png',
  32: 'assets/art/characters/circle_master_motion.png',
};

String? rivalMotionAtlasAssetForEncounter(int encounterId) =>
    rivalMotionAtlasAssetsByEncounter[encounterId];
