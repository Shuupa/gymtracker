import '../ui/exercise_demo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exercise_descriptions.dart';
import '../format.dart';
import '../logic/muscle_groups.dart';
import '../ui/mini_body.dart';
import '../ui/theme.dart';
import 'exercise_picker_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  MuscleGroup? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Библиотека упражнений'),
        actions: [
          if (_selectedGroup != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () => setState(() => _selectedGroup = null),
              tooltip: 'Сбросить фильтр',
            ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка загрузки: $err')),
        data: (items) {
          final filtered =
              items.where((item) {
                  if (_selectedGroup == null) return true;
                  final primary = primaryMuscleGroup(item.shareMap);
                  return primary?.name == _selectedGroup!.name;
                }).toList()
                ..sort((a, b) => a.exercise.name.compareTo(b.exercise.name));

          return Column(
            children: [
              // Панель фильтров
              SizedBox(
                height: 60,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: muscleGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final group = muscleGroups[index];
                    final selected = _selectedGroup?.name == group.name;
                    return ChoiceChip(
                      label: Text(group.name),
                      selected: selected,
                      onSelected: (_) => setState(
                        () => _selectedGroup = selected ? null : group,
                      ),
                      selectedColor: Pal.purple.withValues(alpha: 0.25),
                      labelStyle: TextStyle(
                        color: selected ? Pal.purple : Pal.dim,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: selected ? Pal.purple : Pal.line,
                        width: 1.5,
                      ),
                    );
                  },
                ),
              ),
              // Список упражнений
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'В этой группе нет упражнений',
                          style: TextStyle(color: Pal.dim, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final primaryGroup = primaryMuscleGroup(
                            item.shareMap,
                          );
                          final highlight = item.shareMap.keys.toSet();
                          final back = primaryGroup?.back ?? false;
                          final crop =
                              primaryGroup?.crop ??
                              const Rect.fromLTWH(0, 0, 200, 440);

                          final description =
                              exerciseDescriptions[item.exercise.name] ??
                              'Описание временно отсутствует.';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Pal.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Pal.line),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ТВОЙ КРАСИВЫЙ MINI BODY
                                      Container(
                                        width: 80,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: MiniBody(
                                          highlight: highlight,
                                          back: back,
                                          crop: crop,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.exercise.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Pal.ice.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    equipmentRu(
                                                      item.exercise.equipment,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Pal.ice,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  primaryGroup?.name ??
                                                      'Разное',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Pal.dim,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              description,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.45,
                                                color: Pal.dimLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ExerciseDemo(name: item.exercise.name),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: item.shares.take(4).map((e) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Pal.surface2,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${e.key} ${(e.value * 100).round()}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Pal.dim,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
