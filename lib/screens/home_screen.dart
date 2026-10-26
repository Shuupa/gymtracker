import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exercise_library_screen.dart';
import 'program_generator_screen.dart';
import '../format.dart';
import '../logic/summaries.dart';
import '../providers.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context, WorkoutSummary summary) {
    return confirmDialog(
      context,
      title: 'Удалить тренировку?',
      text:
          '${fmtDay(summary.workout.startedAt)} · '
          '${summary.setCount} подходов · '
          '${summary.exerciseCount} упражнений.\n\n'
          'Это действие нельзя отменить.',
    );
  }

  void _openWorkout(BuildContext context, WorkoutSummary summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => summary.isFinished
            ? ReportScreen(workoutId: summary.workout.id)
            : WorkoutScreen(workoutId: summary.workout.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(workoutSummariesProvider);
    final db = ref.read(dbProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Обзор'),
        actions: [
          IconButton(
            tooltip: 'Библиотека упражнений',
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExerciseLibraryScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Генератор программы',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgramGeneratorScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Профиль',
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить тренировки:\n$error'),
          ),
        ),
        data: (workouts) {
          final now = DateTime.now();
          final weekStart = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6));

          final week = workouts.where((item) {
            final date = item.workout.startedAt;
            return !date.isBefore(weekStart) && !date.isAfter(now);
          }).toList();

          final weekSets = week.fold<int>(
            0,
            (sum, item) => sum + item.setCount,
          );

          final weekVolume = week.fold<double>(
            0,
            (sum, item) => sum + item.volume,
          );

          final active = workouts.where((item) => !item.isFinished).toList();
          final history = workouts.where((item) => item.isFinished).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              _ActivityPanel(
                workouts: workouts,
                weekCount: week.length,
                weekSets: weekSets,
                weekVolume: weekVolume,
                weekDuration: week.fold<Duration>(
                  Duration.zero,
                  (sum, item) => sum + (item.duration ?? Duration.zero),
                ),
              ),
              const SizedBox(height: 28),

              if (active.isNotEmpty) ...[
                const _SectionHeading(
                  title: 'Текущая тренировка',
                  trailing: 'В ПРОЦЕССЕ',
                ),
                const SizedBox(height: 10),
                for (final item in active)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _WorkoutCard(
                      summary: item,
                      onTap: () => _openWorkout(context, item),
                      onDelete: () async {
                        final confirmed = await _confirmDelete(context, item);
                        if (confirmed) {
                          await db.deleteWorkout(item.workout.id);
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 20),
              ],

              _SectionHeading(
                title: 'История',
                trailing: '${history.length} тренировок',
              ),
              const SizedBox(height: 14),

              if (history.isEmpty)
                const _EmptyHistory()
              else
                _HistoryList(
                  history: history,
                  onOpen: (item) => _openWorkout(context, item),
                  onDelete: (item) async {
                    final confirmed = await _confirmDelete(context, item);
                    if (confirmed) {
                      await db.deleteWorkout(item.workout.id);
                    }
                  },
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final id = await db.startWorkout();
          if (!context.mounted) return;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkoutScreen(workoutId: id)),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Новая тренировка'),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  final List<WorkoutSummary> workouts;
  final int weekCount;
  final int weekSets;
  final double weekVolume;
  final Duration weekDuration;

  const _ActivityPanel({
    required this.workouts,
    required this.weekCount,
    required this.weekSets,
    required this.weekVolume,
    required this.weekDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A42), Color(0xFF0F1928)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Pal.line),
        boxShadow: [
          BoxShadow(
            color: Pal.ice.withValues(alpha: 0.06),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'АКТИВНОСТЬ',
                    style: TextStyle(
                      color: Pal.dim,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Pal.ice.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Pal.ice.withValues(alpha: 0.35)),
                  ),
                  child: const Text(
                    '7 ДНЕЙ',
                    style: TextStyle(
                      color: Pal.ice,
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _MainMetric(
                    value: _fmtWeekDuration(weekDuration),
                    label: 'В зале',
                  ),
                ),
                Expanded(
                  child: _MainMetric(value: '$weekSets', label: 'Подходы'),
                ),
                Expanded(
                  child: _MainMetric(
                    value: fmtVolume(weekVolume),
                    label: 'Объём',
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Pal.line.withValues(alpha: 0.7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            child: _WeekActivityChart(workouts: workouts),
          ),
        ],
      ),
    );
  }
}

class _MainMetric extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;

  const _MainMetric({
    required this.value,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              color: Pal.text,
              fontSize: compact ? 19 : 28,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Pal.dim, fontSize: 11)),
      ],
    );
  }
}

class _WeekActivityChart extends StatelessWidget {
  final List<WorkoutSummary> workouts;

  const _WeekActivityChart({required this.workouts});

  static const _weekdays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);

    final days = List.generate(
      7,
      (index) => midnight.subtract(Duration(days: 6 - index)),
    );

    final minutes = days.map((day) {
      return workouts
          .where((item) {
            final date = item.workout.startedAt;
            return date.year == day.year &&
                date.month == day.month &&
                date.day == day.day;
          })
          .fold<int>(0, (sum, item) {
            final d = item.duration;
            return sum + (d == null ? 0 : d.inMinutes);
          });
    }).toList();

    final maxMinutes = minutes.fold<int>(
      0,
      (maximum, m) => m > maximum ? m : maximum,
    );

    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(7, (index) {
          final mins = minutes[index];
          final isToday =
              days[index].year == today.year &&
              days[index].month == today.month &&
              days[index].day == today.day;

          final hasWorkout = mins > 0;

          final barHeight = hasWorkout
              ? 12.0 + 48.0 * mins / (maxMinutes == 0 ? 1 : maxMinutes)
              : 4.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                    child: Center(
                      child: Text(
                        hasWorkout ? '${mins}м' : '',
                        style: const TextStyle(
                          color: Pal.ice,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 12,
                          decoration: BoxDecoration(
                            color: Pal.surface2.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 12,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: hasWorkout
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Pal.ice, Pal.cold],
                                  )
                                : null,
                            color: hasWorkout ? null : Pal.line,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: hasWorkout
                                ? [
                                    BoxShadow(
                                      color: Pal.ice.withValues(alpha: 0.30),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _weekdays[days[index].weekday - 1],
                    style: TextStyle(
                      color: isToday ? Pal.ice : Pal.dim,
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeading({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: Pal.dim,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WorkoutCard({
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final workout = summary.workout;
    final isActive = !summary.isFinished;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [const Color(0xFF1A2A42), const Color(0xFF0F1928)]
                  : [const Color(0xFF141C29), const Color(0xFF0C121C)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? Pal.ice.withValues(alpha: 0.55) : Pal.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Pal.ice, Pal.cold],
                            )
                          : null,
                      color: isActive ? null : Pal.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.fitness_center_rounded
                          : Icons.check_rounded,
                      color: isActive ? const Color(0xFF07111C) : Pal.dim,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fmtDay(workout.startedAt),
                          style: const TextStyle(
                            color: Pal.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive
                              ? 'Начата в ${fmtTime(workout.startedAt)}'
                              : '${fmtTime(workout.startedAt)}'
                                    '  ·  ${fmtDuration(summary.duration!)}',
                          style: const TextStyle(color: Pal.dim, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (isActive) const Pill('Активна', color: Pal.ice),
                  PopupMenuButton<String>(
                    tooltip: 'Действия',
                    icon: const Icon(Icons.more_horiz_rounded, color: Pal.dim),
                    onSelected: (_) => onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Удалить')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _WorkoutValue(
                    value: '${summary.exerciseCount}',
                    label: 'Упражнений',
                  ),
                  const SizedBox(width: 20),
                  _WorkoutValue(
                    value: '${summary.setCount}',
                    label: 'Подходов',
                  ),
                  const SizedBox(width: 20),
                  _WorkoutValue(
                    value: fmtVolume(summary.volume),
                    label: 'Объём',
                  ),
                ],
              ),
              if (summary.exerciseNames.isNotEmpty) ...[
                const SizedBox(height: 13),
                Container(height: 1, color: Pal.line.withValues(alpha: 0.7)),
                const SizedBox(height: 10),
                Text(
                  summary.exerciseNames.join('  ·  '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Pal.dim,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutValue extends StatelessWidget {
  final String value;
  final String label;

  const _WorkoutValue({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Pal.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Pal.dim, fontSize: 10)),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Pal.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.receipt_long_outlined, color: Pal.dim, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Нет завершённых тренировок',
                  style: TextStyle(
                    color: Pal.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Здесь появится история занятий.',
                  style: TextStyle(color: Pal.dim, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtWeekDuration(Duration d) {
  if (d.inMinutes <= 0) return '0м';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h <= 0) return '${m}м';
  if (m == 0) return '${h}ч';
  return '${h}ч ${m}м';
}

class _HistoryList extends StatefulWidget {
  final List<WorkoutSummary> history;
  final void Function(WorkoutSummary) onOpen;
  final Future<void> Function(WorkoutSummary) onDelete;

  const _HistoryList({
    required this.history,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items = _expanded ? widget.history : widget.history.take(3).toList();
    final canExpand = widget.history.length > 3;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _WorkoutCard(
              summary: item,
              onTap: () => widget.onOpen(item),
              onDelete: () => widget.onDelete(item),
            ),
          ),
        if (canExpand)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded
                    ? 'Свернуть'
                    : 'Показать ещё (${widget.history.length - 3})',
                style: const TextStyle(
                  color: Pal.ice,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
