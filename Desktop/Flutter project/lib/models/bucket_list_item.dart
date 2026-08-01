import 'country.dart';

class BucketListItem {
  final Country country;
  String notes;

  BucketListItem({
    required this.country,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country.toJson(),
      'notes': notes,
    };
  }

  factory BucketListItem.fromJson(Map<String, dynamic> json) {
    return BucketListItem(
      country: Country.fromJson(json['country']),
      notes: json['notes'] ?? '',
    );
  }
}
