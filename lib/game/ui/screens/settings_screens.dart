part of '../screens.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});
  final GameController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _musicVolume;
  late double _sfxVolume;
  bool _editingMusic = false;
  bool _editingSfx = false;

  @override
  void initState() {
    super.initState();
    _readSavedVolumes();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _readSavedVolumes();
    }
  }

  void _readSavedVolumes() {
    _musicVolume = widget.controller.save.musicVolume;
    _sfxVolume = widget.controller.save.sfxVolume;
  }

  void _handleControllerChanged() {
    if (!_editingMusic) _musicVolume = widget.controller.save.musicVolume;
    if (!_editingSfx) _sfxVolume = widget.controller.save.sfxVolume;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  Widget _volumeSlider(
    BuildContext context, {
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: GamePalette.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      Slider(
        value: value,
        min: 0,
        max: 1,
        divisions: 20,
        label: '${(value * 100).round()}%',
        activeColor: GamePalette.gold,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final save = controller.save;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          gameText(context, 'ui.settings.title'),
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.sfx')),
                subtitle: Text(
                  gameText(context, 'ui.settings.sfxDescription'),
                  style: TextStyle(color: GamePalette.muted, fontSize: 11),
                ),
                value: save.sfxEnabled,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(sfxEnabled: value),
              ),
              const Divider(),
              _volumeSlider(
                context,
                title: gameText(context, 'ui.settings.musicVolume'),
                value: _musicVolume,
                onChanged: (value) {
                  _editingMusic = true;
                  setState(() => _musicVolume = value);
                  GameAudioScope.maybeOf(context)?.setMusicVolume(value);
                },
                onChangeEnd: (value) {
                  _editingMusic = false;
                  unawaited(controller.updateSettings(musicVolume: value));
                },
              ),
              const Divider(),
              _volumeSlider(
                context,
                title: gameText(context, 'ui.settings.sfxVolume'),
                value: _sfxVolume,
                onChanged: (value) {
                  _editingSfx = true;
                  setState(() => _sfxVolume = value);
                  GameAudioScope.maybeOf(context)?.setSfxVolume(value);
                },
                onChangeEnd: (value) {
                  _editingSfx = false;
                  unawaited(controller.updateSettings(sfxVolume: value));
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.vibration')),
                subtitle: Text(
                  gameText(context, 'ui.settings.vibrationDescription'),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 11,
                  ),
                ),
                value: save.vibrationEnabled,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(vibrationEnabled: value),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.reduceMotion')),
                subtitle: Text(
                  gameText(context, 'ui.settings.reduceMotionDescription'),
                  style: TextStyle(color: GamePalette.muted, fontSize: 11),
                ),
                value: save.reducedMotion,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(reducedMotion: value),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.textScale')),
                subtitle: Text('${(save.textScale * 100).round()}%'),
              ),
              Wrap(
                spacing: 7,
                runSpacing: 4,
                children: [
                  for (final scale in const [1.0, 1.25, 1.5, 1.75, 2.0])
                    ChoiceChip(
                      label: Text('${(scale * 100).round()}%'),
                      selected: (save.textScale - scale).abs() < .01,
                      onSelected: (_) =>
                          controller.updateSettings(textScale: scale),
                      selectedColor: GamePalette.gold,
                    ),
                ],
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.battleSpeed')),
                subtitle: Text(
                  '${save.battleAnimationSpeed.toStringAsFixed(save.battleAnimationSpeed == 1 ? 0 : 1)}×',
                ),
              ),
              Wrap(
                spacing: 7,
                runSpacing: 4,
                children: [
                  for (final speed in const [1.0, 1.5, 2.0])
                    ChoiceChip(
                      label: Text(
                        '${speed.toStringAsFixed(speed == 1 ? 0 : 1)}×',
                      ),
                      selected: (save.battleAnimationSpeed - speed).abs() < .01,
                      onSelected: (_) => controller.updateSettings(
                        battleAnimationSpeed: speed,
                      ),
                      selectedColor: GamePalette.gold,
                    ),
                ],
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  gameText(context, 'ui.settings.skipBattleAnimations'),
                ),
                subtitle: Text(
                  gameText(
                    context,
                    'ui.settings.skipBattleAnimationsDescription',
                  ),
                  style: TextStyle(color: GamePalette.muted, fontSize: 11),
                ),
                value: save.skipBattleAnimations,
                activeThumbColor: GamePalette.gold,
                onChanged: (value) =>
                    controller.updateSettings(skipBattleAnimations: value),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(gameText(context, 'ui.settings.language')),
                subtitle: Text(
                  save.language == 'tr'
                      ? gameText(context, 'ui.settings.turkish')
                      : gameText(context, 'ui.settings.english'),
                  style: const TextStyle(
                    color: GamePalette.muted,
                    fontSize: 11,
                  ),
                ),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'tr', label: Text('TR')),
                    ButtonSegment(value: 'en', label: Text('EN')),
                  ],
                  selected: {save.language},
                  onSelectionChanged: (value) =>
                      controller.updateSettings(language: value.first),
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
              SectionHeading(
                localizedHeading(context, 'ui.settings.campaignSave'),
              ),
              const SizedBox(height: 7),
              Text(
                gameText(context, 'ui.settings.campaignSummary', {
                  'name': _heroDisplayName(context, save.heroName),
                  'level': save.level,
                  'count': save.completedMatches
                      .where(
                        (id) => !id.startsWith('M3') && !id.startsWith('M4'),
                      )
                      .length,
                }),
                style: const TextStyle(color: GamePalette.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GameButton(
                label: gameText(context, 'ui.settings.resetCampaign'),
                icon: Icons.delete_outline,
                secondary: true,
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(
                        gameText(context, 'ui.settings.deleteSaveTitle'),
                      ),
                      content: Text(
                        gameText(context, 'ui.settings.deleteSaveBody'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(gameText(context, 'ui.common.cancel')),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(gameText(context, 'ui.common.reset')),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await _runCampaignReset(context, controller);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GamePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(localizedHeading(context, 'ui.settings.about')),
              SizedBox(height: 9),
              Text(
                gameText(context, 'ui.settings.aboutBody'),
                style: TextStyle(
                  color: GamePalette.muted,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _openBattle(
  BuildContext context,
  GameController controller,
  FutureOr<void> Function() begin, {
  bool resumeFromCheckpoint = false,
}) async {
  if (!resumeFromCheckpoint) {
    try {
      await begin();
    } on Object catch (error) {
      if (!context.mounted) return;
      if (!error.toString().startsWith('Kayıt yazılamadı:')) {
        _showMessage(context, error.toString());
        return;
      }
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: GamePalette.panel,
          icon: const Icon(Icons.save_outlined, color: GamePalette.rust),
          title: Text(gameText(dialogContext, 'ui.error.saveTitle')),
          content: Text(gameText(dialogContext, 'ui.error.saveFailed')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(gameText(dialogContext, 'ui.common.cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(gameText(dialogContext, 'ui.common.retry')),
            ),
          ],
        ),
      );
      if (retry == true && context.mounted) {
        await _openBattle(context, controller, begin);
      }
      return;
    }
  }
  if (!context.mounted) return;
  final audio = GameAudioScope.maybeOf(context);
  final encounter = controller.activeEncounter;
  if (encounter != null) audio?.enterBattle(encounter);
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BattlePage(
          controller: controller,
          resumeFromCheckpoint: resumeFromCheckpoint,
        ),
      ),
    );
  } finally {
    if (audio != null) {
      audio.leaveBattle(
        save: controller.save,
        chapter: controller.campaignComplete
            ? 4
            : controller.nextEncounter.chapter,
        campaignComplete: controller.campaignComplete,
      );
    }
  }
}

Future<void> _showIntermissionChoice(
  BuildContext context,
  GameController controller,
) async {
  final decision = controller.pendingIntermissionDecision;
  if (decision == null) return;
  final chapter = ((decision.afterEncounterId - 1) ~/ 8) + 1;
  final audio = GameAudioScope.maybeOf(context);
  if (audio != null) unawaited(audio.playIntermissionStinger(chapter));

  final availableStats = Stat.values
      .where((stat) => controller.save.stats[stat] < 20)
      .toList();
  Stat? selectedStat = availableStats.isEmpty ? null : availableStats.first;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        backgroundColor: GamePalette.panel,
        icon: const Icon(Icons.campaign_outlined, color: GamePalette.gold),
        title: Text(
          gameText(dialogContext, 'ui.intermission.heading'),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _intermissionArt(context, decision, height: 150),
              ),
              const SizedBox(height: 12),
              Text(
                gameText(dialogContext, 'ui.intermission.body', {
                  'encounter': decision.afterEncounterId,
                }),
                textAlign: TextAlign.center,
              ),
              if (availableStats.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<Stat>(
                  initialValue: selectedStat,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: gameText(
                      dialogContext,
                      'ui.intermission.chooseStat',
                    ),
                  ),
                  items: availableStats
                      .map(
                        (stat) => DropdownMenuItem(
                          value: stat,
                          child: Text(
                            gameText(dialogContext, 'label.stat.${stat.name}'),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (stat) => setDialogState(() {
                    selectedStat = stat;
                  }),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: selectedStat == null
                      ? null
                      : () async {
                          final chosen = await controller
                              .chooseIntermissionReward(
                                decision.id,
                                reward: IntermissionReward.training,
                                stat: selectedStat,
                              );
                          if (chosen && dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  icon: const Icon(Icons.fitness_center),
                  label: Text(
                    gameText(dialogContext, 'ui.intermission.training', {
                      'stat': selectedStat == null
                          ? ''
                          : gameText(
                              dialogContext,
                              'label.stat.${selectedStat!.name}',
                            ),
                    }),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final chosen = await controller.chooseIntermissionReward(
                    decision.id,
                    reward: IntermissionReward.sponsorship,
                  );
                  if (chosen && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                icon: const Icon(Icons.monetization_on_outlined),
                label: Text(
                  gameText(dialogContext, 'ui.intermission.sponsorship', {
                    'gold': decision.sponsorshipGold,
                  }),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(gameText(dialogContext, 'ui.intermission.later')),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showStoryEvidence(
  BuildContext context,
  GameController controller,
  StoryEvidenceEntry evidence,
) async {
  final title = gameText(context, evidence.titleKey);
  final body = gameText(context, evidence.bodyKey);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: GamePalette.panel,
      icon: const Icon(Icons.find_in_page_outlined, color: GamePalette.rust),
      title: Text(title, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GamePalette.panelLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: StoryEvidenceCardArt(
                frame: evidence.frame,
                size: 220,
                semanticLabel: '$title. $body',
              ),
            ),
            const SizedBox(height: 14),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        FilledButton.icon(
          onPressed: () async {
            await controller.markStoryEvidenceSeen(evidence.id);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(gameText(dialogContext, 'ui.story.evidence.close')),
        ),
      ],
    ),
  );
}

Widget _intermissionArt(
  BuildContext context,
  IntermissionDecision decision, {
  required double height,
}) => SizedBox(
  height: height,
  width: double.infinity,
  child: Image.asset(
    decision.art,
    fit: BoxFit.cover,
    cacheWidth: 900,
    semanticLabel: gameText(context, 'ui.intermission.artDescription', {
      'encounter': decision.afterEncounterId,
    }),
    errorBuilder: (context, error, stackTrace) => const ColoredBox(
      color: GamePalette.panelLight,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: GamePalette.muted,
        ),
      ),
    ),
  ),
);

