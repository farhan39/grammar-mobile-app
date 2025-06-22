import 'package:equatable/equatable.dart';

enum ConnectionType { wifi, mobile, none }

enum ConnectionSpeed { fast, average, slow, unknown, medium }

abstract class InternetState extends Equatable {
  const InternetState();

  @override
  List<Object?> get props => [];
}

class InternetInitialState extends InternetState {
  const InternetInitialState();
}

class InternetLoadingState extends InternetState {
  const InternetLoadingState();
}

class InternetConnectedState extends InternetState {
  final ConnectionType connectionType;
  final ConnectionSpeed connectionSpeed;
  final DateTime lastChecked;

  const InternetConnectedState({
    required this.connectionType,
    required this.connectionSpeed,
    required this.lastChecked,
  });

  @override
  List<Object?> get props => [
        connectionType,
        connectionSpeed,
        lastChecked,
      ];
}

class InternetDisconnectedState extends InternetState {
  final DateTime lastChecked;

  const InternetDisconnectedState({
    required this.lastChecked,
  });

  @override
  List<Object?> get props => [lastChecked];
}

class InternetErrorState extends InternetState {
  final String errorMessage;

  const InternetErrorState({
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [errorMessage];
}
