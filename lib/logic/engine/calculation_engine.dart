import 'package:compound_calculator/core/constants.dart';
import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/data/models/profile.dart';

/// Core calculation engine for compound dosing
class CalculationEngine {
  /// Calculate total mg from material mass (Mode A)
  ///
  /// [profile] - The selected mushroom profile
  /// [massG] - Input mass in grams
  /// [massType] - Dry or wet
  /// [dryPercentage] - Dry matter percentage (0-100), only used if wet
  /// [bodyWeightKg] - Optional body weight for mg/kg calculation
  static CalculationResult calculateFromMaterial({
    required Profile profile,
    required double massG,
    required MassType massType,
    double dryPercentage = AppConstants.defaultDryPercentage,
    double? bodyWeightKg,
  }) {
    // Step 1: Calculate effective dry mass
    final double effectiveDryMassG;
    if (massType == MassType.wet) {
      effectiveDryMassG = massG * (dryPercentage / 100.0);
    } else {
      effectiveDryMassG = massG;
    }

    // Step 2: Calculate mg for each compound
    final List<CompoundResult> compounds = [];
    for (final compound in profile.compounds) {
      final totalMg = compound.mgPerG * effectiveDryMassG;
      final mgPerKg = bodyWeightKg != null ? totalMg / bodyWeightKg : null;

      compounds.add(
        CompoundResult(
          compoundName: compound.name,
          totalMg: totalMg,
          mgPerKg: mgPerKg,
        ),
      );
    }

    return CalculationResult(
      mode: CalculationMode.materialToDose,
      compounds: compounds,
      inputMassG: massG,
      inputMassType: massType,
      dryPercentage: massType == MassType.wet ? dryPercentage : null,
      effectiveDryMassG: effectiveDryMassG,
    );
  }

  /// Calculate required material from target dose (Mode B)
  ///
  /// [profile] - The selected mushroom profile
  /// [bodyWeightKg] - Body weight in kg
  /// [targetMgPerKg] - Target dose in mg/kg
  /// [massType] - Desired output (dry or wet)
  /// [dryPercentage] - Dry matter percentage (0-100), only used if wet output
  static CalculationResult calculateFromDose({
    required Profile profile,
    required double bodyWeightKg,
    required double targetMgPerKg,
    required MassType massType,
    double dryPercentage = AppConstants.defaultDryPercentage,
  }) {
    // Step 1: Calculate target total mg
    final targetTotalMg = bodyWeightKg * targetMgPerKg;

    // Step 2: Find primary compound (highest concentration)
    final primaryCompound = profile.primaryCompound;
    if (primaryCompound == null) {
      throw ArgumentError('Profile has no compounds');
    }

    // Step 3: Calculate required dry mass based on primary compound
    final requiredDryG = targetTotalMg / primaryCompound.mgPerG;

    // Step 4: Calculate wet mass if needed
    final double? requiredWetG;
    if (massType == MassType.wet) {
      requiredWetG = requiredDryG / (dryPercentage / 100.0);
    } else {
      requiredWetG = null;
    }

    // Step 5: Calculate actual mg for all compounds at this mass
    final List<CompoundResult> compounds = [];
    for (final compound in profile.compounds) {
      final totalMg = compound.mgPerG * requiredDryG;
      final mgPerKg = totalMg / bodyWeightKg;

      compounds.add(
        CompoundResult(
          compoundName: compound.name,
          totalMg: totalMg,
          mgPerKg: mgPerKg,
        ),
      );
    }

    return CalculationResult(
      mode: CalculationMode.doseToMaterial,
      compounds: compounds,
      bodyWeightKg: bodyWeightKg,
      targetMgPerKg: targetMgPerKg,
      requiredDryG: requiredDryG,
      requiredWetG: requiredWetG,
    );
  }

  /// Generate dosing reference ranges for a profile
  ///
  /// Returns three ranges: microdose, regular, heroic
  static List<DosingRange> generateDosingRanges(Profile profile) {
    return [
      _createDosingRange(
        label: 'Microdose Range',
        description: '0.1-0.3g dry',
        doses: AppConstants.microdoseRange,
        profile: profile,
      ),
      _createDosingRange(
        label: 'Regular Dose',
        description: '1.0-2.5g dry',
        doses: AppConstants.regularDoseRange,
        profile: profile,
      ),
      _createDosingRange(
        label: 'Heroic Dose',
        description: '5.0g+ dry',
        doses: AppConstants.heroicDoseRange,
        profile: profile,
      ),
    ];
  }

  static DosingRange _createDosingRange({
    required String label,
    required String description,
    required List<double> doses,
    required Profile profile,
  }) {
    final points = doses.map((dryG) {
      final compounds = profile.compounds.map((compound) {
        final totalMg = compound.mgPerG * dryG;
        return CompoundResult(
          compoundName: compound.name,
          totalMg: totalMg,
        );
      }).toList();

      return DosingPoint(
        dryGrams: dryG,
        compounds: compounds,
      );
    }).toList();

    return DosingRange(
      label: label,
      description: description,
      points: points,
    );
  }

  /// Validate input parameters
  static String? validateMaterialInput({
    required double? massG,
    double? dryPercentage,
  }) {
    if (massG == null || massG <= 0) {
      return 'Mass must be greater than 0';
    }
    if (massG > AppConstants.maxReasonableMass) {
      return 'Mass seems unusually high (>${AppConstants.maxReasonableMass}g)';
    }
    if (dryPercentage != null) {
      if (dryPercentage < AppConstants.minDryPercentage ||
          dryPercentage > AppConstants.maxDryPercentage) {
        return 'Dry percentage must be between ${AppConstants.minDryPercentage}% and ${AppConstants.maxDryPercentage}%';
      }
    }
    return null;
  }

  static String? validateDoseInput({
    required double? bodyWeightKg,
    required double? targetMgPerKg,
  }) {
    if (bodyWeightKg == null || bodyWeightKg <= 0) {
      return 'Body weight must be greater than 0';
    }
    if (bodyWeightKg > AppConstants.maxReasonableBodyWeight) {
      return 'Body weight seems unusually high (>${AppConstants.maxReasonableBodyWeight}kg)';
    }
    if (targetMgPerKg == null || targetMgPerKg <= 0) {
      return 'Target dose must be greater than 0';
    }
    if (targetMgPerKg > AppConstants.maxReasonableDose) {
      return 'Target dose seems unusually high (>${AppConstants.maxReasonableDose}mg/kg)';
    }
    return null;
  }
}
