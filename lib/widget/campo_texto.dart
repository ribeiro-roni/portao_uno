import 'package:flutter/material.dart';

class Campotexto extends StatefulWidget {

  final TextEditingController controller;
  final String label;
  final String erro;
  final TextInputType keyboardType;


  const Campotexto({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.label,
    required this.erro

  });

  @override
  State<Campotexto> createState() => _CampotextoState();
}

class _CampotextoState extends State<Campotexto> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller:  widget.controller,
        decoration: InputDecoration(labelText: widget.label),
        validator: (value){
          if (value == null ||value.isEmpty){
            return widget.erro;
          }
          return null;
        }
    );
  }
}