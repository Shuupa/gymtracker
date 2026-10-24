import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../format.dart';
import '../logic/muscle_groups.dart';
import '../providers.dart';
import '../ui/mini_body.dart';
import '../ui/theme.dart';

class CatalogItem {
  final Exercise exercise;
  final List<MapEntry<String, double>> shares;
  final Map<String, double> shareMap;

  CatalogItem(this.exercise, this.shares)
    : shareMap = {for (final entry in shares) entry.key: entry.value};
}

final catalogProvider = FutureProvider.autoDispose<List<CatalogItem>>((
  ref,
) async {
  final db = ref.watch(dbProvider);
  final exercises = await db.select(db.exercises).get();
  final links = await db.exerciseMuscleLinks();
  final byExercise = <int, Map<String, double>>{};
  for (final link in links) {
    (byExercise[link.exerciseId] ??= {})[link.muscle] = link.share;
  }
  return [
    for (final exercise in exercises)
      CatalogItem(
        exercise,
        (byExercise[exercise.id]?.entries.toList() ??
              <MapEntry<String, double>>[])
          ..sort((a, b) => b.value.compareTo(a.value)),
      ),
  ];
});

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() => _PickerState();
}

class _PickerState extends ConsumerState<ExercisePickerScreen> {
  MuscleGroup? _group;
  String _query = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _back() {
    if (_query.isNotEmpty) {
      _search.clear();
      setState(() => _query = '');
    } else {
      setState(() => _group = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final canPop = _group == null && _query.isEmpty;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => canPop ? Navigator.pop(context) : _back(),
          ),
          title: Text(_group?.name ?? 'Выбор упражнения'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Поиск по всем упражнениям',
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            Expanded(
              child: catalog.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Ошибка: $error\n$stack'),
                ),
                data: (items) {
                  if (_query.isNotEmpty) {
                    final query = _query.toLowerCase();
                    final found =
                        items
                            .where(
                              (item) => item.exercise.name
                                  .toLowerCase()
                                  .contains(query),
                            )
                            .toList()
                          ..sort(
                            (a, b) =>
                                a.exercise.name.compareTo(b.exercise.name),
                          );
                    return _list(found, null);
                  }
                  if (_group == null) return _grid(items);

                  final group = _group!;
                  final inGroup =
                      items.where((item) {
                        final primary = primaryMuscleGroup(item.shareMap);
                        return primary?.name == group.name;
                      }).toList()..sort((a, b) {
                        final shareOrder = groupShare(
                          group,
                          b.shareMap,
                        ).compareTo(groupShare(group, a.shareMap));
                        return shareOrder != 0
                            ? shareOrder
                            : a.exercise.name.compareTo(b.exercise.name);
                      });
                  return _list(inGroup, group);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<CatalogItem> items) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: [
        for (final group in muscleGroups)
          Material(
            color: Pal.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _group = group),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Pal.line),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          // СНОВА ТВОЙ РОДНОЙ MINIBODY (КАК НА ФОТО 1)
                          child: MiniBody(
                            highlight: group.muscles.toSet(),
                            back: group.back,
                            crop: group.crop,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '${items.where((item) => primaryMuscleGroup(item.shareMap)?.name == group.name).length} упр.',
                      style: const TextStyle(color: Pal.dim, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _list(List<CatalogItem> items, MuscleGroup? group) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Ничего не найдено',
          style: TextStyle(color: Pal.dim, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        final primary = primaryMuscleGroup(item.shareMap);
        final back = primary?.back ?? false;
        final crop = primary?.crop ?? const Rect.fromLTWH(0, 0, 200, 440);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Pal.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => Navigator.pop(context, item.exercise.id),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Pal.line),
                ),
                child: Row(
                  children: [
                    // И ТУТ ТОЖЕ MINIBODY ВМЕСТО ПАЛОЧЕК
                    Container(
                      width: 65,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: MiniBody(
                        highlight: item.shareMap.keys.toSet(),
                        back: back,
                        crop: crop,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.exercise.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Pal.ice.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              equipmentRu(item.exercise.equipment),
                              style: const TextStyle(
                                color: Pal.ice,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _MuscleShares(item: item, group: group),
                        ],
                      ),
                    ),
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

class _MuscleShares extends StatelessWidget {
  final CatalogItem item;
  final MuscleGroup? group;

  const _MuscleShares({required this.item, required this.group});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in item.shares.take(3))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (group != null && group!.muscles.contains(entry.key))
                  ? Pal.purple.withValues(alpha: 0.2)
                  : Pal.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (group != null && group!.muscles.contains(entry.key))
                    ? Pal.purple.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Text(
              '${entry.key} ${(entry.value * 100).round()}%',
              style: TextStyle(
                color: (group != null && group!.muscles.contains(entry.key))
                    ? Pal.purple
                    : Pal.dimLight,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
