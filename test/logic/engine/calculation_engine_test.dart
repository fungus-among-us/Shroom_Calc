import 'package:flutter_test/flutter_test.dart';
import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/data/models/profile.dart';
import 'package:compound_calculator/data/models/compound.dart';
import 'package:compound_calculator/logic/engine/calculation_engine.dart';

void main() {
  group('CalculationEngine - Material to Dose', () {
    const testProfile = Profile(
      label: 'Test Strain',
      compounds: [
        Compound(name: 'Psilocybin', mgPerG: 10.0),
        Compound(name: 'Psilocin', mgPerG: 1.0),
      ],
    );

    test('calculates dry mass correctly', () {
      final result = CalculationEngine.calculateFromMaterial(
        profile: testProfile,
        massG: 2.0,
        massType: MassType.dry,
      );

      expect(result.mode, CalculationMode.materialToDose);
      expect(result.effectiveDryMassG, 2.0);
      expect(result.compounds.length, 2);
      expect(result.compounds[0].totalMg, 20.0); // 10.0 mg/g * 2g
      expect(result.compounds[1].totalMg, 2.0); // 1.0 mg/g * 2g
    });

    test('calculates wet mass correctly', () {
      final result = CalculationEngine.calculateFromMaterial(
        profile: testProfile,
        massG: 10.0,
        massType: MassType.wet,
        dryPercentage: 10.0,
      );

      expect(result.effectiveDryMassG, 1.0); // 10g * 10% = 1g dry
      expect(result.compounds[0].totalMg, 10.0); // 10.0 mg/g * 1g
      expect(result.compounds[1].totalMg, 1.0); // 1.0 mg/g * 1g
    });

    test('calculates mg/kg when body weight provided', () {
      final result = CalculationEngine.calculateFromMaterial(
        profile: testProfile,
        massG: 2.0,
        massType: MassType.dry,
        bodyWeightKg: 70.0,
      );

      expect(result.compounds[0].mgPerKg, closeTo(0.286, 0.001)); // 20mg / 70kg
      expect(result.compounds[1].mgPerKg, closeTo(0.029, 0.001)); // 2mg / 70kg
    });

    test('handles zero dry percentage edge case', () {
      final result = CalculationEngine.calculateFromMaterial(
        profile: testProfile,
        massG: 10.0,
        massType: MassType.wet,
        dryPercentage: 0.0,
      );

      expect(result.effectiveDryMassG, 0.0);
      expect(result.compounds[0].totalMg, 0.0);
    });

    test('handles fractional masses', () {
      final result = CalculationEngine.calculateFromMaterial(
        profile: testProfile,
        massG: 0.5,
        massType: MassType.dry,
      );

      expect(result.compounds[0].totalMg, 5.0); // 10.0 mg/g * 0.5g
      expect(result.compounds[1].totalMg, 0.5); // 1.0 mg/g * 0.5g
    });
  });

  group('CalculationEngine - Dose to Material', () {
    const testProfile = Profile(
      label: 'Test Strain',
      compounds: [
        Compound(name: 'Psilocybin', mgPerG: 10.0),
        Compound(name: 'Psilocin', mgPerG: 1.0),
      ],
    );

    test('calculates required dry mass correctly', () {
      final result = CalculationEngine.calculateFromDose(
        profile: testProfile,
        bodyWeightKg: 70.0,
        targetMgPerKg: 0.25,
        massType: MassType.dry,
      );

      expect(result.mode, CalculationMode.doseToMaterial);
      // Target: 70kg * 0.25 mg/kg = 17.5mg
      // Required: 17.5mg / 10.0 mg/g = 1.75g
      expect(result.requiredDryG, 1.75);
      expect(result.requiredWetG, isNull);
    });

    test('calculates required wet mass correctly', () {
      final result = CalculationEngine.calculateFromDose(
        profile: testProfile,
        bodyWeightKg: 70.0,
        targetMgPerKg: 0.25,
        massType: MassType.wet,
        dryPercentage: 10.0,
      );

      // Required dry: 1.75g
      // Required wet: 1.75g / 0.10 = 17.5g
      expect(result.requiredDryG, 1.75);
      expect(result.requiredWetG, 17.5);
    });

    test('calculates actual compound amounts', () {
      final result = CalculationEngine.calculateFromDose(
        profile: testProfile,
        bodyWeightKg: 70.0,
        targetMgPerKg: 0.25,
        massType: MassType.dry,
      );

      // Primary compound (Psilocybin) should match target
      expect(result.compounds[0].totalMg, 17.5);
      expect(result.compounds[0].mgPerKg, closeTo(0.25, 0.001));

      // Secondary compound scales proportionally
      expect(result.compounds[1].totalMg, 1.75);
      expect(result.compounds[1].mgPerKg, closeTo(0.025, 0.001));
    });

    test('uses primary compound for calculation', () {
      const profileWithDifferentPrimary = Profile(
        label: 'Different Primary',
        compounds: [
          Compound(name: 'Compound A', mgPerG: 5.0),
          Compound(name: 'Compound B', mgPerG: 20.0), // Highest
        ],
      );

      final result = CalculationEngine.calculateFromDose(
        profile: profileWithDifferentPrimary,
        bodyWeightKg: 70.0,
        targetMgPerKg: 0.25,
        massType: MassType.dry,
      );

      // Target: 17.5mg
      // Should use Compound B (20.0 mg/g): 17.5 / 20.0 = 0.875g
      expect(result.requiredDryG, closeTo(0.875, 0.001));
    });
  });

  group('CalculationEngine - Dosing Ranges', () {
    const testProfile = Profile(
      label: 'Test Strain',
      compounds: [
        Compound(name: 'Psilocybin', mgPerG: 10.0),
        Compound(name: 'Psilocin', mgPerG: 1.0),
      ],
    );

    test('generates three dosing ranges', () {
      final ranges = CalculationEngine.generateDosingRanges(testProfile);

      expect(ranges.length, 3);
      expect(ranges[0].label, 'Microdose Range');
      expect(ranges[1].label, 'Regular Dose');
      expect(ranges[2].label, 'Heroic Dose');
    });

    test('microdose range has correct values', () {
      final ranges = CalculationEngine.generateDosingRanges(testProfile);
      final microdose = ranges[0];

      expect(microdose.points.length, 3); // 0.1, 0.2, 0.3g
      expect(microdose.points[0].dryGrams, 0.1);
      expect(microdose.points[0].compounds[0].totalMg, 1.0); // 10.0 * 0.1
      expect(microdose.points[2].dryGrams, 0.3);
      expect(microdose.points[2].compounds[0].totalMg, 3.0); // 10.0 * 0.3
    });

    test('regular dose range has correct values', () {
      final ranges = CalculationEngine.generateDosingRanges(testProfile);
      final regular = ranges[1];

      expect(regular.points.length, 3); // 1.0, 1.75, 2.5g
      expect(regular.points[0].dryGrams, 1.0);
      expect(regular.points[0].compounds[0].totalMg, 10.0);
      expect(regular.points[2].dryGrams, 2.5);
      expect(regular.points[2].compounds[0].totalMg, 25.0);
    });

    test('heroic dose range has correct values', () {
      final ranges = CalculationEngine.generateDosingRanges(testProfile);
      final heroic = ranges[2];

      expect(heroic.points.length, 2); // 5.0, 7.0g
      expect(heroic.points[0].dryGrams, 5.0);
      expect(heroic.points[0].compounds[0].totalMg, 50.0);
      expect(heroic.points[1].dryGrams, 7.0);
      expect(heroic.points[1].compounds[0].totalMg, 70.0);
    });
  });

  group('CalculationEngine - Validation', () {
    test('validates material input - negative mass', () {
      final error = CalculationEngine.validateMaterialInput(massG: -1.0);
      expect(error, isNotNull);
      expect(error, contains('greater than 0'));
    });

    test('validates material input - zero mass', () {
      final error = CalculationEngine.validateMaterialInput(massG: 0.0);
      expect(error, isNotNull);
    });

    test('validates material input - extremely high mass', () {
      final error = CalculationEngine.validateMaterialInput(massG: 2000.0);
      expect(error, isNotNull);
      expect(error, contains('unusually high'));
    });

    test('validates material input - valid mass', () {
      final error = CalculationEngine.validateMaterialInput(massG: 2.5);
      expect(error, isNull);
    });

    test('validates dose input - negative body weight', () {
      final error = CalculationEngine.validateDoseInput(
        bodyWeightKg: -50.0,
        targetMgPerKg: 0.25,
      );
      expect(error, isNotNull);
    });

    test('validates dose input - negative target dose', () {
      final error = CalculationEngine.validateDoseInput(
        bodyWeightKg: 70.0,
        targetMgPerKg: -0.25,
      );
      expect(error, isNotNull);
    });

    test('validates dose input - extremely high values', () {
      final error = CalculationEngine.validateDoseInput(
        bodyWeightKg: 1000.0,
        targetMgPerKg: 20.0,
      );
      expect(error, isNotNull);
    });

    test('validates dose input - valid values', () {
      final error = CalculationEngine.validateDoseInput(
        bodyWeightKg: 70.0,
        targetMgPerKg: 0.25,
      );
      expect(error, isNull);
    });
  });

  group('Profile - Primary Compound', () {
    test('identifies highest concentration compound', () {
      const profile = Profile(
        label: 'Test',
        compounds: [
          Compound(name: 'A', mgPerG: 5.0),
          Compound(name: 'B', mgPerG: 12.0),
          Compound(name: 'C', mgPerG: 3.0),
        ],
      );

      final primary = profile.primaryCompound;
      expect(primary, isNotNull);
      expect(primary!.name, 'B');
      expect(primary.mgPerG, 12.0);
    });

    test('returns null for empty compounds', () {
      const profile = Profile(
        label: 'Empty',
        compounds: [],
      );

      expect(profile.primaryCompound, isNull);
    });
  });

  group('WeightUnit Conversion', () {
    test('converts kg to lb', () {
      const kg = 70.0;
      final lb = WeightUnit.lb.fromKg(kg);
      expect(lb, closeTo(154.32, 0.01));
    });

    test('converts lb to kg', () {
      const lb = 154.32;
      final kg = WeightUnit.lb.toKg(lb);
      expect(kg, closeTo(70.0, 0.01));
    });

    test('kg identity conversion', () {
      const kg = 70.0;
      expect(WeightUnit.kg.toKg(kg), kg);
      expect(WeightUnit.kg.fromKg(kg), kg);
    });
  });
}
