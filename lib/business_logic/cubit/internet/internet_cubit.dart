import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:grammar_checker/utility/constants/app_strings.dart';
import 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity _connectivity;
  late StreamSubscription _connectivityStreamSubscription;

  InternetCubit(this._connectivity) : super(const InternetInitialState()) {
    monitorInternetConnection();
  }

  void monitorInternetConnection() {
    _connectivityStreamSubscription = _connectivity.onConnectivityChanged
        .listen((connectivityResult) async {
          emit(const InternetLoadingState());
          await _updateConnectionStatus(connectivityResult.first);
        });
  }

  Future<void> _updateConnectionStatus(
    ConnectivityResult connectivityResult,
  ) async {
    if (connectivityResult == ConnectivityResult.none) {
      emit(InternetDisconnectedState(lastChecked: DateTime.now()));
    } else {
      try {
        final connectionType = connectivityResult == ConnectivityResult.wifi
            ? ConnectionType.wifi
            : ConnectionType.mobile;

        final connectionSpeed = await _checkConnectionSpeed();

        emit(
          InternetConnectedState(
            connectionType: connectionType,
            connectionSpeed: connectionSpeed,
            lastChecked: DateTime.now(),
          ),
        );
      } catch (e) {
        emit(
          InternetErrorState(
            errorMessage: AppStrings.getError(
              userFriendlyMessage: "Failed to check connection speed.",
            ),
          ),
        );
      }
    }
  }

  Future<ConnectionSpeed> _checkConnectionSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      await http.get(Uri.parse('https://www.google.com'));
      stopwatch.stop();
      final elapsedMilliseconds = stopwatch.elapsedMilliseconds;

      if (elapsedMilliseconds < 300) {
        return ConnectionSpeed.fast;
      } else if (elapsedMilliseconds < 1000) {
        return ConnectionSpeed.average;
      } else {
        return ConnectionSpeed.slow;
      }
    } catch (_) {
      return ConnectionSpeed.unknown;
    }
  }

  Future<void> checkInternet() async {
    emit(const InternetLoadingState());
    final connectivityResult = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(connectivityResult.first);
  }

  Future<bool> checkInternetStatus() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(connectivityResult.first);
    return state is InternetConnectedState;
  }

  @override
  Future<void> close() {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }
}
