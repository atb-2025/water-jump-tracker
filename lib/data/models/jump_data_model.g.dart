// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jump_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JumpDataModelAdapter extends TypeAdapter<JumpDataModel> {
  @override
  final int typeId = 0;

  @override
  JumpDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JumpDataModel(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      fallTime: fields[2] as double,
      height: fields[3] as double,
      velocity: fields[4] as double,
      rotationX: fields[5] as double,
      rotationY: fields[6] as double,
      rotationZ: fields[7] as double,
      stabilityScore: fields[8] as double,
      location: fields[9] as LocationDataModel,
      weather: fields[10] as WeatherDataModel,
      pulse: fields[11] as PulseDataModel,
      totalScore: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, JumpDataModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.fallTime)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.velocity)
      ..writeByte(5)
      ..write(obj.rotationX)
      ..writeByte(6)
      ..write(obj.rotationY)
      ..writeByte(7)
      ..write(obj.rotationZ)
      ..writeByte(8)
      ..write(obj.stabilityScore)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.weather)
      ..writeByte(11)
      ..write(obj.pulse)
      ..writeByte(12)
      ..write(obj.totalScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JumpDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationDataModelAdapter extends TypeAdapter<LocationDataModel> {
  @override
  final int typeId = 1;

  @override
  LocationDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationDataModel(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      altitude: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LocationDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.altitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeatherDataModelAdapter extends TypeAdapter<WeatherDataModel> {
  @override
  final int typeId = 2;

  @override
  WeatherDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherDataModel(
      temperature: fields[0] as double,
      condition: fields[1] as String,
      windSpeed: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.condition)
      ..writeByte(2)
      ..write(obj.windSpeed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PulseDataModelAdapter extends TypeAdapter<PulseDataModel> {
  @override
  final int typeId = 3;

  @override
  PulseDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PulseDataModel(
      startPulse: fields[0] as int,
      maxPulse: fields[1] as int,
      endPulse: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PulseDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.startPulse)
      ..writeByte(1)
      ..write(obj.maxPulse)
      ..writeByte(2)
      ..write(obj.endPulse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PulseDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
