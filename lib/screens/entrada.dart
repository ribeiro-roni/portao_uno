import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EntradaPage extends StatefulWidget {
  const EntradaPage({super.key});

  @override
  State<EntradaPage> createState() => _EntradaPageState();
}

class _EntradaPageState extends State<EntradaPage> {
  final _placaController = TextEditingController();
  Map<String, dynamic>? dadosVeiculo;
  String mensagem = '';
  bool carregando = false;

  Future<void> buscarDados() async {
    final placa = _placaController.text.trim();

    if (placa.isEmpty) {
      setState(() {
        mensagem = 'Por favor, informe a placa.';
        dadosVeiculo = null;
      });
      return;
    }

    setState(() {
      carregando = true;
      mensagem = '';
    });

    try {
      final url = 'https://script.google.com/macros/s/AKfycbyYY0OiOkz2uCMrwFxDkWjY14jxhc40f46BcYUpm6u-kfZS07BUdyIKAcTGPClpo1gH9w/exec?placa=${Uri.encodeComponent(placa)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          setState(() {
            dadosVeiculo = jsonData['data'];
            mensagem = 'Dados encontrados!';
          });
        } else {
          setState(() {
            dadosVeiculo = null;
            mensagem = 'Placa não encontrada.';
          });
        }
      } else {
        // Ocultando o erro, se quiser mostrar algo, pode descomentar abaixo:
        // setState(() {
        //   mensagem = 'Erro de comunicação: ${response.statusCode}';
        // });
      }
    } catch (e) {
      setState(() {
        mensagem = 'Erro ao buscar dados: ${e.toString()}';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> confirmarEntrada() async {
    if (dadosVeiculo == null) {
      return; // Não faz nada se não tiver dados
    }

    setState(() {
      carregando = true;
    });

    try {
      final url = 'https://script.google.com/macros/s/AKfycbyYY0OiOkz2uCMrwFxDkWjY14jxhc40f46BcYUpm6u-kfZS07BUdyIKAcTGPClpo1gH9w/exec?funcao=confirmarEntrada';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Placa': dadosVeiculo!['Placa']}),
      );

      if (response.statusCode >= 200 && response.statusCode < 400) {
        // Simplesmente assume que deu certo, sem tentar decodificar.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada confirmada com sucesso!')),
        );

        setState(() {
          dadosVeiculo = null;
          _placaController.clear();
          mensagem = '';
        });
      }
      // Se não for sucesso, não faz nada e não mostra erro.
    } catch (e) {
      // Oculta completamente qualquer exceção.
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }



  @override
  void dispose() {
    _placaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrada de Veículo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _placaController,
              decoration: const InputDecoration(
                labelText: 'Placa do Veículo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: carregando ? null : buscarDados,
              child: carregando ? const CircularProgressIndicator() : const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            if (mensagem.isNotEmpty)
              Text(
                mensagem,
                style: TextStyle(
                  color: mensagem.contains('Erro') || mensagem.contains('não')
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            if (dadosVeiculo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Empresa: ${dadosVeiculo!['Empresa']}'),
                      Text('Placa: ${dadosVeiculo!['Placa']}'),
                      Text('Motorista: ${dadosVeiculo!['Motorista']}'),
                      Text('CNH: ${dadosVeiculo!['CNH']}'),
                      Text('Ocupante: ${dadosVeiculo!['Ocupante']}'),
                      Text('Autorização: ${dadosVeiculo!['Autorizacao']}'),
                      Text('Apac: ${dadosVeiculo!['Apac']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: carregando ? null : confirmarEntrada,
                child: carregando ? const CircularProgressIndicator() : const Text('Confirmar Entrada',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
