import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../services/training_service.dart';
import 'training_command.dart';
import 'training_status.dart';
import 'training_config.dart';

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
  bool _isAdding = false;
  String? _errorMessage;

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
      final data = await _trainingService.fetchCommands();
      setState(() {
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

  IconData _getCommandIcon(String category, String name) {
    final combined = '$name $category'.toLowerCase();
    if (combined.contains('sit')) {
      return Icons.airline_seat_recline_normal;
    } else if (combined.contains('stay') || combined.contains('stop') || combined.contains('wait') || combined.contains('leave') || combined.contains('impulsive')) {
      return Icons.front_hand;
    } else if (combined.contains('fetch') || combined.contains('ball') || combined.contains('play') || combined.contains('retrieval')) {
      return Icons.sports_baseball;
    } else if (combined.contains('roll') || combined.contains('turn') || combined.contains('rotate') || combined.contains('spin')) {
      return Icons.sync;
    } else if (combined.contains('paw') || combined.contains('hand') || combined.contains('high') || combined.contains('shake')) {
      return Icons.back_hand;
    }
    return Icons.pets;
  }

  Future<void> _cycleCommandStatus(TrainingCommand command) async {
    final newStatus = command.status.next;
    final originalStatus = command.status;

    // Optimistic UI update
    setState(() {
      final index = _commands.indexWhere((c) => c.id == command.id);
      if (index != -1) {
        _commands[index] = TrainingCommand(
          id: command.id,
          name: command.name,
          description: command.description,
          status: newStatus,
          category: command.category,
          createdAt: command.createdAt,
        );
      }
    });

    try {
      await _trainingService.updateCommandStatus(command.id, newStatus);
    } catch (e) {
      // Revert optimistic update on failure
      setState(() {
        final index = _commands.indexWhere((c) => c.id == command.id);
        if (index != -1) {
          _commands[index] = TrainingCommand(
            id: command.id,
            name: command.name,
            description: command.description,
            status: originalStatus,
            category: command.category,
            createdAt: command.createdAt,
          );
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: PawsBaseTokens.error,
        ),
      );
    }
  }

  Future<void> _handleAddCommand() async {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    final category = _inferCategory(text);
    _addController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      _isAdding = true;
    });

    try {
      final newCommand = await _trainingService.addCommand(text, category);
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
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Compute status counts dynamically
    final pendingCount = _commands.where((c) => c.status == TrainingStatus.pending).length;
    final inProgressCount = _commands.where((c) => c.status == TrainingStatus.inProgress).length;
    final masteredCount = _commands.where((c) => c.status == TrainingStatus.mastered).length;

    return Container(
      color: PawsBaseTokens.surface,
      child: SafeArea(
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
                else if (_commands.isEmpty)
                  _buildEmptyState(colorScheme)
                else
                  ..._commands.map((cmd) => _buildCommandCard(cmd, colorScheme)),

                const SizedBox(height: 24),

                // Add command input row
                _buildAddCommandInput(colorScheme),
                const SizedBox(height: 24), // Bottom buffer
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
    final icon = _getCommandIcon(command.category, command.name);

    return GestureDetector(
      onTap: () => _cycleCommandStatus(command),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PawsBaseTokens.secondaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
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
                    command.name,
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    command.description.isNotEmpty ? command.description : command.category,
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
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
      ),
    );
  }

  Widget _buildAddCommandInput(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: PawsBaseTokens.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _addController,
                decoration: const InputDecoration(
                  hintText: TrainingConfig.addCommandPlaceholder,
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                ),
                onSubmitted: (_) => _handleAddCommand(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleAddCommand,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PawsBaseTokens.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isAdding
                  ? const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(PawsBaseTokens.onPrimaryContainer),
                      ),
                    )
                  : const Icon(
                      Icons.add,
                      color: PawsBaseTokens.onPrimaryContainer,
                      size: 24,
                    ),
            ),
          ),
        ],
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
