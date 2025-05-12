import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:varlik_eventos/models/evento.dart';
import 'package:varlik_eventos/models/inscricao.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'package:varlik_eventos/screens/widgets/appbar.dart';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:varlik_eventos/utils/consts.dart';

class PainelOrganizador extends StatefulWidget {
  const PainelOrganizador({super.key});

  @override
  _PainelOrganizadorState createState() => _PainelOrganizadorState();
}

class _PainelOrganizadorState extends State<PainelOrganizador> {
  List<Evento> eventos = [];
  List<Inscricao> inscricoes = [];
  double totalGanhos = 0.0;
  double ganhosReais = 0.0;
  int totalParticipantes = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
    _fetchInscricoes();
  }

  Future<void> _fetchEventos() async {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final usuario = usuarioProvider.usuario;

    if (usuario == null) return;

    try {
      final token = await getToken();
      if (token == null) throw Exception('Token não encontrado');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/eventos?organizadorId=${usuario.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final eventosCarregados = data.map((e) => Evento.fromJson(e)).toList();

        setState(() {
          eventos = eventosCarregados;
          totalGanhos = eventos.fold(
              0.0, (soma, evento) => soma + evento.preco * evento.capacidade);
          totalParticipantes =
              eventos.fold(0, (soma, evento) => soma + evento.capacidade);
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar eventos: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erro: $e');
    }
  }

  Future<void> _fetchInscricoes() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token não encontrado');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/inscricoes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final inscricoesCarregadas =
            data.map((e) => Inscricao.fromJson(e)).toList();

        setState(() {
          inscricoes = inscricoesCarregadas;
          ganhosReais = _calcularGanhosReais();
        });
      } else {
        throw Exception('Erro ao carregar inscrições: ${response.body}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  double _calcularGanhosReais() {
    double somaGanhos = 0.0;

    for (var evento in eventos) {
      final inscricoesConfirmadas = inscricoes.where((inscricao) =>
          inscricao.eventoId == evento.id && inscricao.status == 'confirmado');

      final totalPorEvento = inscricoesConfirmadas.length * evento.preco;
      somaGanhos += totalPorEvento;
    }

    return somaGanhos;
  }

  int _calcularParticipantesReais() {
    return inscricoes
        .where((inscricao) => inscricao.status == 'confirmado')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final usuario = usuarioProvider.usuario;

    if (usuario == null) {
      return const Center(
        child: Text('Usuário não logado'),
      );
    }

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: CustomTopBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Aqui está o resumo dos seus eventos",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(Icons.event, 'Total de Eventos',
                      eventos.length.toString()),
                  _buildStatCard(Icons.people, 'Participantes Potenciais',
                      totalParticipantes.toString()),
                  _buildStatCard(
                    Icons.people_alt,
                    'Participantes Reais',
                    _calcularParticipantesReais().toStringAsFixed(0),
                  ),
                  _buildStatCard(
                    Icons.attach_money,
                    'Ganhos Potenciais',
                    'R\$${totalGanhos.toStringAsFixed(2)}',
                  ),
                  _buildStatCard(
                    Icons.attach_money,
                    'Ganhos Reais',
                    'R\$${ganhosReais.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Próximos Eventos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: eventos
                      .map((evento) => _buildEventoCard(evento))
                      .toList(),
                ),
              ),
              const SizedBox(height: 30),
              const Text("Atividades Recentes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildActivityCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String titulo, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 12),
            Text(titulo, style: const TextStyle(color: Colors.grey)),
            Text(valor,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventoCard(Evento evento) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(evento.titulo,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(evento.descricao, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Data: ${evento.data}',
                style: const TextStyle(color: Colors.grey)),
            Text('Local: ${evento.localizacao}',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    final atividadesConfirmadas = inscricoes
        .where((inscricao) => inscricao.status == 'confirmado')
        .toList();

    atividadesConfirmadas
        .sort((a, b) => b.dataInscricao.compareTo(a.dataInscricao));

    final atividades = atividadesConfirmadas.map((inscricao) {
      final evento = eventos.firstWhere(
        (evento) => evento.id == inscricao.eventoId,
        orElse: () => Evento(
          id: -1,
          titulo: 'Evento desconhecido',
          descricao: '',
          data: '',
          localizacao: '',
          categoria: '',
          organizadorId: 0,
          capacidade: 0,
          preco: 0.0,
          createdAt: '',
          updatedAt: '',
          imagem: '',
        ),
      );

      return ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text('Inscrição confirmada',
            style: const TextStyle(color: Colors.white)),
        subtitle:
            Text(evento.titulo, style: const TextStyle(color: Colors.grey)),
        trailing: Text('R\$${evento.preco.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white)),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: atividades.isNotEmpty
            ? atividades
            : [
                const Center(
                  child: Text('Nenhuma atividade recente',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
      ),
    );
  }
}
