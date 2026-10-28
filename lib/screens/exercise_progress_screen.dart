import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_database.dart';
import '../format.dart';
import '../logic/one_rm.dart';
import '../providers.dart';
import '../ui/glass.dart';
import '../ui/theme.dart';

class ExerciseProgressScreen extends ConsumerStatefulWidget {
  final Exercise exercise;
  const ExerciseProgressScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseProgressScreen> createState() => _State();
}

class _State extends ConsumerState<ExerciseProgressScreen> {
  OneRmFormula _formula = OneRmFormula.average;
  double _bodyWeight = 80;

  @override
  void initState() {
    super.initState();
    _loadBodyWeight();
  }

  Future<void> _loadBodyWeight() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _bodyWeight = prefs.getDouble('bodyWeight') ?? 80);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(exerciseHistoryProvider(widget.exercise.id));
    final scheme = Theme.of(context).colorScheme;

    return GlassScaffold(
      appBar: AppBar(title: Text(widget.exercise.name)),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text('Нет данных. Заверши тренировку с этим упражнением'),
            );
          }
          final values = sessions
              .map(
                (s) => s.best1rm(
                  _formula,
                  bodyWeight: _bodyWeight,
                  exerciseName: widget.exercise.name,
                  equipment: widget.exercise.equipment,
                ),
              )
              .toList();
          final spots = [
            for (var i = 0; i < values.length; i++)
              if (values[i] > 0) FlSpot(i.toDouble(), values[i]),
          ];
          final best = values.fold(0.0, (m, v) => v > m ? v : m);
          final delta = values.length >= 2
              ? values.last - values[values.length - 2]
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Pal.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Pal.line),
                ),
                child: SegmentedButton<OneRmFormula>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide.none,
                    selectedBackgroundColor: Pal.accent,
                    selectedForegroundColor: const Color(0xFFFFFFFF),
                    foregroundColor: Pal.dim,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: OneRmFormula.average,
                      label: Text('Среднее', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: OneRmFormula.epley,
                      label: Text('Epley', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: OneRmFormula.brzycki,
                      label: Text('Brzycki', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: OneRmFormula.lombardi,
                      label: Text('Lombardi', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  selected: {_formula},
                  onSelectionChanged: (s) => setState(() => _formula = s.first),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Stat(
                    'Макс. 1RM',
                    '${fmtNum(_r(best))} кг',
                    accent: Pal.accent,
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    'Последняя',
                    '${fmtNum(_r(values.last))} кг',
                    accent: Pal.steel,
                  ),
                  const SizedBox(width: 8),
                  _Stat(
                    'К прошлой',
                    delta == null
                        ? '—'
                        : '${delta >= 0 ? '+' : ''}${fmtNum(_r(delta))} кг',
                    accent: delta == null
                        ? Pal.dim
                        : (delta >= 0 ? Pal.success : Pal.hot),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Расчётный 1rm',
                style: TextStyle(
                  color: Pal.dim,
                  fontSize: 11,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                decoration: BoxDecoration(
                  color: Pal.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Pal.line),
                ),
                child: SizedBox(
                  height: 220,
                  child: spots.length < 2
                      ? const Center(
                          child: Text(
                            'Для графика нужно минимум 2 тренировки',
                            style: TextStyle(color: Pal.dim),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            titlesData: const FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 34,
                                  interval: 20,
                                  getTitlesWidget: _leftTitle,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: Pal.line.withValues(alpha: 0.5),
                                strokeWidth: 1,
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                color: scheme.primary,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, _, __, ___) =>
                                      FlDotCirclePainter(
                                        radius: 3,
                                        color: scheme.primary,
                                        strokeWidth: 2,
                                        strokeColor: Pal.bg,
                                      ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Pal.accent.withValues(alpha: 0.25),
                                      Pal.accent.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'История',
                style: TextStyle(
                  color: Pal.dim,
                  fontSize: 11,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              for (final s in sessions.reversed)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Pal.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Pal.line),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fmtDate(s.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              s.sets
                                  .map((e) => '${fmtNum(e.weight)}×${e.reps}')
                                  .join(', '),
                              style: const TextStyle(
                                color: Pal.dim,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Pal.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'объём ${fmtNum(_r(s.effectiveVolume(bodyWeight: _bodyWeight, exerciseName: widget.exercise.name, equipment: widget.exercise.equipment)))}',
                          style: const TextStyle(
                            color: Pal.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _r(double v) => (v * 10).round() / 10;
}

Widget _leftTitle(double value, TitleMeta meta) {
  return Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Text(
      value.toInt().toString(),
      style: const TextStyle(color: Pal.dim, fontSize: 11),
      textAlign: TextAlign.right,
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _Stat(this.label, this.value, {required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Pal.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Pal.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Pal.dim, fontSize: 11)),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
