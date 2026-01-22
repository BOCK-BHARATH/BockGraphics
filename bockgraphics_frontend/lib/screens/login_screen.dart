import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth/token_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate() || loading) return;
    setState(() => loading = true);

    try {
      final base = dotenv.env["API_BASE_URL"]!;
      final url = Uri.parse("$base/auth/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passController.text,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception("Login failed (${res.statusCode})");
      }

      final json = jsonDecode(res.body);
      final token = json["token"] as String?;
      if (token == null || token.isEmpty) throw Exception("No token returned");

      await getTokenStore().save(token);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email"),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: "Enter email"),
                    validator: (v) => v == null || v.isEmpty ? "Enter email" : null,
                  ),
                  const SizedBox(height: 12),
                  const Text("Password"),
                  TextFormField(
                    controller: passController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "Enter password"),
                    validator: (v) => v == null || v.isEmpty ? "Enter password" : null,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("LOGIN"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
