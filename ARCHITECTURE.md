# Water Jump Tracker - Projektstruktur

## Översikt
Komplett Flutter-app för automatisk analys av vattenhopp med sensorer, GPS, pulsdata och väder-API.

## Filstruktur

```
water_jump_tracker/
├── lib/
│   ├── core/                              # Kärnkomponenter
│   │   ├── constants/
│   │   │   └── app_constants.dart         # Fysikaliska konstanter, tröskelvärden
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material Design tema (light/dark)
│   │   └── utils/
│   │       └── permission_manager.dart    # Behörighetshantering
│   │
│   ├── data/                              # Data Layer
│   │   ├── datasources/
│   │   │   ├── sensor_data_source.dart    # Gyroskop + Accelerometer (sensors_plus)
│   │   │   ├── location_data_source.dart  # GPS (geolocator)
│   │   │   ├── health_data_source.dart    # Pulsdata (health package)
│   │   │   └── weather_data_source.dart   # Väder-API (Open-Meteo)
│   │   ├── models/
│   │   │   ├── jump_data_model.dart       # Hive-modeller för lokal lagring
│   │   │   └── jump_data_model.g.dart     # Genererad Hive TypeAdapter
│   │   └── repositories/
│   │       └── jump_history_repository.dart # Lokal lagring med Hive
│   │
│   ├── domain/                            # Domain Layer (Business Logic)
│   │   ├── entities/
│   │   │   ├── jump_data.dart             # JumpData, LocationData, WeatherData, PulseData
│   │   │   └── sensor_reading.dart        # SensorReading entitet
│   │   └── usecases/
│   │       ├── jump_analysis_engine.dart  # Falldetektering, analys, beräkningar
│   │       └── score_calculator.dart      # Poängberäkningsalgoritm
│   │
│   ├── presentation/                      # Presentation Layer (UI)
│   │   ├── providers/
│   │   │   └── jump_providers.dart        # Riverpod providers & state management
│   │   └── screens/
│   │       ├── home_screen.dart           # Startskärm med startknapp
│   │       ├── result_screen.dart         # Resultatskärm med grafer
│   │       └── history_screen.dart        # Historik och statistik
│   │
│   └── main.dart                          # Entry point, Hive-initialisering
│
├── android/                               # Android-konfiguration
│   └── app/src/main/AndroidManifest.xml  # Android-behörigheter
│
├── ios/                                   # iOS-konfiguration
│   └── Runner/Info.plist                  # iOS-behörigheter
│
├── pubspec.yaml                           # Dependencies
└── README.md                              # Projektdokumentation
```

## Dataflöde

### 1. Hopp Startar
```
HomeScreen (User taps "STARTA HOPP")
    ↓
JumpTrackingNotifier.startJump()
    ↓
SensorDataSource.startMonitoring() → Streams sensor data
    ↓
JumpAnalysisEngine.startMonitoring() → Listens to sensor stream
```

### 2. Hopp Detekteras
```
SensorReading (gyro > 30°/s)
    ↓
JumpAnalysisEngine._detectFallStart()
    ↓
State changes to "JUMPING"
    ↓
Continues collecting sensor data
```

### 3. Vattenimpact
```
SensorReading (accel > 15 m/s²)
    ↓
JumpAnalysisEngine._detectWaterImpact()
    ↓
Stop sensors
    ↓
JumpAnalysisEngine.analyzeJump()
```

### 4. Resultatberäkning
```
JumpAnalysisEngine.analyzeJump()
    ├── Beräkna falltid (timestamp diff)
    ├── Beräkna höjd (h = 0.5 * g * t²)
    ├── Beräkna hastighet (v = g * t)
    └── Analysera rotation (integrera gyrodata)
    
Parallellt:
    ├── LocationDataSource.getCurrentLocation()
    ├── WeatherDataSource.getCurrentWeather()
    └── HealthDataSource.getPulseData()

ScoreCalculator.calculateTotalScore()
    ├── Höjdpoäng (35%)
    ├── Stabilitetspoäng (30%)
    ├── Pulspoäng (20%)
    └── Rotationspoäng (15%)
```

### 5. Spara & Visa
```
JumpData entity created
    ↓
JumpHistoryRepository.saveJump() → Hive local storage
    ↓
Navigate to ResultScreen
    ↓
Display results with fl_chart graphs
```

## Nyckelklasser

### Analysis Engine
**`JumpAnalysisEngine`** - Hjärtat av appen
- `processSensorReading()` - Analyserar varje sensoravläsning
- `_detectFallStart()` - Detekterar när hoppet startar (gyro > 30°/s)
- `_detectWaterImpact()` - Detekterar vattenlandning (accel > 15 m/s²)
- `analyzeJump()` - Beräknar alla resultat från sensordata

**`ScoreCalculator`** - Poängberäkning
- `calculateTotalScore()` - Viktat genomsnitt av alla faktorer
- Normalisering av höjd, puls, rotation till 0-100 skala

### State Management
**`JumpTrackingNotifier`** - StateNotifier för hoppets livscykel
- States: idle → preparing → ready → jumping → analyzing → completed
- Hanterar all koordination mellan data sources

### Data Sources
- **`SensorDataSource`** - Kombinerar gyro + accelerometer till `SensorReading`
- **`LocationDataSource`** - GPS-position med hög noggrannhet
- **`HealthDataSource`** - Pulsdata från Health/HealthKit
- **`WeatherDataSource`** - Väderdata från Open-Meteo API

## Fysikaliska Formler

### Höjd från Falltid
```dart
final height = 0.5 * AppConstants.gravity * fallTime * fallTime;
// h = 0.5 * 9.82 * t²
```

### Hastighet vid Impact
```dart
final velocity = AppConstants.gravity * fallTime;
// v = 9.82 * t
```

### Rotation (Integration av Gyroskopdata)
```dart
for (int i = 1; i < readings.length; i++) {
  final dt = readings[i].timestamp.difference(readings[i-1].timestamp).inMilliseconds / 1000.0;
  totalRotX += readings[i].gyroX * dt;
}
// θ = ∫ ω dt
```

### Stabilitet (Standardavvikelse)
```dart
final mean = gyroValues.reduce((a, b) => a + b) / gyroValues.length;
final variance = gyroValues.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / gyroValues.length;
final stdDev = sqrt(variance);
final stability = max(0.0, 100.0 - (stdDev * 2));
```

## Dependencies

### Produktion
- `sensors_plus: ^6.0.1` - Gyroskop & accelerometer
- `geolocator: ^13.0.2` - GPS
- `health: ^11.1.0` - Pulsdata
- `dio: ^5.7.0` - HTTP-klient
- `fl_chart: ^0.70.1` - Grafer
- `hive: ^2.2.3` + `hive_flutter: ^1.1.0` - Lokal NoSQL-databas
- `permission_handler: ^11.3.1` - Behörigheter
- `flutter_riverpod: ^2.6.1` - State management
- `intl: ^0.19.0` - Datum/tid-formattering
- `equatable: ^2.0.8` - Value equality
- `uuid: ^4.5.2` - Unika ID:n

### Utveckling
- `hive_generator: ^2.0.1` - Genererar TypeAdapters
- `build_runner: ^2.4.13` - Kod-generering

## Behörigheter

### Android
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.HIGH_SAMPLING_RATE_SENSORS"/>
<uses-permission android:name="android.permission.BODY_SENSORS"/>
```

### iOS
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<key>NSMotionUsageDescription</key>
<key>NSHealthShareUsageDescription</key>
<key>NSHealthUpdateUsageDescription</key>
```

## Testning

### Kör appen
```bash
flutter run
```

### Analysera kod
```bash
flutter analyze
```

### Generera Hive adapters (om ändrat models)
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Implementationsstatus

✅ Projektstruktur och dependencies
✅ Sensor/Data Layer (gyroskop, GPS, health, weather)
✅ Analysis Engine (falldetektering, beräkningar, poäng)
✅ UI Layer (home, result, history screens)
✅ State management (Riverpod)
✅ Lokal lagring (Hive)
✅ Behörighetshantering
✅ Kod kompilerar utan fel

## Nästa Steg

För att använda appen med verkliga hopp:
1. Kör på fysisk enhet (sensorer fungerar ej i emulator)
2. Ge alla behörigheter (plats, sensorer, hälsa)
3. Testa från säker höjd (1-2 meter först)
4. Verifiera att sensordata fångas korrekt
5. Justera tröskelvärden om nödvändigt (AppConstants)

## Kända Begränsningar

- iOS HealthKit kräver App Store-godkännande
- Sensorer fungerar endast på fysiska enheter
- GPS kräver utomhusposition för bästa noggrannhet
- Väder-API kräver internetanslutning (fallback till standardvärden offline)

---

**OBS**: Detta är en experimentell app. Använd med försiktighet och hoppa endast från säkra höjder med kontrollerat vattendjup.
