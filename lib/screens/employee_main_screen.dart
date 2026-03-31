import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'employee_home_screen.dart';
import 'bill_list_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../widgets/clay_container.dart';

class EmployeeMainScreen extends StatefulWidget {
  const EmployeeMainScreen({super.key});

  @override
  State<EmployeeMainScreen> createState() => _EmployeeMainScreenState();
}

class _EmployeeMainScreenState extends State<EmployeeMainScreen> {
  int _currentIndex = 0;

  // IndexedStack keeps all screens alive — no rebuild on tab switch
  final List<Widget> _screens = [
    const EmployeeHomeScreen(),
    const BillListScreen(),
    const _ProfilePlaceholder(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, "Tasks"),
    _NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, "Bills"),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? "Dashboard"
              : _currentIndex == 1
                  ? "Payments"
                  : "Profile",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF2D201A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                auth.logout();
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final tween = Tween(begin: 0.0, end: 1.0)
                          .chain(CurveTween(curve: Curves.easeOutExpo));
                      return FadeTransition(
                        opacity: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE8E4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC3B5AC).withOpacity(0.7),
                      blurRadius: 8,
                      offset: const Offset(3, 3),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      blurRadius: 8,
                      offset: Offset(-3, -3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF5C4A40),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),

      // ── IndexedStack: instant switching, all screens stay alive ──────────
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand, // tight constraints → Column's Expanded works
        children: _screens,
      ),

      // ── Custom Floating Nav Dock ─────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8E4),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC3B5AC).withOpacity(0.85),
                blurRadius: 20,
                offset: const Offset(8, 8),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 20,
                offset: Offset(-8, -8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE8734A), Color(0xFFC9526A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE8734A).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 20,
              color: isSelected ? Colors.white : const Color(0xFF8B7468),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Placeholder ──────────────────────────────────────────────────────
class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ClayContainer(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8734A).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 40,
                  color: Color(0xFFE8734A),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Profile",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF2D201A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Coming Soon",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF8B7468),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
