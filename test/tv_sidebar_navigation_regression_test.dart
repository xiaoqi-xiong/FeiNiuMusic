import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feiniu_music/components/focus/tv_focus_scope.dart';

void main() {
  testWidgets('arrows cross nested navigator without selecting route scopes', (
    tester,
  ) async {
    final sidebar = FocusNode(debugLabel: 'sidebar');
    final firstSong = FocusNode(debugLabel: 'first-song');
    final secondSong = FocusNode(debugLabel: 'second-song');
    addTearDown(() {
      sidebar.dispose();
      firstSong.dispose();
      secondSong.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => TvFocusScope(child: child!),
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 160,
                child: Center(
                  child: Focus(
                    focusNode: sidebar,
                    child: const SizedBox(width: 140, height: 150),
                  ),
                ),
              ),
              Expanded(
                child: Navigator(
                  routeDirectionalTraversalEdgeBehavior:
                      TraversalEdgeBehavior.parentScope,
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                    builder: (_) => Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 300,
                        height: 140,
                        child: Column(
                          children: [
                            Focus(
                              focusNode: firstSong,
                              child: const SizedBox(width: 300, height: 70),
                            ),
                            Focus(
                              focusNode: secondSong,
                              child: const SizedBox(width: 300, height: 70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    firstSong.requestFocus();
    await tester.pump();

    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, sidebar);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, firstSong);
    }

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, secondSong);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, firstSong);
  });
}
