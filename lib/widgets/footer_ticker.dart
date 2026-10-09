import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';
import 'motion_primitives.dart';

class FooterTicker extends StatefulWidget {
  final OperationalPhase phase;

  const FooterTicker({
    super.key,
    this.phase = OperationalPhase.morningIntake,
  });

  @override
  State<FooterTicker> createState() => _FooterTickerState();
}

class _FooterTickerState extends State<FooterTicker> {
  late Timer _clockTimer;
  String _currentTime = '';
  String _currentSeconds = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final secStr = DateFormat('ss').format(now);
    if (timeStr != _currentTime || secStr != _currentSeconds) {
      if (mounted) {
        setState(() {
          _currentTime = timeStr;
          _currentSeconds = secStr;
        });
      }
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTokens.borderSubtle,
            width: 2.0,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Brand Block (Left)
          Flexible(
            flex: 4,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Samui Immigration',
                        style: AppTokens.plexSans(
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.textPrimary,
                          letterSpacing: 1.0,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ตรวจคนเข้าเมืองสมุย • Mae Nam Soi 1',
                        style: AppTokens.plexSansThai(
                          fontSize: 18,
                          color: AppTokens.textMuted,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Live Gateway Telemetry Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTokens.cardBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTokens.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BlinkingDot(color: AppTokens.signalSuccess, size: 7),
                        const SizedBox(width: 8),
                        Text(
                          'PIBICS • QUEQ SYNC',
                          style: AppTokens.plexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 32),

          // 2. Schedule Notices (Center, Fitted to never overflow)
          Expanded(
            flex: 6,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScheduleBadge(
                    title: 'MORNING INTAKE',
                    detail: 'TICKETS UNTIL 11:30',
                    isActive: widget.phase == OperationalPhase.morningIntake,
                    activeColor: AppTokens.signalAction,
                  ),
                  const SizedBox(width: 28),
                  _buildScheduleBadge(
                    title: 'LUNCH BREAK',
                    detail: '12:00 – 13:00',
                    isActive: widget.phase == OperationalPhase.lunchBreak,
                    activeColor: AppTokens.signalWarning,
                  ),
                  const SizedBox(width: 28),
                  _buildScheduleBadge(
                    title: 'AFTERNOON PICKUP',
                    detail: '13:00 – 16:30',
                    isActive: widget.phase == OperationalPhase.afternoonPickup,
                    activeColor: AppTokens.signalSuccess,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 32),

          // 3. Live Tabular Clock (Right, isolated in RepaintBoundary)
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: RepaintBoundary(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentTime.isEmpty ? '10:45' : _currentTime,
                      style: AppTokens.plexSans(
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.textPrimary,
                        letterSpacing: 2.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentSeconds.isEmpty ? '00' : _currentSeconds,
                      style: AppTokens.plexSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppTokens.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleBadge({
    required String title,
    required String detail,
    required bool isActive,
    required Color activeColor,
  }) {
    return AnimatedContainer(
      duration: AppTokens.durationNormal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.12)
            : AppTokens.cardBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? activeColor : AppTokens.borderSubtle,
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            BlinkingDot(color: activeColor, size: 6),
            const SizedBox(width: 8),
          ],
          RichText(
            text: TextSpan(
              style: AppTokens.plexSans(
                fontSize: 15,
                color: isActive ? activeColor : AppTokens.textMuted,
                letterSpacing: 0.8,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                TextSpan(
                  text: detail,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppTokens.textPrimary : AppTokens.textMuted,
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
