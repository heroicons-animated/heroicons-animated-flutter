import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heroicons_animated/heroicons_animated.dart';

void main() {
  testWidgets('All heroicons render without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final icon in allHeroicons)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: HeroiconAnimatedIcon(
                      icon: icon,
                      size: 32,
                      color: Colors.black,
                      trigger: AnimationTrigger.manual,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    // If we get here without throwing, all icons rendered.
    expect(allHeroicons.length, greaterThan(0));
  });
}
