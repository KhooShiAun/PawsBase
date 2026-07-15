import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/pet.dart';
import 'package:pawsbase/views/training/training_log_history_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthLogPage extends StatefulWidget {
  final Pet? pet;

  const HealthLogPage({super.key, this.pet});

  @override
  State<HealthLogPage> createState() => _HealthLogPageState();
}

class _HealthLogPageState extends State<HealthLogPage> {
  late Pet? _pet;
  List<Map<String, dynamic>> _healthLogs = [];
  bool _isLoadingLogs = true;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _fetchHealthLogs();
  }

  Future<void> _fetchHealthLogs() async {
    if (_pet == null) return;
    setState(() => _isLoadingLogs = true);
    try {
      final data = await Supabase.instance.client
          .from('health_logs')
          .select()
          .eq('pet_id', _pet!.id)
          .order('record_date', ascending: false);
      if (mounted) {
        setState(() {
          _healthLogs = List<Map<String, dynamic>>.from(data);
          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLogs = false);
      }
    }
  }

  Future<void> _refreshPet() async {
    if (_pet == null) return;
    try {
      final data = await Supabase.instance.client
          .from('pets')
          .select()
          .eq('id', _pet!.id)
          .single();
      if (mounted) {
        setState(() {
          _pet = Pet.fromJson(data);
        });
      }
    } catch (e) {
      // keep existing pet data if refresh fails
    }
  }

  String _formatWeightDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}";
  }

  Future<void> _showAddEntryDialog() async {
    if (_pet == null) return;
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'checkup';
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: PawsBaseTokens.surfaceBright,
              title: const Text('Add Health Log Entry', style: TextStyle(fontFamily: PawsBaseTokens.fontFamily)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Entry Type'),
                      items: const [
                        DropdownMenuItem(value: 'checkup', child: Text('Routine Checkup')),
                        DropdownMenuItem(value: 'vaccine', child: Text('Vaccination')),
                        DropdownMenuItem(value: 'medication', child: Text('Medication')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title (e.g. Annual Checkup)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(labelText: 'Subtitle (e.g. Vet Clinic Name)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Notes/Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() => selectedDate = date);
                            }
                          },
                          child: Text("${selectedDate.month}/${selectedDate.day}/${selectedDate.year}"),
                        ),
                      ],
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

    if (result == true && titleController.text.isNotEmpty) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      try {
        await Supabase.instance.client.from('health_logs').insert({
          'user_id': userId,
          'pet_id': _pet!.id,
          'log_title': titleController.text.trim(),
          'subtitle': subtitleController.text.trim(),
          'description': descController.text.trim(),
          'type': selectedType,
          'record_date': selectedDate.toIso8601String(),
        });
        await _refreshPet();
        _fetchHealthLogs();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving log: $e'), backgroundColor: PawsBaseTokens.error),
          );
        }
      }
    }
  }

  Future<void> _showEditEntryDialog(Map<String, dynamic> log) async {
    final titleController = TextEditingController(text: log['log_title'] ?? log['title']);
    final subtitleController = TextEditingController(text: log['subtitle']);
    final descController = TextEditingController(text: log['description']);
    String selectedType = log['type'] ?? 'checkup';
    DateTime selectedDate = DateTime.tryParse(log['record_date'] ?? '') ?? DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: PawsBaseTokens.surfaceBright,
              title: const Text('Edit Health Log', style: TextStyle(fontFamily: PawsBaseTokens.fontFamily)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Entry Type'),
                      items: const [
                        DropdownMenuItem(value: 'checkup', child: Text('Routine Checkup')),
                        DropdownMenuItem(value: 'vaccine', child: Text('Vaccination')),
                        DropdownMenuItem(value: 'medication', child: Text('Medication')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title (e.g. Annual Checkup)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(labelText: 'Subtitle (e.g. Vet Clinic Name)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Notes/Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Date:', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() => selectedDate = date);
                            }
                          },
                          child: Text("${selectedDate.month}/${selectedDate.day}/${selectedDate.year}"),
                        ),
                      ],
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

    if (result == true && titleController.text.isNotEmpty) {
      try {
        await Supabase.instance.client.from('health_logs').update({
          'log_title': titleController.text.trim(),
          'subtitle': subtitleController.text.trim(),
          'description': descController.text.trim(),
          'type': selectedType,
          'record_date': selectedDate.toIso8601String(),
        }).eq('id', log['id']);
        _fetchHealthLogs();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating log: $e'), backgroundColor: PawsBaseTokens.error),
          );
        }
      }
    }
  }

  Future<void> _deleteEntry(dynamic id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PawsBaseTokens.surfaceBright,
          title: const Text('Delete Health Log', style: TextStyle(color: PawsBaseTokens.error)),
          content: const Text('Are you sure you want to delete this health log entry?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: PawsBaseTokens.error, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client.from('health_logs').delete().eq('id', id);
        _fetchHealthLogs();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting log: $e'), backgroundColor: PawsBaseTokens.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pet == null) {
      return _buildEmptyState();
    }

    final String lastWeightDateStr = _healthLogs.isNotEmpty 
        ? _formatWeightDate(_healthLogs.first['record_date'])
        : '';

    return Container(
      color: PawsBaseTokens.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_pet!.name}'s Health Log",
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PawsBaseTokens.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_pet!.breed != null)
                  _buildChip(_pet!.breed!, PawsBaseTokens.secondaryContainer, PawsBaseTokens.onSecondaryContainer),
                if (_pet!.breed != null) const SizedBox(width: 8),
                _buildChip(_pet!.species, PawsBaseTokens.surfaceDim, PawsBaseTokens.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Medical history and wellness tracking.",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 18,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PawsBaseTokens.surfaceBright,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.scale, color: PawsBaseTokens.primaryDark, size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CURRENT WEIGHT",
                          style: TextStyle(
                            fontFamily: PawsBaseTokens.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: PawsBaseTokens.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _pet!.weightKg != null ? _pet!.weightKg!.toStringAsFixed(1) : "--",
                              style: const TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: PawsBaseTokens.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "kg",
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 16,
                                color: PawsBaseTokens.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PawsBaseTokens.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up, color: PawsBaseTokens.primaryDark, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              "Stable",
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PawsBaseTokens.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (lastWeightDateStr.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          lastWeightDateStr,
                          style: const TextStyle(
                            fontFamily: PawsBaseTokens.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: PawsBaseTokens.outline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddEntryDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("Add Entry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsBaseTokens.primaryDark,
                    foregroundColor: PawsBaseTokens.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_isLoadingLogs) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: PawsBaseTokens.primaryDark),
                ),
              ),
            ] else if (_healthLogs.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Text(
                    "No health records yet.",
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 16,
                      color: PawsBaseTokens.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ..._healthLogs.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                final isLast = index == _healthLogs.length - 1;

                // Choose icon based on type
                IconData icon = Icons.health_and_safety;
                Color iconColor = PawsBaseTokens.primaryDark;

                final type = log['type'] ?? '';
                switch (type) {
                  case 'vaccine':
                  case 'vaccination':
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

                DateTime recordDate = DateTime.tryParse(log['record_date'] ?? '') ?? DateTime.now();
                String formattedDate = "${recordDate.month}/${recordDate.day}/${recordDate.year}";

                return _buildTimelineItem(
                  icon: icon,
                  iconColor: iconColor,
                  title: log['log_title'] ?? log['title'] ?? 'Record',
                  date: log['record_date']?.substring(0, 10) ?? formattedDate,
                  subtitle: log['subtitle'] ?? 'General',
                  description: log['description'] ?? '',
                  isLast: isLast,
                  onEdit: () => _showEditEntryDialog(log),
                  onDelete: () => _deleteEntry(log['id']),
                );
              }),
            ],

            const SizedBox(height: 48),

            // View Training History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainingLogHistoryPage(pet: _pet!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawsBaseTokens.secondaryDark,
                  foregroundColor: PawsBaseTokens.onSecondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.fitness_center, size: 20),
                label: const Text(
                  "View Training History",
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              child: const Icon(Icons.monitor_heart, color: PawsBaseTokens.primaryDark, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Pet Selected",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Go to the Pets tab and tap on a pet to view their health log.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: PawsBaseTokens.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String subtitle,
    required String description,
    required bool isLast,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    Widget? child,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 40,
                    bottom: -40,
                    child: Container(
                      width: 1,
                      color: PawsBaseTokens.outline.withValues(alpha: 0.3),
                    ),
                  ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PawsBaseTokens.surfaceBright,
                      shape: BoxShape.circle,
                      border: Border.all(color: PawsBaseTokens.surface, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: PawsBaseTokens.outline.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PawsBaseTokens.surfaceBright,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: PawsBaseTokens.fontFamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: PawsBaseTokens.onSurface,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PawsBaseTokens.outline,
                              ),
                            ),
                            if (onEdit != null || onDelete != null) ...[
                              const SizedBox(width: 8),
                              if (onEdit != null)
                                GestureDetector(
                                  onTap: onEdit,
                                  child: const Icon(Icons.edit_outlined, size: 18, color: PawsBaseTokens.primaryDark),
                                ),
                              if (onEdit != null && onDelete != null) const SizedBox(width: 8),
                              if (onDelete != null)
                                GestureDetector(
                                  onTap: onDelete,
                                  child: const Icon(Icons.delete_outline_rounded, size: 18, color: PawsBaseTokens.error),
                                ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: PawsBaseTokens.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 16,
                        color: PawsBaseTokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (child != null) ...[
                      const SizedBox(height: 16),
                      child,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}