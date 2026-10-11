part of '../screens.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    children: [
      Text(
        gameText(context, 'ui.challenge.title'),
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      Text(
        gameText(context, 'ui.challenge.intro'),
        style: const TextStyle(color: GamePalette.muted, fontSize: 12),
      ),
      const SizedBox(height: 16),
      for (var chapter = 1; chapter <= 4; chapter++) ...[
        _ChapterHeader(
          chapter: chapter,
          completed: controller.save.completedContracts
              .where((id) => id.startsWith('C$chapter-'))
              .length,
        ),
        for (final contract in contracts.where(
          (entry) => entry.id.startsWith('C$chapter-'),
        ))
          _ContractTile(controller: controller, contract: contract),
        const SizedBox(height: 10),
      ],
      if (controller.campaignComplete) ...[
        const SizedBox(height: 8),
        GamePanel(
          borderColor: GamePalette.gold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                localizedHeading(context, 'ui.campaign.championsRoad'),
              ),
              const SizedBox(height: 8),
              Text(
                gameText(context, 'ui.challenge.championsRoadIntro'),
                style: TextStyle(color: GamePalette.muted, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gameText(context, 'ui.challenge.completeCount', {
                        'completed': controller.save.championsRunBest,
                      }),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const GameGlyph(
                    GameGlyphKind.champions,
                    color: GamePalette.gold,
                    size: 20,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GameButton(
                label: controller.save.championsRunBest >= 8
                    ? gameText(context, 'ui.challenge.replaySeries')
                    : gameText(context, 'ui.challenge.nextTrial', {
                        'stage': controller.save.championsRunBest + 1,
                      }),
                icon: Icons.sports_martial_arts,
                onPressed: () => _openBattle(
                  context,
                  controller,
                  () => controller.startChampionsRoad(
                    controller.save.championsRunBest >= 8
                        ? 1
                        : controller.save.championsRunBest + 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ] else
        GamePanel(
          child: Text(
            gameText(context, 'ui.challenge.locked'),
            style: TextStyle(color: GamePalette.muted),
          ),
        ),
    ],
  );
}

class _ContractTile extends StatelessWidget {
  const _ContractTile({required this.controller, required this.contract});
  final GameController controller;
  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.isEncounterUnlocked(contract.targetId);
    final completed = controller.save.completedContracts.contains(contract.id);
    final target = getEncounter(contract.targetId);
    final title = localizedContent(context, 'contract', contract.id, 'title');
    final artAsset = contractArtAssetForId(contract.id);

    Widget artworkFallback() => const ColoredBox(
      color: GamePalette.panelLight,
      child: Center(
        child: GameGlyph(
          GameGlyphKind.fighter,
          color: GamePalette.gold,
          size: 24,
          excludeFromSemantics: true,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artSize = (constraints.maxWidth * 0.2)
                .clamp(58.0, 76.0)
                .toDouble();
            final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

            return Row(
              children: [
                SizedBox.square(
                  dimension: artSize,
                  child: Semantics(
                    image: true,
                    label: title,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: artAsset == null
                          ? artworkFallback()
                          : Image.asset(
                              artAsset,
                              fit: BoxFit.cover,
                              cacheWidth: (artSize * devicePixelRatio).round(),
                              excludeFromSemantics: true,
                              frameBuilder: (context, child, frame, _) =>
                                  frame == null ? artworkFallback() : child,
                              errorBuilder: (context, error, stackTrace) =>
                                  artworkFallback(),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  completed
                      ? Icons.task_alt
                      : unlocked
                      ? Icons.assignment_outlined
                      : Icons.lock_outline,
                  color: completed ? GamePalette.teal : GamePalette.gold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${contract.id} · ${_encounterName(context, target)}',
                        style: const TextStyle(
                          color: GamePalette.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizedContent(
                          context,
                          'contract',
                          contract.id,
                          'description',
                        ),
                        style: const TextStyle(
                          color: GamePalette.muted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gameText(context, 'ui.contract.reward', {
                          'reward': contract.reward,
                        }),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: gameText(
                    context,
                    completed ? 'ui.contract.replay' : 'ui.contract.enter',
                  ),
                  onPressed: unlocked
                      ? () => _openBattle(
                          context,
                          controller,
                          () => controller.startContract(contract.id),
                        )
                      : null,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

