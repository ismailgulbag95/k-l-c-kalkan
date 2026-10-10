import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_circuit/game/data/content.dart';
import 'package:ash_circuit/game/ui/contract_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every contract has one bundled illustration', () async {
    final contractIds = contracts.map((contract) => contract.id).toList();

    expect(contractIds, hasLength(16));
    expect(contractIds.toSet(), hasLength(16));
    expect(contractArtById.keys.toSet(), contractIds.toSet());

    final assetPaths = contractIds
        .map(contractArtAssetForId)
        .whereType<String>()
        .toList();
    expect(assetPaths, hasLength(16));
    expect(assetPaths.toSet(), hasLength(16));

    for (final assetPath in assetPaths) {
      final asset = await rootBundle.load(assetPath);
      expect(asset.lengthInBytes, greaterThan(0), reason: assetPath);
    }
  });
}
