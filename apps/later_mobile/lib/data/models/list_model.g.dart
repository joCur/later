// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListItemAdapter extends TypeAdapter<ListItem> {
  @override
  final int typeId = 23;

  @override
  ListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListItem(
      id: fields[0] as String,
      title: fields[1] as String,
      notes: fields[2] as String?,
      isChecked: fields[3] as bool,
      sortOrder: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ListItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.isChecked)
      ..writeByte(4)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListModelAdapter extends TypeAdapter<ListModel> {
  @override
  final int typeId = 22;

  @override
  ListModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListModel(
      id: fields[0] as String,
      spaceId: fields[1] as String,
      name: fields[2] as String,
      icon: fields[3] as String?,
      items: (fields[4] as List?)?.cast<ListItem>(),
      style: fields[5] as ListStyle,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ListModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.spaceId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.style)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListStyleAdapter extends TypeAdapter<ListStyle> {
  @override
  final int typeId = 24;

  @override
  ListStyle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ListStyle.bullets;
      case 1:
        return ListStyle.numbered;
      case 2:
        return ListStyle.checkboxes;
      default:
        return ListStyle.bullets;
    }
  }

  @override
  void write(BinaryWriter writer, ListStyle obj) {
    switch (obj) {
      case ListStyle.bullets:
        writer.writeByte(0);
        break;
      case ListStyle.numbered:
        writer.writeByte(1);
        break;
      case ListStyle.checkboxes:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListStyleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
