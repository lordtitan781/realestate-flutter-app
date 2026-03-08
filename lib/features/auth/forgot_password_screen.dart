import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.forgotPassword(_emailCtrl.text.trim());
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent if account exists; check your email')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending OTP: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.resetPassword(_emailCtrl.text.trim(), _otpCtrl.text.trim(), _newPassCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset successful')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resetting password: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            if (_otpSent) ...[
              TextField(controller: _otpCtrl, decoration: const InputDecoration(labelText: 'Enter OTP')),
              const SizedBox(height: 12),
              TextField(controller: _newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _isLoading ? null : _resetPassword, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Reset Password'))
            ] else ...[
              ElevatedButton(onPressed: _isLoading ? null : _sendOtp, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send OTP'))
            ],
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
