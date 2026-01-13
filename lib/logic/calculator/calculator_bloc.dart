import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/logic/calculator/calculator_event.dart';
import 'package:compound_calculator/logic/calculator/calculator_state.dart';
import 'package:compound_calculator/logic/engine/calculation_engine.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc() : super(const CalculatorState()) {
    on<ProfileSelected>(_onProfileSelected);
    on<ModeChanged>(_onModeChanged);
    on<MassTypeChanged>(_onMassTypeChanged);
    on<MassInputChanged>(_onMassInputChanged);
    on<DryPercentageChanged>(_onDryPercentageChanged);
    on<BodyWeightChanged>(_onBodyWeightChanged);
    on<WeightUnitChanged>(_onWeightUnitChanged);
    on<TargetDoseChanged>(_onTargetDoseChanged);
    on<CalculatePressed>(_onCalculatePressed);
    on<ClearPressed>(_onClearPressed);
  }

  void _onProfileSelected(
    ProfileSelected event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        selectedProfile: event.profile,
        result: null,
        dosingRanges: null,
      ),
    );
  }

  void _onModeChanged(
    ModeChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        mode: event.mode,
        result: null,
        validationError: null,
      ),
    );
  }

  void _onMassTypeChanged(
    MassTypeChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        massType: event.massType,
        result: null,
      ),
    );
  }

  void _onMassInputChanged(
    MassInputChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        massInput: event.value,
        validationError: null,
      ),
    );
  }

  void _onDryPercentageChanged(
    DryPercentageChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        dryPercentage: event.percentage,
        result: null,
      ),
    );
  }

  void _onBodyWeightChanged(
    BodyWeightChanged event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.mode == CalculationMode.materialToDose) {
      emit(
        state.copyWith(
          bodyWeightForModeA: event.value,
          validationError: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          bodyWeightForModeB: event.value,
          validationError: null,
        ),
      );
    }
  }

  void _onWeightUnitChanged(
    WeightUnitChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        weightUnit: event.unit,
        result: null,
      ),
    );
  }

  void _onTargetDoseChanged(
    TargetDoseChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        targetDoseInput: event.value,
        validationError: null,
      ),
    );
  }

  void _onCalculatePressed(
    CalculatePressed event,
    Emitter<CalculatorState> emit,
  ) {
    if (state.selectedProfile == null) {
      emit(
        state.copyWith(
          validationError: 'Please select a profile first',
        ),
      );
      return;
    }

    emit(state.copyWith(isCalculating: true));

    try {
      if (state.mode == CalculationMode.materialToDose) {
        _calculateMaterialToDose(emit);
      } else {
        _calculateDoseToMaterial(emit);
      }
    } catch (e) {
      emit(
        state.copyWith(
          validationError: 'Calculation error: $e',
          isCalculating: false,
        ),
      );
    }
  }

  void _calculateMaterialToDose(Emitter<CalculatorState> emit) {
    final massG = state.massInputValue;
    final dryPercentage = state.dryPercentage;

    // Validate
    final error = CalculationEngine.validateMaterialInput(
      massG: massG,
      dryPercentage: state.massType == MassType.wet ? dryPercentage : null,
    );

    if (error != null) {
      emit(
        state.copyWith(
          validationError: error,
          isCalculating: false,
        ),
      );
      return;
    }

    // Calculate
    final result = CalculationEngine.calculateFromMaterial(
      profile: state.selectedProfile!,
      massG: massG!,
      massType: state.massType,
      dryPercentage: dryPercentage,
      bodyWeightKg: state.bodyWeightKg,
    );

    // Generate dosing ranges
    final dosingRanges =
        CalculationEngine.generateDosingRanges(state.selectedProfile!);

    emit(
      state.copyWith(
        result: result,
        dosingRanges: dosingRanges,
        validationError: null,
        isCalculating: false,
        showDisclaimer: true,
      ),
    );
  }

  void _calculateDoseToMaterial(Emitter<CalculatorState> emit) {
    final bodyWeightKg = state.bodyWeightKg;
    final targetMgPerKg = state.targetDoseValue;

    // Validate
    final error = CalculationEngine.validateDoseInput(
      bodyWeightKg: bodyWeightKg,
      targetMgPerKg: targetMgPerKg,
    );

    if (error != null) {
      emit(
        state.copyWith(
          validationError: error,
          isCalculating: false,
        ),
      );
      return;
    }

    // Calculate
    final result = CalculationEngine.calculateFromDose(
      profile: state.selectedProfile!,
      bodyWeightKg: bodyWeightKg!,
      targetMgPerKg: targetMgPerKg!,
      massType: state.massType,
      dryPercentage: state.dryPercentage,
    );

    // Generate dosing ranges
    final dosingRanges =
        CalculationEngine.generateDosingRanges(state.selectedProfile!);

    emit(
      state.copyWith(
        result: result,
        dosingRanges: dosingRanges,
        validationError: null,
        isCalculating: false,
        showDisclaimer: true,
      ),
    );
  }

  void _onClearPressed(
    ClearPressed event,
    Emitter<CalculatorState> emit,
  ) {
    emit(
      state.copyWith(
        massInput: null,
        bodyWeightForModeA: null,
        bodyWeightForModeB: null,
        targetDoseInput: null,
        result: null,
        dosingRanges: null,
        validationError: null,
      ),
    );
  }
}
