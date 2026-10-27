import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../logic/muscle_strength.dart';
import '../logic/program_generator.dart';
import '../providers.dart';
import '../ui/theme.dart';
import 'exercise_picker_screen.dart';


Map<String, dynamic> _customProgramToMap(GeneratedProgram program) => {
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
    for (final day in program.days) {
      'title': day.title,
      'exercises': [
        for (final e in day.exercises) {
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

// ---------- шаблон: Full Body на 3 дня ----------

class _TplEx {
  final String name;
  final int sets;
  final int repMin;
  final int repMax;
  final int rest;
  const _TplEx(this.name, this.sets, this.repMin, this.repMax, this.rest);
}

/// Названия должны совпадать с названиями упражнений в seed.dart.
/// Если какого-то нет в базе, оно будет пропущено, а пользователь предупреждён.
const List<(String, List<_TplEx>)> _fullBodyTemplate = [
  (
    'Пн — тяжёлый',
    [
      _TplEx('Приседания со штангой', 4, 4, 6, 180),
      _TplEx('Жим лёжа', 4, 4, 6, 180),
      _TplEx('Тяга верхнего блока', 3, 6, 8, 120),
      _TplEx('Гиперэкстензия', 3, 8, 10, 90),
      _TplEx('Жим гантелей сидя', 2, 6, 8, 120),
      _TplEx('Подъём ног в висе', 3, 10, 12, 60),
    ],
  ),
  (
    'Ср — объёмный',
    [
      _TplEx('Жим ногами', 4, 10, 12, 150),
      _TplEx('Жим гантелей на наклонной скамье', 3, 8, 12, 120),
      _TplEx('Тяга горизонтального блока', 3, 10, 12, 120),
      _TplEx('Румынская тяга', 3, 8, 10, 150),
      _TplEx('Махи гантелями в стороны', 3, 12, 15, 60),
      _TplEx('Сгибания на скамье Скотта', 3, 10, 12, 90),
      _TplEx('Разгибания на блоке', 3, 10, 12, 90),
    ],
  ),
  (
    'Пт — средний',
    [
      _TplEx('Приседания со штангой', 3, 6, 8, 150),
      _TplEx('Жим лёжа', 3, 8, 10, 150),
      _TplEx('Рычажная тяга', 3, 8, 10, 120),
      _TplEx('Жим гантелей сидя', 3, 8, 10, 120),
      _TplEx('Гиперэкстензия', 3, 10, 12, 90),
      _TplEx('Молотки', 2, 10, 12, 90),
      _TplEx('Шраги с гантелями', 3, 10, 12, 90),
    ],
  ),
];

// ---------- черновики для редактирования ----------

class _ExDraft {
  int exerciseId;
  String name;
  String equipment;
  String focus;
  int sets;
  int repMin;
  int repMax;
  int rest;

  _ExDraft({
    required this.exerciseId,
    required this.name,
    required this.equipment,
    required this.focus,
    required this.sets,
    required this.repMin,
    required this.repMax,
    required this.rest,
  });
}

class _DayDraft {
  final TextEditingController title;
  final List<_ExDraft> exercises;

  _DayDraft(String text, [List<_ExDraft>? exercises])
    : title = TextEditingController(text: text),
      exercises = exercises ?? [];
}

int _clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

double _setCredit(double share) {
  if (share >= 0.45) return 1.0;
  if (share >= 0.20) return 0.5;
  if (share >= 0.10) return 0.25;
  return 0.0;
}

// ---------- экран ----------

/// Редактор собственной программы. Сохраняет результат в тот же ключ
/// `savedTrainingProgram`, что и генератор, поэтому просмотр программы и запуск
/// тренировок работают без изменений. Возвращает `true`, если программа сохранена.
class CustomProgramScreen extends ConsumerStatefulWidget {
  final GeneratedProgram? initial;
  const CustomProgramScreen({super.key, this.initial});

  @override
  ConsumerState<CustomProgramScreen> createState() =>
      _CustomProgramScreenState();
}

class _CustomProgramScreenState extends ConsumerState<CustomProgramScreen> {
  final List<_DayDraft> _days = [];
  List<MuscleLink> _links = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    for (final d in _days) {
      d.title.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    final links = await ref.read(dbProvider).exerciseMuscleLinks();
    if (!mounted) return;
    setState(() {
      _links = links;
      final p = widget.initial;
      if (p != null) {
        for (final day in p.days) {
          _days.add(
            _DayDraft(day.title, [
              for (final e in day.exercises)
                _ExDraft(
                  exerciseId: e.exerciseId,
                  name: e.name,
                  equipment: e.equipment,
                  focus: e.focus,
                  sets: e.sets,
                  repMin: e.repMin,
                  repMax: e.repMax,
                  rest: e.restSeconds,
                ),
            ]),
          );
        }
      }
      if (_days.isEmpty) _days.add(_DayDraft('Тренировка A'));
      _loading = false;
    });
  }

  String _focusFor(int exerciseId) {
    final mine = _links.where((l) => l.exerciseId == exerciseId).toList()
      ..sort((a, b) => b.share.compareTo(a.share));
    return mine.isEmpty ? 'Другое' : mine.first.muscle;
  }

  bool _isCompound(int exerciseId) =>
      _links.where((l) => l.exerciseId == exerciseId && l.share >= 0.15).length >=
      2;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ----- действия -----

  Future<void> _addExercise(_DayDraft day) async {
    final id = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const ExercisePickerScreen()),
    );
    if (id == null || !mounted) return;
    if (day.exercises.any((e) => e.exerciseId == id)) {
      _snack('Это упражнение уже есть в этом дне.');
      return;
    }
    final db = ref.read(dbProvider);
    final ex = await (db.select(
      db.exercises,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (ex == null || !mounted) return;
    final compound = _isCompound(id);
    setState(() {
      day.exercises.add(
        _ExDraft(
          exerciseId: ex.id,
          name: ex.name,
          equipment: ex.equipment,
          focus: _focusFor(ex.id),
          sets: 3,
          repMin: compound ? 6 : 10,
          repMax: compound ? 10 : 15,
          rest: compound ? 150 : 90,
        ),
      );
    });
  }

  Future<void> _editExercise(_ExDraft e) async {
    var sets = e.sets;
    var repMin = e.repMin;
    var repMax = e.repMax;
    var rest = e.rest;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Pal.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              20 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                _StepperRow(
                  label: 'Подходы',
                  value: '$sets',
                  onMinus: () => setSheet(() => sets = _clampInt(sets - 1, 1, 10)),
                  onPlus: () => setSheet(() => sets = _clampInt(sets + 1, 1, 10)),
                ),
                _StepperRow(
                  label: 'Повторы от',
                  value: '$repMin',
                  onMinus: () => setSheet(() {
                    repMin = _clampInt(repMin - 1, 1, 30);
                  }),
                  onPlus: () => setSheet(() {
                    repMin = _clampInt(repMin + 1, 1, 30);
                    if (repMin > repMax) repMax = repMin;
                  }),
                ),
                _StepperRow(
                  label: 'Повторы до',
                  value: '$repMax',
                  onMinus: () => setSheet(() {
                    repMax = _clampInt(repMax - 1, 1, 30);
                    if (repMax < repMin) repMin = repMax;
                  }),
                  onPlus: () => setSheet(() {
                    repMax = _clampInt(repMax + 1, 1, 30);
                  }),
                ),
                _StepperRow(
                  label: 'Отдых, сек',
                  value: '$rest',
                  onMinus: () => setSheet(() => rest = _clampInt(rest - 15, 15, 420)),
                  onPlus: () => setSheet(() => rest = _clampInt(rest + 15, 15, 420)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Готово'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      setState(() {
        e.sets = sets;
        e.repMin = repMin;
        e.repMax = repMax;
        e.rest = rest;
      });
    }
  }

  void _move<T>(List<T> list, int index, int delta) {
    final j = index + delta;
    if (j < 0 || j >= list.length) return;
    setState(() {
      final item = list.removeAt(index);
      list.insert(j, item);
    });
  }

  void _addDay() {
    setState(() {
      _days.add(
        _DayDraft('Тренировка ${String.fromCharCode(65 + _days.length)}'),
      );
    });
  }

  void _deleteDay(int index) {
    setState(() {
      _days.removeAt(index).title.dispose();
      if (_days.isEmpty) _days.add(_DayDraft('Тренировка A'));
    });
  }

  Future<void> _loadTemplate() async {
    final hasContent = _days.any((d) => d.exercises.isNotEmpty);
    if (hasContent) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Заменить текущую программу?'),
          content: const Text(
            'Шаблон Full Body заменит дни и упражнения, которые ты уже добавил.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Заменить'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    final db = ref.read(dbProvider);
    final all = await db.select(db.exercises).get();
    final byName = {for (final e in all) e.name: e};
    final missing = <String>[];
    final newDays = <_DayDraft>[];

    for (final (title, items) in _fullBodyTemplate) {
      final drafts = <_ExDraft>[];
      for (final t in items) {
        final ex = byName[t.name];
        if (ex == null) {
          missing.add(t.name);
          continue;
        }
        drafts.add(
          _ExDraft(
            exerciseId: ex.id,
            name: ex.name,
            equipment: ex.equipment,
            focus: _focusFor(ex.id),
            sets: t.sets,
            repMin: t.repMin,
            repMax: t.repMax,
            rest: t.rest,
          ),
        );
      }
      newDays.add(_DayDraft(title, drafts));
    }

    if (!mounted) return;
    setState(() {
      for (final d in _days) {
        d.title.dispose();
      }
      _days
        ..clear()
        ..addAll(newDays);
    });
    if (missing.isNotEmpty) {
      _snack('Не нашёл в базе: ${missing.toSet().join(', ')}');
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    final days = <ProgramDay>[];
    final planned = <String, double>{};
    for (var i = 0; i < _days.length; i++) {
      final d = _days[i];
      if (d.exercises.isEmpty) continue;
      final name = d.title.text.trim();
      days.add(
        ProgramDay(
          title: name.isEmpty
              ? 'Тренировка ${String.fromCharCode(65 + i)}'
              : name,
          exercises: [
            for (final e in d.exercises)
              PrescribedExercise(
                exerciseId: e.exerciseId,
                name: e.name,
                equipment: e.equipment,
                focus: e.focus,
                sets: e.sets,
                repMin: e.repMin,
                repMax: e.repMax,
                restSeconds: e.rest,
                reason: 'Своя программа',
              ),
          ],
        ),
      );
      for (final e in d.exercises) {
        for (final link in _links.where((l) => l.exerciseId == e.exerciseId)) {
          planned[link.muscle] =
              (planned[link.muscle] ?? 0) + e.sets * _setCredit(link.share);
        }
      }
    }

    if (days.isEmpty) {
      _snack('Добавь хотя бы одно упражнение.');
      return;
    }

    final old = widget.initial?.options;
    final options = ProgramOptions(
      goal: old?.goal ?? ProgramGoal.hypertrophy,
      level: old?.level ?? TrainingLevel.intermediate,
      daysPerWeek: days.length,
      sessionMinutes: old?.sessionMinutes ?? 60,
      excludedMuscles: old?.excludedMuscles ?? <String>{},
      priorityMuscles: old?.priorityMuscles ?? <String>{},
      excludedExerciseIds: old?.excludedExerciseIds ?? <int>{},
      priorityExerciseIds: old?.priorityExerciseIds ?? <int>{},
      equipment:
          old?.equipment ?? {'barbell', 'dumbbell', 'machine', 'bodyweight'},
      autoPrioritize: old?.autoPrioritize ?? true,
    );

    final program = GeneratedProgram(
      options: options,
      days: days,
      priorities: const [],
      warnings: const [],
      plannedWeeklySets: planned,
    );

    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedTrainingProgram', jsonEncode(_customProgramToMap(program)));
      await prefs.setStringList('programCompletedDays', <String>[]);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Не удалось сохранить: $error');
      }
    }
  }

  // ----- интерфейс -----

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Своя программа'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Шаблоны',
            icon: const Icon(Icons.library_add_rounded),
            onSelected: (v) {
              if (v == 'fullbody') _loadTemplate();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'fullbody',
                child: Text('Шаблон: Full Body, 3 дня'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (var i = 0; i < _days.length; i++) _dayCard(i),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addDay,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить день'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Сохранить программу'),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(int dayIndex) {
    final day = _days[dayIndex];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 10),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pal.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: day.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Название дня',
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'up':
                      _move(_days, dayIndex, -1);
                    case 'down':
                      _move(_days, dayIndex, 1);
                    case 'delete':
                      _deleteDay(dayIndex);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'up', child: Text('Выше')),
                  PopupMenuItem(value: 'down', child: Text('Ниже')),
                  PopupMenuItem(value: 'delete', child: Text('Удалить день')),
                ],
              ),
            ],
          ),
          if (day.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Пока пусто. Добавь первое упражнение.',
                style: TextStyle(color: Pal.dim, fontSize: 14),
              ),
            ),
          for (var j = 0; j < day.exercises.length; j++)
            _exerciseRow(day, j),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addExercise(day),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить упражнение'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseRow(_DayDraft day, int index) {
    final e = day.exercises[index];
    final reps = e.repMin == e.repMax ? '${e.repMin}' : '${e.repMin}-${e.repMax}';
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(right: 0),
      onTap: () => _editExercise(e),
      title: Text(
        e.name,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      subtitle: Text(
        '${e.focus} · ${e.sets} × $reps · отдых ${e.rest} с',
        style: const TextStyle(color: Pal.dim, fontSize: 13),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          switch (v) {
            case 'edit':
              _editExercise(e);
            case 'up':
              _move(day.exercises, index, -1);
            case 'down':
              _move(day.exercises, index, 1);
            case 'delete':
              setState(() => day.exercises.removeAt(index));
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Изменить')),
          PopupMenuItem(value: 'up', child: Text('Выше')),
          PopupMenuItem(value: 'down', child: Text('Ниже')),
          PopupMenuItem(value: 'delete', child: Text('Удалить')),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: 44,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}