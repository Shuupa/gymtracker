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

/// Выбор упражнения: сначала карточки групп мышц, затем список упражнений.
/// Возвращает id выбранного упражнения через Navigator.pop(context, id).
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => canPop ? Navigator.pop(context) : _back(),
          ),
          title: Text(_group?.name ?? 'Упражнение'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
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
      childAspectRatio: 0.8,
      children: [
        for (final group in muscleGroups)
          _GroupTile(
            group: group,
            count: items
                .where(
                  (item) =>
                      primaryMuscleGroup(item.shareMap)?.name == group.name,
                )
                .length,
            onTap: () => setState(() => _group = group),
          ),
      ],
    );
  }

  Widget _list(List<CatalogItem> items, MuscleGroup? group) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Ничего не найдено', style: TextStyle(color: Pal.dim)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            item.exercise.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _MuscleShares(item: item, group: group),
          ),
          trailing: Text(
            equipmentRu(item.exercise.equipment),
            style: const TextStyle(color: Pal.dim, fontSize: 12),
          ),
          onTap: () => Navigator.pop(context, item.exercise.id),
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
    final spans = <InlineSpan>[];
    for (var index = 0; index < item.shares.length; index++) {
      final entry = item.shares[index];
      final highlighted = group != null && group!.muscles.contains(entry.key);
      if (index > 0) {
        spans.add(
          const TextSpan(
            text: '  ·  ',
            style: TextStyle(color: Pal.line),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: '${entry.key} ${(entry.value * 100).round()}%',
          style: TextStyle(
            color: highlighted ? Pal.ember : Pal.dim,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      );
    }
    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 12.5, height: 1.35),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final MuscleGroup group;
  final int count;
  final VoidCallback onTap;

  const _GroupTile({
    required this.group,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Pal.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Pal.line),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: MiniBody(
                      highlight: group.muscles.toSet(),
                      back: group.back,
                      crop: group.crop,
                    ),
                  ),
                ),
              ),
              Text(
                group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                '$count упр.',
                style: const TextStyle(color: Pal.dim, fontSize: 11),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
