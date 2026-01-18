class Expense {
  final String? docId;
  final String name;
  final double amount;
  final String? description;
  // final String? whopaid;
  // final int? groupId;
  // final String? category;

  Expense({
    this.docId,
    this.name = "",
    this.amount = 0,
    this.description
    // required this.username
  });

  Expense copy ({
    String? docId,
    String? name,
    double? amount,
    String? description
  }){
    return Expense(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "name": name,
      "amount": amount,
      "description": description
    };
  }

  static Expense fromMap(Map<String, dynamic> map){
    return Expense(
      name: map["name"] ?? "",
      amount: map["amount"] ?? "",
      description: map["description"] ?? ""
    );
  }

  @override
  String toString() {
    return "Expense($docId, $name, $amount, $description)";
  }
}
