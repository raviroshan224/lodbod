/// Suggestions for the pickup/destination fields. Free text is still
/// accepted; a production app would use a places/geocoding API.
const nepalCities = [
  'Kathmandu',
  'Lalitpur',
  'Bhaktapur',
  'Pokhara',
  'Birgunj',
  'Biratnagar',
  'Butwal',
  'Bhairahawa',
  'Narayanghat',
  'Bharatpur',
  'Hetauda',
  'Dharan',
  'Itahari',
  'Janakpur',
  'Nepalgunj',
  'Dhangadhi',
  'Mahendranagar',
  'Birtamod',
  'Damak',
  'Banepa',
  'Mugling',
  'Tansen',
  'Ghorahi',
  'Tulsipur',
  'Surkhet',
  'Kakarbhitta',
  'Lahan',
  'Rajbiraj',
  'Gaur',
  'Kalaiya',
];

List<String> suggestCities(String query, {int limit = 6}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final starts = nepalCities.where((c) => c.toLowerCase().startsWith(q));
  final contains = nepalCities.where(
    (c) => !c.toLowerCase().startsWith(q) && c.toLowerCase().contains(q),
  );
  return [
    ...starts,
    ...contains,
  ].where((c) => c.toLowerCase() != q).take(limit).toList();
}
