import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'package:varlik_eventos/screens/create_account.dart';
import 'package:varlik_eventos/screens/home.dart';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:varlik_eventos/utils/consts.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;
  @override
  void initState() {
    super.initState();
    _checkToken();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _checkToken() async {
    setState(() {
      isLoading = true;
    });
    final token = await getToken();
    Provider.of<UsuarioProvider>(context, listen: false).loadUsuario();
    if (token != null) {
      bool isValid = await validateToken(token);
      if (isValid) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.confirmation_num, size: 40, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Bem Vindo ao Eventos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Login',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await login(
                        _emailController.text, _passwordController.text);
                    final token = await getToken();
                    if (token != null) {
                      await Provider.of<UsuarioProvider>(context, listen: false)
                          .loadUsuario();
                      if (Provider.of<UsuarioProvider>(context, listen: false)
                              .usuario !=
                          null) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Erro ao carregar usuário. Tente novamente.'),
                          ),
                        );
                      }
                    }
                  },
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text('Entrar'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Criar',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/api/v1/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      saveToken(token);
    } else {
      print('Erro no login: ${response.body}');
    }
  } catch (e) {
    print('Erro ao conectar à API: $e');
  }
}
