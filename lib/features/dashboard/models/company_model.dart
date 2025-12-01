class CompanyModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final List<String> specialties;
  final String phone;
  final String? founded;
  final String? members;
  final String? states;
  final List<String>? features;
  final List<String>? benefits;

  CompanyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.specialties,
    required this.phone,
    this.founded,
    this.members,
    this.states,
    this.features,
    this.benefits,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      specialties: json['specialties'] is List
          ? List<String>.from(json['specialties'])
          : [],
      phone: json['phone'] ?? json['phone_number'] ?? '',
      founded: json['founded'],
      members: json['members'],
      states: json['states'],
      features:
          json['features'] is List ? List<String>.from(json['features']) : null,
      benefits:
          json['benefits'] is List ? List<String>.from(json['benefits']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'rating': rating,
      'specialties': specialties,
      'phone': phone,
      'founded': founded,
      'members': members,
      'states': states,
      'features': features,
      'benefits': benefits,
    };
  }
}

class PlanModel {
  final String id;
  final String title;
  final String description;
  final String color;
  final String? category;
  final double? price;
  final String? coverage;

  PlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    this.category,
    this.price,
    this.coverage,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? 'bg-blue-500',
      category: json['category'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      coverage: json['coverage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'category': category,
      'price': price,
      'coverage': coverage,
    };
  }
}
