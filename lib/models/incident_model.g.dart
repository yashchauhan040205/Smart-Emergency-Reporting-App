// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncidentAdapter extends TypeAdapter<Incident> {
  @override
  final int typeId = 3;

  @override
  Incident read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Incident(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as IncidentCategory,
      priority: fields[4] as IncidentPriority,
      status: fields[5] as IncidentStatus,
      location: fields[6] as String,
      reportedAt: fields[7] as DateTime,
      assignedResponder: fields[8] as String?,
      isSynced: fields[9] as bool,
      reportedBy: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Incident obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.reportedAt)
      ..writeByte(8)
      ..write(obj.assignedResponder)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.reportedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncidentStatusAdapter extends TypeAdapter<IncidentStatus> {
  @override
  final int typeId = 0;

  @override
  IncidentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncidentStatus.reported;
      case 1:
        return IncidentStatus.inProgress;
      case 2:
        return IncidentStatus.resolved;
      default:
        return IncidentStatus.reported;
    }
  }

  @override
  void write(BinaryWriter writer, IncidentStatus obj) {
    switch (obj) {
      case IncidentStatus.reported:
        writer.writeByte(0);
        break;
      case IncidentStatus.inProgress:
        writer.writeByte(1);
        break;
      case IncidentStatus.resolved:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncidentPriorityAdapter extends TypeAdapter<IncidentPriority> {
  @override
  final int typeId = 1;

  @override
  IncidentPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncidentPriority.low;
      case 1:
        return IncidentPriority.medium;
      case 2:
        return IncidentPriority.high;
      case 3:
        return IncidentPriority.critical;
      default:
        return IncidentPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, IncidentPriority obj) {
    switch (obj) {
      case IncidentPriority.low:
        writer.writeByte(0);
        break;
      case IncidentPriority.medium:
        writer.writeByte(1);
        break;
      case IncidentPriority.high:
        writer.writeByte(2);
        break;
      case IncidentPriority.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncidentCategoryAdapter extends TypeAdapter<IncidentCategory> {
  @override
  final int typeId = 2;

  @override
  IncidentCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncidentCategory.medical;
      case 1:
        return IncidentCategory.fire;
      case 2:
        return IncidentCategory.security;
      case 3:
        return IncidentCategory.accident;
      case 4:
        return IncidentCategory.natural;
      case 5:
        return IncidentCategory.other;
      default:
        return IncidentCategory.other;
    }
  }

  @override
  void write(BinaryWriter writer, IncidentCategory obj) {
    switch (obj) {
      case IncidentCategory.medical:
        writer.writeByte(0);
        break;
      case IncidentCategory.fire:
        writer.writeByte(1);
        break;
      case IncidentCategory.security:
        writer.writeByte(2);
        break;
      case IncidentCategory.accident:
        writer.writeByte(3);
        break;
      case IncidentCategory.natural:
        writer.writeByte(4);
        break;
      case IncidentCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
