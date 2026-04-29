class Budget {
  final int? budgetId;
  final int userId;
  final String nama;
  final String? datetime;

  Budget({
    this.budgetId,
    required this.userId,
    required this.nama,
    this.datetime,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'user_id': userId,
      'nama': nama,
      'datetime': datetime,
    };
    if (budgetId != null) map['budget_id'] = budgetId!;
    return map;
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      budgetId: map['budget_id'],
      userId: map['user_id'],
      nama: map['nama'],
      datetime: map['datetime'],
    );
  }
}
