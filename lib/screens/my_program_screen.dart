import 'package:flutter/material.dart';

import '../logic/program_library.dart';
import '../ui/glass.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'custom_programs_screen.dart';

/// Библиотека своих программ: тяжёлая, лёгкая, делоад и любые другие.
/// Закрывается со значением `true`, если активная программа изменилась.
class MyProgramsScreen extends StatefulWidget {
  const MyProgramsScreen({super.key});

  @override
  State<MyProgramsScreen> createState() => _MyProgramsScreenState();
}

class _MyProgramsScreenState extends State<MyProgramsScreen> {
  List<SavedProgram> _items = [];
  String? _activeId;
  bool _loading = true;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await loadProgramLibrary();
    final active = await activeProgramId();
    if (!mounted) return;
    setState(() {
      _items = items;
      _activeId = active;
      _loading = false;
    });
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _edit(SavedProgram? p) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomProgramScreen(
          initial: p?.program,
          savedId: p?.id,
          savedName: p?.name,
        ),
      ),
    );
    if (saved == true) _changed = true;
    await _reload();
  }

  Future<void> _activate(SavedProgram p) async {
    await activateProgram(p);
    _changed = true;
    await _reload();
    if (mounted) _snack('Включена: ${p.name}');
  }

  Future<void> _duplicate(SavedProgram p) async {
    await upsertProgram(
      SavedProgram(
        id: newProgramId(),
        name: '${p.name} (копия)',
        program: p.program,
        updatedAt: DateTime.now(),
      ),
    );
    await _reload();
  }

  Future<void> _delete(SavedProgram p) async {
    final ok = await confirmDialog(
      context,
      title: 'Удалить «${p.name}»?',
      text: 'Программа пропадёт из списка. Если она сейчас включена, останется как текущая.',
    );
    if (!ok) return;
    await deleteProgram(p.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: GlassScaffold(
        appBar: AppBar(
          title: const Text('Мои программы'),
          actions: [
            IconButton(
              tooltip: 'Новая программа',
              onPressed: () => _edit(null),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
            ? _empty()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [for (final p in _items) _card(p)],
              ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Пока нет сохранённых программ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Собери тяжёлую, лёгкую или делоад-программу и переключайся между ними.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Pal.dim, fontSize: 15),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _edit(null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Создать программу'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(SavedProgram p) {
    final active = p.id == _activeId;
    final dayTitles = p.program.days.map((d) => d.title).join(' / ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
      decoration: BoxDecoration(
        color: Pal.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? Pal.accent : Pal.line,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Pal.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Активна',
                    style: TextStyle(
                      color: Pal.onAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'duplicate':
                      _duplicate(p);
                    case 'delete':
                      _delete(p);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'duplicate', child: Text('Дублировать')),
                  PopupMenuItem(value: 'delete', child: Text('Удалить')),
                ],
              ),
            ],
          ),
          Text(
            '${p.program.days.length} дн., ${p.exerciseCount} упр.',
            style: const TextStyle(color: Pal.dim, fontSize: 13),
          ),
          if (dayTitles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                dayTitles,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Pal.dimLight, fontSize: 13),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: active ? null : () => _activate(p),
                    child: Text(active ? 'Включена' : 'Включить'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _edit(p),
                    child: const Text('Изменить'),
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
