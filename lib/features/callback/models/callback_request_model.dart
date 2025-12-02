class CallbackRequestModel {
  final int id;
  final int? userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String preferredDate;
  final String preferredTime;
  final String timeZone;
  final String status;
  final String? message;
  final int? planId;
  final PlanInfo? plan;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CallbackRequestModel({
    required this.id,
    this.userId,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.preferredDate,
    required this.preferredTime,
    required this.timeZone,
    required this.status,
    this.message,
    this.planId,
    this.plan,
    required this.createdAt,
    this.updatedAt,
  });

  factory CallbackRequestModel.fromJson(Map<String, dynamic> json) {
    return CallbackRequestModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      preferredDate: json['preferred_date'] ?? '',
      preferredTime: json['preferred_time'] ?? '',
      timeZone: json['time_zone'] ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'],
      planId: json['plan_id'] as int?,
      plan: json['plan'] != null ? PlanInfo.fromJson(json['plan']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'time_zone': timeZone,
      'status': status,
      'message': message,
      'plan_id': planId,
      'plan': plan?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get formatted date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(preferredDate);
      return '${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return preferredDate;
    }
  }

  /// Get formatted time for display
  String get formattedTime {
    try {
      final timeParts = preferredTime.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = timeParts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (e) {
      return preferredTime;
    }
  }

  /// Get full formatted date and time
  String get fullDateTime {
    return '$formattedDate at $formattedTime ($timeZone)';
  }

  /// Check if callback is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if callback is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if callback is cancelled
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  String _getWeekday(int weekday) {
    const weekdays = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[weekday];
  }

  String _getMonth(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}

class PlanInfo {
  final int id;
  final String name;
  final CompanyInfo? company;

  PlanInfo({
    required this.id,
    required this.name,
    this.company,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) {
    return PlanInfo(
      id: json['id'] as int,
      name: json['name'] ?? '',
      company: json['company'] != null
          ? CompanyInfo.fromJson(json['company'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company?.toJson(),
    };
  }
}

class CompanyInfo {
  final String name;

  CompanyInfo({
    required this.name,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CallbackRequestResponse {
  final bool success;
  final CallbackRequestModel? data;
  final String message;
  final Map<String, List<String>>? errors;

  CallbackRequestResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory CallbackRequestResponse.fromJson(Map<String, dynamic> json) {
    return CallbackRequestResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? CallbackRequestModel.fromJson(json['data'])
          : null,
      message: json['message'] ?? '',
      errors: json['errors'] != null
          ? Map<String, List<String>>.from(json['errors']
              .map((key, value) => MapEntry(key, List<String>.from(value))))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'errors': errors,
    };
  }

  /// Check if request was successful
  bool get isSuccess => success;

  /// Get error messages as a single string
  String get errorMessage {
    if (errors == null || errors!.isEmpty) {
      return message;
    }

    return errors!.values.expand((list) => list).join('\n');
  }

  /// Check if there are validation errors
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
}
