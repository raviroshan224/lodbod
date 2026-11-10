import 'dart:io';
import 'dart:ui' as ui;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod/app.dart';
import 'package:lodbod/features/auth/session.dart';
import 'package:lodbod/routing/app_router.dart';

import 'fakes.dart';
import 'helpers.dart';

/// Loads the app's real font. The default test font draws every glyph a full
/// em wide (about twice Inter's width), which would exaggerate overflows.
Future<void> loadInterFont() async {
  final inter = FontLoader('Inter');
  for (final w in [400, 500, 600, 700, 800]) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();
}

/// Loads the Material icon font from the Flutter SDK so rendered screens
/// show real icons (the test default draws boxes).
Future<void> loadIconFont() async {
  final sdk = File(Platform.resolvedExecutable)
      .parent
      .parent
      .parent
      .parent
      .path;
  final file = File('$sdk/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (!file.existsSync()) return;
  final bytes = file.readAsBytesSync();
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

final appBoundaryKey = GlobalKey();

/// The whole app (router, shell, every provider) over in-memory fakes.
class AppHarness {
  AppHarness(this.tester, this.container, this.auth, this.uid);
  final WidgetTester tester;
  final ProviderContainer container;
  final FakeAuthRepository auth;
  final String uid;

  GoRouter get router => container.read(routerProvider);

  /// Lets fake Firestore deliver, then advances animations without waiting
  /// for infinite ones (shimmer, tracking truck) to finish.
  Future<void> settle() async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> go(String location) async {
    router.go(location);
    await settle();
  }

  /// Saves what's on screen as a PNG (for design review).
  Future<void> capture(String path) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(appBoundaryKey),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  Future<void> tapText(String text) async {
    final target = find.text(text).last;
    await tester.ensureVisible(target);
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(target);
    await settle();
  }
}

Future<AppHarness> pumpApp(
  WidgetTester tester, {
  Size size = const Size(412, 915),
  double textScale = 1,
  bool signedIn = true,
  bool withSamples = true,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final auth = FakeAuthRepository();
  late ProviderContainer container;
  late String uid;
  await tester.runAsync(() async {
    (container, uid) = await signedInContainer(
      FakeFirebaseFirestore(),
      auth: auth,
      withSamples: withSamples,
    );
    if (!signedIn) await container.read(authActionsProvider).signOut();
  });
  addTearDown(container.dispose);

  await tester.pumpWidget(
    RepaintBoundary(
      key: appBoundaryKey,
      child: UncontrolledProviderScope(
        container: container,
        child: const LodbodApp(),
      ),
    ),
  );
  final app = AppHarness(tester, container, auth, uid);
  await app.settle();
  return app;
}
