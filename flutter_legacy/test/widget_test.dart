import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamemaster_hub/app.dart';

void main() {
  testWidgets('GameMasterHubApp launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GameMasterHubApp());

    // Vérifie qu’un widget MaterialApp est présent
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
