part of '../screens.dart';

class CharacterCreator extends StatefulWidget {
  const CharacterCreator({super.key, required this.controller});
  final GameController controller;

  @override
  State<CharacterCreator> createState() => _CharacterCreatorState();
}

class _CharacterCreatorState extends State<CharacterCreator> {
  final _name = TextEditingController();
  var stats = const Stats();
  int remaining = 6;
  String origin = 'Kıyı';
  String bodyProportionId = 'body_01';

  HeroAppearanceSelection get _appearanceSelection =>
      HeroAppearanceSelection(bodyProportionId: bodyProportionId);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _adjust(Stat stat, int delta) {
    if (delta > 0 && (remaining == 0 || stats[stat] >= 5)) return;
    if (delta < 0 && stats[stat] <= 2) return;
    setState(() {
      stats = stats.withStat(stat, stats[stat] + delta);
      remaining -= delta;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(gameText(context, 'ui.creator.title')),
      leading: _labelledIconButton(
        label: gameText(context, 'ui.common.back'),
        onPressed: () => Navigator.pop(context),
        icon: Icons.arrow_back,
      ),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            children: [
              GamePanel(
                child: Row(
                  children: [
                    SizedBox(
                      width: 132,
                      child: FighterArt(
                        seed: 1,
                        name: gameText(context, 'ui.creator.newFighter'),
                        isPlayer: true,
                        origin: origin,
                        portraitAsset: heroArtForAppearance(origin),
                        customization: _appearanceSelection,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameText(context, 'ui.creator.heading'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            gameText(context, 'ui.creator.body'),
                            style: TextStyle(
                              color: GamePalette.muted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                maxLength: 20,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: gameText(context, 'ui.creator.name'),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 12),
              SectionHeading(
                localizedHeading(context, 'ui.creator.appearance'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final choice in ['Kıyı', 'Ocak', 'Fırtına', 'Taç'])
                    ChoiceChip(
                      avatar: SizedBox(
                        width: 25,
                        height: 38,
                        child: HeroAppearanceOptionPreview(
                          kind: HeroAppearanceOptionKind.body,
                          optionId: 'body_02',
                          origin: choice,
                        ),
                      ),
                      label: Text(
                        gameText(context, switch (choice) {
                          'Kıyı' => 'ui.origin.coast',
                          'Ocak' => 'ui.origin.forge',
                          'Fırtına' => 'ui.origin.storm',
                          _ => 'ui.origin.crown',
                        }),
                      ),
                      selected: origin == choice,
                      onSelected: (_) => setState(() => origin = choice),
                      selectedColor: GamePalette.gold,
                      labelStyle: TextStyle(
                        color: origin == choice
                            ? GamePalette.ink
                            : GamePalette.parchment,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              GamePanel(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SectionHeading(
                            localizedHeading(context, 'ui.creator.stats'),
                          ),
                        ),
                        ValuePill(
                          icon: Icons.add_circle_outline,
                          value: gameText(context, 'ui.points.remaining', {
                            'count': remaining,
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final stat in Stat.values)
                      _StatEditor(
                        stat: stat,
                        value: stats[stat],
                        onMinus: () => _adjust(stat, -1),
                        onPlus: () => _adjust(stat, 1),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildCustomizationControls(context),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GameButton(
            label: gameText(context, 'ui.creator.joinLeague'),
            icon: Icons.arrow_forward,
            enabled: remaining == 0,
            onPressed: remaining == 0
                ? () async {
                    try {
                      await widget.controller.createHero(
                        name: _name.text,
                        stats: stats,
                        appearance: origin,
                        bodyProportionId: bodyProportionId,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } on Object catch (error) {
                      if (context.mounted) _showMessage(context, '$error');
                    }
                  }
                : null,
          ),
        ),
      ),
    ),
  );

  Widget _buildCustomizationControls(BuildContext context) {
    final isEnglish = GameLocalizations.of(context).isEnglish;
    final labelStyle = TextStyle(
      color: GamePalette.parchment,
      fontWeight: FontWeight.w700,
    );

    Widget selectorTitle(String turkish, String english) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(isEnglish ? english : turkish, style: labelStyle),
    );

    Widget accessibleChoice({
      required String group,
      required String groupLabel,
      required String optionId,
      required int index,
      required bool selected,
      required Widget chip,
      required VoidCallback onSelected,
    }) {
      final option = gameText(context, 'ui.appearance.option', {
        'group': groupLabel,
        'count': index + 1,
      });
      return Semantics(
        key: ValueKey('creator.$group.$optionId'),
        label: option,
        selected: selected,
        button: true,
        onTap: onSelected,
        child: ExcludeSemantics(child: chip),
      );
    }

    Widget imageChoice({
      required String group,
      required String groupLabel,
      required String id,
      required bool selected,
      required HeroAppearanceOptionKind kind,
      required int displayIndex,
      required double previewHeight,
      required ValueChanged<bool> onSelected,
    }) => accessibleChoice(
      group: group,
      groupLabel: groupLabel,
      optionId: id,
      index: displayIndex,
      selected: selected,
      onSelected: () => onSelected(true),
      chip: ChoiceChip(
        avatar: SizedBox(
          width: 42,
          height: previewHeight,
          child: HeroAppearanceOptionPreview(
            kind: kind,
            optionId: id,
            origin: origin,
          ),
        ),
        label: Text('${displayIndex + 1}'),
        selected: selected,
        onSelected: onSelected,
        selectedColor: GamePalette.gold,
        labelStyle: TextStyle(
          color: selected ? GamePalette.ink : GamePalette.parchment,
          fontWeight: FontWeight.w800,
        ),
        visualDensity: VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      ),
    );

    return GamePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          selectorTitle('Yapı', 'Build'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in heroBodyProportionIds.asMap().entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: imageChoice(
                      group: 'body',
                      groupLabel: gameText(context, 'ui.appearance.build'),
                      id: entry.value,
                      selected: bodyProportionId == entry.value,
                      kind: HeroAppearanceOptionKind.body,
                      displayIndex: entry.key,
                      previewHeight: 48,
                      onSelected: (_) =>
                          setState(() => bodyProportionId = entry.value),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatEditor extends StatelessWidget {
  const _StatEditor({
    required this.stat,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });
  final Stat stat;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gameText(context, 'label.stat.${stat.name}'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                gameText(context, 'ui.statHelp.${stat.name}'),
                style: const TextStyle(color: GamePalette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: value > 2 ? onMinus : null,
          icon: const Icon(Icons.remove, size: 18),
          tooltip: gameText(context, 'ui.common.decrease'),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GamePalette.gold,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < 5 ? onPlus : null,
          icon: const Icon(Icons.add, size: 18),
          tooltip: gameText(context, 'ui.common.increase'),
        ),
      ],
    ),
  );
}

