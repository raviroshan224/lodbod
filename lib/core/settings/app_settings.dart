import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UI language. Stored on the device, not the account: it's a property of
/// the phone in hand.
enum AppLanguage {
  english('en', 'English'),
  nepali('ne', 'नेपाली');

  const AppLanguage(this.code, this.nativeName);
  final String code;
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      values.where((l) => l.code == code).firstOrNull ?? english;
}

/// Light / dark preference. [system] follows the phone setting.
enum Appearance {
  system,
  light,
  dark;

  Brightness resolve(Brightness platform) => switch (this) {
    system => platform,
    light => Brightness.light,
    dark => Brightness.dark,
  };

  static Appearance fromName(String? name) =>
      values.where((a) => a.name == name).firstOrNull ?? system;
}

class AppSettings {
  const AppSettings({
    this.language = AppLanguage.english,
    this.appearance = Appearance.system,
  });

  final AppLanguage language;
  final Appearance appearance;

  AppSettings copyWith({AppLanguage? language, Appearance? appearance}) =>
      AppSettings(
        language: language ?? this.language,
        appearance: appearance ?? this.appearance,
      );
}

/// The device's preference store. `main` overrides it with the real one;
/// tests leave it null and settings stay in memory.
final sharedPreferencesProvider = Provider<SharedPreferences?>((_) => null);

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _languageKey = 'settings.language';
  static const _appearanceKey = 'settings.appearance';

  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = _prefs;
    return AppSettings(
      language: AppLanguage.fromCode(prefs?.getString(_languageKey)),
      appearance: Appearance.fromName(prefs?.getString(_appearanceKey)),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await _prefs?.setString(_languageKey, language.code);
  }

  Future<void> setAppearance(Appearance appearance) async {
    state = state.copyWith(appearance: appearance);
    await _prefs?.setString(_appearanceKey, appearance.name);
  }
}
