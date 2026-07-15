import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/pet.dart';
import 'package:pawsbase/views/pets/edit_pet_page.dart';
import 'package:pawsbase/views/training/training_log_history_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetDetailPage extends StatefulWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  late Pet _pet;
  List<Map<String, dynamic>> _healthLogs = [];
  bool _isLoadingLogs = true;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _fetchHealthLogs();
  }

  Future<void> _fetchHealthLogs() async {
    setState(() => _isLoadingLogs = true);
    try {
      final data = await Supabase.instance.client
          .from('health_logs')
          .select()
          .eq('pet_id', _pet.id)
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
    try {
      final data = await Supabase.instance.client
          .from('pets')
          .select()
          .eq('id', _pet.id)
          .single();
      if (mounted) {
        setState(() {
          _pet = Pet.fromJson(data);
        });
      }
    } catch (e) {
      // Keep existing pet data if refresh fails
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
          _pet.name,
          style: const TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: PawsBaseTokens.primaryDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: PawsBaseTokens.onSurfaceVariant),
            tooltip: 'Edit Pet',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditPetPage(pet: _pet),
                ),
              );
              if (result == 'deleted') {
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              } else if (result == true) {
                await _refreshPet();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Profile Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PawsBaseTokens.surfaceDim,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pet.imageUrl != null
                        ? Image.network(_pet.imageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.pets, size: 48, color: PawsBaseTokens.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _pet.name,
                    style: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: PawsBaseTokens.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_pet.breed != null)
                        _buildChip(_pet.breed!, PawsBaseTokens.secondaryContainer, PawsBaseTokens.onSecondaryContainer),
                      if (_pet.breed != null) const SizedBox(width: 8),
                      _buildChip(_pet.species, PawsBaseTokens.surfaceDim, PawsBaseTokens.onSurfaceVariant),
                      if (_pet.gender != null) const SizedBox(width: 8),
                      if (_pet.gender != null)
                        _buildChip(_pet.gender!, PawsBaseTokens.primaryContainer, PawsBaseTokens.onPrimaryContainer),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Pet Info Cards
            Row(
              children: [
                if (_pet.vaccinated != null)
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.vaccines,
                      label: 'Vaccinated',
                      value: _pet.vaccinated! ? 'Yes' : 'No',
                      valueColor: _pet.vaccinated! ? PawsBaseTokens.primaryDark : PawsBaseTokens.neutral,
                    ),
                  ),
                if (_pet.vaccinated != null && _pet.neutered != null)
                  const SizedBox(width: 12),
                if (_pet.neutered != null)
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.medical_services_outlined,
                      label: 'Neutered/Spayed',
                      value: _pet.neutered! ? 'Yes' : 'No',
                      valueColor: _pet.neutered! ? PawsBaseTokens.primaryDark : PawsBaseTokens.neutral,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 48),

            // Health Log Section
            Text(
              "Health Log",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: PawsBaseTokens.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Medical history and wellness tracking.",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Weight Card
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
                        Text(
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
                              _pet.weightKg != null ? _pet.weightKg!.toStringAsFixed(1) : "--",
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: PawsBaseTokens.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
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
                        Text(
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
                ],
              ),
            ),
            const SizedBox(height: 24),

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

            // Timeline
            if (_isLoadingLogs)
              const Center(child: CircularProgressIndicator())
            else if (_healthLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    "No health records yet.",
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 16,
                      color: PawsBaseTokens.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ..._healthLogs.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                final isLast = index == _healthLogs.length - 1;

                IconData icon;
                Color iconColor;
                switch (log['type']) {
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
                  default:
                    icon = Icons.health_and_safety;
                    iconColor = PawsBaseTokens.primaryDark;
                }

                // parse date
                DateTime date = DateTime.tryParse(log['record_date'] ?? '') ?? DateTime.now();
                String formattedDate = "${date.month}/${date.day}/${date.year}";

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

            const SizedBox(height: 48),

            // View Training History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TrainingLogHistoryPage(pet: _pet),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PawsBaseTokens.onSurfaceVariant),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 12,
                  color: PawsBaseTokens.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
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
                            style: TextStyle(
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
                              style: TextStyle(
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
                      style: TextStyle(
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
                      style: TextStyle(
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

  Future<void> _showAddEntryDialog() async {
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
                        DropdownMenuItem(value: 'vaccination', child: Text('Vaccination')),
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
          'pet_id': _pet.id,
          'log_title': titleController.text.trim(),
          'subtitle': subtitleController.text.trim(),
          'description': descController.text.trim(),
          'type': selectedType,
          'record_date': selectedDate.toIso8601String(),
        });
        _fetchHealthLogs(); // refresh timeline
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
                        DropdownMenuItem(value: 'vaccination', child: Text('Vaccination')),
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
        _fetchHealthLogs(); // refresh timeline
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
}