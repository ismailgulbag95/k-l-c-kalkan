part of '../screens.dart';

class FighterPage extends StatelessWidget {
  const FighterPage({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final save = controller.save;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          _heroDisplayName(context, save.heroName),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        Text(
          gameText(context, 'ui.fighter.heading'),
          style: const TextStyle(color: GamePalette.muted),
        ),
        const SizedBox(height: 16),
        GamePanel(
          child: Row(
            children: [
              SizedBox(
                width: 128,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final currentSave = controller.save;
                    return FighterArt(
                      seed: _originIndex(currentSave.appearance),
                      name: _heroDisplayName(context, currentSave.heroName),
                      isPlayer: true,
                      origin: currentSave.appearance,
                      family: _familyName(currentSave.weaponId),
                      portraitAsset: heroArtForAppearance(
                        currentSave.appearance,
                      ),
                      customization: HeroAppearanceSelection(
                        bodyProportionId: currentSave.bodyProportionId,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameText(context, 'ui.fighter.level', {
                        'level': save.level,
                      }),
                      style: const TextStyle(
                        color: GamePalette.gold,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ResourceBar(
                      label: gameText(context, 'ui.resource.health'),
                      value: save.health,
                      max: save.health,
                      color: GamePalette.health,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    ResourceBar(
                      label: gameText(context, 'ui.resource.effort'),
                      value: save.effort,
                      max: save.effort,
                      color: GamePalette.effort,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    ResourceBar(
                      label: gameText(context, 'ui.resource.mana'),
                      value: save.mana,
                      max: save.mana,
                      color: GamePalette.mana,
                      compact: true,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ValuePill(
                          icon: Icons.monetization_on,
                          value: '${save.gold}',
                        ),
                        ValuePill(
                          icon: Icons.add_circle,
                          value: gameText(context, 'ui.campaign.points', {
                            'count': save.unspentStatPoints,
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GameButton(
          label: gameText(context, 'ui.appearance.edit'),
          icon: Icons.face_retouching_natural,
          secondary: true,
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => AppearanceEditorPage(controller: controller),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (save.rebirthCredits > 0)
          GamePanel(
            padding: const EdgeInsets.all(12),
            borderColor: GamePalette.gold,
            child: Row(
              children: [
                const Icon(Icons.restart_alt, color: GamePalette.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    gameText(context, 'ui.fighter.redistribution', {
                      'count': save.rebirthCredits,
                    }),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(
                          gameText(context, 'ui.fighter.resetStats.title'),
                        ),
                        content: Text(
                          gameText(context, 'ui.fighter.resetStats.body'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: Text(gameText(context, 'ui.common.cancel')),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(gameText(context, 'ui.common.reset')),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) await controller.redistributeStats();
                  },
                  child: Text(gameText(context, 'ui.common.use')),
                ),
              ],
            ),
          ),
        if (save.rebirthCredits > 0) const SizedBox(height: 12),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeading(
                      localizedHeading(context, 'ui.creator.stats'),
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.fighter.pointsToSpend', {
                      'count': save.unspentStatPoints,
                    }),
                    style: const TextStyle(
                      color: GamePalette.gold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final stat in Stat.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          gameText(context, 'label.stat.${stat.name}'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _StatPips(value: save.stats[stat]),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${save.stats[stat]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: GamePalette.gold,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: gameText(context, 'ui.fighter.spendPoint'),
                        onPressed:
                            save.unspentStatPoints > 0 && save.stats[stat] < 20
                            ? () => controller.spendStat(stat)
                            : null,
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeading(
                      localizedHeading(context, 'ui.fighter.equipment'),
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.fighter.inventoryCount', {
                      'count': save.ownedItems
                          .where((id) => !id.startsWith('spell_'))
                          .length,
                    }),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final slot in const [
                'weapon',
                'bow',
                'head',
                'body',
                'boots',
                'talisman',
              ])
                _GearSlot(controller: controller, slot: slot),
              const Divider(height: 22),
              Row(
                children: [
                  const GameGlyph(
                    GameGlyphKind.supply,
                    size: 17,
                    color: GamePalette.gold,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gameText(context, 'ui.fighter.salveCount', {
                      'count': save.healingSalves,
                    }),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    gameText(context, 'ui.fighter.tonicCount', {
                      'count': save.effortTonics,
                    }),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                gameText(context, 'ui.fighter.learnedSpells', {
                  'count': save.ownedItems
                      .where((id) => id.startsWith('spell_'))
                      .length,
                }),
                style: const TextStyle(color: GamePalette.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeading(
                      localizedHeading(context, 'ui.fighter.masteryTree'),
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.fighter.masteryPoints', {
                      'count': save.unspentMasteryPoints,
                    }),
                    style: const TextStyle(
                      color: GamePalette.gold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final mastery in _masteryList)
                _MasteryTile(controller: controller, item: mastery),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatPips extends StatelessWidget {
  const _StatPips({required this.value});
  final int value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < 10; i++)
        Container(
          width: 5,
          height: 13,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: i < value ? GamePalette.gold : GamePalette.panelLight,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
    ],
  );
}

class _GearSlot extends StatelessWidget {
  const _GearSlot({required this.controller, required this.slot});
  final GameController controller;
  final String slot;

  @override
  Widget build(BuildContext context) {
    final save = controller.save;
    final id = save.equippedItems[slot];
    final item = shopItems.where((entry) => entry.id == id).firstOrNull;
    final owned = save.ownedItems
        .map(
          (ownedId) =>
              shopItems.where((entry) => entry.id == ownedId).firstOrNull,
        )
        .whereType<ShopItem>()
        .where((entry) => entry.category == slot)
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameText(context, switch (slot) {
                    'weapon' => 'ui.gear.melee',
                    'bow' => 'ui.gear.ranged',
                    'head' => 'ui.gear.head',
                    'body' => 'ui.gear.body',
                    'boots' => 'ui.gear.boots',
                    _ => 'ui.gear.talisman',
                  }),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  item == null
                      ? gameText(context, 'ui.gear.starting')
                      : localizedContent(context, 'item', item.id, 'name'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (owned.length > 1)
            DropdownButton<String>(
              value: id,
              dropdownColor: GamePalette.panel,
              underline: const SizedBox(),
              items: [
                for (final entry in owned)
                  DropdownMenuItem(
                    value: entry.id,
                    child: Text(
                      localizedContent(context, 'item', entry.id, 'name'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
              onChanged: (next) {
                if (next != null) {
                  unawaited(
                    _runShopOperation(
                      context,
                      controller,
                      () => controller.equip(next),
                    ),
                  );
                }
              },
            )
          else
            Text(
              item == null
                  ? '—'
                  : '+${item.weaponPower > 0 ? item.weaponPower : item.armor}',
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _Mastery {
  const _Mastery(this.id);
  final String id;
}

const _masteryList = <_Mastery>[
  _Mastery('front_1'),
  _Mastery('front_2'),
  _Mastery('front_3'),
  _Mastery('duel_1'),
  _Mastery('duel_2'),
  _Mastery('duel_3'),
  _Mastery('seal_1'),
  _Mastery('seal_2'),
  _Mastery('seal_3'),
];

class _MasteryTile extends StatelessWidget {
  const _MasteryTile({required this.controller, required this.item});
  final GameController controller;
  final _Mastery item;
  @override
  Widget build(BuildContext context) {
    final unlocked = controller.save.masteries.contains(item.id);
    final tier = int.parse(item.id.substring(item.id.length - 1));
    final previous =
        tier == 1 ||
        controller.save.masteries.contains(
          '${item.id.substring(0, item.id.length - 1)}${tier - 1}',
        );
    final canUnlock = previous && controller.save.unspentMasteryPoints > 0;
    final unlockLabel = gameText(context, 'ui.mastery.unlock', {
      'name': localizedContent(context, 'mastery', item.id, 'name'),
    });
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        unlocked
            ? Icons.verified
            : previous
            ? Icons.lock_open
            : Icons.lock_outline,
        color: unlocked ? GamePalette.teal : GamePalette.gold,
        size: 20,
      ),
      title: Text(
        localizedContent(context, 'mastery', item.id, 'name'),
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: unlocked ? GamePalette.teal : GamePalette.parchment,
        ),
      ),
      subtitle: Text(
        '${localizedContent(context, 'mastery', item.id, 'path')} · ${localizedContent(context, 'mastery', item.id, 'description')}',
        style: const TextStyle(color: GamePalette.muted, fontSize: 10),
      ),
      trailing: unlocked
          ? const Icon(Icons.check, color: GamePalette.teal)
          : _labelledIconButton(
              label: unlockLabel,
              onPressed: canUnlock
                  ? () => controller.unlockMastery(item.id)
                  : null,
              icon: Icons.add_circle_outline,
            ),
    );
  }
}

String _familyName(String? itemId) {
  final item = shopItems.where((entry) => entry.id == itemId).firstOrNull;
  return item?.family?.name ?? 'shortSword';
}

int _originIndex(String appearance) =>
    const {'Kıyı': 0, 'Ocak': 1, 'Fırtına': 2, 'Taç': 3}[appearance] ?? 0;

