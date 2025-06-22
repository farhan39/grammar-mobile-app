import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:grammar_checker/business_logic/cubit/internet/internet_cubit.dart';
import 'package:grammar_checker/data/service_locator.dart';

import 'package:http/http.dart' as http;
import 'dart:async';

class NetworkService {
  final InternetCubit _internetCubit;

  NetworkService._internal(this._internetCubit) {
    _client = http.Client();
  }

  static final NetworkService _instance = NetworkService._internal(
    InternetCubit(getIt<Connectivity>()),
  );

  static NetworkService get instance => _instance;

  late final http.Client _client;

  http.Client get client => _client;

  static const defaultTimeout = Duration(seconds: 10);

  void dispose() {
    _client.close();
  }

  Future<bool> isConnected() async {
    try {
      final response = await _internetCubit.checkInternetStatus();
      return response;
    } catch (e) {
      return false;
    }
  }
}
