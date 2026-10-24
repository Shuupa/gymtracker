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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          fmtDay(w.startedAt),
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 13, color: Pal.dim),
            const SizedBox(width: 5),
            Text(
              '${fmtTime(w.startedAt)} · ${fmtDuration(r.duration)}',
              style: const TextStyle(color: Pal.dim, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Pal.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Pal.line),
            ),
            child: BodyMap(
              colors: colors,
              onMuscleTap: (m) => setState(() => _selected = m),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: sel == null
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.touch_app_outlined, size: 14, color: Pal.dim),
                      SizedBox(width: 6),
                      Text(
                        'Нажми на мышцу',
                        style: TextStyle(
                          color: Pal.dim,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Pal.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Pal.line),
                    ),
                    child: Text(
                      load[sel] == null
                          ? '$sel: не работала'
                          : '$sel · ${load[sel]!.toStringAsFixed(1)} эфф. подходов',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          const _HeatBar(),
          const SizedBox(height: 16),
          for (final e in ranking)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      e.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: maxLoad == 0 ? 0 : e.value / maxLoad,
                        minHeight: 7,
                        backgroundColor: Pal.surface2,
                        color: colors[e.key],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 30,
                    child: Text(
                      e.value.toStringAsFixed(1),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Pal.dim,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SectionTitle('Упражнения'),
        for (final ex in r.exercises)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF161F2E), Color(0xFF0C121C)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Pal.line),
            ),
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
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (ex.best1rm > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Pal.hot.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Pal.hot.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '1RM ≈ ${fmtNum((ex.best1rm * 10).round() / 10)}',
                          style: const TextStyle(
                            color: Pal.hot,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
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
                          border: Border.all(color: Pal.line),
                        ),
                        child: Text(
                          '${fmtNum(s.weight)}×${s.reps}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 12,
                      color: Pal.dim,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Тоннаж: ${fmtVolume(ex.volume)}',
                      style: const TextStyle(color: Pal.dim, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HeatBar extends StatelessWidget {
  const _HeatBar();
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
              style: TextStyle(color: Pal.dim, fontSize: 10),
            ),
            Text('больше', style: TextStyle(color: Pal.dim, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
