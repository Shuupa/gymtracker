import '../logic/program_generator.dart';

/// Сериализация программы в JSON-совместимую Map (для SharedPreferences).
Map<String, dynamic> programToMap(GeneratedProgram program) => {
  'options': {
    'goal': program.options.goal.name,
    'level': program.options.level.name,
    'daysPerWeek': program.options.daysPerWeek,
    'sessionMinutes': program.options.sessionMinutes,
    'excludedMuscles': program.options.excludedMuscles.toList(),
    'priorityMuscles': program.options.priorityMuscles.toList(),
    'excludedExerciseIds': program.options.excludedExerciseIds.toList(),
    'priorityExerciseIds': program.options.priorityExerciseIds.toList(),
    'equipment': program.options.equipment.toList(),
    'autoPrioritize': program.options.autoPrioritize,
  },
  'days': [
    for (final day in program.days)
      {
        'title': day.title,
        'exercises': [
          for (final e in day.exercises)
            {
              'exerciseId': e.exerciseId,
              'name': e.name,
              'equipment': e.equipment,
              'focus': e.focus,
              'sets': e.sets,
              'repMin': e.repMin,
              'repMax': e.repMax,
              'restSeconds': e.restSeconds,
              'reason': e.reason,
            },
        ],
      },
  ],
  'priorities': program.priorities,
  'warnings': program.warnings,
  'plannedWeeklySets': program.plannedWeeklySets,
};

GeneratedProgram programFromMap(Map<String, dynamic> json) {
  final o = Map<String, dynamic>.from(json['options'] as Map);
  final days = (json['days'] as List<dynamic>? ?? []).map((rawDay) {
    final day = Map<String, dynamic>.from(rawDay as Map);
    final exercises = (day['exercises'] as List<dynamic>? ?? []).map((raw) {
      final e = Map<String, dynamic>.from(raw as Map);
      return PrescribedExercise(
        exerciseId: e['exerciseId'] as int,
        name: e['name'] as String,
        equipment: e['equipment'] as String,
        focus: e['focus'] as String,
        sets: e['sets'] as int,
        repMin: e['repMin'] as int,
        repMax: e['repMax'] as int,
        restSeconds: e['restSeconds'] as int,
        reason: e['reason'] as String? ?? '',
      );
    }).toList();
    return ProgramDay(title: day['title'] as String, exercises: exercises);
  }).toList();
  return GeneratedProgram(
    options: ProgramOptions(
      goal: ProgramGoal.values.firstWhere(
        (v) => v.name == o['goal'],
        orElse: () => ProgramGoal.hypertrophy,
      ),
      level: TrainingLevel.values.firstWhere(
        (v) => v.name == o['level'],
        orElse: () => TrainingLevel.beginner,
      ),
      daysPerWeek: o['daysPerWeek'] as int? ?? 3,
      sessionMinutes: o['sessionMinutes'] as int? ?? 60,
      excludedMuscles: (o['excludedMuscles'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      priorityMuscles: (o['priorityMuscles'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      excludedExerciseIds: (o['excludedExerciseIds'] as List<dynamic>? ?? [])
          .cast<int>()
          .toSet(),
      priorityExerciseIds: (o['priorityExerciseIds'] as List<dynamic>? ?? [])
          .cast<int>()
          .toSet(),
      equipment: (o['equipment'] as List<dynamic>? ?? [])
          .cast<String>()
          .toSet(),
      autoPrioritize: o['autoPrioritize'] as bool? ?? true,
    ),
    days: days,
    priorities: (json['priorities'] as List<dynamic>? ?? []).cast<String>(),
    warnings: (json['warnings'] as List<dynamic>? ?? []).cast<String>(),
    plannedWeeklySets: (json['plannedWeeklySets'] as Map? ?? {}).map(
      (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
    ),
  );
}
