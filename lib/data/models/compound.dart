// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'compound.freezed.dart';
part 'compound.g.dart';

/// Represents a single compound with its concentration
@freezed
class Compound with _$Compound {
  const factory Compound({
    required String name,
    @JsonKey(name: 'mg_per_g') required double mgPerG,
  }) = _Compound;

  factory Compound.fromJson(Map<String, dynamic> json) =>
      _$CompoundFromJson(json);

  // Support alternative JSON field names
  static Compound fromJsonFlexible(Map<String, dynamic> json) {
    // Try different field names for concentration
    final name = json['name'] as String;
    final double mgPerG;

    if (json.containsKey('mg_per_g')) {
      mgPerG = (json['mg_per_g'] as num).toDouble();
    } else if (json.containsKey('concentration_mg_per_g')) {
      mgPerG = (json['concentration_mg_per_g'] as num).toDouble();
    } else if (json.containsKey('mg_per_g_dry')) {
      mgPerG = (json['mg_per_g_dry'] as num).toDouble();
    } else {
      throw ArgumentError(
        'No valid concentration field found in compound JSON',
      );
    }

    return Compound(name: name, mgPerG: mgPerG);
  }
}
