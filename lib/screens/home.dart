import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varlik_eventos/models/evento.dart';
import 'package:varlik_eventos/screens/compra.dart';
import 'package:varlik_eventos/screens/widgets/appbar.dart';
import 'package:varlik_eventos/utils/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? categoriaSelecionada;
  DateTime? dataInicio;
  DateTime? dataFim;
  String? localizacaoSelecionada;
  String? nomeEventoSelecionado;

  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _nomeEventoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _localizacaoController.dispose();
    _nomeEventoController.dispose();
    super.dispose();
  }

  Future<List<Evento>> fetchEventos() async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/eventos/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Evento>.from(data.map((e) => Evento.fromJson(e)));
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(),
      backgroundColor: const Color(0xFF1F1F1F),
      body: FutureBuilder<List<Evento>>(
        future: fetchEventos(),
        builder: (context, snapshot) {
          final eventos = snapshot.data ?? [];
          final eventosFiltrados = eventos.where((e) {
            final categoriaMatch = categoriaSelecionada == null ||
                e.categoria == categoriaSelecionada;
            final localizacaoMatch = localizacaoSelecionada == null ||
                e.localizacao
                    .toLowerCase()
                    .contains(localizacaoSelecionada!.toLowerCase());
            final nomeMatch = nomeEventoSelecionado == null ||
                e.titulo
                    .toLowerCase()
                    .contains(nomeEventoSelecionado!.toLowerCase());
            final dataMatch = (dataInicio == null ||
                    DateTime.parse(e.data).isAfter(dataInicio!)) &&
                (dataFim == null || DateTime.parse(e.data).isBefore(dataFim!));
            return categoriaMatch && localizacaoMatch && nomeMatch && dataMatch;
          }).toList();

          return snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eventosFiltrados.isNotEmpty)
                          _buildHero(eventosFiltrados[0]),
                        const SizedBox(height: 20),
                        _buildFiltros(),
                        const SizedBox(height: 20),
                        _buildCategorias(),
                        const SizedBox(height: 30),
                        _buildEventos(eventosFiltrados.skip(1).toList()),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildHero(Evento evento) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            '$cloudFrontUrl${evento.imagem}',
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(4)),
                child: const Text('Evento em Destaque',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              Text(evento.titulo,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(evento.descricao,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(evento.data,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(evento.localizacao,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelaCompraIngresso(evento: evento),
                    ),
                  );
                },
                child: const Text(
                  'Comprar Ingressos',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorias() {
    final categorias = [
      {'icon': Icons.computer, 'label': 'Tecnologia'},
      {'icon': Icons.music_note, 'label': 'Música'},
      {'icon': Icons.brush, 'label': 'Artes'},
      {'icon': Icons.sports_basketball, 'label': 'Esporte'},
      {'icon': Icons.restaurant, 'label': 'Comida'},
      {'icon': Icons.business_center, 'label': 'Negócios'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categorias
            .map(
              (cat) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      categoriaSelecionada =
                          categoriaSelecionada == cat['label']
                              ? null
                              : cat['label'] as String;
                    });
                  },
                  child: Container(
                    width: 140,
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoriaSelecionada == cat['label']
                          ? const Color(0xFF3A3A3C)
                          : const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: categoriaSelecionada == cat['label']
                          ? [
                              BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 6)
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'] as IconData?,
                            color: Colors.red, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          cat['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEventos(List<Evento> eventos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Em Breve ',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: eventos.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisExtent: 300,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final evento = eventos[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.network(
                          '$cloudFrontUrl${evento.imagem}',
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('New',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(evento.data,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          evento.titulo,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          evento.descricao,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${evento.preco.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaCompraIngresso(evento: evento),
                                ),
                              );
                            },
                            child: const Text(
                              'Comprar Ingresso',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildFiltros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _nomeEventoController,
                decoration: inputDecoration.copyWith(
                  hintText: 'Nome do Evento',
                  prefixIcon: const Icon(Icons.event, color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  setState(() {
                    nomeEventoSelecionado = value.isNotEmpty ? value : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: dataInicio == null
                      ? 'dd/mm/aaaa'
                      : '${dataInicio!.day}/${dataInicio!.month}/${dataInicio!.year}',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dataInicio = pickedDate;
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration.copyWith(
                  suffixIcon:
                      const Icon(Icons.calendar_today, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: dataFim == null
                      ? 'dd/mm/aaaa'
                      : '${dataFim!.day}/${dataFim!.month}/${dataFim!.year}',
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dataFim = pickedDate;
                    });
                  }
                },
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration.copyWith(
                  suffixIcon:
                      const Icon(Icons.calendar_today, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 250,
              child: TextField(
                controller: _localizacaoController,
                decoration: inputDecoration.copyWith(
                  hintText: 'Localização',
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  setState(() {
                    localizacaoSelecionada = value.isNotEmpty ? value : null;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text(
                'Resetar Filtros',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  categoriaSelecionada = null;
                  localizacaoSelecionada = null;
                  nomeEventoSelecionado = null;
                  dataInicio = null;
                  dataFim = null;
                  _localizacaoController.clear();
                  _nomeEventoController.clear();
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

final inputDecoration = InputDecoration(
  filled: true,
  fillColor: const Color(0xFF2C2C2E), // tom escuro
  hintStyle: const TextStyle(color: Colors.white70),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  ),
);
