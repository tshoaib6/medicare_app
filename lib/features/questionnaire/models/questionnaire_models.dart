class QuestionOption {
  final int id;
  final int questionId;
  final String label;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionOption({
    required this.id,
    required this.questionId,
    required this.label,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'label': label,
      'value': value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Question {
  final int id;
  final int questionnaireId;
  final String questionText;
  final String questionType; // 'single_choice', 'multiple_choice', 'text', etc.
  final bool isRequired;
  final int orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.questionnaireId,
    required this.questionText,
    required this.questionType,
    required this.isRequired,
    required this.orderNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      questionnaireId: json['questionnaire_id'] as int,
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'single_choice',
      isRequired: json['is_required'] ?? false,
      orderNumber: json['order_number'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => QuestionOption.fromJson(option))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionnaire_id': questionnaireId,
      'question_text': questionText,
      'question_type': questionType,
      'is_required': isRequired,
      'order_number': orderNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}

class Questionnaire {
  final int id;
  final String title;
  final String description;
  final int planId;
  final String instructions;
  final int estimatedTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Question> questions;

  Questionnaire({
    required this.id,
    required this.title,
    required this.description,
    required this.planId,
    required this.instructions,
    required this.estimatedTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.questions,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      id: json['id'] as int,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      planId: json['plan_id'] as int,
      instructions: json['instructions'] ?? '',
      estimatedTime: json['estimated_time'] ?? 0,
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((question) => Question.fromJson(question))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'plan_id': planId,
      'instructions': instructions,
      'estimated_time': estimatedTime,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}
