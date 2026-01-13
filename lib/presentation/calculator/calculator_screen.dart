import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/data/models/profile.dart';
import 'package:compound_calculator/logic/calculator/calculator_bloc.dart';
import 'package:compound_calculator/logic/calculator/calculator_event.dart';
import 'package:compound_calculator/logic/calculator/calculator_state.dart';
import 'package:compound_calculator/presentation/calculator/widgets/dose_input_section.dart';
import 'package:compound_calculator/presentation/calculator/widgets/mass_input_section.dart';
import 'package:compound_calculator/presentation/calculator/widgets/profile_selector.dart';
import 'package:compound_calculator/presentation/calculator/widgets/results_display.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({
    super.key,
    required this.profiles,
  });
  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<CalculatorBloc, CalculatorState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // Header with profile selector
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B7355), // Sage green
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Compound Analysis',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProfileSelector(
                          profiles: profiles,
                          selectedProfile: state.selectedProfile,
                          onProfileSelected: (profile) {
                            context
                                .read<CalculatorBloc>()
                                .add(CalculatorEvent.profileSelected(profile));
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Mode toggle
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: SegmentedButton<CalculationMode>(
                        segments: const [
                          ButtonSegment(
                            value: CalculationMode.materialToDose,
                            label: Text('By Weight'),
                            icon: Icon(Icons.scale_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: CalculationMode.doseToMaterial,
                            label: Text('Target Dose'),
                            icon: Icon(Icons.my_location_outlined, size: 18),
                          ),
                        ],
                        selected: {state.mode},
                        onSelectionChanged: (Set<CalculationMode> selection) {
                          context.read<CalculatorBloc>().add(
                                CalculatorEvent.modeChanged(selection.first),
                              );
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF8B7355);
                              }
                              return Colors.transparent;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return colorScheme.onSurface;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Input section based on mode
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: state.mode == CalculationMode.materialToDose
                        ? MassInputSection(state: state)
                        : DoseInputSection(state: state),
                  ),
                ),

                // Calculate button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (state.validationError != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: colorScheme.onErrorContainer,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.validationError!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: state.canCalculate
                                    ? () {
                                        context.read<CalculatorBloc>().add(
                                              const CalculatorEvent
                                                  .calculatePressed(),
                                            );
                                      }
                                    : null,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Calculate'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B7355),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {
                                context
                                    .read<CalculatorBloc>()
                                    .add(const CalculatorEvent.clearPressed());
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                              ),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Results section
                if (state.result != null)
                  SliverToBoxAdapter(
                    child: ResultsDisplay(
                      result: state.result!,
                      dosingRanges: state.dosingRanges ?? [],
                      showDisclaimer: state.showDisclaimer,
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
