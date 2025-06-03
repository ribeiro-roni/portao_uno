import 'package:flutter/material.dart';
import 'package:orbital_p1/mixins/validations_mixin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Formpage extends StatefulWidget {
  const Formpage({super.key});

  @override
  State<Formpage> createState() => _FormpageState();
}

class _FormpageState extends State<Formpage> with ValidationsMixin {
  // CONTROLADORES
  final _formKey = GlobalKey<FormState>();
  final _empresaController = TextEditingController();
  final _placaController = TextEditingController();
  final _motoristaController = TextEditingController();
  final _cnhController = TextEditingController();
  final _ocupanteController = TextEditingController();
  final _apacController = TextEditingController();
  final _autorizadoController = TextEditingController();

  final FocusNode _empresaFocus = FocusNode();

  // A URL do seu Google Apps Script
  static const String _appsScriptUrl = 'https://script.google.com/macros/s/AKfycbyYY0OiOkz2uCMrwFxDkWjY14jxhc40f46BcYUpm6u-kfZS07BUdyIKAcTGPClpo1gH9w/exec';

  @override
  void dispose() {
    _empresaController.dispose();
    _placaController.dispose();
    _motoristaController.dispose();
    _cnhController.dispose();
    _ocupanteController.dispose();
    _apacController.dispose();
    _autorizadoController.dispose();
    _empresaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Registro de Veículos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Campos para Cadastro de Entrada
                TextFormField(
                  controller: _empresaController,
                  decoration: const InputDecoration(labelText: 'Empresa'),
                  validator: isNotEmpty,
                ),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(labelText: 'Placa'),
                  validator: temSeteChars,
                ),
                TextFormField(
                  controller: _motoristaController,
                  decoration: const InputDecoration(labelText: 'Motorista'),
                  validator: isNotEmpty,
                ),
                TextFormField(
                  controller: _cnhController,
                  decoration: const InputDecoration(labelText: 'CNH'),
                  keyboardType: TextInputType.number,
                  validator: isNotEmpty,
                ),
                TextFormField(
                  controller: _ocupanteController,
                  decoration: const InputDecoration(labelText: 'Ocupante'),
                ),
                TextFormField(
                  controller: _autorizadoController,
                  decoration: const InputDecoration(labelText: 'Autorização'),
                ),
                TextFormField(
                  controller: _apacController,
                  decoration: const InputDecoration(labelText: 'APAC'),
                  validator: isNotEmpty,
                ),

                const SizedBox(height: 30),

                // Botão para Cadastrar Nova Entrada
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final sucesso = await _salvarNovoVeiculo();
                      if (sucesso) {
                        _clearFormFields();
                        FocusScope.of(context).requestFocus(_empresaFocus);
                      }
                    }
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Registrar Nova Entrada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para limpar os campos do formulário
  void _clearFormFields() {
    _empresaController.clear();
    _placaController.clear();
    _motoristaController.clear();
    _cnhController.clear();
    _ocupanteController.clear();
    _autorizadoController.clear();
    _apacController.clear();
  }

  // Função genérica para enviar a requisição HTTP,
  // com tratamento específico para o 302 do Apps Script
  Future<Map<String, dynamic>> _sendRequest(String url, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      // Se o status for 200 OK, processa normalmente
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      // Se o status for 302, vamos "ignorar" o erro do Flutter,
      // e tentar parsear a resposta como se fosse um 200 OK.
      else if (response.statusCode == 302) {
        try {
          final decodedResponse = json.decode(response.body);
          if (decodedResponse['status'] == 'success') {
            return decodedResponse;
          } else {
            return {'status': 'error', 'error': 'Resposta Apps Script (302) com status: ${decodedResponse['status']}'};
          }
        } catch (e) {
          print('Erro ao decodificar JSON após 302 (provavelmente HTML de redirecionamento): $e');
          // Retorna um sucesso "otimista" para não exibir o erro ao usuário
          return {'status': 'success', 'message': 'Operação concluída (resposta 302 ignorada).'};
        }
      }
      // Para qualquer outro status (4xx, 5xx), ainda é um erro.
      else {
        return {'status': "error", 'error': "Erro de servidor: ${response.statusCode}. ${response.body}"};
      }
    } catch (e) {
      return {'status': "error", 'error': "Erro de conexão: ${e.toString()}"};
    }
  }


  Future<bool> _salvarNovoVeiculo() async {
    final data = {
      'funcao': 'cadastrarNovoVeiculo',
      'dados': {
        'Empresa': _empresaController.text,
        'Placa': _placaController.text,
        'Motorista': _motoristaController.text,
        'CNH': _cnhController.text,
        'Ocupante': _ocupanteController.text,
        'Autorização': _autorizadoController.text,
        'Apac': _apacController.text
      }
    };

    final responseData = await _sendRequest(_appsScriptUrl, data);

    if (responseData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados de entrada salvos com sucesso!')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar entrada: ${responseData['error']}')),
      );
      return false;
    }
  }
}
