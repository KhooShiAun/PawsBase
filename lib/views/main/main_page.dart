import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/health_log/health_log_page.dart';
import 'package:pawsbase/views/home/home_page.dart';
import 'package:pawsbase/views/pets/add_pet_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const _PetsPage(),
    const _PlaceholderPage('Health'),
    const _PlaceholderPage('Training'),
    const _PlaceholderPage('Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      appBar: AppBar(
        backgroundColor: PawsBaseTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'PawsBase',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: PawsBaseTokens.primaryDark,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PawsBaseTokens.outline.withOpacity(0.2)),
            ),
            child: const CircleAvatar(
              backgroundColor: PawsBaseTokens.secondaryContainer,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCWw7Q21E5d946zOBAOb-YuUz-WP_pC6uGH0qJcndRsjgO5wpNDD4IC5gXPMBaNrJA7HLcmSrxITTROROmS-p6IwuvmFkJ-ypy_KbSFwUzbh_nwRaEKNbYitSH0mPPPXusYU-EolReFRKqsZFEVrEQuTOblMboYQ0UY8eVrKRea5EThTsPcH1IXHbig-EygDsLl4Iyn0-EqoFi4IHqDVqvSpMBXToJTh2mfOTMKvp_gZDrMex1ya3MKWHKYXVrL4X2cLQfkMRUBg4Cb',
              ),
            ),
          ),
        ),
        leadingWidth: 64,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: PawsBaseTokens.primaryDark, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: PawsBaseTokens.surface,
          boxShadow: [
            BoxShadow(
              color: PawsBaseTokens.primaryDark.withOpacity(0.06),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.pets, 'Pets'),
              _buildNavItem(2, Icons.monitor_heart, 'Health'),
              _buildNavItem(3, Icons.fitness_center, 'Training'),
              _buildNavItem(4, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? PawsBaseTokens.primaryContainer.withOpacity(0.7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? PawsBaseTokens.onPrimaryContainer : PawsBaseTokens.neutral,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? PawsBaseTokens.onPrimaryContainer : PawsBaseTokens.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetsPage extends StatelessWidget {
  const _PetsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: PawsBaseTokens.primaryContainer.withOpacity(0.3),
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
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPetPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PawsBaseTokens.primaryDark,
                foregroundColor: PawsBaseTokens.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add a Pet',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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