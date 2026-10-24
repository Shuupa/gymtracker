import 'dart:convert';

import 'exercise_library_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../format.dart';
import '../logic/one_rm.dart';
import '../logic/report.dart';
import '../providers.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'exercise_picker_screen.dart';
import 'exercise_progress_screen.dart';
import 'report_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  final int workoutId;
  const WorkoutScreen({super.key, required this.workoutId});

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final report = await buildReport(db, workoutId);
    if (!context.mounted) return;

    if (report == null || report.exercises.isEmpty) {
      final ok = await confirmDialog(
        context,
        title: 'Пустая тренировка',
        text: 'Подходов нет. Удалить тренировку?',
      );
      if (!ok || !context.mounted) return;
      Navigator.pop(context);
      await db.deleteWorkout(workoutId);
      return;
    }
    await db.finishWorkout(workoutId);
    final prefs = await SharedPreferences.getInstance();
    final programDayIndex = prefs.getInt('programDayIndex_$workoutId');
    if (programDayIndex != null) {
      var allPrescribedExercisesPresent = true;
      final rawPrescription = prefs.getString('workoutPrescription_$workoutId');
      if (rawPrescription != null) {
        try {
          final decoded = jsonDecode(rawPrescription) as Map<String, dynamic>;
          final prescribed = decoded['exercises'] as Map<String, dynamic>?;
          if (prescribed != null && prescribed.isNotEmpty) {
            final actualIds = await db.workoutExerciseIds(workoutId);
            allPrescribedExercisesPresent = prescribed.keys
                .map(int.tryParse)
                .whereType<int>()
                .every(actualIds.contains);
          }
        } catch (_) {}
      }
      if (allPrescribedExercisesPresent) {
        final completed =
            (prefs.getStringList('programCompletedDays') ?? <String>[]).toSet();
        completed.add(programDayIndex.toString());
        await prefs.setStringList('programCompletedDays', completed.toList());
      }
    }
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReportScreen(workoutId: workoutId)),
    );
  }

  Future<void> _pickExercise(BuildContext context, WidgetRef ref) async {
    final exerciseId = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );

    if (exerciseId == null || !context.mounted) return;
    await ref.read(dbProvider).addExerciseToWorkout(workoutId, exerciseId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(workoutExercisesProvider(workoutId));
    final workout = ref.watch(workoutProvider(workoutId)).value;
    final finished = workout?.finishedAt != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Тренировка'),
            if (workout != null)
              _Elapsed(start: workout.startedAt, end: workout.finishedAt),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Как выполнять упражнения?',
            icon: const Icon(Icons.help_outline_rounded, color: Pal.ember),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExerciseLibraryScreen(),
                ),
              );
            },
          ),
          finished
              ? TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportScreen(workoutId: workoutId),
                    ),
                  ),
                  child: const Text('Итоги'),
                )
              : TextButton(
                  onPressed: () => _finish(context, ref),
                  child: const Text(
                    'Завершить',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
        ],
      ),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (list) => list.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Pal.surface2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Pal.line),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 32,
                        color: Pal.ice,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Добавь первое упражнение',
                      style: TextStyle(
                        color: Pal.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _pickExercise(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Упражнение'),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                children: [
                  for (final it in list)
                    ExerciseCard(
                      key: ValueKey(it.we.id),
                      workoutId: workoutId,
                      we: it.we,
                      exercise: it.ex,
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text(
          'Упражнение',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onPressed: () => _pickExercise(context, ref),
      ),
    );
  }
}

class _Elapsed extends StatelessWidget {
  final DateTime start;
  final DateTime? end;
  const _Elapsed({required this.start, this.end});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: Pal.dim,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    if (end != null) {
      return Text(fmtDuration(end!.difference(start)), style: style);
    }
    return StreamBuilder<int>(
      stream: Stream.periodic(const Duration(seconds: 20), (i) => i),
      builder: (_, __) =>
          Text(fmtDuration(DateTime.now().difference(start)), style: style),
    );
  }
}

class ExerciseCard extends ConsumerStatefulWidget {
  final int workoutId;
  final WorkoutExercise we;
  final Exercise exercise;
  const ExerciseCard({
    super.key,
    required this.workoutId,
    required this.we,
    required this.exercise,
  });

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  final _weight = TextEditingController();
  final _reps = TextEditingController();
  List<WorkoutSet> _last = [];
  bool _warmup = false;
  double _bodyWeight = 80;
  Map<String, dynamic>? _prescription;

  double get _step => switch (widget.exercise.equipment) {
    'barbell' => 2.5,
    'machine' => 5.0,
    'bodyweight' => 2.5,
    _ => 1.0,
  };

  @override
  void initState() {
    super.initState();
    _loadLast();
    _loadBodyWeight();
    _loadPrescription();
  }

  Future<void> _loadPrescription() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('workoutPrescription_${widget.workoutId}');
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final all = decoded['exercises'] as Map<String, dynamic>?;
      final entry = all?[widget.exercise.id.toString()];
      if (!mounted || entry is! Map) return;
      setState(() => _prescription = Map<String, dynamic>.from(entry));
    } catch (_) {}
  }

  Future<void> _loadBodyWeight() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _bodyWeight = prefs.getDouble('bodyWeight') ?? 80);
  }

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  Future<void> _loadLast() async {
    final last = await ref
        .read(dbProvider)
        .lastSetsFor(widget.exercise.id, widget.workoutId);
    if (!mounted) return;
    setState(() => _last = last);
    _prefill(0);
  }

  void _prefill(int index) {
    if (index >= _last.length) return;
    final s = _last[index];
    _weight.text = fmtNum(s.weight);
    _reps.text = s.reps.toString();
  }

  void _bump(TextEditingController c, double delta) {
    final cur = double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
    final next = cur + delta < 0 ? 0.0 : cur + delta;
    c.text = fmtNum((next * 100).round() / 100);
  }

  Future<void> _add(List<WorkoutSet> sets) async {
    final w = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
    final r = int.tryParse(_reps.text);
    if (r == null || r <= 0 || w < 0) return;
    HapticFeedback.lightImpact();
    await ref.read(dbProvider).addSet(widget.we.id, w, r, isWarmup: _warmup);
    final working = sets.where((s) => !s.isWarmup).length;
    _prefill(_warmup ? working : working + 1);
  }

  Future<void> _removeExercise(List<WorkoutSet> sets) async {
    final db = ref.read(dbProvider);
    if (sets.isNotEmpty) {
      final ok = await confirmDialog(
        context,
        title: 'Удалить упражнение?',
        text: '«${widget.exercise.name}» и ${sets.length} подх. будут удалены.',
      );
      if (!ok) return;
    }
    await db.deleteWorkoutExercise(widget.we.id);
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(dbProvider);
    final sets = ref.watch(setsProvider(widget.we.id)).value ?? [];
    var n = 0;
    final labels = {for (final s in sets) s.id: s.isWarmup ? 'Р' : '${++n}'};

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161F2E), Color(0xFF0C121C)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Pal.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Pal.dim),
                  onSelected: (v) {
                    if (v == 'progress') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ExerciseProgressScreen(exercise: widget.exercise),
                        ),
                      );
                    } else {
                      _removeExercise(sets);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'progress', child: Text('Прогресс')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Удалить упражнение'),
                    ),
                  ],
                ),
              ],
            ),
            if (_prescription != null) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(right: 6, bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Pal.success.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Pal.success.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.checklist_rounded,
                      size: 14,
                      color: Pal.success,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'По программе: ${_prescription!['sets']} × ${_prescription!['repMin']}–${_prescription!['repMax']} · отдых ${_prescription!['restSeconds']} с',
                        style: const TextStyle(
                          color: Pal.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _last.isEmpty
                  ? const Text(
                      'Раньше не делал',
                      style: TextStyle(color: Pal.dim, fontSize: 12),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Прошлый раз',
                          style: TextStyle(color: Pal.dim, fontSize: 12),
                        ),
                        for (final s in _last)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Pal.surface2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${fmtNum(s.weight)}×${s.reps}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Pal.ice,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                children: [
                  for (final s in sets)
                    Dismissible(
                      key: ValueKey('set${s.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => db.deleteSet(s.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Pal.hot.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      child: _SetRow(
                        label: labels[s.id]!,
                        set: s,
                        exerciseName: widget.exercise.name,
                        equipment: widget.exercise.equipment,
                        bodyWeight: _bodyWeight,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _Stepper(
                      label: widget.exercise.equipment == 'bodyweight'
                          ? 'Общая нагрузка, кг'
                          : 'Вес, кг',
                      controller: _weight,
                      decimal: true,
                      onMinus: () => _bump(_weight, -_step),
                      onPlus: () => _bump(_weight, _step),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Stepper(
                      label: 'Повторы',
                      controller: _reps,
                      decimal: false,
                      onMinus: () => _bump(_reps, -1),
                      onPlus: () => _bump(_reps, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Разминка'),
                    selected: _warmup,
                    onSelected: (v) => setState(() => _warmup = v),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 46),
                      ),
                      onPressed: () => _add(sets),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        _warmup ? 'Записать разминку' : 'Записать подход',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final String label;
  final WorkoutSet set;
  final String exerciseName;
  final String equipment;
  final double bodyWeight;
  const _SetRow({
    required this.label,
    required this.set,
    required this.exerciseName,
    required this.equipment,
    required this.bodyWeight,
  });

  @override
  Widget build(BuildContext context) {
    final load = effectiveExerciseLoad(
      exerciseName: exerciseName,
      equipment: equipment,
      bodyWeight: bodyWeight,
      enteredWeight: set.weight,
    );
    final est = set.isWarmup ? 0.0 : oneRm(load, set.reps);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Pal.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: set.isWarmup ? Pal.cold.withValues(alpha: 0.5) : Pal.ice,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: set.isWarmup ? Pal.text : const Color(0xFF07111C),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              equipment == 'bodyweight' && set.weight <= 0
                  ? 'Собств. вес (~${fmtNum(load)} кг) × ${set.reps}'
                  : '${fmtNum(set.weight)} кг × ${set.reps}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          if (est > 0)
            Text(
              '≈ ${fmtNum((est * 10).round() / 10)}',
              style: const TextStyle(color: Pal.dim, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool decimal;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  const _Stepper({
    required this.label,
    required this.controller,
    required this.decimal,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final btn = IconButton.styleFrom(
      minimumSize: const Size(36, 36),
      padding: EdgeInsets.zero,
      backgroundColor: Pal.surface2,
      foregroundColor: Pal.ice,
    );
    return Row(
      children: [
        IconButton(
          style: btn,
          onPressed: onMinus,
          icon: const Icon(Icons.remove, size: 18),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: decimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              labelText: label,
              hintText: '0',
              isDense: true,
              floatingLabelAlignment: FloatingLabelAlignment.center,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          style: btn,
          onPressed: onPlus,
          icon: const Icon(Icons.add, size: 18),
        ),
      ],
    );
  }
}
