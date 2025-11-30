enum ActivityFilter {
  today,
  all,
  sevenDays,
  upcoming,
  completed
}

extension ActivityFilterExtension on ActivityFilter {
  String get displayName {
    switch (this) {
      case ActivityFilter.today:
        return 'Hoy';
      case ActivityFilter.all:
        return 'Todas';
      case ActivityFilter.sevenDays:
        return '7 Días';
      case ActivityFilter.upcoming:
        return 'Próximas';
      case ActivityFilter.completed:
        return 'Completadas';
    }
  }
}