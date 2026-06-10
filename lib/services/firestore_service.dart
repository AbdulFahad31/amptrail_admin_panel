import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/station.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService()
    : _db = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'stations31',
      ) {
    _db.settings = const Settings(persistenceEnabled: true);
  }

  Future<void> addStation(Station station) async {
    await _db.collection('stations').add(station.toMap());
  }

  Future<void> updateStation(Station station) async {
    await _db.collection('stations').doc(station.id).update(station.toMap());
  }

  Future<void> deleteStation(String stationId) async {
    await _db.collection('stations').doc(stationId).delete();
  }

  Stream<List<Station>> getStationsByOwner(String ownerId) {
    return _db
        .collection('stations')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<Station>> getAllStations() {
    return _db
        .collection('stations')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Station.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getBookingHistory(
    String ownerId,
  ) async {
    final stationSnap = await _db
        .collection('stations')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final stationIds = stationSnap.docs.map((doc) => doc.id).toList();

    if (stationIds.isEmpty) return [];

    final allBookings = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < stationIds.length; i += 10) {
      final chunk = stationIds.sublist(
        i,
        i + 10 > stationIds.length ? stationIds.length : i + 10,
      );
      final bookingsSnap = await _db
          .collection('bookings')
          .where('stationId', whereIn: chunk)
          .get();
      allBookings.addAll(bookingsSnap.docs);
    }

    return allBookings;
  }
}
