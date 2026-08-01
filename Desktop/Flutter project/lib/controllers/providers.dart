import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../db/local_storage.dart';
import '../models/country.dart';
import '../models/bucket_list_item.dart';
import '../services/region_mapping_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final localStorageProvider = Provider((ref) => LocalStorage());

final isDarkModeProvider = StateProvider<bool>((ref) => false);

/// Loads the local country→region JSON mapping asset once.
/// All other providers that need region data must await this first.
final regionMappingProvider = FutureProvider<void>((ref) async {
  await RegionMappingService.load();
});

class CountriesNotifier extends StateNotifier<AsyncValue<List<Country>>> {
  final Ref _ref;
  final ApiService _api;
  final LocalStorage _storage;

  CountriesNotifier(this._ref, this._api, this._storage)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    // Ensure local mapping assets are available before parsing countries.
    await _ref.read(regionMappingProvider.future);

    final cached = await _storage.loadCountriesCache();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    } else {
      state = const AsyncValue.loading();
    }

    try {
      final remote = await _api.fetchCountries();
      state = AsyncValue.data(remote);
      await _storage.saveCountriesCache(remote);
    } catch (error, stackTrace) {
      if (cached.isEmpty) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

final countriesProvider =
    StateNotifierProvider<CountriesNotifier, AsyncValue<List<Country>>>((ref) {
  return CountriesNotifier(
    ref,
    ref.read(apiServiceProvider),
    ref.read(localStorageProvider),
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedRegionProvider = StateProvider<String>((ref) => 'All');
final sortOrderProvider = StateProvider<String>((ref) => 'A-Z');
final countriesPageProvider = StateProvider<int>((ref) => 1);

const int _countriesPageSize = 20;

final filteredCountriesProvider = Provider<List<Country>>((ref) {
  final countries = ref.watch(countriesProvider).valueOrNull ?? <Country>[];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final region = ref.watch(selectedRegionProvider);
  final sort = ref.watch(sortOrderProvider);

  var result = countries.where((c) {
    final matchesQuery = c.name.toLowerCase().contains(query);
    final matchesRegion = region == 'All' || c.region == region;
    return matchesQuery && matchesRegion;
  }).toList();

  if (sort == 'A-Z') {
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  } else {
    result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
  }
  return result;
});

final pagedCountriesProvider = Provider<List<Country>>((ref) {
  final filtered = ref.watch(filteredCountriesProvider);
  final page = ref.watch(countriesPageProvider);
  final maxItems = page * _countriesPageSize;
  final end = maxItems < filtered.length ? maxItems : filtered.length;
  return filtered.take(end).toList();
});

final hasMoreCountriesProvider = Provider<bool>((ref) {
  final filtered = ref.watch(filteredCountriesProvider);
  final page = ref.watch(countriesPageProvider);
  return (page * _countriesPageSize) < filtered.length;
});

class BucketListNotifier extends StateNotifier<List<BucketListItem>> {
  final LocalStorage _db;
  BucketListNotifier(this._db) : super([]) {
    _init();
  }

  Future<void> _init() async {
    state = await _db.loadBucketList();
  }

  Future<void> addOrUpdate(BucketListItem item) async {
    final index = state.indexWhere((e) => e.country.name == item.country.name);
    final newState = List<BucketListItem>.from(state);
    if (index >= 0) {
      newState[index] = item;
    } else {
      newState.add(item);
    }
    state = newState;
    await _db.saveBucketList(state);
  }

  Future<void> remove(String countryName) async {
    state = state.where((e) => e.country.name != countryName).toList();
    await _db.saveBucketList(state);
  }
}

final bucketListProvider = StateNotifierProvider<BucketListNotifier, List<BucketListItem>>((ref) {
  return BucketListNotifier(ref.read(localStorageProvider));
});

final bucketListSortProvider = StateProvider<String>((ref) => 'Alphabetical');
final bucketListRegionProvider = StateProvider<String>((ref) => 'All');

final sortedBucketListProvider = Provider<List<BucketListItem>>((ref) {
  final list = ref.watch(bucketListProvider);
  final sort = ref.watch(bucketListSortProvider);
  final region = ref.watch(bucketListRegionProvider);

  var sorted = List<BucketListItem>.from(list);

  // Filter by region
  if (region != 'All') {
    sorted = sorted.where((item) => item.country.region == region).toList();
  }

  // Sort
  if (sort == 'Alphabetical') {
    sorted.sort((a, b) => a.country.name.compareTo(b.country.name));
  } else if (sort == 'Descending') {
    sorted.sort((a, b) => b.country.name.compareTo(a.country.name));
  }
  return sorted;
});
