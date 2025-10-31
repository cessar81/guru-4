// lib/utils/sensor_service.dart
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  void iniciarDeteccionMovimiento(Function onMovimientoDetectado) {
    userAccelerometerEvents.listen((event) {
      if (event.x.abs() > 5 || event.y.abs() > 5 || event.z.abs() > 5) {
        onMovimientoDetectado();
      }
    });
  }
}