class Evento {
  final int id;
  final String titulo;
  final String descricao;
  final String data;
  final String localizacao;
  final int organizadorId;
  final int capacidade;
  final double preco;
  final String createdAt;
  final String updatedAt;
  final String imagem;

  Evento({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.localizacao,
    required this.organizadorId,
    required this.capacidade,
    required this.preco,
    required this.createdAt,
    required this.updatedAt,
    required this.imagem,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      data: json['data'],
      localizacao: json['localizacao'],
      organizadorId: json['organizador_id'],
      capacidade: json['capacidade'],
      preco: (json['preco'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imagem: json['imagem'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data': data,
      'localizacao': localizacao,
      'organizador_id': organizadorId,
      'capacidade': capacidade,
      'preco': preco,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'imagem': imagem,
    };
  }
}
