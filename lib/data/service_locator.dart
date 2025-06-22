import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:grammar_checker/business_logic/cubit/auth/auth_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/grammar/grammar_cubit.dart';
import 'package:grammar_checker/business_logic/cubit/internet/internet_cubit.dart';

import 'package:get_it/get_it.dart';
import 'package:grammar_checker/data/services/api_service.dart';
import 'package:grammar_checker/data/services/local_storage.dart';
import 'package:grammar_checker/data/providers/provider.dart';
import 'package:grammar_checker/data/repositories/repository.dart';
import 'package:grammar_checker/data/services/network_service.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    _registerCoreServices();

    _registerBusinessServices();

    _registerRepositories();

    _registerCubits();
  }

  static void _registerCoreServices() {
    getIt.registerLazySingleton(() => LocalStorageService.instance);
    getIt.registerLazySingleton(() => ApiService.instance);
    getIt.registerLazySingleton(() => Connectivity());
    getIt.registerLazySingleton(() => NetworkService.instance);
  }

  static void _registerBusinessServices() {
    getIt.registerLazySingleton(
      () => Provider(
        localStorageService: getIt<LocalStorageService>(),
        apiService: getIt<ApiService>(),
        networkService: getIt<NetworkService>(),
      ),
    );
  }

  static void _registerRepositories() {
    getIt.registerLazySingleton(() => Repository(provider: getIt<Provider>()));
  }

  static void _registerCubits() {
    // Register the main grammar cubit
    getIt.registerLazySingleton(
      () => GrammarCubit(repository: getIt<Repository>()),
    );

    // Register the internet cubit
    getIt.registerLazySingleton(() => InternetCubit(getIt<Connectivity>()));

    // Register the auth cubit
    getIt.registerLazySingleton(
      () => AuthCubit(repository: getIt<Repository>()),
    );
  }
}
