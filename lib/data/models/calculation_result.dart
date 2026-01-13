import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculation_result.freezed.dart';

/// Represents the result of a compound calculation
@freezed
class CompoundResult with _$CompoundResult {
  const factory CompoundResult({
    required String compoundName,
    required double totalMg,
    double? mgPerKg, // Only present if body weight provided
  }) = _CompoundResult;
}

/// Calculation mode
enum CalculationMode {
  materialToDose, // User provides mass, we calculate mg
  doseToMaterial, // User provides target dose, we calculate required mass
}

/// Mass type
enum MassType {
  dry,
  wet,
}

/// Weight unit
enum WeightUnit {
  kg,
  lb;

  /// Convert to kg
  double toKg(double value) {
    switch (this) {
      case WeightUnit.kg:
        return value;
      case WeightUnit.lb:
        return value * 0.453592;
    }
  }

  /// Convert from kg
  double fromKg(double kg) {
    switch (this) {
      case WeightUnit.kg:
        return kg;
      case WeightUnit.lb:
        return kg / 0.453592;
    }
  }

  String get symbol {
    switch (this) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lb:
        return 'lb';
    }
  }
}

/// Full calculation result
@freezed
class CalculationResult with _$CalculationResult {
  const factory CalculationResult({
    required CalculationMode mode,
    required List<CompoundResult> compounds,
    // For mode A (material → dose)
    double? inputMassG,
    MassType? inputMassType,
    double? dryPercentage,
    double? effectiveDryMassG,
    // For mode B (dose → material)
    double? bodyWeightKg,
    double? targetMgPerKg,
    double? requiredDryG,
    double? requiredWetG,
  }) = _CalculationResult;

  const CalculationResult._();

  /// Get human-readable summary
  String get summary {
    switch (mode) {
      case CalculationMode.materialToDose:
        final mass = inputMassType == MassType.dry
            ? '${effectiveDryMassG?.toStringAsFixed(2)}g dry'
            : '${inputMassG?.toStringAsFixed(2)}g wet (${dryPercentage?.toStringAsFixed(1)}% dry = ${effectiveDryMassG?.toStringAsFixed(2)}g)';
        return 'From $mass';
      case CalculationMode.doseToMaterial:
        return 'Target: ${targetMgPerKg?.toStringAsFixed(2)} mg/kg for ${bodyWeightKg?.toStringAsFixed(1)} kg';
    }
  }
}

/// Dosing reference range
@freezed
class DosingRange with _$DosingRange {
  const factory DosingRange({
    required String label,
    required String description,
    required List<DosingPoint> points,
  }) = _DosingRange;
}

/// Single point in a dosing range
@freezed
class DosingPoint with _$DosingPoint {
  const factory DosingPoint({
    required double dryGrams,
    required List<CompoundResult> compounds,
  }) = _DosingPoint;
}
