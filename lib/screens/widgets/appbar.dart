import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'package:varlik_eventos/screens/listar_compras.dart';
import 'package:varlik_eventos/screens/login.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2C2C2E),
      elevation: 0,
      titleSpacing: 20,
      actions: [
        const SizedBox(width: 12),
        Text(
          Provider.of<UsuarioProvider>(context, listen: false).usuario!.name,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundImage: NetworkImage(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Sample_User_Icon.png/600px-Sample_User_Icon.png',
          ),
          radius: 16,
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          onPressed: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(100, 80, 0, 0),
              items: [
                PopupMenuItem(
                  value: 'minhas_compras',
                  child: Text('Minhas compras'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ).then((value) {
              if (value == 'minhas_compras') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PurchaseHistoryPage(),
                  ),
                );
              } else if (value == 'logout') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF2C2C2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Confirmar Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'Você realmente deseja deslogar?',
                        style: TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Provider.of<UsuarioProvider>(context, listen: false)
                                .logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            });
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
