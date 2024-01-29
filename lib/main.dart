import 'package:flutter/material.dart';
import 'ekran_gry.dart';
import 'ustawienia_ekran.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oczko',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EkranGlowny(),
    );
  }
}

class EkranGlowny extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oczko'),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/tlo.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EkranGry()),
                    );
                  },
                  child: Text('Zagraj w oczko'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UstawieniaEkran()),
                    );
                  },
                  child: Text('Ustawienia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
