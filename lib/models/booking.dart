import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String stationId;
  final String stationName;
  final DateTime bookingDate;
  final String timeSlot;
  final double pricePerHr;
  final int hours;
  final double totalPrice;
  final BookingStatus status;
  final String? rejectionReason;
  final int portNumber;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.stationId,
    required this.stationName,
    required this.bookingDate,
    required this.timeSlot,
    required this.pricePerHr,
    required this.hours,
    required this.totalPrice,
    required this.status,
    this.rejectionReason,
    this.portNumber = 1,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};

      DateTime parseDate(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is Timestamp) return value.toDate();
        if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
        if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
        return DateTime.now();
      }

      double parseDouble(dynamic value, double defaultValue) {
        if (value == null) return defaultValue;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? defaultValue;
        return defaultValue;
      }

      int parseInt(dynamic value, int defaultValue) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value) ?? defaultValue;
        return defaultValue;
      }

      return Booking(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        userName: data['userName']?.toString() ?? '',
        userPhone: data['userPhone']?.toString() ?? '',
        stationId: data['stationId']?.toString() ?? '',
        stationName: data['stationName']?.toString() ?? 'Unknown Station',
        bookingDate: parseDate(data['bookingDate']),
        timeSlot: data['timeSlot']?.toString() ?? '',
        pricePerHr: parseDouble(data['pricePerHr'], 0.0),
        hours: parseInt(data['hours'], 0),
        totalPrice: parseDouble(data['totalPrice'], 0.0),
        status: BookingStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (data['status']?.toString() ?? 'pending'),
          orElse: () => BookingStatus.pending,
        ),
        rejectionReason: data['rejectionReason']?.toString(),
        portNumber: parseInt(data['portNumber'], 1),
      );
    } catch (e) {
      print("Error parsing Booking ${doc.id}: $e");
      rethrow;
    }
  }
}
