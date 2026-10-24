import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format.dart';
import '../logic/report.dart';
import '../providers.dart';
import '../ui/body_map.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'workout_screen.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final int workoutId;
  const ReportScreen({super.key, required this.workoutId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String? _selected;

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Удалить тренировку?',
      text: 'Это действие нельзя отменить.',
    );
    if (!ok || !mounted) return;
    final db = ref.read(dbProvider);
    Navigator.pop(context);
    await db.deleteWorkout(widget.workoutId);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(reportProvider(widget.workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Итоги'),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutScreen(workoutId: widget.workoutId),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (_) => _delete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Удалить тренировку')),
            ],
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка: $e\n$st'),
        ),
        data: (r) => r == null ? const SizedBox() : _content(context, r),
      ),
    );
  }

  Widget _content(BuildContext context, WorkoutReport r) {
    final w = r.workout;
    final load = r.muscleLoad;
    final maxLoad = load.values.fold(0.0, (m, v) => v > m ? v : m);
    final colors = <String, Color>{
      for (final e in load.entries)
        e.key: heatColor(maxLoad == 0 ? 0 : 0.2 + 0.8 * (e.value / maxLoad)),
    };
    final ranking = load.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sel = _selected;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Text(
          fmtDay(w.startedAt),
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          '${fmtTime(w.startedAt)} · ${fmtDuration(r.duration)}',
          style: const TextStyle(color: Pal.dim),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            StatTile('${r.exercises.length}', 'упражнений'),
            const SizedBox(width: 8),
            StatTile('${r.setCount}', 'подходов'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            StatTile(fmtVolume(r.volume), 'тоннаж'),
            const SizedBox(width: 8),
            StatTile(fmtDuration(r.duration), 'время'),
          ],
        ),
        const SectionTitle('Какие мышцы поработали'),
        if (load.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Нет рабочих подходов',
                style: TextStyle(color: Pal.dim),
              ),
            ),
          )
        else ...[
          BodyMap(
            colors: colors,
            onMuscleTap: (m) => setState(() => _selected = m),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              sel == null
                  ? 'Нажми на мышцу'
                  : (load[sel] == null
                        ? '$sel: не работала'
                        : '$sel: ${load[sel]!.toStringAsFixed(1)} эфф. подх.'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          _HeatBar(),
          const SizedBox(height: 14),
          for (final e in ranking)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      e.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: maxLoad == 0 ? 0 : e.value / maxLoad,
                        minHeight: 8,
                        backgroundColor: Pal.surface2,
                        color: colors[e.key],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      e.value.toStringAsFixed(1),
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Pal.dim),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SectionTitle('Упражнения'),
        for (final ex in r.exercises)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ex.exercise.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (ex.best1rm > 0)
                        Text(
                          '1RM ≈ ${fmtNum((ex.best1rm * 10).round() / 10)}',
                          style: const TextStyle(
                            color: Pal.hot,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in ex.sets)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Pal.surface2,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${fmtNum(s.weight)}×${s.reps}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Тоннаж: ${fmtVolume(ex.volume)}',
                    style: const TextStyle(color: Pal.dim, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HeatBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [for (var i = 0; i <= 10; i++) heatColor(0.2 + 0.08 * i)],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'меньше нагрузки',
              style: TextStyle(color: Pal.dim, fontSize: 11),
            ),
            Text('больше', style: TextStyle(color: Pal.dim, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
