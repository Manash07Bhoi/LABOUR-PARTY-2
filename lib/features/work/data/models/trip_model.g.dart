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
      place: fields[6] == null ? '' : fields[6] as String,
      workType: fields[7] == null ? 'Sand (Bali)' : fields[7] as String,
      notes: fields[8] == null ? '' : fields[8] as String,
      updatedAt: fields[9] as DateTime?,
      status: fields[10] == null ? 'Completed' : fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.place)
      ..writeByte(7)
      ..write(obj.workType)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.status);
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
