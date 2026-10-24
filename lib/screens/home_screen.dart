import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<bool> _confirmDelete(BuildContext context, WorkoutSummary s) {
    return confirmDialog(
      context,
      title: 'Удалить тренировку?',
      text:
          '${fmtDay(s.workout.startedAt)}: ${s.setCount} подх., '
          '${s.exerciseCount} упр. Это действие нельзя отменить.',
    );
  }

  void _open(BuildContext context, WorkoutSummary s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => s.isFinished
            ? ReportScreen(workoutId: s.workout.id)
            : WorkoutScreen(workoutId: s.workout.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(workoutSummariesProvider);
    final db = ref.read(dbProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ac_unit, size: 56, color: Pal.cold),
                  SizedBox(height: 12),
                  Text('Пока пусто', style: TextStyle(color: Pal.dim)),
                  Text('Жми «Начать»', style: TextStyle(color: Pal.dim)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: list.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) return _WeekHeader(list);
              final s = list[i - 1];
              return Dismissible(
                key: ValueKey('w${s.workout.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(ctx, s),
                onDismissed: (_) => db.deleteWorkout(s.workout.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: _WorkoutCard(
                  s: s,
                  onTap: () => _open(ctx, s),
                  onDelete: () async {
                    if (await _confirmDelete(ctx, s)) {
                      await db.deleteWorkout(s.workout.id);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.bolt),
        label: const Text(
          'Начать',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        onPressed: () async {
          final id = await db.startWorkout();
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkoutScreen(workoutId: id)),
          );
        },
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final List<WorkoutSummary> list;
  const _WeekHeader(this.list);

  @override
  Widget build(BuildContext context) {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final week = list.where((s) => s.workout.startedAt.isAfter(from)).toList();
    final vol = week.fold(0.0, (a, s) => a + s.volume);
    final sets = week.fold(0, (a, s) => a + s.setCount);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Pal.ember.withValues(alpha: 0.18), Pal.surface],
          ),
          border: Border.all(color: Pal.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ЗА 7 ДНЕЙ',
              style: TextStyle(
                color: Pal.ice,
                fontSize: 12,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StatTile('${week.length}', 'тренировок'),
                const SizedBox(width: 8),
                StatTile('$sets', 'подходов'),
                const SizedBox(width: 8),
                StatTile(fmtVolume(vol), 'тоннаж'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutSummary s;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _WorkoutCard({
    required this.s,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final w = s.workout;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: s.isFinished ? Pal.line : Pal.ember),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fmtDay(w.startedAt),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          s.isFinished
                              ? '${fmtTime(w.startedAt)} · ${fmtDuration(s.duration!)}'
                              : 'с ${fmtTime(w.startedAt)}',
                          style: const TextStyle(color: Pal.dim),
                        ),
                      ],
                    ),
                  ),
                  if (!s.isFinished) const Pill('В процессе'),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Pal.dim),
                    onSelected: (_) => onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Удалить тренировку'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    StatTile('${s.exerciseCount}', 'упражнений'),
                    const SizedBox(width: 8),
                    StatTile('${s.setCount}', 'подходов'),
                    const SizedBox(width: 8),
                    StatTile(fmtVolume(s.volume), 'тоннаж'),
                  ],
                ),
              ),
              if (s.exerciseNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    s.exerciseNames.join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Pal.dim, fontSize: 13),
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
