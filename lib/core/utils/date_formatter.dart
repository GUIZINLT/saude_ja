/// Formatação de datas em português, sem depender do pacote intl.
class DateFormatter {
  DateFormatter._();

  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// "Qui, 26 nov 2026", como no card de consulta do protótipo.
  static String shortDate(DateTime d) =>
      '${weekdayShort(d)}, ${d.day} ${_months[d.month - 1].substring(0, 3)} '
      '${d.year}';

  /// "Qui"
  static String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

  /// "Novembro 2026", título do seletor de datas.
  static String monthYear(DateTime d) {
    final month = _months[d.month - 1];
    return '${month[0].toUpperCase()}${month.substring(1)} ${d.year}';
  }
}
