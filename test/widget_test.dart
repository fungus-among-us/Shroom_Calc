// Basic smoke test for the Compound Calculator app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compound_calculator/data/repositories/profile_repository.dart';
import 'package:compound_calculator/data/sources/local_data_source.dart';
import 'package:compound_calculator/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Initialize test dependencies
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = LocalDataSource(prefs: prefs);
    final profileRepository =
        ProfileRepository(localDataSource: localDataSource);

    // Build the app - this is a smoke test to ensure it doesn't crash
    await tester.pumpWidget(
      CompoundCalculatorApp(profileRepository: profileRepository),
    );

    // If we get here without exceptions, the app built successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
