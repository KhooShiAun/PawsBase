import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/health_log/health_log_page.dart';
import 'package:pawsbase/widgets/paws_card/paws_card.dart';
import 'package:pawsbase/widgets/paws_search_bar/paws_search_bar.dart';
import 'package:pawsbase/widgets/paws_bottom_nav/paws_bottom_nav.dart';
import 'package:pawsbase/views/pets/pet.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; // Default to 'Pets' tab as shown in the mockup

  final List<Widget> _pages = [
    const _PlaceholderPage('Home'),
    const _PetsPage(),
    const HealthLogPage(),
    const _PlaceholderPage('Training'),
    const _PlaceholderPage('Settings'),
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
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: const CircleAvatar(
              backgroundColor: PawsBaseTokens.secondaryContainer,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=150', // high quality avatar matching mockup
              ),
            ),
          ),
        ),
        leadingWidth: 60,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none, 
                color: isDark ? colorScheme.primary : PawsBaseTokens.primaryDark, 
                size: 28,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // Add action
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
  const _PetsPage({Key? key}) : super(key: key);

  @override
  State<_PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<_PetsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Pet> _allPets = const [
    Pet(
      id: '1',
      name: 'Barnaby',
      species: 'Dog',
      breed: 'Golden Retriever',
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
    ),
    Pet(
      id: '2',
      name: 'Luna',
      species: 'Cat',
      breed: 'Domestic Shorthair',
      imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=400',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: PawsBaseTokens.onSurface,
          ),
        ),
      ),
    );
  }
}
