import 'package:flutter/material.dart';
import '../app_language.dart';
import '../models/user_profile.dart';
import '../services/db_service.dart';

class SetUsernameDialog extends StatefulWidget {
  final UserProfile userProfile;
  final AppLanguage language;
  final Function(UserProfile) onUsernameUpdated;
  final bool isMandatory; // true if setting name for the first time, prevents closing dialog

  const SetUsernameDialog({
    super.key,
    required this.userProfile,
    required this.language,
    required this.onUsernameUpdated,
    this.isMandatory = false,
  });

  @override
  State<SetUsernameDialog> createState() => _SetUsernameDialogState();
}

class _SetUsernameDialogState extends State<SetUsernameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  AppText get _text => AppText(widget.language);

  @override
  void initState() {
    super.initState();
    if (widget.userProfile.displayName != null) {
      _usernameController.text = widget.userProfile.displayName!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    final inputName = _usernameController.text.trim();
    if (inputName == widget.userProfile.displayName) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedProfile = await DbService.setDisplayName(
        widget.userProfile.id,
        inputName,
      );

      if (updatedProfile != null) {
        widget.onUsernameUpdated(updatedProfile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _text.displayNameSuccess,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = _text.authRequestFailed;
        });
      }
    } catch (e) {
      final errorMsg = e.toString();
      setState(() {
        if (errorMsg.contains('Display name already taken') || errorMsg.contains('already taken')) {
          _errorMessage = _text.displayNameTaken;
        } else if (errorMsg.contains('Not enough diamonds')) {
          _errorMessage = _text.reviveNoDiamonds;
        } else if (errorMsg.contains('between 4 and 20') || errorMsg.contains('20 characters')) {
          _errorMessage = _text.displayNameLengthError;
        } else {
          _errorMessage = _text.authRequestFailed;
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cost = DbService.getRenameCost(widget.userProfile.renameCount);
    final bool isFree = cost == 0;

    return WillPopScope(
      onWillPop: () async => !widget.isMandatory, // Prevent back button if mandatory
      child: Dialog(
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
                            Icons.badge_rounded,
                            color: Color(0xFF00F2FE),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            widget.isMandatory ? _text.enterUsername : _text.changeDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Cost Description
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFree ? Colors.green.withOpacity(0.08) : Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFree ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isFree ? Icons.check_circle_outline_rounded : Icons.diamond_rounded,
                            color: isFree ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isFree ? _text.displayNameFree : _text.displayNameCost(cost),
                              style: TextStyle(
                                color: isFree ? Colors.greenAccent : Colors.orangeAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isFree) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          _text.balance(widget.userProfile.diamonds),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Input Field
                    TextFormField(
                      controller: _usernameController,
                      maxLength: 20,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: _text.displayName,
                        hintText: '4 – 20 ký tự bất kỳ',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 1.5),
                        ),
                        counterText: "",
                      ),
                      validator: (value) {
                        final trimmed = (value ?? '').trim();
                        if (trimmed.isEmpty) {
                          return _text.displayNameRequired;
                        }
                        if (trimmed.length < 4 || trimmed.length > 20) {
                          return _text.displayNameLengthError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Error text
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        if (!widget.isMandatory) ...[
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
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00F2FE),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: const Color(0xFF00F2FE).withOpacity(0.5),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
      ),
    );
  }
}
