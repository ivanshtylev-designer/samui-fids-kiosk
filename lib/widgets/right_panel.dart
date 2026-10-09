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
        constraints: const BoxConstraints(minHeight: 220),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppTokens.panelBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
        ),
      );
    }

    final bool isAfternoonRush = systemState == OperationalPhase.afternoonPickup;

    return Column(
      key: key,
      children: [
        if (isAfternoonRush)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTokens.signalSuccess.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const BlinkingDot(color: AppTokens.signalSuccess, size: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AFTERNOON PICK-UP IN PROGRESS • BATCHES READY AT COUNTER 4',
                    style: AppTokens.plexSans(
                      fontSize: 14,
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
            padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                  ? const SizedBox(key: ValueKey('empty_batch'), height: 56)
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
          'PASSPORT PICK-UP',
          style: AppTokens.plexSans(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppTokens.signalSuccess,
            letterSpacing: 2.0,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'รับหนังสือเดินทาง',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRACK QUEUE ON YOUR PHONE',
            style: AppTokens.plexSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTokens.signalInfo,
              letterSpacing: 2.0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ติดตามสถานะคิวผ่านมือถือ',
            style: AppTokens.plexSansThai(
              fontSize: 14,
              color: AppTokens.signalInfo,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: QrImageView(
              data: 'https://queq.me/samui-immigration',
              version: QrVersions.auto,
              size: 184.0,
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
          Text(
            item.desk,
            textAlign: TextAlign.right,
            style: AppTokens.plexSans(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.0,
              glow: item.isHighlight,
              glowColor: AppTokens.signalSuccess,
            ),
          ),
        ],
      ),
    );
  }
}
