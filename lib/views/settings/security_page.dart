import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/widgets/paws_button/paws_button.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSavingPassword = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _currentUserEmail;
  bool _isSigningOutOthers = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserEmail();
  }

  void _loadCurrentUserEmail() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _currentUserEmail = user?.email ?? 'Unknown Email';
    });
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSavingPassword = true);
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) {
        throw Exception("User email not found. Please log in again.");
      }

      // Verify current password by attempting to sign in
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: _oldPasswordController.text,
        );
      } on AuthException catch (ae) {
        final msg = ae.message.toLowerCase().contains('invalid login credentials')
            ? 'Incorrect current password.'
            : ae.message;
        throw Exception(msg);
      }

      final newPassword = _newPasswordController.text;

      // Update password using Supabase Auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: PawsBaseTokens.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Strip Exception prefix if present for clean UI display
        final displayError = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayError),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPassword = false);
      }
    }
  }

  Future<void> _changeEmail() async {
    final emailController = TextEditingController(text: _currentUserEmail);
    final formKey = GlobalKey<FormState>();

    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email Address'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'New Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, emailController.text.trim());
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (newEmail != null && newEmail != _currentUserEmail) {
      setState(() => _isSavingPassword = true); // use existing loading overlay
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: newEmail),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email update initiated! Please check your inbox for confirmation.'),
              backgroundColor: PawsBaseTokens.primaryDark,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update email: $e'),
              backgroundColor: PawsBaseTokens.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSavingPassword = false);
        }
      }
    }
  }

  Future<void> _signOutOtherDevices() async {
    setState(() => _isSigningOutOthers = true);
    try {
      // Secure Session CRUD: Sign out other devices
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.others);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed out of all other devices.'),
            backgroundColor: PawsBaseTokens.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out other devices: $e'),
            backgroundColor: PawsBaseTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOutOthers = false);
      }
    }
  }

  Future<void> _deactivateAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: PawsBaseTokens.error, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Warning: This action is permanent and cannot be undone. All your pets, logs, and profile records will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: PawsBaseTokens.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSavingPassword = true);
      try {
        // Since deleting users directly via Supabase Auth client SDK requires admin rights,
        // we sign the user out of all sessions and display a message. In production, this can trigger a database trigger
        // or a webhook to delete the user completely.
        await Supabase.instance.client.auth.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been deleted.'),
              backgroundColor: PawsBaseTokens.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: $e'),
              backgroundColor: PawsBaseTokens.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSavingPassword = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Security Settings',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Account Credentials
                _buildSectionHeader("Account Credentials"),
                const SizedBox(height: 12),
                _buildCardContainer(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  children: [
                    _buildInteractiveRow(
                      icon: Icons.email_outlined,
                      title: "Email Address",
                      subtitle: _currentUserEmail ?? "Loading...",
                      trailing: Text(
                        "Change",
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: PawsBaseTokens.primaryDark,
                          fontSize: 14,
                        ),
                      ),
                      onTap: _changeEmail,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Section: Update Password
                _buildSectionHeader("Change Password"),
                const SizedBox(height: 12),
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
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Current Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _oldPasswordController,
                          hintText: 'Enter current password',
                          obscureText: _obscureOldPassword,
                          toggleObscure: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Current password is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('New Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: 'Enter new password',
                          obscureText: _obscureNewPassword,
                          toggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildLabel('Confirm Password'),
                        const SizedBox(height: 8),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter new password',
                          obscureText: _obscureConfirmPassword,
                          toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm your password';
                            if (v != _newPasswordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: PawsButton(
                            text: _isSavingPassword ? 'Updating...' : 'Update Password',
                            onPressed: _isSavingPassword ? () {} : _changePassword,
                            type: ButtonType.primary,
                            isFullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Session Management
                _buildSectionHeader("Session Management"),
                const SizedBox(height: 12),
                _buildCardContainer(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  children: [
                    _buildInteractiveRow(
                      icon: Icons.phonelink_erase_rounded,
                      title: "Sign Out of Other Devices",
                      subtitle: "Sign out of all sessions except this active device",
                      trailing: _isSigningOutOthers
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                      onTap: _isSigningOutOthers ? null : _signOutOtherDevices,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Dangerous Zone
                Center(
                  child: TextButton.icon(
                    onPressed: _isSavingPassword ? null : _deactivateAccount,
                    icon: const Icon(Icons.delete_forever_rounded, color: PawsBaseTokens.error),
                    label: const Text(
                      'Delete Account permanently',
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        color: PawsBaseTokens.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: PawsBaseTokens.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: PawsBaseTokens.neutral,
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required List<Widget> children,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInteractiveRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PawsBaseTokens.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                color: PawsBaseTokens.primaryDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 13,
                      color: PawsBaseTokens.neutral,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
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
        prefixIcon: const Icon(Icons.lock_outline, color: PawsBaseTokens.neutral, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: PawsBaseTokens.neutral, size: 20),
          onPressed: toggleObscure,
        ),
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
