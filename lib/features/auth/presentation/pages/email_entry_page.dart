import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/app_text_field.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import 'package:kora/features/auth/presentation/pages/otp_verification_page.dart';

/// Screen allowing the user to begin account linking by entering their email.
///
/// Designed to match the Amie UI kit design with ClashDisplay typography,
/// real-time email validation, disabled CTA state, and helpful support footer.
class EmailEntryPage extends StatefulWidget {
  /// Creates an [EmailEntryPage].
  const EmailEntryPage({super.key});

  @override
  State<EmailEntryPage> createState() => _EmailEntryPageState();
}

class _EmailEntryPageState extends State<EmailEntryPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValidEmail = false;

  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final text = _emailController.text.trim();
    final valid = _emailRegex.hasMatch(text);
    if (valid != _isValidEmail) {
      setState(() {
        _isValidEmail = valid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_isValidEmail) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthSendOtpRequested(_emailController.text.trim()),
    );
  }

  void _showAlreadyRegisteredDialog(BuildContext context, String email) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (bottomContext) => Container(
          decoration: const BoxDecoration(
            color: AppGreyColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Already Registered',
                style: AppTypography.h4Bold.copyWith(
                  color: AppGreyColors.shade1050,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This email is already associated with a Kora account. '
                'Verify via OTP to merge your recent scans and sign in.',
                style: AppTypography.bodyMRegular.copyWith(
                  color: AppGreyColors.shade700,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Continue with $email',
                onPressed: () {
                  Navigator.of(bottomContext).pop();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: OtpVerificationPage(email: email),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(bottomContext).pop(),
                  child: Text(
                    'Use another email',
                    style: AppTypography.bodyMRegular.copyWith(
                      color: AppGreyColors.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent) {
          final targetEmail = state.email ?? _emailController.text.trim();
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: OtpVerificationPage(email: targetEmail),
              ),
            ),
          );
        } else if (state.status == AuthStatus.emailAlreadyInUse) {
          _showAlreadyRegisteredDialog(
            context,
            state.email ?? _emailController.text.trim(),
          );
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 16,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Let`s get started with\nyour email',
                            style: AppTypography.h3Bold.copyWith(
                              color: AppGreyColors.shade1050,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'use your email to save progress and enjoy a\n'
                            'smooth experience with Amie',
                            style: AppTypography.bodyLRegular.copyWith(
                              color: AppGreyColors.shade700,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 36),
                          AppTextField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofocus: true,
                            semanticLabel: 'Email input field',
                            onFieldSubmitted: (_) => _handleContinue(),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: 'Continue',
                            height: 52,
                            isDisabled: !_isValidEmail,
                            isLoading: state.isLoading,
                            onPressed: _isValidEmail ? _handleContinue : null,
                          ),
                          const Spacer(),
                          const SizedBox(height: 16),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTypography.bodyMRegular.copyWith(
                                    color: AppGreyColors.shade700,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Need help? email us: ',
                                    ),
                                    TextSpan(
                                      text: 'care@amie.care',
                                      style: AppTypography.bodyMRegular
                                          .copyWith(
                                            color: AppGreyColors.shade1050,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
