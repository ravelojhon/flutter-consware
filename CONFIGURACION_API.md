# Configuración de la API

## Configuración de la IP Local

Para que la aplicación móvil pueda conectarse a tu API local, necesitas configurar la IP correcta en `lib/src/core/config/app_config.dart`.

### Para Emulador Android

Si estás usando el emulador de Android, usa:
```dart
static const String localIp = '10.0.2.2';
```

### Para Dispositivo Físico

Si estás usando un dispositivo físico (teléfono/tablet), necesitas usar la IP de tu máquina:

1. **En Windows:**
   ```bash
   ipconfig
   ```
   Busca la dirección IPv4 (ej: `192.168.1.100`)

2. **En Mac/Linux:**
   ```bash
   ifconfig
   # o
   ip addr
   ```
   Busca la dirección IP de tu interfaz de red (ej: `192.168.1.100`)

3. **Actualiza el archivo `lib/src/core/config/app_config.dart`:**
   ```dart
   static const String localIp = '192.168.1.100'; // Reemplaza con tu IP
   ```

### Verificar la Conexión

1. Asegúrate de que tu API esté corriendo en el puerto 3000
2. Verifica que tu dispositivo/emulador esté en la misma red que tu máquina
3. Prueba acceder a la API desde el navegador del dispositivo: `http://TU_IP:3000/api/companies`

### Solución de Problemas

#### Error: "No se pudo conectar al servidor"

1. **Verifica que la API esté corriendo:**
   ```bash
   # En tu máquina, prueba en el navegador:
   http://localhost:3000/api/companies
   ```

2. **Verifica el firewall:**
   - Asegúrate de que el puerto 3000 esté abierto en tu firewall
   - En Windows, permite la conexión en el Firewall de Windows

3. **Verifica la IP:**
   - Asegúrate de usar la IP correcta según tu dispositivo
   - Para emulador: `10.0.2.2`
   - Para dispositivo físico: IP de tu máquina en la red local

4. **Verifica la red:**
   - Tu dispositivo y tu máquina deben estar en la misma red WiFi
   - No uses datos móviles si tu máquina está en WiFi

#### Error: "Tiempo de espera agotado"

1. Verifica que la API esté respondiendo correctamente
2. Aumenta el timeout en `app_config.dart` si es necesario:
   ```dart
   static const int httpTimeout = 30; // Aumentar si es necesario
   ```

#### Logs de Debug

La aplicación imprime logs en la consola cuando intenta conectarse:
- `🔗 Intentando conectar a: ...` - Muestra la URL que se está intentando
- `📡 Respuesta recibida: ...` - Muestra el código de estado HTTP
- `✅ Compañías cargadas: ...` - Muestra cuántas compañías se cargaron
- `❌ Error de conexión: ...` - Muestra errores de conexión

Revisa estos logs en la consola de Flutter para diagnosticar problemas.

