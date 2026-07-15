class Pet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final String? imageUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final bool? vaccinated;
  final bool? neutered;
  final double? weightKg;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.imageUrl,
    this.gender,
    this.dateOfBirth,
    this.vaccinated,
    this.neutered,
    this.weightKg,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      imageUrl: json['image_url'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      vaccinated: json['vaccinated'] as bool?,
      neutered: json['neutered'] as bool?,
      weightKg: json['weight_kg'] != null
          ? (json['weight_kg'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'image_url': imageUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'vaccinated': vaccinated,
      'neutered': neutered,
      'weight_kg': weightKg,
    };
  }
}