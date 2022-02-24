import 'package:dio/dio.dart';
import 'package:discovery_door/data/directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
    required int transport,
  }) async {
    final mode = transport == 1
        ? 'driving'
        : transport == 2
            ? 'walking'
            : 'bicycling';

    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': 'AIzaSyCE0ftWsd_caoV1AS_O8v67JDVi3E1eKMQ',
        'mode': mode,
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      final directions = Directions.fromMap(response.data);

      if (directions.bounds == null) return null;
      return directions;
    }
    return null;
  }
}
