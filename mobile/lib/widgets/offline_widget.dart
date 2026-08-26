import 'package:flutter/material.dart';

class OfflineWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? errorMessage;

  const OfflineWidget({
    super.key,
    required onRetry,
    this.errorMessage,
  }) : onRetry = onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBF7),
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Connection Icon Card
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE7E5E4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFF78716C),
                size: 36,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Connection Lost',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1917),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              errorMessage ??
                  'Unable to connect to KitchenOS server. Please check your internet or local network connection.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF78716C),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Retry Button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFFF5F5F4)),
              label: const Text(
                'Retry Connection',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5F5F4),
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF292524),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
