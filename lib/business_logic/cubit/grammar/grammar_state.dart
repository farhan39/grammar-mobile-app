import 'package:equatable/equatable.dart';
import 'package:grammar_checker/utility/helpers/text_diff_helper.dart';

abstract class GrammarState extends Equatable {
  const GrammarState();

  @override
  List<Object?> get props => [];
}

class GrammarInitial extends GrammarState {}

class GrammarLoading extends GrammarState {}

class GrammarCheckSuccess extends GrammarState {
  final String originalText;
  final String correctedText;
  final List<TextError> errors;
  final bool hasCorrections;

  const GrammarCheckSuccess({
    required this.originalText,
    required this.correctedText,
    required this.errors,
    required this.hasCorrections,
  });

  @override
  List<Object?> get props => [
    originalText,
    correctedText,
    errors,
    hasCorrections,
  ];
}

class GrammarCheckError extends GrammarState {
  final String message;

  const GrammarCheckError({required this.message});

  @override
  List<Object?> get props => [message];
}
