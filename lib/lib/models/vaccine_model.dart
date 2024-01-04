class Vaccine {
  final String id;
  final String name;
  final String dosageCount;
  final int ageDuration;
  final String start;
  final String end;
  final String? dateApplied;
  final String? weight;
  final String? height;
  final String? cardImage;

  Vaccine({
    required this.id,
    required this.name,
    required this.dosageCount,
    required this.ageDuration,
    required this.start,
    required this.end,
    this.dateApplied,
    this.weight,
    this.height,
    this.cardImage,
  });
}

class VaccineRecord {
  final String vaccineId;
  final String name;
  final int age;
  final DateTime dueDate;
  String status;
  final int? nextDueInWeeks;
  bool isDone;
  DateTime? givenDate;

  VaccineRecord(
      {required this.vaccineId,
      required this.name,
      required this.age,
      required this.dueDate,
      this.status = '',
      required this.nextDueInWeeks,
      this.isDone = false,
      this.givenDate});
}
