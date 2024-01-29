import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UstawieniaEkran extends StatelessWidget {
  Future<void> zresetujSaldo(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('saldo', 200);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saldo zresetowane do stanu początkowego (200 PLN).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: Container(
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
                onPressed: () async {
                  await zresetujSaldo(context);
                },
                child: Text('Resetuj Saldo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
