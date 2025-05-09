class Usuario {
  final int id;
  final String name;
  final String tipo;
  final String email;

  Usuario({
    required this.id,
    required this.name,
    required this.tipo,
    required this.email,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      name: json['name'],
      tipo: json['tipo'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tipo': tipo,
      'email': email,
    };
  }
}
