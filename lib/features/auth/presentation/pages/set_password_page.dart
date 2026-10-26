import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/core/router/app_routes.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';

/// Screen allowing the user to configure their password after OTP confirmation.
class SetPasswordPage extends StatefulWidget {
  /// Creates a [SetPasswordPage].
  const SetPasswordPage({super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validateInputs);
    _confirmPasswordController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final pwd = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final valid = pwd.length >= 8 && pwd == confirm;
    if (valid != _isFormValid) {
      setState(() {
        _isFormValid = valid;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthSetPasswordRequested(_passwordController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppPrimaryColors.shade700,
              content: Text(
                'Account secured successfully! Welcome to Kora.',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
          );
          // O19: Route to Home dashboard
          context.go(AppRoutes.home);
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppErrorColors.shade500,
              content: Text(
                state.errorMessage!,
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.white,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppGreyColors.shade1050,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
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
                    const SizedBox(height: 8),
                    Text(
                      'Create a password',
                      style: AppTypography.h3Bold.copyWith(
                        color: AppGreyColors.shade1050,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose a secure password (min. 8 characters) to '
                      'protect your skin scans and progress history.',
                      style: AppTypography.bodyLRegular.copyWith(
                        color: AppGreyColors.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _passwordController,
                      hintText: 'Enter new password',
                      labelText: 'Password',
                      isPassword: true,
                      autofocus: true,
                      semanticLabel: 'New password field',
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm new password',
                      labelText: 'Confirm Password',
                      isPassword: true,
                      semanticLabel: 'Confirm password field',
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Save & Finish',
                      height: 52,
                      isDisabled: !_isFormValid,
                      isLoading: state.isLoading,
                      onPressed: _isFormValid ? _handleSubmit : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
