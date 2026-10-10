class StoryEvidenceEntry {
  const StoryEvidenceEntry({
    required this.id,
    required this.afterEncounterId,
    required this.frame,
    required this.titleKey,
    required this.bodyKey,
  });

  final String id;
  final int afterEncounterId;
  final int frame;
  final String titleKey;
  final String bodyKey;

  String get encounterKey => 'M${afterEncounterId.toString().padLeft(2, '0')}';
}

const storyEvidenceEntries = <StoryEvidenceEntry>[
  StoryEvidenceEntry(
    id: 'E04',
    afterEncounterId: 4,
    frame: 0,
    titleKey: 'story.evidence.E04.title',
    bodyKey: 'story.evidence.E04.body',
  ),
  StoryEvidenceEntry(
    id: 'E12',
    afterEncounterId: 12,
    frame: 1,
    titleKey: 'story.evidence.E12.title',
    bodyKey: 'story.evidence.E12.body',
  ),
  StoryEvidenceEntry(
    id: 'E20',
    afterEncounterId: 20,
    frame: 2,
    titleKey: 'story.evidence.E20.title',
    bodyKey: 'story.evidence.E20.body',
  ),
  StoryEvidenceEntry(
    id: 'E28',
    afterEncounterId: 28,
    frame: 3,
    titleKey: 'story.evidence.E28.title',
    bodyKey: 'story.evidence.E28.body',
  ),
];
