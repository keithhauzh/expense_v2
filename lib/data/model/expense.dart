class Expense {
  final String? docId;
  final String name;
  final double amount;
  final String? description;
  // final String whopaid;
  final String? groupName;
  final String? categoryName;

  Expense({
    this.docId,
    this.name = "",
    this.amount = 0,
    this.description,
    // this.whopaid = "",
    // changed this in favor of using group name for finding expenses per group, 
    // it is faster when rendering group names on personal expenses screen on every expense
    this.groupName,
    this.categoryName
  });

  Expense copy ({
    String? docId,
    String? name,
    double? amount,
    String? description,
    // String? whopaid,
    // The reason i am using groupName for this, 
    // is so that i can display groupName in personal expenses
    String? groupName,
    String? categoryName
  }){
    return Expense(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      // whopaid: whopaid ?? this.whopaid
      groupName: groupName ?? this.groupName,
      categoryName: categoryName ?? this.categoryName
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "name": name,
      "amount": amount,
      "description": description,
      // "whopaid": whopaid,
      "groupName": groupName,
      "categoryName": categoryName
    };
  }

  static Expense fromMap(Map<String, dynamic> map){
    return Expense(
      name: map["name"] ?? "",
      amount: map["amount"] ?? "",
      description: map["description"] ?? "",
      // whopaid: map["description"]
      groupName: map["groupName"] ?? "",
      categoryName: map["categoryName"] ?? ""
    );
  }

  @override
  String toString() {
    return "Expense($docId, $name, $amount, $description, $groupName, $categoryName)";
  }
}
