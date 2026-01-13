/// Core constants for the application
class AppConstants {
  // App metadata
  static const String appName = 'Compound Calculator';
  static const String appVersion = '1.0.0';
  static const String packageId = 'com.medicine.compound_calculator';

  // Data source - Full profiles database from GitHub
  static const String profilesJsonUrl =
      'https://raw.githubusercontent.com/fungus-among-us/Mushroom_Math/refs/heads/main/profiles.json';

  // Storage keys
  static const String profilesJsonKey = 'profiles.json';
  static const String profilesBackupKey = 'profiles_backup.json';
  static const String selectedProfileKey = 'selected_profile';
  static const String defaultWeightUnitKey = 'default_weight_unit';
  static const String disclaimerAcknowledgedKey = 'disclaimer_acknowledged';

  // Calculation defaults
  static const double defaultDryPercentage = 10.0;
  static const double minDryPercentage = 5.0;
  static const double maxDryPercentage = 25.0;

  // Dosing reference ranges (in grams dry)
  static const List<double> microdoseRange = [0.1, 0.2, 0.3];
  static const List<double> regularDoseRange = [1.0, 1.75, 2.5];
  static const List<double> heroicDoseRange = [5.0, 7.0];

  // Warnings and disclaimers
  static const String batchVariationWarning =
      'While this app uses average % of active compounds, batches can vary up to 3x in concentration';

  static const String educationalDisclaimer =
      'This calculator is for educational purposes only. '
      'Always verify compound concentrations independently. '
      'The developers assume no liability for use of this information.';

  // Input validation
  static const double maxReasonableMass = 1000.0; // grams
  static const double maxReasonableBodyWeight = 500.0; // kg
  static const double maxReasonableDose = 10.0; // mg/kg
}
