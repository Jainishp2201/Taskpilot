import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToastUtils {
  static void showCustomToast(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 110,
        left: 28,
        right: 28,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 28 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D201A),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.20),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                            spreadRadius: -6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isError
                                  ? const Color(0xFFD4524A).withOpacity(0.22)
                                  : const Color(0xFF5B9E7A).withOpacity(0.22),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isError ? Icons.close_rounded : Icons.check_rounded,
                              color: isError ? const Color(0xFFD4524A) : const Color(0xFF5B9E7A),
                              size: 13,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              message,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.92),
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
