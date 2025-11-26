# Icono de la Aplicación SYE

## Instrucciones para cambiar el icono

1. **Prepara tu icono:**
   - Crea un archivo PNG de **1024x1024 píxeles**
   - El icono debe ser cuadrado
   - Recomendado: fondo transparente o sólido
   - Nombra el archivo como `icon.png`

2. **Coloca el icono:**
   - Guarda el archivo `icon.png` en esta carpeta (`assets/icon/`)

3. **Genera los iconos:**
   - Ejecuta el siguiente comando en la terminal:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Verifica:**
   - Los iconos se generarán automáticamente para Android, iOS, Web y Windows
   - Si necesitas ajustar la configuración, edita la sección `flutter_launcher_icons` en `pubspec.yaml`

## Notas
- El icono debe ser de alta calidad para que se vea bien en todos los tamaños
- Asegúrate de que el icono tenga buen contraste y sea reconocible en tamaños pequeños
- Para iOS, el icono no debe tener esquinas redondeadas (iOS las agrega automáticamente)

