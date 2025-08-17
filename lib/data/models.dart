class MyDay {
  final String date;
  final bool cleanedTeethMorning;
  final bool cleanedTeethEvening;

  const MyDay({
    required this.date,
    required this.cleanedTeethEvening,
    required this.cleanedTeethMorning,
  });

  Map<String, Object?> toMap() {
    return {
      'date': date,
      'cleanedTeethMorning': cleanedTeethMorning ? 1 : 0,
      'cleanedTeethEvening': cleanedTeethEvening ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'MyDay{date: $date, cleanedTeethMorning: $cleanedTeethMorning, cleanedTeethEvening: $cleanedTeethEvening}';
  }
}


class Activity {
  final int? id;
  final String date;
  final int duration;
  final String category;

  const Activity({
    this.id,
    required this.date,
    required this.duration,
    required this.category,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'Activity{id: $id, date: $date, duration: $duration, category: $category}';
  }
}


class ActivityCategory {
  final int? id;
  final String category;

  const ActivityCategory({
    this.id,
    required this.category,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'Activity{id: $id, category: $category}';
  }
}