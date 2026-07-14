import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../services/training_service.dart';
import 'training_command.dart';
import 'training_status.dart';
import 'training_config.dart';
import '../pets/pet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainingChecklistPage extends StatefulWidget {
  const TrainingChecklistPage({super.key});

  @override
  State<TrainingChecklistPage> createState() => _TrainingChecklistPageState();
}

class _TrainingChecklistPageState extends State<TrainingChecklistPage> {
  final TrainingService _trainingService = TrainingService();
  final TextEditingController _addController = TextEditingController();

  List<TrainingCommand> _commands = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Pet> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadCommands();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _loadCommands() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final petsData = await Supabase.instance.client.from('pets').select();
      final petsList = (petsData as List).map((json) => Pet.fromJson(json)).toList();

      final data = await _trainingService.fetchCommands();
      setState(() {
        _pets = petsList;
        _commands = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load training checklist. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _inferCategory(String commandName) {
    final name = commandName.toLowerCase();
    if (name.contains('sit') || name.contains('down') || name.contains('come') || name.contains('heel')) {
      return 'Basic obedience';
    } else if (name.contains('stay') || name.contains('wait') || name.contains('leave')) {
      return 'Impulsive control';
    } else if (name.contains('fetch') || name.contains('ball') || name.contains('toy') || name.contains('retrieve')) {
      return 'Play & retrieval';
    } else if (name.contains('roll') || name.contains('spin') || name.contains('jump') || name.contains('flip') || name.contains('turn')) {
      return 'Advanced trick';
    } else if (name.contains('paw') || name.contains('shake') || name.contains('high five') || name.contains('greet')) {
      return 'Greeting trick';
    }
    return 'General training';
  }


  // Removed manual status cycling since status is now dynamically computed based on completedSessions




  Future<void> _showAddCommandDialog() async {
    final nameController = TextEditingController();
    final sessionsController = TextEditingController(text: '1');
    Pet? selectedPet = _pets.isNotEmpty ? _pets.first : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: PawsBaseTokens.surfaceBright,
              title: const Text('Add Training', style: TextStyle(fontFamily: PawsBaseTokens.fontFamily)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Training Name'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Pet>(
                      initialValue: selectedPet,
                      decoration: const InputDecoration(labelText: 'Select Pet'),
                      items: _pets.map((pet) {
                        return DropdownMenuItem(
                          value: pet,
                          child: Text(pet.name),
                        );
                      }).toList(),
                      onChanged: (Pet? value) {
                        setDialogState(() {
                          selectedPet = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: sessionsController,
                      decoration: const InputDecoration(labelText: 'Sessions Needed'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && nameController.text.isNotEmpty) {
      final name = nameController.text.trim();
      final sessions = int.tryParse(sessionsController.text.trim()) ?? 1;
      
      try {
        final category = _inferCategory(name);
        final newCommand = await _trainingService.addCommand(
          name, 
          category,
          petId: selectedPet?.id,
          sessionsNeeded: sessions,
        );
        setState(() {
          _commands.add(newCommand);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add command: $e'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
      }
    }
  }

  Future<void> _showEditCommandDialog(TrainingCommand command) async {
    final nameController = TextEditingController(text: command.name);
    final sessionsController = TextEditingController(text: command.sessionsNeeded.toString());
    Pet? selectedPet = _pets.where((p) => p.id == command.petId).firstOrNull;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: PawsBaseTokens.surfaceBright,
              title: const Text('Edit Training', style: TextStyle(fontFamily: PawsBaseTokens.fontFamily)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Training Name'),
                    ),
                    const SizedBox(height: 16),
                    if (_pets.isNotEmpty)
                      DropdownButtonFormField<Pet>(
                        initialValue: selectedPet,
                        decoration: const InputDecoration(labelText: 'Select Pet'),
                        items: _pets.map((pet) {
                          return DropdownMenuItem(
                            value: pet,
                            child: Text(pet.name),
                          );
                        }).toList(),
                        onChanged: (Pet? value) {
                          setDialogState(() {
                            selectedPet = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: sessionsController,
                      decoration: const InputDecoration(labelText: 'Sessions Needed'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && nameController.text.isNotEmpty) {
      final name = nameController.text.trim();
      final sessions = int.tryParse(sessionsController.text.trim()) ?? command.sessionsNeeded;
      
      // Prevent making sessions needed less than completed sessions
      final validSessions = sessions < command.completedSessions ? command.completedSessions : sessions;
      final petId = selectedPet?.id ?? command.petId;

      try {
        await _trainingService.updateCommand(command.id, petId ?? '', name, validSessions);
        _loadCommands(); // reload list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update command: $e'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
      }
    }
  }

  Future<void> _completeSession(TrainingCommand command) async {
    if (command.completedSessions >= command.sessionsNeeded) return;
    
    // Optimistic update
    setState(() {
      final index = _commands.indexWhere((c) => c.id == command.id);
      if (index != -1) {
        _commands[index] = TrainingCommand(
          id: command.id,
          name: command.name,
          description: command.description,
          category: command.category,
          createdAt: command.createdAt,
          petId: command.petId,
          sessionsNeeded: command.sessionsNeeded,
          completedSessions: command.completedSessions + 1,
        );
      }
    });

    try {
      await _trainingService.completeTrainingSession(
        command.id, 
        command.completedSessions,
        command.sessionsNeeded,
        petId: command.petId,
        commandName: command.name,
      );
    } catch (e) {
      // Rollback on failure
      setState(() {
        final index = _commands.indexWhere((c) => c.id == command.id);
        if (index != -1) {
          _commands[index] = command; // revert
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete session: $e'),
          backgroundColor: PawsBaseTokens.error,
        ),
      );
    }
  }

  void _showTrainingDetailsBottomSheet(TrainingCommand command, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true, // Allows the sheet to take up more screen space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Get latest command state from the list in case it updated
            final currentCommand = _commands.firstWhere((c) => c.id == command.id, orElse: () => command);
            final remaining = currentCommand.sessionsNeeded - currentCommand.completedSessions;
            final progress = currentCommand.completedSessions / currentCommand.sessionsNeeded;
            
            return FractionallySizedBox(
              heightFactor: 0.85, // Takes up 85% of screen height
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 24),
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentCommand.name,
                                style: TextStyle(
                                  fontFamily: PawsBaseTokens.fontFamily,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await _showEditCommandDialog(currentCommand);
                              },
                              icon: const Icon(Icons.edit_outlined, color: PawsBaseTokens.primaryDark),
                              tooltip: 'Edit Training',
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showDeleteTrainingConfirmation(currentCommand);
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: PawsBaseTokens.error),
                              tooltip: 'Delete Training',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overall Progress',
                                    style: TextStyle(
                                      fontFamily: PawsBaseTokens.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: colorScheme.outline.withValues(alpha: 0.1),
                                      valueColor: const AlwaysStoppedAnimation<Color>(PawsBaseTokens.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: remaining > 0 ? PawsBaseTokens.secondaryContainer : PawsBaseTokens.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    remaining > 0 ? '$remaining' : 'Done!',
                                    style: TextStyle(
                                      fontFamily: PawsBaseTokens.fontFamily,
                                      fontSize: remaining > 0 ? 20 : 16,
                                      fontWeight: FontWeight.w800,
                                      color: remaining > 0 ? PawsBaseTokens.onSecondaryContainer : PawsBaseTokens.onPrimaryContainer,
                                    ),
                                  ),
                                  if (remaining > 0)
                                    Text(
                                      'Left',
                                      style: TextStyle(
                                        fontFamily: PawsBaseTokens.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: PawsBaseTokens.onSecondaryContainer,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  
                  // Timeline
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                      itemCount: currentCommand.sessionsNeeded,
                      itemBuilder: (context, index) {
                        final isCompleted = index < currentCommand.completedSessions;
                        final isNext = index == currentCommand.completedSessions;
                        final isLast = index == currentCommand.sessionsNeeded - 1;
                        
                        return _buildTimelineItem(
                          sessionIndex: index,
                          isCompleted: isCompleted,
                          isNext: isNext,
                          isLast: isLast,
                          colorScheme: colorScheme,
                          onTap: () async {
                            if (isNext) {
                              await _completeSession(currentCommand);
                              setSheetState(() {});
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _showDeleteTrainingConfirmation(TrainingCommand command) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PawsBaseTokens.surfaceBright,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: PawsBaseTokens.error, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete Training',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontWeight: FontWeight.w700,
                  color: PawsBaseTokens.error,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${command.name}"? This action cannot be undone.',
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 15,
              color: PawsBaseTokens.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: PawsBaseTokens.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _trainingService.deleteCommand(command.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${command.name}" has been deleted.',
                style: const TextStyle(fontFamily: PawsBaseTokens.fontFamily),
              ),
              backgroundColor: PawsBaseTokens.primaryDark,
            ),
          );
          _loadCommands(); // refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting training: $e'),
              backgroundColor: PawsBaseTokens.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildTimelineItem({
    required int sessionIndex,
    required bool isCompleted,
    required bool isNext,
    required bool isLast,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    final color = isCompleted 
        ? PawsBaseTokens.primary 
        : (isNext ? PawsBaseTokens.secondaryDark : colorScheme.outline.withValues(alpha: 0.3));
        
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 32,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: isCompleted 
                          ? PawsBaseTokens.primary.withValues(alpha: 0.5) 
                          : colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    onTap: isNext ? onTap : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? PawsBaseTokens.primary : (isNext ? PawsBaseTokens.primaryContainer : Colors.transparent),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: isNext ? 3 : 2,
                        ),
                        boxShadow: isCompleted || isNext
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : (isNext 
                              ? const Icon(Icons.play_arrow, size: 18, color: PawsBaseTokens.primaryDark)
                              : null),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: isNext ? onTap : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted || isNext 
                        ? colorScheme.surfaceContainerHighest 
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNext 
                          ? PawsBaseTokens.primary.withValues(alpha: 0.5) 
                          : colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session ${sessionIndex + 1}',
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 16,
                                fontWeight: isCompleted || isNext ? FontWeight.w700 : FontWeight.w500,
                                color: isCompleted || isNext ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (isNext) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Tap to complete',
                                style: TextStyle(
                                  fontFamily: PawsBaseTokens.fontFamily,
                                  fontSize: 13,
                                  color: PawsBaseTokens.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else if (isCompleted) ...[
                               const SizedBox(height: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontFamily: PawsBaseTokens.fontFamily,
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isNext)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: PawsBaseTokens.primary,
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: const Text(
                             'READY',
                             style: TextStyle(
                               fontFamily: PawsBaseTokens.fontFamily,
                               fontSize: 10,
                               fontWeight: FontWeight.w800,
                               color: Colors.white,
                               letterSpacing: 1.0,
                             ),
                           ),
                         ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Compute status counts dynamically
    final pendingCount = _commands.where((c) => c.status == TrainingStatus.pending).length;
    final inProgressCount = _commands.where((c) => c.status == TrainingStatus.inProgress).length;
    final masteredCount = _commands.where((c) => c.status == TrainingStatus.mastered).length;

    final sortedCommands = List<TrainingCommand>.from(_commands)..sort((a, b) {
      if (a.status == TrainingStatus.mastered && b.status != TrainingStatus.mastered) {
        return 1;
      } else if (a.status != TrainingStatus.mastered && b.status == TrainingStatus.mastered) {
        return -1;
      }
      return 0;
    });

    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommandDialog,
        backgroundColor: PawsBaseTokens.primaryDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadCommands,
          color: PawsBaseTokens.primaryDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Text(
                  TrainingConfig.pageTitle,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  TrainingConfig.pageSubtitle,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats row
                Row(
                  children: [
                    _buildStatCard('Pending', pendingCount, colorScheme),
                    const SizedBox(width: 12),
                    _buildStatCard('In Progress', inProgressCount, colorScheme),
                    const SizedBox(width: 12),
                    _buildStatCard('Mastered', masteredCount, colorScheme),
                  ],
                ),
                const SizedBox(height: 32),

                // Main body state management (Loading, Error, Empty, List)
                if (_isLoading)
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_errorMessage != null)
                  _buildErrorState()
                else if (sortedCommands.isEmpty)
                  _buildEmptyState(colorScheme)
                else
                  ...sortedCommands.map((cmd) => _buildCommandCard(cmd, colorScheme)),

                const SizedBox(height: 24),

                const SizedBox(height: 80), // Bottom buffer for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandCard(TrainingCommand command, ColorScheme colorScheme) {
    // Find pet name if available in our dummy list
    final pet = _pets.where((p) => p.id == command.petId).firstOrNull;
    final petName = pet?.name ?? 'Unknown Pet';

    return GestureDetector(
      onTap: () => _showTrainingDetailsBottomSheet(command, colorScheme),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: command.status == TrainingStatus.mastered
              ? Colors.green.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: command.status == TrainingStatus.mastered
                ? Colors.green.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Pet Picture Placeholder / Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: PawsBaseTokens.secondaryContainer.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: PawsBaseTokens.secondaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        command.name,
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                        decoration: BoxDecoration(
                          color: command.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        command.status.label,
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: command.status.color,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommandInput(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _showAddCommandDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: PawsBaseTokens.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PawsBaseTokens.primary.withValues(alpha: 0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: PawsBaseTokens.primary),
            SizedBox(width: 8),
            Text(
              'Add Training Session',
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center_outlined,
            size: 48,
            color: PawsBaseTokens.neutral,
          ),
          const SizedBox(height: 16),
          Text(
            TrainingConfig.emptyStateMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: PawsBaseTokens.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: PawsBaseTokens.error, size: 36),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              color: PawsBaseTokens.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCommands,
            style: ElevatedButton.styleFrom(
              backgroundColor: PawsBaseTokens.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
