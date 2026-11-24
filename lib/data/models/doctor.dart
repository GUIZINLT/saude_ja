class Doctor {
  final String id;
  final String name;
  final String specialtyId;
  final String specialtyName;
  final String crm;
  final double rating;
  final int reviewCount;
  final String bio;
  final String? photoUrl;
  final bool featured;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialtyId,
    required this.specialtyName,
    required this.crm,
    required this.rating,
    required this.reviewCount,
    required this.bio,
    required this.photoUrl,
    required this.featured,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'] as String,
    name: json['name'] as String,
    specialtyId: json['specialtyId'] as String,
    specialtyName: json['specialtyName'] as String,
    crm: json['crm'] as String,
    rating: (json['rating'] as num).toDouble(),
    reviewCount: json['reviewCount'] as int,
    bio: json['bio'] as String,
    photoUrl: json['photoUrl'] as String?,
    featured: json['featured'] as bool,
  );
}
