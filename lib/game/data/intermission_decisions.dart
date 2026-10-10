enum IntermissionReward { training, sponsorship }

class IntermissionDecision {
  const IntermissionDecision({
    required this.id,
    required this.afterEncounterId,
    required this.sponsorshipGold,
    required this.art,
  });

  final String id;
  final int afterEncounterId;
  final int sponsorshipGold;
  final String art;

  String get encounterKey => 'M${afterEncounterId.toString().padLeft(2, '0')}';
}

const intermissionDecisions = <IntermissionDecision>[
  IntermissionDecision(
    id: 'I04',
    afterEncounterId: 4,
    sponsorshipGold: 120,
    art: 'assets/art/intermissions/i04_training_offer.webp',
  ),
  IntermissionDecision(
    id: 'I12',
    afterEncounterId: 12,
    sponsorshipGold: 180,
    art: 'assets/art/intermissions/i12_forge_choice.webp',
  ),
  IntermissionDecision(
    id: 'I20',
    afterEncounterId: 20,
    sponsorshipGold: 240,
    art: 'assets/art/intermissions/i20_storm_strategy.webp',
  ),
  IntermissionDecision(
    id: 'I28',
    afterEncounterId: 28,
    sponsorshipGold: 300,
    art: 'assets/art/intermissions/i28_crown_preparation.webp',
  ),
];
