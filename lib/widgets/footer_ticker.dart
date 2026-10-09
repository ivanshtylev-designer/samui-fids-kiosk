import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_tokens.dart';

class FooterTicker extends StatefulWidget {
  const FooterTicker({super.key});

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

  void _updateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('HH:mm').format(now);
    if (formatted != _currentTime) {
      if (mounted) {
        setState(() {
          _currentTime = formatted;
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
          // 1. Brand Block
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Samui Immigration',
                style: AppTokens.plexSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: AppTokens.textPrimary,
                  letterSpacing: 1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ตรวจคนเข้าเมืองสมุย',
                style: AppTokens.plexSansThai(
                  fontSize: 20,
                  color: AppTokens.textMuted,
                  height: 1.0,
                ),
              ),
            ],
          ),

          const Spacer(),

          // 2. Morning Intake
          RichText(
            text: TextSpan(
              style: AppTokens.plexSans(
                fontSize: 18,
                color: AppTokens.textMuted,
                letterSpacing: 1.0,
              ),
              children: [
                const TextSpan(text: 'MORNING INTAKE: '),
                TextSpan(
                  text: 'TICKETS ACCEPTED UNTIL 11:30',
                  style: AppTokens.plexSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 48),

          // 3. Afternoon Pickup
          RichText(
            text: TextSpan(
              style: AppTokens.plexSans(
                fontSize: 18,
                color: AppTokens.textMuted,
                letterSpacing: 1.0,
              ),
              children: [
                const TextSpan(text: 'AFTERNOON PICKUP: '),
                TextSpan(
                  text: '13:00 – 16:30',
                  style: AppTokens.plexSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 4. Live Clock
          Text(
            _currentTime.isEmpty ? '10:45' : _currentTime,
            style: AppTokens.plexSans(
              fontSize: 64,
              fontWeight: FontWeight.w500,
              color: AppTokens.textPrimary,
              letterSpacing: 2.0,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

