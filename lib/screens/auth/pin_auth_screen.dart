import 'package:flutter/material.dart';
import 'package:industrial_monitor/screens/auth/login_screen.dart';
import 'package:industrial_monitor/screens/home/home_screen.dart';
import 'package:industrial_monitor/services/auth_service.dart';
import 'package:industrial_monitor/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class PinAuthScreen extends StatefulWidget {
  static const String routeName = '/pin-auth';

  const PinAuthScreen({Key? key}) : super(key: key);

  @override
  _PinAuthScreenState createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen> {
  final List<String> _pin = ['', '', '', ''];
  int _currentDigitIndex = 0;
  bool _isAuthenticating = false;
  bool _isError = false;
  String _errorMessage = '';
  int _attempts = 0;
  final int _maxAttempts = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: mediaQuery.size.height -
                  mediaQuery.padding.top -
                  mediaQuery.padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'PIN Authentication',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lock Icon and Title
                      Icon(
                        Icons.lock_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Enter Your PIN',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please enter your 4-digit PIN to access the app',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),

                      // PIN Indicator
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _pin[index].isNotEmpty
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                              border: Border.all(
                                color: _pin[index].isNotEmpty
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Error Message
                      if (_isError) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Attempts: $_attempts/$_maxAttempts',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],

                      // Keypad
                      const SizedBox(height: 36),
                      _buildNumericKeypad(context),

                      // Alternative Login
                      const SizedBox(height: 24),
                      CustomButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(LoginScreen.routeName);
                        },
                        text: 'Use Email Login',
                        // variant: ButtonVariant.secondary,
                      ),
                      const SizedBox(height: 16), // Added bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        ...List.generate(9, (index) => _buildKeypadButton('${index + 1}')),
        _buildForgotPinButton(context),
        _buildKeypadButton('0'),
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isAuthenticating ? null : () => _handleDigitInput(digit),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPinButton(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isAuthenticating ? null : _showForgotPinDialog,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.help_outline,
            color: theme.colorScheme.secondary,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isAuthenticating ? null : _handleBackspace,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _handleDigitInput(String digit) {
    if (_currentDigitIndex < 4) {
      setState(() {
        _pin[_currentDigitIndex] = digit;
        _currentDigitIndex++;
        _isError = false;
      });

      // When all 4 digits are entered, attempt authentication
      if (_currentDigitIndex == 4) {
        _authenticateWithPin();
      }
    }
  }

  void _handleBackspace() {
    if (_currentDigitIndex > 0) {
      setState(() {
        _currentDigitIndex--;
        _pin[_currentDigitIndex] = '';
        _isError = false;
      });
    }
  }

  Future<void> _authenticateWithPin() async {
    final enteredPin = _pin.join();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.verifyPin(enteredPin);

      if (success) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        _attempts++;
        setState(() {
          _isAuthenticating = false;
          _isError = true;
          _errorMessage = 'Incorrect PIN. Please try again.';
          _resetPin();
        });

        // If max attempts reached, go back to email login
        if (_attempts >= _maxAttempts) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Maximum attempts reached. Please use email login.'),
              duration: Duration(seconds: 3),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _isError = true;
        _errorMessage = 'Authentication failed';
        _resetPin();
      });
    }
  }

  void _resetPin() {
    setState(() {
      for (int i = 0; i < 4; i++) {
        _pin[i] = '';
      }
      _currentDigitIndex = 0;
    });
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
            'You will need to log in with your email and password to reset your PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/pin-reset');
            },
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}
