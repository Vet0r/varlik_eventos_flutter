import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:varlik_eventos/models/merged_data.dart';
import 'package:varlik_eventos/models/pagamento.dart';
import 'package:varlik_eventos/models/inscricao.dart';
import 'package:varlik_eventos/utils/capitalize.dart';
import 'package:varlik_eventos/utils/consts.dart';
import 'package:varlik_eventos/utils/auth.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  List<MergedData> comprasPendentes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComprasPendentes();
  }

  Future<void> fetchComprasPendentes() async {
    setState(() => isLoading = true);
    final token = await getToken();

    final pagamentosResp = await http.get(
      Uri.parse('$baseUrl/api/v1/pagamentos'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final inscricoesResp = await http.get(
      Uri.parse('$baseUrl/api/v1/inscricoes'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (pagamentosResp.statusCode != 200 || inscricoesResp.statusCode != 200) {
      setState(() => isLoading = false);
      return;
    }

    final pagamentos = (jsonDecode(pagamentosResp.body) as List)
        .map((e) => Pagamento.fromJson(e))
        .toList();
    final inscricoes = (jsonDecode(inscricoesResp.body) as List)
        .map((e) => Inscricao.fromJson(e))
        .toList();

    List<MergedData> lista = [];
    for (final pagamento in pagamentos.where((p) => p.status == 'pendente')) {
      final inscricao = inscricoes.firstWhere(
        (i) => i.id == pagamento.inscricaoId,
        orElse: () => Inscricao(
          id: -1,
          eventoId: -1,
          userId: -1,
          status: '',
          dataInscricao: '',
        ),
      );
      if (inscricao.id == -1) continue;

      final eventoResp = await http.get(
        Uri.parse('$baseUrl/api/v1/eventos/${inscricao.eventoId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (eventoResp.statusCode != 200) continue;
      final evento = jsonDecode(eventoResp.body);

      final usuarioResp = await http.get(
        Uri.parse('$baseUrl/api/v1/usuarios/${inscricao.userId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (usuarioResp.statusCode != 200) continue;
      final usuario = jsonDecode(usuarioResp.body);

      lista.add(MergedData(
        eventoNome: evento['titulo'],
        data: pagamento.data,
        valor: pagamento.valor,
        categoria: evento['categoria'],
        localizacao: evento['localizacao'],
        pagamento: pagamento,
        inscricao: inscricao,
        emailUsuario: usuario['email'],
        nomeUsuario: usuario['nome'],
      ));
    }

    setState(() {
      comprasPendentes = lista;
      isLoading = false;
    });
  }

  Future<void> aprovarRembolso(MergedData compra) async {
    final token = await getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/pagamentos/${compra.pagamento.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'status': 'reembolsado'}),
    );
    await http.put(
      Uri.parse('$baseUrl/api/v1/inscricoes/${compra.inscricao.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'status': 'cancelado'}),
    );
    fetchComprasPendentes();
  }

  Future<void> rejeitarReembolso(MergedData compra) async {
    final token = await getToken();
    await http.put(
      Uri.parse('$baseUrl/api/v1/pagamentos/${compra.pagamento.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'status': 'pago'}),
    );
    await http.put(
      Uri.parse('$baseUrl/api/v1/inscricoes/${compra.inscricao.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'status': 'confirmado'}),
    );
    fetchComprasPendentes();
  }

  @override
  Widget build(BuildContext context) {
    final valorTotal = comprasPendentes.fold(0.0, (s, c) => s + c.valor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Scaffold(
          backgroundColor: const Color(0xFF1F1F1F),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Painel de Disputas',
                style: TextStyle(color: Colors.white)),
            centerTitle: false,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gerencie e revise compras pendentes',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      isMobile
                          ? Column(
                              children: [
                                _buildInfoCardMobile(
                                    'Compras Pendentes',
                                    comprasPendentes.length.toString(),
                                    '',
                                    Colors.amber),
                                const SizedBox(height: 8),
                                _buildInfoCardMobile(
                                    'Valor Total',
                                    'R\$ ${valorTotal.toStringAsFixed(2)}',
                                    'Aguardando aprovação',
                                    Colors.white),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: _buildInfoCard(
                                        'Compras Pendentes',
                                        comprasPendentes.length.toString(),
                                        '',
                                        Colors.amber)),
                                Expanded(
                                    child: _buildInfoCard(
                                        'Valor Total',
                                        'R\$ ${valorTotal.toStringAsFixed(2)}',
                                        'Aguardando aprovação',
                                        Colors.white)),
                              ],
                            ),
                      const SizedBox(height: 20),
                      const Text('Compras Pendentes',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF2A2A2A),
                          ),
                          child: Column(
                            children: [
                              _buildTableHeader(isMobile: isMobile),
                              Expanded(
                                child: comprasPendentes.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Nenhuma compra pendente',
                                          style:
                                              TextStyle(color: Colors.white54),
                                        ),
                                      )
                                    : isMobile
                                        ? SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              width: 700,
                                              child: ListView.builder(
                                                itemCount:
                                                    comprasPendentes.length,
                                                itemBuilder: (context, index) {
                                                  final compra =
                                                      comprasPendentes[index];
                                                  return _buildTableRow(compra,
                                                      isMobile: isMobile);
                                                },
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: comprasPendentes.length,
                                            itemBuilder: (context, index) {
                                              final compra =
                                                  comprasPendentes[index];
                                              return _buildTableRow(compra);
                                            },
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
      String title, String value, String subtitle, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader({bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFF333333),
      child: Row(
        children: [
          Expanded(
              child: Text('ID',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text('Evento',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text('Cliente',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text('Data',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text('Valor',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text('Status',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          SizedBox(
              width: isMobile ? 100 : 80,
              child: Text('Ação',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
        ],
      ),
    );
  }

  Widget _buildTableRow(MergedData compra, {bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text('#PUR-${compra.pagamento.id}',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text(compra.eventoNome,
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
            child: Row(
              children: [
                const CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compra.nomeUsuario ?? 'Cliente',
                      style: TextStyle(
                          color: Colors.white, fontSize: isMobile ? 12 : 14),
                    ),
                    Text(
                      compra.emailUsuario ?? '',
                      style: TextStyle(
                          color: Colors.white54, fontSize: isMobile ? 10 : 12),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
              child: Text(compra.data,
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
              child: Text('R\$ ${compra.valor.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14))),
          Expanded(
            child: Chip(
              label: Text(compra.pagamento.status.capitalize(),
                  style: TextStyle(
                      color: Colors.white, fontSize: isMobile ? 12 : 14)),
              backgroundColor: compra.pagamento.status == 'pendente'
                  ? Colors.orange
                  : compra.pagamento.status == 'aprovado'
                      ? Colors.green
                      : Colors.red,
            ),
          ),
          SizedBox(
            width: isMobile ? 100 : 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Text('Aprovar',
                      style: TextStyle(
                          color: Colors.green, fontSize: isMobile ? 10 : 14)),
                  onPressed: compra.pagamento.status == 'pendente'
                      ? () => aprovarRembolso(compra)
                      : null,
                ),
                IconButton(
                  icon: Text('Rejeitar',
                      style: TextStyle(
                          color: Colors.red, fontSize: isMobile ? 10 : 14)),
                  onPressed: compra.pagamento.status == 'pendente'
                      ? () => rejeitarReembolso(compra)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardMobile(
      String title, String value, String subtitle, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
