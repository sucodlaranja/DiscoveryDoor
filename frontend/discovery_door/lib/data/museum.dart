import 'package:discovery_door/data/review.dart';

class Museum {
  final String name;
  final String website;
  final int price;
  final String contact;
  final String address;
  final List<String> photos;
  final List<Review> reviews;
  final String category;
  final double lat;
  final double lng;
  final double evaluation;

  Museum(
      {required this.name,
      required this.website,
      required this.price,
      required this.contact,
      required this.address,
      required this.photos,
      required this.reviews,
      required this.category,
      required this.lat,
      required this.lng,
      required this.evaluation});

  factory Museum.fromJson(Map<String, dynamic> json) {
    return Museum(
      name: json['name'],
      website: json['website'],
      price: json['preco'],
      contact: json['contacto'],
      address: json['endereco'],
      photos: List.from(json['fotografias']),
      reviews: json['reviews']
          .map<Review>((json2) => Review.fromJson(json2))
          .toList(),
      category: json['categoria'] ?? '',
      lat: json['latitude'],
      lng: json['longitude'],
      evaluation: json['avaliacao'],
    );
  }
}
