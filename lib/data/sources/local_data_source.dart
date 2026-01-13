import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:compound_calculator/core/constants.dart';
import 'package:compound_calculator/data/models/profile.dart';
import 'package:compound_calculator/services/storage_service.dart';

/// Local data source for profiles and preferences
class LocalDataSource {
  LocalDataSource({
    required SharedPreferences prefs,
    StorageService? storageService,
  })  : _prefs = prefs,
        _storageService = storageService ?? StorageService();
  final StorageService _storageService;
  final SharedPreferences _prefs;

  // Profile JSON operations

  Future<ProfileLibrary?> loadProfiles() async {
    final jsonString = await _storageService.loadProfilesJson();
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProfileLibrary.fromJson(json);
    } catch (e) {
      throw ProfileParseException('Failed to parse profiles: $e');
    }
  }

  Future<void> saveProfiles(ProfileLibrary library) async {
    final json = _profileLibraryToJson(library);
    final jsonString = jsonEncode(json);
    await _storageService.saveProfilesJson(jsonString);
  }

  Future<void> saveProfilesBackup(ProfileLibrary library) async {
    final json = _profileLibraryToJson(library);
    final jsonString = jsonEncode(json);
    await _storageService.saveProfilesBackup(jsonString);
  }

  Future<void> saveProfilesFromString(String jsonString) async {
    // Validate JSON before saving
    try {
      final json = jsonDecode(jsonString);
      if (json is Map<String, dynamic>) {
        ProfileLibrary.fromJson(json);
      } else {
        throw ProfileParseException('Invalid JSON structure');
      }
      await _storageService.saveProfilesJson(jsonString);
    } catch (e) {
      throw ProfileParseException('Invalid JSON: $e');
    }
  }

  Future<String?> loadProfilesAsString() async {
    return _storageService.loadProfilesJson();
  }

  Future<bool> profilesExist() async {
    return _storageService.profilesExist();
  }

  Future<void> restoreFromBackup() async {
    await _storageService.restoreFromBackup();
  }

  // Preferences operations

  Future<void> setSelectedProfileLabel(String label) async {
    await _prefs.setString(AppConstants.selectedProfileKey, label);
  }

  String? getSelectedProfileLabel() {
    return _prefs.getString(AppConstants.selectedProfileKey);
  }

  Future<void> setDefaultWeightUnit(String unit) async {
    await _prefs.setString(AppConstants.defaultWeightUnitKey, unit);
  }

  String getDefaultWeightUnit() {
    return _prefs.getString(AppConstants.defaultWeightUnitKey) ?? 'kg';
  }

  Future<void> setDisclaimerAcknowledged(bool acknowledged) async {
    await _prefs.setBool(AppConstants.disclaimerAcknowledgedKey, acknowledged);
  }

  bool isDisclaimerAcknowledged() {
    return _prefs.getBool(AppConstants.disclaimerAcknowledgedKey) ?? false;
  }

  // Helper to convert ProfileLibrary to JSON
  Map<String, dynamic> _profileLibraryToJson(ProfileLibrary library) {
    return {
      if (library.source != null) 'source': library.source,
      if (library.description != null) 'description': library.description,
      'profiles': library.profiles
          .map(
            (p) => {
              'label': p.label,
              'compounds': p.compounds
                  .map(
                    (c) => {
                      'name': c.name,
                      'mg_per_g': c.mgPerG,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }
}

/// Exception for profile parsing errors
class ProfileParseException implements Exception {
  ProfileParseException(this.message);
  final String message;

  @override
  String toString() => message;
}
