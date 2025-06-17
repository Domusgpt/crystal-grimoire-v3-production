import 'package:flutter/foundation.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final List<String> moodTags;
  final List<String> crystalIdsUsed;
  final String? moonPhase;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    List<String>? moodTags,
    List<String>? crystalIdsUsed,
    this.moonPhase,
  })  : moodTags = moodTags ?? [],
        crystalIdsUsed = crystalIdsUsed ?? [];

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      moodTags: json['moodTags'] != null ? List<String>.from(json['moodTags']) : [],
      crystalIdsUsed: json['crystalIdsUsed'] != null ? List<String>.from(json['crystalIdsUsed']) : [],
      moonPhase: json['moonPhase'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'moodTags': moodTags,
      'crystalIdsUsed': crystalIdsUsed,
      'moonPhase': moonPhase,
    };
  }

  // Optional: A copyWith method can be useful for state management
  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    List<String>? moodTags,
    List<String>? crystalIdsUsed,
    String? moonPhase,
    bool setMoonPhaseNull = false, // Explicitly set moonPhase to null
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      moodTags: moodTags ?? this.moodTags,
      crystalIdsUsed: crystalIdsUsed ?? this.crystalIdsUsed,
      moonPhase: setMoonPhaseNull ? null : moonPhase ?? this.moonPhase,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          date == other.date &&
          listEquals(moodTags, other.moodTags) &&
          listEquals(crystalIdsUsed, other.crystalIdsUsed) &&
          moonPhase == other.moonPhase;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      date.hashCode ^
      moodTags.hashCode ^
      crystalIdsUsed.hashCode ^
      moonPhase.hashCode;
}