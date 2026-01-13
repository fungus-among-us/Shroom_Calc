import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/data/models/profile.dart';

part 'calculator_state.freezed.dart';

@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    // Selected profile
    Profile? selectedProfile,

    // Calculation mode
    @Default(CalculationMode.materialToDose) CalculationMode mode,

    // Common inputs
    @Default(MassType.dry) MassType massType,
    @Default(10.0) double dryPercentage,
    @Default(WeightUnit.kg) WeightUnit weightUnit,

    // Mode A inputs (material → dose)
    String? massInput,
    String? bodyWeightForModeA,

    // Mode B inputs (dose → material)
    String? bodyWeightForModeB,
    String? targetDoseInput,

    // Results
    CalculationResult? result,
    List<DosingRange>? dosingRanges,

    // Validation
    String? validationError,

    // UI state
    @Default(false) bool isCalculating,
    @Default(false) bool showDisclaimer,
  }) = _CalculatorState;

  const CalculatorState._();

  // Computed properties

  double? get massInputValue {
    if (massInput == null || massInput!.isEmpty) return null;
    return double.tryParse(massInput!);
  }

  double? get bodyWeightKg {
    final input = mode == CalculationMode.materialToDose
        ? bodyWeightForModeA
        : bodyWeightForModeB;
    if (input == null || input.isEmpty) return null;
    final value = double.tryParse(input);
    if (value == null) return null;
    return weightUnit.toKg(value);
  }

  double? get targetDoseValue {
    if (targetDoseInput == null || targetDoseInput!.isEmpty) return null;
    return double.tryParse(targetDoseInput!);
  }

  bool get canCalculate {
    if (selectedProfile == null) return false;

    if (mode == CalculationMode.materialToDose) {
      return massInputValue != null && massInputValue! > 0;
    } else {
      return bodyWeightKg != null &&
          bodyWeightKg! > 0 &&
          targetDoseValue != null &&
          targetDoseValue! > 0;
    }
  }
}
