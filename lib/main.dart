import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await dotenv.load();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = AuthManager();

    final router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/login', // Start at login screen
      refreshListenable: authManager,
      redirect: (context, state) {
        final authFromProvider = context.read<AuthManager>();
        final isLoggedIn = authFromProvider.isAuth;
        
        final isAtAuthScreen =
            state.matchedLocation == '/login' || state.matchedLocation == '/signup';

        if (isLoggedIn && isAtAuthScreen) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const BottomNavBarScreen(),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProvider(create: (context) => AccountManager()),
        ChangeNotifierProvider(create: (context) => CategoriesManager()),
        ChangeNotifierProxyProvider<CategoriesManager, TransactionsManager>(
          create: (context) => TransactionsManager(
            Provider.of<CategoriesManager>(context, listen: false),
          ),
          update: (context, categories, previous) =>
              previous ?? TransactionsManager(categories),
        ),
        ChangeNotifierProvider(create: (context) => SavingsGoalsManager()),
      ],
      child: MaterialApp.router(
        title: 'Abacus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        routerConfig: router,
      ),
    );
  }
}

