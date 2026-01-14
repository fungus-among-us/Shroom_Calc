import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compound_calculator/core/constants.dart';
import 'package:compound_calculator/core/theme.dart';
import 'package:compound_calculator/data/models/calculation_result.dart';
import 'package:compound_calculator/data/models/profile.dart';
import 'package:compound_calculator/data/repositories/profile_repository.dart';
import 'package:compound_calculator/data/sources/local_data_source.dart';
import 'package:compound_calculator/logic/calculator/calculator_bloc.dart';
import 'package:compound_calculator/logic/calculator/calculator_event.dart';
import 'package:compound_calculator/presentation/calculator/calculator_screen.dart';
import 'package:compound_calculator/presentation/library/library_screen.dart';
import 'package:compound_calculator/presentation/settings/json_editor_screen.dart';
import 'package:compound_calculator/presentation/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final localDataSource = LocalDataSource(prefs: prefs);
  final profileRepository = ProfileRepository(localDataSource: localDataSource);

  runApp(
    CompoundCalculatorApp(
      profileRepository: profileRepository,
    ),
  );
}

class CompoundCalculatorApp extends StatelessWidget {
  const CompoundCalculatorApp({
    super.key,
    required this.profileRepository,
  });
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compound Calculator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AppShell(profileRepository: profileRepository),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.profileRepository,
  });
  final ProfileRepository profileRepository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  ProfileLibrary? _profileLibrary;
  Profile? _selectedProfile;
  WeightUnit _defaultWeightUnit = WeightUnit.kg;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize profiles (download if first launch)
      final library = await widget.profileRepository.initializeProfiles();

      // Load selected profile
      final selectedLabel = widget.profileRepository.getSelectedProfileLabel();
      Profile? selected;
      if (selectedLabel != null) {
        selected = library.profiles.firstWhere(
          (p) => p.label == selectedLabel,
          orElse: () => library.profiles.first,
        );
      } else {
        selected = library.profiles.first;
      }

      // Load preferences
      final weightUnitStr = widget.profileRepository.getDefaultWeightUnit();
      final weightUnit = weightUnitStr == 'lb' ? WeightUnit.lb : WeightUnit.kg;

      setState(() {
        _profileLibrary = library;
        _selectedProfile = selected;
        _defaultWeightUnit = weightUnit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e\n\nURL: ${AppConstants.profilesJsonUrl}\n\nVersion: ${AppConstants.appVersion}';
        _isLoading = false;
      });
    }
  }

  Future<void> _onProfileSelected(Profile profile) async {
    await widget.profileRepository.setSelectedProfileLabel(profile.label);
    setState(() {
      _selectedProfile = profile;
    });
  }

  Future<void> _onWeightUnitChanged(WeightUnit unit) async {
    await widget.profileRepository.setDefaultWeightUnit(unit.name);
    setState(() {
      _defaultWeightUnit = unit;
    });
  }

  Future<void> _onManageProfiles() async {
    final jsonString = await widget.profileRepository.loadProfilesAsString();
    if (jsonString == null) return;

    if (!mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => JsonEditorScreen(
          initialJson: jsonString,
          onSave: (newJson) async {
            await widget.profileRepository.saveProfilesFromString(newJson);
            // Reload profiles
            final library = await widget.profileRepository.loadProfiles();
            if (library != null && mounted) {
              setState(() {
                _profileLibrary = library;
                // Try to keep the same profile selected if it still exists
                final stillExists = library.profiles.any(
                  (p) => p.label == _selectedProfile?.label,
                );
                if (!stillExists && library.profiles.isNotEmpty) {
                  _selectedProfile = library.profiles.first;
                }
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _onDownloadLatest() async {
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Downloading profiles from GitHub...'),
            ],
          ),
          duration: Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final library = await widget.profileRepository.downloadLatestProfiles();
      if (mounted) {
        setState(() {
          _profileLibrary = library;
          _selectedProfile = library.profiles.first;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Downloaded ${library.profiles.length} profiles from GitHub',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onRestoreDefaults() async {
    try {
      await widget.profileRepository.restoreFromBackup();
      final library = await widget.profileRepository.loadProfiles();
      if (library != null && mounted) {
        setState(() {
          _profileLibrary = library;
          _selectedProfile = library.profiles.first;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profiles restored from backup'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading profiles...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializeApp();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_profileLibrary == null || _selectedProfile == null) {
      return const Scaffold(
        body: Center(child: Text('No profiles available')),
      );
    }

    final screens = [
      BlocProvider(
        create: (context) => CalculatorBloc()
          ..add(CalculatorEvent.profileSelected(_selectedProfile!)),
        child: CalculatorScreen(profiles: _profileLibrary!.profiles),
      ),
      LibraryScreen(
        profiles: _profileLibrary!.profiles,
        selectedProfile: _selectedProfile,
        onProfileSelected: (profile) {
          _onProfileSelected(profile);
          setState(() => _currentIndex = 0); // Navigate back to calculator
        },
      ),
      SettingsScreen(
        defaultWeightUnit: _defaultWeightUnit,
        onWeightUnitChanged: _onWeightUnitChanged,
        onManageProfiles: _onManageProfiles,
        onDownloadLatest: _onDownloadLatest,
        onRestoreDefaults: _onRestoreDefaults,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: const Color(0xFF8B7355).withOpacity( 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
