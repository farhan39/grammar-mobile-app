import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grammar_checker/business_logic/cubit/grammar/grammar_state.dart';
import 'package:grammar_checker/data/repositories/repository.dart';
import 'package:grammar_checker/utility/helpers/text_diff_helper.dart';

class GrammarCubit extends Cubit<GrammarState> {
  final Repository repository;

  GrammarCubit({required this.repository}) : super(GrammarInitial());

  // Grammar checking methods
  Future<void> checkGrammar(String text) async {
    if (text.trim().isEmpty) {
      emit(const GrammarCheckError(message: 'Please enter some text to check'));
      return;
    }

    emit(GrammarLoading());

    try {
      final response = await repository.checkGrammar(text);
      final hasCorrections = text.trim() != response.corrected.trim();

      // Generate errors from the difference between original and corrected text
      List<TextError> errors = [];
      if (hasCorrections) {
        errors = TextDiffHelper.findErrors(text, response.corrected);
      }

      emit(
        GrammarCheckSuccess(
          originalText: text,
          correctedText: response.corrected,
          errors: errors,
          hasCorrections: hasCorrections,
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();
      print('Grammar check error: $errorMessage'); // Debug logging

      // Handle specific authentication errors
      if (errorMessage.contains('authentication') ||
          errorMessage.contains('token') ||
          errorMessage.contains('401')) {
        print(
          'Authentication error detected in grammar check',
        ); // Debug logging
        emit(
          const GrammarCheckError(
            message:
                'Authentication failed. Please try again or re-login if the issue persists.',
          ),
        );
      } else if (errorMessage.contains('No internet connection')) {
        emit(
          const GrammarCheckError(
            message: 'No internet connection. Please check your network.',
          ),
        );
      } else {
        emit(GrammarCheckError(message: _parseErrorMessage(errorMessage)));
      }
    }
  }

  // Clear grammar result
  void clearGrammarResult() {
    emit(GrammarInitial());
  }

  // Helper method to parse and clean error messages
  String _parseErrorMessage(String error) {
    if (error.contains('Grammar check failed:')) {
      String cleanedError = error
          .replaceAll('Grammar check failed:', '')
          .trim();
      return cleanedError.isNotEmpty
          ? cleanedError
          : 'Grammar check failed. Please try again.';
    }

    if (error.contains('Text cannot be empty')) {
      return 'Please enter some text to check.';
    }

    // Return a generic message for unknown errors
    return 'Something went wrong. Please try again.';
  }

  // Getters for easier access to state
  bool get isLoading => state is GrammarLoading;
  bool get hasResult => state is GrammarCheckSuccess;
}
