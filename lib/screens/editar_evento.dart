import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:varlik_eventos/models/evento.dart';
import 'package:varlik_eventos/provider/usuario.dart';
import 'dart:convert';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:varlik_eventos/utils/consts.dart';

class EditarEventoPage extends StatefulWidget {
  final Evento evento;

  const EditarEventoPage({super.key, required this.evento});

  @override
  State<EditarEventoPage> createState() => _EditarEventoPageState();
}

class _EditarEventoPageState extends State<EditarEventoPage> {
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _dataController;
  late TextEditingController _localController;
  late TextEditingController _capacidadeController;
  late TextEditingController _precoController;
  String? _categoria;
  XFile? _imagemSelecionada;
  bool _uploading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.evento.titulo);
    _descricaoController = TextEditingController(text: widget.evento.descricao);
    _dataController = TextEditingController(text: widget.evento.data);
    _localController = TextEditingController(text: widget.evento.localizacao);
    _capacidadeController =
        TextEditingController(text: widget.evento.capacidade.toString());
    _precoController =
        TextEditingController(text: widget.evento.preco.toStringAsFixed(2));
    _categoria = widget.evento.categoria;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagemSelecionada = picked;
      });
    }
  }

  Future<String?> _uploadToS3(XFile file) async {
    setState(() => _uploading = true);
    final fileName =
        'eventos/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final url = 'https://verlink.s3.amazonaws.com/$fileName';
    final uploadResp = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'image/jpeg',
      },
      body: await file.readAsBytes(),
    );

    setState(() => _uploading = false);

    if (uploadResp.statusCode == 200) {
      return fileName;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao fazer upload da imagem')),
      );
      return null;
    }
  }

  Future<void> _atualizarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    String? imagemPath = widget.evento.imagem;
    if (_imagemSelecionada != null) {
      imagemPath = await _uploadToS3(_imagemSelecionada!);
      if (imagemPath == null) return;
    }

    final token = await getToken();
    var variaveis = {
      "titulo": _tituloController.text,
      "descricao": _descricaoController.text,
      "data": _dataController.text,
      "localizacao": _localController.text,
      "categoria": _categoria ?? '',
      "capacidade": int.tryParse(_capacidadeController.text) ?? 0,
      "preco":
          double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0,
      "imagem": imagemPath,
      "organizador_id":
          Provider.of<UsuarioProvider>(context, listen: false).usuario!.id,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/eventos/${widget.evento.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(variaveis),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar evento: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Editar Evento'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 48,
              vertical: isMobile ? 16 : 32,
            ),
            constraints: BoxConstraints(
              maxWidth: isMobile ? 600 : 700,
              minWidth: isMobile ? 0 : 400,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
              boxShadow: isMobile
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edite os detalhes do evento abaixo',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _tituloController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            filled: true,
                            fillColor: Color(0xFF3A3A3A),
                            labelStyle: TextStyle(color: Colors.white),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (!isMobile) const SizedBox(width: 8),
                      if (!isMobile)
                        Flexible(
                          child: TextFormField(
                            controller: _localController,
                            decoration: const InputDecoration(
                              labelText: 'Local',
                              filled: true,
                              fillColor: Color(0xFF3A3A3A),
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _localController,
                      decoration: const InputDecoration(
                        labelText: 'Local',
                        filled: true,
                        fillColor: Color(0xFF3A3A3A),
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextField('Descrição do Evento',
                      controller: _descricaoController,
                      maxLines: 5,
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDateField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDropdown('Categoria')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField('Local',
                              controller: _localController,
                              validator: (v) =>
                                  v!.isEmpty ? 'Obrigatório' : null)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField('Capacidade Máxima',
                              controller: _capacidadeController,
                              validator: (v) =>
                                  v!.isEmpty ? 'Obrigatório' : null)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Preço',
                      controller: _precoController,
                      prefixText: 'R\$ ',
                      width: 150,
                      validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
                  const SizedBox(height: 24),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _uploading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_imagemSelecionada != null)
                                  Text(
                                      'Imagem Selecionada: ${_imagemSelecionada!.path.split('/').last}'),
                                if (_imagemSelecionada == null &&
                                    widget.evento.imagem.isNotEmpty)
                                  Text(
                                      'Imagem atual: ${widget.evento.imagem.split('/').last}'),
                                const Icon(Icons.cloud_upload_outlined,
                                    size: 40, color: Colors.white70),
                                const SizedBox(height: 8),
                                const Text(
                                  'Arraste e solte sua imagem aqui, ou',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[800],
                                  ),
                                  child: const Text('Procurar Arquivos'),
                                )
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _atualizarEvento,
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar Alterações'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label,
      {int maxLines = 1,
      String? hint,
      IconData? icon,
      String? prefixText,
      double? width,
      TextEditingController? controller,
      String? Function(String?)? validator}) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: const Color(0xFF3A3A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      value: _categoria,
      dropdownColor: const Color(0xFF2C2C2C),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      iconEnabledColor: Colors.white,
      style: const TextStyle(color: Colors.white),
      items: const [
        DropdownMenuItem(value: 'Tecnologia', child: Text('Tecnologia')),
        DropdownMenuItem(value: 'Música', child: Text('Música')),
        DropdownMenuItem(value: 'Artes', child: Text('Artes')),
        DropdownMenuItem(value: 'Esporte', child: Text('Esporte')),
        DropdownMenuItem(value: 'Comida', child: Text('Comida')),
        DropdownMenuItem(value: 'Negócios', child: Text('Negócios')),
      ],
      onChanged: (value) {
        setState(() {
          _categoria = value;
        });
      },
      validator: (v) => v == null ? 'Selecione uma categoria' : null,
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              DateTime.tryParse(_dataController.text) ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          locale: const Locale('pt', 'BR'),
        );
        if (picked != null) {
          _dataController.text = picked.toIso8601String().split('T')[0];
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
          'Data do Evento',
          controller: _dataController,
          hint: 'dd/mm/aaaa',
          icon: Icons.calendar_today,
          validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
        ),
      ),
    );
  }
}
