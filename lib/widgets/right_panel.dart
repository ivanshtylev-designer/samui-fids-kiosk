import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';
import 'motion_primitives.dart';

class RightPanel extends StatelessWidget {
  final List<ReadyBatch> readyBatches;
  final OperationalPhase systemState;

  const RightPanel({
    super.key,
    required this.readyBatches,
    required this.systemState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header (Passport Pick-up)
        _buildHeader(),
        const SizedBox(height: 32),

        // 2. Table Column Headers
        _buildTableHeaders(),
        const SizedBox(height: 16),

        // 3. Ready Batch Rows (Desk 4 - Passport Delivery)
        FidsPanelTransition(
          child: _buildReadyBatchesContent(key: ValueKey(systemState)),
        ),

        // 4. Subtle Hairline Separator
        _buildSeparator(),

        // 5. Mobile Queue Tracking via QR Code
        _buildQrSection(),
      ],
    );
  }

  Widget _buildReadyBatchesContent({required Key key}) {
    if (systemState == OperationalPhase.booting) {
      return Container(
        key: key,
        height: 240,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTokens.panelBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTokens.borderSubtle),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BlinkingDot(color: AppTokens.signalSuccess, size: 14),
            const SizedBox(height: 16),
            Text(
              'SYNCING DOCUMENT BATCH STATUS...',
              style: AppTokens.plexSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTokens.signalSuccess,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Standby for Counter 4 passport batch numbers',
              style: AppTokens.plexSans(
                fontSize: 14,
                color: AppTokens.textMuted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    final bool isAfternoonRush = systemState == OperationalPhase.afternoonPickup;

    return Column(
      key: key,
      children: [
        if (isAfternoonRush)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTokens.signalSuccess.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.signalSuccess.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const BlinkingDot(color: AppTokens.signalSuccess, size: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AFTERNOON PICK-UP IN PROGRESS • BATCHES READY AT COUNTER 4',
                    style: AppTokens.plexSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.signalSuccess,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ...List.generate(QueueDomainConstants.maxReadyBatches, (index) {
          final item = index < readyBatches.length ? readyBatches[index] : null;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: AnimatedSwitcher(
              duration: AppTokens.durationNormal,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, -0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: item == null
                  ? const SizedBox(key: ValueKey('empty_batch'), height: 72)
                  : _ReadyBatchRow(
                      key: ValueKey(item.id),
                      item: item,
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passport Pick-up',
          style: AppTokens.plexSans(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppTokens.signalSuccess,
            letterSpacing: 2.0,
            height: 1.0,
            glow: true,
            glowColor: AppTokens.signalSuccess,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'รับหนังสือเดินทาง • Counter 4',
          style: AppTokens.plexSansThai(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: AppTokens.textMuted,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaders() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TICKET',
                style: AppTokens.plexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.textMuted,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'หมายเลขคิว',
                style: AppTokens.plexSansThai(
                  fontSize: 14,
                  color: AppTokens.textMuted,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DESK',
                style: AppTokens.plexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.textMuted,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ช่อง',
                style: AppTokens.plexSansThai(
                  fontSize: 14,
                  color: AppTokens.textMuted,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: const Divider(
        height: 1,
        thickness: 1,
        color: AppTokens.borderSubtle,
      ),
    );
  }

  Widget _buildQrSection() {
    return AnimatedOpacity(
      duration: AppTokens.durationNormal,
      opacity: systemState == OperationalPhase.booting ? 0.0 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QR Code Card (240x240)
          Container(
            width: 240,
            height: 240,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.textPrimary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: QrImageView(
              data: 'https://queq.me/samui-immigration',
              version: QrVersions.auto,
              size: 216.0,
              backgroundColor: Colors.transparent,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 28),

          // Instructions & Context
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track Queue on Phone',
                  style: AppTokens.plexSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.signalInfo,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ติดตามสถานะคิวผ่านมือถือใน QueQ',
                  style: AppTokens.plexSansThai(
                    fontSize: 16,
                    color: AppTokens.signalInfo,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan the QR code to track your ticket live on your smartphone.\n'
                  'You may wait outside under the shaded terrace or in Mae Nam cafes. '
                  'The app alerts you when 3 tickets remain before your turn.',
                  style: AppTokens.plexSans(
                    fontSize: 15,
                    color: AppTokens.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTokens.cardBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTokens.borderSubtle),
                  ),
                  child: Text(
                    'OFFICIAL APP: QueQ (iOS / Android)',
                    style: AppTokens.plexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyBatchRow extends StatelessWidget {
  final ReadyBatch item;

  const _ReadyBatchRow({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = item.isHighlight ? Colors.white : AppTokens.signalSuccess;

    return PulsingGlowCard(
      isHighlight: item.isHighlight,
      glowColor: AppTokens.signalSuccess,
      backgroundColor: AppTokens.panelBackground.withValues(alpha: 0.5),
      borderColor: AppTokens.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Batch Range Display
          Expanded(
            child: AnimatedDigitText(
              text: item.displayRange,
              style: AppTokens.plexSans(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 2.0,
                height: 1.1,
                glow: item.isHighlight,
                glowColor: AppTokens.signalSuccess,
              ),
            ),
          ),

          // Desk 4 Counter
          Expanded(
            child: AnimatedDigitText(
              text: item.desk,
              textAlign: TextAlign.right,
              style: AppTokens.plexSans(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.0,
                glow: item.isHighlight,
                glowColor: AppTokens.signalSuccess,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
