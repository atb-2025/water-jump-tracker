# Water Jump Tracker

En intelligent mobilapp för att analysera vattenhopp automatiskt med hjälp av telefonens sensorer och externa API:er.

## Översikt

Water Jump Tracker fångar hela hoppupplevelsen från start till landning i vattnet. Appen använder telefonens inbyggda sensorer (gyroskop, accelerometer), GPS, pulsdata och väder-API för att ge omedelbar feedback på hoppprestationen.

## Kärnfunktionalitet

### 1. Automatisk Falldetektering
- Gyroskopet övervakar rörelse kontinuerligt
- Detekterar automatiskt när hoppet startar (rörelse över 30°/s)
- Identifierar vattenimpact genom accelerometerdata
- Mäter exakt falltid från start till vattenlandning

### 2. Realtidsmätning och Beräkningar
- **Höjd**: Beräknas från falltid med fysikaliska formler (h = 0.5 * g * t²)
- **Hastighet**: Beräknas från falltid och gravitationskonstanten
- **Rotation & Stabilitet**: Gyroskopet mäter vridningar och rotationsmönster
- **Miljödata**: GPS-position och väderdata (temperatur, väderförhållanden)
- **Pulsdata**: Högsta puls under hoppet, start- och slutpuls från Health API

### 3. Resultatanalys och Poängberäkning
Sammanvägt score baserat på:
- Hopphöjd (35%)
- Rotationsstabilitet (30%)
- Pulsreaktion (20%)
- Rotationsteknik (15%)

## Installation och Användning

### Kör appen
```bash
cd water_jump_tracker
flutter pub get
flutter run
```

### Användning
1. Tryck på **STARTA HOPP**
2. Vänta tills statusen visar **REDO**
3. Gör ditt hopp - appen detekterar automatiskt
4. Se ditt resultat med detaljerad analys

**OBS**: Kräver fysisk enhet (sensorer fungerar inte i emulator)

## Teknisk Arkitektur

### Paket
- `sensors_plus` - Gyroskop och accelerometer
- `geolocator` - GPS-data
- `health` - Pulsdata
- `dio` - Weather API (Open-Meteo)
- `fl_chart` - Grafer
- `hive` - Lokal lagring
- `flutter_riverpod` - State management

### Struktur
```
lib/
├── core/           # Konstanter, tema, utils
├── data/           # Data sources, repositories, models
├── domain/         # Entities, use cases
└── presentation/   # Screens, widgets, providers
```

## Säkerhet

**Varning**: Använd appen ansvarsfullt. Hoppa alltid från säkra höjder och kontrollera vattendjup. Utvecklarna ansvarar inte för skador.
