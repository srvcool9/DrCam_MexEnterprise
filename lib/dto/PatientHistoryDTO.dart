import 'package:doctorcam/models/databasemodel.dart';

class PatientHistoryDto  {
  final int? id;
  final int patientId;
  final String appointmentId;
  final String patientName;
  final String lastVisited;

  PatientHistoryDto({
    this.id,
    required this.patientId,
    required this.appointmentId,
    required this.patientName,
    required this.lastVisited,
  });

  // Convert DTO to JSON (for API calls or storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'patientName': patientName,
      'lastVisited': lastVisited,
    };
  }

  // Create DTO from JSON (e.g., from API response)
  factory PatientHistoryDto.fromJson(Map<String, dynamic> json) {
    return PatientHistoryDto(
      id: json['id'],
      patientId: json['patientId'],
      appointmentId: json['appointmentId'],
      patientName: json['patientName'],
      lastVisited: json['lastVisited'],
    );
  }

  // Copy method for immutability support
  PatientHistoryDto copyWith({
    int? id,
    int? patientId,
    String? appointmentId,
    String? patientName,
    String? lastVisited,
  }) {
    return PatientHistoryDto(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId ,
      patientName: patientName ?? this.patientName,
      lastVisited: lastVisited ?? this.lastVisited,
    );
  }
}

