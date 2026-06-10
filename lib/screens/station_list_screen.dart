import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/station.dart';
import '../widgets/sidebar.dart';
import '../theme_constants.dart';
import '../screens/add_station_screen.dart';
import 'package:intl/intl.dart';

class StationListScreen extends StatefulWidget {
  const StationListScreen({super.key});

  @override
  State<StationListScreen> createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  Future<void> _deleteStation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Station',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: const Text(
          'Are you sure you want to delete this station?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteStation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Station deleted'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _editStation(Station station) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddStationScreen(stationToEdit: station),
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Please log in',
            style: TextStyle(color: AppColors.textMain),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(activeRoute: 'manage_stations'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage Stations',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
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
                      child: StreamBuilder<List<Station>>(
                        stream: _firestoreService.getStationsByOwner(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            );
                          }

                          final stations = snapshot.data ?? [];

                          if (stations.isEmpty) {
                            return const Center(
                              child: Text(
                                'No stations added yet.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: DataTable(
                                  headingTextStyle: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  dataTextStyle: const TextStyle(
                                    color: AppColors.textMain,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('Station Name')),
                                    DataColumn(label: Text('Charger Type')),
                                    DataColumn(label: Text('Ports')),
                                    DataColumn(label: Text('Price/kWh')),
                                    DataColumn(label: Text('Date Added')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: stations.map((station) {
                                    final dateStr = station.createdAt != null
                                        ? DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(station.createdAt!)
                                        : 'N/A';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station.stationName)),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              station.chargerType,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${station.availablePorts} / ${station.totalPorts}',
                                          ),
                                        ),
                                        DataCell(
                                          Text('₹${station.pricePerUnit}'),
                                        ),
                                        DataCell(Text(dateStr)),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blueAccent,
                                                ),
                                                onPressed: () =>
                                                    _editStation(station),
                                                splashRadius: 20,
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.danger,
                                                ),
                                                onPressed: () =>
                                                    _deleteStation(station.id),
                                                splashRadius: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
}
