import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../format.dart';
import '../logic/one_rm.dart';
import '../providers.dart';

class ExerciseProgressScreen extends ConsumerStatefulWidget {
  final Exercise exercise;
  const ExerciseProgressScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseProgressScreen> createState() => _State();
}

class _State extends ConsumerState<ExerciseProgressScreen> {
  OneRmFormula _formula = OneRmFormula.average;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(exerciseHistoryProvider(widget.exercise.id));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
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
          final values = sessions.map((s) => s.best1rm(_formula)).toList();
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
              SegmentedButton<OneRmFormula>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: OneRmFormula.average,
                    label: Text('Среднее'),
                  ),
                  ButtonSegment(
                    value: OneRmFormula.epley,
                    label: Text('Epley'),
                  ),
                  ButtonSegment(
                    value: OneRmFormula.brzycki,
                    label: Text('Brzycki'),
                  ),
                  ButtonSegment(
                    value: OneRmFormula.lombardi,
                    label: Text('Lombardi'),
                  ),
                ],
                selected: {_formula},
                onSelectionChanged: (s) => setState(() => _formula = s.first),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat('Рекорд 1RM', '${fmtNum(_r(best))} кг'),
                  _Stat('Последняя', '${fmtNum(_r(values.last))} кг'),
                  _Stat(
                    'К прошлой',
                    delta == null
                        ? '—'
                        : '${delta >= 0 ? '+' : ''}${fmtNum(_r(delta))} кг',
                    color: delta == null
                        ? null
                        : (delta >= 0 ? Colors.greenAccent : Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Расчётный 1RM по тренировкам',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: spots.length < 2
                    ? const Center(
                        child: Text('Для графика нужно минимум 2 тренировки'),
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
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(drawVerticalLine: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 3,
                              color: scheme.primary,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Text('История', style: Theme.of(context).textTheme.titleSmall),
              for (final s in sessions.reversed)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(fmtDate(s.date)),
                  subtitle: Text(
                    s.sets
                        .map((e) => '${fmtNum(e.weight)}×${e.reps}')
                        .join(', '),
                  ),
                  trailing: Text('объём ${fmtNum(_r(s.volume))}'),
                ),
            ],
          );
        },
      ),
    );
  }

  double _r(double v) => (v * 10).round() / 10; // округляем до 0.1
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _Stat(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
