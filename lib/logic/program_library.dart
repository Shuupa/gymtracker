import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'program_codec.dart';
import 'program_generator.dart';

const _libraryKey = 'programLibrary';
const _activeIdKey = 'activeProgramId';
const _activeProgramKey = 'savedTrainingProgram';
const _completedKey = 'programCompletedDays';

/// Программа в личной библиотеке (тяжёлая, лёгкая, делоад и т.д.).
class SavedProgram {
  final String id;
  final String name;
  final GeneratedProgram program;
  final DateTime updatedAt;

  const SavedProgram({
    required this.id,
    required this.name,
    required this.program,
    required this.updatedAt,
  });

  SavedProgram copyWith({
    String? id,
    String? name,
    GeneratedProgram? program,
  }) => SavedProgram(
    id: id ?? this.id,
    name: name ?? this.name,
    program: program ?? this.program,
    updatedAt: DateTime.now(),
  );

  int get exerciseCount =>
      program.days.fold<int>(0, (sum, d) => sum + d.exercises.length);
}

String newProgramId() => DateTime.now().microsecondsSinceEpoch.toString();

Future<List<SavedProgram>> loadProgramLibrary() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_libraryKey);
  if (raw == null) return [];
  final result = <SavedProgram>[];
  try {
    for (final item in jsonDecode(raw) as List<dynamic>) {
      try {
        final map = item as Map<String, dynamic>;
        result.add(
          SavedProgram(
            id: map['id'] as String,
            name: map['name'] as String,
            updatedAt:
                DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
                DateTime.now(),
            program: programFromMap(map['program'] as Map<String, dynamic>),
          ),
        );
      } catch (_) {
        // битую запись пропускаем, остальные остаются
      }
    }
  } catch (_) {}
  return result;
}

Future<void> _writeLibrary(
  SharedPreferences prefs,
  List<SavedProgram> items,
) async {
  await prefs.setString(
    _libraryKey,
    jsonEncode([
      for (final p in items)
        {
          'id': p.id,
          'name': p.name,
          'updatedAt': p.updatedAt.toIso8601String(),
          'program': programToMap(p.program),
        },
    ]),
  );
}

Future<String?> activeProgramId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_activeIdKey);
}

/// Сбрасывает связь активной программы с библиотекой (например, после генерации).
Future<void> clearActiveProgramId() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_activeIdKey);
}

/// Добавляет программу или заменяет существующую с тем же id.
Future<void> upsertProgram(SavedProgram program) async {
  final prefs = await SharedPreferences.getInstance();
  final items = await loadProgramLibrary();
  final index = items.indexWhere((p) => p.id == program.id);
  if (index >= 0) {
    items[index] = program;
  } else {
    items.insert(0, program);
  }
  await _writeLibrary(prefs, items);
}

Future<void> deleteProgram(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final items = await loadProgramLibrary();
  items.removeWhere((p) => p.id == id);
  await _writeLibrary(prefs, items);
  if (prefs.getString(_activeIdKey) == id) {
    await prefs.remove(_activeIdKey); // сама активная программа остаётся
  }
}

/// Делает программу активной: именно её видит экран программы и тренировки.
Future<void> activateProgram(
  SavedProgram program, {
  bool resetProgress = true,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _activeProgramKey,
    jsonEncode(programToMap(program.program)),
  );
  await prefs.setString(_activeIdKey, program.id);
  if (resetProgress) {
    await prefs.setStringList(_completedKey, <String>[]);
  }
}
