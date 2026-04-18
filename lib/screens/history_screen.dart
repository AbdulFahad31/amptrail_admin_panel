import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/sidebar.dart';
import '../theme_constants.dart';
import '../models/booking.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  late Future<List<Booking>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final user = _authService.currentUser;
    if (user != null) {
      _historyFuture = _firestoreService.getBookingHistory(user.uid).then((docs) {
        final List<Booking> bookings = [];
        for (var doc in docs) {
          try {
            bookings.add(Booking.fromFirestore(doc));
          } catch (e) {
            // skip unparseable
          }
        }
        bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
        return bookings;
      });
    } else {
      _historyFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Please log in', style: TextStyle(color: AppColors.textMain)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(activeRoute: 'history'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking History',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _loadHistory();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Linked to this current admin user',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: FutureBuilder<List<Booking>>(
                      future: _historyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading history: ${snapshot.error}',
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          );
                        }

                        final bookings = snapshot.data ?? [];

                        if (bookings.isEmpty) {
                          return const Center(
                            child: Text(
                              'No booking history found.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 600,
                            mainAxisExtent: 220,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(bookings[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.completed:
        statusColor = AppColors.primary;
        break;
      case BookingStatus.pending:
        statusColor = Colors.orangeAccent;
        break;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        statusColor = AppColors.danger;
        break;
      case BookingStatus.accepted:
        statusColor = Colors.blueAccent;
        break;
    }

    final dateStr = DateFormat('dd MMM yyyy').format(booking.bookingDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.ev_station,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.stationName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${booking.id}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (booking.userName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'User: ${booking.userName} (${booking.userPhone})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(dateStr, style: const TextStyle(color: AppColors.textMain, fontSize: 13)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(booking.timeSlot.isNotEmpty ? booking.timeSlot : 'N/A', style: const TextStyle(color: AppColors.textMain, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timelapse_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('${booking.hours} Hours', style: const TextStyle(color: AppColors.textMain, fontSize: 13)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.wallet_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('₹${booking.totalPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: statusColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                booking.status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
