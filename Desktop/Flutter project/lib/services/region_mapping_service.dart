import 'dart:convert';
import 'package:flutter/services.dart';

/// Loads local JSON mapping assets for regions, languages, and timezones once.
/// Provides O(1) fallback lookups by country name.
class RegionMappingService {
  static Map<String, String> _regionCache = {};
  static Map<String, List<String>> _languageCache = {};
  static Map<String, List<String>> _timezoneCache = {};
  static bool _loaded = false;

  /// Call this once before parsing country data.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      final regionsRaw = await rootBundle.loadString('assets/country_regions.json');
      final Map<String, dynamic> decodedRegions = json.decode(regionsRaw);
      _regionCache = decodedRegions.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _regionCache = {};
    }

    try {
      final languagesRaw = await rootBundle.loadString('assets/country_languages.json');
      final Map<String, dynamic> decodedLanguages = json.decode(languagesRaw);
      _languageCache = decodedLanguages.map((k, v) => MapEntry(k, List<String>.from(v ?? [])));
    } catch (_) {
      _languageCache = {};
    }

    try {
      final timezonesRaw = await rootBundle.loadString('assets/country_timezones.json');
      final Map<String, dynamic> decodedTimezones = json.decode(timezonesRaw);
      _timezoneCache = decodedTimezones.map((k, v) => MapEntry(k, List<String>.from(v ?? [])));
    } catch (_) {
      _timezoneCache = {};
    }

    _loaded = true;
  }

  /// Returns the region string for [countryName], or 'Unknown' if not found.
  static String regionFor(String countryName) {
    if (countryName.isEmpty) return 'Unknown';
    return _regionCache[countryName] ?? 'Unknown';
  }

  /// Fuzzy fallback: tries to match if any cache key is contained in [countryName]
  /// or [countryName] is contained in a cache key (case-insensitive).
  static String fuzzyRegionFor(String countryName) {
    if (countryName.isEmpty) return 'Unknown';
    final nameLower = countryName.toLowerCase();
    for (final entry in _regionCache.entries) {
      final keyLower = entry.key.toLowerCase();
      if (nameLower.contains(keyLower) || keyLower.contains(nameLower)) {
        return entry.value;
      }
    }
    return 'Unknown';
  }

  /// Returns the languages list for [countryName], or empty list if not found.
  static List<String> languagesFor(String countryName) {
    if (countryName.isEmpty) return [];
    return _languageCache[countryName] ?? [];
  }

  /// Returns the timezones list for [countryName], or empty list if not found.
  static List<String> timezonesFor(String countryName) {
    if (countryName.isEmpty) return [];
    return _timezoneCache[countryName] ?? [];
  }

  /// Returns all unique regions present in the mapping (sorted).
  static List<String> get allRegions {
    final regions = _regionCache.values.toSet().toList()..sort();
    return regions;
  }

  /// Resets the cache (useful for testing).
  static void reset() {
    _regionCache = {};
    _languageCache = {};
    _timezoneCache = {};
    _loaded = false;
  }
}
