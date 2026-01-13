import 'dart:convert';

import 'package:compound_calculator/data/models/profile.dart';
import 'package:compound_calculator/data/sources/local_data_source.dart';
import 'package:compound_calculator/data/sources/remote_data_source.dart';

/// Repository for managing profile data
class ProfileRepository {
  ProfileRepository({
    required LocalDataSource localDataSource,
    RemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource ?? RemoteDataSource();
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  /// Initialize profiles on first launch
  ///
  /// Downloads from remote, saves as both working and backup copies
  Future<ProfileLibrary> initializeProfiles() async {
    // Check if profiles already exist
    final exists = await _localDataSource.profilesExist();
    if (exists) {
      final library = await _localDataSource.loadProfiles();
      if (library != null) return library;
    }

    // Download from remote
    final jsonString = await _remoteDataSource.downloadProfiles();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final library = ProfileLibrary.fromJson(json);

    // Save as both working and backup
    await _localDataSource.saveProfiles(library);
    await _localDataSource.saveProfilesBackup(library);

    return library;
  }

  /// Load profiles from local storage
  Future<ProfileLibrary?> loadProfiles() async {
    return _localDataSource.loadProfiles();
  }

  /// Load profiles as raw JSON string (for editor)
  Future<String?> loadProfilesAsString() async {
    return _localDataSource.loadProfilesAsString();
  }

  /// Save edited profiles from JSON string
  Future<void> saveProfilesFromString(String jsonString) async {
    await _localDataSource.saveProfilesFromString(jsonString);
  }

  /// Restore profiles from backup
  Future<void> restoreFromBackup() async {
    await _localDataSource.restoreFromBackup();
  }

  /// Force download fresh profiles from remote source
  /// Overwrites local storage with latest data from GitHub
  Future<ProfileLibrary> downloadLatestProfiles() async {
    // Download from remote
    final jsonString = await _remoteDataSource.downloadProfiles();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final library = ProfileLibrary.fromJson(json);

    // Save as both working and backup
    await _localDataSource.saveProfiles(library);
    await _localDataSource.saveProfilesBackup(library);

    return library;
  }

  /// Get selected profile label
  String? getSelectedProfileLabel() {
    return _localDataSource.getSelectedProfileLabel();
  }

  /// Set selected profile label
  Future<void> setSelectedProfileLabel(String label) async {
    await _localDataSource.setSelectedProfileLabel(label);
  }

  /// Get default weight unit
  String getDefaultWeightUnit() {
    return _localDataSource.getDefaultWeightUnit();
  }

  /// Set default weight unit
  Future<void> setDefaultWeightUnit(String unit) async {
    await _localDataSource.setDefaultWeightUnit(unit);
  }

  /// Check if disclaimer has been acknowledged
  bool isDisclaimerAcknowledged() {
    return _localDataSource.isDisclaimerAcknowledged();
  }

  /// Mark disclaimer as acknowledged
  Future<void> acknowledgeDisclaimer() async {
    await _localDataSource.setDisclaimerAcknowledged(true);
  }

  void dispose() {
    _remoteDataSource.dispose();
  }
}
