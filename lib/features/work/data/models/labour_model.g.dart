// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labour_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LabourModelAdapter extends TypeAdapter<LabourModel> {
  @override
  final int typeId = 2;

  @override
  LabourModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LabourModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneOptional: fields[2] as String?,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LabourModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneOptional)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabourModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
