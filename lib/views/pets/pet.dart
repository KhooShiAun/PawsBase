class Pet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final String? imageUrl;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.imageUrl,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'image_url': imageUrl,
    };
  }
}
