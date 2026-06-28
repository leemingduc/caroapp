import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../app_language.dart';
import '../supabase_config.dart';

class ProfileDialog extends StatefulWidget {
  final UserProfile userProfile;
  final AppLanguage language;

  const ProfileDialog({
    super.key,
    required this.userProfile,
    required this.language,
  });

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  AppText get _text => AppText(widget.language);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      // Step 1: Re-authenticate with current password
      await supabase.auth.signInWithPassword(
        email: widget.userProfile.email,
        password: _currentPasswordController.text,
      );

      // Step 2: Update the password
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text.changePasswordSuccess,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      if (!mounted) return;
      String errMsg = _text.changePasswordFailed;
      if (error.message.toLowerCase().contains('invalid login credentials')) {
        errMsg = _text.currentPasswordIncorrect;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text.changePasswordFailed,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.5),
      ),
      elevation: 24,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F2FE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.manage_accounts_rounded,
                          color: Color(0xFF00F2FE),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _text.profileTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── User email ──
                  Text(
                    widget.userProfile.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 24),

                  // ── Section title ──
                  Text(
                    _text.changePassword,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Current password ──
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: _text.currentPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return _text.currentPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── New password ──
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: _text.newPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return _text.newPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm new password ──
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: _text.confirmNewPassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return _text.confirmNewPasswordRequired;
                      }
                      if (value != _newPasswordController.text) {
                        return _text.passwordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Action buttons ──
                  Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.06),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                          ),
                          child: Text(
                            _text.cancel,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Submit
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00F2FE),
                            foregroundColor: Colors.black,
                            disabledBackgroundColor:
                                const Color(0xFF00F2FE).withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : Text(
                                  _text.confirm,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
