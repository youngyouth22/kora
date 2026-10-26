import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kora/common/app_colors.dart';
import 'package:kora/common/app_typography.dart';
import 'package:kora/common/widgets/primary_button.dart';
import 'package:kora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kora/features/auth/presentation/bloc/auth_event.dart';
import 'package:kora/features/auth/presentation/bloc/auth_state.dart';
import 'package:kora/features/auth/presentation/pages/set_password_page.dart';
import 'package:pinput/pinput.dart';

/// Screen allowing the user to enter the 6-digit OTP code sent to their email.
class OtpVerificationPage extends StatefulWidget {
  /// Creates an [OtpVerificationPage].
  const OtpVerificationPage({
    required this.email,
    this.autoStartTimer = true,
    super.key,
  });

  /// The email address receiving the OTP code.
  final String email;

  /// Whether to auto-start the resend countdown timer.
  final bool autoStartTimer;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  Timer? _resendTimer;
  int _secondsRemaining = 45;

  @override
  void initState() {
    super.initState();
    if (widget.autoStartTimer) {
      _startResendTimer();
    } else {
      _secondsRemaining = 0;
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 45;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _submitCode(String pin) {
    if (pin.length < 6) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(email: widget.email, token: pin),
    );
  }

  void _resendCode() {
    if (_secondsRemaining > 0) return;
    context.read<AuthBloc>().add(AuthSendOtpRequested(widget.email));
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTypography.h4Bold.copyWith(
        color: AppGreyColors.shade1050,
      ),
      decoration: BoxDecoration(
        color: AppGreyColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppGreyColors.shade400,
          width: 1.2,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: AppPrimaryColors.shade500,
          width: 1.6,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: AppPrimaryColors.shade600,
          width: 1.4,
        ),
      ),
    );

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpVerified) {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: const SetPasswordPage(),
              ),
            ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Verify your email',
                    style: AppTypography.h3Bold.copyWith(
                      color: AppGreyColors.shade1050,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the 6-digit code sent to\n${widget.email}',
                    style: AppTypography.bodyLRegular.copyWith(
                      color: AppGreyColors.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: Material(
                      type: MaterialType.transparency,
                      child: Pinput(
                        length: 6,
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        autofocus: true,
                        onCompleted: _submitCode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    text: 'Verify Code',
                    height: 52,
                    isLoading: state.isLoading,
                    onPressed: () => _submitCode(_pinController.text),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _secondsRemaining == 0 ? _resendCode : null,
                      child: Text(
                        _secondsRemaining > 0
                            ? 'Resend code in ${_secondsRemaining}s'
                            : 'Resend code',
                        style: AppTypography.bodyMRegular.copyWith(
                          color: _secondsRemaining == 0
                              ? AppPrimaryColors.shade700
                              : AppGreyColors.shade600,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
