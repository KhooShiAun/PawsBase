import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/pet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPetPage extends StatefulWidget {
  final Pet pet;

  const EditPetPage({super.key, required this.pet});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _weightController;

  bool _isLoading = false;

  late String _selectedSpecies;
  late String _selectedGender;
  late String _selectedVaccinated;
  late String _selectedNeutered;
  DateTime? _dateOfBirth;
  Uint8List? _petPhotoBytes;
  String? _petPhotoExt;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed ?? '');
    _weightController = TextEditingController();
    _selectedSpecies = widget.pet.species;
    _selectedGender = widget.pet.gender ?? 'male';
    _selectedVaccinated = (widget.pet.vaccinated ?? false) ? 'yes' : 'no';
    _selectedNeutered = (widget.pet.neutered ?? false) ? 'yes' : 'no';
    _dateOfBirth = widget.pet.dateOfBirth;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last;
      setState(() {
        _petPhotoBytes = bytes;
        _petPhotoExt = ext;
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<String?> _uploadPhoto() async {
    if (_petPhotoBytes == null || _petPhotoExt == null) return null;

    try {
      final fileName = '${widget.pet.id}.$_petPhotoExt';

      await Supabase.instance.client.storage
          .from('pet-photos')
          .uploadBinary(
            fileName,
            _petPhotoBytes!,
            fileOptions: FileOptions(contentType: 'image/$_petPhotoExt', upsert: true),
          );

      return Supabase.instance.client.storage
          .from('pet-photos')
          .getPublicUrl(fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload error: $e'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        String? imageUrl = widget.pet.imageUrl;

        if (_petPhotoBytes != null) {
          imageUrl = await _uploadPhoto();
        }

        await Supabase.instance.client.from('pets').update({
          'name': _nameController.text.trim(),
          'species': _selectedSpecies,
          'gender': _selectedGender,
          'breed': _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
          'date_of_birth': _dateOfBirth?.toIso8601String(),
          'vaccinated': _selectedVaccinated == 'yes',
          'neutered': _selectedNeutered == 'yes',
          if (imageUrl != null) 'image_url': imageUrl,
        }).eq('id', widget.pet.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_nameController.text} updated successfully!',
                style: const TextStyle(fontFamily: PawsBaseTokens.fontFamily),
              ),
              backgroundColor: PawsBaseTokens.primaryDark,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating pet: $e'),
              backgroundColor: PawsBaseTokens.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
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
                'Delete Pet',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontWeight: FontWeight.w700,
                  color: PawsBaseTokens.error,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${widget.pet.name}? This action cannot be undone and all associated health logs and training data will be permanently removed.',
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
      await _deletePet();
    }
  }

  Future<void> _deletePet() async {
    setState(() => _isLoading = true);

    try {
      // Delete associated health logs first
      await Supabase.instance.client
          .from('health_logs')
          .delete()
          .eq('pet_id', widget.pet.id);

      // Delete associated training commands
      await Supabase.instance.client
          .from('training_commands')
          .delete()
          .eq('pet_id', widget.pet.id);

      // Delete the pet photo from storage if it exists
      if (widget.pet.imageUrl != null) {
        try {
          final uri = Uri.parse(widget.pet.imageUrl!);
          final fileName = uri.pathSegments.last;
          await Supabase.instance.client.storage
              .from('pet-photos')
              .remove([fileName]);
        } catch (_) {
          // Photo cleanup is best-effort
        }
      }

      // Delete the pet record
      await Supabase.instance.client
          .from('pets')
          .delete()
          .eq('id', widget.pet.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.pet.name} has been deleted.',
              style: const TextStyle(fontFamily: PawsBaseTokens.fontFamily),
            ),
            backgroundColor: PawsBaseTokens.primaryDark,
          ),
        );
        // Pop twice: once for EditPetPage, once for PetDetailPage
        Navigator.of(context).pop('deleted');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting pet: $e'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
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
        title: const Text(
          'Edit Pet',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: PawsBaseTokens.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Upload
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: PawsBaseTokens.surfaceBright,
                          border: Border.all(
                            color: PawsBaseTokens.outline.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _petPhotoBytes != null
                            ? Image.memory(_petPhotoBytes!, fit: BoxFit.cover)
                            : widget.pet.imageUrl != null
                                ? Image.network(widget.pet.imageUrl!, fit: BoxFit.cover)
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 32,
                                        color: PawsBaseTokens.outline.withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          fontFamily: PawsBaseTokens.fontFamily,
                                          fontSize: 12,
                                          color: PawsBaseTokens.outline.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap to change photo',
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 13,
                        color: PawsBaseTokens.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _FieldLabel('Name'),
                  const SizedBox(height: 8),
                  _PawsTextInput(
                    controller: _nameController,
                    hintText: 'E.g., Luna',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Species'),
                  const SizedBox(height: 8),
                  _TwoOptionToggle(
                    selected: _selectedSpecies,
                    optionA: 'dog',
                    labelA: 'Dog',
                    iconA: Icons.pets,
                    optionB: 'cat',
                    labelB: 'Cat',
                    iconB: Icons.pets,
                    onChanged: (val) => setState(() => _selectedSpecies = val),
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Gender'),
                  const SizedBox(height: 8),
                  _TwoOptionToggle(
                    selected: _selectedGender,
                    optionA: 'male',
                    labelA: 'Male',
                    iconA: Icons.male,
                    optionB: 'female',
                    labelB: 'Female',
                    iconB: Icons.female,
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Breed'),
                  const SizedBox(height: 8),
                  _PawsTextInput(
                    controller: _breedController,
                    hintText: 'E.g., Golden Retriever',
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Date of Birth'),
                  const SizedBox(height: 8),
                  _DatePickerField(
                    selectedDate: _dateOfBirth,
                    onTap: _pickDateOfBirth,
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Vaccinated?'),
                  const SizedBox(height: 8),
                  _TwoOptionToggle(
                    selected: _selectedVaccinated,
                    optionA: 'yes',
                    labelA: 'Yes',
                    iconA: Icons.check_circle_outline,
                    optionB: 'no',
                    labelB: 'No',
                    iconB: Icons.cancel_outlined,
                    onChanged: (val) => setState(() => _selectedVaccinated = val),
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Neutered / Spayed?'),
                  const SizedBox(height: 8),
                  _TwoOptionToggle(
                    selected: _selectedNeutered,
                    optionA: 'yes',
                    labelA: 'Yes',
                    iconA: Icons.check_circle_outline,
                    optionB: 'no',
                    labelB: 'No',
                    iconB: Icons.cancel_outlined,
                    onChanged: (val) => setState(() => _selectedNeutered = val),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PawsBaseTokens.primaryDark,
                        foregroundColor: PawsBaseTokens.onPrimary,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                        ),
                      ),
                      label: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      icon: _isLoading ? const SizedBox() : const Icon(Icons.save_rounded, size: 20),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Delete Pet Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _showDeleteConfirmation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PawsBaseTokens.error,
                        side: const BorderSide(color: PawsBaseTokens.error, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                        ),
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, size: 20),
                      label: const Text(
                        'Delete Pet',
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: PawsBaseTokens.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: PawsBaseTokens.onSurfaceVariant,
      ),
    );
  }
}

class _PawsTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const _PawsTextInput({
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(
        fontFamily: PawsBaseTokens.fontFamily,
        fontSize: 16,
        color: PawsBaseTokens.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: PawsBaseTokens.fontFamily,
          fontSize: 16,
          color: PawsBaseTokens.neutral,
        ),
        filled: true,
        fillColor: PawsBaseTokens.surfaceBright,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          borderSide: BorderSide(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          borderSide: BorderSide(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          borderSide: const BorderSide(color: PawsBaseTokens.primaryDark),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          borderSide: const BorderSide(color: PawsBaseTokens.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          borderSide: const BorderSide(color: PawsBaseTokens.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _TwoOptionToggle extends StatelessWidget {
  final String selected;
  final String optionA;
  final String labelA;
  final IconData iconA;
  final String optionB;
  final String labelB;
  final IconData iconB;
  final ValueChanged<String> onChanged;

  const _TwoOptionToggle({
    required this.selected,
    required this.optionA,
    required this.labelA,
    required this.iconA,
    required this.optionB,
    required this.labelB,
    required this.iconB,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleOption(
            label: labelA,
            icon: iconA,
            isSelected: selected == optionA,
            onTap: () => onChanged(optionA),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ToggleOption(
            label: labelB,
            icon: iconB,
            isSelected: selected == optionB,
            onTap: () => onChanged(optionB),
          ),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? PawsBaseTokens.primaryContainer.withValues(alpha: 0.4)
              : PawsBaseTokens.surfaceBright,
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          border: Border.all(
            color: isSelected
                ? PawsBaseTokens.primaryDark
                : PawsBaseTokens.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? PawsBaseTokens.primaryDark : PawsBaseTokens.neutral,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isSelected ? PawsBaseTokens.primaryDark : PawsBaseTokens.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const _DatePickerField({required this.selectedDate, required this.onTap});

  String get _displayText {
    if (selectedDate == null) return '';
    return '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: PawsBaseTokens.surfaceBright,
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _displayText.isEmpty ? 'Select a date' : _displayText,
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 16,
                  color: selectedDate == null
                      ? PawsBaseTokens.neutral
                      : PawsBaseTokens.onSurface,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: PawsBaseTokens.neutral,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}