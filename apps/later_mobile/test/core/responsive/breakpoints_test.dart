import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/responsive/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    testWidgets('isMobile returns true for mobile widths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // iPhone size
            child: Builder(
              builder: (context) {
                expect(Breakpoints.isMobile(context), isTrue);
                expect(Breakpoints.isTablet(context), isFalse);
                expect(Breakpoints.isDesktop(context), isFalse);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isTablet returns true for tablet widths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)), // Tablet size
            child: Builder(
              builder: (context) {
                expect(Breakpoints.isMobile(context), isFalse);
                expect(Breakpoints.isTablet(context), isTrue);
                expect(Breakpoints.isDesktop(context), isFalse);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('isDesktop returns true for desktop widths', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1440, 900)), // Desktop size
            child: Builder(
              builder: (context) {
                expect(Breakpoints.isMobile(context), isFalse);
                expect(Breakpoints.isTablet(context), isFalse);
                expect(Breakpoints.isDesktop(context), isTrue);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('getScreenSize returns correct enum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.getScreenSize(context), ScreenSize.mobile);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('valueWhen returns correct value based on screen size',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)), // Mobile
            child: Builder(
              builder: (context) {
                final value = Breakpoints.valueWhen<int>(
                  context: context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 3,
                );
                expect(value, 1);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(768, 1024)), // Tablet
            child: Builder(
              builder: (context) {
                final value = Breakpoints.valueWhen<int>(
                  context: context,
                  mobile: 1,
                  tablet: 2,
                  desktop: 3,
                );
                expect(value, 2);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Extension methods work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 812)),
            child: Builder(
              builder: (context) {
                expect(context.isMobile, isTrue);
                expect(context.isTablet, isFalse);
                expect(context.isDesktop, isFalse);
                expect(context.screenSize, ScreenSize.mobile);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });
  });
}
