import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../theme/theme_cubit.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/explore/data/repositories/explore_repository.dart';
import '../../features/explore/presentation/cubit/explore_cubit.dart';

import '../../features/places/data/repositories/places_repository.dart';
import '../../features/places/presentation/cubit/places_cubit.dart';

import '../../features/itinerary/data/repositories/itinerary_repository.dart';
import '../../features/itinerary/presentation/cubit/itinerary_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDI() async {
  // ── Infrastructure ──────────────────────────────────────────
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  sl.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: sl()),
  );

  sl.registerLazySingleton<ApiService>(
    () => ApiService(sl<DioClient>().dio),
  );

  // ── Theme ───────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // ── Repositories ────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl(), sl()),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepository(sl()),
  );
  sl.registerLazySingleton<PlacesRepository>(
    () => PlacesRepository(sl()),
  );
  sl.registerLazySingleton<ItineraryRepository>(
    () => ItineraryRepository(sl()),
  );

  // ── Cubits (factories — new instance per page) ───────────────
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl(), sl()));
  sl.registerFactory<ExploreCubit>(() => ExploreCubit(sl()));
  sl.registerFactory<PlacesCubit>(() => PlacesCubit(sl()));
  sl.registerFactory<ItineraryCubit>(() => ItineraryCubit(sl()));
}
