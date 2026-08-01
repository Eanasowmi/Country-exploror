import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bucket_list_item.dart';
import '../models/country.dart';

class LocalStorage {
  static const String _bucketListKey = 'bucket_list';
  static const String _countriesCacheKey = 'countries_cache';

  Future<void> saveBucketList(List<BucketListItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_bucketListKey, data);
  }

  Future<List<BucketListItem>> loadBucketList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_bucketListKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => BucketListItem.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveCountriesCache(List<Country> countries) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(countries.map((e) => e.toJson()).toList());
    await prefs.setString(_countriesCacheKey, data);
  }

  Future<List<Country>> loadCountriesCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_countriesCacheKey);
    if (data == null || data.isEmpty) {
      return [];
    }

    final List decoded = jsonDecode(data);
    return decoded
        .whereType<Map<String, dynamic>>()
        .map((e) => Country.fromJson(e))
        .toList();
  }
}
