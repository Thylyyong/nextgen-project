import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen/app/theme/theme.dart';
import 'package:nextgen/auth/model/auth_model.dart';
import 'package:nextgen/auth/service/auth_service.dart';

/// RegisterPage — account creation screen.
///
/// On success: persists token and navigates to /home.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = GetIt.I<AuthService>();
      await authService.register(
        RegisterRequest(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ),
      );
      if (mounted) context.go('/home');
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'Registration failed';
      setState(() => _errorMessage = msg.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.screenBg,
      appBar: AppBar(
        backgroundColor: ColorTheme.screenBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: ColorTheme.neutral800, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create account', style: context.titleMedium),
                const Gap(8),
                Text('Join NextGen today', style: context.subtitleLarge),
                const Gap(32),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorTheme.statusRedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: ColorTheme.statusRed, size: 18),
                        const Gap(8),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: context.subtitleSmall
                                  .copyWith(color: ColorTheme.statusRed)),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                ],

                _buildField(
                  label: 'Full name',
                  controller: _nameCtrl,
                  hint: 'Your name',
                  prefixIcon: Icons.person_outline,
                  action: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Name is too short' : null,
                ),
                const Gap(16),
                _buildField(
                  label: 'Email address',
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  action: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const Gap(16),
                _buildField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  hint: 'Min 8 characters',
                  prefixIcon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  toggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  action: TextInputAction.done,
                  onSubmit: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Must be at least 8 characters';
                    return null;
                  },
                ),
                const Gap(32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.buttonPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Create Account',
                            style: context.subtitleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const Gap(20),
                Center(
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: context.subtitleSmall
                            .copyWith(color: ColorTheme.neutral600),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: context.subtitleSmall.copyWith(
                              color: ColorTheme.buttonLinkText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType type = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    void Function(String)? onSubmit,
    bool obscure = false,
    VoidCallback? toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.subtitleSmall.copyWith(
              color: ColorTheme.neutral800, fontWeight: FontWeight.w600),
        ),
        const Gap(6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          textInputAction: action,
          onFieldSubmitted: onSubmit,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: ColorTheme.neutral400, fontSize: 14),
            prefixIcon:
                Icon(prefixIcon, color: ColorTheme.neutral400, size: 20),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: ColorTheme.neutral400,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColorTheme.neutral200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColorTheme.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: ColorTheme.primary400, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColorTheme.statusRed),
            ),
          ),
        ),
      ],
    );
  }
}
