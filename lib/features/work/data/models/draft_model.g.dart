// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftModelAdapter extends TypeAdapter<DraftModel> {
  @override
  final int typeId = 4;

  @override
  DraftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DraftModel(
      date: fields[0] as String,
      session: fields[1] as String,
      workType: fields[2] as String,
      place: fields[3] as String,
      tractor: fields[4] as String,
      driverName: fields[5] as String,
      encodedLabours: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DraftModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.session)
      ..writeByte(2)
      ..write(obj.workType)
      ..writeByte(3)
      ..write(obj.place)
      ..writeByte(4)
      ..write(obj.tractor)
      ..writeByte(5)
      ..write(obj.driverName)
      ..writeByte(6)
      ..write(obj.encodedLabours);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
