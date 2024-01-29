import 'dart:math';

class Talia {
  List<String> karty = [];

  Talia() {
    stworzTalie();
  }

  void stworzTalie() {
    List<String> figury = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    List<String> kolory = ['♣', '♦', '♥', '♠'];

    for (String figura in figury) {
      for (String kolor in kolory) {
        karty.add('$figura $kolor');
      }
    }
  }

  void tasuj() {
    karty.shuffle(Random());
  }

  String pobierzKarte() {
    if (karty.isNotEmpty) {
      return karty.removeAt(0);
    } else {
      print('Brak kart w talii!');
      return '';
    }
  }
}
