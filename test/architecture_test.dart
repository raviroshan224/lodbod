import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces feature-first clean architecture (docs/TECHNICAL_NOTE.md §1).
///
/// Every feature has three layers, and dependencies point inward:
///
///   lib/features/{feature}/
///     presentation/  screens, widgets, Riverpod state ─┐
///     data/          Firebase repository ──────────────┴─► domain/  pure
///                                                Dart: models, contract, rules
///
/// - domain imports only other domain code and core's pure-Dart errors and
///   utils: no Flutter, no Firebase.
/// - data implements the domain contract and never imports presentation. Its
///   internals are private: the rest of the app reaches a repository only
///   through the feature's `data/providers.dart`.
/// - A feature may use another feature's domain, state and widgets, but never
///   its screens: screens are reached through routes.
/// - core is feature-agnostic, and only data (plus core/firebase and app
///   start-up) touches Firebase.
void main() {
  final graph = _ImportGraph.load('lib');

  test('the scan sees the whole app, and every file has a layer', () {
    expect(graph.files.length, greaterThan(80));
    expect(
      graph.files.where((f) => _Place.of(f) == null).toList(),
      isEmpty,
      reason:
          'Feature code lives in features/<name>/{domain,data,presentation}; '
          'shared code in core/<area>; navigation in routing/.',
    );
  });

  test('domain is pure Dart: other domain code and core errors/utils only', () {
    expect(
      graph.violations((from, to) {
        if (from.layer != 'domain') return false;
        if (to.isDart) return false;
        return !(to.layer == 'domain' || to.isCore('errors', 'utils'));
      }),
      isEmpty,
    );
  });

  test("core's errors and utils are pure Dart too", () {
    expect(
      graph.violations(
        (from, to) =>
            from.isCore('errors', 'utils') &&
            !to.isDart &&
            !to.isCore('errors', 'utils'),
      ),
      isEmpty,
    );
  });

  test('dependencies point inward: data never imports UI', () {
    expect(
      graph.violations(
        (from, to) =>
            from.layer == 'data' &&
            (to.layer == 'presentation' ||
                to.area == 'routing' ||
                to.isCore('widgets', 'theme', 'platform')),
      ),
      isEmpty,
    );
  });

  test('outside data, repositories are reached only via data/providers', () {
    expect(
      graph.violations(
        (from, to) =>
            from.layer != 'data' &&
            from.area != 'core' &&
            to.layer == 'data' &&
            !to.path.endsWith('/data/providers.dart'),
      ),
      isEmpty,
      reason: 'Repository implementations and mappers are private to data.',
    );
  });

  test("a feature never imports another feature's screens", () {
    expect(
      graph.violations(
        (from, to) =>
            from.feature != null &&
            to.feature != null &&
            from.feature != to.feature &&
            to.path.endsWith('_screen.dart'),
      ),
      isEmpty,
      reason: 'Navigate with Routes; the router composes the screens.',
    );
  });

  test('core is feature-agnostic', () {
    expect(
      graph.violations(
        (from, to) =>
            from.area == 'core' && (to.feature != null || to.area == 'routing'),
      ),
      isEmpty,
    );
  });

  test('only data, core/firebase and app start-up know about Firebase', () {
    expect(
      graph.violations(
        (from, to) =>
            to.isFirebase &&
            from.layer != 'data' &&
            !from.isCore('firebase') &&
            from.area != 'app',
      ),
      isEmpty,
    );
  });
}

/// Where a file or import target sits in the architecture.
class _Place {
  _Place._(this.path, {this.area, this.sub, this.feature, this.layer});

  final String path;

  /// `app` (main, app, firebase options), `core`, `routing` or `features`;
  /// null for packages and `dart:`.
  final String? area;

  /// The core area (`widgets`, `errors`, ...) for core files.
  final String? sub;
  final String? feature;

  /// `domain`, `data` or `presentation` for feature files.
  final String? layer;

  static const _layers = {'domain', 'data', 'presentation'};
  static const _coreAreas = {
    'constants',
    'errors',
    'firebase',
    'platform',
    'theme',
    'utils',
    'widgets',
  };

  bool get isDart => path.startsWith('dart:');
  bool get isFirebase =>
      path.startsWith('package:firebase_') ||
      path.startsWith('package:cloud_firestore');
  bool isCore(String a, [String? b, String? c]) =>
      area == 'core' && {a, b, c}.contains(sub);

  /// Null when [path] is an app file outside every known place.
  static _Place? of(String path) {
    if (!path.startsWith('lib/')) return _Place._(path);
    final parts = path.split('/');
    if (parts.length == 2) return _Place._(path, area: 'app');
    switch (parts[1]) {
      case 'routing':
        return _Place._(path, area: 'routing');
      case 'core' when parts.length > 3 && _coreAreas.contains(parts[2]):
        return _Place._(path, area: 'core', sub: parts[2]);
      case 'features' when parts.length > 4 && _layers.contains(parts[3]):
        return _Place._(
          path,
          area: 'features',
          feature: parts[2],
          layer: parts[3],
        );
    }
    return null;
  }
}

class _ImportGraph {
  _ImportGraph(this.imports);

  /// Every app file mapped to what it imports: `lib/...` paths for app
  /// files, `dart:x` and `package:x/...` otherwise.
  final Map<String, List<String>> imports;

  Iterable<String> get files => imports.keys;

  static final _directive = RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  );

  static _ImportGraph load(String root) {
    final imports = <String, List<String>>{};
    final dartFiles = Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in dartFiles) {
      final path = file.path.replaceAll(r'\', '/');
      imports[path] = [
        for (final m in _directive.allMatches(file.readAsStringSync()))
          _resolve(path, m.group(1)!),
      ];
    }
    return _ImportGraph(imports);
  }

  static String _resolve(String from, String uri) {
    const self = 'package:lodbod/';
    if (uri.startsWith(self)) return 'lib/${uri.substring(self.length)}';
    if (uri.contains(':')) return uri;
    // Resolving against the importing file also removes `..` segments.
    return Uri(path: from).resolve(uri).path;
  }

  /// "file → import" for every import matching [breaks], sorted. Unplaced
  /// files are reported by the first test instead.
  List<String> violations(bool Function(_Place from, _Place to) breaks) => [
    for (final MapEntry(key: file, value: targets) in imports.entries)
      if (_Place.of(file) case final from?)
        for (final target in targets)
          if (_Place.of(target) case final to? when breaks(from, to))
            '$file → $target',
  ]..sort();
}
