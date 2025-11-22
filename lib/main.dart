import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens.dart';
import 'services/notification_service.dart';
import 'ui/notifications/notifications_manager.dart';
import 'ui/shared/theme_manager.dart';

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
  late final ThemeManager _themeManager;
  
  late final AuthManager _authManager;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    
    // Initialize Managers
    _themeManager = ThemeManager();
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authManager),
        ChangeNotifierProvider.value(value: widget.notificationsManager),
        ChangeNotifierProvider.value(value: _themeManager), 
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
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp.router(
            title: 'Abacus',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeManager.colorSelected.color,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeManager.colorSelected.color,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeManager.themeMode, 
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
