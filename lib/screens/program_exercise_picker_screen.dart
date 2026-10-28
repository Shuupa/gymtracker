import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../logic/muscle_groups.dart';
import '../ui/mini_body.dart';
import '../ui/glass.dart';
import '../ui/theme.dart';
import 'exercise_picker_screen.dart' show CatalogItem, catalogProvider;

/// Returns {'excluded': [...], 'priority': [...]} when the user taps Save.
class ProgramExercisePickerScreen extends ConsumerStatefulWidget {
  final Set<int> excludedIds;
  final Set<int> priorityIds;

  const ProgramExercisePickerScreen({
    super.key,
    required this.excludedIds,
    required this.priorityIds,
  });

  @override
  ConsumerState<ProgramExercisePickerScreen> createState() =>
      _ProgramExercisePickerScreenState();
}

class _ProgramExercisePickerScreenState
    extends ConsumerState<ProgramExercisePickerScreen> {
  late Set<int> _excluded;
  late Set<int> _priority;
  MuscleGroup? _group;
  String _query = '';
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _excluded = Set<int>.from(widget.excludedIds);
    _priority = Set<int>.from(widget.priorityIds);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleExcluded(int id) {
    setState(() {
      if (_excluded.remove(id)) return;
      _priority.remove(id);
      _excluded.add(id);
    });
  }

  void _togglePriority(int id) {
    setState(() {
      if (_priority.remove(id)) return;
      _excluded.remove(id);
      _priority.add(id);
    });
  }

  void _save() {
    Navigator.pop<Map<String, List<int>>>(context, {
      'excluded': _excluded.toList(),
      'priority': _priority.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    return GlassScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_query.isNotEmpty) {
              _search.clear();
              setState(() => _query = '');
            } else if (_group != null) {
              setState(() => _group = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(_group?.name ?? 'Настроить упражнения'),
        actions: [TextButton(onPressed: _save, child: const Text('Готово'))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Поиск упражнения',
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                _legend(
                  const Color(0xFFFF453A),
                  'Исключить ${_excluded.length}',
                ),
                const SizedBox(width: 12),
                _legend(const Color(0xFF30D158), 'Упор ${_priority.length}'),
              ],
            ),
          ),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Ошибка загрузки: $error')),
              data: (items) {
                if (_query.isEmpty && _group == null) return _groupGrid(items);
                final query = _query.toLowerCase();
                final filtered =
                    items.where((item) {
                      if (query.isNotEmpty) {
                        return item.exercise.name.toLowerCase().contains(query);
                      }
                      final primary = primaryMuscleGroup(item.shareMap);
                      return primary?.name == _group?.name;
                    }).toList()..sort(
                      (a, b) => a.exercise.name.compareTo(b.exercise.name),
                    );
                return _exerciseList(filtered);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: FilledButton(
          onPressed: _save,
          child: Text(
            'Сохранить выбор · исключено ${_excluded.length} · упор ${_priority.length}',
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) => Expanded(
    child: Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Pal.dim),
          ),
        ),
      ],
    ),
  );

  Widget _groupGrid(List<CatalogItem> items) => GridView.count(
    crossAxisCount: 3,
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.8,
    children: [
      for (final group in muscleGroups)
        Material(
          color: Pal.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _group = group),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${items.where((item) => primaryMuscleGroup(item.shareMap)?.name == group.name).length} упр.',
                    style: const TextStyle(color: Pal.dim, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
    ],
  );

  Widget _exerciseList(List<CatalogItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Упражнения не найдены', style: TextStyle(color: Pal.dim)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item.exercise.id;
        final excluded = _excluded.contains(id);
        final priority = _priority.contains(id);
        final border = excluded
            ? const Color(0xFFFF453A)
            : priority
            ? const Color(0xFF30D158)
            : Pal.line;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: excluded
                ? const Color(0x22FF453A)
                : priority
                ? const Color(0x1F30D158)
                : Pal.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: excluded || priority ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.exercise.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.shares
                    .take(3)
                    .map(
                      (entry) => '${entry.key} ${(entry.value * 100).round()}%',
                    )
                    .join(' · '),
                style: const TextStyle(color: Pal.dim, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF453A),
                        side: BorderSide(
                          color: excluded ? const Color(0xFFFF453A) : Pal.line,
                        ),
                        backgroundColor: excluded
                            ? const Color(0x22FF453A)
                            : Colors.transparent,
                      ),
                      onPressed: () => _toggleExcluded(id),
                      icon: Icon(
                        excluded
                            ? Icons.block_rounded
                            : Icons.remove_circle_outline_rounded,
                        size: 17,
                      ),
                      label: Text(excluded ? 'Исключено' : 'Исключить'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF30D158),
                        side: BorderSide(
                          color: priority ? const Color(0xFF30D158) : Pal.line,
                        ),
                        backgroundColor: priority
                            ? const Color(0x1F30D158)
                            : Colors.transparent,
                      ),
                      onPressed: () => _togglePriority(id),
                      icon: Icon(
                        priority
                            ? Icons.check_circle_rounded
                            : Icons.trending_up_rounded,
                        size: 17,
                      ),
                      label: Text(priority ? 'Приоритет' : 'Сделать упор'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
