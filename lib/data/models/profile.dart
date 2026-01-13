import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:compound_calculator/data/models/compound.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Represents a mushroom strain profile with its compounds
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String label,
    required List<Compound> compounds,
  }) = _Profile;

  const Profile._();

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  // Flexible parsing that handles alternative field names
  static Profile fromJsonFlexible(Map<String, dynamic> json) {
    final label = json['label'] as String;
    final compoundsJson = json['compounds'] as List<dynamic>;
    final compounds = compoundsJson
        .map((c) => Compound.fromJsonFlexible(c as Map<String, dynamic>))
        .toList();

    return Profile(label: label, compounds: compounds);
  }

  /// Find the primary compound (highest mg_per_g)
  Compound? get primaryCompound {
    if (compounds.isEmpty) return null;
    return compounds.reduce(
      (a, b) => a.mgPerG > b.mgPerG ? a : b,
    );
  }
}

/// Container for profile library data
@freezed
class ProfileLibrary with _$ProfileLibrary {
  const factory ProfileLibrary({
    String? source,
    String? description,
    required List<Profile> profiles,
  }) = _ProfileLibrary;

  factory ProfileLibrary.fromJson(Map<String, dynamic> json) {
    // Handle both formats:
    // 1. {"profiles": [...]}
    // 2. [...]  (bare array)
    if (json.containsKey('profiles')) {
      return ProfileLibrary(
        source: json['source'] as String?,
        description: json['description'] as String?,
        profiles: (json['profiles'] as List<dynamic>)
            .map((p) => Profile.fromJsonFlexible(p as Map<String, dynamic>))
            .toList(),
      );
    } else {
      // Assume the whole JSON is an array of profiles
      throw ArgumentError(
        'JSON must contain "profiles" array. Bare arrays should be wrapped.',
      );
    }
  }

  // Parse from list directly
  static ProfileLibrary fromList(List<dynamic> jsonList) {
    return ProfileLibrary(
      profiles: jsonList
          .map((p) => Profile.fromJsonFlexible(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
