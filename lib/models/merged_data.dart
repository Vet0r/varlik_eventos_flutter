import 'package:varlik_eventos/models/pagamento.dart';
import 'package:varlik_eventos/models/inscricao.dart';

class MergedData {
  final String eventoNome;
  final String data;
  final String localizacao;
  final double valor;
  final String categoria;
  final Pagamento pagamento;
  final Inscricao inscricao;

  MergedData({
    required this.eventoNome,
    required this.data,
    required this.localizacao,
    required this.valor,
    required this.categoria,
    required this.pagamento,
    required this.inscricao,
  });
}
