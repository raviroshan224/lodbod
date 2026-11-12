import '../../../core/l10n/strings.dart';

enum CargoCategory {
  cement,
  steel,
  construction,
  foodGrains,
  fmcg,
  furniture,
  electronics,
  other;

  String get label => switch (this) {
    cement => l10n.cargoCement,
    steel => l10n.cargoSteel,
    construction => l10n.cargoConstruction,
    foodGrains => l10n.cargoFoodGrains,
    fmcg => l10n.cargoFmcg,
    furniture => l10n.cargoFurniture,
    electronics => l10n.cargoElectronics,
    other => l10n.cargoOther,
  };

  static CargoCategory? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}

enum VehicleType {
  openTruck,
  closedTruck,
  container,
  trailer,
  tipper,
  tanker,
  miniTruck;

  String get label => switch (this) {
    openTruck => l10n.vehicleOpen,
    closedTruck => l10n.vehicleClosed,
    container => l10n.vehicleContainer,
    trailer => l10n.vehicleTrailer,
    tipper => l10n.vehicleTipper,
    tanker => l10n.vehicleTanker,
    miniTruck => l10n.vehicleMini,
  };

  static VehicleType? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}

enum WeightUnit {
  tonne,
  kg;

  String get symbol => this == tonne ? l10n.unitTonneSymbol : l10n.unitKgSymbol;
  String get label => this == tonne ? l10n.unitTonnes : l10n.unitKilograms;

  double toTonnes(double value) => this == tonne ? value : value / 1000;

  static WeightUnit? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}
