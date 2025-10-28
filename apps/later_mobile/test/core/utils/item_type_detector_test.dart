import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/utils/item_type_detector.dart';

void main() {
  group('ItemTypeDetector - detectType', () {
    group('Task Detection', () {
      test('should detect task with action verb at start', () {
        expect(
          ItemTypeDetector.detectType('Buy milk tomorrow'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Call mom at 5pm'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Send email to team ASAP'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Schedule dentist appointment'),
          ContentType.todoList,
        );
      });

      test('should detect task with checkbox syntax', () {
        expect(
          ItemTypeDetector.detectType('[ ] Complete the report'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('[x] Finish homework'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('[] Buy groceries'),
          ContentType.todoList,
        );
      });

      test('should detect task with time/date indicators', () {
        expect(
          ItemTypeDetector.detectType('Meeting tomorrow at 3pm'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Call next week'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Submit by Friday'),
          ContentType.todoList,
        );
      });

      test('should detect task with priority indicators', () {
        expect(
          ItemTypeDetector.detectType('URGENT: Review document'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Important meeting today'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Call client asap'),
          ContentType.todoList,
        );
      });

      test('should detect task with multiple action verbs', () {
        expect(
          ItemTypeDetector.detectType('Write and send report'),
          ContentType.todoList,
        );
        expect(ItemTypeDetector.detectType('Read book'), ContentType.todoList);
        expect(
          ItemTypeDetector.detectType('Complete project'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Start workout'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Update database'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Delete old files'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Create presentation'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Book flight tickets'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Email team updates'),
          ContentType.todoList,
        );
        expect(
          ItemTypeDetector.detectType('Finish coding task'),
          ContentType.todoList,
        );
      });

      test('should detect short imperative sentences as tasks', () {
        expect(
          ItemTypeDetector.detectType('Get groceries'),
          ContentType.todoList,
        );
        expect(ItemTypeDetector.detectType('Fix bug'), ContentType.todoList);
      });
    });

    group('List Detection', () {
      test('should detect list with bullet points', () {
        expect(
          ItemTypeDetector.detectType('- Milk\n- Eggs\n- Bread'),
          ContentType.list,
        );
        expect(
          ItemTypeDetector.detectType('* Apples\n* Oranges\n* Bananas'),
          ContentType.list,
        );
        expect(
          ItemTypeDetector.detectType('• Item 1\n• Item 2\n• Item 3'),
          ContentType.list,
        );
      });

      test('should detect list with numbered items', () {
        expect(
          ItemTypeDetector.detectType('1. Wake up\n2. Exercise\n3. Breakfast'),
          ContentType.list,
        );
        expect(
          ItemTypeDetector.detectType('1) First item\n2) Second item'),
          ContentType.list,
        );
      });

      test('should detect list with keywords', () {
        expect(
          ItemTypeDetector.detectType('Shopping list:\n- Milk\n- Eggs'),
          ContentType.list,
        );
        expect(
          ItemTypeDetector.detectType('TODO:\n- Task 1\n- Task 2'),
          ContentType.list,
        );
        expect(
          ItemTypeDetector.detectType('Things to buy:\napples\noranges'),
          ContentType.list,
        );
      });

      test('should detect list with multiple short items', () {
        expect(
          ItemTypeDetector.detectType('Milk\nEggs\nBread\nButter'),
          ContentType.list,
        );
      });

      test('should detect list with mixed patterns', () {
        expect(
          ItemTypeDetector.detectType(
            'Items to pack:\n- Clothes\n- Shoes\n- Toiletries',
          ),
          ContentType.list,
        );
      });
    });

    group('Note Detection', () {
      test('should detect note with long text', () {
        expect(
          ItemTypeDetector.detectType(
            'This is a longer piece of text that contains multiple sentences. '
            'It\'s more narrative in nature and doesn\'t have a clear action or list structure.',
          ),
          ContentType.note,
        );
      });

      test('should detect note with multiple sentences', () {
        expect(
          ItemTypeDetector.detectType(
            'Meeting notes: We discussed the project timeline and agreed on the deliverables. '
            'Everyone was aligned on the next steps.',
          ),
          ContentType.note,
        );
      });

      test('should detect note with paragraphs', () {
        expect(
          ItemTypeDetector.detectType(
            'Random thought I had about improving the workflow.\n\n'
            'This could really help with productivity.',
          ),
          ContentType.note,
        );
      });

      test('should default to note for unclear patterns', () {
        expect(
          ItemTypeDetector.detectType('Just a random thought'),
          ContentType.note,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty string', () {
        expect(ItemTypeDetector.detectType(''), ContentType.note);
      });

      test('should handle single word', () {
        expect(ItemTypeDetector.detectType('Hello'), ContentType.note);
      });

      test('should handle whitespace only', () {
        expect(ItemTypeDetector.detectType('   \n  \t  '), ContentType.note);
      });

      test('should handle mixed patterns preferring strongest signal', () {
        // List pattern is stronger than action verb in this case
        expect(
          ItemTypeDetector.detectType('Buy these items:\n- Milk\n- Eggs'),
          ContentType.list,
        );
      });

      test('should detect task over note for short action verb sentences', () {
        expect(ItemTypeDetector.detectType('Buy milk'), ContentType.todoList);
      });
    });
  });

  group('ItemTypeDetector - getConfidence', () {
    test('should return high confidence for clear task patterns', () {
      final confidence = ItemTypeDetector.getConfidence(
        'Buy milk tomorrow',
        ContentType.todoList,
      );
      expect(confidence, greaterThan(0.7));
    });

    test('should return high confidence for clear list patterns', () {
      final confidence = ItemTypeDetector.getConfidence(
        '- Milk\n- Eggs\n- Bread',
        ContentType.list,
      );
      expect(confidence, greaterThan(0.7));
    });

    test('should return high confidence for clear note patterns', () {
      final confidence = ItemTypeDetector.getConfidence(
        'This is a very long piece of narrative text that clearly looks like a note. '
        'It has multiple sentences and a descriptive tone.',
        ContentType.note,
      );
      expect(confidence, greaterThan(0.7));
    });

    test('should return lower confidence for ambiguous content', () {
      final confidence = ItemTypeDetector.getConfidence(
        'Hello world',
        ContentType.note,
      );
      expect(confidence, lessThan(0.7));
    });

    test('should return confidence between 0.0 and 1.0', () {
      final confidence = ItemTypeDetector.getConfidence(
        'Some text',
        ContentType.note,
      );
      expect(confidence, greaterThanOrEqualTo(0.0));
      expect(confidence, lessThanOrEqualTo(1.0));
    });

    test('should return low confidence for wrong type', () {
      final confidence = ItemTypeDetector.getConfidence(
        '- Milk\n- Eggs',
        ContentType.todoList,
      );
      expect(confidence, lessThan(0.5));
    });
  });

  group('ItemTypeDetector - extractDueDate', () {
    test('should extract due date from "tomorrow"', () {
      final dueDate = ItemTypeDetector.extractDueDate('Buy milk tomorrow');
      expect(dueDate, isNotNull);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(dueDate!.day, tomorrow.day);
      expect(dueDate.month, tomorrow.month);
      expect(dueDate.year, tomorrow.year);
    });

    test('should extract due date from "today"', () {
      final dueDate = ItemTypeDetector.extractDueDate('Meeting today');
      expect(dueDate, isNotNull);
      final today = DateTime.now();
      expect(dueDate!.day, today.day);
      expect(dueDate.month, today.month);
      expect(dueDate.year, today.year);
    });

    test('should return null for no date indicators', () {
      final dueDate = ItemTypeDetector.extractDueDate('Buy milk');
      expect(dueDate, isNull);
    });

    test('should handle "next week"', () {
      final dueDate = ItemTypeDetector.extractDueDate('Call next week');
      expect(dueDate, isNotNull);
      expect(dueDate!.isAfter(DateTime.now()), isTrue);
      expect(
        dueDate.difference(DateTime.now()).inDays,
        greaterThanOrEqualTo(6),
      );
    });

    test('should handle multiple date indicators', () {
      final dueDate = ItemTypeDetector.extractDueDate(
        'Meeting tomorrow at 3pm',
      );
      expect(dueDate, isNotNull);
    });
  });

  group('ItemTypeDetector - extractListItems', () {
    test('should extract items from bullet list', () {
      final items = ItemTypeDetector.extractListItems(
        '- Milk\n- Eggs\n- Bread',
      );
      expect(items, ['Milk', 'Eggs', 'Bread']);
    });

    test('should extract items from numbered list', () {
      final items = ItemTypeDetector.extractListItems(
        '1. Wake up\n2. Exercise\n3. Breakfast',
      );
      expect(items, ['Wake up', 'Exercise', 'Breakfast']);
    });

    test('should extract items from asterisk list', () {
      final items = ItemTypeDetector.extractListItems(
        '* Apples\n* Oranges\n* Bananas',
      );
      expect(items, ['Apples', 'Oranges', 'Bananas']);
    });

    test('should extract items from bullet point list', () {
      final items = ItemTypeDetector.extractListItems(
        '• Item 1\n• Item 2\n• Item 3',
      );
      expect(items, ['Item 1', 'Item 2', 'Item 3']);
    });

    test('should handle list with header', () {
      final items = ItemTypeDetector.extractListItems(
        'Shopping list:\n- Milk\n- Eggs',
      );
      expect(items, ['Milk', 'Eggs']);
    });

    test('should handle mixed bullet styles', () {
      final items = ItemTypeDetector.extractListItems(
        '- Milk\n* Eggs\n• Bread',
      );
      expect(items, ['Milk', 'Eggs', 'Bread']);
    });

    test('should return empty list for non-list content', () {
      final items = ItemTypeDetector.extractListItems(
        'This is just a paragraph of text',
      );
      expect(items, isEmpty);
    });

    test('should handle simple line-separated items', () {
      final items = ItemTypeDetector.extractListItems(
        'Milk\nEggs\nBread\nButter',
      );
      expect(items, ['Milk', 'Eggs', 'Bread', 'Butter']);
    });

    test('should trim whitespace from items', () {
      final items = ItemTypeDetector.extractListItems(
        '-  Milk  \n-  Eggs  \n-  Bread  ',
      );
      expect(items, ['Milk', 'Eggs', 'Bread']);
    });

    test('should handle empty input', () {
      final items = ItemTypeDetector.extractListItems('');
      expect(items, isEmpty);
    });

    test('should handle numbered list with parentheses', () {
      final items = ItemTypeDetector.extractListItems(
        '1) First item\n2) Second item\n3) Third item',
      );
      expect(items, ['First item', 'Second item', 'Third item']);
    });
  });
}
