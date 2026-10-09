import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_tokens.dart';
import 'models/queue_state.dart';
import 'widgets/left_panel.dart';
import 'widgets/right_panel.dart';
import 'widgets/footer_ticker.dart';
import 'widgets/operator_toolbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SamuiFidsApp());
}

class SamuiFidsApp extends StatelessWidget {
  const SamuiFidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samui Immigration - FIDS Queue Display',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTokens.displayCanvas,
        canvasColor: AppTokens.displayCanvas,
      ),
      home: const FidsScreen(),
    );
  }
}

class FidsScreen extends StatefulWidget {
  const FidsScreen({super.key});

  @override
  State<FidsScreen> createState() => _FidsScreenState();
}

class _FidsScreenState extends State<FidsScreen> {
  late final QueueController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = QueueController();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _controller.callNext();
      } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
        _controller.addReadyBatch();
      } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        _controller.reset();
      } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
        _controller.clearQueue();
      } else if (event.logicalKey == LogicalKeyboardKey.keyT) {
        _controller.toggleSystemState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppTokens.displayCanvas,
        body: Stack(
          children: [
            // Responsive 16:9 Canvas (Fixed 1920x1080 Virtual Grid)
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: SizedBox(
                  width: AppTokens.designWidth,
                  height: AppTokens.designHeight,
                  child: Container(
                    color: AppTokens.displayCanvas,
                    padding: const EdgeInsets.fromLTRB(64, 48, 64, 48),
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Main Arena (838px height)
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Panel: Call to Counter
                                  Expanded(
                                    child: LeftPanel(
                                      activeCalls: _controller.activeCalls,
                                      nextBuffer: _controller.nextBuffer,
                                      systemState: _controller.systemState,
                                    ),
                                  ),

                                  // Gap between panels (96px exact Figma metric)
                                  const SizedBox(width: 96),

                                  // Right Panel: Passport Pick-up
                                  Expanded(
                                    child: RightPanel(
                                      readyBatches: _controller.readyBatches,
                                      systemState: _controller.systemState,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Footer (98px)
                            const FooterTicker(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Operator Simulator Toolbar (Floating controls)
            OperatorToolbar(controller: _controller),
          ],
        ),
      ),
    );
  }
}

