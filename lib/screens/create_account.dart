import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varlik_eventos/utils/consts.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool aceitarTermos = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 48,
              vertical: isMobile ? 24 : 48,
            ),
            constraints: BoxConstraints(
              maxWidth: isMobile ? 500 : 600,
              minWidth: isMobile ? 0 : 400,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
              boxShadow: isMobile
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.confirmation_num, size: 40, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Criar Conta',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Junte-se ao Events hoje',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Color(0xFF3A3A3A),
                          labelStyle: TextStyle(color: Colors.white),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    if (!isMobile) const SizedBox(width: 8),
                    if (!isMobile)
                      Expanded(
                        child: TextFormField(
                          controller: sobrenomeController,
                          decoration: const InputDecoration(
                            labelText: 'Sobrenome',
                            prefixIcon: Icon(Icons.person),
                            filled: true,
                            fillColor: Color(0xFF3A3A3A),
                            labelStyle: TextStyle(color: Colors.white),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                if (isMobile) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: sobrenomeController,
                    decoration: const InputDecoration(
                      labelText: 'Sobrenome',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Color(0xFF3A3A3A),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Color(0xFF3A3A3A),
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Color(0xFF3A3A3A),
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmarSenhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Color(0xFF3A3A3A),
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: aceitarTermos,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          aceitarTermos = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Eu aceito os ',
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: 'Termos ',
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(
                              text: 'e a ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: aceitarTermos
                        ? () async {
                            if (senhaController.text !=
                                confirmarSenhaController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'As senhas não coincidem.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                              return;
                            }
                            await register(
                              '${nomeController.text} ${sobrenomeController.text}',
                              emailController.text,
                              senhaController.text,
                              confirmarSenhaController.text,
                            ).then((_) {
                              Navigator.pop(context);
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Criar Conta'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Já tem uma conta? Entrar',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> register(
    String name, String email, String password, String passwordConf) async {
  final url = Uri.parse('$baseUrl/api/v1/register');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'tipo': 'inscrito',
      }),
    );

    if (response.statusCode == 201) {
      print('Conta criada com sucesso!');
    } else {
      print('Erro ao criar conta: ${response.body}');
    }
  } catch (e) {
    print('Erro ao conectar à API: $e');
  }
}
