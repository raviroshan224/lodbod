import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/app_exception.dart';

/// Upper bound for any single write. Firestore queues writes while offline
/// and would otherwise leave the UI spinning; failing fast lets us tell the
/// user honestly that the action did not go through.
const writeTimeout = Duration(seconds: 15);

/// Runs a Firestore operation, applying [writeTimeout] and translating any
/// failure into an [AppException].
Future<T> guarded<T>(Future<T> Function() action) async {
  try {
    return await action().timeout(writeTimeout);
  } catch (error) {
    throw mapError(error);
  }
}

/// Maps stream errors to [AppException]s.
StreamTransformer<T, T> mapStreamErrors<T>() =>
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stack, sink) =>
          sink.addError(mapError(error), stack),
    );

/// Parses documents, skipping (and logging the id of) any malformed record
/// so one bad document can't take down the whole list.
List<T> parseDocs<T>(
  Iterable<({String id, Map<String, dynamic> data})> docs,
  T Function(String id, Map<String, dynamic> data) parse,
) {
  final out = <T>[];
  for (final doc in docs) {
    try {
      out.add(parse(doc.id, doc.data));
    } on FormatException catch (e) {
      debugPrint('Skipping malformed document ${doc.id}: ${e.message}');
    }
  }
  return out;
}

/// Appends one entry to a shipment's stored timeline array.
List<Map<String, dynamic>> appendTimeline(
  Map<String, dynamic> shipmentData,
  Map<String, dynamic> entry,
) {
  final existing = (shipmentData['timeline'] as List? ?? const [])
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e));
  return [...existing, entry];
}

int readInt(Map<String, dynamic>? data, String key) =>
    (data?[key] as num?)?.toInt() ?? 0;
