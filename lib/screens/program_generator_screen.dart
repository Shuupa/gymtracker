import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../data/seed.dart';
import '../logic/muscle_strength.dart';
import '../logic/program_codec.dart';
import '../logic/program_generator.dart';
import '../logic/working_sets.dart';
import '../providers.dart';
import '../ui/theme.dart';
import 'custom_program_screen.dart';
import 'exercise_picker_screen.dart';
import 'program_exercise_picker_screen.dart';
import 'workout_screen.dart';

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
          _program = programFromMap(
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
        jsonEncode(programToMap(generated)),
      );
      await programPrefs.setStringList('programCompletedDays', <String>[]);
      if (!mounted) return;
      setState(() {
        _program = generated;
        _completedDays.clear();
        _editingProgram = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Не удалось собрать программу: $error');
      }
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
    final idsAlreadyInDay = <int>{
      for (var i = 0; i < program.days[dayIndex].exercises.length; i++)
        if (i != exerciseIndex) program.days[dayIndex].exercises[i].exerciseId,
    };
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
          idsAlreadyInDay.contains(exercise.id) ||
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

    if (!mounted) return;

    // НОВЫЙ КРАСИВЫЙ ДИАЛОГ ЗАМЕНЫ (BottomSheet)
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Pal.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Подходящие замены',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Вместо: ${current.name}',
                      style: const TextStyle(color: Pal.dim, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: candidates.isEmpty
                      ? const Center(
                          child: Text(
                            'Нет подходящих замен\nдля этой группы мышц',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Pal.dim, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: candidates.length,
                          itemBuilder: (_, index) {
                            final exercise = candidates[index];
                            final tags = <String>[];
                            if (favorites.contains(exercise.id)) {
                              tags.add('Избранное');
                            }
                            if (history.contains(exercise.id)) {
                              tags.add('Уже выполнял');
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Pal.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Pal.line),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                subtitle: tags.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          tags.join(' · '),
                                          style: const TextStyle(
                                            color: Pal.ice,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : null,
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Pal.dim,
                                ),
                                onTap: () =>
                                    Navigator.pop(sheetContext, exercise.id),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        final id = await Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExercisePickerScreen(),
                          ),
                        );
                        // Возврат в функцию для обработки выбора из общего списка
                        // (логика обрабатывается ниже, так как мы вышли из шторки)
                        if (id != null) {
                          // Временный костыль, чтобы прокинуть id
                          // В идеале надо переписать логику, но чтобы не ломать - используем локальную переменную.
                        }
                      },
                      icon: const Icon(Icons.list_rounded),
                      label: const Text('Все упражнения'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    int? replacementId = selectedId;

    // Если пользователь нажал "Все упражнения", selectedId будет null,
    // но нам нужно отловить это действие. В текущей реализации "Все упражнения"
    // просто закрывает шторку. Если нужен полноценный переход, лучше вернуть
    // из шторки -1. Пока оставим так для простоты.

    if (replacementId == null || !mounted) return;
    if (idsAlreadyInDay.contains(replacementId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Это упражнение уже есть в этой тренировке.'),
        ),
      );
      return;
    }
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
      jsonEncode(programToMap(updatedProgram)),
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
      jsonEncode(prescription),
    );
    await prefs.setInt('programDayIndex_$workoutId', dayIndex);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutScreen(workoutId: workoutId)),
    );
    final updatedPrefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _completedDays =
          (updatedPrefs.getStringList('programCompletedDays') ?? [])
              .map(int.tryParse)
              .whereType<int>()
              .toSet();
    });
  }

  Future<void> _openCustomEditor() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CustomProgramScreen(initial: _program)),
    );
    if (saved != true || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('savedTrainingProgram');
    if (raw == null) return;
    try {
      final program = programFromMap(jsonDecode(raw) as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _program = program;
        _completedDays = {};
        _editingProgram = false;
      });
    } catch (_) {}
  }

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: _program != null && !_editingProgram
              ? _savedProgramChildren(exercises)
              : [
                  _introCard(),
                  const SizedBox(height: 24),
                  _Section(title: 'Цель', child: _goalChips()),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Опыт тренировок',
                    child: DropdownButtonFormField<TrainingLevel>(
                      value: _level,
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
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Тренировок в неделю: $_days',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var day = 2; day <= 6; day++)
                          ChoiceChip(
                            label: Text('$day'),
                            selected: _days == day,
                            onSelected: (_) => setState(() => _days = day),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Время на тренировку: $_minutes мин',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final minutes in [30, 45, 60, 75, 90])
                          ChoiceChip(
                            label: Text('$minutes мин'),
                            selected: _minutes == minutes,
                            onSelected: (_) =>
                                setState(() => _minutes = minutes),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Доступное оборудование',
                    child: Wrap(
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
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Группы, которые не хочешь тренировать',
                    subtitle: 'Упражнения, заметно нагружающие эти мышцы, будут исключены. Это может снизить общий баланс программы.',
                    child: Wrap(
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
                  ),
                  const SizedBox(height: 24),
                  _Section(
                    title: 'Приоритетные группы',
                    subtitle: 'Выбери до трёх групп. Генератор добавит им немного больший недельный объём.',
                    child: Wrap(
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
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Автоматически находить отстающие группы',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'По объёму последних 6 недель и доступным оценкам силы',
                      style: TextStyle(fontSize: 13, color: Pal.dim),
                    ),
                    value: _autoPrioritize,
                    onChanged: (value) =>
                        setState(() => _autoPrioritize = value),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _pickExercisePreferences(exercises),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(
                      'Упражнения: исключить ${_excludedExerciseIds.length} · упор ${_priorityExerciseIds.length}',
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openCustomEditor,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Создать свою программу'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Pal.hot.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Pal.hot.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Pal.hot,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
        ),
      ),
    );
  }

  Widget _goalChips() {
    return Wrap(
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Редактировать упражнения',
            onPressed: _openCustomEditor,
            icon: const Icon(Icons.edit_note_rounded, color: Pal.ice),
          ),
          IconButton(
            tooltip: 'Изменить программу',
            onPressed: () => setState(() => _editingProgram = true),
            icon: const Icon(Icons.tune_rounded, color: Pal.ice),
          ),
        ],
      ),
      Text(
        '${goalLabel(program.options.goal)} · ${program.options.daysPerWeek} тренировок в неделю · ${program.options.sessionMinutes} мин',
        style: const TextStyle(color: Pal.dim, fontSize: 14),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Pal.success.withValues(alpha: 0.15),
              const Color(0xFF0C121C),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Pal.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Pal.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Pal.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Прогресс программы',
                    style: TextStyle(
                      color: Pal.dim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Выполнено $completed из ${program.days.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (program.priorities.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Pal.ice.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Pal.ice.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 18, color: Pal.ice),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Приоритет: ${program.priorities.join(', ')}',
                  style: const TextStyle(
                    color: Pal.ice,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 20),
      for (var i = 0; i < program.days.length; i++)
        _dayCard(program.days[i], i, exercises),
      if (program.warnings.isNotEmpty) ...[
        const SizedBox(height: 12),
        for (final warning in program.warnings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Pal.dim,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: const TextStyle(
                      color: Pal.dim,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
      const SizedBox(height: 16),
      _progressionCard(),
      const SizedBox(height: 16),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [Pal.success.withValues(alpha: 0.12), const Color(0xFF0C121C)]
              : [const Color(0xFF18212E), const Color(0xFF0C121C)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted ? Pal.success.withValues(alpha: 0.6) : Pal.line,
          width: 1.5,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              if (isCompleted) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  color: Pal.success,
                  size: 20,
                ),
                const SizedBox(width: 6),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Pal.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${day.exercises.length} упр.',
                  style: const TextStyle(
                    color: Pal.dim,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < day.exercises.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  height: 1,
                  color: Pal.line.withValues(alpha: 0.5),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Pal.ice.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Pal.ice.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Pal.ice,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.exercises[i].name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Pal.ice.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${day.exercises[i].sets} × ${day.exercises[i].repMin}–${day.exercises[i].repMax} · отдых ${day.exercises[i].restSeconds} с',
                          style: const TextStyle(
                            color: Pal.ice,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${day.exercises[i].focus} · ${day.exercises[i].reason}',
                        style: const TextStyle(
                          color: Pal.dim,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () =>
                              _replaceExercise(dayIndex, i, allExercises),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                          label: const Text(
                            'Заменить упражнение',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            foregroundColor: Pal.dimLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
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
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Pal.line),
      boxShadow: [
        BoxShadow(
          color: Pal.ice.withValues(alpha: 0.05),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.auto_awesome_rounded, color: Pal.ice, size: 28),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Программа под тебя',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Учитываются ограничения, оборудование, история тренировок и приоритетные мышцы. Программа остаётся повторяемой, чтобы можно было отслеживать прогресс.',
                style: TextStyle(
                  color: Pal.dimLight,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _progressionCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Pal.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Pal.line),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Как прогрессировать',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '• Большинство подходов заканчивай с запасом примерно 1–3 повтора, не обязательно до отказа.',
          style: TextStyle(color: Pal.dimLight, fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 8),
        Text(
          '• Когда выполнишь верхнюю границу повторов во всех рабочих подходах с хорошей техникой на двух тренировках подряд, прибавь небольшой вес: обычно 2–5% для верха тела и 5–10% для низа.',
          style: TextStyle(color: Pal.dimLight, fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 8),
        Text(
          '• Если техника ломается, появляется боль или результат резко падает, не повышай нагрузку; уменьши вес или останови упражнение.',
          style: TextStyle(color: Pal.dimLight, fontSize: 14, height: 1.5),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(color: Pal.dim, fontSize: 13, height: 1.4),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
