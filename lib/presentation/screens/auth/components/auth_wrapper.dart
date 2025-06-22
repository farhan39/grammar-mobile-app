import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_state.dart';
import 'package:grammar_checker/presentation/widgets/auth/auth_card.dart';
import 'package:grammar_checker/presentation/widgets/auth/auth_navigation.dart';
import 'package:grammar_checker/presentation/widgets/buttons/primary_button.dart';
import 'package:grammar_checker/presentation/widgets/common/app_header.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';
import 'package:grammar_checker/utility/helpers/responsive_helper.dart';

class AuthScreenWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cardTitle;
  final String buttonText;
  final String navigationLeadingText;
  final String navigationActionText;
  final String navigationRoute;
  final List<Widget> formFields;
  final VoidCallback onSubmit;

  const AuthScreenWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cardTitle,
    required this.buttonText,
    required this.navigationLeadingText,
    required this.navigationActionText,
    required this.navigationRoute,
    required this.formFields,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            } else if (state is AuthLoggedIn) {
              Navigator.of(context).pushReplacementNamed('/grammar');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: availableHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: responsive.authTopSpacing),
                        AppHeader(
                          title: title,
                          subtitle: subtitle,
                          titleFontSize: responsive.headerTitleSize,
                          subtitleFontSize: responsive.headerSubtitleSize,
                        ),
                        SizedBox(height: responsive.authHeaderSpacing),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: responsive.authCardMaxWidth,
                            ),
                            child: AuthCard(
                              title: cardTitle,
                              padding: EdgeInsets.all(responsive.cardPadding),
                              children: [
                                ...formFields,
                                SizedBox(height: responsive.mediumSpacing),
                                PrimaryButton(
                                  text: buttonText,
                                  onPressed: isLoading ? null : onSubmit,
                                  isLoading: isLoading,
                                ),
                                const SizedBox(height: 16),
                                AuthNavigation(
                                  leadingText: navigationLeadingText,
                                  actionText: navigationActionText,
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushReplacementNamed(navigationRoute),
                                  isEnabled: !isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.authBottomSpacing),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
