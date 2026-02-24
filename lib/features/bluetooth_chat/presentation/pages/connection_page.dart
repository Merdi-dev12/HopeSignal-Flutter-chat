import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import './../../../../main.dart';
import '../bloc/bluetooth_bloc.dart';
import '../bloc/bluetooth_state.dart';
import '../bloc/bluetooth_event.dart';

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage({super.key});

  @override
  State<BluetoothConnectionPage> createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Bluetooth"),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: primaryColor,
            ),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: BlocConsumer<BluetoothBloc, BluetoothBlocState>(
        listener: (context, state) {
          if (state is ConnectedState)
            Navigator.pushReplacementNamed(context, '/chat');
          if (state is BluetoothErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: _buildStatusCard(theme, primaryColor, isDark),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "APPAREILS DÉTECTÉS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: secondaryTextColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (state is ScanningState)
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _buildDeviceList(state, theme, primaryColor),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.read<BluetoothBloc>().add(StartScanEvent()),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radar_rounded),
              SizedBox(width: 12),
              Text(
                "Lancer le scan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(
    BluetoothBlocState state,
    ThemeData theme,
    Color primary,
  ) {
    List<ScanResult> results = (state is ScanningState) ? state.results : [];
    final secondaryText = theme.brightness == Brightness.dark
        ? Colors.white60
        : Colors.black54;

    if (results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_searching_rounded,
                size: 64,
                color: secondaryText.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                state is ScanningState
                    ? "Recherche en cours..."
                    : "Appuyez sur scanner",
                style: TextStyle(color: secondaryText, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final result = results[index];
          final name = result.advertisementData.advName.isNotEmpty
              ? result.advertisementData.advName
              : (result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : "Appareil inconnu");

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withOpacity(0.1)),
            ),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getDeviceIcon(name), color: primary),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                result.device.remoteId.str,
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryText,
                  fontFamily: 'monospace',
                ),
              ),
              trailing: Icon(Icons.link_rounded, color: primary),
              onTap: () => context.read<BluetoothBloc>().add(
                ConnectToDeviceEvent(result.device),
              ),
            ),
          );
        }, childCount: results.length),
      ),
    );
  }

  IconData _getDeviceIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains("esp32") || n.contains("hope")) return Icons.memory_rounded;
    return Icons.bluetooth_rounded;
  }

  Widget _buildStatusCard(ThemeData theme, Color primary, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withOpacity(0.1),
                  child: Icon(Icons.bluetooth_audio_rounded, color: primary),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Signal Radio",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Scan des modules Hope...",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bluetooth",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                StreamBuilder<BluetoothAdapterState>(
                  stream: FlutterBluePlus.adapterState,
                  builder: (context, snapshot) => Switch.adaptive(
                    value: snapshot.data == BluetoothAdapterState.on,
                    activeColor: primary,
                    onChanged: (val) => context.read<BluetoothBloc>().add(
                      ToggleBluetoothEvent(val),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
