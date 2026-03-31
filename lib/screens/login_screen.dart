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
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeOutCirc;
            var curveTween = CurveTween(curve: curve);
            var scaleTween = Tween(begin: 0.9, end: 1.0).chain(curveTween);
            var fadeTween = Tween(begin: 0.0, end: 1.0).chain(curveTween);

            return Opacity(
              opacity: animation.drive(fadeTween).value,
              child: Transform.scale(
                scale: animation.drive(scaleTween).value,
                child: child,
              ),
            );
          },
        )
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Taskpilot.", 
                             style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w300, color: const Color(0xFF1F2937), letterSpacing: -1.5)),
                        const SizedBox(height: 12),
                        Text("Sign in to continue to your dashboard",
                            style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF6B7280), fontWeight: FontWeight.w300)),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRoleToggle(),
                        const SizedBox(height: 40),
                        _buildTextField(_usernameController, "Username", Icons.person_outline_rounded),
                        const SizedBox(height: 24),
                        _buildTextField(_passwordController, "Password", Icons.lock_outline_rounded, obscure: true),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return GestureDetector(
                          onTap: auth.isLoading ? null : _handleLogin,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  offset: const Offset(0, 12),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 24, width: 24, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("LOGIN",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 2.0,
                                    )),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF2),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: const Color(0xFFC4D1DF).withOpacity(0.7), blurRadius: 10, offset: const Offset(4, 4)),
          const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-4, -4)),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCirc,
            alignment: _selectedRole == UserRole.employee ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFD1D9E6).withOpacity(0.6), blurRadius: 10, offset: const Offset(0, 4)),
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
                      duration: const Duration(milliseconds: 300),
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedRole == UserRole.employee ? FontWeight.w500 : FontWeight.w300, 
                        fontSize: 15, 
                        letterSpacing: 1.5, 
                        color: _selectedRole == UserRole.employee ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF)
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
                      duration: const Duration(milliseconds: 300),
                      style: GoogleFonts.poppins(
                        fontWeight: _selectedRole == UserRole.party ? FontWeight.w500 : FontWeight.w300, 
                        fontSize: 15, 
                        letterSpacing: 1.5, 
                        color: _selectedRole == UserRole.party ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF)
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD1D9E6).withOpacity(0.6),
            offset: const Offset(0, 8),
            blurRadius: 16,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: const Color(0xFF374151), fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w300),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 24, right: 16),
            child: Icon(icon, color: const Color(0xFF9CA3AF), size: 24),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        ),
      ),
    );
  }
}
