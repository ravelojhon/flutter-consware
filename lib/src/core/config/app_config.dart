/// Configuración de la aplicación
/// Maneja los diferentes ambientes (local y producción)
class AppConfig {
  /// Ambiente actual de la aplicación
  static const Environment _environment = Environment.local;

  /// IP local de la máquina para desarrollo
  /// IMPORTANTE: Cambiar por la IP de tu máquina (ej: '192.168.1.100')
  /// Para encontrar tu IP en Windows: ipconfig
  /// Para encontrar tu IP en Mac/Linux: ifconfig o ip addr
  // static const String localIp = '10.0.2.2'; // Para emulador Android
  static const String localIp = '179.33.214.87'; // IP de la máquina

  /// URL base de la API según el ambiente
  static String get baseUrl {
    switch (_environment) {
      case Environment.local:
        // Usar IP en lugar de localhost para dispositivos móviles
        return 'http://$localIp:3000';
      case Environment.production:
        return 'https://api.produccion.com'; // TODO: Reemplazar con URL real
    }
  }

  /// Timeout para las peticiones HTTP (en segundos)
  static const int httpTimeout = 15;
}

/// Enum para los diferentes ambientes
enum Environment { local, production }
