part of '../screens.dart';

class AppearanceEditorPage extends StatefulWidget {
  const AppearanceEditorPage({super.key, required this.controller});

  final GameController controller;

  @override
  State<AppearanceEditorPage> createState() => _AppearanceEditorPageState();
}

class _AppearanceEditorPageState extends State<AppearanceEditorPage> {
  late String _bodyProportionId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final save = widget.controller.save;
    _bodyProportionId = save.bodyProportionId;
  }

  Future<void> _selectAppearance({required String bodyProportionId}) async {
    if (_saving) return;
    if (bodyProportionId == _bodyProportionId) return;

    setState(() {
      _bodyProportionId = bodyProportionId;
      _saving = true;
    });
    try {
      final updated = await widget.controller.updateHeroAppearance(
        bodyProportionId: bodyProportionId,
      );
      if (!updated && mounted) {
        _showMessage(context, gameText(context, 'ui.appearance.saveFailed'));
      }
    } on Object {
      if (mounted) {
        _showMessage(context, gameText(context, 'ui.appearance.saveFailed'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _optionChip({
    required BuildContext context,
    required String group,
    required String groupLabel,
    required String optionId,
    required int index,
    required bool selected,
    required Widget avatar,
    required ValueChanged<String> onSelected,
  }) {
    final optionSemanticLabel = gameText(context, 'ui.appearance.option', {
      'group': groupLabel,
      'count': index + 1,
    });
    return Semantics(
      label: optionSemanticLabel,
      selected: selected,
      button: true,
      enabled: !_saving,
      onTap: _saving ? null : () => onSelected(optionId),
      child: ExcludeSemantics(
        child: ChoiceChip(
          key: ValueKey('appearance.$group.$optionId'),
          avatar: avatar,
          label: Text('${index + 1}'),
          selected: selected,
          onSelected: _saving ? null : (_) => onSelected(optionId),
          selectedColor: GamePalette.gold,
          labelStyle: TextStyle(
            color: selected ? GamePalette.ink : GamePalette.parchment,
            fontWeight: FontWeight.w800,
          ),
          visualDensity: VisualDensity.standard,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        ),
      ),
    );
  }

  Widget _bodyOptions(BuildContext context) {
    final groupLabel = gameText(context, 'ui.appearance.build');
    return _appearanceGroup(
      context,
      title: groupLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final entry in heroBodyProportionIds.asMap().entries)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _optionChip(
                  context: context,
                  group: 'body',
                  groupLabel: groupLabel,
                  optionId: entry.value,
                  index: entry.key,
                  selected: _bodyProportionId == entry.value,
                  avatar: SizedBox(
                    width: 42,
                    height: 48,
                    child: HeroAppearanceOptionPreview(
                      kind: HeroAppearanceOptionKind.body,
                      optionId: entry.value,
                      origin: widget.controller.save.appearance,
                    ),
                  ),
                  onSelected: (id) => _selectAppearance(bodyProportionId: id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _appearanceGroup(
    BuildContext context, {
    required String title,
    required Widget child,
  }) => GamePanel(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [SectionHeading(title), const SizedBox(height: 10), child],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final save = widget.controller.save;
    final appearance = HeroAppearanceSelection(
      bodyProportionId: _bodyProportionId,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(gameText(context, 'ui.appearance.title')),
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                GamePanel(
                  child: Column(
                    children: [
                      SizedBox(
                        key: const ValueKey('appearance.preview'),
                        width: 180,
                        height: 190,
                        child: FighterArt(
                          seed: _originIndex(save.appearance),
                          name: _heroDisplayName(context, save.heroName),
                          isPlayer: true,
                          origin: save.appearance,
                          family: _familyName(save.weaponId),
                          portraitAsset: heroArtForAppearance(save.appearance),
                          customization: appearance,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gameText(context, 'ui.appearance.description'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GamePalette.muted,
                          height: 1.4,
                        ),
                      ),
                      if (_saving) ...[
                        const SizedBox(height: 12),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GamePalette.gold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _bodyOptions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

