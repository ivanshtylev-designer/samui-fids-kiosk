import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';

class RightPanel extends StatelessWidget {
  final List<ReadyBatch> readyBatches;
  final SystemState systemState;

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

        // 2. Table Header
        _buildTableHeaders(),
        const SizedBox(height: 16),

        // 3. Ready Batch Rows
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _buildReadyBatchesContent(key: ValueKey(systemState)),
        ),

        // 4. Separator
        _buildSeparator(),

        // 5. Track Queue via QR Block
        _buildQrSection(),
      ],
    );
  }

  Widget _buildReadyBatchesContent({required Key key}) {
    if (systemState == SystemState.booting || systemState == SystemState.intakeClosed) {
      return Container(
        key: key,
        height: 240,
      ); // Blank space for empty states
    }

    return Column(
      key: key,
      children: List.generate(3, (index) {
        final item = index < readyBatches.length ? readyBatches[index] : null;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, -0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: item == null 
              ? const SizedBox(key: ValueKey('empty'), height: 74)
              : _ReadyBatchRow(key: ValueKey(item.displayRange), item: item),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passport Pick-up',
          style: AppTokens.plexSans(
            fontSize: 32,
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
        // Ticket
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TICKET',
                style: AppTokens.plexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textMuted,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
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

        // Desk
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DESK',
                style: AppTokens.plexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textMuted,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
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
      duration: const Duration(milliseconds: 600),
      opacity: systemState == SystemState.booting ? 0.0 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track queue on your phone',
                style: AppTokens.plexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.signalInfo,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ติดตามสถานะคิวผ่านมือถือ',
                style: AppTokens.plexSansThai(
                  fontSize: 14,
                  color: AppTokens.signalInfo,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Code Box (256x256)
          Container(
            width: 256,
            height: 256,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.textPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: QrImageView(
              data: 'https://queq.me/samui-immigration',
              version: QrVersions.auto,
              size: 232.0,
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

  const _ReadyBatchRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = item.isHighlight ? AppTokens.signalSuccess : Colors.transparent;
    final Color textColor = item.isHighlight ? Colors.white : AppTokens.signalSuccess;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: highlightColor.withValues(alpha: item.isHighlight ? 0.15 : 0.0),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: highlightColor.withValues(alpha: item.isHighlight ? 0.3 : 0.0),
          width: 1,
        ),
        boxShadow: item.isHighlight
            ? [
                BoxShadow(
                  color: AppTokens.signalSuccess.withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display range or single ticket
          Expanded(
            child: Text(
              item.displayRange,
              style: AppTokens.plexSans(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 2.0,
                height: 1.1,
                glow: item.isHighlight,
              ),
            ),
          ),

          // Desk
          Expanded(
            child: Text(
              item.desk,
              textAlign: TextAlign.right,
              style: AppTokens.plexSans(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.0,
                glow: item.isHighlight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

