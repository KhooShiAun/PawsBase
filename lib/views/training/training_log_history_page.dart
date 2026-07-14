import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/pet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawsbase/views/training/training_command.dart';
import 'package:pawsbase/views/training/training_status.dart';

class TrainingLogHistoryPage extends StatefulWidget {
  final Pet pet;

  const TrainingLogHistoryPage({super.key, required this.pet});

  @override
  State<TrainingLogHistoryPage> createState() => _TrainingLogHistoryPageState();
}

class _TrainingLogHistoryPageState extends State<TrainingLogHistoryPage> {
  bool _isLoading = true;
  List<TrainingCommand> _commands = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('training_commands')
          .select()
          .eq('pet_id', widget.pet.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final commands = data.map((json) => TrainingCommand.fromJson(json as Map<String, dynamic>)).toList();
      
      if (mounted) {
        setState(() {
          _commands = commands;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load history.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      appBar: AppBar(
        backgroundColor: PawsBaseTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PawsBaseTokens.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "${widget.pet.name}'s Training History",
          style: const TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: PawsBaseTokens.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: PawsBaseTokens.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchHistory,
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: PawsBaseTokens.primaryDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.pet.name}'s Training Log",
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PawsBaseTokens.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "A record of all training sessions.",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            if (_commands.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48.0),
                  child: Text(
                    "No training history yet.",
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 16,
                      color: PawsBaseTokens.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ..._commands.map((cmd) {
                final isMastered = cmd.status == TrainingStatus.mastered;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildSessionCard(
                    command: cmd.name,
                    date: "Sessions: ${cmd.completedSessions} / ${cmd.sessionsNeeded}",
                    duration: cmd.category,
                    result: cmd.status.name.toUpperCase(),
                    resultColor: isMastered ? PawsBaseTokens.primaryDark : PawsBaseTokens.secondaryDark,
                    notes: cmd.description,
                  ),
                );
              }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String command,
    required String date,
    required String duration,
    required String result,
    required Color resultColor,
    required String notes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                command,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                ),
                child: Text(
                  result,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: resultColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: PawsBaseTokens.outline),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 13,
                  color: PawsBaseTokens.outline,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.category_outlined, size: 14, color: PawsBaseTokens.outline),
              const SizedBox(width: 6),
              Text(
                duration,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 13,
                  color: PawsBaseTokens.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 15,
              color: PawsBaseTokens.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}