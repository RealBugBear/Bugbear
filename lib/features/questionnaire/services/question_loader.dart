import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


import 'package:bugbear_app/features/questionnaire/models/question_item.dart';
import 'package:bugbear_app/features/questionnaire/models/questionnaire_state.dart';

import '../models/question_item.dart';
import '../models/questionnaire_state.dart';


class QuestionLoader {
  Future<List<QuestionItem>> load(QuestionnaireLanguage language) async {
    final path = language == QuestionnaireLanguage.en
        ? 'assets/quiz_questions_en.json'
        : 'assets/quiz_questions_de.json';
    final content = await rootBundle.loadString(path);
    final data = json.decode(content) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .where((e) => e.containsKey('id'))
        .map((e) {
          if (language == QuestionnaireLanguage.en) {
            return QuestionItem.fromJson({
              'id': e['id'],
              'reflexKeys': List<String>.from(e['reflex_keys'] ?? []),
              'reflexNames': List<String>.from(e['reflex_names'] ?? []),
              'text': e['question'] as String? ?? '',
              'example': e['example'] as String? ?? '',
              'sources': List<String>.from(e['sources'] ?? []),
            });
          } else {
            return QuestionItem.fromJson({
              'id': e['id'],
              'reflexKeys': List<String>.from(e['reflex_keys'] ?? []),
              'reflexNames': List<String>.from(e['reflex_names'] ?? []),
              'text': e['frage'] as String? ?? '',
              'example': e['beispiel'] as String? ?? '',
              'sources': List<String>.from(e['quellen'] ?? []),
            });
          }
        })
        .toList();
  }
}
