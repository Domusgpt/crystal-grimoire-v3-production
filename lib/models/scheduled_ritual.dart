// lib/models/scheduled_ritual.dart

class ScheduledRitual {
  final String id;
  final String moonPhase;
  final String ritualName;
  final DateTime scheduledDate;
  bool isCompleted;

  ScheduledRitual({
    required this.id,
    required this.moonPhase,
    required this.ritualName,
    required this.scheduledDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'moonPhase': moonPhase,
    'ritualName': ritualName,
    'scheduledDate': scheduledDate.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory ScheduledRitual.fromJson(Map<String, dynamic> json) => ScheduledRitual(
    id: json['id'] as String,
    moonPhase: json['moonPhase'] as String,
    ritualName: json['ritualName'] as String,
    scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );

  ScheduledRitual copyWith({
    String? id,
    String? moonPhase,
    String? ritualName,
    DateTime? scheduledDate,
    bool? isCompleted,
  }) {
    return ScheduledRitual(
      id: id ?? this.id,
      moonPhase: moonPhase ?? this.moonPhase,
      ritualName: ritualName ?? this.ritualName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
