import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/health_log/health_log_page.dart';
import 'package:pawsbase/widgets/paws_card/paws_card.dart';
import 'package:pawsbase/widgets/paws_search_bar/paws_search_bar.dart';
import 'package:pawsbase/widgets/paws_bottom_nav/paws_bottom_nav.dart';
import 'package:pawsbase/views/pets/pet.dart';
import 'package:pawsbase/views/pets/add_pet_page.dart';
import 'package:pawsbase/views/home/home_page.dart';
import 'package:pawsbase/views/training/training_checklist_page.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pawsbase/views/settings/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; // Default to 'Pets' tab as shown in the mockup

  final List<Widget> _pages = [
    const HomePage(),
    const _PetsPage(),
    const HealthLogPage(),
    const TrainingChecklistPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'PawsBase',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDark ? colorScheme.primary : PawsBaseTokens.primaryDark,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: CircleAvatar(
              backgroundColor: PawsBaseTokens.secondaryContainer,
              backgroundImage: NetworkImage(
                Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] ??
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCWw7Q21E5d946zOBAOb-YuUz-WP_pC6uGH0qJcndRsjgO5wpNDD4IC5gXPMBaNrJA7HLcmSrxITTROROmS-p6IwuvmFkJ-ypy_KbSFwUzbh_nwRaEKNbYitSH0mPPPXusYU-EolReFRKqsZFEVrEQuTOblMboYQ0UY8eVrKRea5EThTsPcH1IXHbig-EygDsLl4Iyn0-EqoFi4IHqDVqvSpMBXToJTh2mfOTMKvp_gZDrMex1ya3MKWHKYXVrL4X2cLQfkMRUBg4Cb',
              ),
            ),
          ),
        ),
        leadingWidth: 60,

      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPetPage()),
                );
              },
              backgroundColor: isDark ? colorScheme.primary : PawsBaseTokens.primaryDark,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      bottomNavigationBar: PawsBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PetsPage extends StatefulWidget {
  const _PetsPage();

  @override
  State<_PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<_PetsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Pet> _allPets = [];
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription? _petsSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToPets();
  }

  void _subscribeToPets() {
    // Listen for real-time updates to the pets table
    _petsSubscription = Supabase.instance.client
        .from('pets')
        .stream(primaryKey: ['id'])
        .listen((data) {
      final loadedPets = data.map((json) => Pet.fromJson(json)).toList();
      if (mounted) {
        setState(() {
          _allPets = loadedPets;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load pets. Please try again.';
          _isLoading = false;
        });
      }
    });
  }

  void _retryFetch() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    // The stream will naturally re-emit or we could restart it, 
    // but typically just waiting or restarting the app is enough.
    _petsSubscription?.cancel();
    _subscribeToPets();
  }

  @override
  void dispose() {
    _petsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryFetch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawsBaseTokens.primaryDark,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allPets.isEmpty) {
      return const _EmptyPetsPage();
    }

    final filteredPets = _allPets.where((pet) {
      final query = _searchQuery.toLowerCase();
      final nameMatch = pet.name.toLowerCase().contains(query);
      final breedMatch = (pet.breed ?? '').toLowerCase().contains(query);
      final speciesMatch = pet.species.toLowerCase().contains(query);
      return nameMatch || breedMatch || speciesMatch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'My Family',
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 36,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          PawsSearchBar(
            controller: _searchController,
            hintText: 'Search pets...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: filteredPets.isEmpty
                ? Center(
                    child: Text(
                      'No pets found',
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 16,
                        color: PawsBaseTokens.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100), // Clear float FAB & bottom navigation
                    itemCount: filteredPets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];
                      return PawsCard(
                        name: pet.name,
                        species: pet.species,
                        breed: pet.breed,
                        imageUrl: pet.imageUrl,
                        onTap: () {
                          // Action on tap
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


class _EmptyPetsPage extends StatelessWidget {
  const _EmptyPetsPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: PawsBaseTokens.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: PawsBaseTokens.primaryDark, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            "Your Pets",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first pet to get started.",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 16,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}