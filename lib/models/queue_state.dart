import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/sound_service.dart';

/// The 4 operational phases of Koh Samui Immigration center.
enum OperationalPhase {
  booting,          // Hardware check & PIBICS terminal sync
  morningIntake,    // 08:30–11:30: Full active queue (Counters 1–3 + Next + Ready)
  lunchBreak,       // 12:00–13:00: Counters paused (On Hold banner, pick-up standby)
  afternoonPickup,  // 13:00–16:30: Morning intake closed for new TM.7, Counter 4 full delivery
}

/// Domain constants for queue sequencing (eliminating magic numbers).
class QueueDomainConstants {
  static const int startSeqA = 69;
  static const int startSeqC = 7;
  static const int startSeqD = 110;
  static const int maxNextBuffer = 4;
  static const int maxReadyBatches = 3;
  static const Duration highlightDuration = Duration(milliseconds: 4000);
  static const Duration bootSequenceDuration = Duration(milliseconds: 3000);
  static const Duration autoDemoInterval = Duration(milliseconds: 7500);

  static const String serviceShortTerm = 'Short-term Tourist Ext.';
  static const String serviceReEntry = 'Re-entry Permit';
  static const String serviceLongTerm = 'Long-term Visa Ext.';
}

class CalledTicket {
  final String ticket;
  final String service;
  final String desk;
  final bool isHighlight;
  final DateTime callTime;
  final String id;

  CalledTicket({
    required this.ticket,
    required this.service,
    required this.desk,
    this.isHighlight = false,
    DateTime? callTime,
    String? id,
  })  : callTime = callTime ?? DateTime.now(),
        id = id ?? UniqueKey().toString();

  bool get isEmpty => ticket == '---';

  CalledTicket copyWith({
    String? ticket,
    String? service,
    String? desk,
    bool? isHighlight,
  }) {
    return CalledTicket(
      ticket: ticket ?? this.ticket,
      service: service ?? this.service,
      desk: desk ?? this.desk,
      isHighlight: isHighlight ?? this.isHighlight,
      callTime: callTime,
      id: id,
    );
  }
}

class NextTicket {
  final String ticket;
  final String service;
  final String deskHint;

  NextTicket({
    required this.ticket,
    required this.service,
    this.deskHint = '1',
  });
}

class ReadyBatch {
  final String displayRange;
  final String desk;
  final bool isHighlight;
  final DateTime readyTime;
  final String id;

  ReadyBatch({
    required this.displayRange,
    required this.desk,
    this.isHighlight = false,
    DateTime? readyTime,
    String? id,
  })  : readyTime = readyTime ?? DateTime.now(),
        id = id ?? UniqueKey().toString();

  ReadyBatch copyWith({bool? isHighlight}) {
    return ReadyBatch(
      displayRange: displayRange,
      desk: desk,
      isHighlight: isHighlight ?? this.isHighlight,
      readyTime: readyTime,
      id: id,
    );
  }
}

class QueueController extends ChangeNotifier {
  List<CalledTicket> _activeCalls = [];
  List<NextTicket> _nextBuffer = [];
  List<ReadyBatch> _readyBatches = [];

  OperationalPhase _phase = OperationalPhase.booting;
  OperationalPhase get phase => _phase;

  // Backward compatibility getter for widgets expecting SystemState
  OperationalPhase get systemState => _phase;

  bool _isAutoDemo = false;
  bool get isAutoDemo => _isAutoDemo;

  int _seqA = QueueDomainConstants.startSeqA;
  int _seqC = QueueDomainConstants.startSeqC;
  int _seqD = QueueDomainConstants.startSeqD;
  int _batchCounter = 0;
  int _callCounter = 0;

  bool _isDisposed = false;

  // Tracked Timers for complete leak-free disposal (Resolves Audit 6.1)
  Timer? _highlightTimer;
  Timer? _batchHighlightTimer;
  Timer? _bootTimer;
  Timer? _autoDemoTimer;

  List<CalledTicket> get activeCalls => List.unmodifiable(_activeCalls);
  List<NextTicket> get nextBuffer => List.unmodifiable(_nextBuffer);
  List<ReadyBatch> get readyBatches => List.unmodifiable(_readyBatches);

  QueueController({bool startWithBoot = true}) {
    if (startWithBoot) {
      _startBootSequence();
    } else {
      reset();
    }
  }

  void _safeNotify() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  void _startBootSequence() {
    _phase = OperationalPhase.booting;
    _safeNotify();

    _bootTimer?.cancel();
    _bootTimer = Timer(QueueDomainConstants.bootSequenceDuration, () {
      if (_isDisposed) return;
      _phase = OperationalPhase.morningIntake;
      reset();
    });
  }

  /// Sets specific operational phase.
  void setPhase(OperationalPhase newPhase) {
    if (_isDisposed || _phase == newPhase) return;
    _phase = newPhase;

    if (_phase == OperationalPhase.booting) {
      _startBootSequence();
      return;
    }

    _safeNotify();
  }

  /// Cycles between the 3 main working day phases.
  void cyclePhase() {
    if (_isDisposed) return;
    switch (_phase) {
      case OperationalPhase.booting:
      case OperationalPhase.morningIntake:
        setPhase(OperationalPhase.lunchBreak);
        break;
      case OperationalPhase.lunchBreak:
        setPhase(OperationalPhase.afternoonPickup);
        break;
      case OperationalPhase.afternoonPickup:
        setPhase(OperationalPhase.morningIntake);
        break;
    }
  }

  /// Backward-compatible toggle state method.
  void toggleSystemState() {
    cyclePhase();
  }

  /// Resets queue to reference initial state.
  void reset() {
    if (_isDisposed) return;
    _phase = OperationalPhase.morningIntake;

    _activeCalls = [
      CalledTicket(
        ticket: 'A 065',
        service: QueueDomainConstants.serviceShortTerm,
        desk: '1',
      ),
      CalledTicket(
        ticket: 'C 005',
        service: QueueDomainConstants.serviceReEntry,
        desk: '2',
      ),
      CalledTicket(
        ticket: 'D 109',
        service: QueueDomainConstants.serviceLongTerm,
        desk: '3',
      ),
    ];

    _nextBuffer = [
      NextTicket(ticket: 'A 066', service: QueueDomainConstants.serviceShortTerm, deskHint: '1'),
      NextTicket(ticket: 'A 067', service: QueueDomainConstants.serviceShortTerm, deskHint: '1'),
      NextTicket(ticket: 'A 068', service: QueueDomainConstants.serviceShortTerm, deskHint: '1'),
      NextTicket(ticket: 'C 006', service: QueueDomainConstants.serviceReEntry, deskHint: '2'),
    ];

    _readyBatches = [
      ReadyBatch(displayRange: 'A 050—A 058', desk: '4'),
      ReadyBatch(displayRange: 'C 004', desk: '4'),
      ReadyBatch(displayRange: 'D 105', desk: '4'),
    ];

    _seqA = QueueDomainConstants.startSeqA;
    _seqC = QueueDomainConstants.startSeqC;
    _seqD = QueueDomainConstants.startSeqD;
    _batchCounter = 0;
    _callCounter = 0;

    _safeNotify();
  }

  /// Clears active calls and buffers.
  void clearQueue() {
    if (_isDisposed) return;
    _nextBuffer.clear();
    _activeCalls = [
      CalledTicket(ticket: '---', service: 'Counter Available', desk: '1'),
      CalledTicket(ticket: '---', service: 'Counter Available', desk: '2'),
      CalledTicket(ticket: '---', service: 'Counter Available', desk: '3'),
    ];
    _readyBatches.clear();
    _safeNotify();
  }

  /// Calls next ticket in queue to Counter 1, 2, or 3.
  /// If [targetDesk] is omitted, uses round-robin rotation.
  void callNext({int? targetDesk}) {
    if (_isDisposed || _phase != OperationalPhase.morningIntake) return;
    if (_nextBuffer.isEmpty) return;

    SoundService.playChime();

    final next = _nextBuffer.removeAt(0);
    final int deskIndex = targetDesk != null
        ? (targetDesk - 1).clamp(0, 2)
        : (_callCounter % 3);
    final String deskNumber = (deskIndex + 1).toString();
    _callCounter++;

    // Determine appropriate service name based on desk
    String serviceName = next.service;
    if (deskNumber == '1') {
      serviceName = QueueDomainConstants.serviceShortTerm;
    } else if (deskNumber == '2') {
      serviceName = QueueDomainConstants.serviceReEntry;
    } else if (deskNumber == '3') {
      serviceName = QueueDomainConstants.serviceLongTerm;
    }

    _activeCalls[deskIndex] = CalledTicket(
      ticket: next.ticket,
      service: serviceName,
      desk: deskNumber,
      isHighlight: true,
      callTime: DateTime.now(),
    );

    // Replenish buffer with structured realistic numbering
    _replenishNextBuffer(deskIndex);

    _safeNotify();

    // Reset highlight pulse timer safely
    _highlightTimer?.cancel();
    _highlightTimer = Timer(QueueDomainConstants.highlightDuration, () {
      if (_isDisposed) return;
      for (int i = 0; i < _activeCalls.length; i++) {
        if (_activeCalls[i].isHighlight) {
          _activeCalls[i] = _activeCalls[i].copyWith(isHighlight: false);
        }
      }
      _safeNotify();
    });
  }

  void _replenishNextBuffer(int deskIndex) {
    if (deskIndex == 1) {
      final int nextNum = _seqC++;
      final String formattedNum = nextNum.toString().padLeft(3, '0');
      _nextBuffer.add(NextTicket(
        ticket: 'C $formattedNum',
        service: QueueDomainConstants.serviceReEntry,
        deskHint: '2',
      ));
    } else if (deskIndex == 2) {
      final int nextNum = _seqD++;
      final String formattedNum = nextNum.toString().padLeft(3, '0');
      _nextBuffer.add(NextTicket(
        ticket: 'D $formattedNum',
        service: QueueDomainConstants.serviceLongTerm,
        deskHint: '3',
      ));
    } else {
      final int nextNum = _seqA++;
      final String formattedNum = nextNum.toString().padLeft(3, '0');
      _nextBuffer.add(NextTicket(
        ticket: 'A $formattedNum',
        service: QueueDomainConstants.serviceShortTerm,
        deskHint: '1',
      ));
    }
  }

  /// Pushes a new batch of ready passports to Desk 4.
  void addReadyBatch({String? customRange}) {
    if (_isDisposed) return;
    if (_phase == OperationalPhase.booting) return;

    SoundService.playChime();

    _batchCounter++;
    final int startNum = 50 + (_batchCounter * 8);
    final int endNum = startNum + 6;
    final String range = customRange ?? 'A 0$startNum—A 0$endNum';

    final newBatch = ReadyBatch(
      displayRange: range,
      desk: '4',
      isHighlight: true,
      readyTime: DateTime.now(),
    );

    _readyBatches.insert(0, newBatch);
    if (_readyBatches.length > QueueDomainConstants.maxReadyBatches) {
      _readyBatches.removeLast();
    }

    _safeNotify();

    // Reset batch highlight timer safely (Resolves Audit 6.1)
    _batchHighlightTimer?.cancel();
    _batchHighlightTimer = Timer(QueueDomainConstants.highlightDuration, () {
      if (_isDisposed) return;
      for (int i = 0; i < _readyBatches.length; i++) {
        if (_readyBatches[i].isHighlight) {
          _readyBatches[i] = _readyBatches[i].copyWith(isHighlight: false);
        }
      }
      _safeNotify();
    });
  }

  /// Toggles Autonomous Demo Mode (simulates live airport terminal for screencasts).
  void toggleAutoDemo() {
    if (_isDisposed) return;
    _isAutoDemo = !_isAutoDemo;

    _autoDemoTimer?.cancel();
    if (_isAutoDemo) {
      _autoDemoTimer = Timer.periodic(QueueDomainConstants.autoDemoInterval, (_) {
        if (_isDisposed || !_isAutoDemo) return;
        if (_phase == OperationalPhase.morningIntake) {
          // 70% chance call next ticket, 30% chance add ready batch
          if (_callCounter % 3 == 2) {
            addReadyBatch();
          } else {
            callNext();
          }
        } else if (_phase == OperationalPhase.afternoonPickup) {
          addReadyBatch();
        }
      });
    }

    _safeNotify();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _highlightTimer?.cancel();
    _batchHighlightTimer?.cancel();
    _bootTimer?.cancel();
    _autoDemoTimer?.cancel();
    super.dispose();
  }
}
