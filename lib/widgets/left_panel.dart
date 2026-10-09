import 'package:flutter/material.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';
import 'motion_primitives.dart';

class LeftPanel extends StatelessWidget {
  final List<CalledTicket> activeCalls;
  final List<NextTicket> nextBuffer;
  final OperationalPhase systemState;

  const LeftPanel({
    super.key,
    required this.activeCalls,
    required this.nextBuffer,
    required this.systemState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header (Call to Counter)
        _buildHeader(),
        const SizedBox(height: 32),

        // 2. Table Column Headers
        _buildTableHeaders(),
        const SizedBox(height: 16),

        // 3. Complete Phase Body with Unified Transition
        FidsPanelTransition(
          child: _buildPhaseBody(key: ValueKey(systemState)),
        ),
      ],
    );
  }

  Widget _buildPhaseBody({required Key key}) {
    if (systemState == OperationalPhase.booting) {
      return _buildBootingState(key: key);
    }
    if (systemState == OperationalPhase.afternoonPickup) {
      return _buildAfternoonPickupState(key: key);
    }
    if (systemState == OperationalPhase.lunchBreak) {
      return _buildLunchBreakState(key: key);
    }
    return _buildMorningIntakeState(key: key);
  }

  Widget _buildBootingState({required Key key}) {
    return Container(
      key: key,
      constraints: const BoxConstraints(minHeight: 220),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTokens.panelBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.borderSubtle),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BlinkingDot(color: AppTokens.signalAction, size: 14),
            const SizedBox(height: 16),
            Text(
              'INITIALIZING FIDS TERMINAL...',
              style: AppTokens.plexSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTokens.signalAction,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecting to PIBICS Immigration Database & QueQ Dispatch Engine',
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

  Widget _buildAfternoonPickupState({required Key key}) {
    return Container(
      key: key,
      constraints: const BoxConstraints(minHeight: 220),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTokens.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.signalInfo.withValues(alpha: 0.4)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: AppTokens.signalInfo, size: 36),
            const SizedBox(height: 10),
            Text(
              'MORNING INTAKE CLOSED',
              style: AppTokens.plexSans(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTokens.textPrimary,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ปิดรับบัตรคิวสำหรับยื่นเอกสารใหม่ช่วงเช้า',
              style: AppTokens.plexSansThai(
                fontSize: 16,
                color: AppTokens.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New 30-day visa extension submissions resume tomorrow at 08:30.\nPassport collections continue at Counter 4 on the right panel.',
              textAlign: TextAlign.center,
              style: AppTokens.plexSans(
                fontSize: 14,
                color: AppTokens.textMuted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLunchBreakState({required Key key}) {
    return Column(
      key: key,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTokens.signalWarning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTokens.signalWarning.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const BlinkingDot(color: AppTokens.signalWarning, size: 10),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LUNCH BREAK (12:00 – 13:00) • COUNTERS ON HOLD',
                      style: AppTokens.plexSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTokens.signalWarning,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'พักเที่ยง — เคาน์เตอร์เปิดให้บริการต่อเวลา 13:00 น.',
                      style: AppTokens.plexSansThai(
                        fontSize: 14,
                        color: AppTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...List.generate(activeCalls.length, (index) {
          final item = activeCalls[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: _ActiveCallRow(
              key: ValueKey('paused_${item.id}'),
              item: item,
              isPaused: true,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMorningIntakeState({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(activeCalls.length, (index) {
          final item = activeCalls[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: _ActiveCallRow(
              key: ValueKey(item.id),
              item: item,
              isPaused: false,
            ),
          );
        }),
        _buildSeparator(),
        _buildNextSectionContent(),
      ],
    );
  }

  Widget _buildNextSectionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Header
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT',
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
                  'คิวถัดไป',
                  style: AppTokens.plexSansThai(
                    fontSize: 14,
                    color: AppTokens.signalInfo,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Next Rows Stream (Staggered smooth transitions)
        Column(
          children: List.generate(QueueDomainConstants.maxNextBuffer, (index) {
            final next = index < nextBuffer.length ? nextBuffer[index] : null;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: AnimatedSwitcher(
                duration: AppTokens.durationNormal,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.35),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: next == null
                    ? const SizedBox(key: ValueKey('empty_slot'), height: 42)
                    : Row(
                        key: ValueKey(next.ticket),
                        children: [
                          // Ticket Number
                          Expanded(
                            child: Text(
                              next.ticket,
                              style: AppTokens.plexSans(
                                fontSize: 38,
                                fontWeight: FontWeight.w500,
                                color: AppTokens.textMuted,
                                letterSpacing: 2.0,
                                height: 1.1,
                              ),
                            ),
                          ),

                          // Service Label
                          Expanded(
                            child: Text(
                              next.service,
                              style: AppTokens.plexSans(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: AppTokens.textMuted,
                                height: 1.1,
                              ),
                            ),
                          ),

                          // Desk hint indicator
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTokens.cardBackground.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTokens.borderSubtle),
                                ),
                                child: Text(
                                  'DESK ${next.deskHint}',
                                  style: AppTokens.plexSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTokens.textDim,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Call to Counter',
          style: AppTokens.plexSans(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppTokens.signalAction,
            letterSpacing: 2.0,
            height: 1.0,
            glow: true,
            glowColor: AppTokens.signalAction,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'เรียกคิวเข้ารับบริการ',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVICE',
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
                'ประเภทบริการ',
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
    if (systemState != OperationalPhase.morningIntake) {
      return const SizedBox.shrink();
    }
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
}

class _ActiveCallRow extends StatelessWidget {
  final CalledTicket item;
  final bool isPaused;

  const _ActiveCallRow({
    super.key,
    required this.item,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = item.isEmpty;
    final Color textColor = item.isHighlight
        ? Colors.white
        : (isEmpty || isPaused ? AppTokens.textMuted : AppTokens.signalAction);

    final Color serviceColor = item.isHighlight
        ? Colors.white
        : (isEmpty || isPaused ? AppTokens.textDim : AppTokens.textPrimary);

    return PulsingGlowCard(
      isHighlight: item.isHighlight && !isPaused,
      glowColor: AppTokens.signalAction,
      backgroundColor: isEmpty ? Colors.transparent : AppTokens.panelBackground.withValues(alpha: 0.5),
      borderColor: isEmpty ? AppTokens.borderSubtle.withValues(alpha: 0.3) : AppTokens.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ticket Number with Digit Transition
          Expanded(
            child: AnimatedDigitText(
              text: item.ticket,
              style: AppTokens.plexSans(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 2.0,
                height: 1.1,
                glow: item.isHighlight && !isPaused,
                glowColor: AppTokens.signalAction,
              ),
            ),
          ),

          // Service Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.service,
                  style: AppTokens.plexSans(
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    color: serviceColor,
                    height: 1.1,
                  ),
                ),
                if (isPaused)
                  Text(
                    'ON HOLD • พักให้บริการชั่วคราว',
                    style: AppTokens.plexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.signalWarning,
                      letterSpacing: 1.0,
                    ),
                  ),
              ],
            ),
          ),

          // Desk Counter Number
          Expanded(
            child: AnimatedDigitText(
              text: item.desk,
              textAlign: TextAlign.right,
              style: AppTokens.plexSans(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 1.0,
                glow: item.isHighlight && !isPaused,
                glowColor: AppTokens.signalAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
