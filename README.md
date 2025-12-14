# AgroSig 🌱

Aplicación móvil desarrollada en Flutter para la gestión agrícola inteligente, permitiendo el control de parcelas, trazabilidad de productos y optimización de procesos agrícolas.

## 📱 Características Principales

### 🗺️ Gestión de Parcelas  
- Registro y edición de parcelas con geolocalización precisa  
- Integración con Google Maps para visualización y delimitación  
- Seguimiento de áreas y coordenadas exactas  
  
### 📊 Control de Actividades  
- Registro detallado de operaciones agrícolas  
- Seguimiento de tareas y cronograma de actividades  
- Historial completo de operaciones por parcela  
  
### 📄 Reportes PDF  
- Generación de reportes personalizados  
- Exportación de datos de producción y actividades  
- Documentación profesional para análisis  
  
### 🤖 Asistente IA con Gemini  
- Asistente inteligente para consultas agrícolas  
- Recomendaciones basadas en datos del cultivo  
- Soporte para toma de decisiones  
  
### 🔔 Notificaciones Push  
- Alertas importantes sobre actividades  
- Recordatorios programados  
- Actualizaciones en tiempo real  

## 🛠️ Tecnologías Utilizadas

- **Framework**: Flutter ^3.6.1
- **State Management**: Riverpod ^2.6.1
- **Backend**: Firebase (Auth, Firestore, Messaging)
- **Mapas**: Google Maps Flutter ^2.10.0
- **IA**: Google ML Kit ^0.19.0, Google Generative AI ^0.4.6
- **Red**: HTTP ^1.3.0, Socket.IO Client ^3.0.2

## 📋 Requisitos Previos

- Flutter SDK >= 3.6.1
- Dart SDK >= 3.6.1
- Android Studio / VS Code
- Cuenta de Firebase configurada

## 🚀 Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/AgroSigDev/agrosig_app.git
cd agrosig_app
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
# Editar .env con tus credenciales de Firebase
```

4. Ejecutar la aplicación:
```bash
flutter run
```

## 📁 Estructura del Proyecto

```
lib/
├── screens/           # Pantallas principales
│   ├── auth/         # Autenticación
│   ├── settings/     # Configuración
│   ├── production_batch/  # Gestión de producción
│   └── onboarding_plot/  # Configuración inicial
├── domain/           # Lógica de negocio
├── data/            # Capa de datos
└── widgets/         # Componentes reutilizables
```

## 🔧 Configuración

1. **Firebase**: Configura tu proyecto en Firebase Console y descarga los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)

2. **Google Maps**: Obtén una API key y agrégala en el archivo `android/app/src/main/AndroidManifest.xml`

3. **Notificaciones**: Configura Firebase Cloud Messaging para notificaciones push

## 🤝 Contribuir

1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit de cambios (`git commit -m 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles

## 📞 Contacto

- **Repository**: AgroSigDev/agrosig_app
- **Issues**: [GitHub Issues](https://github.com/AgroSigDev/agrosig_app/issues)

## 👥 Autor
- **David Hernández** - [@Dave0097-hdz](https://github.com/Dave0097-hdz)
