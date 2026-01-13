import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/data/models/profile.dart';

part 'calculator_event.freezed.dart';

@freezed
class CalculatorEvent with _$CalculatorEvent {
  // Profile selection
  const factory CalculatorEvent.profileSelected(Profile profile) =
      ProfileSelected;

  // Mode switching
  const factory CalculatorEvent.modeChanged(CalculationMode mode) = ModeChanged;

  // Mass type toggle
  const factory CalculatorEvent.massTypeChanged(MassType massType) =
      MassTypeChanged;

  // Input changes
  const factory CalculatorEvent.massInputChanged(String value) =
      MassInputChanged;
  const factory CalculatorEvent.dryPercentageChanged(double percentage) =
      DryPercentageChanged;
  const factory CalculatorEvent.bodyWeightChanged(String value) =
      BodyWeightChanged;
  const factory CalculatorEvent.weightUnitChanged(WeightUnit unit) =
      WeightUnitChanged;
  const factory CalculatorEvent.targetDoseChanged(String value) =
      TargetDoseChanged;

  // Calculation trigger
  const factory CalculatorEvent.calculatePressed() = CalculatePressed;

  // Clear all inputs
  const factory CalculatorEvent.clearPressed() = ClearPressed;
}
