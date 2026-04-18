import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme_constants.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_station_screen.dart';
import '../screens/station_list_screen.dart';
import '../screens/history_screen.dart';

class Sidebar extends StatelessWidget {
  final String activeRoute;

  Sidebar({super.key, required this.activeRoute});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: AppColors.background,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AmpTrail\nAdmin',
                  style: GoogleFonts.outfit(
                    color: AppColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  isActive: activeRoute == 'dashboard',
                  onTap: () {
                    if (activeRoute != 'dashboard') {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const DashboardScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  title: 'Add Station',
                  icon: Icons.add_location_alt_rounded,
                  isActive: activeRoute == 'add_station',
                  onTap: () {
                    if (activeRoute != 'add_station') {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const AddStationScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  title: 'Manage Stations',
                  icon: Icons.format_list_bulleted_rounded,
                  isActive: activeRoute == 'manage_stations',
                  onTap: () {
                    if (activeRoute != 'manage_stations') {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const StationListScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                _SidebarItem(
                  title: 'History',
                  icon: Icons.assignment_rounded,
                  isActive: activeRoute == 'history',
                  onTap: () {
                    if (activeRoute != 'history') {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HistoryScreen(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _SidebarItem(
              title: 'Logout',
              icon: Icons.logout_rounded,
              isActive: false,
              isLogout: true,
              onTap: () async {
                await _authService.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isLogout
        ? AppColors.danger
        : (widget.isActive ? AppColors.primary : AppColors.textSecondary);
        
    final bgColor = widget.isActive
        ? AppColors.primary.withValues(alpha: 0.1)
        : (_isHovering 
            ? (widget.isLogout ? AppColors.danger.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05))
            : Colors.transparent);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  color: widget.isActive ? AppColors.textMain : color,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (widget.isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
