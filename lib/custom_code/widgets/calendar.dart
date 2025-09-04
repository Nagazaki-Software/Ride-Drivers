// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// ===== Cores no escopo do arquivo (visíveis para todas as classes abaixo) =====
const Color _bg = Color(0xFFF59E0B); // Laranja
const Color _bgDark = Color(0xFFF08C00);
const Color _tile = Colors.white;
const Color _tileMuted = Color(0xFFFFD08A);
const Color _textPrimary = Colors.black87;
const Color _textMuted = Colors.black54;

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // Mês visível (primeiro dia do mês)
  DateTime _visibleMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selected;

  // Marcadores de exemplo (pontos) para agosto/2025
  // chave = data exata; valor = qtd de pontos (1–3).
  final Map<DateTime, int> _markers = {
    DateTime(2025, 8, 3): 1,
    DateTime(2025, 8, 5): 1,
    DateTime(2025, 8, 6): 2,
    DateTime(2025, 8, 11): 3,
    DateTime(2025, 8, 22): 3,
    DateTime(2025, 8, 28): 1,
  };

  void _gotoPrev() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _gotoNext() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  String _monthLabel(DateTime m) {
    final months = const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[m.month - 1]} ${m.year}';
  }

  int _daysInMonth(DateTime m) {
    final nextMonth = DateTime(m.year, m.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  int _startWeekday(DateTime m) {
    // Queremos calendário começando no domingo. DateTime.weekday: Seg=1..Dom=7
    final mondayFirst = DateTime(m.year, m.month, 1).weekday; // 1..7
    final sundayIndex = mondayFirst % 7; // 0..6 onde 0 = Domingo
    return sundayIndex;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _markerCountFor(DateTime day) {
    for (final entry in _markers.entries) {
      if (_isSameDay(entry.key, day)) return entry.value.clamp(1, 3);
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // Para abrir já em Agosto/2025 (como no screenshot), mantenha:
    _visibleMonth = DateTime(2025, 8, 1);
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? double.infinity;
    final height = widget.height ?? 420;

    final theme = Theme.of(context);
    final textStyleHeader = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    final startPad =
        _startWeekday(_visibleMonth); // 0..6 espaços antes do dia 1
    final totalDays = _daysInMonth(_visibleMonth);
    final totalCells =
        ((startPad + totalDays) <= 35) ? 35 : 42; // 5 ou 6 linhas

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_bg, _bgDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        children: [
          // Cabeçalho
          _Header(
            label: _monthLabel(_visibleMonth),
            onPrev: _gotoPrev,
            onNext: _gotoNext,
          ),
          const SizedBox(height: 8),
          // Linha de dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Weekday('S'),
              _Weekday('M'),
              _Weekday('T'),
              _Weekday('W'),
              _Weekday('T'),
              _Weekday('F'),
              _Weekday('S'),
            ],
          ),
          const SizedBox(height: 8),
          // Grade
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellSpacing = 8.0;
                final cellWidth =
                    (constraints.maxWidth - cellSpacing * 6) / 7.0;
                final cellHeight = (constraints.maxHeight - cellSpacing * 5) /
                    (totalCells / 7);

                List<Widget> cells = [];

                // Blocos iniciais em branco
                for (int i = 0; i < startPad; i++) {
                  cells.add(_BlankCell(
                    w: cellWidth,
                    h: cellHeight,
                  ));
                }

                // Dias do mês
                for (int d = 1; d <= totalDays; d++) {
                  final date =
                      DateTime(_visibleMonth.year, _visibleMonth.month, d);
                  final isToday = _isSameDay(date, DateTime.now());
                  final isSelected =
                      _selected != null && _isSameDay(date, _selected!);
                  final dots = _markerCountFor(date);

                  cells.add(GestureDetector(
                    onTap: () => setState(() => _selected = date),
                    child: _DayCell(
                      w: cellWidth,
                      h: cellHeight,
                      day: d,
                      dots: dots,
                      isToday: isToday,
                      isSelected: isSelected,
                    ),
                  ));
                }

                // Blocos finais em branco
                while (cells.length < totalCells) {
                  cells.add(_BlankCell(
                    w: cellWidth,
                    h: cellHeight,
                  ));
                }

                return Wrap(
                  spacing: cellSpacing,
                  runSpacing: cellSpacing,
                  children: cells,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Cabeçalho com label do mês e botões circulares de navegação
class _Header extends StatelessWidget {
  const _Header({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
          ),
        ),
        _RoundIconButton(
          icon: Icons.chevron_left,
          onTap: onPrev,
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.chevron_right,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
        ),
      ),
    );
  }
}

class _BlankCell extends StatelessWidget {
  const _BlankCell({required this.w, required this.h});
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1B0), // laranja claro
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.w,
    required this.h,
    required this.day,
    required this.dots,
    required this.isToday,
    required this.isSelected,
  });

  final double w;
  final double h;
  final int day;
  final int dots; // 0..3
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: _tile,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? Colors.black87
              : (isToday ? Colors.black54 : Colors.transparent),
          width: isSelected ? 2 : (isToday ? 1.2 : 0),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 0.5,
            spreadRadius: 0,
            offset: Offset(0, 0.25),
            color: Color(0x22000000),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
          ),
          const Spacer(),
          if (dots > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(dots, (i) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.only(right: i == dots - 1 ? 0 : 4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
