// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_labour_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripLabourModelAdapter extends TypeAdapter<TripLabourModel> {
  @override
  final int typeId = 3;

  @override
  TripLabourModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripLabourModel(
      id: fields[0] as String,
      tripId: fields[1] as String,
      labourId: fields[2] as String,
      isPresent: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TripLabourModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tripId)
      ..writeByte(2)
      ..write(obj.labourId)
      ..writeByte(3)
      ..write(obj.isPresent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripLabourModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
