// lib/screens/profile_screen.dart

import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math' as math;

import '../data/app_database.dart';
import '../data/seed.dart' show muscleNames;
import '../logic/muscle_strength.dart';
import '../logic/profile_rating.dart';
import '../logic/one_rm.dart';
import '../logic/working_sets.dart';
import '../providers.dart';
import '../ui/body_map.dart';
import '../ui/levels.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'exercise_progress_screen.dart';
import 'program_generator_screen.dart';

String _format1(num value) =>
    ((value * 10).roundToDouble() / 10).toStringAsFixed(1);

/// Отображает именно выполненный рекордный подход, а не расчётный 1RM.
String _recordSetLabel({
  required Exercise exercise,
  required SetData? set,
  required double bodyWeight,
}) {
  if (set == null) return '—';
  if (exercise.equipment == 'bodyweight' && set.weight <= 0) {
    final effectiveLoad = effectiveExerciseLoad(
      exerciseName: exercise.name,
      equipment: exercise.equipment,
      bodyWeight: bodyWeight,
      enteredWeight: 0,
    );
    return effectiveLoad > 0
        ? '≈${_format1(effectiveLoad)} кг × ${set.reps}'
        : 'Свой вес × ${set.reps}';
  }
  return '${_format1(set.weight)} × ${set.reps}';
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  double _weight = 80;
  double _height = 180;
  double? _bodyFat;
  bool _male = true;
  bool _loaded = false;
  bool _saving = false;
  bool _measurementsSaved = false;
  bool _editingMeasurements = true;

  String? _selectedMuscle;
  Set<int> _favoriteIds = {};
  Future<Map<String, MuscleResult>>? _scoresFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  double? _parse(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    _weight = prefs.getDouble('bodyWeight') ?? 80;
    _height = prefs.getDouble('bodyHeight') ?? 180;
    _bodyFat = prefs.getDouble('bodyFatPercent');
    _male = prefs.getBool('isMale') ?? true;
    _measurementsSaved =
        prefs.containsKey('bodyWeight') && prefs.containsKey('bodyHeight');
    _editingMeasurements = !_measurementsSaved;

    _favoriteIds = (prefs.getStringList('favoriteExerciseIds') ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();

    _weightCtrl.text = _format1(_weight);
    _heightCtrl.text = _format1(_height);
    _fatCtrl.text = _bodyFat == null ? '' : _format1(_bodyFat!);

    _scoresFuture = _calculateScores();

    setState(() {
      _loaded = true;
    });
  }

  Future<Map<String, MuscleResult>> _calculateScores() async {
    final db = ref.read(dbProvider);
    final sets = await loadWorkingSets(db);
    final links = await db.exerciseMuscleLinks();

    return muscleScores(
      sets: sets,
      links: links,
      bodyWeight: _weight,
      isMale: _male,
    );
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('bodyWeight', _weight);
    await prefs.setDouble('bodyHeight', _height);
    await prefs.setBool('isMale', _male);

    if (_bodyFat == null) {
      await prefs.remove('bodyFatPercent');
    } else {
      await prefs.setDouble('bodyFatPercent', _bodyFat!);
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteExerciseIds',
      _favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  void _recalculate() {
    setState(() {
      _scoresFuture = _calculateScores();
    });
  }

  Future<void> _saveMeasurements() async {
    final weight = _parse(_weightCtrl.text);
    final height = _parse(_heightCtrl.text);
    final fatText = _fatCtrl.text.trim();
    final fat = fatText.isEmpty ? null : _parse(fatText);

    if (weight == null || weight < 20 || weight > 400) {
      _showMessage('Укажи вес от 20 до 400 кг');
      return;
    }

    if (height == null || height < 80 || height > 250) {
      _showMessage('Укажи рост от 80 до 250 см');
      return;
    }

    if (fatText.isNotEmpty && (fat == null || fat < 2 || fat > 70)) {
      _showMessage('Процент жира должен быть от 2 до 70');
      return;
    }

    setState(() {
      _saving = true;
      _weight = weight;
      _height = height;
      _bodyFat = fat;
    });

    try {
      await _saveProfile();
      if (mounted) {
        setState(() {
          _measurementsSaved = true;
          _editingMeasurements = false;
        });
      }
      _recalculate();
      if (mounted) _showMessage('Параметры сохранены');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  double get _bmi {
    final meters = _height / 100;
    return ((_weight / (meters * meters)) * 10).roundToDouble() / 10;
  }

  double? get _leanMass {
    if (_bodyFat == null) return null;
    final value = _weight * (1 - _bodyFat! / 100);
    return (value * 10).roundToDouble() / 10;
  }

  Future<void> _toggleFavorite(Exercise exercise) async {
    setState(() {
      if (_favoriteIds.contains(exercise.id)) {
        _favoriteIds.remove(exercise.id);
      } else {
        _favoriteIds.add(exercise.id);
      }
    });

    await _saveFavorites();
  }

  Future<void> _chooseFavorites(List<Exercise> exercises) async {
    final selected = Set<int>.from(_favoriteIds);

    // При первом открытии отмечаем те упражнения, которые уже показываются
    // автоматически: самые часто выполняемые. Так выбор не выглядит пустым.
    if (selected.isEmpty) {
      final usage = <int, int>{};
      for (final exercise in exercises) {
        try {
          final sessions = await ref.read(
            exerciseHistoryProvider(exercise.id).future,
          );
          if (sessions.isNotEmpty) usage[exercise.id] = sessions.length;
        } catch (_) {
          // Недоступная история не должна блокировать открытие выбора.
        }
      }
      final sorted = usage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      selected.addAll(sorted.take(3).map((entry) => entry.key));
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Pal.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Избранные упражнения',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
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
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Выбери упражнения для быстрого просмотра прогресса.',
                          style: TextStyle(color: Pal.dim, fontSize: 13),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: exercises.length,
                        itemBuilder: (_, index) {
                          final exercise = exercises[index];
                          final isSelected = selected.contains(exercise.id);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Material(
                              color: isSelected
                                  ? Pal.ice.withValues(alpha: 0.10)
                                  : Pal.bg,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  setSheetState(() {
                                    if (isSelected) {
                                      selected.remove(exercise.id);
                                    } else {
                                      selected.add(exercise.id);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? Pal.ice : Pal.line,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Pal.surface,
                                          borderRadius: BorderRadius.circular(
                                            11,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center_rounded,
                                          color: Pal.ice,
                                          size: 19,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.add_circle_outline_rounded,
                                        color: isSelected ? Pal.ice : Pal.dim,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            setState(() {
                              _favoriteIds = Set<int>.from(selected);
                            });
                            await _saveFavorites();

                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider);
    final workoutsAsync = ref.watch(workoutsProvider);

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
        children: [
          FutureBuilder<Map<String, MuscleResult>>(
            future: _scoresFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ErrorPanel(
                  text: 'Не удалось рассчитать рейтинг: ${snapshot.error}',
                );
              }

              if (!snapshot.hasData) {
                return const _LoadingPanel();
              }

              return _FitnessRating(scores: snapshot.data!);
            },
          ),

          const SizedBox(height: 20),
          const _SavedProgramCard(),
          const SizedBox(height: 18),
          workoutsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (workouts) => _AttendanceHeatmap(workouts: workouts),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 26),
          _SectionHeading(
            title: 'Избранные упражнения',
            trailing: _favoriteIds.isEmpty
                ? 'АВТОВЫБОР'
                : '${_favoriteIds.length} выбрано',
            onAction: () => exercisesAsync.whenData(
              (exercises) => _chooseFavorites(exercises),
            ),
            actionLabel: 'Выбрать упражнения',
          ),
          const SizedBox(height: 10),
          exercisesAsync.when(
            loading: () => const _LoadingPanel(),
            error: (error, _) =>
                _ErrorPanel(text: 'Не удалось загрузить упражнения: $error'),
            data: (exercises) {
              // Если пользователь не выбрал избранное вручную, показываем
              // упражнения, которые он выполняет чаще всего.
              final usage = <Exercise, int>{};
              for (final exercise in exercises) {
                final history = ref.watch(exerciseHistoryProvider(exercise.id));
                history.whenData((sessions) {
                  if (sessions.isNotEmpty) {
                    usage[exercise] = sessions.length;
                  }
                });
              }

              final automaticFavorites = usage.keys.toList()
                ..sort((a, b) => (usage[b] ?? 0).compareTo(usage[a] ?? 0));
              final favorites = _favoriteIds.isNotEmpty
                  ? exercises
                        .where((exercise) => _favoriteIds.contains(exercise.id))
                        .toList()
                  : automaticFavorites.take(3).toList();

              if (favorites.isEmpty) {
                return const _EmptyPanel(
                  title: 'Пока нет истории упражнений',
                  subtitle: 'Здесь автоматически появятся упражнения, которые ты выполняешь чаще всего.',
                );
              }

              return Column(
                children: [
                  for (final exercise in favorites)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FavoriteExerciseCard(
                        exercise: exercise,
                        bodyWeight: _weight,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExerciseProgressScreen(exercise: exercise),
                            ),
                          );
                        },
                        onRemove: () => _toggleFavorite(exercise),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 26),
          const _SectionHeading(title: 'Мышечная карта', trailing: 'ПО СИЛЕ'),
          const SizedBox(height: 10),
          FutureBuilder<Map<String, MuscleResult>>(
            future: _scoresFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ErrorPanel(
                  text: 'Не удалось рассчитать мышцы: ${snapshot.error}',
                );
              }

              if (!snapshot.hasData) {
                return const _LoadingPanel();
              }

              return _MuscleProfile(
                scores: snapshot.data!,
                selectedMuscle: _selectedMuscle,
                onSelect: (muscle) {
                  setState(() {
                    _selectedMuscle = muscle;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 26),
          const _SectionHeading(title: 'Все упражнения', trailing: 'ИСТОРИЯ'),
          const SizedBox(height: 10),
          exercisesAsync.when(
            loading: () => const _LoadingPanel(),
            error: (error, _) =>
                _ErrorPanel(text: 'Не удалось загрузить упражнения: $error'),
            data: (exercises) => Column(
              children: [
                for (final exercise in exercises)
                  _ExerciseHistoryEntry(
                    exercise: exercise,
                    bodyWeight: _weight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ExerciseProgressScreen(exercise: exercise),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Divider(color: Pal.line),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Параметры тела',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _editingMeasurements = !_editingMeasurements;
                  });
                },
                icon: Icon(
                  _editingMeasurements
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(_editingMeasurements ? 'Свернуть' : 'Изменить'),
              ),
            ],
          ),
          if (!_editingMeasurements && _measurementsSaved)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Pal.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Pal.line),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text('${_format1(_weight)} кг'),
                  Text('${_format1(_height)} см'),
                  Text(
                    _bodyFat == null
                        ? 'Жир не указан'
                        : '${_format1(_bodyFat!)}% жира',
                  ),
                  Text(_male ? 'Мужские нормативы' : 'Женские нормативы'),
                ],
              ),
            ),
          if (_editingMeasurements) ...[
            const SizedBox(height: 8),
            _MeasurementsPanel(
              weightCtrl: _weightCtrl,
              heightCtrl: _heightCtrl,
              fatCtrl: _fatCtrl,
              male: _male,
              saving: _saving,
              bmi: _bmi,
              leanMass: _leanMass,
              onGenderChanged: (male) async {
                setState(() {
                  _male = male;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isMale', male);
                _recalculate();
              },
              onSave: _saveMeasurements,
            ),
          ],
        ],
      ),
    );
  }
}

class _FitnessRating extends StatelessWidget {
  final Map<String, MuscleResult> scores;

  const _FitnessRating({required this.scores});

  @override
  Widget build(BuildContext context) {
    // Оцениваем всё тело: группы без данных остаются нулевыми,
    // а не исчезают из среднего и не завышают рейтинг.
    final allScores = muscleNames
        .map((name) => (scores[name]?.score ?? 0.0).clamp(0.0, 1.0))
        .toList();
    final average = allScores.isEmpty
        ? 0.0
        : allScores.reduce((a, b) => a + b) / allScores.length;
    // Elo 0…2200+
    final elo = (average * 2200).roundToDouble();
    final rankIndex = rankIndexForElo(elo).clamp(0, gymRanks.length - 1);
    final rank = gymRanks[rankIndex];
    final ranking = scores.entries.toList()
      ..sort((a, b) => a.value.score.compareTo(b.value.score));
    final strongest = ranking.reversed.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Pal.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'РЕЙТИНГ ВСЕГО ТЕЛА',
            style: TextStyle(
              color: Pal.dim,
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _GymRankBadge(rankIndex: rankIndex, size: 92),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rank.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${elo.toStringAsFixed(0)} Elo · ${rank.description}',
                      style: const TextStyle(
                        color: Pal.ice,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: average.clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: Pal.surface2,
                        color: Pal.ice,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            scores.isEmpty
                ? 'Рейтинг предварительный: нужны завершённые тренировки с рабочими подходами.'
                : 'Оценка рассчитывается по всем ${muscleNames.length} мышечным группам. '
                      'Группы без истории пока считаются неразвитыми в рамках индекса.',
            style: const TextStyle(color: Pal.dim, fontSize: 11, height: 1.45),
          ),
          if (strongest.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(color: Pal.line, height: 1),
            const SizedBox(height: 14),
            const Text(
              'Сильнейшие группы',
              style: TextStyle(color: Pal.dim, fontSize: 11),
            ),
            const SizedBox(height: 10),
            for (final entry in strongest)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: entry.value.score.clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: Pal.surface2,
                          color: levelColor(entry.value.score),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${(entry.value.score * 100).toStringAsFixed(1)}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 10, color: Pal.dim),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _GymRankBadge extends StatelessWidget {
  final int rankIndex;
  final double size;

  const _GymRankBadge({required this.rankIndex, this.size = 92});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GymRankPainter(rankIndex: rankIndex)),
    );
  }
}

class _GymRankPainter extends CustomPainter {
  final int rankIndex;

  const _GymRankPainter({required this.rankIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;
    final t = (rankIndex / 9).clamp(0.0, 1.0);
    final accent = Color.lerp(
      const Color(0xFFA8D4F0),
      const Color(0xFF7C3AED),
      t,
    )!;

    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF171D25));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accent
        ..strokeWidth = size.width * 0.025
        ..style = PaintingStyle.stroke,
    );

    final points = 3 + rankIndex;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = -math.pi / 2 + i * math.pi / points;
      final r = i.isEven ? radius * 0.76 : radius * 0.42;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = accent
        ..strokeWidth = size.width * 0.018
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    final icon = rankIndex < 2
        ? Icons.bedtime_outlined
        : rankIndex < 4
        ? Icons.fitness_center
        : rankIndex < 7
        ? Icons.bolt
        : rankIndex < 9
        ? Icons.workspace_premium
        : Icons.emoji_events;
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.27,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: accent,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _GymRankPainter oldDelegate) =>
      oldDelegate.rankIndex != rankIndex;
}

class _MeasurementsPanel extends StatelessWidget {
  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController fatCtrl;
  final bool male;
  final bool saving;
  final double bmi;
  final double? leanMass;
  final ValueChanged<bool> onGenderChanged;
  final VoidCallback onSave;

  const _MeasurementsPanel({
    required this.weightCtrl,
    required this.heightCtrl,
    required this.fatCtrl,
    required this.male,
    required this.saving,
    required this.bmi,
    required this.leanMass,
    required this.onGenderChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Pal.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: weightCtrl,
                  label: 'Вес',
                  suffix: 'кг',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: heightCtrl,
                  label: 'Рост',
                  suffix: 'см',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: fatCtrl,
                  label: 'Жир (опционально)',
                  suffix: '%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Пол для нормативов',
                      style: TextStyle(color: Pal.dim, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: true, label: Text('М')),
                          ButtonSegment(value: false, label: Text('Ж')),
                        ],
                        selected: {male},
                        onSelectionChanged: (values) {
                          onGenderChanged(values.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BodyMetric(
                  label: 'ИМТ',
                  value: bmi.isFinite ? _format1(bmi) : '—',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BodyMetric(
                  label: 'Безжировая масса',
                  value: leanMass == null ? '—' : '${_format1(leanMass!)} кг',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: saving ? null : onSave,
              child: Text(saving ? 'Сохранение…' : 'Сохранить параметры'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Безжировая масса рассчитывается только при указанном проценте жира. '
            'ИМТ — справочный показатель и не оценивает состав тела.',
            style: TextStyle(color: Pal.dim, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }
}

class _BodyMetric extends StatelessWidget {
  final String label;
  final String value;

  const _BodyMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Pal.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Pal.dim, fontSize: 10)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Pal.text,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleProfile extends StatelessWidget {
  final Map<String, MuscleResult> scores;
  final String? selectedMuscle;
  final ValueChanged<String> onSelect;

  const _MuscleProfile({
    required this.scores,
    required this.selectedMuscle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = <String, Color>{
      for (final entry in scores.entries)
        entry.key: heatColor(entry.value.score),
    };

    final ranking = scores.entries.toList()
      ..sort((a, b) => a.value.score.compareTo(b.value.score));

    final weakest = ranking.take(3).toList();
    final strongest = ranking.reversed.take(3).toList();
    final noData = muscleNames.where((name) => !scores.containsKey(name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Pal.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Pal.line),
          ),
          child: BodyMap(colors: colors, onMuscleTap: onSelect),
        ),
        const SizedBox(height: 10),
        const LevelLegend(),
        const SizedBox(height: 12),
        _MuscleInfo(
          name: selectedMuscle,
          result: selectedMuscle == null ? null : scores[selectedMuscle],
        ),
        if (scores.isEmpty)
          const _EmptyPanel(
            title: 'Пока нет оценок мышц',
            subtitle: 'Заверши тренировку с рабочими подходами.',
          )
        else ...[
          const SectionTitle('Сильнее всего'),
          for (final entry in strongest) _MuscleRow(entry.key, entry.value),
          const SectionTitle('Есть потенциал для роста'),
          for (final entry in weakest) _MuscleRow(entry.key, entry.value),
        ],
        if (noData.isNotEmpty) ...[
          const SectionTitle('Без данных'),
          Text(noData.join(', '), style: const TextStyle(color: Pal.dim)),
        ],
      ],
    );
  }
}

class _MuscleInfo extends StatelessWidget {
  final String? name;
  final MuscleResult? result;

  const _MuscleInfo({required this.name, required this.result});

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'Выбери мышцу на карте',
            style: TextStyle(color: Pal.dim),
          ),
        ),
      );
    }

    final muscle = result;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pal.line),
      ),
      child: muscle == null
          ? Text(
              '$name: нет данных',
              style: const TextStyle(fontWeight: FontWeight.w700),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Pill(
                      levelName(muscle.score),
                      color: levelColor(muscle.score),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: muscle.score.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: Pal.surface2,
                    color: levelColor(muscle.score),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Упражнения, влияющие на оценку',
                  style: TextStyle(color: Pal.dim, fontSize: 11),
                ),
                const SizedBox(height: 6),
                for (final source in muscle.sources)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text(source.exercise)),
                        Text(
                          levelName(source.score),
                          style: TextStyle(
                            color: levelColor(source.score),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _MuscleRow extends StatelessWidget {
  final String name;
  final MuscleResult result;

  const _MuscleRow(this.name, this.result);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: result.score.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: Pal.surface2,
                color: levelColor(result.score),
              ),
            ),
          ),
          SizedBox(
            width: 78,
            child: Text(
              levelName(result.score),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: levelColor(result.score),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final double bodyWeight;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteExerciseCard({
    required this.exercise,
    required this.bodyWeight,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(exerciseHistoryProvider(exercise.id));

    return Material(
      color: Pal.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Pal.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Pal.ice.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.show_chart_rounded, color: Pal.ice),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Убрать из избранного',
                    onPressed: onRemove,
                    icon: const Icon(Icons.star_rounded, color: Pal.ice),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              history.when(
                loading: () => const SizedBox(
                  height: 56,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (error, _) => Text(
                  'Не удалось загрузить историю: $error',
                  style: const TextStyle(color: Pal.dim, fontSize: 12),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return const Text(
                      'Нет завершённых тренировок с этим упражнением.',
                      style: TextStyle(color: Pal.dim, fontSize: 12),
                    );
                  }

                  final values = sessions
                      .map(
                        (session) => session.best1rm(
                          OneRmFormula.average,
                          bodyWeight: bodyWeight,
                          exerciseName: exercise.name,
                          equipment: exercise.equipment,
                        ),
                      )
                      .toList();

                  final best = values.reduce(
                    (a, b) => math.max(a, b).toDouble(),
                  );
                  final bestSet = sessions
                      .expand((session) => session.sets)
                      .where((set) => set.reps > 0)
                      .fold<SetData?>(null, (current, set) {
                        if (current == null) return set;
                        if (set.weight > current.weight) return set;
                        if (set.weight == current.weight &&
                            set.reps > current.reps) {
                          return set;
                        }
                        return current;
                      });
                  final first = values.first;
                  final last = values.last;
                  final delta = last - first;
                  final percent = first > 0 ? delta / first * 100 : 0.0;

                  final spots = <FlSpot>[
                    for (var i = 0; i < values.length; i++)
                      if (values[i] > 0)
                        FlSpot(
                          i.toDouble(),
                          (values[i] * 10).roundToDouble() / 10,
                        ),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MiniMetric(
                              label: 'Текущий 1RM',
                              value: last > 0 ? '${_format1(last)} кг' : '—',
                            ),
                          ),
                          Expanded(
                            child: _MiniMetric(
                              label: 'Рекордный подход',
                              value: _recordSetLabel(
                                exercise: exercise,
                                set: bestSet,
                                bodyWeight: bodyWeight,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _MiniMetric(
                              label: 'Изменение',
                              value: sessions.length < 2
                                  ? '—'
                                  : '${percent >= 0 ? '+' : ''}'
                                        '${percent.toStringAsFixed(1)}%',
                              valueColor: sessions.length < 2
                                  ? Pal.dim
                                  : percent >= 0
                                  ? Pal.ice
                                  : Pal.hot,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 82,
                        child: spots.length < 2
                            ? const Center(
                                child: Text(
                                  'Для графика нужно 2 тренировки',
                                  style: TextStyle(
                                    color: Pal.dim,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: (spots.length - 1).toDouble(),
                                  minY:
                                      spots
                                          .map((spot) => spot.y)
                                          .reduce(
                                            (a, b) => math.min(a, b).toDouble(),
                                          ) *
                                      0.92,
                                  maxY:
                                      spots
                                          .map((spot) => spot.y)
                                          .reduce(
                                            (a, b) => math.max(a, b).toDouble(),
                                          ) *
                                      1.08,
                                  titlesData: const FlTitlesData(
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 10,
                                  ),
                                  lineTouchData: const LineTouchData(
                                    enabled: false,
                                  ),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      barWidth: 2.5,
                                      color: Pal.ice,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Pal.ice.withValues(alpha: 0.08),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 13,
                            color: Pal.dim,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Открыть подробный график',
                            style: TextStyle(color: Pal.dim, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseHistoryEntry extends ConsumerWidget {
  final Exercise exercise;
  final double bodyWeight;
  final VoidCallback onTap;

  const _ExerciseHistoryEntry({
    required this.exercise,
    required this.bodyWeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(exerciseHistoryProvider(exercise.id));

    return history.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();

        final values = sessions
            .map(
              (session) => session.best1rm(
                OneRmFormula.average,
                bodyWeight: bodyWeight,
                exerciseName: exercise.name,
                equipment: exercise.equipment,
              ),
            )
            .toList();

        final latest = values.last;
        final bestSet = sessions
            .expand((session) => session.sets)
            .where((set) => set.reps > 0)
            .fold<SetData?>(null, (current, set) {
              if (current == null) return set;
              if (set.weight > current.weight) return set;
              if (set.weight == current.weight && set.reps > current.reps) {
                return set;
              }
              return current;
            });
        final recordLabel = _recordSetLabel(
          exercise: exercise,
          set: bestSet,
          bodyWeight: bodyWeight,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Pal.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Pal.line),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.show_chart_rounded,
                      color: Pal.ice,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sessions.length} тренировок · '
                            'лучший подход $recordLabel',
                            style: const TextStyle(
                              color: Pal.dim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      latest > 0 ? '${_format1(latest)} кг 1RM' : '—',
                      style: const TextStyle(
                        color: Pal.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Pal.dim),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniMetric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Pal.dim, fontSize: 10)),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor ?? Pal.text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeading({
    required this.title,
    required this.trailing,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!))
        else
          Text(
            trailing,
            style: const TextStyle(
              color: Pal.dim,
              fontSize: 10,
              letterSpacing: 0.8,
            ),
          ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String text;

  const _ErrorPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Pal.line),
      ),
      child: Text(text, style: const TextStyle(color: Pal.hot, fontSize: 12)),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onTap;

  const _EmptyPanel({
    required this.title,
    required this.subtitle,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pal.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Pal.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: Pal.dim, fontSize: 12, height: 1.4),
          ),
          if (action != null && onTap != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onTap, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

class _SavedProgramCard extends StatelessWidget {
  const _SavedProgramCard();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final raw = snapshot.data?.getString('savedTrainingProgram');
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (raw == null || raw.isEmpty) {
          return Material(
            color: Pal.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgramGeneratorScreen(),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Pal.line),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Pal.ice, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Персональная программа',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Составить план под свои цели и предпочтения',
                            style: TextStyle(color: Pal.dim, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Pal.dim),
                  ],
                ),
              ),
            ),
          );
        }

        Map<String, dynamic> program;
        try {
          program = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          return const SizedBox.shrink();
        }
        final options = program['options'] is Map
            ? Map<String, dynamic>.from(program['options'] as Map)
            : <String, dynamic>{};
        final days = program['days'] is List
            ? program['days'] as List
            : const [];
        final completed =
            (snapshot.data?.getStringList('programCompletedDays') ?? [])
                .map(int.tryParse)
                .whereType<int>()
                .toSet();
        final goal = switch (options['goal']) {
          'strength' => 'Сила',
          'general' => 'Общее развитие',
          _ => 'Рост мышц',
        };

        return Material(
          color: Pal.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgramGeneratorScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Pal.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x1F49D18D),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF49D18D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Моя программа',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$goal · ${options['daysPerWeek'] ?? days.length} тренировок в неделю',
                          style: const TextStyle(color: Pal.dim, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Закрыто ${completed.length} из ${days.length} тренировок',
                          style: const TextStyle(
                            color: Color(0xFF49D18D),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Pal.dim),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AttendanceHeatmap extends StatelessWidget {
  final List<Workout> workouts;
  const _AttendanceHeatmap({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthNames = const [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    final visited = <int>{};
    for (final workout in workouts) {
      final finished = workout.finishedAt;
      if (finished == null) continue;
      if (finished.year == now.year && finished.month == now.month) {
        visited.add(finished.day);
      }
    }
    final visitCount = visited.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Pal.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Посещения зала',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${monthNames[first.month - 1]} ${now.year}',
                style: const TextStyle(color: Pal.dim, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '$visitCount ${_visitWord(visitCount)} в этом месяце',
            style: const TextStyle(color: Pal.dim, fontSize: 12),
          ),
          const SizedBox(height: 13),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 40,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              if (day > daysInMonth) {
                return Opacity(
                  opacity: 0.06,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Pal.dim,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }
              final attended = visited.contains(day);
              final date = DateTime(now.year, now.month, day);
              final future = date.isAfter(
                DateTime(now.year, now.month, now.day),
              );
              final color = attended
                  ? const Color(0xFF49D18D)
                  : future
                  ? Pal.surface2
                  : const Color(0xFF454D58);
              return Tooltip(
                message:
                    '$day ${monthNames[now.month - 1]}${attended ? ' · тренировка' : ''}',
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Нет тренировки',
                style: TextStyle(color: Pal.dim, fontSize: 10),
              ),
              const Spacer(),
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF49D18D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Был в зале',
                style: TextStyle(color: Pal.dim, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _visitWord(int count) {
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'посещений';
    return switch (count % 10) {
      1 => 'посещение',
      2 || 3 || 4 => 'посещения',
      _ => 'посещений',
    };
  }
}
