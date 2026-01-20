class Expense {
  final String? docId;
  final String name;
  final double amount;
  final String? description;
  // final String whopaid;
  final int? groupId;
  // final String? category;

  Expense({
    this.docId,
    this.name = "",
    this.amount = 0,
    this.description,
    // this.whopaid = "",
    this.groupId
  });

  Expense copy ({
    String? docId,
    String? name,
    double? amount,
    String? description,
    // String? whopaid,
    // The reason i am using groupName for this, 
    // is so that i can display groupName in personal expenses
    String? groupName
  }){
    return Expense(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      // whopaid: whopaid ?? this.whopaid
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "name": name,
      "amount": amount,
      "description": description,
      // "whopaid": whopaid,
      "groupId": groupId
    };
  }

  static Expense fromMap(Map<String, dynamic> map){
    return Expense(
      name: map["name"] ?? "",
      amount: map["amount"] ?? "",
      description: map["description"] ?? ""
      // whopaid: map["description"]
    );
  }

  @override
  String toString() {
    return "Expense($docId, $name, $amount, $description, $groupId)";
  }
}
