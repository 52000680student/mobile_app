import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final authLocalDataSource = getIt<AuthLocalDataSource>();
      final rememberMe = await authLocalDataSource.getRememberMe();

      if (rememberMe) {
        final credentials = await authLocalDataSource.getLoginCredentials();
        setState(() {
          _rememberMe = rememberMe;
          _usernameController.text = credentials['username'] ?? '';
          _passwordController.text = credentials['password'] ?? '';
        });
      }
    } catch (e) {
      // Handle error silently, use default values
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => _authBloc,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                context.go(AppRoutes.mainNavigation);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header with Illustration
                          SizedBox(
                            height: constraints.maxHeight * 0.35,
                            width: double.infinity,
                            child: _buildHeaderIllustration(),
                          ),

                          // Login Form
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    offset: Offset(0, -4),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Welcome Text
                                      Text(
                                        l10n.welcomeBack,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.onBackgroundColor,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),

                                      Text(
                                        l10n.signInToContinue,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: AppTheme.onSurfaceColor,
                                              fontSize: 16,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),

                                      // Username Field
                                      Text(
                                        l10n.username,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onBackgroundColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _usernameController,
                                        labelText: '',
                                        hintText: l10n.usernameHint,
                                        keyboardType: TextInputType.text,
                                        validator: _validateUsername,
                                      ),
                                      const SizedBox(height: 20),

                                      // Password Field
                                      Text(
                                        l10n.password,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.onBackgroundColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AuthTextField(
                                        controller: _passwordController,
                                        labelText: '',
                                        hintText: l10n.passwordHint,
                                        obscureText: !_isPasswordVisible,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppTheme.onSurfaceColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible =
                                                  !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                        validator: _validatePassword,
                                      ),
                                      const SizedBox(height: 16),

                                      // Remember Me Checkbox
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              activeColor:
                                                  AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            l10n.rememberMe,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.onSurfaceColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      // Login Button
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: const LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor,
                                                  AppTheme.primaryVariant,
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 8),
                                                  blurRadius: 24,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: state is AuthLoading
                                                  ? null
                                                  : () => _handleLogin(context),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: state is AuthLoading
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                    )
                                                  : Text(
                                                      l10n.login,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Flexible spacing instead of Spacer
                                      SizedBox(
                                          height: constraints.maxHeight > 700
                                              ? 32
                                              : 16),

                                      // Footer
                                      Text(
                                        '© 2025 IOLIS Solutions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.onSurfaceColor
                                              .withOpacity(0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
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
        ),
      ),
    );
  }

  Widget _buildHeaderIllustration() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FA), Color(0xFFE5E7EB)],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Image.asset(
            'assets/images/logo.png',
            height: 120,
            width: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.usernameRequired;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < AppConstants.minPasswordLength) {
      return l10n.passwordTooShort(AppConstants.minPasswordLength);
    }
    return null;
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _usernameController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }
}
