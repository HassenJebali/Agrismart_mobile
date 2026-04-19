import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'auth_service.dart';

/// Écran d'inscription en 2 étapes pour les agriculteurs (PRODUCTEUR)
/// Étape 1 : Remplir le formulaire → envoi du code par email
/// Étape 2 : Saisir le code à 6 chiffres → création du compte
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _codeSent = false; // true = étape 2

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Étape 1 — Demande l'envoi du code de vérification
  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).requestSignupCode(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Code envoyé à ${_emailController.text.trim()}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_mapError(e.toString()));
      }
    }
  }

  /// Étape 2 — Vérifie le code et finalise la création du compte
  Future<void> _verifyCode() async {
    if (_codeController.text.trim().length != 6) {
      _showError('Veuillez saisir le code à 6 chiffres reçu par email.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authServiceProvider).verifySignupCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (user != null) {
          ref.read(authStateProvider.notifier).state = user;
          context.go('/');
        } else {
          _showError('Code invalide ou expiré. Veuillez réessayer.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_mapError(e.toString()));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  String _mapError(String raw) {
    if (raw.contains('EMAIL_ALREADY_EXISTS')) return 'Cet email est déjà utilisé.';
    if (raw.contains('SIGNUP_CODE_EXPIRED')) return 'Le code a expiré. Relancez l\'inscription.';
    if (raw.contains('SIGNUP_CODE_INVALID')) return 'Code incorrect. Vérifiez votre email.';
    if (raw.contains('SIGNUP_CODE_NOT_FOUND')) return 'Aucun code trouvé. Relancez l\'inscription.';
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            if (_codeSent) {
              setState(() => _codeSent = false);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _codeSent ? _buildStep2() : _buildStep1(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.agriculture, size: 48, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Créer un compte agriculteur',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rejoignez AgriSmart — réservé aux producteurs',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildFieldRow(
            child1: _buildTextField(
              controller: _firstNameController,
              hint: 'Prénom',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            child2: _buildTextField(
              controller: _lastNameController,
              hint: 'Nom',
              icon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            hint: 'Adresse email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Email requis';
              if (!v.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Mot de passe (min. 8 caractères)',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Mot de passe requis';
              if (v.length < 8) return 'Minimum 8 caractères';
              if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(v)) {
                return 'Doit contenir au moins une lettre et un chiffre';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Un code de vérification sera envoyé à votre email.',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Recevoir le code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Déjà un compte ?'),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Se connecter', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Vérifiez votre email',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Saisissez le code à 6 chiffres envoyé à\n${_emailController.text.trim()}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 40),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12),
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(letterSpacing: 8, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Vérifier et créer le compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : () {
              setState(() {
                _codeSent = false;
                _codeController.clear();
              });
            },
            child: const Text('Renvoyer un nouveau code', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildFieldRow({required Widget child1, required Widget child2}) {
    return Row(
      children: [
        Expanded(child: child1),
        const SizedBox(width: 12),
        Expanded(child: child2),
      ],
    );
  }
}
