import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/order/data/repositories/order_repository_impl.dart';
import '../../features/order/domain/repositories/order_repository.dart';
import '../../features/order/presentation/cubit/order_cubit.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';

// New imports for multi-tenant system
import '../../features/restaurant/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurant/domain/repositories/restaurant_repository.dart';
import '../../features/restaurant/presentation/cubit/restaurant_cubit.dart';
import '../../features/branch/data/repositories/branch_repository_impl.dart';
import '../../features/branch/domain/repositories/branch_repository.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';

import '../services/notification_service.dart';
import '../services/locale_cubit.dart';
import '../services/location_service.dart';
import '../services/order_notification_service.dart';
import '../services/pending_order_cubit.dart';
import '../services/search_service.dart';
import '../services/ocr_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);

  // Services
  sl.registerLazySingleton(() => NotificationService(sl(), sl()));
  sl.registerLazySingleton(() => OrderNotificationService(firestore: sl(), messaging: sl()));
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => SearchService(firestore: sl()));
  sl.registerLazySingleton(() => OcrService());

  // Legacy Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(auth: sl(), firestore: sl()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(firestore: sl()),
  );

  // New Multi-tenant Repositories
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<BranchRepository>(
    () => BranchRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(firestore: sl()),
  );

  // Legacy Cubits
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => LocaleCubit());
  sl.registerFactory(() => PendingOrderCubit(sl()));
  sl.registerFactory(() => OrderCubit(sl()));
  sl.registerFactory(() => AdminCubit(sl()));

  // New Cubits
  sl.registerFactory(() => RestaurantCubit(sl(), sl()));
  sl.registerFactory(() => CartCubit(sl()));
}
