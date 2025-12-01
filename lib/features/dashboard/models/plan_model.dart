class PlanModel {
  final int id;
  final String slug;
  final String title;
  final String description;
  final int companyId;
  final List<String> benefits;
  final String eligibilityCriteria;
  final String coverageDetails;
  final String pricingInfo;
  final String enrollmentPeriod;
  final String contactInfo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CompanyModel? company;

  PlanModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.companyId,
    required this.benefits,
    required this.eligibilityCriteria,
    required this.coverageDetails,
    required this.pricingInfo,
    required this.enrollmentPeriod,
    required this.contactInfo,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.company,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as int,
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      companyId: json['company_id'] as int,
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
      eligibilityCriteria: json['eligibility_criteria'] ?? '',
      coverageDetails: json['coverage_details'] ?? '',
      pricingInfo: json['pricing_info'] ?? '',
      enrollmentPeriod: json['enrollment_period'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      isActive: json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      company: json['company'] != null
          ? CompanyModel.fromJson(json['company'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'description': description,
      'company_id': companyId,
      'benefits': benefits,
      'eligibility_criteria': eligibilityCriteria,
      'coverage_details': coverageDetails,
      'pricing_info': pricingInfo,
      'enrollment_period': enrollmentPeriod,
      'contact_info': contactInfo,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'company': company?.toJson(),
    };
  }
}

class CompanyModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String rating;
  final String phone;
  final List<String> specialties;
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      rating: json['rating']?.toString() ?? '0.0',
      phone: json['phone'] ?? '',
      specialties:
          (json['specialties'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
    };
  }
}
