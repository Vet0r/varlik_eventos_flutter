import 'package:flutter/material.dart';
import 'package:varlik_eventos/models/evento.dart';

class TelaCompraIngresso extends StatefulWidget {
  final Evento evento;

  const TelaCompraIngresso({super.key, required this.evento});

  @override
  State<TelaCompraIngresso> createState() => _TelaCompraIngressoState();
}

class _TelaCompraIngressoState extends State<TelaCompraIngresso> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text("Voltar para eventos",
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.evento.imagem,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.evento.titulo,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Text("Disponível",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text(widget.evento.data,
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text(widget.evento.localizacao,
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          const Icon(Icons.people,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text("${widget.evento.capacidade} pessoas",
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const Text("Descrição do Evento",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        widget.evento.descricao,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      const Text("O que está incluído",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
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
                                const Icon(Icons.check,
                                    color: Colors.redAccent, size: 18),
                                const SizedBox(width: 6),
                                Text(item,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                            "Valor do Ingresso: R\$ ${widget.evento.preco.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white)),
                        const Text("Taxa de Serviço: R\$ 1,99",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                            "Total: R\$ ${(widget.evento.preco + 1.99).toStringAsFixed(2)}",
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        const TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black,
                            hintText: "E-mail",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black,
                                  hintText: "Nome",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black,
                                  hintText: "Sobrenome",
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
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
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
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
