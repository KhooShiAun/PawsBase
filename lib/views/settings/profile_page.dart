import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/widgets/paws_button/paws_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDirty = false;

  // Preset Avatars for premium pet-owner themes
  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=200', // Corgi
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=200', // Cat
    'https://images.unsplash.com/photo-1537151608828-ea2b117b6b86?auto=format&fit=crop&q=80&w=200', // Dog
    'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&q=80&w=200', // Cat 2
    'https://images.unsplash.com/photo-1452570053594-1b985d6ea890?auto=format&fit=crop&q=80&w=200', // Parrot
    'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&q=80&w=200', // Bunny
  ];

  Map<String, dynamic> _initialData = {};

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    
    // Add listeners to check if values are dirty (modified)
    _nameController.addListener(_checkDirtyState);
    _usernameController.addListener(_checkDirtyState);
    _phoneController.addListener(_checkDirtyState);
    _bioController.addListener(_checkDirtyState);
    _avatarUrlController.addListener(_checkDirtyState);
  }

  void _loadProfileData() {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata ?? {};
      _initialData = {
        'full_name': metadata['full_name'] ?? '',
        'username': metadata['username'] ?? '',
        'phone': metadata['phone'] ?? '',
        'bio': metadata['bio'] ?? '',
        'avatar_url': metadata['avatar_url'] ?? '',
      };

      _nameController.text = _initialData['full_name'];
      _usernameController.text = _initialData['username'];
      _phoneController.text = _initialData['phone'];
      _bioController.text = _initialData['bio'];
      _avatarUrlController.text = _initialData['avatar_url'];
    }
    setState(() {
      _isLoading = false;
      _isDirty = false;
    });
  }

  void _checkDirtyState() {
    final nameChanged = _nameController.text.trim() != _initialData['full_name'];
    final usernameChanged = _usernameController.text.trim() != _initialData['username'];
    final phoneChanged = _phoneController.text.trim() != _initialData['phone'];
    final bioChanged = _bioController.text.trim() != _initialData['bio'];
    final avatarChanged = _avatarUrlController.text.trim() != _initialData['avatar_url'];

    final dirty = nameChanged || usernameChanged || phoneChanged || bioChanged || avatarChanged;
    if (dirty != _isDirty) {
      setState(() => _isDirty = dirty);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final fullName = _nameController.text.trim();
      final username = _usernameController.text.trim();
      final phone = _phoneController.text.trim();
      final bio = _bioController.text.trim();
      final avatarUrl = _avatarUrlController.text.trim();

      // CRUD: Update operation in database (auth.users metadata)
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'username': username,
            'phone': phone,
            'bio': bio,
            'avatar_url': avatarUrl,
          },
        ),
      );

      // Cache updated values as new initial values
      _initialData = {
        'full_name': fullName,
        'username': username,
        'phone': phone,
        'bio': bio,
        'avatar_url': avatarUrl,
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: PawsBaseTokens.primaryDark,
          ),
        );
        setState(() {
          _isDirty = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _resetProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text('Are you sure you want to clear your profile info? This will reset fields to empty.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: PawsBaseTokens.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        // CRUD: Delete/Clear profile data by setting attributes to empty strings
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': '',
              'username': '',
              'phone': '',
              'bio': '',
              'avatar_url': '',
            },
          ),
        );

        _nameController.clear();
        _usernameController.clear();
        _phoneController.clear();
        _bioController.clear();
        _avatarUrlController.clear();

        _initialData = {
          'full_name': '',
          'username': '',
          'phone': '',
          'bio': '',
          'avatar_url': '',
        };

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile reset successfully!'),
              backgroundColor: PawsBaseTokens.primaryDark,
            ),
          );
          setState(() {
            _isDirty = false;
            _isSaving = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reset profile: $e'),
              backgroundColor: PawsBaseTokens.error,
            ),
          );
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: PawsBaseTokens.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetAvatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final imageUrl = _presetAvatars[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarUrlController.text = imageUrl;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _avatarUrlController.text == imageUrl
                                ? PawsBaseTokens.primaryDark
                                : Colors.transparent,
                            width: 3,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Or Paste Custom Image URL:',
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.neutral,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _avatarUrlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/avatar.png',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _avatarUrlController.clear(),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: PawsButton(
                  text: 'Done',
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
        appBar: AppBar(
          backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) Navigator.pop(context);
            },
          ),
          title: Text(
            'Profile Information',
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: PawsBaseTokens.error),
              tooltip: 'Reset Profile',
              onPressed: _isSaving ? null : _resetProfile,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Card
                    const SizedBox(height: 16),
                    _buildAvatarSection(isDark, colorScheme),
                    const SizedBox(height: 32),

                    // Inputs Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Display Name'),
                          const SizedBox(height: 8),
                          _buildTextInput(
                            controller: _nameController,
                            hintText: 'Your full name',
                            icon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Display name is required';
                              }
                              if (v.trim().length < 3) {
                                return 'Must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Username'),
                          const SizedBox(height: 8),
                          _buildTextInput(
                            controller: _usernameController,
                            hintText: 'username',
                            icon: Icons.alternate_email,
                            prefixText: '@',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Username is required';
                              }
                              if (v.trim().length < 3) {
                                return 'Must be at least 3 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                                return 'Only alphanumeric and underscore';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Phone Number'),
                          const SizedBox(height: 8),
                          _buildTextInput(
                            controller: _phoneController,
                            hintText: 'e.g. +1234567890',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v != null && v.trim().isNotEmpty) {
                                if (!RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(v.trim())) {
                                  return 'Invalid phone number format';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Bio'),
                          const SizedBox(height: 8),
                          _buildTextInput(
                            controller: _bioController,
                            hintText: 'Tell us about yourself and your pets...',
                            icon: Icons.info_outline,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: PawsButton(
                        text: _isSaving ? 'Saving...' : 'Save Changes',
                        onPressed: _isDirty ? _saveProfile : () {},
                        type: _isDirty ? ButtonType.primary : ButtonType.secondary,
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark, ColorScheme colorScheme) {
    final avatarUrl = _avatarUrlController.text.trim();
    final hasAvatar = avatarUrl.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PawsBaseTokens.secondaryContainer.withValues(alpha: 0.4),
            border: Border.all(
              color: PawsBaseTokens.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: hasAvatar
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_outline,
                      size: 60,
                      color: PawsBaseTokens.primaryDark,
                    ),
                  )
                : const Icon(
                    Icons.person_outline,
                    size: 60,
                    color: PawsBaseTokens.primaryDark,
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showAvatarPicker,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: PawsBaseTokens.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: PawsBaseTokens.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: PawsBaseTokens.neutral,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: PawsBaseTokens.fontFamily,
        fontSize: 16,
        color: isDark ? Colors.white : PawsBaseTokens.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: PawsBaseTokens.fontFamily,
          fontSize: 15,
          color: PawsBaseTokens.neutral,
        ),
        prefixIcon: prefixText != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14),
                  Icon(icon, color: PawsBaseTokens.neutral, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    prefixText,
                    style: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PawsBaseTokens.neutral,
                    ),
                  ),
                ],
              )
            : Icon(icon, color: PawsBaseTokens.neutral, size: 20),
        filled: true,
        fillColor: isDark ? colorScheme.surface : PawsBaseTokens.surfaceBright,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PawsBaseTokens.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PawsBaseTokens.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PawsBaseTokens.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
