import '../services/region_mapping_service.dart';

class Country {
  final String name;
  final String alpha2Code;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final String flag;
  final String coatOfArms;
  final List<String> timezones;
  final List<String> borders;
  final List<String> languages;

  Country({
    required this.name,
    required this.alpha2Code,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.flag,
    required this.coatOfArms,
    required this.timezones,
    required this.borders,
    required this.languages,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final countryName = _resolveCountryName(json);
    final alpha2Code = _resolveAlpha2Code(json);
    final apiLanguages = _toStringList(json['languages']);
    final apiTimezones = _toStringList(json['timezones']);
    final apiFlag = _resolveFlag(json);
    final apiCoatOfArms = _resolveCoatOfArms(json);

    return Country(
      name: countryName.isEmpty ? 'Unknown' : countryName,
      alpha2Code: alpha2Code,
      capital: _resolveCapital(json),
      region: _resolveRegion(countryName, json['region']),
      subregion: json['subregion'] ?? '',
      population: json['population'] != null 
          ? int.tryParse(json['population'].toString()) ?? 0 
          : 0,
      // Prefer a stable flag CDN URL from alpha-2 code when available.
      flag: _resolveFlagUrl(alpha2Code, apiFlag),
      coatOfArms: apiCoatOfArms,
      timezones: apiTimezones.isNotEmpty ? apiTimezones : RegionMappingService.timezonesFor(countryName),
      borders: _toStringList(json['borders']),
      languages: apiLanguages.isNotEmpty ? apiLanguages : RegionMappingService.languagesFor(countryName),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'alpha2Code': alpha2Code,
      'capital': capital,
      'region': region,
      'subregion': subregion,
      'population': population,
      'flag': flag,
      'coatOfArms': coatOfArms,
      'timezones': timezones,
      'borders': borders,
      'languages': languages,
    };
  }
}

String _resolveCountryName(Map<String, dynamic> json) {
  final rawName = json['name'];
  if (rawName is Map<String, dynamic>) {
    final common = rawName['common'] ?? rawName['official'];
    if (common != null && common.toString().trim().isNotEmpty) {
      return common.toString().trim();
    }
  }

  final name = (rawName ?? json['commonName'] ?? '').toString().trim();
  return name.isEmpty ? 'Unknown' : name;
}

String _resolveAlpha2Code(Map<String, dynamic> json) {
  final candidates = [
    json['abbreviation'],
    json['alpha2Code'],
    json['cca2'],
    json['code'],
  ];

  for (final candidate in candidates) {
    final rawCode = candidate.toString().trim().toUpperCase();
    if (RegExp(r'^[A-Z]{2}$').hasMatch(rawCode)) {
      return rawCode;
    }
  }
  return '';
}

String _resolveCapital(Map<String, dynamic> json) {
  final capital = json['capital'];
  if (capital is List && capital.isNotEmpty) {
    return capital.first.toString();
  }

  final capitalText = (capital ?? json['capitalName'] ?? 'N/A').toString().trim();
  return capitalText.isEmpty ? 'N/A' : capitalText;
}

String _resolveFlag(Map<String, dynamic> json) {
  final media = json['media'];
  if (media is Map<String, dynamic>) {
    final flag = media['flag'] ?? media['png'] ?? media['svg'];
    if (flag != null && flag.toString().trim().isNotEmpty) {
      return flag.toString().trim();
    }
  }

  final flags = json['flags'];
  if (flags is Map<String, dynamic>) {
    final flag = flags['png'] ?? flags['svg'];
    if (flag != null && flag.toString().trim().isNotEmpty) {
      return flag.toString().trim();
    }
  }

  return (json['flag'] ?? '').toString();
}

String _resolveCoatOfArms(Map<String, dynamic> json) {
  final media = json['media'];
  if (media is Map<String, dynamic>) {
    final coat = media['emblem'] ?? media['coatOfArms'] ?? media['coat'];
    if (coat != null && coat.toString().trim().isNotEmpty) {
      return coat.toString().trim();
    }
  }

  final coatOfArms = json['coatOfArms'];
  if (coatOfArms is Map<String, dynamic>) {
    final coat = coatOfArms['png'] ?? coatOfArms['svg'];
    if (coat != null && coat.toString().trim().isNotEmpty) {
      return coat.toString().trim();
    }
  }

  return (json['coatOfArms'] ?? '').toString();
}

String _resolveFlagUrl(String alpha2Code, String apiFlag) {
  if (alpha2Code.isNotEmpty) {
    return 'https://flagcdn.com/w320/${alpha2Code.toLowerCase()}.png';
  }
  return apiFlag;
}

List<String> _toStringList(dynamic value) {
  if (value is Map) {
    return value.values.map((item) => item.toString()).toList();
  }
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return <String>[];
}

/// Resolves the region for a country:
/// 1. Uses the API-supplied region if non-empty.
/// 2. Falls back to the local [RegionMappingService] exact lookup.
/// 3. Tries case-insensitive substring matching as a last resort.
/// 4. Returns 'Unknown' if nothing matches.
String _resolveRegion(String countryName, dynamic apiRegion) {
  if (apiRegion != null && apiRegion.toString().trim().isNotEmpty) {
    return apiRegion.toString().trim();
  }
  final exact = RegionMappingService.regionFor(countryName);
  if (exact != 'Unknown') return exact;

  // Try fuzzy: check if any known key is contained in countryName or vice-versa
  return RegionMappingService.fuzzyRegionFor(countryName);
}
