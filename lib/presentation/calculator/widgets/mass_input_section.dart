import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/logic/calculator/calculator_bloc.dart';
import 'package:compound_calculator/logic/calculator/calculator_event.dart';
import 'package:compound_calculator/logic/calculator/calculator_state.dart';

class MassInputSection extends StatelessWidget {
  const MassInputSection({
    super.key,
    required this.state,
  });
  final CalculatorState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355).withOpacity( 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'INPUT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dry/Wet toggle
          SegmentedButton<MassType>(
            segments: const [
              ButtonSegment(
                value: MassType.dry,
                label: Text('Dry'),
                icon: Icon(Icons.thermostat_outlined, size: 16),
              ),
              ButtonSegment(
                value: MassType.wet,
                label: Text('Wet'),
                icon: Icon(Icons.water_drop_outlined, size: 16),
              ),
            ],
            selected: {state.massType},
            onSelectionChanged: (Set<MassType> selection) {
              context
                  .read<CalculatorBloc>()
                  .add(CalculatorEvent.massTypeChanged(selection.first));
            },
          ),

          const SizedBox(height: 16),

          // Mass input
          TextField(
            decoration: const InputDecoration(
              labelText: 'Mass',
              suffixText: 'g',
              helperText: 'Material mass in grams',
              prefixIcon: Icon(Icons.scale_outlined),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) {
              context
                  .read<CalculatorBloc>()
                  .add(CalculatorEvent.massInputChanged(value));
            },
            controller: TextEditingController(text: state.massInput)
              ..selection = TextSelection.collapsed(
                offset: state.massInput?.length ?? 0,
              ),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Dry percentage slider (only for wet)
          if (state.massType == MassType.wet) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dry Matter Content',
                        style: theme.textTheme.labelLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF8B7355).withOpacity( 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${state.dryPercentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8B7355),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: state.dryPercentage,
                    min: 5.0,
                    max: 25.0,
                    divisions: 40,
                    activeColor: const Color(0xFF8B7355),
                    onChanged: (value) {
                      context
                          .read<CalculatorBloc>()
                          .add(CalculatorEvent.dryPercentageChanged(value));
                    },
                  ),
                  Text(
                    'Typical range: 5-25% for fresh material',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 20),

          // Optional body weight for mg/kg calculation
          Text(
            'Body Weight (Optional)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Body Weight',
                    helperText: 'For mg/kg calculation',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (value) {
                    context
                        .read<CalculatorBloc>()
                        .add(CalculatorEvent.bodyWeightChanged(value));
                  },
                  controller:
                      TextEditingController(text: state.bodyWeightForModeA)
                        ..selection = TextSelection.collapsed(
                          offset: state.bodyWeightForModeA?.length ?? 0,
                        ),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                  ],
                  selected: {state.weightUnit},
                  onSelectionChanged: (Set<WeightUnit> selection) {
                    context.read<CalculatorBloc>().add(
                          CalculatorEvent.weightUnitChanged(selection.first),
                        );
                  },
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
