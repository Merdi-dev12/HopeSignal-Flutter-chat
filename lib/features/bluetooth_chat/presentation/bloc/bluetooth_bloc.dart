import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_event.dart';
import 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothBlocState> {
  StreamSubscription? _scanSubscription;

  BluetoothBloc() : super(BluetoothInitial()) {
    // 1. Gérer le scan (Universel : ESP32, Phones, Audio, etc.)
    on<StartScanEvent>((event, emit) async {
      emit(ScanningState(const []));

      try {
        // On lance le scan avec les paramètres recommandés
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          androidUsesFineLocation: true,
        );

        _scanSubscription?.cancel();
        _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
          add(_UpdateScanResults(results));
        });
      } catch (e) {
        emit(BluetoothErrorState("Erreur de scan: $e"));
      }
    });

    // Événement interne pour mettre à jour la liste en temps réel
    on<_UpdateScanResults>((event, emit) {
      emit(ScanningState(event.results));
    });

    // 2. Gérer la connexion (CORRECTION DÉFINITIVE DE LA LICENCE)
    on<ConnectToDeviceEvent>((event, emit) async {
      emit(ConnectingState(event.device));

      try {
        await FlutterBluePlus.stopScan();

        // On utilise License.values.first pour satisfaire l'argument requis
        // sans risquer une erreur "Undefined name" ou "No constant named"
        await event.device.connect(
          autoConnect: false,
          license: License.values.first, // <--- La clé du succès
          timeout: const Duration(seconds: 35),
        );

        emit(ConnectedState(event.device));
      } catch (e) {
        emit(BluetoothErrorState("Échec de connexion: $e"));
      }
    });

    // 3. Activer/Désactiver Bluetooth (Android seulement)
    on<ToggleBluetoothEvent>((event, emit) async {
      if (event.enable) {
        try {
          await FlutterBluePlus.turnOn();
        } catch (_) {
          // Sur iOS ou certaines versions Android, cela peut échouer silencieusement
        }
      }
    });
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}

// Classe privée pour la mise à jour fluide des résultats
class _UpdateScanResults extends BluetoothEvent {
  final List<ScanResult> results;
  _UpdateScanResults(this.results);
}
