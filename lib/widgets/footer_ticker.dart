import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';

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

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTokens.borderSubtle,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 28.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Brand Block (Left)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAMUI IMMIGRATION',
                style: AppTokens.plexSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                  letterSpacing: 2.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ตรวจคนเข้าเมืองสมุย',
                style: AppTokens.plexSansThai(
                  fontSize: 16,
                  color: AppTokens.textMuted,
                  height: 1.0,
                ),
              ),
            ],
          ),

          // 2. Schedule Notices (Center, Pure Typographic Alignment, Bounded)
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTokens.plexSans(
                          fontSize: 16,
                          color: AppTokens.textMuted,
                          letterSpacing: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'MORNING INTAKE: '),
                          TextSpan(
                            text: 'TICKETS ACCEPTED UNTIL 11:30',
                            style: AppTokens.plexSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                    RichText(
                      text: TextSpan(
                        style: AppTokens.plexSans(
                          fontSize: 16,
                          color: AppTokens.textMuted,
                          letterSpacing: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'AFTERNOON PICKUP: '),
                          TextSpan(
                            text: '13:00 – 16:30',
                            style: AppTokens.plexSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.textPrimary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Live Tabular Clock (Right, isolated in RepaintBoundary)
          RepaintBoundary(
            child: Text(
              _currentTime.isEmpty ? '10:45' : _currentTime,
              style: AppTokens.plexSans(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: AppTokens.textPrimary,
                letterSpacing: 2.0,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
