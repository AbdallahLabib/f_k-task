import 'dart:ui';
import 'package:flapkap_task/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blocs/orders_bloc.dart';
import 'screens/metrics_screen.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrdersBloc>()..add(LoadOrders()),
      child: MaterialApp(
        title: 'Orders Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          primaryColor: AppColors.primary,
          hintColor: AppColors.accent,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.cardBackground, // Match metrics screen
            foregroundColor: AppColors.appBarForeground,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(
                  bodyColor: AppColors.textPrimary,
                  displayColor: AppColors.textPrimary,
                ),
          ),
          buttonTheme: const ButtonThemeData(
            buttonColor: Colors.blue,
            textTheme: ButtonTextTheme.primary,
          ),
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D1B2A), // Dark Blue
                  Color(0xFF1B263B), // Medium Blue
                  Color(0xFF415A77), // Light Blue
                ],
              ),
            ),
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(),
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: child!,
            ),
          );
        },
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MetricsScreen(),
    // GraphScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Flapkap Task'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
    );
  }
}
