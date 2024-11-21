// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_layout_option.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FacilityLayoutOptionAdapter extends TypeAdapter<FacilityLayoutOption> {
  @override
  final int typeId = 0;

  @override
  FacilityLayoutOption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FacilityLayoutOption(
      uid: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      children: (fields[3] as List?)?.cast<FacilityLayoutOption>(),
      depth: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FacilityLayoutOption obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.children)
      ..writeByte(4)
      ..write(obj.depth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacilityLayoutOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
