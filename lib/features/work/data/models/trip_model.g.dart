// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 1;

  @override
  TripModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripModel(
      id: fields[0] as String,
      workId: fields[1] as String,
      tripNumber: fields[2] as int,
      tractor: fields[3] as String,
      driverName: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workId)
      ..writeByte(2)
      ..write(obj.tripNumber)
      ..writeByte(3)
      ..write(obj.tractor)
      ..writeByte(4)
      ..write(obj.driverName)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
