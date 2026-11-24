enum AppointmentStatus {
  confirmed('confirmed', 'Confirmada'),
  completed('completed', 'Realizada'),
  cancelled('cancelled', 'Cancelada');

  /// Valor usado na API.
  final String value;

  /// Texto mostrado no AppointmentCard.
  final String label;

  const AppointmentStatus(this.value, this.label);

  static AppointmentStatus fromValue(String value) =>
      AppointmentStatus.values.firstWhere((s) => s.value == value);
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialtyId;
  final String specialtyName;

  /// "AAAA-MM-DD"
  final String date;

  /// "HH:mm"
  final String time;
  final AppointmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? cancelledAt;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialtyId,
    required this.specialtyName,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.cancelledAt,
  });

  /// Data e hora da consulta juntas, útil para ordenar e formatar.
  DateTime get startsAt => DateTime.parse('${date}T$time:00');

  bool get canCancel => status == AppointmentStatus.confirmed;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    id: json['id'] as String,
    doctorId: json['doctorId'] as String,
    doctorName: json['doctorName'] as String,
    specialtyId: json['specialtyId'] as String,
    specialtyName: json['specialtyName'] as String,
    date: json['date'] as String,
    time: json['time'] as String,
    status: AppointmentStatus.fromValue(json['status'] as String),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    cancelledAt: json['cancelledAt'] == null
        ? null
        : DateTime.parse(json['cancelledAt'] as String),
  );
}
