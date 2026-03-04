import 'package:flutter/material.dart';
import '../investor/investor_shell.dart';
import '../landowner/landowner_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String role = "Investor";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Tourism Investment Platform",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(
              value: role,
              items: const [
                DropdownMenuItem(
                  value: "Investor",
                  child: Text("Investor"),
                ),
                DropdownMenuItem(
                  value: "Landowner",
                  child: Text("Landowner"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  role = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                if (role == "Investor") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InvestorShell()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LandownerShell()),
                  );
                }
              },
              child: const Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}