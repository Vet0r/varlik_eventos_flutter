import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:varlik_eventos/models/evento.dart';
import 'package:varlik_eventos/screens/compra.dart';
import 'package:varlik_eventos/utils/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Evento>> fetchEventos() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/v1/eventos/'));

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
      backgroundColor: const Color(0xFF1F1F1F),
      body: FutureBuilder<List<Evento>>(
        future: fetchEventos(),
        builder: (context, snapshot) {
          final eventos = snapshot.data ?? [];
          return snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eventos.isNotEmpty) _buildHero(eventos[0]),
                        const SizedBox(height: 20),
                        _buildCategorias(),
                        const SizedBox(height: 30),
                        _buildEventos(eventos.skip(1).toList()),
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
                onPressed: () {},
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
            .map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: MediaQuery.of(context).size.width * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      border: Border.all(color: Colors.white70),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[800],
                          child: Icon(cat['icon'] as IconData,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(cat['label'] as String,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12))
                      ],
                    ),
                  ),
                ))
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
}
