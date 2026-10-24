import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/seed.dart' show muscleNames;
import '../format.dart';
import '../logic/muscle_strength.dart';
import '../logic/working_sets.dart';
import '../providers.dart';
import '../ui/body_map.dart';
import '../ui/levels.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _weightCtrl = TextEditingController();
  double _bw = 80;
  bool _male = true;
  String? _selected;
  Future<Map<String, MuscleResult>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _bw = p.getDouble('bodyWeight') ?? 80;
    _male = p.getBool('isMale') ?? true;
    _weightCtrl.text = fmtNum(_bw);
    _recalc();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('bodyWeight', _bw);
    await p.setBool('isMale', _male);
  }

  void _recalc() {
    setState(() {
      _future = _calc();
    });
  }

  Future<Map<String, MuscleResult>> _calc() async {
    final db = ref.read(dbProvider);
    final sets = await loadWorkingSets(db);
    final links = await db.exerciseMuscleLinks();
    return muscleScores(
      sets: sets,
      links: links,
      bodyWeight: _bw,
      isMale: _male,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Вес тела, кг'),
                  onChanged: (v) {
                    final w = double.tryParse(v.replaceAll(',', '.'));
                    if (w == null || w <= 0) return;
                    _bw = w;
                    _save();
                    _recalc();
                  },
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('М')),
                  ButtonSegment(value: false, label: Text('Ж')),
                ],
                selected: {_male},
                onSelectionChanged: (s) {
                  _male = s.first;
                  _save();
                  _recalc();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, MuscleResult>>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) {
                return Text('Ошибка: ${snap.error}\n${snap.stackTrace}');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _body(context, snap.data!);
            },
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, Map<String, MuscleResult> res) {
    final colors = {
      for (final e in res.entries) e.key: levelColor(e.value.score),
    };
    final ranking = res.entries.toList()
      ..sort((a, b) => a.value.score.compareTo(b.value.score));
    final weakest = ranking.take(3).toList();
    final strongest = ranking.reversed.take(3).toList();
    final noData = muscleNames.where((m) => !res.containsKey(m)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyMap(
          colors: colors,
          onMuscleTap: (m) => setState(() => _selected = m),
        ),
        const SizedBox(height: 10),
        const LevelLegend(),
        const SizedBox(height: 14),
        _MuscleInfo(
          name: _selected,
          result: _selected == null ? null : res[_selected],
        ),
        if (res.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              'Заверши тренировку с любыми упражнениями, и мышцы окрасятся по уровню силы.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Pal.dim),
            ),
          )
        else ...[
          const SectionTitle('Сильнее всего'),
          for (final e in strongest) _MuscleRow(e.key, e.value),
          const SectionTitle('Подтянуть'),
          for (final e in weakest) _MuscleRow(e.key, e.value),
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
      return const Center(
        child: Text('Нажми на мышцу', style: TextStyle(color: Pal.dim)),
      );
    }
    final r = result;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Pal.line),
      ),
      child: r == null
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
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Pill(levelName(r.score), color: levelColor(r.score)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: r.score,
                    minHeight: 8,
                    backgroundColor: Pal.surface2,
                    color: levelColor(r.score),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Лучшие упражнения для этой мышцы',
                  style: TextStyle(color: Pal.dim, fontSize: 12),
                ),
                const SizedBox(height: 4),
                for (final s in r.sources)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text(s.exercise)),
                        Text(
                          levelName(s.score),
                          style: TextStyle(
                            color: levelColor(s.score),
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
  final MuscleResult r;
  const _MuscleRow(this.name, this.r);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: r.score,
                minHeight: 8,
                backgroundColor: Pal.surface2,
                color: levelColor(r.score),
              ),
            ),
          ),
          SizedBox(
            width: 76,
            child: Text(
              levelName(r.score),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: levelColor(r.score),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
