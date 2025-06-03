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
      appBar: AppBar(backgroundColor: Colors.blue, title: Text('Registro')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  TextFormField(
                    controller: _empresaController,
                    decoration: InputDecoration(labelText: 'Empresa'),
                    validator: isNotEmpty,
                  ),

                  TextFormField(
                    controller: _placaController,
                    decoration: InputDecoration(labelText: 'Placa'),
                    validator: temSeteChars,
                  ),

                  TextFormField(
                    controller: _motoristaController,
                    decoration: InputDecoration(labelText: 'Motorista'),
                    validator: isNotEmpty,
                  ),

                  TextFormField(
                    controller: _cnhController,
                    decoration: InputDecoration(labelText: 'CNH'),
                    keyboardType: TextInputType.number,
                    validator: isNotEmpty,
                  ),

                  TextFormField(
                    controller: _ocupanteController,
                    decoration: InputDecoration(labelText: 'Ocupante'),
                  ),

                  TextFormField(
                    controller: _autorizadoController,
                    decoration: InputDecoration(labelText: 'Autorização'),
                  ),

                  TextFormField(
                    controller: _apacController,
                    decoration: InputDecoration(labelText: 'APAC'),
                    validator: isNotEmpty,
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {

                        _salvarNoExcel();

                      }
                      //Limpar os campos
                      _empresaController.clear();
                      _placaController.clear();
                      _motoristaController.clear();
                      _cnhController.clear();
                      _ocupanteController.clear();
                      _autorizadoController.clear();
                      _apacController.clear();

                      FocusScope.of(context).requestFocus(_empresaFocus);

                    },
                    child: Text('Enviar'),


                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );



  }
  void _salvarNoExcel() async {
    const url = 'https://script.google.com/macros/s/AKfycbzXwjQqiOES280lHC5_-U_P8Gl2WeDUHofcYXfMHbbg7hZoUEDb_pG-GNXlRBzpjWeCAg/exec';

    final data = {
      'Empresa': _empresaController.text,
      'Placa': _placaController.text,
      'Motorista': _motoristaController.text,
      'CNH': _cnhController.text,
      'Ocupante': _ocupanteController.text,
      'Autorização': _autorizadoController.text,
      'Apac': _apacController.text
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dados salvos com sucesso!'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${responseData['error']}'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: ${e.toString()}'))
      );
    }
  }

}