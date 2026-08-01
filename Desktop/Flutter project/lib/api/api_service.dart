import 'package:dio/dio.dart';
import '../models/country.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static const String _primaryEndpoint =
      'https://api.sampleapis.com/countries/countries';

  Future<List<Country>> fetchCountries() async {
    final response = await _dio.get(_primaryEndpoint);
    if (response.statusCode == 200) {
      final parsed = _parseCountries(response.data);
      if (parsed.isNotEmpty) {
        return parsed;
      }
    }

    return <Country>[];
  }

  List<Country> _parseCountries(dynamic data) {
    if (data is! List) {
      return <Country>[];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(Country.fromJson)
        .toList();
  }
}
