import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_state.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

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
                      fontSize: fontSize ?? 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (userEmail.isNotEmpty)
                    Text(
                      'Welcome, $userEmail',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),
            if (showLogout)
              IconButton(
                onPressed: () => context.read<AuthCubit>().logout(),
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.textSecondaryColor,
                ),
                tooltip: 'Logout',
              ),
          ],
        );
      },
    );
  }
}
