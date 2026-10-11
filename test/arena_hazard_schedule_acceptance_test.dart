import 'package:ash_circuit/game/data/content.dart';
import 'package:flutter_test/flutter_test.dart';

const _warningTurnsByEncounterId = <int, int>{
  4: 1,
  7: 2,
  9: 1,
  13: 2,
  14: 2,
  15: 2,
  19: 2,
  20: 1,
  22: 1,
  23: 1,
  28: 1,
};

const _repeatingEncounterIds = <int>{7, 9, 13, 14, 15, 19, 22, 23, 28};

void main() {
  group('arena hazard schedule acceptance', () {
    test('matches every documented encounter and no undocumented schedule', () {
      final encountersById = {
        for (final encounter in mainEncounters) encounter.id: encounter,
      };
      final scheduledEncounterIds = mainEncounters
          .where((encounter) => encounter.hazardSchedule != null)
          .map((encounter) => encounter.id)
          .toSet();

      expect(encountersById.keys, containsAll(_warningTurnsByEncounterId.keys));
      expect(scheduledEncounterIds, _warningTurnsByEncounterId.keys.toSet());

      for (final encounter in mainEncounters) {
        final expectedWarningTurns = _warningTurnsByEncounterId[encounter.id];
        if (expectedWarningTurns == null) {
          expect(
            encounter.hazardSchedule,
            isNull,
            reason:
                'Encounter M${encounter.id.toString().padLeft(2, '0')} is not in §13.10.',
          );
          continue;
        }

        final schedule = encounter.hazardSchedule;
        expect(
          encounter.hazard,
          isNotEmpty,
          reason: 'encounter ${encounter.id}',
        );
        expect(schedule, isNotNull, reason: 'encounter ${encounter.id}');
        expect(schedule!.warningTurns, expectedWarningTurns);
        expect(schedule.firstImpactTurn, 3);
        if (_repeatingEncounterIds.contains(encounter.id)) {
          expect(
            schedule.repeatEveryTurns,
            4,
            reason: 'encounter ${encounter.id}',
          );
        } else {
          expect(
            schedule.repeatEveryTurns,
            isNull,
            reason: 'encounter ${encounter.id}',
          );
        }
      }
    });

    test('first impact and countdown match the documented warning window', () {
      for (final entry in _warningTurnsByEncounterId.entries) {
        final schedule = encountersByIdForTest(entry.key).hazardSchedule!;
        final warningTurns = entry.value;

        expect(
          schedule.impactsAfterTurn(2),
          isFalse,
          reason: 'encounter ${entry.key}',
        );
        expect(
          schedule.impactsAfterTurn(3),
          isTrue,
          reason: 'encounter ${entry.key}',
        );
        expect(
          schedule.warningTurnsRemainingOn(2),
          warningTurns == 2 ? 2 : null,
          reason: 'encounter ${entry.key}, action 2',
        );
        expect(
          schedule.warningTurnsRemainingOn(3),
          1,
          reason: 'encounter ${entry.key}, action 3',
        );
      }
    });

    test('repeat hazards warn and impact again on actions 7 and 11', () {
      for (final encounterId in _repeatingEncounterIds) {
        final schedule = encountersByIdForTest(encounterId).hazardSchedule!;
        final warningTurns = _warningTurnsByEncounterId[encounterId]!;

        for (final impactAction in [7, 11]) {
          expect(
            schedule.impactsAfterTurn(impactAction - 1),
            isFalse,
            reason: 'encounter $encounterId before action $impactAction',
          );
          expect(
            schedule.impactsAfterTurn(impactAction),
            isTrue,
            reason: 'encounter $encounterId at action $impactAction',
          );
          expect(
            schedule.warningTurnsRemainingOn(impactAction - 1),
            warningTurns == 2 ? 2 : null,
            reason: 'encounter $encounterId, action ${impactAction - 1}',
          );
          expect(
            schedule.warningTurnsRemainingOn(impactAction),
            1,
            reason: 'encounter $encounterId, action $impactAction',
          );
        }
      }
    });

    test('M04 and M20 remain one-shot and do not warn again', () {
      for (final encounterId in [4, 20]) {
        final schedule = encountersByIdForTest(encounterId).hazardSchedule!;

        expect(
          schedule.impactsAfterTurn(7),
          isFalse,
          reason: 'encounter $encounterId',
        );
        expect(
          schedule.impactsAfterTurn(11),
          isFalse,
          reason: 'encounter $encounterId',
        );
        expect(
          schedule.warningTurnsRemainingOn(4),
          isNull,
          reason: 'encounter $encounterId',
        );
        expect(
          schedule.warningTurnsRemainingOn(7),
          isNull,
          reason: 'encounter $encounterId',
        );
        expect(
          schedule.warningTurnsRemainingOn(11),
          isNull,
          reason: 'encounter $encounterId',
        );
      }
    });
  });
}

Encounter encountersByIdForTest(int encounterId) =>
    mainEncounters.singleWhere((encounter) => encounter.id == encounterId);
