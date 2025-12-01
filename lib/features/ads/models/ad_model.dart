class AdModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? targetUrl;
  final String buttonText;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.targetUrl,
    required this.buttonText,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      targetUrl: json['target_url'] as String?,
      buttonText: json['button_text'] as String? ?? 'Learn More',
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'target_url': targetUrl,
      'button_text': buttonText,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if the ad is currently active and not expired
  bool get isCurrentlyActive {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    return true;
  }

  /// Get display-ready image URL with fallback
  String? get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    // Handle relative URLs by prepending base URL if needed
    if (imageUrl!.startsWith('/')) {
      return 'http://10.0.2.2:8000$imageUrl'; // Adjust base URL as needed
    }

    return imageUrl;
  }

  /// Get safe button text with fallback
  String get safeButtonText {
    if (buttonText.isEmpty) return 'Learn More';
    return buttonText;
  }

  /// Check if ad has valid content to display
  bool get hasValidContent {
    return title.isNotEmpty && description.isNotEmpty;
  }
}

class AdList {
  final int currentPage;
  final List<AdModel> data;
  final int? totalPages;
  final int? totalItems;
  final int? perPage;

  AdList({
    required this.currentPage,
    required this.data,
    this.totalPages,
    this.totalItems,
    this.perPage,
  });

  factory AdList.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? {};

    return AdList(
      currentPage: dataJson['current_page'] ?? 1,
      totalPages: dataJson['last_page'],
      totalItems: dataJson['total'],
      perPage: dataJson['per_page'],
      data: (dataJson['data'] as List<dynamic>? ?? [])
          .map((item) => AdModel.fromJson(item))
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

  /// Get only currently active and valid ads
  List<AdModel> get activeAds {
    return data
        .where((ad) => ad.isCurrentlyActive && ad.hasValidContent)
        .toList();
  }
}
