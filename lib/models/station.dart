import 'package:cloud_firestore/cloud_firestore.dart';

class Station {
  final String id;
  final String stationName;
  final String ownerName;
  final String address;
  final double latitude;
  final double longitude;
  final String chargerType;
  final int totalPorts;
  final int availablePorts;
  final double pricePerUnit;
  final double rating;
  final DateTime? createdAt;
  final String ownerId;

  Station({
    required this.id,
    required this.stationName,
    required this.ownerName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.chargerType,
    required this.totalPorts,
    required this.availablePorts,
    required this.pricePerUnit,
    this.rating = 4.5,
    this.createdAt,
    required this.ownerId,
  });

  factory Station.fromMap(String id, Map<String, dynamic> data) {
    return Station(
      id: id,
      stationName:
          (data['stationName'] ?? data['name'])?.toString() ??
          'Unnamed Station',
      ownerName: data['ownerName']?.toString() ?? 'App Admin',
      address: data['address']?.toString() ?? 'Unknown Address',
      latitude: double.tryParse(data['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(data['longitude']?.toString() ?? '0') ?? 0.0,
      chargerType: data['chargerType']?.toString() ?? 'Type2',
      totalPorts: int.tryParse(data['totalPorts']?.toString() ?? '0') ?? 1,
      availablePorts:
          int.tryParse(data['availablePorts']?.toString() ?? '0') ?? 1,
      pricePerUnit:
          double.tryParse(data['pricePerUnit']?.toString() ?? '0') ?? 0.0,
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 4.5,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      ownerId: data['ownerId']?.toString() ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationName': stationName,
      'name': stationName,
      'ownerName': ownerName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'chargerType': chargerType,
      'totalPorts': totalPorts,
      'availablePorts': availablePorts,
      'pricePerUnit': pricePerUnit,
      'rating': rating,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'ownerId': ownerId,
    };
  }
}
