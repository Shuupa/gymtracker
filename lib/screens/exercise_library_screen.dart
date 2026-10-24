import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exercise_picker_screen.dart';
import '../data/exercise_descriptions.dart';
import '../logic/muscle_groups.dart';
import '../ui/mini_body.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'exercise_picker_screen.dart'; // Берем существующий catalogProvider

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

String equipmentRu(dynamic equipment) {
  final name = equipment.toString().split('.').last.toLowerCase();
  switch (name) {
    case 'barbell':
      return 'Штанга';
    case 'dumbbell':
      return 'Гантели';
    case 'machine':
      return 'Тренажёр';
    case 'cable':
      return 'Блок';
    case 'bodyweight':
      return 'Свой вес';
    case 'kettlebell':
      return 'Гиря';
    case 'ezbar':
      return 'EZ-гриф';
    case 'smith':
      return 'Смит';
    case 'none':
      return 'Без инвентаря';
    default:
      return 'Инвентарь';
  }
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
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _selectedGroup = null),
              tooltip: 'Сбросить фильтр',
            ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка загрузки: $err')),
        data: (items) {
          // Фильтрация по основной группе мышц (логика из muscle_groups.dart)
          final filtered =
              items.where((item) {
                  if (_selectedGroup == null) return true;
                  final primary = primaryMuscleGroup(item.shareMap);
                  return primary?.name == _selectedGroup!.name;
                }).toList()
                ..sort((a, b) => a.exercise.name.compareTo(b.exercise.name));

          return Column(
            children: [
              // Панель выбора групп мышц (чипсы)
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                      onSelected: (_) {
                        setState(() {
                          _selectedGroup = selected ? null : group;
                        });
                      },
                      selectedColor: Pal.ember.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: selected ? Pal.ember : Pal.dim,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      side: BorderSide(color: selected ? Pal.ember : Pal.line),
                    );
                  },
                ),
              ),

              // Список упражнений
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'В этой группе нет упражнений',
                          style: TextStyle(color: Pal.dim),
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

                          // Подсвечиваем все мышцы, которые задействованы в упражнении
                          final highlight = item.shareMap.keys.toSet();
                          // Если основная группа не определена, показываем все тело (fallback)
                          final back = primaryGroup?.back ?? false;
                          final crop =
                              primaryGroup?.crop ??
                              const Rect.fromLTWH(0, 0, 200, 440);

                          final description =
                              exerciseDescriptions[item.exercise.name] ??
                              'Описание временно отсутствует.';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Pal.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Pal.line),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Векторная графика: MiniBody из твоего проекта
                                  Container(
                                    width: 80,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: MiniBody(
                                      highlight: highlight,
                                      back: back,
                                      crop: crop,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.exercise.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${equipmentRu(item.exercise.equipment)} · ${primaryGroup?.name ?? "Разное"}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Pal.dim,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          description,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Проценты задействованных мышц (как в ExercisePicker)
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: item.shares.take(3).map((
                                            e,
                                          ) {
                                            return Text(
                                              '${e.key} ${(e.value * 100).round()}%',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Pal.dim,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
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
