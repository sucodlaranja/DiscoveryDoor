import 'package:discovery_door/data/museum.dart';

class Regist {
  late String date;
  late int tempoDeViagem;
  late Museum museum;

  Regist({
    required this.date,
    required this.tempoDeViagem,
    required this.museum,
  });

  factory Regist.fromJson(Map<String, dynamic> json) {
    return Regist(
      date: json['date'],
      tempoDeViagem: json['tempoDeViagem'],
      museum: Museum.fromJson(json['museu']),
    );
  }
}
