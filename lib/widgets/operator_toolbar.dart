import 'package:flutter/material.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';
import 'motion_primitives.dart';

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
      return _buildCollapsedTrigger();
    }

    return _buildExpandedPanel();
  }

  Widget _buildCollapsedTrigger() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton.extended(
        backgroundColor: AppTokens.cardBackground,
        foregroundColor: AppTokens.textPrimary,
        elevation: 6,
        icon: const Icon(Icons.tune, size: 20),
        label: Text(
          'SIMULATOR CONTROLS',
          style: AppTokens.plexSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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

  Widget _buildExpandedPanel() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTokens.borderSubtle, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Pill with Active Phase Label
            _buildStatusHeader(),
            const SizedBox(width: 16),

            // Call Next (Counter 1 / General)
            _buildActionButton(
              label: 'CALL NEXT [SPACE]',
              icon: Icons.notifications_active,
              color: AppTokens.signalAction,
              textColor: Colors.black,
              onPressed: () => widget.controller.callNext(),
            ),
            const SizedBox(width: 8),

            // Desk 1 Specific Call
            _buildSmallDeskButton(
              label: 'C1',
              tooltip: 'Call to Counter 1 (Tourist Ext)',
              onPressed: () => widget.controller.callNext(targetDesk: 1),
            ),
            const SizedBox(width: 4),

            // Desk 2 Specific Call
            _buildSmallDeskButton(
              label: 'C2',
              tooltip: 'Call to Counter 2 (Re-entry)',
              onPressed: () => widget.controller.callNext(targetDesk: 2),
            ),
            const SizedBox(width: 4),

            // Desk 3 Specific Call
            _buildSmallDeskButton(
              label: 'C3',
              tooltip: 'Call to Counter 3 (Long-term)',
              onPressed: () => widget.controller.callNext(targetDesk: 3),
            ),
            const SizedBox(width: 12),

            // Batch Ready (Counter 4)
            _buildActionButton(
              label: 'BATCH READY [B]',
              icon: Icons.done_all,
              color: AppTokens.signalSuccess,
              textColor: Colors.black,
              onPressed: () => widget.controller.addReadyBatch(),
            ),
            const SizedBox(width: 10),

            // Auto-Demo Toggle Button
            _buildAutoDemoButton(),
            const SizedBox(width: 10),

            // Phase Cycle Button
            _buildOutlineButton(
              label: 'PHASE [T]',
              icon: Icons.access_time,
              onPressed: () => widget.controller.cyclePhase(),
            ),
            const SizedBox(width: 8),

            // Clear Queue Button
            _buildOutlineButton(
              label: 'CLEAR [C]',
              icon: Icons.clear_all,
              onPressed: () => widget.controller.clearQueue(),
            ),
            const SizedBox(width: 8),

            // Reset Button
            _buildOutlineButton(
              label: 'RESET [R]',
              icon: Icons.refresh,
              color: AppTokens.textMuted,
              onPressed: () => widget.controller.reset(),
            ),
            const SizedBox(width: 12),

            // Collapse Button
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppTokens.textMuted),
              tooltip: 'Minimize Toolbar',
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

  Widget _buildStatusHeader() {
    final Color statusColor;
    final String phaseName;

    switch (widget.controller.phase) {
      case OperationalPhase.booting:
        statusColor = AppTokens.signalAction;
        phaseName = 'BOOTING';
        break;
      case OperationalPhase.morningIntake:
        statusColor = AppTokens.signalSuccess;
        phaseName = 'MORNING INTAKE';
        break;
      case OperationalPhase.lunchBreak:
        statusColor = AppTokens.signalWarning;
        phaseName = 'LUNCH BREAK';
        break;
      case OperationalPhase.afternoonPickup:
        statusColor = AppTokens.signalInfo;
        phaseName = 'AFTERNOON PICKUP';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlinkingDot(color: statusColor, size: 8),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'KIOSK SIMULATOR',
              style: AppTokens.plexSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTokens.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              phaseName,
              style: AppTokens.plexSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: AppTokens.plexSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildSmallDeskButton({
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.signalAction,
          side: const BorderSide(color: AppTokens.borderSubtle),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTokens.plexSans(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTokens.signalAction,
          ),
        ),
      ),
    );
  }

  Widget _buildAutoDemoButton() {
    final bool isDemo = widget.controller.isAutoDemo;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: isDemo ? AppTokens.signalInfo.withValues(alpha: 0.2) : Colors.transparent,
        foregroundColor: isDemo ? AppTokens.signalInfo : AppTokens.textPrimary,
        side: BorderSide(color: isDemo ? AppTokens.signalInfo : AppTokens.borderSubtle),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(
        isDemo ? Icons.pause_circle_outline : Icons.play_circle_outline,
        size: 16,
        color: isDemo ? AppTokens.signalInfo : AppTokens.textMuted,
      ),
      label: Text(
        isDemo ? 'DEMO ON [A]' : 'AUTO DEMO [A]',
        style: AppTokens.plexSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDemo ? AppTokens.signalInfo : AppTokens.textPrimary,
        ),
      ),
      onPressed: () => widget.controller.toggleAutoDemo(),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    Color color = AppTokens.textPrimary,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: const BorderSide(color: AppTokens.borderSubtle),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 15, color: color),
      label: Text(
        label,
        style: AppTokens.plexSans(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
      onPressed: onPressed,
    );
  }
}
