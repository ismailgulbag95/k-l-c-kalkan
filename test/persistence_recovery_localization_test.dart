import 'package:ash_circuit/game/l10n/game_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persistence retry messages are localized and actionable', () {
    const english = GameLocalizations('en');
    const turkish = GameLocalizations('tr');

    expect(english.text('ui.error.saveFailed'), contains('retry safely'));
    expect(
      english.text('ui.result.saveFailed'),
      contains('same result and rewards safely'),
    );
    expect(
      turkish.text('ui.settings.resetSaveFailed'),
      contains('Kampanya sıfırlanmadı'),
    );
    expect(
      english.text('ui.shop.error.saveFailed'),
      contains('action was not applied'),
    );
  });

  test('active hazards have English names and countdown text uses actions', () {
    const english = GameLocalizations('en');
    for (final encounterId in ['M15', 'M20', 'M22', 'M28']) {
      expect(
        english.text('content.encounter.$encounterId.hazard'),
        isNot('content.encounter.$encounterId.hazard'),
      );
    }

    expect(
      english.text('battle.log.hazardApproaching', {'turns': 1}),
      contains('1 action'),
    );
    expect(
      english.text('battle.log.hazardApproaching', {'turns': 2}),
      contains('2 actions'),
    );
  });
}
