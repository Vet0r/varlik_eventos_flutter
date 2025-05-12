import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varlik_eventos/screens/widgets/appbar.dart';
import 'package:varlik_eventos/screens/widgets/detalhes_compra.dart';
import 'package:varlik_eventos/utils/consts.dart';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:varlik_eventos/models/pagamento.dart';
import 'package:varlik_eventos/models/inscricao.dart';
import 'package:varlik_eventos/models/merged_data.dart';

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({super.key});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas as Categorias';

  Future<List<Map<String, dynamic>>> fetchPurchaseHistory() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/pagamentos');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('falha ao carregar histórico de compras');
    }
  }

  Future<List<Pagamento>> fetchPayments() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/pagamentos');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pagamento.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar pagamentos');
    }
  }

  Future<List<Inscricao>> fetchSubscriptions() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('$baseUrl/api/v1/inscricoes');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Inscricao.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar inscrições');
    }
  }

  Future<Map<String, dynamic>> fetchEventDetails(int eventId) async {
    final url = Uri.parse('$baseUrl/api/v1/eventos/$eventId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar detalhes do evento');
    }
  }

  Future<List<MergedData>> fetchCombinedData() async {
    final payments = await fetchPayments();
    final subscriptions = await fetchSubscriptions();

    final combinedData = <MergedData>[];

    for (final payment in payments) {
      final subscription = subscriptions.firstWhere(
        (sub) => sub.id == payment.inscricaoId,
        orElse: () => throw Exception(
            'Inscrição não encontrada para o pagamento ${payment.id}'),
      );

      final eventDetails = await fetchEventDetails(subscription.eventoId);
      combinedData.add(MergedData(
        eventoNome: eventDetails['titulo'],
        data: payment.data,
        valor: payment.valor,
        categoria: eventDetails['categoria'],
        pagamento: payment,
        inscricao: subscription,
      ));
    }

    return combinedData;
  }

  List<MergedData> _filterByCategory(List<MergedData> data, String category) {
    if (category == 'Todas as Categorias') return data;
    return data
        .where((item) => item.categoria
            .toString()
            .toLowerCase()
            .contains(category.toLowerCase()))
        .toList();
  }

  Widget _buildDropdown(
      String value, List<String> options, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: const Color(0xFF3A3A3A),
          items: options
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option,
                        style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSummary(List<MergedData> combinedData) {
    final totalSpent = combinedData.fold(0.0, (sum, item) => sum + item.valor);
    final totalEvents = combinedData.length;
    final averagePrice = totalEvents > 0 ? totalSpent / totalEvents : 0.0;
    final lastPurchase =
        combinedData.isNotEmpty ? combinedData.last.data : 'N/A';

    final summary = [
      {'title': 'Total Gasto', 'value': 'R\$ ${totalSpent.toStringAsFixed(2)}'},
      {'title': 'Total de Eventos', 'value': '$totalEvents'},
      {
        'title': 'Preço Médio',
        'value': 'R\$ ${averagePrice.toStringAsFixed(2)}'
      },
      {'title': 'Última Compra', 'value': lastPurchase},
    ];

    return Row(
      children: summary.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title']!,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(item['value']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildPurchaseCards(List<MergedData> combinedData) {
    return combinedData.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.ticket, color: Colors.red, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.eventoNome,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('Data da Compra: ${item.data}',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('R\$ ${item.valor}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF444444)),
              onPressed: () {
                showTicketDetailsDialog(context, item);
              },
              child: const Text('Ver Detalhes'),
            )
          ],
        ),
      );
    }).toList();
  }

  List<MergedData> _filterData(List<MergedData> data, String query) {
    if (query.isEmpty) return data;
    return data
        .where((item) => item.eventoNome
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(),
      backgroundColor: const Color(0xFF2C2C2C),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Compras',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 16),
                _buildDropdown(
                  _selectedCategory,
                  [
                    'Todas as Categorias',
                    'Tecnologia',
                    'Música',
                    'Artes',
                    'Esporte',
                    'Comida',
                    'Negócios'
                  ],
                  (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      hintText: 'Pesquisar compras...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF3A3A3A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<MergedData>>(
              future: fetchCombinedData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Sem compras realizadas',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final filteredData = _filterByCategory(
                    _filterData(snapshot.data!, _searchController.text),
                    _selectedCategory,
                  );
                  return Expanded(
                    child: Column(
                      children: [
                        ..._buildPurchaseCards(filteredData),
                        const SizedBox(height: 24),
                        _buildSummary(filteredData),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
