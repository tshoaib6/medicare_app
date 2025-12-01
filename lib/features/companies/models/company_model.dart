class CompanyModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String rating; // Keep as string for backward compatibility
  final String phone;
  final List<String> specialties;
  final DateTime createdAt;
  final DateTime updatedAt;
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
    required this.phone,
    required this.specialties,
    required this.createdAt,
    required this.updatedAt,
    this.founded,
    this.members,
    this.states,
    this.features,
    this.benefits,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      specialties:
          (json['specialties'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      founded: json['founded'],
      members: json['members'],
      states: json['states'],
      features: (json['features'] as List<dynamic>?)?.cast<String>(),
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'rating': rating,
      'phone': phone,
      'specialties': specialties,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'founded': founded,
      'members': members,
      'states': states,
      'features': features,
      'benefits': benefits,
    };
  }

  /// Get rating as double for sorting
  double get ratingValue {
    try {
      return double.parse(rating);
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if company has a specific specialty
  bool hasSpecialty(String specialty) {
    if (specialty == 'all') return true;
    return specialties
        .any((s) => s.toLowerCase().contains(specialty.toLowerCase()));
  }

  /// Get display-ready image URL with fallback
  String? get displayImageUrl {
    if (imageUrl.isEmpty) return null;

    // Handle relative URLs by prepending base URL if needed
    if (imageUrl.startsWith('/')) {
      return 'http://10.0.2.2:8000$imageUrl'; // Adjust base URL as needed
    }

    return imageUrl;
  }

  /// Get formatted phone number
  String get formattedPhone {
    if (phone.isEmpty) return 'Contact Available';
    return phone;
  }

  /// Get primary specialties (first 2) for display
  List<String> get primarySpecialties {
    return specialties.take(2).toList();
  }

  /// Check if has more specialties beyond primary
  bool get hasMoreSpecialties {
    return specialties.length > 2;
  }

  /// Get count of additional specialties
  int get additionalSpecialtiesCount {
    return specialties.length > 2 ? specialties.length - 2 : 0;
  }
}

class CompanyList {
  final int currentPage;
  final List<CompanyModel> data;
  final int? totalPages;
  final int? totalItems;
  final int? perPage;

  CompanyList({
    required this.currentPage,
    required this.data,
    this.totalPages,
    this.totalItems,
    this.perPage,
  });

  factory CompanyList.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? {};

    return CompanyList(
      currentPage: dataJson['current_page'] ?? 1,
      totalPages: dataJson['last_page'],
      totalItems: dataJson['total'],
      perPage: dataJson['per_page'],
      data: (dataJson['data'] as List<dynamic>? ?? [])
          .map((item) => CompanyModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((item) => item.toJson()).toList(),
      if (totalPages != null) 'last_page': totalPages,
      if (totalItems != null) 'total': totalItems,
      if (perPage != null) 'per_page': perPage,
    };
  }

  bool get hasNextPage => totalPages != null && currentPage < totalPages!;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;

  /// Filter companies by specialty
  List<CompanyModel> filterBySpecialty(String specialty) {
    if (specialty == 'all') return data;
    return data.where((company) => company.hasSpecialty(specialty)).toList();
  }

  /// Sort companies by different criteria
  List<CompanyModel> sortBy(String sortBy) {
    final sortedData = List<CompanyModel>.from(data);

    switch (sortBy) {
      case 'rating':
        sortedData.sort((a, b) => b.ratingValue.compareTo(a.ratingValue));
        break;
      case 'name':
        sortedData.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        // Keep original order
        break;
    }

    return sortedData;
  }
}
