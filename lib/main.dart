import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens.dart';
import 'services/notification_service.dart';
import 'ui/notifications/notifications_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await dotenv.load();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize notifications manager
  final notificationsManager = NotificationsManager();
  await notificationsManager.loadNotifications();

  // Setup callback để lưu notifications khi có thông báo mới
  notificationService.onNotificationCreated = (notification) {
    notificationsManager.addNotification(notification);
  };

  runApp(MyApp(notificationsManager: notificationsManager));
}

class MyApp extends StatefulWidget {
  final NotificationsManager notificationsManager;

  const MyApp({super.key, required this.notificationsManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Theme state - follow Yummy pattern
  ThemeMode _themeMode = ThemeMode.light;

  // Router & AuthManager - create once to prevent rebuilds
  late final AuthManager _authManager;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Initialize AuthManager once
    _authManager = AuthManager();

    // Initialize GoRouter once
    _router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/splash', // Start at splash screen
      refreshListenable: _authManager,
      redirect: (context, state) {
        final authFromProvider = context.read<AuthManager>();
        final isLoggedIn = authFromProvider.isAuth;

        final isAtAuthScreen =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        if (isLoggedIn && isAtAuthScreen) {
          return '/';
        }

        return null;
      },
      routes: [
        // Splash - NO transition (first screen)
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SplashScreen()),
        ),

        // Login - FADE transition (smooth)
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),

        // Signup - SLIDE UP transition (modal-like)
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => SlideUpTransitionPage(
            key: state.pageKey,
            child: const SignupScreen(),
          ),
        ),

        // Home - FADE transition (smooth)
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => FadeTransitionPage(
            key: state.pageKey,
            child: const BottomNavBarScreen(),
          ),
        ),
      ],
    );
  }

  // Change theme method - follow Yummy pattern
  void _changeThemeMode(bool useLightMode) {
    setState(() {
      _themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authManager),
        ChangeNotifierProvider.value(value: widget.notificationsManager),
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
        // Expose theme change callback - follow Yummy pattern
        Provider<void Function(bool)>.value(value: _changeThemeMode),
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
          scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF11998e),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        ),
        themeMode: _themeMode,
        routerConfig: _router,
      ),
    );
  }
}
