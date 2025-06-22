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
import 'package:grammar_checker/utility/helpers/responsive_helper.dart';

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
    final responsive = context.responsive;

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
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: responsive.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        UserHeader(
                          title: 'Grammar Checker',
                          fontSize: responsive.pageTitle,
                        ),
                        SizedBox(height: responsive.sectionSpacing),
                        _buildResponsiveLayout(state, responsive),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    GrammarState state,
    ResponsiveHelper responsive,
  ) {
    if (responsive.shouldUseTabletLayout && state is GrammarCheckSuccess) {
      // Tablet layout: side-by-side for input and results
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: _buildGrammarChecker(state, responsive)),
          SizedBox(width: responsive.cardSpacing),
          Expanded(flex: 1, child: _buildGrammarResult(state, responsive)),
        ],
      );
    } else {
      // Mobile layout: stacked vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGrammarChecker(state, responsive),
          if (state is GrammarCheckSuccess) ...[
            SizedBox(height: responsive.cardSpacing),
            _buildGrammarResult(state, responsive),
          ],
        ],
      );
    }
  }

  Widget _buildGrammarChecker(GrammarState state, ResponsiveHelper responsive) {
    final isLoading = state is GrammarLoading;

    return CardContainer(
      padding: EdgeInsets.all(responsive.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your text',
            style: GoogleFonts.nunito(
              fontSize: responsive.sectionTitle,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: responsive.smallSpacing),

          // Text Input Field
          CustomTextField(
            controller: _textController,
            hintText: 'Type your text here...',
            maxLines: responsive.textFieldLines.toInt(),
          ),

          SizedBox(height: responsive.smallSpacing),

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

  Widget _buildGrammarResult(
    GrammarCheckSuccess result,
    ResponsiveHelper responsive,
  ) {
    return CardContainer(
      padding: EdgeInsets.all(responsive.cardPadding),
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
                size: responsive.mediumIcon,
              ),
              SizedBox(width: responsive.getSpacing(6, 8, 10)),
              Expanded(
                child: Text(
                  result.hasCorrections
                      ? 'Grammar Issues Found'
                      : 'Perfect Grammar!',
                  style: GoogleFonts.nunito(
                    fontSize: responsive.cardTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.smallSpacing),

          if (result.hasCorrections) ...[
            // Errors Summary
            if (result.errors.isNotEmpty) ...[
              Text(
                'Errors Found: ${result.errors.length}',
                style: GoogleFonts.nunito(
                  fontSize: responsive.bodyText,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              SizedBox(height: responsive.getSpacing(6, 8, 10)),

              // Error breakdown with responsive layout
              ...result.errors.map(
                (error) => _buildErrorSummary(error, responsive),
              ),

              SizedBox(height: responsive.smallSpacing),
            ],

            // Original Text with highlights
            Text(
              'Original Text (tap errors to correct):',
              style: GoogleFonts.nunito(
                fontSize: responsive.bodyText,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryColor,
              ),
            ),
            SizedBox(height: responsive.getSpacing(6, 8, 10)),
            Container(
              padding: EdgeInsets.all(responsive.getSpacing(10, 12, 14)),
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
                  fontSize: responsive.bodyText,
                  color: AppColors.textColor,
                ),
              ),
            ),

            SizedBox(height: responsive.smallSpacing),

            // Corrected Text
            Text(
              'Corrected Text:',
              style: GoogleFonts.nunito(
                fontSize: responsive.bodyText,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryColor,
              ),
            ),
            SizedBox(height: responsive.getSpacing(6, 8, 10)),
            Container(
              padding: EdgeInsets.all(responsive.getSpacing(10, 12, 14)),
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
                  fontSize: responsive.bodyText,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ] else ...[
            // Perfect Grammar Message
            Container(
              padding: EdgeInsets.all(responsive.getSpacing(10, 12, 14)),
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
                  fontSize: responsive.bodyText,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ],

          SizedBox(height: responsive.smallSpacing),

          // Action Buttons with responsive layout
          _buildActionButtons(result, responsive),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    GrammarCheckSuccess result,
    ResponsiveHelper responsive,
  ) {
    if (responsive.shouldStackButtonsVertically) {
      // Stack buttons vertically on very small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (result.hasCorrections) ...[
            PrimaryButton(
              text: 'Use Corrected Text',
              onPressed: () {
                _textController.text = result.correctedText;
                context.read<GrammarCubit>().clearGrammarResult();
              },
              isOutlined: true,
            ),
            const SizedBox(height: 8),
          ],
          PrimaryButton(
            text: 'Clear All',
            onPressed: () {
              _textController.clear();
              context.read<GrammarCubit>().clearGrammarResult();
            },
            isOutlined: true,
            borderColor: AppColors.borderColor,
            foregroundColor: AppColors.textSecondaryColor,
          ),
        ],
      );
    } else {
      // Horizontal layout for larger screens
      return Row(
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
            SizedBox(width: responsive.getSpacing(8, 12, 16)),
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
      );
    }
  }

  Widget _buildErrorSummary(TextError error, ResponsiveHelper responsive) {
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
      margin: EdgeInsets.only(bottom: responsive.getSpacing(6, 8, 10)),
      padding: EdgeInsets.all(responsive.getSpacing(8, 10, 12)),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(errorIcon, color: errorColor, size: responsive.smallIcon),
          SizedBox(width: responsive.getSpacing(6, 8, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${error.errorType.toUpperCase()}: "${error.originalText}"',
                  style: GoogleFonts.nunito(
                    fontSize: responsive.bodyText,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                if (error.suggestion.isNotEmpty) ...[
                  SizedBox(height: responsive.getSpacing(2, 4, 6)),
                  Text(
                    'Suggestion: ${error.suggestion}',
                    style: GoogleFonts.nunito(
                      fontSize: responsive.smallText,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (error.errorType == 'remove') ...[
                  SizedBox(height: responsive.getSpacing(2, 4, 6)),
                  Text(
                    'Suggestion: Remove this word',
                    style: GoogleFonts.nunito(
                      fontSize: responsive.smallText,
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
