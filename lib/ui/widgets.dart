import 'package:flutter/material.dart';

import 'theme.dart';

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? text,
  String ok = 'Удалить',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Pal.hot, size: 28),
      title: Text(title),
      content: text == null ? null : Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Отмена', style: TextStyle(color: Pal.dim)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Pal.hot,
            foregroundColor: const Color(0xFF20090C),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ok),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Метрический тайл. Красивее за счёт мягкого градиента и более чистой иерархии.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? accent;

  const StatTile(this.value, this.label, {super.key, this.icon, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Pal.ice;
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2435), Color(0xFF101822)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Pal.line.withValues(alpha: 0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 8),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Pal.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  letterSpacing: -0.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Pal.dim,
                fontSize: 11.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, {super.key, this.color = Pal.ice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;
  const SectionTitle(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: Pal.dim,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: Pal.dim, fontSize: 12)),
      ],
    ),
  );
}

/// Премиальная панель с мягким градиентом и опциональной подсветкой.
class ArcPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final VoidCallback? onTap;
  final bool gradient;

  const ArcPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.onTap,
    this.gradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2435), Color(0xFF0E1420)],
              )
            : null,
        color: gradient ? null : Pal.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent?.withValues(alpha: 0.5) ?? Pal.line,
          width: 1,
        ),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.ac_unit_rounded,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A2435), Color(0xFF0E1420)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Pal.line),
              boxShadow: [
                BoxShadow(
                  color: Pal.ice.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, size: 32, color: Pal.ice),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Pal.dim),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
