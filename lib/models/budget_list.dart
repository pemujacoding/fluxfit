class BudgetList {
  final int? listId;
  final int budgetId;
  final int alatId;
  final int? jumlah;

  BudgetList({
    this.listId,
    required this.budgetId,
    required this.alatId,
    this.jumlah,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'budget_id': budgetId,
      'alat_id': alatId,
      'jumlah': jumlah,
    };
    if (listId != null) map['list_id'] = listId!;
    return map;
  }

  factory BudgetList.fromMap(Map<String, dynamic> map) {
    return BudgetList(
      listId: map['list_id'],
      budgetId: map['budget_id'],
      alatId: map['alat_id'],
      jumlah: map['jumlah'],
    );
  }
}
