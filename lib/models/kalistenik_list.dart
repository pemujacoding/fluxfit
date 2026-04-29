class KalistenikList {
  final int? listId;
  final int levelId;
  final int kalistenikId;
  final int? setCount;

  KalistenikList({
    this.listId,
    required this.levelId,
    required this.kalistenikId,
    this.setCount,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'level_id': levelId,
      'kalistenik_id': kalistenikId,
      'set_count': setCount,
    };
    if (listId != null) map['list_id'] = listId!;
    return map;
  }

  factory KalistenikList.fromMap(Map<String, dynamic> map) {
    return KalistenikList(
      listId: map['list_id'],
      levelId: map['level_id'],
      kalistenikId: map['kalistenik_id'],
      setCount: map['set_count'],
    );
  }
}
