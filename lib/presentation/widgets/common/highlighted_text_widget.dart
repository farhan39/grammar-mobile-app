import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';
import 'package:grammar_checker/utility/helpers/text_diff_helper.dart';

class HighlightedTextWidget extends StatelessWidget {
  final String text;
  final List<TextError> errors;
  final Function(String, int, int)? onTextReplaced;
  final TextStyle? style;

  const HighlightedTextWidget({
    super.key,
    required this.text,
    required this.errors,
    this.onTextReplaced,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(text: _buildTextSpan(context));
  }

  TextSpan _buildTextSpan(BuildContext context) {
    if (errors.isEmpty) {
      return TextSpan(
        text: text,
        style:
            style ??
            GoogleFonts.nunito(fontSize: 14, color: AppColors.textColor),
      );
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // Sort errors by start position
    List<TextError> sortedErrors = List.from(errors)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (TextError error in sortedErrors) {
      // Ensure error positions are within text bounds
      int errorStart = error.start.clamp(0, text.length);
      int errorEnd = error.end.clamp(0, text.length);

      // Skip if error positions are invalid
      if (errorStart >= errorEnd || errorStart >= text.length) {
        continue;
      }

      // Add text before the error
      if (currentIndex < errorStart) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, errorStart),
            style:
                style ??
                GoogleFonts.nunito(fontSize: 14, color: AppColors.textColor),
          ),
        );
      }

      // Add highlighted error text (non-interactive if onTextReplaced is null)
      spans.add(
        TextSpan(
          text: text.substring(errorStart, errorEnd),
          style:
              (style ??
                      GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ))
                  .copyWith(
                    backgroundColor: _getErrorColor(
                      error.errorType,
                    ).withValues(alpha: 0.2),
                    decoration: TextDecoration.underline,
                    decorationColor: _getErrorColor(error.errorType),
                    decorationThickness: 2,
                  ),
          recognizer: onTextReplaced != null
              ? (TapGestureRecognizer()
                  ..onTap = () => _showSuggestionDialog(context, error))
              : null, // No tap functionality if onTextReplaced is null
        ),
      );

      currentIndex = errorEnd;
    }

    // Add remaining text after last error
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style:
              style ??
              GoogleFonts.nunito(fontSize: 14, color: AppColors.textColor),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  Color _getErrorColor(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'spelling':
        return Colors.red;
      case 'grammar':
        return Colors.orange;
      case 'remove':
        return Colors.purple;
      default:
        return AppColors.errorColor;
    }
  }

  void _showSuggestionDialog(BuildContext context, TextError error) {
    if (error.suggestion.isEmpty && error.errorType != 'remove') {
      return; // No suggestion available
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                _getErrorIcon(error.errorType),
                color: _getErrorColor(error.errorType),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_capitalizeFirst(error.errorType)} Error',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getErrorMessage(error.errorType),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Original text
              Text(
                'Original:',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  error.originalText,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textColor,
                  ),
                ),
              ),

              if (error.suggestion.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Suggestion:',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _applySuggestion(context, error);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.successColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppColors.successColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error.suggestion,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondaryColor,
                              size: 12,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to apply correction (you can fix multiple errors)',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: AppColors.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (error.errorType == 'remove') ...[
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    _applySuggestion(context, error);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Remove this word',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondaryColor,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(color: AppColors.textSecondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applySuggestion(BuildContext context, TextError error) {
    if (onTextReplaced != null) {
      onTextReplaced!(error.suggestion, error.start, error.end);
    }
    Navigator.of(context).pop();

    // Show a brief, subtle confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Applied "${error.suggestion}"',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(milliseconds: 800), // Shorter duration
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 100,
          left: 16,
          right: 16,
        ), // Position higher
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  IconData _getErrorIcon(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'spelling':
        return Icons.spellcheck;
      case 'grammar':
        return Icons.edit;
      case 'remove':
        return Icons.delete_outline;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorMessage(String errorType) {
    switch (errorType.toLowerCase()) {
      case 'spelling':
        return 'This word appears to be misspelled.';
      case 'grammar':
        return 'Grammar correction is suggested for this word.';
      case 'remove':
        return 'This word should be removed.';
      default:
        return 'An error was detected in this text.';
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
