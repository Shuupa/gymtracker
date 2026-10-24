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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 112),
            children: [
              _ActivityPanel(
                workouts: workouts,
                weekCount: week.length,
                weekSets: weekSets,
                weekVolume: weekVolume,
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
              const SizedBox(height: 10),

              if (history.isEmpty)
                const _EmptyHistory()
              else
                for (final item in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey('workout-${item.workout.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context, item),
                      onDismissed: (_) {
                        db.deleteWorkout(item.workout.id);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 22),
                        decoration: BoxDecoration(
                          color: Pal.hot.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Pal.hot,
                        ),
                      ),
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

  const _ActivityPanel({
    required this.workouts,
    required this.weekCount,
    required this.weekSets,
    required this.weekVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Pal.line),
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
                    color: Pal.ice.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(8),
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
                  child: _MainMetric(value: '$weekCount', label: 'Тренировки'),
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
          Container(height: 1, color: Pal.line),
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
              fontWeight: FontWeight.w700,
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

    final counts = days.map((day) {
      return workouts.where((item) {
        final date = item.workout.startedAt;
        return date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      }).length;
    }).toList();

    final maxCount = counts.fold<int>(
      0,
      (maximum, count) => count > maximum ? count : maximum,
    );

    return Column(
      children: [
        SizedBox(
          height: 92,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (index) {
              final count = counts[index];
              final isToday =
                  days[index].year == today.year &&
                  days[index].month == today.month &&
                  days[index].day == today.day;

              final hasWorkout = count > 0;

              final barHeight = hasWorkout
                  ? 12.0 + 48.0 * count / (maxCount == 0 ? 1 : maxCount)
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
                            hasWorkout ? '$count' : '',
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
                                color: Pal.surface2,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 12,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: hasWorkout ? Pal.ice : Pal.line,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: hasWorkout
                                    ? [
                                        BoxShadow(
                                          color: Pal.ice.withValues(
                                            alpha: 0.18,
                                          ),
                                          blurRadius: 10,
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
                          fontWeight: isToday
                              ? FontWeight.w800
                              : FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
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
              fontWeight: FontWeight.w700,
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
      color: Pal.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? Pal.ice.withValues(alpha: 0.65) : Pal.line,
            ),
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
                      color: isActive
                          ? Pal.ice.withValues(alpha: 0.12)
                          : Pal.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.fitness_center_rounded
                          : Icons.check_rounded,
                      color: isActive ? Pal.ice : Pal.dim,
                      size: 19,
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
                            fontWeight: FontWeight.w700,
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
                Container(height: 1, color: Pal.line.withValues(alpha: 0.8)),
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
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
        borderRadius: BorderRadius.circular(16),
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
