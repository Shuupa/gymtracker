import 'package:flutter/material.dart';

import 'theme.dart';

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? text,
  String ok = 'Удалить',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: text == null ? null : Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Отмена', style: TextStyle(color: Pal.dim)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ok, style: const TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Плитка со значением и подписью. Растягивается (Expanded) внутри Row.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  const StatTile(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Pal.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Pal.dim, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, {super.key, this.color = Pal.ember});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Pal.ice,
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
