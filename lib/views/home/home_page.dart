import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/add_pet_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawsbase/views/pets/pet.dart';
import 'package:pawsbase/views/pets/pet_detail_page.dart';
import 'package:pawsbase/views/training/training_command.dart';
import 'package:pawsbase/views/training/training_status.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;

  const HomePage({super.key, this.onTabSelected});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Pet> _pets = [];
  int _masteredCount = 0;
  Map<String, dynamic>? _recentHealthLog;
  Pet? _healthLogPet;
  TrainingCommand? _activeTrainingCommand;
  Pet? _trainingPet;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_pets.isEmpty && _masteredCount == 0 && _recentHealthLog == null && _activeTrainingCommand == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final client = Supabase.instance.client;

      // 1. Fetch authenticated user display name
      final user = client.auth.currentUser;
      if (user != null) {
        final metadata = user.userMetadata ?? {};
        _displayName = metadata['full_name'] ?? user.email?.split('@').first ?? 'User';
      }

      // 2. Fetch pets
      final petsData = await client.from('pets').select();
      final loadedPets = (petsData as List).map((json) => Pet.fromJson(json as Map<String, dynamic>)).toList();

      // 3. Fetch training commands
      final commandsData = await client.from('training_commands').select();
      final loadedCommands = (commandsData as List).map((json) => TrainingCommand.fromJson(json as Map<String, dynamic>)).toList();

      // 4. Fetch latest health log
      final healthData = await client
          .from('health_logs')
          .select()
          .order('record_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _pets = loadedPets;
          _masteredCount = loadedCommands.where((c) => c.status == TrainingStatus.mastered).length;

          // Find the most recent active training command (in progress or pending)
          final activeCommands = loadedCommands.where((c) => c.status != TrainingStatus.mastered).toList();
          activeCommands.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (activeCommands.isNotEmpty) {
            _activeTrainingCommand = activeCommands.first;
            final petId = _activeTrainingCommand!.petId;
            final matches = _pets.where((p) => p.id == petId);
            _trainingPet = matches.isNotEmpty ? matches.first : null;
          } else {
            _activeTrainingCommand = null;
            _trainingPet = null;
          }

          if (healthData != null) {
            _recentHealthLog = healthData;
            final petId = _recentHealthLog!['pet_id'];
            final matches = _pets.where((p) => p.id == petId);
            _healthLogPet = matches.isNotEmpty ? matches.first : null;
          } else {
            _recentHealthLog = null;
            _healthLogPet = null;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load home data. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _formatRecordDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDay = DateTime(date.year, date.month, date.day);

    final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    if (recordDay == today) {
      return "TODAY, $timeStr";
    } else if (recordDay == yesterday) {
      return "YESTERDAY, $timeStr";
    } else {
      final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: PawsBaseTokens.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: PawsBaseTokens.primaryDark,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: PawsBaseTokens.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 16,
                    color: PawsBaseTokens.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsBaseTokens.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: PawsBaseTokens.surface,
      child: RefreshIndicator(
        onRefresh: _fetchData,
        color: PawsBaseTokens.primaryDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 48),
              _buildYourPetsSection(context),
              const SizedBox(height: 48),
              _buildHealthAndTrainingSection(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${_getGreeting()}, $_displayName!",
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ready for another great day with your furry friends?",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 16,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.pets,
                  "Active Pets",
                  _pets.length.toString(),
                  PawsBaseTokens.primaryContainer.withValues(alpha: 0.3),
                  PawsBaseTokens.primaryDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  Icons.workspace_premium,
                  "Mastered",
                  _masteredCount.toString(),
                  PawsBaseTokens.secondaryContainer.withValues(alpha: 0.3),
                  PawsBaseTokens.secondaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color bgColor, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: PawsBaseTokens.onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYourPetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Your Pets",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onTabSelected?.call(1);
              },
              child: const Text(
                "VIEW ALL",
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.primaryDark,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              if (_pets.isEmpty) ...[
                _buildEmptyPetsCard(context),
              ] else ...[
                ..._pets.map((pet) => Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetDetailPage(pet: pet),
                            ),
                          );
                          if (result == true || result == 'deleted') {
                            _fetchData();
                          }
                        },
                        child: _buildPetCard(
                          pet.name,
                          pet.breed ?? pet.species,
                          pet.imageUrl ?? '',
                        ),
                      ),
                    )),
              ],
              _buildAddPetCard(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(String name, String breed, String imageUrl) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                  )
                : _buildFallbackImage(),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            breed.toUpperCase(),
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: PawsBaseTokens.surfaceDim,
      child: const Icon(
        Icons.pets,
        size: 64,
        color: PawsBaseTokens.outline,
      ),
    );
  }

  Widget _buildEmptyPetsCard(BuildContext context) {
    return Container(
      width: 240,
      height: 275,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 48, color: PawsBaseTokens.outline),
          SizedBox(height: 16),
          Text(
            "No pets yet",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Add a pet to start",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 14,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddPetPage()),
        );
        if (result == true) {
          _fetchData();
        }
      },
      child: Container(
        width: 120,
        height: 275,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PawsBaseTokens.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          color: PawsBaseTokens.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: PawsBaseTokens.primaryDark, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              "ADD",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthAndTrainingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecentHealthCard(),
        const SizedBox(height: 24),
        _buildTrainingProgressCard(),
      ],
    );
  }

  Widget _buildRecentHealthCard() {
    final hasLog = _recentHealthLog != null;
    final petName = _healthLogPet?.name ?? 'your pet';
    final logTitle = _recentHealthLog?['log_title'] ?? _recentHealthLog?['title'] ?? 'Health Entry';
    final subtitle = _recentHealthLog?['subtitle'] ?? '';
    final recordDate = _recentHealthLog?['record_date'] as String?;

    IconData icon = Icons.health_and_safety;
    Color iconColor = PawsBaseTokens.primaryDark;

    if (hasLog) {
      final type = _recentHealthLog?['type'] ?? '';
      switch (type) {
        case 'vaccine':
          icon = Icons.vaccines;
          iconColor = PawsBaseTokens.primaryDark;
          break;
        case 'checkup':
          icon = Icons.medical_services;
          iconColor = PawsBaseTokens.secondaryDark;
          break;
        case 'medication':
          icon = Icons.pest_control;
          iconColor = PawsBaseTokens.neutralDark;
          break;
        case 'training':
          icon = Icons.fitness_center;
          iconColor = PawsBaseTokens.secondaryDark;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recent Health Entry",
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: PawsBaseTokens.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasLog ? "$petName: $logTitle${subtitle.isNotEmpty ? ' - $subtitle' : ''}" : "No recent health entries logged.",
                  style: const TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 16,
                    color: PawsBaseTokens.onSurfaceVariant,
                  ),
                ),
                if (hasLog) ...[
                  const SizedBox(height: 12),
                  Text(
                    _formatRecordDate(recordDate),
                    style: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PawsBaseTokens.neutralDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingProgressCard() {
    final hasCommand = _activeTrainingCommand != null;
    final petName = _trainingPet?.name ?? 'Your pet';
    final commandName = _activeTrainingCommand?.name ?? '';
    final completed = _activeTrainingCommand?.completedSessions ?? 0;
    final needed = _activeTrainingCommand?.sessionsNeeded ?? 1;

    final remaining = needed - completed;
    final double progressFactor = completed / needed;
    final percent = (progressFactor * 100).toInt();

    final titleText = hasCommand ? "$petName is $remaining session${remaining > 1 ? 's' : ''} away from mastering '$commandName'." : "No active training sessions in progress.";

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fitness_center, color: PawsBaseTokens.secondaryDark, size: 28),
              SizedBox(width: 12),
              Text(
                "Training Progress",
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: const TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 16,
                    color: PawsBaseTokens.onSurfaceVariant,
                  ),
                ),
              ),
              if (hasCommand) ...[
                const SizedBox(width: 16),
                Text(
                  "$percent%",
                  style: const TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: PawsBaseTokens.secondaryDark,
                  ),
                ),
              ],
            ],
          ),
          if (hasCommand) ...[
            const SizedBox(height: 12),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressFactor.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: PawsBaseTokens.secondaryDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onTabSelected?.call(2); // Go to Training
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PawsBaseTokens.secondaryDark,
                foregroundColor: PawsBaseTokens.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasCommand ? "CONTINUE TRAINING" : "START TRAINING",
                    style: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}