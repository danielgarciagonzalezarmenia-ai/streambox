# StreamBox para iOS (iPhone) 🎬

App de streaming con estética premium inspirada en Apple TV+ y Netflix, diseñada para iOS.
Incluye reproductor de video nativo, soporte para películas y series con temporadas y episodios, catálogo en la nube sincronizable en tiempo real desde la PC y almacenamiento local.

---

## ⚡ ¿Cómo agregar películas y series desde tu PC?

**No necesitas volver a compilar la app ni usar Sideloadly para añadir nuevo contenido.**

### Método 1: Usar el script asistente (Recomendado)
1. En tu PC, abre PowerShell en esta carpeta.
2. Ejecuta:
   ```powershell
   .\agregar_contenido.ps1
   ```
3. Elige si vas a agregar una **Película** o una **Serie con episodios**.
4. Pega la URL del video (`.mp4`, `.m3u8`), la URL del póster y el título.
5. El script actualizará `catalog.json` y subirá los cambios a GitHub automáticamente.
6. Abre **StreamBox** en tu iPhone: ¡el nuevo contenido aparecerá al instante!

### Método 2: Editar `catalog.json` manualmente
Abre el archivo `catalog.json` en tu editor de código o directamente en GitHub:
- Para una película:
```json
{
  "id": "mi-pelicula",
  "title": "Nombre de la Película",
  "type": "movie",
  "genre": "Acción",
  "year": "2025",
  "duration": "2h 10m",
  "rating": "4.9",
  "description": "Sinopsis de la película...",
  "posterUrl": "https://enlace-a-tu-imagen.jpg",
  "bannerUrl": "https://enlace-a-tu-banner.jpg",
  "videoUrl": "https://enlace-directo-al-video.mp4",
  "categories": ["Tendencias", "Películas", "Acción"]
}
```
- Para una serie con episodios:
```json
{
  "id": "mi-serie",
  "title": "Nombre de la Serie",
  "type": "series",
  "genre": "Ciencia Ficción",
  "year": "2025",
  "duration": "1 Temporada",
  "rating": "4.8",
  "description": "Sinopsis...",
  "posterUrl": "https://enlace-a-tu-imagen.jpg",
  "bannerUrl": "https://enlace-a-tu-banner.jpg",
  "categories": ["Series", "Tendencias"],
  "seasons": [
    {
      "seasonNumber": 1,
      "title": "Temporada 1",
      "episodes": [
        {
          "episodeNumber": 1,
          "title": "Episodio 1: Inicio",
          "duration": "45 min",
          "videoUrl": "https://enlace-al-video-ep1.mp4"
        }
      ]
    }
  ]
}
```
Haz `git commit` y `git push`. La app detectará los cambios en su próximo inicio o al deslizar hacia abajo en Inicio.

---

## 📲 Instalación del `.ipa` en el iPhone (Sin Mac y con Apple ID Gratis)

### Requisitos previos en tu PC
1. Descarga e instala **Sideloadly** desde [sideloadly.io](https://sideloadly.io).
2. Asegúrate de tener instalado **iTunes** o **Apple Devices** descargado directamente desde apple.com (la versión de Microsoft Store no es compatible con Sideloadly).

### Pasos de instalación en 6 pasos

1. **Conectar el iPhone:** Conecta tu iPhone a la PC mediante cable USB, desbloquéalo y presiona **«Confiar en este ordenador»** si te lo solicita.
2. **Activar Modo Desarrollador en el iPhone:**
   - Ve a **Ajustes > Privacidad y seguridad > Modo desarrollador**.
   - Actívalo y reinicia tu iPhone cuando lo solicite.
3. **Cargar en Sideloadly:**
   - Abre Sideloadly en tu PC.
   - Arrastra el archivo `StreamBox-unsigned.ipa` a la ventana de Sideloadly.
   - Ingresa tu **Apple ID normal** (gratuito, no requiere cuenta de pago de Apple).
4. **Firmar e Instalar:**
   - Haz clic en **«Start»**.
   - Si te lo pide, introduce la contraseña de tu Apple ID y el código de verificación en dos pasos (2FA) que llegará a tu pantalla.
   - Espera a que indique `Done`. La app aparecerá en la pantalla de inicio de tu iPhone.
5. **Confiar en el Certificado:**
   - En tu iPhone, ve a **Ajustes > General > VPN y gestión de dispositivos**.
   - Selecciona tu Apple ID bajo *«App de desarrollador»* y pulsa **«Confiar en...»**.
6. **Abrir StreamBox y Disfrutar:**
   - Abre la aplicación. Concede los permisos de red para cargar las carátulas y reproducción de video.

---

### Límites de la firma gratuita de Apple
- **Caducidad de 7 días:** Por restricciones de Apple para cuentas gratuitas, la firma expira tras 7 días. Para renovarla, basta con volver a pasar el `.ipa` por Sideloadly (tus listas y progreso de reproducción se conservan intactos).
- **Límite de 3 apps:** Una cuenta gratuita permite tener instaladas hasta 3 aplicaciones firmadas simultáneamente.
- *Nota:* TrollStore no es compatible con versiones recientes de iOS.
