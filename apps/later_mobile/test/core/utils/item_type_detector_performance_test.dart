// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/utils/item_type_detector.dart';

void main() {
  group('ItemTypeDetector - Performance', () {
    test('should detect type in less than 10ms for short content', () {
      const content = 'Buy milk tomorrow at 5pm';
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        ItemTypeDetector.detectType(content);
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMilliseconds / 100;

      print('Average detection time for short content: ${avgTime}ms');
      expect(avgTime, lessThan(10));
    });

    test('should detect type in less than 10ms for list content', () {
      const content = '''
- Item 1
- Item 2
- Item 3
- Item 4
- Item 5
''';
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        ItemTypeDetector.detectType(content);
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMilliseconds / 100;

      print('Average detection time for list content: ${avgTime}ms');
      expect(avgTime, lessThan(10));
    });

    test('should detect type in less than 10ms for long note content', () {
      const content = '''
This is a longer piece of text that contains multiple sentences.
It's more narrative in nature and doesn't have a clear action or list structure.
The purpose of this test is to measure the performance of the type detection
algorithm when dealing with longer text content that clearly represents a note.
We want to ensure that even with longer content, the detection remains fast
and efficient.
''';
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        ItemTypeDetector.detectType(content);
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMilliseconds / 100;

      print('Average detection time for long note content: ${avgTime}ms');
      expect(avgTime, lessThan(10));
    });

    test('should extract list items in less than 10ms', () {
      const content = '''
Shopping list:
- Milk
- Eggs
- Bread
- Butter
- Cheese
- Yogurt
- Apples
- Oranges
- Bananas
- Grapes
''';
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        ItemTypeDetector.extractListItems(content);
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMilliseconds / 100;

      print('Average extraction time for list items: ${avgTime}ms');
      expect(avgTime, lessThan(10));
    });

    test('should calculate confidence in less than 10ms', () {
      const content = 'Buy milk tomorrow at 5pm';
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 100; i++) {
        ItemTypeDetector.getConfidence(content, ContentType.todoList);
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMilliseconds / 100;

      print('Average confidence calculation time: ${avgTime}ms');
      expect(avgTime, lessThan(10));
    });
  });
}
