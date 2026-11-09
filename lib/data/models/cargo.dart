enum CargoCategory {
  cement('Cement'),
  steel('Steel'),
  construction('Construction material'),
  foodGrains('Food grains'),
  fmcg('FMCG'),
  furniture('Furniture'),
  electronics('Electronics'),
  other('Other');

  const CargoCategory(this.label);
  final String label;

  static CargoCategory? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}

enum VehicleType {
  openTruck('Open truck'),
  closedTruck('Closed truck'),
  container('Container'),
  trailer('Trailer'),
  tipper('Tipper'),
  tanker('Tanker'),
  miniTruck('Mini truck');

  const VehicleType(this.label);
  final String label;

  static VehicleType? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}

enum WeightUnit {
  tonne('t', 'Tonnes'),
  kg('kg', 'Kilograms');

  const WeightUnit(this.symbol, this.label);
  final String symbol;
  final String label;

  double toTonnes(double value) => this == tonne ? value : value / 1000;

  static WeightUnit? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}
