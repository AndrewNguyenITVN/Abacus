import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens.dart';
import 'services/notification_service.dart';
import 'ui/notifications/notifications_manager.dart';
import 'ui/shared/theme_manager.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await dotenv.load();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final notificationsManager = NotificationsManager();
  await notificationsManager.loadNotifications();

  notificationService.onNotificationCreated = (notification) {
    notificationsManager.addNotification(notification);
  };

  runApp(MyApp(
    notificationsManager: notificationsManager,
    notificationService: notificationService,
  ));
}

class MyApp extends StatefulWidget {
  final NotificationsManager notificationsManager;
  final NotificationService notificationService;
  const MyApp({
    super.key,
    required this.notificationsManager,
    required this.notificationService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeManager _themeManager;
  late final AuthManager _authManager;
  late final GoRouter _router;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _authManager = AuthManager();
    _lastUserId = _authManager.user?.id;

    _authManager.addListener(() {
      final currentUserId = _authManager.user?.id;
      if (currentUserId != _lastUserId) {
        // User changed (login/logout) -> Clear notifications
        widget.notificationsManager.clearAll();
        _lastUserId = currentUserId;
      }
    });

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/splash',
      refreshListenable: _authManager,
      redirect: (context, state) {
        final authManager = context.read<AuthManager>();
        final isAuth = authManager.isAuth;
        
        // Kiểm tra xem user có đang ở trang login/signup/splash không
        final isLoggingIn = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/signup' ||
                            state.matchedLocation == '/splash';

        // Chưa đăng nhập và không ở trang auth -> về trang login
        if (!isAuth && !isLoggingIn) {
          return '/login';
        }
        if (isAuth && isLoggingIn) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => FadeTransitionPage(key: state.pageKey, child: const LoginScreen()),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => FadeTransitionPage(key: state.pageKey, child: const SignupScreen()),
        ),

        // Cấu hình Bottom Navigation Bar (Shell Route)
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BottomNavBarScreen(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Trang chủ
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                  routes: [
                    GoRoute(
                      path: 'savings-goals', 
                      builder: (context, state) => const SavingsGoalsScreen(),
                      routes: [
                        GoRoute(
                          path: 'add',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) => SlideUpTransitionPage(
                            key: state.pageKey,
                            child: const AddEditGoalScreen(),
                          ),
                        ),
                        GoRoute(
                          path: 'edit/:id',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) {
                            final id = state.pathParameters['id']!;
                            final goalsManager = context.read<SavingsGoalsManager>();
                            final goal = goalsManager.findById(id);
                            return SlideUpTransitionPage(
                              key: state.pageKey,
                              child: AddEditGoalScreen(goal: goal),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Branch 1: Giao dịch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/transactions',
                  builder: (context, state) => const TransactionsScreen(),
                ),
              ],
            ),
            // Branch 2: Danh mục
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/categories',
                  builder: (context, state) => const CategoriesScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final type = state.uri.queryParameters['type'] ?? 'expense';
                        return SlideUpTransitionPage(
                          key: state.pageKey,
                          child: EditCategoryScreen(type: type),
                        );
                      },
                    ),
                    GoRoute(
                      path: 'edit/:id',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final id = state.pathParameters['id']!;
                        final categoriesManager = context.read<CategoriesManager>();
                        final category = categoriesManager.findById(id);
                        if (category == null) {
                          throw Exception('Category not found');
                        }
                        return SlideUpTransitionPage(
                          key: state.pageKey,
                          child: EditCategoryScreen(
                            category: category,
                            type: category.type,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Branch 3: Tài khoản
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/account',
                  builder: (context, state) => const AccountScreen(),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey, // Che lấp BottomBar
                      pageBuilder: (context, state) {
                        // Lấy account từ AccountManager thay vì truyền qua extra
                        final accountManager = context.read<AccountManager>();
                        final account = accountManager.account;
                        if (account == null) {
                          throw Exception('Account not found');
                        }
                        return SlideUpTransitionPage(
            key: state.pageKey,
                          child: EditProfileScreen(account: account),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Route cho Add Transaction (Nằm ngoài Shell để che mất BottomBar)
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey, 
          path: '/add-transaction',
          pageBuilder: (context, state) => SlideUpTransitionPage(
            key: state.pageKey,
            child: const AddTransactionScreen(),
          ),
        ),

        // Route cho Report Detail
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: '/report-detail',
          builder: (context, state) {
             final type = state.uri.queryParameters['type'] ?? 'expense';
             return DetailedReportScreen(type: type);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.notificationService),
        ChangeNotifierProvider.value(value: _authManager),
        ChangeNotifierProvider.value(value: widget.notificationsManager),
        ChangeNotifierProvider.value(value: _themeManager), 
        ChangeNotifierProxyProvider<AuthManager, AccountManager>(
          create: (context) => AccountManager(),
          update: (context, authManager, accountManager) {
            accountManager!.update(authManager.user);
            return accountManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, CategoriesManager>(
          create: (context) => CategoriesManager(),
          update: (context, authManager, categoriesManager) {
            categoriesManager!.update(authManager.user);
            return categoriesManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, TransactionsManager>(
          create: (context) => TransactionsManager(),
          update: (context, authManager, transactionsManager) {
            transactionsManager!.update(authManager.user);
            return transactionsManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, SavingsGoalsManager>(
          create: (context) => SavingsGoalsManager(),
          update: (context, authManager, savingsGoalsManager) {
            savingsGoalsManager!.update(authManager.user);
            return savingsGoalsManager;
          },
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp.router(
            title: 'Abacus',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: themeManager.colorSelected.color, brightness: Brightness.light),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: themeManager.colorSelected.color, brightness: Brightness.dark),
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