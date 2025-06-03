import 'package:flutter/material.dart';
import 'package:orbital_p1/screens/entrada.dart';
import 'package:orbital_p1/screens/form_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        body: SafeArea(child: Homepage()),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}


class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [

          SizedBox(height: 50),

          Image.asset('lib/images/logo.png'),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                ElevatedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Formpage())
                  );
                }, child: Text('Saida')),
                SizedBox(height: 10),
                ElevatedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EntradaPage())
                  );
                }, child: Text('Entrada'))
              ],
            ),
          )
        ],
      ),
    );
  }
}