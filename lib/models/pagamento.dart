class Pagamento {
  final int id;
  final int inscricaoId;
  final double valor;
  final String metodoPagamento;
  final String status;
  final String data;

  Pagamento({
    required this.id,
    required this.inscricaoId,
    required this.valor,
    required this.metodoPagamento,
    required this.status,
    required this.data,
  });

  factory Pagamento.fromJson(Map<String, dynamic> json) {
    return Pagamento(
      id: json['id'],
      inscricaoId: json['inscricao_id'],
      valor: json['valor'],
      metodoPagamento: json['metodo_pagamento'],
      status: json['status'],
      data: json['data'],
    );
  }
}
