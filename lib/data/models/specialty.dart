class Specialty {
  final String id;
  final String name;

  /// Nome de um ícone do Material (ex.: "favorite"). O app converte em
  /// IconData, por exemplo com um `Map<String, IconData>` em core/constants.
  final String icon;
  final int doctorCount;

  const Specialty({
    required this.id,
    required this.name,
    required this.icon,
    required this.doctorCount,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) => Specialty(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    doctorCount: json['doctorCount'] as int? ?? 0,
  );
}
