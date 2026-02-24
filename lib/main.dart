import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/bluetooth_chat/data/data_sources/ble_data_source.dart';
import 'features/bluetooth_chat/data/repositories/ble_repository_impl.dart';
import 'features/bluetooth_chat/domain/repositories/ble_repository.dart';
import 'features/bluetooth_chat/presentation/bloc/bluetooth_bloc.dart';
import 'features/bluetooth_chat/presentation/bloc/chat_bloc.dart';
import 'features/bluetooth_chat/presentation/pages/connection_page.dart';
import 'features/bluetooth_chat/presentation/pages/chat_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final bleDataSource = BleDataSource();
  final bleRepository = BleRepositoryImpl(bleDataSource);

  runApp(
    RepositoryProvider<BleRepository>.value(
      value: bleRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BluetoothBloc>(create: (context) => BluetoothBloc()),
          BlocProvider<ChatBloc>(create: (context) => ChatBloc(bleRepository)),
        ],
        child: const Esp32App(),
      ),
    ),
  );
}

class Esp32App extends StatelessWidget {
  const Esp32App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Hope Signal',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // DESIGN CLAIR
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF007AFF),
            scaffoldBackgroundColor: const Color(0xFFF2F2F7),
            cardColor: Colors.white,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // DESIGN SOMBRE
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF007AFF),
            scaffoldBackgroundColor: Colors.black,
            cardColor: const Color(0xFF1C1C1E),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1C1C1E),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ),

          initialRoute: '/',
          routes: {
            '/': (context) => const BluetoothConnectionPage(),
            '/chat': (context) => const ChatPage(),
          },
        );
      },
    );
  }
}
