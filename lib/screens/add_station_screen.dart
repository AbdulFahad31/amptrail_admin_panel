import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/station.dart';
import '../widgets/sidebar.dart';
import '../theme_constants.dart';
import 'station_list_screen.dart';

class AddStationScreen extends StatefulWidget {
  final Station? stationToEdit;

  const AddStationScreen({super.key, this.stationToEdit});

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stationNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _totalPortsController = TextEditingController();
  final _priceController = TextEditingController();

  String _chargerType = 'Type2';
  final List<String> _chargerTypes = const ['Type2', 'DC Fast'];

  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.stationToEdit != null) {
      final station = widget.stationToEdit!;
      _stationNameController.text = station.stationName;
      _ownerNameController.text = station.ownerName;
      _addressController.text = station.address;
      _latitudeController.text = station.latitude.toString();
      _longitudeController.text = station.longitude.toString();
      _totalPortsController.text = station.totalPorts.toString();
      _priceController.text = station.pricePerUnit.toString();

      if (_chargerTypes.contains(station.chargerType)) {
        _chargerType = station.chargerType;
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final totalPorts = int.parse(_totalPortsController.text);

      final station = Station(
        id: widget.stationToEdit != null ? widget.stationToEdit!.id : '',
        stationName: _stationNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        chargerType: _chargerType,
        totalPorts: totalPorts,
        availablePorts: widget.stationToEdit != null
            ? widget.stationToEdit!.availablePorts
            : totalPorts,
        pricePerUnit: double.parse(_priceController.text.trim()),
        rating: widget.stationToEdit?.rating ?? 4.5,
        createdAt: widget.stationToEdit?.createdAt,
        ownerId: user.uid,
      );

      if (widget.stationToEdit != null) {
        await _firestoreService.updateStation(station);
      } else {
        await _firestoreService.addStation(station);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.stationToEdit != null
                ? 'Station updated successfully!'
                : 'Station added successfully!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      if (widget.stationToEdit != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const StationListScreen(),
            transitionDuration: Duration.zero,
          ),
        );
        return;
      }

      _stationNameController.clear();
      _ownerNameController.clear();
      _addressController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _totalPortsController.clear();
      _priceController.clear();
      setState(() {
        _chargerType = 'Type2';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding station: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _stationNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _totalPortsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(
            activeRoute: widget.stationToEdit != null
                ? 'manage_stations'
                : 'add_station',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stationToEdit != null
                        ? 'Edit Station'
                        : 'Add New Station',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(32),
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
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ResponsiveFieldRow(
                                children: [
                                  _buildTextField(
                                    controller: _stationNameController,
                                    labelText: 'Station Name',
                                    icon: Icons.ev_station,
                                    validator: (value) =>
                                        value!.isEmpty ? 'Required' : null,
                                  ),
                                  _buildTextField(
                                    controller: _ownerNameController,
                                    labelText: 'Owner Name',
                                    icon: Icons.person,
                                    validator: (value) =>
                                        value!.isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _addressController,
                                labelText: 'Address',
                                icon: Icons.map,
                                validator: (value) =>
                                    value!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 24),
                              _ResponsiveFieldRow(
                                children: [
                                  _buildTextField(
                                    controller: _latitudeController,
                                    labelText: 'Latitude',
                                    icon: Icons.location_on,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final numValue = double.tryParse(value);
                                      if (numValue == null) {
                                        return 'Invalid number';
                                      }
                                      if (numValue < -90 || numValue > 90) {
                                        return 'Must be between -90 and 90';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    controller: _longitudeController,
                                    labelText: 'Longitude',
                                    icon: Icons.location_on,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final numValue = double.tryParse(value);
                                      if (numValue == null) {
                                        return 'Invalid number';
                                      }
                                      if (numValue < -180 || numValue > 180) {
                                        return 'Must be between -180 and 180';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              DropdownButtonFormField<String>(
                                initialValue: _chargerType,
                                dropdownColor: AppColors.surface,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Charger Type',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.electrical_services,
                                    color: AppColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                items: _chargerTypes.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _chargerType = value;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              _ResponsiveFieldRow(
                                children: [
                                  _buildTextField(
                                    controller: _totalPortsController,
                                    labelText: 'Total Charging Ports',
                                    icon: Icons.onetwothree,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final intValue = int.tryParse(value);
                                      if (intValue == null || intValue <= 0) {
                                        return 'Must be > 0';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    controller: _priceController,
                                    labelText: 'Price per kWh',
                                    icon: Icons.attach_money,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final numValue = double.tryParse(value);
                                      if (numValue == null || numValue < 0) {
                                        return 'Invalid price';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 48),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.background,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          widget.stationToEdit != null
                                              ? 'Save Changes'
                                              : 'Add Station',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.background,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

class _ResponsiveFieldRow extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFieldRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 24),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 24),
            ],
          ],
        );
      },
    );
  }
}
