import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_state.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';
import 'package:grammar_checker/utility/helpers/responsive_helper.dart';

class UserHeader extends StatelessWidget {
  final String title;
  final double? fontSize;
  final bool showLogout;

  const UserHeader({
    super.key,
    required this.title,
    this.fontSize,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String userEmail = '';
        if (authState is AuthLoggedIn) {
          userEmail = authState.userEmail;
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: fontSize ?? responsive.pageTitle,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    SizedBox(height: responsive.getSpacing(2, 4, 6)),
                    Text(
                      'Welcome, $userEmail',
                      style: GoogleFonts.nunito(
                        fontSize: responsive.bodyText,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showLogout)
              IconButton(
                onPressed: () => context.read<AuthCubit>().logout(),
                icon: Icon(
                  Icons.logout,
                  color: AppColors.textSecondaryColor,
                  size: responsive.mediumIcon,
                ),
                tooltip: 'Logout',
              ),
          ],
        );
      },
    );
  }
}
