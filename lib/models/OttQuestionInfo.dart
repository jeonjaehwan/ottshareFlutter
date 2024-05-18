class OttQuestionInfo {
  final int questionId; // Dart에서는 int 타입을 사용합니다.
  final String firstQuestion;
  final String secondQuestion;
  final String firstQuestionOttType;
  final String secondQuestionOttType;


  OttQuestionInfo({
    required this.questionId,
    required this.firstQuestion,
    required this.secondQuestion,
    required this.firstQuestionOttType,
    required this.secondQuestionOttType,
  });

  factory OttQuestionInfo.fromJson(Map<String, dynamic> json) {
    return OttQuestionInfo(
      questionId: json['id'] as int? ?? 0, // Long 대신 int를 사용하고, 기본값을 제공합니다.
      firstQuestion: json['firstQuestion'] as String? ?? '', // 기본값으로 빈 문자열 제공
      secondQuestion: json['secondQuestion'] as String? ?? '',
      firstQuestionOttType: json['firstQuestionOttType'] as String? ?? '',
      secondQuestionOttType: json['secondQuestionOttType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': questionId,
      'firstQuestion': firstQuestion,
      'secondQuestion': secondQuestion,
      'firstQuestionOttType': firstQuestionOttType,
      'secondQuestionOttType': secondQuestionOttType,
    };
  }

}