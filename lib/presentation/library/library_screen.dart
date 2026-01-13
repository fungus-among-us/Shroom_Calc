import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';

import 'package:compound_calculator/data/models/profile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.profiles,
    required this.selectedProfile,
    required this.onProfileSelected,
  });
  final List<Profile> profiles;
  final Profile? selectedProfile;
  final ValueChanged<Profile> onProfileSelected;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Profile> _filteredProfiles = [];
  late Fuzzy<Profile> _fuzzy;

  @override
  void initState() {
    super.initState();
    _filteredProfiles = widget.profiles;
    _fuzzy = Fuzzy<Profile>(
      widget.profiles,
      options: FuzzyOptions(
        keys: [
          WeightedKey(
            name: 'label',
            getter: (Profile p) => p.label,
            weight: 1.0,
          ),
        ],
        threshold: 0.4,
        distance: 100,
      ),
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = widget.profiles;
      } else {
        final results = _fuzzy.search(query);
        _filteredProfiles = results.map((r) => r.item).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            Container(
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
                          color: const Color(0xFF8B7355),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Profile Library',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                        ),
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
                          '${_filteredProfiles.length}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8B7355),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search profiles...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),

            // Profile grid
            Expanded(
              child: _filteredProfiles.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProfiles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final profile = _filteredProfiles[index];
                        final isSelected = profile == widget.selectedProfile;
                        return _buildProfileCard(
                          context,
                          profile,
                          isSelected,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity( 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No profiles found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity( 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    Profile profile,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF8B7355).withOpacity( 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected ? const Color(0xFF8B7355) : colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            widget.onProfileSelected(profile);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B7355),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...profile.compounds.map((compound) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF8B7355).withOpacity( 0.5),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            compound.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
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
                            '${compound.mgPerG.toStringAsFixed(1)} mg/g',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
