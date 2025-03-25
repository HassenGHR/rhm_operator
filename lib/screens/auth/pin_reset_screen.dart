import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../utils/validators.dart';

class PinResetScreen extends StatefulWidget {
  static const String routeName = '/pin-reset';

  const PinResetScreen({Key? key}) : super(key: key);

  @override
  _PinResetScreenState createState() => _PinResetScreenState();
}

class _PinResetScreenState extends State<PinResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _hasCurrentPin = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _toggleHasCurrentPin(bool value) {
    setState(() {
      _hasCurrentPin = value;
      if (!_hasCurrentPin) {
        _currentPinController.clear();
      }
    });
  }

  Future<void> _resetPin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_hasCurrentPin) {
        // Reset PIN with current PIN verification
        await _authService.resetPin(
          // _emailController.text.trim(),
          // _currentPinController.text.trim(),
          _newPinController.text.trim(),
        );
      } else {
        // Reset PIN using email verification
        await _authService.sendPinResetEmail(
            // _emailController.text.trim(),
            // _newPinController.text.trim(),
            );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN has been reset successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset PIN: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset PIN'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Reset Your 4-Digit PIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomInput(
                  controller: _emailController,
                  hintText: 'Your Email',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email',
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('I remember my current PIN'),
                  value: _hasCurrentPin,
                  onChanged: _toggleHasCurrentPin,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                if (_hasCurrentPin)
                  CustomInput(
                    controller: _currentPinController,
                    hintText: 'Current 4-Digit PIN',
                    prefixIcon: Icons.lock_outline,
                    validator: Validators.validatePin,
                    keyboardType: TextInputType.number,
                    // maxLength: 4,
                    // isPassword: true,
                    label: 'Current PIN',
                  ),
                const SizedBox(height: 16),
                CustomInput(
                  controller: _newPinController,
                  hintText: 'New 4-Digit PIN',
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePin,
                  keyboardType: TextInputType.number,
                  // maxLength: 4,
                  // isPassword: true,
                  label: 'New PIN',
                ),
                const SizedBox(height: 16),
                CustomInput(
                  controller: _confirmPinController,
                  hintText: 'Confirm New PIN',
                  prefixIcon: Icons.lock_outline,
                  validator: (value) => Validators.validateConfirmPin(
                    value,
                    _newPinController.text,
                  ),
                  keyboardType: TextInputType.number,
                  // maxLength: 4,
                  // isPassword: true,
                  label: 'Confirm PIN',
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: _isLoading ? null : _resetPin,
                  text: 'Reset PIN',
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                if (!_hasCurrentPin)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Note: A verification email will be sent to reset your PIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
