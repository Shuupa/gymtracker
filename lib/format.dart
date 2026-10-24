String fmtNum(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

String _p(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime d) =>
    '${_p(d.day)}.${_p(d.month)}.${d.year}  ${_p(d.hour)}:${_p(d.minute)}';

const _wd = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
const _mon = [
  'янв',
  'фев',
  'мар',
  'апр',
  'мая',
  'июн',
  'июл',
  'авг',
  'сен',
  'окт',
  'ноя',
  'дек',
];

String fmtDay(DateTime d) =>
    '${_wd[d.weekday - 1]}, ${d.day} ${_mon[d.month - 1]}';

String fmtTime(DateTime d) => '${_p(d.hour)}:${_p(d.minute)}';

String fmtDuration(Duration d) {
  if (d.inMinutes < 1) return '< 1 мин';
  if (d.inMinutes < 60) return '${d.inMinutes} мин';
  return '${d.inHours} ч ${d.inMinutes % 60} мин';
}

String fmtVolume(double v) => v >= 1000
    ? '${(v / 1000).toStringAsFixed(1)} т'
    : '${fmtNum(v.roundToDouble())} кг';

String equipmentRu(String e) => switch (e) {
  'barbell' => 'штанга',
  'dumbbell' => 'гантели',
  'machine' => 'тренажёр',
  'bodyweight' => 'свой вес',
  _ => e,
};
