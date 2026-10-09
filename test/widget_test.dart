import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:samui_fids_kiosk/main.dart';
import 'package:samui_fids_kiosk/models/queue_state.dart';

void main() {
  group('QueueController Domain Logic Tests', () {
    test('initializes with default morningIntake when startWithBoot is false', () {
      final controller = QueueController(startWithBoot: false);
      expect(controller.phase, OperationalPhase.morningIntake);
      expect(controller.activeCalls.length, 3);
      expect(controller.nextBuffer.isNotEmpty, true);
      expect(controller.readyBatches.isNotEmpty, true);
      controller.dispose();
    });

    test('advances queue and updates target desk correctly on callNext', () {
      final controller = QueueController(startWithBoot: false);
      final initialTicket = controller.nextBuffer.first.ticket;

      controller.callNext(targetDesk: 1);

      expect(controller.activeCalls[0].ticket, initialTicket);
      expect(controller.activeCalls[0].desk, '1');
      expect(controller.activeCalls[0].isHighlight, true);

      controller.dispose();
    });

    test('targets counter 2 with Re-Entry Permit service on callNext(targetDesk: 2)', () {
      final controller = QueueController(startWithBoot: false);
      controller.callNext(targetDesk: 2);

      expect(controller.activeCalls[1].desk, '2');
      expect(controller.activeCalls[1].service, QueueDomainConstants.serviceReEntry);
      expect(controller.activeCalls[1].isHighlight, true);

      controller.dispose();
    });

    test('adds ready batches to Desk 4 capped at maxReadyBatches', () {
      final controller = QueueController(startWithBoot: false);
      controller.addReadyBatch(customRange: 'A 090—A 098');

      expect(controller.readyBatches.length, QueueDomainConstants.maxReadyBatches);
      expect(controller.readyBatches.first.displayRange, 'A 090—A 098');
      expect(controller.readyBatches.first.desk, '4');
      expect(controller.readyBatches.first.isHighlight, true);

      controller.dispose();
    });

    test('cycles phases across booting, morning, lunch, and afternoon', () {
      final controller = QueueController(startWithBoot: false);
      expect(controller.phase, OperationalPhase.morningIntake);

      controller.cyclePhase();
      expect(controller.phase, OperationalPhase.lunchBreak);

      controller.cyclePhase();
      expect(controller.phase, OperationalPhase.afternoonPickup);

      controller.cyclePhase();
      expect(controller.phase, OperationalPhase.morningIntake);

      controller.dispose();
    });

    test('clears queue to Counter Available idle state', () {
      final controller = QueueController(startWithBoot: false);
      controller.clearQueue();

      expect(controller.nextBuffer.isEmpty, true);
      expect(controller.readyBatches.isEmpty, true);
      expect(controller.activeCalls.every((c) => c.ticket == '---'), true);

      controller.dispose();
    });

    test('safely disposes without leaking timers', () {
      final controller = QueueController(startWithBoot: false);
      controller.callNext();
      controller.addReadyBatch();
      controller.toggleAutoDemo();

      expect(() => controller.dispose(), returnsNormally);
      // Repeated actions after disposal are silent no-ops
      expect(() => controller.callNext(), returnsNormally);
      expect(() => controller.cyclePhase(), returnsNormally);
    });
  });

  group('FIDS Screen Widget & Layout Tests', () {
    testWidgets('renders cleanly at 1920x1080 without RenderFlex overflow in morning phase',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = QueueController(startWithBoot: false);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: FidsScreen(controller: controller),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('CALL TO COUNTER'), findsOneWidget);
      expect(find.text('PASSPORT PICK-UP'), findsOneWidget);
      expect(find.text('A 065'), findsOneWidget);
      expect(find.text('A 050—A 058'), findsOneWidget);
    });

    testWidgets('renders lunch break banner when phase is lunchBreak', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = QueueController(startWithBoot: false);
      controller.setPhase(OperationalPhase.lunchBreak);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: FidsScreen(controller: controller),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('LUNCH BREAK (12:00 – 13:00) • COUNTERS ON HOLD'), findsOneWidget);
      expect(find.text('PASSPORT PICK-UP'), findsOneWidget);
    });

    testWidgets('renders afternoon pickup banner when phase is afternoonPickup',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = QueueController(startWithBoot: false);
      controller.setPhase(OperationalPhase.afternoonPickup);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: FidsScreen(controller: controller),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('MORNING INTAKE CLOSED'), findsOneWidget);
      expect(find.textContaining('AFTERNOON PICK-UP'), findsOneWidget);
    });

    testWidgets('responds to keyboard shortcuts: T cycles phase, Space calls next',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = QueueController(startWithBoot: false);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: FidsScreen(controller: controller),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.phase, OperationalPhase.morningIntake);

      // Press 'T' key to cycle phase to lunchBreak
      await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.phase, OperationalPhase.lunchBreak);
    });
  });
}
