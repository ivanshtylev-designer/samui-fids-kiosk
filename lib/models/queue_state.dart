import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/sound_service.dart';

enum SystemState { booting, active, intakeClosed }

class CalledTicket {
  final String ticket;
  final String service;
  final String desk;
  final bool isHighlight;
  final String id;

  CalledTicket({
    required this.ticket,
    required this.service,
    required this.desk,
    this.isHighlight = false,
  }) : id = UniqueKey().toString(); // Need unique ID for animations

  CalledTicket copyWith({bool? isHighlight, String? ticket, String? desk}) {
    return CalledTicket(
      ticket: ticket ?? this.ticket,
      service: service,
      desk: desk ?? this.desk,
      isHighlight: isHighlight ?? this.isHighlight,
    );
  }
}

class NextTicket {
  final String ticket;
  final String service;

  NextTicket({required this.ticket, required this.service});
}

class ReadyBatch {
  final String displayRange;
  final String desk;
  final bool isHighlight;

  ReadyBatch({
    required this.displayRange,
    required this.desk,
    this.isHighlight = false,
  });

  ReadyBatch copyWith({bool? isHighlight}) {
    return ReadyBatch(
      displayRange: displayRange,
      desk: desk,
      isHighlight: isHighlight ?? this.isHighlight,
    );
  }
}

class QueueController extends ChangeNotifier {
  List<CalledTicket> _activeCalls = [];
  List<NextTicket> _nextBuffer = [];
  List<ReadyBatch> _readyBatches = [];

  SystemState _systemState = SystemState.booting;
  SystemState get systemState => _systemState;

  int _nextSeqA = 69;
  int _callCounter = 0;
  Timer? _highlightTimer;
  Timer? _bootTimer;

  List<CalledTicket> get activeCalls => List.unmodifiable(_activeCalls);
  List<NextTicket> get nextBuffer => List.unmodifiable(_nextBuffer);
  List<ReadyBatch> get readyBatches => List.unmodifiable(_readyBatches);

  QueueController() {
    _startBootSequence();
  }

  void _startBootSequence() {
    _systemState = SystemState.booting;
    notifyListeners();
    _bootTimer?.cancel();
    _bootTimer = Timer(const Duration(seconds: 3), () {
      _systemState = SystemState.active;
      reset();
    });
  }

  void toggleSystemState() {
    if (_systemState == SystemState.active) {
      _systemState = SystemState.intakeClosed;
      _nextBuffer.clear();
      _activeCalls.clear();
      _readyBatches.clear();
    } else {
      _startBootSequence();
    }
    notifyListeners();
  }

  void reset() {
    _systemState = SystemState.active;
    _activeCalls = [
      CalledTicket(ticket: 'A 065', service: 'Short-term Tourist Ext.', desk: '1'),
      CalledTicket(ticket: 'C 005', service: 'Re-entry Permit', desk: '2'),
      CalledTicket(ticket: 'D 109', service: 'Long-term Visa Ext.', desk: '3'),
    ];

    _nextBuffer = [
      NextTicket(ticket: 'A 066', service: 'Short-term Tourist Ext.'),
      NextTicket(ticket: 'A 067', service: 'Short-term Tourist Ext.'),
      NextTicket(ticket: 'A 068', service: 'Short-term Tourist Ext.'),
      NextTicket(ticket: 'C 006', service: 'Re-entry Permit'),
    ];

    _readyBatches = [
      ReadyBatch(displayRange: 'A 050—A 058', desk: '4'),
      ReadyBatch(displayRange: 'C 004', desk: '4'),
      ReadyBatch(displayRange: 'D 105', desk: '4'),
    ];

    _nextSeqA = 69;
    _callCounter = 0;
    notifyListeners();
  }

  void clearQueue() {
    _nextBuffer.clear();
    _activeCalls = [
      CalledTicket(ticket: '---', service: 'Available', desk: '1'),
      CalledTicket(ticket: '---', service: 'Available', desk: '2'),
      CalledTicket(ticket: '---', service: 'Available', desk: '3'),
    ];
    _readyBatches.clear();
    notifyListeners();
  }

  /// Calls the next ticket in line to an available counter
  void callNext() {
    if (_systemState != SystemState.active) return;
    if (_nextBuffer.isEmpty) return;

    SoundService.playChime();

    final next = _nextBuffer.removeAt(0);
    final targetDeskIndex = _callCounter % 3;
    final deskNumber = (targetDeskIndex + 1).toString();
    _callCounter++;

    // Replace the call at target desk with highlight
    _activeCalls[targetDeskIndex] = CalledTicket(
      ticket: next.ticket,
      service: next.service,
      desk: deskNumber,
      isHighlight: true,
    );

    // Refill buffer randomly to simulate real flow
    final newTicketNum = _nextSeqA++;
    final formattedNum = newTicketNum.toString().padLeft(3, '0');
    _nextBuffer.add(NextTicket(
      ticket: 'A $formattedNum',
      service: 'Short-term Tourist Ext.',
    ));

    notifyListeners();

    // Reset highlight pulse
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 4000), () {
      for (int i = 0; i < _activeCalls.length; i++) {
        if (_activeCalls[i].isHighlight) {
          _activeCalls[i] = _activeCalls[i].copyWith(isHighlight: false);
        }
      }
      notifyListeners();
    });
  }

  /// Pushes a new batch of ready passports to Desk 4
  void addReadyBatch() {
    if (_systemState != SystemState.active) return;
    SoundService.playChime();

    final newBatch = ReadyBatch(
      displayRange: 'A 0${59 + _callCounter}—A 0${64 + _callCounter}',
      desk: '4',
      isHighlight: true,
    );

    _readyBatches.insert(0, newBatch);
    if (_readyBatches.length > 3) {
      _readyBatches.removeLast();
    }

    notifyListeners();

    Timer(const Duration(milliseconds: 4000), () {
      for (int i = 0; i < _readyBatches.length; i++) {
        if (_readyBatches[i].isHighlight) {
          _readyBatches[i] = _readyBatches[i].copyWith(isHighlight: false);
        }
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _bootTimer?.cancel();
    super.dispose();
  }
}

