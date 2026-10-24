import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../data/seed.dart';
import '../logic/muscle_strength.dart';
import '../logic/program_generator.dart';
import '../logic/working_sets.dart';
import '../providers.dart';
import '../ui/theme.dart';
import 'workout_screen.dart';
import 'exercise_picker_screen.dart';
import 'program_exercise_picker_screen.dart';

Map<String, dynamic> _programToMap(GeneratedProgram program) => {
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

GeneratedProgram _programFromMap(Map<String, dynamic> json) {
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

class ProgramGeneratorScreen extends ConsumerStatefulWidget {
  const ProgramGeneratorScreen({super.key});

  @override
  ConsumerState<ProgramGeneratorScreen> createState() =>
      _ProgramGeneratorScreenState();
}

class _ProgramGeneratorScreenState
    extends ConsumerState<ProgramGeneratorScreen> {
  ProgramGoal _goal = ProgramGoal.hypertrophy;
  TrainingLevel _level = TrainingLevel.beginner;
  int _days = 3;
  int _minutes = 60;
  bool _autoPrioritize = true;
  bool _loadingSettings = true;
  bool _generating = false;
  Set<String> _excludedMuscles = {};
  Set<String> _priorityMuscles = {};
  Set<int> _excludedExerciseIds = {};
  Set<int> _priorityExerciseIds = {};
  Set<int> _completedDays = {};
  bool _editingProgram = true;
  Set<String> _equipment = {'barbell', 'dumbbell', 'machine', 'bodyweight'};
  GeneratedProgram? _program;
  String? _error;

  static const _equipmentLabels = <String, String>{
    'barbell': 'Штанга',
    'dumbbell': 'Гантели',
    'machine': 'Тренажёры',
    'bodyweight': 'Свой вес',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _goal = ProgramGoal.values.firstWhere(
        (value) => value.name == prefs.getString('programGoal'),
        orElse: () => ProgramGoal.hypertrophy,
      );
      _level = TrainingLevel.values.firstWhere(
        (value) => value.name == prefs.getString('programLevel'),
        orElse: () => TrainingLevel.beginner,
      );
      _days = (prefs.getInt('programDays') ?? 3).clamp(2, 6).toInt();
      _minutes = (prefs.getInt('programMinutes') ?? 60).clamp(30, 90).toInt();
      _autoPrioritize = prefs.getBool('programAutoPrioritize') ?? true;
      _excludedMuscles = (prefs.getStringList('programExcludedMuscles') ?? [])
          .toSet();
      _priorityMuscles = (prefs.getStringList('programPriorityMuscles') ?? [])
          .toSet();
      _excludedExerciseIds =
          (prefs.getStringList('programExcludedExercises') ?? [])
              .map(int.tryParse)
              .whereType<int>()
              .toSet();
      _priorityExerciseIds =
          (prefs.getStringList('programPriorityExercises') ?? [])
              .map(int.tryParse)
              .whereType<int>()
              .toSet();
      _completedDays = (prefs.getStringList('programCompletedDays') ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();
      final savedProgram = prefs.getString('savedTrainingProgram');
      if (savedProgram != null) {
        try {
          _program = _programFromMap(
            jsonDecode(savedProgram) as Map<String, dynamic>,
          );
          _editingProgram = false;
        } catch (_) {
          _program = null;
          _editingProgram = true;
        }
      }
      _equipment =
          (prefs.getStringList('programEquipment') ??
                  ['barbell', 'dumbbell', 'machine', 'bodyweight'])
              .toSet();
      _loadingSettings = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('programGoal', _goal.name);
    await prefs.setString('programLevel', _level.name);
    await prefs.setInt('programDays', _days);
    await prefs.setInt('programMinutes', _minutes);
    await prefs.setBool('programAutoPrioritize', _autoPrioritize);
    await prefs.setStringList(
      'programExcludedMuscles',
      _excludedMuscles.toList(),
    );
    await prefs.setStringList(
      'programPriorityMuscles',
      _priorityMuscles.toList(),
    );
    await prefs.setStringList(
      'programExcludedExercises',
      _excludedExerciseIds.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList(
      'programPriorityExercises',
      _priorityExerciseIds.map((id) => id.toString()).toList(),
    );
    await prefs.setStringList('programEquipment', _equipment.toList());
  }

  double _credit(double share) {
    if (share >= 0.45) return 1;
    if (share >= 0.20) return 0.5;
    if (share >= 0.10) return 0.25;
    return 0;
  }

  Future<void> _generate(List<Exercise> exercises) async {
    setState(() {
      _generating = true;
      _error = null;
    });

    try {
      final db = ref.read(dbProvider);
      final links = await db.exerciseMuscleLinks();
      final byExercise = <int, List<MuscleLink>>{};
      for (final link in links) {
        (byExercise[link.exerciseId] ??= []).add(link);
      }

      // Use completed workout history from the last six weeks. It is a measure
      // of recent stimulus, not a claim that the muscle is medically weak.
      final histories = await Future.wait(
        exercises.map((exercise) => db.exerciseHistory(exercise.id)),
      );
      final cutoff = DateTime.now().subtract(const Duration(days: 42));
      final recentWeeklySets = <String, double>{};
      final exercisesWithHistory = <int>{};
      for (var i = 0; i < exercises.length; i++) {
        final exercise = exercises[i];
        final sessions = histories[i];
        if (sessions.isNotEmpty) exercisesWithHistory.add(exercise.id);
        final recentSessions = sessions.where((s) => !s.date.isBefore(cutoff));
        final recentSetCount = recentSessions.fold<int>(
          0,
          (sum, session) => sum + session.sets.length,
        );
        if (recentSetCount == 0) continue;
        for (final link in byExercise[exercise.id] ?? const <MuscleLink>[]) {
          recentWeeklySets[link.muscle] =
              (recentWeeklySets[link.muscle] ?? 0) +
              recentSetCount * _credit(link.share) / 6;
        }
      }

      final workingSets = await loadWorkingSets(db);
      final prefs = await SharedPreferences.getInstance();
      final bodyWeight = prefs.getDouble('bodyWeight') ?? 80;
      final isMale = prefs.getBool('isMale') ?? true;
      final favoriteExerciseIds =
          (prefs.getStringList('favoriteExerciseIds') ?? [])
              .map(int.tryParse)
              .whereType<int>()
              .toSet();
      final scores = muscleScores(
        sets: workingSets,
        links: links,
        bodyWeight: bodyWeight,
        isMale: isMale,
      );
      final strengthScores = <String, double>{
        for (final entry in scores.entries)
          if (entry.value.sources.isNotEmpty)
            entry.key: entry.value.score.clamp(0.0, 1.0).toDouble(),
      };

      final generated = generateProgram(
        exercises: exercises,
        links: links,
        options: ProgramOptions(
          goal: _goal,
          level: _level,
          daysPerWeek: _days,
          sessionMinutes: _minutes,
          excludedMuscles: Set<String>.from(_excludedMuscles),
          priorityMuscles: Set<String>.from(_priorityMuscles),
          excludedExerciseIds: Set<int>.from(_excludedExerciseIds),
          priorityExerciseIds: {
            ..._priorityExerciseIds,
            ...favoriteExerciseIds,
          },
          equipment: Set<String>.from(_equipment),
          autoPrioritize: _autoPrioritize,
        ),
        recentWeeklySets: recentWeeklySets,
        strengthScores: strengthScores,
        exercisesWithHistory: exercisesWithHistory,
      );
      await _saveSettings();
      if (generated.days.isEmpty) {
        if (mounted) setState(() => _error = generated.warnings.join('\n'));
        return;
      }
      final programPrefs = await SharedPreferences.getInstance();
      await programPrefs.setString(
        'savedTrainingProgram',
        jsonEncode(_programToMap(generated)),
      );
      await programPrefs.setStringList('programCompletedDays', <String>[]);
      if (!mounted) return;
      setState(() {
        _program = generated;
        _completedDays.clear();
        _editingProgram = false;
      });
    } catch (error) {
      if (mounted)
        setState(() => _error = 'Не удалось собрать программу: $error');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _pickExercisePreferences(List<Exercise> exercises) async {
    final result = await Navigator.push<Map<String, List<int>>>(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramExercisePickerScreen(
          excludedIds: _excludedExerciseIds,
          priorityIds: _priorityExerciseIds,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _excludedExerciseIds = (result['excluded'] ?? <int>[]).toSet();
      _priorityExerciseIds = (result['priority'] ?? <int>[]).toSet();
    });
    await _saveSettings();
  }

  Future<void> _replaceExercise(
    int dayIndex,
    int exerciseIndex,
    List<Exercise> allExercises,
  ) async {
    final program = _program;
    if (program == null) return;
    final current = program.days[dayIndex].exercises[exerciseIndex];
    final db = ref.read(dbProvider);
    final links = await db.exerciseMuscleLinks();
    final byExercise = <int, List<MuscleLink>>{};
    for (final link in links) {
      (byExercise[link.exerciseId] ??= []).add(link);
    }
    final replacementPrefs = await SharedPreferences.getInstance();
    final favorites =
        (replacementPrefs.getStringList('favoriteExerciseIds') ?? [])
            .map(int.tryParse)
            .whereType<int>()
            .toSet();

    final candidates = allExercises.where((exercise) {
      if (exercise.id == current.exerciseId ||
          _excludedExerciseIds.contains(exercise.id) ||
          !_equipment.contains(exercise.equipment))
        return false;
      final muscleLinks = byExercise[exercise.id] ?? const <MuscleLink>[];
      if (muscleLinks.any(
        (link) => _excludedMuscles.contains(link.muscle) && link.share >= 0.20,
      )) {
        return false;
      }
      return muscleLinks.any(
        (link) => link.muscle == current.focus && link.share >= 0.10,
      );
    }).toList();

    final history = <int>{};
    for (final exercise in candidates) {
      final sessions = await db.exerciseHistory(exercise.id);
      if (sessions.isNotEmpty) history.add(exercise.id);
    }
    candidates.sort((a, b) {
      double score(Exercise exercise) {
        final share = (byExercise[exercise.id] ?? const <MuscleLink>[])
            .where((link) => link.muscle == current.focus)
            .fold<double>(0, (sum, link) => sum + link.share);
        return share * 3 +
            (history.contains(exercise.id) ? 1.0 : 0.0) +
            (favorites.contains(exercise.id) ? 1.5 : 0.0);
      }

      return score(b).compareTo(score(a));
    });

    final selectedId = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Подходящие замены'),
        content: SizedBox(
          width: double.maxFinite,
          child: candidates.isEmpty
              ? const Text(
                  'Нет подходящих замен для этой группы мышц. Можно выбрать другое упражнение вручную.',
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: candidates.length > 7 ? 7 : candidates.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final exercise = candidates[index];
                    final tags = <String>[];
                    if (favorites.contains(exercise.id)) tags.add('Избранное');
                    if (history.contains(exercise.id)) tags.add('Уже выполнял');
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(exercise.name),
                      subtitle: Text(
                        tags.isEmpty ? exercise.equipment : tags.join(' · '),
                      ),
                      onTap: () => Navigator.pop(dialogContext, exercise.id),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, -1),
            child: const Text('Все упражнения'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );

    int? replacementId = selectedId;
    if (selectedId == -1) {
      replacementId = await Navigator.push<int>(
        context,
        MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
      );
    }
    if (replacementId == null || !mounted) return;
    Exercise? replacement;
    for (final exercise in allExercises) {
      if (exercise.id == replacementId) {
        replacement = exercise;
        break;
      }
    }
    if (replacement == null) return;

    final updatedDays = <ProgramDay>[];
    for (var d = 0; d < program.days.length; d++) {
      final oldDay = program.days[d];
      final updatedExercises = List<PrescribedExercise>.from(oldDay.exercises);
      if (d == dayIndex) {
        updatedExercises[exerciseIndex] = PrescribedExercise(
          exerciseId: replacement.id,
          name: replacement.name,
          equipment: replacement.equipment,
          focus: current.focus,
          sets: current.sets,
          repMin: current.repMin,
          repMax: current.repMax,
          restSeconds: current.restSeconds,
          reason: 'Замена: подобрано по целевой группе, истории и избранному',
        );
      }
      updatedDays.add(
        ProgramDay(title: oldDay.title, exercises: updatedExercises),
      );
    }
    final updatedProgram = GeneratedProgram(
      options: program.options,
      days: updatedDays,
      priorities: program.priorities,
      warnings: program.warnings,
      plannedWeeklySets: program.plannedWeeklySets,
    );
    final updatedPrefs = await SharedPreferences.getInstance();
    await updatedPrefs.setString(
      'savedTrainingProgram',
      jsonEncode(_programToMap(updatedProgram)),
    );
    if (!mounted) return;
    setState(() => _program = updatedProgram);
  }

  Future<void> _startDay(ProgramDay day, int dayIndex) async {
    if (day.exercises.isEmpty) return;
    final db = ref.read(dbProvider);
    final workoutId = await db.startWorkout();
    for (final exercise in day.exercises) {
      await db.addExerciseToWorkout(workoutId, exercise.exerciseId);
    }

    // Store the prescription separately so it does not require a database
    // migration. WorkoutScreen can read this and show set/rep targets.
    final prefs = await SharedPreferences.getInstance();
    final prescription = <String, dynamic>{
      'title': day.title,
      'programDayIndex': dayIndex,
      'exercises': {
        for (final exercise in day.exercises)
          exercise.exerciseId.toString(): {
            'sets': exercise.sets,
            'repMin': exercise.repMin,
            'repMax': exercise.repMax,
            'restSeconds': exercise.restSeconds,
            'focus': exercise.focus,
          },
      },
    };
    await prefs.setString(
      'workoutPrescription_$workoutId',
      _encodeJson(prescription),
    );
    await prefs.setInt('programDayIndex_$workoutId', dayIndex);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutScreen(workoutId: workoutId)),
    );
    final updatedPrefs = await SharedPreferences.getInstance();
    final missedFocuses =
        (updatedPrefs.getStringList('programUnderperforming_$workoutId') ??
                <String>[])
            .toSet();
    final currentProgram = _program;
    if (currentProgram != null && missedFocuses.isNotEmpty) {
      // Recovery-first adjustment: do not transfer missed sets to the next day.
      // Reduce the next exposure for affected muscles by one set (minimum two),
      // then continue the schedule normally.
      final adjustedDays = <ProgramDay>[];
      for (var i = 0; i < currentProgram.days.length; i++) {
        final dayItem = currentProgram.days[i];
        final exercises = <PrescribedExercise>[];
        for (final exercise in dayItem.exercises) {
          final shouldAdjust =
              i > dayIndex && missedFocuses.contains(exercise.focus);
          exercises.add(
            PrescribedExercise(
              exerciseId: exercise.exerciseId,
              name: exercise.name,
              equipment: exercise.equipment,
              focus: exercise.focus,
              sets: shouldAdjust
                  ? (exercise.sets - 1).clamp(2, exercise.sets).toInt()
                  : exercise.sets,
              repMin: exercise.repMin,
              repMax: exercise.repMax,
              restSeconds: exercise.restSeconds,
              reason: shouldAdjust
                  ? 'Объём временно снижен для восстановления после незавершённой тренировки'
                  : exercise.reason,
            ),
          );
        }
        adjustedDays.add(
          ProgramDay(title: dayItem.title, exercises: exercises),
        );
      }
      final adjustedProgram = GeneratedProgram(
        options: currentProgram.options,
        days: adjustedDays,
        priorities: currentProgram.priorities,
        warnings: [
          ...currentProgram.warnings,
          'После незавершённой тренировки объём затронутых групп снижен на следующем занятии. Пропущенные подходы не переносятся на один день.',
        ],
        plannedWeeklySets: currentProgram.plannedWeeklySets,
      );
      await updatedPrefs.setString(
        'savedTrainingProgram',
        jsonEncode(_programToMap(adjustedProgram)),
      );
      await updatedPrefs.remove('programUnderperforming_$workoutId');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Тренировка выполнена не полностью: объём на следующем занятии скорректирован без добавления пропущенных подходов.',
            ),
          ),
        );
      }
      if (mounted) setState(() => _program = adjustedProgram);
    }
    if (!mounted) return;
    setState(() {
      _completedDays =
          (updatedPrefs.getStringList('programCompletedDays') ?? [])
              .map(int.tryParse)
              .whereType<int>()
              .toSet();
    });
  }

  String _encodeJson(Object value) => jsonEncode(value);

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);
    if (_loadingSettings) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Генератор программы')),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Не удалось загрузить упражнения: $error')),
        data: (exercises) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: _program != null && !_editingProgram
              ? _savedProgramChildren(exercises)
              : [
                  _introCard(),
                  const SizedBox(height: 16),
                  _sectionTitle('Цель'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final goal in ProgramGoal.values)
                        ChoiceChip(
                          label: Text(goalLabel(goal)),
                          selected: _goal == goal,
                          onSelected: (_) => setState(() => _goal = goal),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Опыт тренировок'),
                  DropdownButtonFormField<TrainingLevel>(
                    value: _level,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final level in TrainingLevel.values)
                        DropdownMenuItem(
                          value: level,
                          child: Text(levelLabel(level)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _level = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Тренировок в неделю: $_days'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var day = 2; day <= 6; day++)
                        ChoiceChip(
                          label: Text('$day'),
                          selected: _days == day,
                          onSelected: (_) => setState(() => _days = day),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Время на тренировку: $_minutes мин'),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final minutes in [30, 45, 60, 75, 90])
                        ChoiceChip(
                          label: Text('$minutes мин'),
                          selected: _minutes == minutes,
                          onSelected: (_) => setState(() => _minutes = minutes),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Доступное оборудование'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in _equipmentLabels.entries)
                        FilterChip(
                          label: Text(entry.value),
                          selected: _equipment.contains(entry.key),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _equipment.add(entry.key);
                            } else if (_equipment.length > 1) {
                              _equipment.remove(entry.key);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Группы, которые не хочешь тренировать'),
                  const Text(
                    'Упражнения, заметно нагружающие эти мышцы, будут исключены. Это может снизить общий баланс программы.',
                    style: TextStyle(color: Pal.dim, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final muscle in muscleNames)
                        FilterChip(
                          label: Text(muscle),
                          selected: _excludedMuscles.contains(muscle),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _excludedMuscles.add(muscle);
                              _priorityMuscles.remove(muscle);
                            } else {
                              _excludedMuscles.remove(muscle);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Приоритетные группы (необязательно)'),
                  const Text(
                    'Выбери до трёх групп. Генератор добавит им немного больший недельный объём.',
                    style: TextStyle(color: Pal.dim, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final muscle in muscleNames.where(
                        (m) => !_excludedMuscles.contains(m),
                      ))
                        FilterChip(
                          label: Text(muscle),
                          selected: _priorityMuscles.contains(muscle),
                          onSelected: (selected) => setState(() {
                            if (selected && _priorityMuscles.length < 3) {
                              _priorityMuscles.add(muscle);
                            } else if (!selected) {
                              _priorityMuscles.remove(muscle);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Автоматически находить отстающие группы',
                    ),
                    subtitle: const Text(
                      'По объёму последних 6 недель и доступным оценкам силы',
                    ),
                    value: _autoPrioritize,
                    onChanged: (value) =>
                        setState(() => _autoPrioritize = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickExercisePreferences(exercises),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(
                      'Упражнения: исключить ${_excludedExerciseIds.length} · упор ${_priorityExerciseIds.length}',
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _generating ? null : () => _generate(exercises),
                    icon: _generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      _generating
                          ? 'Анализирую историю…'
                          : 'Сгенерировать программу',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Pal.hot)),
                  ],
                ],
        ),
      ),
    );
  }

  List<Widget> _savedProgramChildren(List<Exercise> exercises) {
    final program = _program!;
    final completed = _completedDays.length;
    return [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Твоя программа',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'Изменить программу',
            onPressed: () => setState(() => _editingProgram = true),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      Text(
        '${goalLabel(program.options.goal)} · ${program.options.daysPerWeek} тренировок в неделю · ${program.options.sessionMinutes} мин',
        style: const TextStyle(color: Pal.dim, fontSize: 12),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Pal.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Pal.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Pal.ice),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Выполнено тренировок: $completed из ${program.days.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      if (program.priorities.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          'Приоритет: ${program.priorities.join(', ')}',
          style: const TextStyle(color: Pal.ice, fontWeight: FontWeight.w700),
        ),
      ],
      const SizedBox(height: 14),
      for (var i = 0; i < program.days.length; i++)
        _dayCard(program.days[i], i, exercises),
      if (program.warnings.isNotEmpty) ...[
        const SizedBox(height: 8),
        for (final warning in program.warnings)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: Pal.dim,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: const TextStyle(color: Pal.dim, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
      const SizedBox(height: 12),
      _progressionCard(),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('savedTrainingProgram');
          await prefs.setStringList('programCompletedDays', <String>[]);
          if (!mounted) return;
          setState(() {
            _program = null;
            _completedDays.clear();
            _editingProgram = true;
          });
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Создать новую программу'),
      ),
    ];
  }

  Widget _dayCard(ProgramDay day, int dayIndex, List<Exercise> allExercises) {
    final isCompleted = _completedDays.contains(dayIndex);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? const Color(0xFF49D18D) : Pal.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF49D18D),
                  size: 20,
                ),
              const SizedBox(width: 6),
              Text(
                '${day.exercises.length} упражн.',
                style: const TextStyle(color: Pal.dim, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < day.exercises.length; i++) ...[
            if (i > 0) const Divider(color: Pal.line, height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Pal.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Pal.ice,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.exercises[i].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.exercises[i].sets} × ${day.exercises[i].repMin}–${day.exercises[i].repMax} · отдых ${day.exercises[i].restSeconds} сек',
                        style: const TextStyle(
                          color: Pal.ice,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${day.exercises[i].focus} · ${day.exercises[i].reason}',
                        style: const TextStyle(color: Pal.dim, fontSize: 11),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              _replaceExercise(dayIndex, i, allExercises),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                          label: const Text('Не знаю как делать · заменить'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isCompleted ? null : () => _startDay(day, dayIndex),
              icon: Icon(
                isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(
                isCompleted ? 'Тренировка выполнена' : 'Начать эту тренировку',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Pal.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Pal.line),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.tune_rounded, color: Pal.ice, size: 25),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Программа под тебя',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 5),
              Text(
                'Учитываются ограничения, оборудование, история тренировок и приоритетные мышцы. Программа остаётся повторяемой, чтобы можно было отслеживать прогресс.',
                style: TextStyle(color: Pal.dim, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
  );

  Widget _progressionCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Pal.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Pal.line),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Как прогрессировать',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          '• Большинство подходов заканчивай с запасом примерно 1–3 повтора, не обязательно до отказа.',
          style: TextStyle(color: Pal.dim, fontSize: 12, height: 1.4),
        ),
        SizedBox(height: 5),
        Text(
          '• Когда выполнишь верхнюю границу повторов во всех рабочих подходах с хорошей техникой на двух тренировках подряд, прибавь небольшой вес: обычно 2–5% для верха тела и 5–10% для низа.',
          style: TextStyle(color: Pal.dim, fontSize: 12, height: 1.4),
        ),
        SizedBox(height: 5),
        Text(
          '• Если техника ломается, появляется боль или результат резко падает, не повышай нагрузку; уменьши вес или останови упражнение.',
          style: TextStyle(color: Pal.dim, fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}
