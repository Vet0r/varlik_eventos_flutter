import 'package:flutter/material.dart';
import 'package:varlik_eventos/screens/widgets/info_row.dart';
import 'package:varlik_eventos/models/merged_data.dart';

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
                          Text(
                              'Local não informado', // Placeholder as `localizacao` is not defined
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
                          value: ticketDetails.pagamento.id.toString()),
                      InfoRow(
                          title: 'Data da Compra',
                          value: ticketDetails.pagamento.data),
                      InfoRow(
                          title: 'Método de Pagamento',
                          value: ticketDetails.pagamento.metodoPagamento ??
                              'Não informado'),
                      InfoRow(
                          title: 'Valor Pago',
                          value: 'R\$ ${ticketDetails.valor}',
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
                          value:
                              'Não informado'), // Placeholder as `tipoIngresso` is not defined
                      InfoRow(
                          title: 'Quantidade',
                          value:
                              '1'), // Placeholder as `quantidade` is not defined
                      Row(
                        children: [
                          const Text('Status',
                              style: TextStyle(color: Colors.grey)),
                          const Spacer(),
                          Chip(
                            label: Text(ticketDetails.inscricao.status,
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor:
                                ticketDetails.inscricao.status == 'Ativo'
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
