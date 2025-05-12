class Inscricao {
  final int id;
  final int userId;
  final int eventoId;
  final String dataInscricao;
  final String status;

  Inscricao({
    required this.id,
    required this.userId,
    required this.eventoId,
    required this.dataInscricao,
    required this.status,
  });

  factory Inscricao.fromJson(Map<String, dynamic> json) {
    return Inscricao(
      id: json['id'],
      userId: json['user_id'],
      eventoId: json['evento_id'],
      dataInscricao: json['data_inscricao'],
      status: json['status'],
    );
  }
}
