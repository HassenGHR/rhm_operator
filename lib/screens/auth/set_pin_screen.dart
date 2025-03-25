import 'package:flutter/material.dart';
import 'package:industrial_monitor/screens/home/home_screen.dart';
import 'package:industrial_monitor/services/auth_service.dart';
import 'package:provider/provider.dart';

class PinSetupScreen extends StatefulWidget {
  static const String routeName = '/pin-setup';

  const PinSetupScreen({Key? key}) : super(key: key);

  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final List<String> _pin = ['', '', '', ''];
  final List<String> _confirmPin = ['', '', '', ''];
  int _currentDigitIndex = 0;
  bool _isSetupMode = true;
  bool _isError = false;
  String _errorMessage = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Setup PIN',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock Icon and Title
                    Icon(
                      Icons.lock_open_rounded,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isSetupMode ? 'Create Your PIN' : 'Confirm Your PIN',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSetupMode
                          ? 'Create a 4-digit PIN for quick access'
                          : 'Please re-enter your PIN to confirm',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
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
                            color: _getCurrentPin()[index].isNotEmpty
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                            border: Border.all(
                              color: _getCurrentPin()[index].isNotEmpty
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
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Keypad
                    const SizedBox(height: 36),
                    _buildNumericKeypad(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCurrentPin() {
    return _isSetupMode ? _pin : _confirmPin;
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
        const SizedBox(), // Placeholder
        _buildKeypadButton('0'),
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isProcessing ? null : () => _handleDigitInput(digit),
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

  Widget _buildBackspaceButton() {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isProcessing ? null : _handleBackspace,
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
    final currentPin = _getCurrentPin();
    final currentIndex = _currentDigitIndex;

    if (currentIndex < 4) {
      setState(() {
        currentPin[currentIndex] = digit;
        _currentDigitIndex++;
        _isError = false;
      });

      // When all 4 digits are entered
      if (_currentDigitIndex == 4) {
        if (_isSetupMode) {
          // Switch to confirmation mode
          setState(() {
            _isSetupMode = false;
            _currentDigitIndex = 0;
          });
        } else {
          // Verify PIN
          _validateAndSavePin();
        }
      }
    }
  }

  void _handleBackspace() {
    final currentPin = _getCurrentPin();

    if (_currentDigitIndex > 0) {
      setState(() {
        _currentDigitIndex--;
        currentPin[_currentDigitIndex] = '';
        _isError = false;
      });
    } else if (!_isSetupMode) {
      // Go back to setup mode if in confirmation mode
      setState(() {
        _isSetupMode = true;
        _currentDigitIndex = 4;
      });
    }
  }

  Future<void> _validateAndSavePin() async {
    setState(() {
      _isProcessing = true;
    });

    // Check if PINs match
    if (_pin.join() == _confirmPin.join()) {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.setPin(_pin.join());

        if (success) {
          // Navigate to home or next screen
          Navigator.of(context).pushNamed(HomeScreen.routeName);
        } else {
          setState(() {
            _isError = true;
            _errorMessage = 'Failed to set PIN. Please try again.';
            _resetPins();
          });
        }
      } catch (e) {
        setState(() {
          _isError = true;
          _errorMessage = 'An error occurred. Please try again.';
          _resetPins();
        });
      }
    } else {
      setState(() {
        _isError = true;
        _errorMessage = 'PINs do not match. Please try again.';
        _resetPins();
      });
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _resetPins() {
    setState(() {
      _pin.fillRange(0, 4, '');
      _confirmPin.fillRange(0, 4, '');
      _currentDigitIndex = 0;
      _isSetupMode = true;
    });
  }
}
