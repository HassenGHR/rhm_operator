import 'package:flutter/material.dart';
import 'package:industrial_monitor/services/auth_service.dart';
import 'package:industrial_monitor/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class PinAuthScreen extends StatefulWidget {
  static var routeName;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN Authentication'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Title and Instructions
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Enter Your PIN',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your 4-digit PIN to continue',
                      style: theme.textTheme.bodyLarge,
                    ),

                    // PIN Display
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _pin[index].isNotEmpty
                                ? theme.colorScheme.primary
                                : theme.disabledColor.withOpacity(0.3),
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
                  ],
                ),
              ),
            ),

            // PIN Keypad
            Expanded(
              flex: 7,
              child: Container(
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Digits 1-9
                          for (int i = 1; i <= 9; i++)
                            _buildKeypadButton(i.toString()),

                          // Forgot PIN Button
                          _buildActionButton(
                            icon: Icons.help_outline,
                            onTap: _showForgotPinDialog,
                            color: theme.colorScheme.secondary,
                          ),

                          // Digit 0
                          _buildKeypadButton('0'),

                          // Backspace Button
                          _buildActionButton(
                            icon: Icons.backspace_outlined,
                            onTap: _handleBackspace,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),

                    // Alternative Login
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        text: 'Use Email Login Instead',
                        // isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return InkWell(
      onTap: _isAuthenticating ? null : () => _handleDigitInput(digit),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: _isAuthenticating ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
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
        Navigator.of(context).pushReplacementNamed('/home');
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
