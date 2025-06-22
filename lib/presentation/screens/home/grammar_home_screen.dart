import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_state.dart';
import 'package:grammar_checker/business_logic/cubit/grammar/grammar_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/grammar/grammar_state.dart';
import 'package:grammar_checker/presentation/widgets/buttons/primary_button.dart';
import 'package:grammar_checker/presentation/widgets/common/card_container.dart';
import 'package:grammar_checker/presentation/widgets/common/highlighted_text_widget.dart';
import 'package:grammar_checker/presentation/widgets/forms/custom_text_field.dart';
import 'package:grammar_checker/presentation/widgets/common/user_header.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';
import 'package:grammar_checker/utility/helpers/text_diff_helper.dart';

class GrammarHomeScreen extends StatefulWidget {
  const GrammarHomeScreen({super.key});

  @override
  State<GrammarHomeScreen> createState() => _GrammarHomeScreenState();
}

class _GrammarHomeScreenState extends State<GrammarHomeScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
          child: BlocConsumer<GrammarCubit, GrammarState>(
            listener: (context, state) {
              if (state is GrammarCheckError) {
                // Handle session expiry error
                if (state.message.contains('session has expired') ||
                    state.message.contains('login again')) {
                  context.read<AuthCubit>().logout();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.errorColor,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UserHeader(title: 'Grammar Checker'),
                    const SizedBox(height: 32),
                    _buildGrammarChecker(state),
                    if (state is GrammarCheckSuccess) ...[
                      const SizedBox(height: 24),
                      _buildGrammarResult(state),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGrammarChecker(GrammarState state) {
    final isLoading = state is GrammarLoading;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your text',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Text Input Field
          CustomTextField(
            controller: _textController,
            hintText: 'Type your text here...',
            maxLines: 6,
          ),

          const SizedBox(height: 16),

          // Check Grammar Button
          PrimaryButton(
            text: 'Check Grammar',
            onPressed: () =>
                context.read<GrammarCubit>().checkGrammar(_textController.text),
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarResult(GrammarCheckSuccess result) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Result Header
          Row(
            children: [
              Icon(
                result.hasCorrections ? Icons.edit : Icons.check_circle,
                color: result.hasCorrections
                    ? AppColors.primaryColor
                    : AppColors.successColor,
              ),
              const SizedBox(width: 8),
              Text(
                result.hasCorrections
                    ? 'Grammar Issues Found'
                    : 'Perfect Grammar!',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (result.hasCorrections) ...[
            // Errors Summary
            if (result.errors.isNotEmpty) ...[
              Text(
                'Errors Found: ${result.errors.length}',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Error breakdown
              ...result.errors.map((error) => _buildErrorSummary(error)),

              const SizedBox(height: 16),
            ],

            // Original Text with highlights
            Text(
              'Original Text (tap errors to correct):',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.errorColor.withValues(alpha: 0.3),
                ),
              ),
              child: HighlightedTextWidget(
                text: result.originalText,
                errors: result.errors,
                onTextReplaced: (suggestion, start, end) {
                  _textController.text = _textController.text.replaceRange(
                    start,
                    end,
                    suggestion,
                  );
                  // Re-check grammar after applying suggestion
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_textController.text.trim().isNotEmpty && mounted) {
                      context.read<GrammarCubit>().checkGrammar(
                        _textController.text,
                      );
                    }
                  });
                },
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Corrected Text
            Text(
              'Corrected Text:',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                result.correctedText,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ] else ...[
            // Perfect Grammar Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                result.correctedText,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              if (result.hasCorrections) ...[
                Expanded(
                  child: PrimaryButton(
                    text: 'Use Corrected Text',
                    onPressed: () {
                      _textController.text = result.correctedText;
                      context.read<GrammarCubit>().clearGrammarResult();
                    },
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: PrimaryButton(
                  text: 'Clear All',
                  onPressed: () {
                    _textController.clear();
                    context.read<GrammarCubit>().clearGrammarResult();
                  },
                  isOutlined: true,
                  borderColor: AppColors.borderColor,
                  foregroundColor: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSummary(TextError error) {
    Color errorColor;
    IconData errorIcon;

    switch (error.errorType.toLowerCase()) {
      case 'spelling':
        errorColor = Colors.red;
        errorIcon = Icons.spellcheck;
        break;
      case 'grammar':
        errorColor = Colors.orange;
        errorIcon = Icons.edit;
        break;
      case 'remove':
        errorColor = Colors.purple;
        errorIcon = Icons.delete_outline;
        break;
      default:
        errorColor = AppColors.errorColor;
        errorIcon = Icons.error_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(errorIcon, color: errorColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${error.errorType.toUpperCase()}: "${error.originalText}"',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                if (error.suggestion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Suggestion: ${error.suggestion}',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (error.errorType == 'remove') ...[
                  const SizedBox(height: 4),
                  Text(
                    'Suggestion: Remove this word',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
