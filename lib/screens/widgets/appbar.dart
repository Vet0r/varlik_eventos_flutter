import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'package:varlik_eventos/screens/create_new_event.dart';
import 'package:varlik_eventos/screens/dashboard_admin.dart';
import 'package:varlik_eventos/screens/listar_compras.dart';
import 'package:varlik_eventos/screens/login.dart';
import 'package:varlik_eventos/screens/painel_eventos.dart';
import 'package:varlik_eventos/utils/consts.dart';

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
          onPressed: () async {
            final usuario =
                Provider.of<UsuarioProvider>(context, listen: false).usuario;
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(100, 80, 0, 0),
              items: [
                if (usuario != null && usuario.tipo == 'organizador')
                  PopupMenuItem(
                    value: 'painel_eventos',
                    child: Text('Painel de Eventos'),
                  ),
                if (usuario != null && usuario.tipo == 'organizador')
                  PopupMenuItem(
                    value: 'add_eventos',
                    child: Text('Adicionar Evento'),
                  ),
                if (usuario != null && usuario.tipo == 'administrador')
                  PopupMenuItem(
                    value: 'recursos_administrador',
                    child: Text('Recursos Administrativos'),
                  ),
                if (usuario != null && usuario.tipo == 'administrador')
                  PopupMenuItem(
                    value: 'painel_administrador',
                    child: Text('Painel do Administrador'),
                  ),
                PopupMenuItem(
                  value: 'minhas_compras',
                  child: Text('Minhas compras'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ).then((value) async {
              if (value == 'painel_eventos') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PainelOrganizador(),
                  ),
                );
              } else if (value == 'recursos_administrador') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DashboardAdminPage(),
                  ),
                );
              } else if (value == 'painel_administrador') {
                final Uri url = Uri.parse('$baseUrl/admin');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              } else if (value == 'minhas_compras') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PurchaseHistoryPage(),
                  ),
                );
              } else if (value == 'add_eventos') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdicionarEventoPage(),
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
