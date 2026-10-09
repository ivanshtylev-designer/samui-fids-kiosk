import 'package:flutter/material.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';
import '../services/sound_service.dart';

class OperatorToolbar extends StatefulWidget {
  final QueueController controller;

  const OperatorToolbar({super.key, required this.controller});

  @override
  State<OperatorToolbar> createState() => _OperatorToolbarState();
}

class _OperatorToolbarState extends State<OperatorToolbar> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return Positioned(
        bottom: 24,
        right: 24,
        child: FloatingActionButton.extended(
          backgroundColor: AppTokens.borderSubtle,
          foregroundColor: AppTokens.textPrimary,
          elevation: 4,
          icon: const Icon(Icons.tune, size: 20),
          label: Text(
            'OPERATOR CONTROLS',
            style: AppTokens.plexSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = true;
            });
          },
        ),
      );
    }

    return Positioned(
      bottom: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTokens.borderSubtle, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.controller.systemState == SystemState.active 
                    ? AppTokens.signalSuccess 
                    : AppTokens.signalAction,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'KIOSK SIMULATOR',
              style: AppTokens.plexSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTokens.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 24),

            // Button 1: Call Next
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.signalAction,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.notifications_active, size: 18),
              label: Text(
                'CALL NEXT [SPACE]',
                style: AppTokens.plexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () => widget.controller.callNext(),
            ),
            const SizedBox(width: 12),

            // Button 2: Batch Ready
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.signalSuccess,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(
                'BATCH READY [B]',
                style: AppTokens.plexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () => widget.controller.addReadyBatch(),
            ),
            const SizedBox(width: 12),

            // Button 3: Toggle State
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.textPrimary,
                side: const BorderSide(color: AppTokens.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.power_settings_new, size: 18),
              label: Text(
                'STATE [T]',
                style: AppTokens.plexSans(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => widget.controller.toggleSystemState(),
            ),
            const SizedBox(width: 12),

            // Button 4: Clear Queue
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.textPrimary,
                side: const BorderSide(color: AppTokens.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(
                'CLEAR [C]',
                style: AppTokens.plexSans(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => widget.controller.clearQueue(),
            ),
            const SizedBox(width: 12),

            // Button 5: Reset
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTokens.textMuted,
                side: const BorderSide(color: AppTokens.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'RESET [R]',
                style: AppTokens.plexSans(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () => widget.controller.reset(),
            ),
            const SizedBox(width: 16),

            // Close button
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: AppTokens.textMuted),
              onPressed: () {
                setState(() {
                  _isExpanded = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

