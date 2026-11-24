/// Resposta de GET /doctors/{id}/availability.
class DoctorAvailability {
  final String doctorId;
  final List<AvailableDay> days;

  const DoctorAvailability({required this.doctorId, required this.days});

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) =>
      DoctorAvailability(
        doctorId: json['doctorId'] as String,
        days: (json['days'] as List)
            .map((d) => AvailableDay.fromJson(d as Map<String, dynamic>))
            .toList(),
      );
}

class AvailableDay {
  /// "AAAA-MM-DD"
  final String date;
  final List<TimeSlot> slots;

  const AvailableDay({required this.date, required this.slots});

  DateTime get dateTime => DateTime.parse(date);

  bool get hasFreeSlot => slots.any((s) => s.available);

  factory AvailableDay.fromJson(Map<String, dynamic> json) => AvailableDay(
    date: json['date'] as String,
    slots: (json['slots'] as List)
        .map((s) => TimeSlot.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class TimeSlot {
  /// "HH:mm"
  final String time;
  final bool available;

  const TimeSlot({required this.time, required this.available});

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    time: json['time'] as String,
    available: json['available'] as bool,
  );
}
