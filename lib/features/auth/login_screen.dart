import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';
import '../../services/api_service.dart'; // network helpers
import '../investor/investor_shell.dart';
import '../landowner/landowner_shell.dart';
import '../admin/admin_shell.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  String _role = "INVESTOR";
  String? _emailError;
  String? _passwordError;

  void _submit() async {
    // basic validation
    if (!_validateForm()) return;

    final appState = context.read<AppState>();
    bool success;
    if (_isLogin) {
      success = await appState.login(_emailCtrl.text.trim(), _passwordCtrl.text, role: _role);
    } else {
      success = await appState.register(_emailCtrl.text.trim(), _passwordCtrl.text, _role);
    }

    if (success) {
      final role = appState.currentUserRole?.toUpperCase();
      if (role == "INVESTOR") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InvestorShell()));
      } else if (role == "LANDOWNER") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LandownerShell()));
      } else if (role == "ADMIN") {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Authentication Failed")));
    }
  }

  bool _validateForm() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    String? eErr;
    String? pErr;

    final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    if (email.isEmpty) {
      eErr = 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      eErr = 'Enter a valid email address';
    }

    if (password.isEmpty) {
      pErr = 'Password is required';
    } else if (password.length < 6) {
      pErr = 'Password must be at least 6 characters';
    }

    setState(() {
      _emailError = eErr;
      _passwordError = pErr;
    });

    return eErr == null && pErr == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, size: 80, color: Color(0xFF1A237E)),
                  const SizedBox(height: 24),
                  Text("Investify", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(_isLogin ? "Welcome Back" : "Create Account", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_emailError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline)),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_passwordError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: "INVESTOR", child: Text("Investor")),
                      DropdownMenuItem(value: "LANDOWNER", child: Text("Landowner")),
                      DropdownMenuItem(value: "ADMIN", child: Text("Admin")),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? "INVESTOR"),
                    decoration: const InputDecoration(labelText: "Role", prefixIcon: Icon(Icons.person_outline)),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: context.watch<AppState>().isLoading ? null : _submit,
                      child: context.watch<AppState>().isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(_isLogin ? "Sign In" : "Sign Up"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In"),
                  ),
                  if (_isLogin)
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: const Text("Forgot Password?"),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
