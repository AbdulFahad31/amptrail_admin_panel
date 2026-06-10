import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/station.dart';
import '../widgets/sidebar.dart';
import '../theme_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(activeRoute: 'dashboard'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  StreamBuilder<List<Station>>(
                    stream: firestoreService.getStationsByOwner(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Error fetching data',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      final stations = snapshot.data ?? [];
                      final totalStations = stations.length;
                      final totalPorts = stations.fold(
                        0,
                        (sum, station) => sum + station.totalPorts,
                      );
                      final availablePorts = stations.fold(
                        0,
                        (sum, station) => sum + station.availablePorts,
                      );

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final cards = [
                            _buildStatCard(
                              'Total Stations',
                              totalStations.toString(),
                              Icons.ev_station,
                              Colors.blueAccent,
                            ),
                            _buildStatCard(
                              'Total Ports',
                              totalPorts.toString(),
                              Icons.electrical_services,
                              Colors.orangeAccent,
                            ),
                            _buildStatCard(
                              'Available Ports',
                              availablePorts.toString(),
                              Icons.check_circle_outline,
                              AppColors.primary,
                            ),
                          ];

                          if (constraints.maxWidth < 760) {
                            return Column(
                              children: [
                                for (var i = 0; i < cards.length; i++) ...[
                                  cards[i],
                                  if (i != cards.length - 1)
                                    const SizedBox(height: 16),
                                ],
                              ],
                            );
                          }

                          return Row(
                            children: [
                              for (var i = 0; i < cards.length; i++) ...[
                                Expanded(child: cards[i]),
                                if (i != cards.length - 1)
                                  const SizedBox(width: 16),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
