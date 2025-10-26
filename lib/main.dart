import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthManager()),
        ChangeNotifierProvider(create: (context) => AccountManager()),
        ChangeNotifierProvider(create: (context) => CategoriesManager()),
        ChangeNotifierProxyProvider<CategoriesManager, TransactionsManager>(
          create: (context) => TransactionsManager(
            Provider.of<CategoriesManager>(context, listen: false),
          ),
          update: (context, categoriesManager, previousTransactionsManager) =>
              previousTransactionsManager ?? TransactionsManager(categoriesManager),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abacus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue, 
          brightness: Brightness.light, 
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

      ),
      home: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          return authManager.isAuth
              ? const BottomNavBarScreen()
              : const LoginScreen();
        },
      ),

      //home: const CategoriesScreen(),
      //home: const BottomNavBarScreen(),
    );
  }
}

