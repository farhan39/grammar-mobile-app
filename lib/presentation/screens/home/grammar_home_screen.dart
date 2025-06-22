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
                // Show error message instead of automatically logging out
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.errorColor,
                    duration: const Duration(seconds: 4),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    action:
                        state.message.contains('Authentication failed') ||
                            state.message.contains('re-login')
                        ? SnackBarAction(
                            label: 'Login',
                            textColor: Colors.white,
                            onPressed: () {
                              context.read<AuthCubit>().logout();
                            },
                          )
                        : null,
                  ),
                );
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
            // Original Text with highlights (non-interactive)
            Text(
              'Original Text:',
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
                onTextReplaced: null, // Remove tap functionality
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
    // Only show Clear All button
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: responsive.shouldStackButtonsVertically
              ? double.infinity
              : 200,
        ),
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
    );
  }
}
