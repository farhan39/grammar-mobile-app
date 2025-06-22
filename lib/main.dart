import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/auth/auth_state.dart';
import 'package:grammar_checker/business_logic/cubit/grammar/grammar_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/internet/internet_cubit.dart';
import 'package:grammar_checker/data/service_locator.dart';
import 'package:grammar_checker/presentation/core/route/app_routes.dart';
import 'package:grammar_checker/presentation/screens/auth/login_screen.dart';
import 'package:grammar_checker/presentation/screens/home/grammar_home_screen.dart';
import 'package:grammar_checker/utility/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InternetCubit>(
          create: (context) => getIt<InternetCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>()..initializeAuth(),
        ),
        BlocProvider<GrammarCubit>(create: (context) => getIt<GrammarCubit>()),
      ],
      child: MaterialApp(
        title: 'Grammar Checker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loading only for initial auth check, not for login attempts
        if (state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        // If user is logged in, show grammar home screen
        if (state is AuthLoggedIn) {
          return const GrammarHomeScreen();
        }

        // For AuthLoggedOut, AuthError, and AuthLoading states during login,
        // show the login screen (AuthScreenWrapper will handle the states properly)
        return const LoginScreen();
      },
    );
  }
}
