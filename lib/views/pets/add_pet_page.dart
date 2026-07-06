import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  
  bool _isLoading = false;

  String _selectedSpecies = 'dog';
  String _selectedGender = 'male';
  String _selectedVaccinated = 'no';
  String _selectedNeutered = 'no';
  DateTime? _adoptionDate;
  DateTime? _dateOfBirth;

  Future<void> _pickAdoptionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _adoptionDate = picked);
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to add a pet.'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await Supabase.instance.client.from('pets').insert({
          'user_id': userId,
          'name': _nameController.text.trim(),
          'species': _selectedSpecies,
          'gender': _selectedGender,
          'breed': _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
          'weight': _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
          'date_of_birth': _dateOfBirth?.toIso8601String(),
          'adoption_date': _adoptionDate?.toIso8601String(),
          'vaccinated': _selectedVaccinated == 'yes',
          'neutered': _selectedNeutered == 'yes',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_nameController.text} added to the family!',
                style: const TextStyle(fontFamily: PawsBaseTokens.fontFamily),
              ),
              backgroundColor: PawsBaseTokens.primaryDark,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding pet: $e'),
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
          'Add New Pet',
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
                  Center(
                    child: Text(
                      "Welcome to the family. Let's start with the basics.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: PawsBaseTokens.onSurfaceVariant,
                        height: 1.8,
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

                  _FieldLabel('Weight (kg)'),
                  const SizedBox(height: 8),
                  _PawsTextInput(
                    controller: _weightController,
                    hintText: 'E.g., 12.5',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Date of Birth'),
                  const SizedBox(height: 8),
                  _DatePickerField(
                    selectedDate: _dateOfBirth,
                    onTap: _pickDateOfBirth,
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel('Adoption Date'),
                  const SizedBox(height: 8),
                  _DatePickerField(
                    selectedDate: _adoptionDate,
                    onTap: _pickAdoptionDate,
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : const Text(
                            'Add to Family',
                            style: TextStyle(
                              fontFamily: PawsBaseTokens.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      icon: _isLoading ? const SizedBox() : const Icon(Icons.favorite_rounded, size: 20),
                      iconAlignment: IconAlignment.end,
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
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _PawsTextInput({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
          color: isSelected ? PawsBaseTokens.primaryContainer.withValues(alpha: 0.4) : PawsBaseTokens.surfaceBright,
          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
          border: Border.all(
            color: isSelected ? PawsBaseTokens.primaryDark : PawsBaseTokens.outline.withValues(alpha: 0.2),
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
                  color: selectedDate == null ? PawsBaseTokens.neutral : PawsBaseTokens.onSurface,
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