class Expense {
  int? id;
  String? title;
  double? cost;
  String? date;

  Expense({
    this.id,
    this.title,
    this.cost,
    this.date,
  });

  Expense.fromMap(Map map) {
    id = map['ID'];
    title = map['TITLE'];
    cost = map['COST'];
    date = map['DATE'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'TITLE': title,
      'COST': cost,
      'DATE': date,
    };
    if (id != null) {
      map['ID'] = id;
    }
    return map;
  }
}
