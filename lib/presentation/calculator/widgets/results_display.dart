import 'package:flutter/material.dart';

import 'package:compound_calculator/core/constants.dart';
import 'package:compound_calculator/data/models/calculation_result.dart';

class ResultsDisplay extends StatefulWidget {
  const ResultsDisplay({
    super.key,
    required this.result,
    required this.dosingRanges,
    this.showDisclaimer = true,
  });
  final CalculationResult result;
  final List<DosingRange> dosingRanges;
  final bool showDisclaimer;

  @override
  State<ResultsDisplay> createState() => _ResultsDisplayState();
}

class _ResultsDisplayState extends State<ResultsDisplay> {
  bool _disclaimerDismissed = false;
  final Set<int> _expandedRanges = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header
          Row(
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7355),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Analysis Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mode B: Required material (hero card)
          if (widget.result.mode == CalculationMode.doseToMaterial) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B7355), Color(0xFF5A7A68)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B7355).withOpacity( 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUIRED MATERIAL',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withOpacity( 0.9),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.result.inputMassType == MassType.dry)
                    Text(
                      '${widget.result.requiredDryG?.toStringAsFixed(2)} g',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        letterSpacing: -1,
                      ),
                    )
                  else ...[
                    Text(
                      '${widget.result.requiredWetG?.toStringAsFixed(2)} g wet',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'or ${widget.result.requiredDryG?.toStringAsFixed(2)} g dry (${widget.result.dryPercentage?.toStringAsFixed(1)}% content)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity( 0.9),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Compound breakdown
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < widget.result.compounds.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: colorScheme.outlineVariant),
                  _buildCompoundCard(
                    context,
                    widget.result.compounds[i],
                    widget.result.mode == CalculationMode.doseToMaterial,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Dosing reference ranges
          Text(
            'Dosing Reference',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          ...widget.dosingRanges.asMap().entries.map((entry) {
            final index = entry.key;
            final range = entry.value;
            return _buildDosingRangeAccordion(
              context,
              range,
              index,
              _expandedRanges.contains(index),
              () {
                setState(() {
                  if (_expandedRanges.contains(index)) {
                    _expandedRanges.remove(index);
                  } else {
                    _expandedRanges.add(index);
                  }
                });
              },
            );
          }),

          // Disclaimer at bottom
          if (widget.showDisclaimer && !_disclaimerDismissed) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E6), // Warm amber
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFB74D),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE65100),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppConstants.batchVariationWarning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE65100),
                        height: 1.4,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() => _disclaimerDismissed = true);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: const Color(0xFFE65100),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompoundCard(
    BuildContext context,
    CompoundResult compound,
    bool showTarget,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            compound.compoundName.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF8B7355),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                compound.totalMg.toStringAsFixed(2),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'mg total',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (compound.mgPerKg != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${compound.mgPerKg!.toStringAsFixed(3)} mg/kg',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showTarget) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF8B7355),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDosingRangeAccordion(
    BuildContext context,
    DosingRange range,
    int index,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isExpanded ? const Color(0xFF8B7355) : colorScheme.outlineVariant,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            range.label.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: const Color(0xFF8B7355),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            range.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: const Color(0xFF8B7355),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                  ...range.points.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'At ${point.dryGrams.toStringAsFixed(1)}g dry:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: point.compounds.map((compound) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${compound.compoundName}: ${compound.totalMg.toStringAsFixed(2)}mg',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
