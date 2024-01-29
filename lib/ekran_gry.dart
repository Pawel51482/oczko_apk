import 'package:flutter/material.dart';
import 'talia.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EkranGry extends StatefulWidget {
  @override
  _EkranGryState createState() => _EkranGryState();
}

class _EkranGryState extends State<EkranGry> {
  bool widocznoscPrzyciskow = true;
  bool widocznoscPrzyciskuZakonczTure = true;
  bool moznaDobrac = false;
  bool pokazKarty = false;
  List<String> rekaGracza = [];
  List<String> rekaKrupiera = [];
  Talia talia = Talia();
  bool turaZakonczona = false;
  String wynikGry = '';
  int saldoGracza = 200;
  int aktualnyZaklad = 0;
  int wybranaStawka = 0;

  void dodajStawke(int kwota) {
    if (!turaZakonczona) {
      if (saldoGracza >= wybranaStawka + kwota) {
        setState(() {
          wybranaStawka += kwota;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nie możesz postawić więcej niż masz w saldzie.'),
          ),
        );

        Future.delayed(Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        });
      }
    }
  }


  void cofnijStawke() {
    if (!turaZakonczona && wybranaStawka > 0) {
      setState(() {
        wybranaStawka = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    odczytajSaldo();
    rozpocznijGre();
  }

  void rozpocznijGre() {
    talia.tasuj();
    rekaGracza = [talia.pobierzKarte(), talia.pobierzKarte()];
    rekaKrupiera = [talia.pobierzKarte()];
    turaZakonczona = false;
    wynikGry = '';
    aktualnyZaklad = 0;
    pokazKarty = false;
    moznaDobrac = false;
    widocznoscPrzyciskow = true;
    widocznoscPrzyciskuZakonczTure = true;
  }

  int obliczReke(List<String> reka) {
    int suma = 0;
    int asy = 0;

    for (String karta in reka) {
      String figura = karta.split(' ')[0];
      if (figura == 'A') {
        asy++;
        suma += 11;
      } else if (figura == 'K' || figura == 'Q' || figura == 'J') {
        suma += 10;
      } else {
        suma += int.parse(figura);
      }
    }

    while (asy > 0 && suma > 21) {
      suma -= 10;
      asy--;
    }

    return suma;
  }

  void dobierzKarte() {
    if (!turaZakonczona) {
      setState(() {
        rekaGracza.add(talia.pobierzKarte());
        if (obliczReke(rekaGracza) > 21) {
          zakonczRunde();
          setState(() {
            widocznoscPrzyciskuZakonczTure = false;
          });

          Future.delayed(Duration(seconds: 6), () {
            setState(() {
              widocznoscPrzyciskuZakonczTure = true;
            });
          });
        }
      });
    }
  }

  Future<void> odczytajSaldo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      saldoGracza = prefs.getInt('saldo') ?? 200;
    });
  }

  Future<void> zapiszSaldo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('saldo', saldoGracza);
  }


  Future<void> zakonczRunde() async {
    setState(() {
      turaZakonczona = true;
      widocznoscPrzyciskow = true;
    });

    while (obliczReke(rekaKrupiera) < 15) {
      await Future.delayed(Duration(seconds: 1), () {
        setState(() {
          rekaKrupiera.add(talia.pobierzKarte());
        });
      });
    }

    int sumaGracza = obliczReke(rekaGracza);
    int sumaKrupiera = obliczReke(rekaKrupiera);

    if (sumaGracza > 21 || (sumaKrupiera <= 21 && sumaKrupiera > sumaGracza)) {
      wynikGry = 'Przegrałeś!';
    } else if (sumaGracza == sumaKrupiera) {
      saldoGracza += aktualnyZaklad;
      wynikGry = 'Remis!';
    } else {
      saldoGracza += aktualnyZaklad * 2;
      wynikGry = 'Wygrałeś!';
    }

    setState(() {
      wybranaStawka = 0;
    });

    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        rekaGracza.clear();
        rekaKrupiera.clear();
        zapiszSaldo();
        rozpocznijGre();
      });
    });
  }


  void postawZaklad(int zaklad) {
    if (saldoGracza >= zaklad && !turaZakonczona && aktualnyZaklad == 0) {
      setState(() {
        aktualnyZaklad = zaklad;
        saldoGracza -= zaklad;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oczko'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/tlo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Saldo: $saldoGracza PLN',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              if (!widocznoscPrzyciskow)
                Column(
                  children: [
                    Text(
                      'Aktualny zakład: $aktualnyZaklad PLN',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              if (pokazKarty)
                Column(
                  children: [
                    Text(
                      'Ręka gracza: ${obliczReke(rekaGracza)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        for (String karta in rekaGracza)
                          Card(
                            child: Container(
                              width: 90.0,
                              height: 120.0,
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: (karta == '♥' || karta == '♦')
                                    ? Colors.red
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Colors.black, width: 4.0),
                              ),
                              child: Text(
                                karta,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Ręka krupiera: ${obliczReke(rekaKrupiera)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        for (String karta in rekaKrupiera)
                          Card(
                            child: Container(
                              width: 90.0,
                              height: 120.0,
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: (karta == '♥' || karta == '♦')
                                    ? Colors.red
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Colors.black, width: 4.0),
                              ),
                              child: Text(
                                karta,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              if (obliczReke(rekaGracza) < 21 && !turaZakonczona)
                Column(
                  children: [
                    Column(
                      children: [
                        if (widocznoscPrzyciskow)
                          ElevatedButton(
                            onPressed: () => dodajStawke(5),
                            child: Text('Dodaj 5 PLN'),
                          ),
                        if (widocznoscPrzyciskow)
                          ElevatedButton(
                            onPressed: () => dodajStawke(10),
                            child: Text('Dodaj 10 PLN'),
                          ),
                        if (widocznoscPrzyciskow)
                          ElevatedButton(
                            onPressed: () => dodajStawke(20),
                            child: Text('Dodaj 20 PLN'),
                          ),
                        if (widocznoscPrzyciskow)
                          ElevatedButton(
                            onPressed: () => dodajStawke(50),
                            child: Text('Dodaj 50 PLN'),
                          ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (widocznoscPrzyciskow)
                      ElevatedButton(
                        onPressed: () => cofnijStawke(),
                        child: Text('Cofnij stawkę'),
                      ),
                    if (widocznoscPrzyciskow)
                      Column(
                        children: [
                          Text(
                            'Wybrana stawka: $wybranaStawka PLN',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    if (widocznoscPrzyciskow)
                      ElevatedButton(
                        onPressed: () {
                          postawZaklad(wybranaStawka);
                          pokazKarty = true;
                          setState(() {
                            moznaDobrac = true;
                            widocznoscPrzyciskow = false;
                          });
                        },
                        child: Text('Postaw stawkę'),
                      ),
                    if (moznaDobrac)
                      ElevatedButton(
                        onPressed: dobierzKarte,
                        child: Text('Dobierz kartę'),
                      ),
                    SizedBox(height: 20,)
                  ],
                ),
              if (moznaDobrac)
                ElevatedButton(
                  onPressed: widocznoscPrzyciskuZakonczTure
                      ? () async {
                    zakonczRunde();
                    setState(() {
                      widocznoscPrzyciskuZakonczTure = false;
                    });

                    await Future.delayed(Duration(seconds: 6));

                    setState(() {
                      widocznoscPrzyciskuZakonczTure = true;
                    });
                  }
                      : null,
                  child: Text('Zakończ turę'),
                ),
              SizedBox(height: 20),
              Text(
                wynikGry,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}