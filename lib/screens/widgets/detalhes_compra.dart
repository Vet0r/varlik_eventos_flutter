import 'package:flutter/material.dart';
import 'package:varlik_eventos/screens/widgets/info_row.dart';

void showTicketDetailsDialog(
    BuildContext context, Map<String, dynamic> ticketDetails) {
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
            // Header
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
                      Text(ticketDetails['evento_nome'],
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
                          Text(ticketDetails['data'],
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                              ticketDetails['localizacao'] ??
                                  'Local não informado',
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

            // Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Purchase Details
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
                          value: ticketDetails['id'].toString()),
                      InfoRow(
                          title: 'Data da Compra',
                          value: ticketDetails['data']),
                      InfoRow(
                          title: 'Método de Pagamento',
                          value: ticketDetails['metodo_pagamento'] ??
                              'Não informado'),
                      InfoRow(
                          title: 'Valor Pago',
                          value: 'R\$ ${ticketDetails['valor']}',
                          red: true),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Ticket Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informações do Ingresso',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      InfoRow(
                          title: 'Tipo de Ingresso',
                          value: ticketDetails['tipo_ingresso'] ??
                              'Não informado'),
                      InfoRow(
                          title: 'Quantidade',
                          value:
                              ticketDetails['quantidade']?.toString() ?? '1'),
                      Row(
                        children: [
                          const Text('Status',
                              style: TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Chip(
                            label: Text(ticketDetails['status'] ?? 'Ativo',
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: ticketDetails['status'] == 'Ativo'
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

            // Actions
            const Text('Ações Disponíveis',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Baixar Ingresso'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 16)),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar Ingresso'),
                  style:
                      OutlinedButton.styleFrom(foregroundColor: Colors.white),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Adicionar ao Calendário'),
                  style:
                      OutlinedButton.styleFrom(foregroundColor: Colors.white),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh),
                  label: const Text('Solicitar Reembolso'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Solicitações de reembolso devem ser feitas com pelo menos 48 horas de antecedência. Termos e condições se aplicam.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          ],
        ),
      ),
    ),
  );
}
