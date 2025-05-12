import 'package:flutter/material.dart';
import 'package:varlik_eventos/screens/home.dart';
import 'package:varlik_eventos/screens/widgets/info_row.dart';
import 'package:varlik_eventos/models/merged_data.dart';
import 'package:varlik_eventos/utils/capitalize.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:varlik_eventos/utils/consts.dart';

Future<void> changeInscricaoStatus(int inscricaoId, String status) async {
  final token = await getToken();
  final url = Uri.parse('$baseUrl/api/v1/inscricoes/$inscricaoId');
  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'status': status}),
  );
  if (response.statusCode != 200) {
    throw Exception('Erro ao atualizar status da inscrição');
  }
}

Future<void> changePagamentoStatus(int pagamentoId, String status) async {
  final token = await getToken();
  final url = Uri.parse('$baseUrl/api/v1/pagamentos/$pagamentoId');
  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'status': status}),
  );
  if (response.statusCode != 200) {
    throw Exception('Erro ao atualizar status do pagamento');
  }
}

Future<void> changeStatus(
    BuildContext context, int inscricaoId, int pagamentoId) async {
  try {
    await changeInscricaoStatus(inscricaoId, "pendente");
    await changePagamentoStatus(pagamentoId, "pendente");
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Solicitação enviada",
          style: TextStyle(color: Colors.black),
        ),
        content: const Text(
          "Sua solicitação de reembolso foi enviada e será analisada por um administrador. O valor será extornado após aprovação.",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            ),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  } catch (e) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Erro", style: TextStyle(color: Colors.red)),
        content: Text(
          "Não foi possível solicitar o reembolso.\n$e",
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

void showTicketDetailsDialog(BuildContext context, MergedData ticketDetails) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: const Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A1D1D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.confirmation_num,
                      color: Colors.red, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticketDetails.eventoNome,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(ticketDetails.data,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(ticketDetails.localizacao,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                )
              ],
            ),
            const Divider(color: Colors.grey, height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detalhes da Compra',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      InfoRow(
                          title: 'Número do Pedido',
                          value: ticketDetails.pagamento.id.toString()),
                      InfoRow(
                          title: 'Data da Compra',
                          value: ticketDetails.pagamento.data),
                      InfoRow(
                          title: 'Método de Pagamento',
                          value: ticketDetails.pagamento.metodoPagamento
                              .capitalize()),
                      InfoRow(
                          title: 'Valor Pago',
                          value: 'R\$ ${ticketDetails.valor}',
                          red: true),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informações do Ingresso',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      InfoRow(title: 'Quantidade', value: '1'),
                      Row(
                        children: [
                          const Text('Status',
                              style: TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Chip(
                            label: Text(
                                ticketDetails.inscricao.status.capitalize(),
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor:
                                ticketDetails.inscricao.status == 'confirmado'
                                    ? Colors.green
                                    : Colors.red,
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
            ticketDetails.inscricao.status == 'confirmado'
                ? const Text('Ações Disponíveis',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white))
                : Container(),
            const SizedBox(height: 12),
            ticketDetails.inscricao.status == 'confirmado'
                ? Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Baixar Ingresso'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        label: const Text('Compartilhar Ingresso'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Adicionar ao Calendário'),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text(
                                "Solicitar Reembolso",
                                style: TextStyle(color: Colors.black),
                              ),
                              content: const Text(
                                "O processo de reembolso precisa passar por aprovação de um administrador. Só então o valor será extornado. Deseja continuar?",
                                style: TextStyle(color: Colors.black),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Cancelar",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    changeStatus(
                                      context,
                                      ticketDetails.inscricao.id,
                                      ticketDetails.pagamento.id,
                                    );
                                  },
                                  child: const Text("Solicitar",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Solicitar Reembolso'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    ),
  );
}
