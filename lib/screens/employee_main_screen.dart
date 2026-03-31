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
  
  final List<Widget> _screens = [
    EmployeeHomeScreen(),
    BillListScreen(),
    Center(
      child: ClayContainer(
        padding: const EdgeInsets.all(32),
        child: Text("Profile Settings \n(Coming Soon)", 
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF6B7280), fontWeight: FontWeight.w300),
        )
      )
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? "Dashboard" : _currentIndex == 1 ? "Payments" : "Profile", 
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937))
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: const Color(0xFF4B5563)),
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var curve = Curves.easeOutCirc;
                    var tween = Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: curve));
                    var fadeTween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
                    return Opacity(
                      opacity: animation.drive(fadeTween).value,
                      child: Transform.scale(
                        scale: animation.drive(tween).value,
                        child: child,
                      ),
                    );
                  },
                )
              );
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final key = child.key as ValueKey<int>?;
            final index = key?.value ?? 0;
            
            Alignment alignment = Alignment.bottomCenter;
            if (index == 0) alignment = const Alignment(-0.6, 1.0);
            if (index == 2) alignment = const Alignment(0.6, 1.0);
            
            return ScaleTransition(
              scale: animation,
              alignment: alignment,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF2), // Matches scaffold background
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC4D1DF).withOpacity(0.8),
                blurRadius: 20,
                offset: const Offset(10, 10),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 20,
                offset: Offset(-10, -10),
              ),
            ]
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: const Color(0xFFE8EEF2),
              elevation: 0,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: const Color(0xFF9CA3AF),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 13),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: "Tasks"),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet_rounded), label: "Bills"),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
