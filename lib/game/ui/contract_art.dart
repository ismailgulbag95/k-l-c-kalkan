/// Runtime artwork paths for the contract card illustrations.
const contractArtById = <String, String>{
  'C1-A': 'assets/art/contracts/c1_a_clean_duel.webp',
  'C1-B': 'assets/art/contracts/c1_b_short_sword_mastery.webp',
  'C1-C': 'assets/art/contracts/c1_c_defense_trial.webp',
  'C1-D': 'assets/art/contracts/c1_d_lighthouse_shadow.webp',
  'C2-A': 'assets/art/contracts/c2_a_ash_control.webp',
  'C2-B': 'assets/art/contracts/c2_b_armor_breaker.webp',
  'C2-C': 'assets/art/contracts/c2_c_heat_management.webp',
  'C2-D': 'assets/art/contracts/c2_d_matrons_seals.webp',
  'C3-A': 'assets/art/contracts/c3_a_range_mastery.webp',
  'C3-B': 'assets/art/contracts/c3_b_seal_breaker.webp',
  'C3-C': 'assets/art/contracts/c3_c_unbroken_tempo.webp',
  'C3-D': 'assets/art/contracts/c3_d_judges_opening.webp',
  'C4-A': 'assets/art/contracts/c4_a_last_preparation.webp',
  'C4-B': 'assets/art/contracts/c4_b_commanders_opening.webp',
  'C4-C': 'assets/art/contracts/c4_c_champions_oath.webp',
  'C4-D': 'assets/art/contracts/c4_d_break_the_seal.webp',
};

String? contractArtAssetForId(String id) => contractArtById[id];
