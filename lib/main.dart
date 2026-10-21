import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/cart_provider.dart';
import 'provider/customer_profile_provider.dart';
import 'provider/transaction_history_provider.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<CustomerProfileProvider>(
          create: (_) => CustomerProfileProvider(),
        ),
        ChangeNotifierProvider<TransactionHistoryProvider>(
          create: (_) => TransactionHistoryProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'ApotekKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
