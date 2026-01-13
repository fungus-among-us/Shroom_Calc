import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:compound_calculator/core/constants.dart';

/// Service for local file storage
class StorageService {
  /// Get the app's documents directory
  Future<Directory> getAppDocumentsDirectory() async {
    return getApplicationDocumentsDirectory();
  }

  /// Save profiles JSON to working copy
  Future<void> saveProfilesJson(String jsonContent) async {
    final dir = await getAppDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.profilesJsonKey}');
    await file.writeAsString(jsonContent);
  }

  /// Save profiles JSON to backup copy
  Future<void> saveProfilesBackup(String jsonContent) async {
    final dir = await getAppDocumentsDirectory();
    final file = File('${dir.path}/${AppConstants.profilesBackupKey}');
    await file.writeAsString(jsonContent);
  }

  /// Load profiles JSON from working copy
  Future<String?> loadProfilesJson() async {
    try {
      final dir = await getAppDocumentsDirectory();
      final file = File('${dir.path}/${AppConstants.profilesJsonKey}');
      if (await file.exists()) {
        return file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Load profiles JSON from backup copy
  Future<String?> loadProfilesBackup() async {
    try {
      final dir = await getAppDocumentsDirectory();
      final file = File('${dir.path}/${AppConstants.profilesBackupKey}');
      if (await file.exists()) {
        return file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if profiles exist locally
  Future<bool> profilesExist() async {
    try {
      final dir = await getAppDocumentsDirectory();
      final file = File('${dir.path}/${AppConstants.profilesJsonKey}');
      return file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Restore working copy from backup
  Future<void> restoreFromBackup() async {
    final backup = await loadProfilesBackup();
    if (backup == null) {
      throw Exception('No backup found to restore from');
    }
    await saveProfilesJson(backup);
  }

  /// Delete all profile data (for testing/reset)
  Future<void> deleteAllProfiles() async {
    final dir = await getAppDocumentsDirectory();
    final workingFile = File('${dir.path}/${AppConstants.profilesJsonKey}');
    final backupFile = File('${dir.path}/${AppConstants.profilesBackupKey}');

    if (await workingFile.exists()) {
      await workingFile.delete();
    }
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }
}
