class TextDiffHelper {
  /// Analyzes differences between original and corrected text
  /// and generates error information for highlighting
  static List<TextError> findErrors(String original, String corrected) {
    if (original.trim() == corrected.trim()) return [];

    List<TextError> errors = [];
    List<String> originalWords = original.split(' ');
    List<String> correctedWords = corrected.split(' ');

    int originalIndex = 0;
    int correctedIndex = 0;

    // Compare word by word
    while (originalIndex < originalWords.length &&
        correctedIndex < correctedWords.length) {
      String originalWord = originalWords[originalIndex];
      String correctedWord = correctedWords[correctedIndex];

      if (originalWord.toLowerCase() != correctedWord.toLowerCase()) {
        // Found a difference
        int start = _getWordStartPosition(original, originalIndex);
        int end = start + originalWord.length;

        errors.add(
          TextError(
            start: start,
            end: end,
            originalText: originalWord,
            suggestion: correctedWord,
            errorType: _determineErrorType(originalWord, correctedWord),
          ),
        );
      }

      originalIndex++;
      correctedIndex++;
    }

    // Handle remaining words in original (words to be removed)
    while (originalIndex < originalWords.length) {
      String originalWord = originalWords[originalIndex];
      int start = _getWordStartPosition(original, originalIndex);
      int end = start + originalWord.length;

      errors.add(
        TextError(
          start: start,
          end: end,
          originalText: originalWord,
          suggestion: '', // Empty means remove
          errorType: 'remove',
        ),
      );
      originalIndex++;
    }

    return errors;
  }

  static int _getWordStartPosition(String text, int wordIndex) {
    List<String> words = text.split(' ');
    int position = 0;

    for (int i = 0; i < wordIndex && i < words.length; i++) {
      position += words[i].length + 1; // +1 for space
    }

    return position;
  }

  static String _determineErrorType(String original, String corrected) {
    // Simple heuristics to determine error type
    if (_isSimilarWord(original, corrected)) {
      return 'spelling';
    } else {
      return 'grammar';
    }
  }

  static bool _isSimilarWord(String word1, String word2) {
    // Check if words are similar (likely spelling mistake)
    int distance = _levenshteinDistance(
      word1.toLowerCase(),
      word2.toLowerCase(),
    );
    return distance <= 2;
  }

  static int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }
}

class TextError {
  final int start;
  final int end;
  final String originalText;
  final String suggestion;
  final String errorType;

  TextError({
    required this.start,
    required this.end,
    required this.originalText,
    required this.suggestion,
    required this.errorType,
  });
}
