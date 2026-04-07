import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/locale_cubit.dart';
import 'core/services/notification_service.dart';
import 'core/services/location_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/session/presentation/cubit/session_cubit.dart';
import 'features/menu/presentation/cubit/menu_cubit.dart';
import 'features/order/presentation/cubit/order_cubit.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';
import 'features/restaurant/presentation/cubit/restaurant_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/home/presentation/pages/modern_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependencies
  await initDependencies();

  // Initialize notifications
  await sl<NotificationService>().initialize();

  runApp(const FtarnaApp());
}

class FtarnaApp extends StatelessWidget {
  const FtarnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<LocationService>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<LocaleCubit>()),
          BlocProvider(create: (_) => sl<AuthCubit>()),
          BlocProvider(create: (_) => sl<SessionCubit>()),
          BlocProvider(create: (_) => sl<MenuCubit>()),
          BlocProvider(create: (_) => sl<OrderCubit>()),
          BlocProvider(create: (_) => sl<AdminCubit>()),
          BlocProvider(create: (_) => sl<RestaurantCubit>()),
          BlocProvider(create: (_) => sl<CartCubit>()),
        ],
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp(
              title: 'Ftarna',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              locale: localeState.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    // Initialize cart for authenticated user
                    context.read<CartCubit>().initializeCart(state.user.id);
                    // Set current user for notifications
                    sl<NotificationService>().setCurrentUser(state.user.id);
                  } else {
                    // Initialize cart for guest
                    context.read<CartCubit>().initializeCart(null);
                  }
                },
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      return const ModernHomeScreen();
                    }
                    return const LoginScreen();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
