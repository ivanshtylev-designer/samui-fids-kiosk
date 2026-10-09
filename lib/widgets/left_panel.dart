import 'package:flutter/material.dart';
import '../constants/app_tokens.dart';
import '../models/queue_state.dart';

class LeftPanel extends StatelessWidget {
  final List<CalledTicket> activeCalls;
  final List<NextTicket> nextBuffer;
  final SystemState systemState;

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

        // 2. Table Header
        _buildTableHeaders(),
        const SizedBox(height: 16),

        // 3. Active Called Rows
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
          child: _buildActiveCallsContent(key: ValueKey(systemState)),
        ),

        // 4. Hairline Separator
        _buildSeparator(),

        // 5. Next Queue Section
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
          child: _buildNextSectionContent(key: ValueKey(systemState)),
        ),
      ],
    );
  }

  Widget _buildActiveCallsContent({required Key key}) {
    if (systemState == SystemState.booting) {
      return Container(
        key: key,
        height: 240,
        alignment: Alignment.center,
        child: Text(
          'INITIALIZING SYSTEM...',
          style: AppTokens.plexSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTokens.textMuted,
            letterSpacing: 4.0,
          ),
        ),
      );
    }

    if (systemState == SystemState.intakeClosed) {
      return Container(
        key: key,
        height: 240,
        alignment: Alignment.center,
        child: Text(
          'INTAKE CLOSED',
          style: AppTokens.plexSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTokens.borderSubtle,
            letterSpacing: 4.0,
          ),
        ),
      );
    }

    return Column(
      key: key,
      children: List.generate(activeCalls.length, (index) {
        final item = activeCalls[index];
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
            child: _ActiveCallRow(key: ValueKey(item.id), item: item),
          ),
        );
      }),
    );
  }

  Widget _buildNextSectionContent({required Key key}) {
    if (systemState == SystemState.booting || systemState == SystemState.intakeClosed) {
      return Container(key: key);
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEXT',
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
              'คิวถัดไป',
              style: AppTokens.plexSansThai(
                fontSize: 14,
                color: AppTokens.signalInfo,
                height: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Next rows wrapper
        Column(
          children: List.generate(4, (index) {
            final next = index < nextBuffer.length ? nextBuffer[index] : null;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.4),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: next == null 
                  ? const SizedBox(key: ValueKey('empty'), height: 44) 
                  : Row(
                      key: ValueKey(next.ticket),
                      children: [
                        Expanded(
                          child: Text(
                            next.ticket,
                            style: AppTokens.plexSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: AppTokens.textMuted,
                              letterSpacing: 2.0,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            next.service,
                            style: AppTokens.plexSans(
                              fontSize: 24,
                              fontWeight: FontWeight.normal,
                              color: AppTokens.textMuted,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTokens.signalAction,
            letterSpacing: 2.0,
            height: 1.0,
          ).copyWith(
            fontFamilyFallback: ['IBM Plex Sans'],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVICE',
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
}

class _ActiveCallRow extends StatelessWidget {
  final CalledTicket item;

  const _ActiveCallRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = item.ticket == '---';
    final Color highlightColor = item.isHighlight ? AppTokens.signalAction : Colors.transparent;
    final Color textColor = item.isHighlight ? Colors.white : (isEmpty ? AppTokens.borderSubtle : AppTokens.signalAction);
    final Color serviceColor = item.isHighlight ? Colors.white : (isEmpty ? AppTokens.textMuted.withValues(alpha: 0.5) : AppTokens.textPrimary);

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
                  color: AppTokens.signalAction.withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Number
          Expanded(
            child: Text(
              item.ticket,
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

          // Service
          Expanded(
            child: Text(
              item.service,
              style: AppTokens.plexSans(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: serviceColor,
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

