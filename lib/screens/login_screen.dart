import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_utils.dart';
import 'party_home_screen.dart';
import 'employee_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.employee;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ToastUtils.showCustomToast(context, "Username and password are required", isError: true);
      return;
    }

    final success = await context.read<AuthProvider>().login(username, password, _selectedRole);

    if (success) {
      if (!mounted) return;
      ToastUtils.showCustomToast(context, "Welcome back, $username!");
      Widget nextScreen = _selectedRole == UserRole.employee
          ? const EmployeeMainScreen()
          : const PartyHomeScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeOutExpo;
            var curveTween = CurveTween(curve: curve);
            var scaleTween = Tween(begin: 0.92, end: 1.0).chain(curveTween);
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(curveTween);
            return Opacity(
              opacity: animation.drive(fadeTween).value,
              child: Transform.scale(
                scale: animation.drive(scaleTween).value,
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      if (!mounted) return;
      ToastUtils.showCustomToast(context, "Invalid credentials or wrong role selected.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 96),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Task",
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w200,
                                  color: const Color(0xFF2D201A),
                                  letterSpacing: -2.0,
                                ),
                              ),
                              TextSpan(
                                text: "pilot",
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE8734A),
                                  letterSpacing: -2.0,
                                ),
                              ),
                              TextSpan(
                                text: ".",
                                style: GoogleFonts.poppins(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w200,
                                  color: const Color(0xFFE8734A),
                                  letterSpacing: -2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Sign in to continue to your dashboard",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF8B7468),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 56),

                    // Form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRoleToggle(),
                        const SizedBox(height: 40),
                        _buildTextField(_usernameController, "Username", Icons.person_outline_rounded),
                        const SizedBox(height: 20),
                        _buildTextField(_passwordController, "Password", Icons.lock_outline_rounded, obscure: true),
                      ],
                    ),
                    const SizedBox(height: 52),

                    // Login Button — gradient with arrow
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return GestureDetector(
                          onTap: auth.isLoading ? null : _handleLogin,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: auth.isLoading
                                    ? [const Color(0xFFCFB5A8), const Color(0xFFCFB5A8)]
                                    : [const Color(0xFFE8734A), const Color(0xFFC9526A)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: auth.isLoading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(0xFFE8734A).withOpacity(0.45),
                                        offset: const Offset(0, 16),
                                        blurRadius: 36,
                                        spreadRadius: -6,
                                      ),
                                    ],
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "SIGN IN",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 4.0,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.22),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8E4),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC3B5AC).withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: Offset(-4, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCirc,
            alignment: _selectedRole == UserRole.employee
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8734A), Color(0xFFC9526A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8734A).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = UserRole.employee),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 320),
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedRole == UserRole.employee
                            ? FontWeight.w600
                            : FontWeight.w300,
                        fontSize: 13,
                        letterSpacing: 1.8,
                        color: _selectedRole == UserRole.employee
                            ? Colors.white
                            : const Color(0xFF8B7468),
                      ),
                      child: const Text("EMPLOYEE"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = UserRole.party),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 320),
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedRole == UserRole.party
                            ? FontWeight.w600
                            : FontWeight.w300,
                        fontSize: 13,
                        letterSpacing: 1.8,
                        color: _selectedRole == UserRole.party
                            ? Colors.white
                            : const Color(0xFF8B7468),
                      ),
                      child: const Text("PARTY"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCEBFB8).withOpacity(0.55),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2D201A),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFFB0A09A),
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 22, right: 14),
            child: Icon(icon, color: const Color(0xFFB0A09A), size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}
