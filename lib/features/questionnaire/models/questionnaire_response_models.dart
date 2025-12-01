class QuestionnaireResponseAnswer {
  final int questionId;
  final List<dynamic>? answerValue;
  final String? answerText;

  QuestionnaireResponseAnswer({
    required this.questionId,
    this.answerValue,
    this.answerText,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer_value': answerValue,
      'answer_text': answerText,
    };
  }

  factory QuestionnaireResponseAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponseAnswer(
      questionId: json['question_id'] ?? 0,
      answerValue: json['answer_value'] != null
          ? List<dynamic>.from(json['answer_value'])
          : null,
      answerText: json['answer_text'],
    );
  }
}

class QuestionnaireResponsePlan {
  final int id;
  final String name;

  QuestionnaireResponsePlan({
    required this.id,
    required this.name,
  });

  factory QuestionnaireResponsePlan.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponsePlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class QuestionnaireResponseQuestionnaire {
  final int id;
  final String title;
  final QuestionnaireResponsePlan? plan;

  QuestionnaireResponseQuestionnaire({
    required this.id,
    required this.title,
    this.plan,
  });

  factory QuestionnaireResponseQuestionnaire.fromJson(
      Map<String, dynamic> json) {
    return QuestionnaireResponseQuestionnaire(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      plan: json['plan'] != null
          ? QuestionnaireResponsePlan.fromJson(json['plan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (plan != null) 'plan': plan!.toJson(),
    };
  }
}

class QuestionnaireResponse {
  final int id;
  final int userId;
  final int questionnaireId;
  final String status;
  final int completionPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? timeTaken;
  final QuestionnaireResponseQuestionnaire? questionnaire;

  QuestionnaireResponse({
    required this.id,
    required this.userId,
    required this.questionnaireId,
    required this.status,
    required this.completionPercentage,
    this.startedAt,
    this.completedAt,
    this.timeTaken,
    this.questionnaire,
  });

  factory QuestionnaireResponse.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResponse(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      questionnaireId: json['questionnaire_id'] ?? 0,
      status: json['status'] ?? 'unknown',
      completionPercentage: json['completion_percentage'] ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      timeTaken: json['time_taken'],
      questionnaire: json['questionnaire'] != null
          ? QuestionnaireResponseQuestionnaire.fromJson(json['questionnaire'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'questionnaire_id': questionnaireId,
      'status': status,
      'completion_percentage': completionPercentage,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'time_taken': timeTaken,
      if (questionnaire != null) 'questionnaire': questionnaire!.toJson(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isPending => status == 'pending';

  Duration? get duration {
    if (timeTaken != null) {
      return Duration(minutes: timeTaken!);
    }
    return null;
  }

  String get statusDisplay {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }
}

class QuestionnaireResponseList {
  final int currentPage;
  final List<QuestionnaireResponse> data;
  final int? totalPages;
  final int? totalItems;
  final int? perPage;

  QuestionnaireResponseList({
    required this.currentPage,
    required this.data,
    this.totalPages,
    this.totalItems,
    this.perPage,
  });

  factory QuestionnaireResponseList.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? {};

    return QuestionnaireResponseList(
      currentPage: dataJson['current_page'] ?? 1,
      totalPages: dataJson['last_page'],
      totalItems: dataJson['total'],
      perPage: dataJson['per_page'],
      data: (dataJson['data'] as List<dynamic>? ?? [])
          .map((item) => QuestionnaireResponse.fromJson(item))
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
}

class StartQuestionnaireRequest {
  final int questionnaireId;

  StartQuestionnaireRequest({
    required this.questionnaireId,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionnaire_id': questionnaireId,
    };
  }
}

class SubmitAnswersRequest {
  final int responseId;
  final List<QuestionnaireResponseAnswer> answers;

  SubmitAnswersRequest({
    required this.responseId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }
}

class CompleteQuestionnaireRequest {
  final int responseId;

  CompleteQuestionnaireRequest({
    required this.responseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'response_id': responseId,
    };
  }
}
