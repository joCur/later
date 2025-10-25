/// Smart type detection utility for automatically classifying content
/// based on content heuristics for the dual-model architecture.
///
/// Detects whether content should be:
/// - TodoList: Actionable tasks with checkboxes
/// - List: Reference collections (shopping lists, watch lists, etc.)
/// - Note: Free-form documentation

/// Content type enum for dual-model architecture
enum ContentType {
  todoList,
  list,
  note,
}

class ItemTypeDetector {
  // Scoring weights
  static const double _checkboxScore = 3.0;
  static const double _actionVerbStartScore = 2.5;
  static const double _actionVerbScore = 0.5;
  static const double _timeIndicatorScore = 1.0;
  static const double _priorityIndicatorScore = 1.5;
  static const double _shortTaskBonusScore = 1.0;
  static const double _bulletListBaseScore = 4.0;
  static const double _bulletListItemScore = 0.5;
  static const double _listKeywordScore = 1.5;
  static const double _simpleListScore = 2.0;
  static const double _longTextScore = 2.0;
  static const double _multipleSentencesScore = 1.5;
  static const double _paragraphScore = 1.5;
  static const double _narrativeTextScore = 1.0;
  static const double _noteBaselineScore = 1.0;

  // Thresholds
  static const int _taskLengthThreshold = 100;
  static const int _shortLineThreshold = 50;
  static const int _noteWordCountThreshold = 20;
  static const double _weakSignalThreshold = 2.0;
  static const double _weakSignalConfidenceMultiplier = 0.6;

  // Action verbs that indicate a task
  static const _actionVerbs = [
    'buy',
    'call',
    'send',
    'schedule',
    'book',
    'email',
    'write',
    'read',
    'complete',
    'finish',
    'start',
    'create',
    'update',
    'delete',
    'fix',
    'get',
    'make',
    'do',
    'plan',
    'prepare',
    'review',
    'check',
    'verify',
    'test',
    'submit',
    'contact',
    'meet',
    'discuss',
    'confirm',
    'cancel',
    'reschedule',
  ];

  // Time/date indicators
  static const _timeIndicators = [
    'tomorrow',
    'today',
    'tonight',
    'next week',
    'next month',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
    'at',
    'by',
    'pm',
    'am',
  ];

  // Priority indicators
  static const _priorityIndicators = [
    'urgent',
    'important',
    'asap',
    'critical',
    'high priority',
  ];

  // List keywords
  static const _listKeywords = [
    'list',
    'items',
    'things to',
    'todo',
    'checklist',
  ];

  // Checkbox pattern
  static final _checkboxPattern = RegExp(r'^\s*\[[\sx]?\]\s*');

  // Bullet point patterns
  static final _bulletPattern = RegExp(r'^\s*[-*•]\s+');

  // Numbered list pattern
  static final _numberedPattern = RegExp(r'^\s*\d+[\.)]\s+');

  // Multiple newlines pattern
  static final _multipleNewlinesPattern = RegExp(r'\n\s*\n');

  /// Detects the most likely content type based on content.
  ///
  /// Uses heuristics to analyze the content and determine if it's a
  /// TodoList, List, or Note. Returns [ContentType.note] as the default for
  /// ambiguous content.
  static ContentType detectType(String content) {
    if (content.trim().isEmpty) {
      return ContentType.note;
    }

    final taskScore = _calculateTaskScore(content);
    final listScore = _calculateListScore(content);
    final noteScore = _calculateNoteScore(content);

    // Return the type with the highest score
    if (listScore > taskScore && listScore > noteScore) {
      return ContentType.list;
    } else if (taskScore > noteScore) {
      return ContentType.todoList;
    } else {
      return ContentType.note;
    }
  }

  /// Returns confidence score (0.0 - 1.0) for the detection.
  ///
  /// Higher scores indicate stronger confidence in the type classification.
  /// The confidence is based on how much stronger the detected type is
  /// compared to other types.
  static double getConfidence(String content, ContentType type) {
    if (content.trim().isEmpty) {
      return type == ContentType.note ? 0.5 : 0.0;
    }

    final taskScore = _calculateTaskScore(content);
    final listScore = _calculateListScore(content);
    final noteScore = _calculateNoteScore(content);

    final totalScore = taskScore + listScore + noteScore;
    if (totalScore == 0) {
      return type == ContentType.note ? 0.5 : 0.0;
    }

    double typeScore;
    switch (type) {
      case ContentType.todoList:
        typeScore = taskScore;
        break;
      case ContentType.list:
        typeScore = listScore;
        break;
      case ContentType.note:
        typeScore = noteScore;
        break;
    }

    // Calculate raw confidence as proportion of total score
    final rawConfidence = typeScore / totalScore;

    // Adjust confidence based on absolute score strength
    // Low absolute scores indicate weak signals
    final maxScore = [taskScore, listScore, noteScore].reduce((a, b) => a > b ? a : b);
    if (maxScore < _weakSignalThreshold) {
      // Weak signal - reduce confidence
      return (rawConfidence * _weakSignalConfidenceMultiplier).clamp(0.0, 1.0);
    }

    return rawConfidence.clamp(0.0, 1.0);
  }

  /// Extracts potential due date from natural language.
  ///
  /// Currently supports:
  /// - "today" - returns current date
  /// - "tomorrow" - returns next day
  /// - "next week" - returns 7 days from now
  ///
  /// Returns null if no date indicator is found.
  static DateTime? extractDueDate(String content) {
    final lowerContent = content.toLowerCase();
    final now = DateTime.now();

    if (lowerContent.contains('today') || lowerContent.contains('tonight')) {
      return DateTime(now.year, now.month, now.day);
    }

    if (lowerContent.contains('tomorrow')) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }

    if (lowerContent.contains('next week')) {
      final nextWeek = now.add(const Duration(days: 7));
      return DateTime(nextWeek.year, nextWeek.month, nextWeek.day);
    }

    return null;
  }

  /// Extracts list items if content is a list.
  ///
  /// Handles various list formats:
  /// - Bullet points: `- `, `* `, `• `
  /// - Numbered lists: `1. `, `2) `
  /// - Simple line-separated items
  ///
  /// Returns empty list if content is not a list.
  static List<String> extractListItems(String content) {
    if (content.trim().isEmpty) {
      return [];
    }

    final lines = content.split('\n');
    final items = <String>[];
    bool foundListPattern = false;

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty) {
        continue;
      }

      // Check for bullet points
      if (_bulletPattern.hasMatch(line)) {
        final item = line.replaceFirst(_bulletPattern, '').trim();
        if (item.isNotEmpty) {
          items.add(item);
          foundListPattern = true;
        }
        continue;
      }

      // Check for numbered lists
      if (_numberedPattern.hasMatch(line)) {
        final item = line.replaceFirst(_numberedPattern, '').trim();
        if (item.isNotEmpty) {
          items.add(item);
          foundListPattern = true;
        }
        continue;
      }

      // Skip headers/keywords if we haven't found list items yet
      final lowerLine = trimmedLine.toLowerCase();
      final isKeyword = _listKeywords.any((keyword) => lowerLine.contains(keyword));
      if (isKeyword && items.isEmpty) {
        continue;
      }

      // If we've found list patterns, skip non-list lines
      if (foundListPattern) {
        continue;
      }

      // For simple line-separated items (no bullets or numbers)
      // Only include if the line is relatively short
      if (trimmedLine.length < _shortLineThreshold &&
          !trimmedLine.contains('.') &&
          !trimmedLine.endsWith(':')) {
        items.add(trimmedLine);
      }
    }

    // If we collected simple items without finding list patterns,
    // only return them if we have multiple items
    if (!foundListPattern && items.length < 2) {
      return [];
    }

    return items;
  }

  // Private helper methods for scoring

  static double _calculateTaskScore(String content) {
    double score = 0.0;
    final lowerContent = content.toLowerCase();
    final words = lowerContent.split(RegExp(r'\s+'));
    bool hasStrongIndicator = false;

    // Check for checkbox syntax (strong indicator)
    if (_checkboxPattern.hasMatch(content)) {
      score += _checkboxScore;
      hasStrongIndicator = true;
    }

    // Check for action verbs at the start (strong indicator)
    if (words.isNotEmpty) {
      final firstWord = words[0].replaceAll(RegExp(r'[^\w]'), '');
      if (_actionVerbs.contains(firstWord)) {
        score += _actionVerbStartScore;
        hasStrongIndicator = true;
      }
    }

    // Check for any action verbs in content
    if (_containsAny(lowerContent, _actionVerbs)) {
      score += _actionVerbScore;
    }

    // Check for time/date indicators
    if (_containsAny(lowerContent, _timeIndicators)) {
      score += _timeIndicatorScore;
      hasStrongIndicator = true;
    }

    // Check for priority indicators
    if (_containsAny(lowerContent, _priorityIndicators)) {
      score += _priorityIndicatorScore;
      hasStrongIndicator = true;
    }

    // Short imperative sentences
    // Only add this bonus if we have a strong indicator
    if (content.length < _taskLengthThreshold &&
        !content.contains('\n') &&
        hasStrongIndicator) {
      score += _shortTaskBonusScore;
    }

    return score;
  }

  static double _calculateListScore(String content) {
    double score = 0.0;
    final lowerContent = content.toLowerCase();
    final lines = content.split('\n');

    // Count lines with bullet points
    final bulletCount = _countMatchingLines(lines, _bulletPattern);
    if (bulletCount >= 2) {
      score += _bulletListBaseScore + (bulletCount * _bulletListItemScore);
    }

    // Count numbered list items
    final numberedCount = _countMatchingLines(lines, _numberedPattern);
    if (numberedCount >= 2) {
      score += _bulletListBaseScore + (numberedCount * _bulletListItemScore);
    }

    // Check for list keywords
    if (_containsAny(lowerContent, _listKeywords)) {
      score += _listKeywordScore;
    }

    // Check for multiple short lines (potential simple list)
    final nonEmptyLines = lines.where((line) => line.trim().isNotEmpty).toList();
    if (nonEmptyLines.length >= 3) {
      final shortLinesCount =
          nonEmptyLines.where((line) => line.trim().length < _shortLineThreshold).length;
      if (shortLinesCount >= 3 && shortLinesCount == nonEmptyLines.length) {
        score += _simpleListScore;
      }
    }

    return score;
  }

  static double _calculateNoteScore(String content) {
    double score = 0.0;

    // Longer text
    if (content.length > _taskLengthThreshold) {
      score += _longTextScore;
    }

    // Multiple sentences with punctuation
    final sentenceCount = '.!?'.split('').fold<int>(0, (count, punct) {
      return count + punct.allMatches(content).length;
    });
    if (sentenceCount >= 2) {
      score += _multipleSentencesScore;
    }

    // Paragraphs (multiple newlines)
    if (_multipleNewlinesPattern.hasMatch(content)) {
      score += _paragraphScore;
    }

    // Check for narrative/descriptive patterns
    final words = content.split(RegExp(r'\s+'));
    if (words.length > _noteWordCountThreshold) {
      score += _narrativeTextScore;
    }

    // Default baseline for notes (always has some score)
    score += _noteBaselineScore;

    return score;
  }

  // Utility helper methods

  /// Checks if content contains any of the given keywords.
  static bool _containsAny(String content, List<String> keywords) {
    for (final keyword in keywords) {
      if (content.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  /// Counts how many lines match the given pattern.
  static int _countMatchingLines(List<String> lines, RegExp pattern) {
    int count = 0;
    for (final line in lines) {
      if (pattern.hasMatch(line)) {
        count++;
      }
    }
    return count;
  }
}
