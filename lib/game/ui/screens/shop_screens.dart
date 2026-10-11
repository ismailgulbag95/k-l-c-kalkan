part of '../screens.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, required this.controller});
  final GameController controller;
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final visibleItems = shopItems
        .where(
          (item) =>
              item.act <= controller.unlockedAct &&
              (filter == 'all' ||
                  (filter == 'weapon' &&
                      ['weapon', 'bow'].contains(item.category)) ||
                  (filter == 'armor' &&
                      ['head', 'body', 'boots'].contains(item.category)) ||
                  (filter == 'talisman' && item.category == 'talisman')),
        )
        .toList();
    final ownedGear = shopItems
        .where(
          (item) =>
              controller.save.ownedItems.contains(item.id) &&
              (filter == 'all' ||
                  (filter == 'weapon' &&
                      ['weapon', 'bow'].contains(item.category)) ||
                  (filter == 'armor' &&
                      ['head', 'body', 'boots'].contains(item.category)) ||
                  (filter == 'talisman' && item.category == 'talisman')),
        )
        .toList();
    final showSpells = filter == 'all' || filter == 'magic';
    final showConsumables = filter == 'all' || filter == 'supplies';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          gameText(context, 'ui.shop.title'),
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          gameText(context, 'ui.shop.catalog', {'act': controller.unlockedAct}),
          style: const TextStyle(color: GamePalette.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in [
              'all',
              'weapon',
              'armor',
              'talisman',
              'magic',
              'supplies',
            ])
              ChoiceChip(
                label: Text(gameText(context, 'ui.filter.$choice')),
                selected: filter == choice,
                onSelected: (_) => setState(() => filter = choice),
                selectedColor: GamePalette.gold,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                visualDensity: VisualDensity.standard,
                labelStyle: TextStyle(
                  color: filter == choice
                      ? GamePalette.ink
                      : GamePalette.parchment,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems)
          _ShopItemCard(controller: controller, item: item),
        if (ownedGear.isNotEmpty) ...[
          const SizedBox(height: 10),
          SectionHeading(localizedHeading(context, 'ui.shop.resaleTitle')),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              gameText(context, 'ui.shop.resaleInfo'),
              style: const TextStyle(color: GamePalette.muted, fontSize: 11),
            ),
          ),
          for (final item in ownedGear)
            _OwnedGearSaleCard(controller: controller, item: item),
        ],
        if (showSpells) ...[
          const SizedBox(height: 10),
          SectionHeading(localizedHeading(context, 'ui.shop.learnableSkills')),
          for (final spell in spells)
            _SpellCard(controller: controller, spell: spell),
        ],
        if (showConsumables) ...[
          const SizedBox(height: 10),
          SectionHeading(localizedHeading(context, 'ui.shop.suppliesBelt')),
          _ConsumableCard(controller: controller, salve: true),
          _ConsumableCard(controller: controller, salve: false),
        ],
      ],
    );
  }
}

class _OwnedGearSaleCard extends StatelessWidget {
  const _OwnedGearSaleCard({required this.controller, required this.item});
  final GameController controller;
  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    final equipped = controller.save.equippedItems[item.category] == item.id;
    final equipmentFrame = shopEquipmentAtlasFrame(item);
    final resalePrice = item.price ~/ 2;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: Center(
                child: equipmentFrame != null
                    ? EquipmentAtlasSprite(frame: equipmentFrame, size: 34)
                    : ItemAtlasIcon(frame: shopItemIconFrame(item), size: 30),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedContent(context, 'item', item.id, 'name'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.resalePrice', {
                      'price': resalePrice,
                    }),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 76,
              child: FilledButton(
                onPressed: equipped
                    ? null
                    : () async {
                        final error = await controller.sellItem(item.id);
                        if (!context.mounted) return;
                        _showMessage(
                          context,
                          error == null
                              ? gameText(context, 'ui.shop.saleSuccess', {
                                  'price': resalePrice,
                                })
                              : gameText(context, 'ui.shop.saleRejected'),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: GamePalette.panelLight,
                  foregroundColor: GamePalette.parchment,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  equipped
                      ? gameText(context, 'ui.shop.saleEquipped')
                      : gameText(context, 'ui.shop.sell'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({required this.controller, required this.item});
  final GameController controller;
  final ShopItem item;
  @override
  Widget build(BuildContext context) {
    final save = controller.save;
    final equipmentFrame = shopEquipmentAtlasFrame(item);
    final owned = save.ownedItems.contains(item.id);
    final equipped = save.equippedItems[item.category] == item.id;
    final meetsMinimumAttribute =
        item.minAttribute == null ||
        save.stats[item.minAttribute!] >= item.minAttributeValue;
    final minimumAttributeText = item.minAttribute == null
        ? null
        : gameText(context, 'ui.shop.minimumAttribute', {
            'attribute': gameText(
              context,
              'label.stat.${item.minAttribute!.name}',
            ),
            'value': item.minAttributeValue,
          });
    final canBuy =
        !owned &&
        save.gold >= item.price &&
        save.level >= item.level &&
        meetsMinimumAttribute;
    final badge = switch (item.category) {
      'weapon' => gameText(context, 'label.family.${item.family!.name}'),
      'bow' => gameText(context, 'ui.shop.bow'),
      'head' => gameText(context, 'ui.gear.head'),
      'body' => gameText(context, 'ui.gear.body'),
      'boots' => gameText(context, 'ui.gear.boots'),
      _ => gameText(context, 'ui.gear.talisman'),
    };
    final power = item.weaponPower > 0
        ? gameText(context, 'ui.shop.power', {'power': item.weaponPower})
        : gameText(context, 'ui.shop.armorValue', {'armor': item.armor});
    final statusResistance = item.statusResistance > 0
        ? gameText(context, 'ui.shop.statusResistance', {
            'value': item.statusResistance,
          })
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: GamePalette.gold.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: equipmentFrame != null
                    ? EquipmentAtlasSprite(frame: equipmentFrame, size: 38)
                    : ItemAtlasIcon(frame: shopItemIconFrame(item), size: 32),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizedContent(context, 'item', item.id, 'name'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        GameLocalizations.of(context).uppercase(badge),
                        style: const TextStyle(
                          color: GamePalette.gold,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${localizedContent(context, 'item', item.id, 'description')}  ·  $power',
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                  if (statusResistance != null)
                    Text(
                      statusResistance,
                      style: const TextStyle(
                        color: GamePalette.teal,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  if (minimumAttributeText != null)
                    Text(
                      minimumAttributeText,
                      style: TextStyle(
                        color: meetsMinimumAttribute
                            ? GamePalette.teal
                            : GamePalette.rust,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    gameText(context, 'ui.shop.itemLevelPrice', {
                      'level': item.level,
                      'price': item.price,
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
            SizedBox(
              width: 74,
              child: FilledButton(
                onPressed: equipped
                    ? null
                    : owned
                    ? meetsMinimumAttribute
                          ? () {
                              unawaited(
                                _runShopOperation(
                                  context,
                                  controller,
                                  () => controller.equip(item.id),
                                ),
                              );
                            }
                          : null
                    : canBuy
                    ? () => unawaited(
                        _runShopOperation(
                          context,
                          controller,
                          () => controller.buyItem(item),
                        ),
                      )
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: owned
                      ? GamePalette.panelLight
                      : GamePalette.gold,
                  foregroundColor: owned
                      ? GamePalette.parchment
                      : GamePalette.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  equipped
                      ? gameText(context, 'ui.shop.equipped')
                      : owned
                      ? gameText(context, 'ui.shop.equip')
                      : gameText(context, 'ui.shop.buy'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpellCard extends StatelessWidget {
  const _SpellCard({required this.controller, required this.spell});
  final GameController controller;
  final SpellInfo spell;
  @override
  Widget build(BuildContext context) {
    final id = 'spell_${spell.action.name}';
    final known = controller.save.ownedItems.contains(id);
    final act =
        spell.action == BattleAction.emberSpear ||
            spell.action == BattleAction.ashBurst
        ? 1
        : spell.action == BattleAction.tideWard ||
              spell.action == BattleAction.saltCleanse
        ? 2
        : 3;
    const price = [140, 340, 700];
    final cost = price[act - 1];
    final unlocked =
        act <= controller.unlockedAct && controller.save.gold >= cost;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            SizedBox(
              width: 43,
              height: 43,
              child: Center(
                child: ItemAtlasIcon(
                  frame: spellIconFrame(spell.action),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameText(context, 'label.action.${spell.action.name}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.spellCost', {
                      'description': localizedContent(
                        context,
                        'spell',
                        spell.action.name,
                        'description',
                      ),
                      'cost': spell.cost,
                    }),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.actPrice', {
                      'act': act,
                      'cost': cost,
                    }),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 74,
              child: FilledButton(
                onPressed: known || !unlocked
                    ? null
                    : () {
                        unawaited(
                          _runShopOperation(
                            context,
                            controller,
                            () => controller.buySpell(spell.action),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: known
                      ? GamePalette.panelLight
                      : GamePalette.gold,
                  foregroundColor: known
                      ? GamePalette.parchment
                      : GamePalette.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(
                  known
                      ? gameText(context, 'ui.shop.learned')
                      : gameText(context, 'ui.shop.learn'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumableCard extends StatelessWidget {
  const _ConsumableCard({required this.controller, required this.salve});
  final GameController controller;
  final bool salve;
  @override
  Widget build(BuildContext context) {
    final count = salve
        ? controller.save.healingSalves
        : controller.save.effortTonics;
    final price = getConsumablePrice(controller.unlockedAct, salve: salve);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: GamePanel(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            SizedBox(
              width: 43,
              height: 43,
              child: Center(
                child: ItemAtlasIcon(frame: salve ? 14 : 15, size: 36),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameText(
                      context,
                      salve ? 'ui.shop.healingSalve' : 'ui.shop.effortTonic',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    salve
                        ? gameText(context, 'ui.shop.salveDescription')
                        : gameText(context, 'ui.shop.tonicDescription'),
                    style: const TextStyle(
                      color: GamePalette.muted,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    gameText(context, 'ui.shop.inventoryPrice', {
                      'count': count,
                      'price': price,
                    }),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 76,
              child: FilledButton(
                onPressed: count >= 3 || controller.save.gold < price
                    ? null
                    : () {
                        unawaited(
                          _runShopOperation(
                            context,
                            controller,
                            () => controller.buyConsumable(salve: salve),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: GamePalette.gold,
                  foregroundColor: GamePalette.ink,
                ),
                child: Text(
                  gameText(context, 'ui.shop.purchase'),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

