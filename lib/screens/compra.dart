import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:varlik_eventos/models/evento.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:varlik_eventos/utils/consts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TelaCompraIngresso extends StatefulWidget {
  final Evento evento;

  const TelaCompraIngresso({super.key, required this.evento});

  @override
  State<TelaCompraIngresso> createState() => _TelaCompraIngressoState();
}

class _TelaCompraIngressoState extends State<TelaCompraIngresso> {
  String _metodoPagamento = "pix";

  Future<Map<String, dynamic>> _fazerInscricao(Evento evento) async {
    final url = Uri.parse('$baseUrl/api/v1/inscricoes');
    final body = {
      "user_id":
          Provider.of<UsuarioProvider>(context, listen: false).usuario!.id,
      "evento_id": evento.id,
      "data_inscricao": DateTime.now().toIso8601String(),
      "status": "confirmado"
    };
    String? token = await getToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao criar inscrição: ${response.statusCode}');
    }
  }

  Future<void> _finalizarCompra(
      Map<String, dynamic> inscricao, Evento evento) async {
    final url = Uri.parse('$baseUrl/api/v1/pagamentos');
    String? token = await getToken();

    final Map<String, dynamic> dados = {
      "inscricao_id": inscricao['id'],
      "valor": evento.preco + 1.99,
      "metodo_pagamento": _metodoPagamento,
      "status": "pago",
      "data": DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dados),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Pagamento enviado com sucesso: ${response.body}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                "Compra Finalizada",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("OK"),
              ),
            ],
          ),
        ),
      );
    } else {
      throw Exception('Erro ao enviar pagamento: ${response.statusCode}');
    }
  }

  void _processarCompra(Evento evento) async {
    try {
      final inscricao = await _fazerInscricao(evento);
      await _finalizarCompra(inscricao, evento);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erro"),
          content: const Text(
              "Não foi possível processar a compra. Tente novamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  botaoMeioDePagamento(String tipo) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _metodoPagamento = tipo;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _metodoPagamento == tipo ? Colors.green : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/$tipo.jpg',
            width: 50,
            height: 30,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: EdgeInsets.all(isMobile ? 8 : 24),
            child: isMobile
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEventoInfo(isMobile),
                        const SizedBox(height: 24),
                        _buildCompraCard(isMobile),
                      ],
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildEventoInfo(isMobile),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: _buildCompraCard(isMobile),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventoInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: const Text("Voltar para eventos",
              style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            '$cloudFrontUrl${widget.evento.imagem}',
            height: isMobile ? 180 : 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(widget.evento.titulo,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text("Disponível",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(widget.evento.data,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(widget.evento.localizacao,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text("${widget.evento.capacidade} pessoas",
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const Text("Descrição do Evento",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text(widget.evento.descricao,
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        const Text("O que está incluído",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        ...[
          "Acesso completo ao evento",
          "Almoço e lanches",
          "Sessões de networking",
          "Materiais do evento"
        ].map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(item, style: const TextStyle(color: Colors.white)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCompraCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Selecionar Ingressos",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Text(
              "Valor do Ingresso: R\$ " +
                  widget.evento.preco.toStringAsFixed(2),
              style: const TextStyle(color: Colors.white)),
          const Text("Taxa de Serviço: R\$ 1,99",
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text("Total: R\$ " + (widget.evento.preco + 1.99).toStringAsFixed(2),
              style: const TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text("Método de Pagamento",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              botaoMeioDePagamento("pix"),
              botaoMeioDePagamento("cartao"),
              botaoMeioDePagamento("boleto"),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _processarCompra(widget.evento);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Finalizar Compra"),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 16, color: Colors.white38),
              SizedBox(width: 4),
              Text("Pagamento seguro via Stripe",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

popUpConfirmacao(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            "Compra Finalizada",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    ),
  );
}
