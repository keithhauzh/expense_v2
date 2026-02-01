class Expense {
  final String? docId;
  final String name;
  final double amount;
  final String? description;
  final String whopaid;
  final String? groupName;
  final String? categoryName;

  Expense({
    this.docId,
    this.name = "",
    this.amount = 0.0,
    this.description,
    required this.whopaid,
    this.groupName,
    this.categoryName,
  });

  Expense copy({
    String? docId,
    String? name,
    double? amount,
    String? description,
    String? whopaid,
    String? groupName,
    String? categoryName,
  }) {
    return Expense(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      whopaid: whopaid ?? this.whopaid,
      groupName: groupName ?? this.groupName,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "amount": amount,
      "description": description,
      "whopaid": whopaid,
      "groupName": groupName,
      "categoryName": categoryName,
    };
  }


  static Expense fromMap(Map<String, dynamic> map) {

		// To fix parsing issues for type double on amount field
		final rawAmount = map['amount'];
		double amount = 0.0;
		if(rawAmount is num){
			amount = rawAmount.toDouble();
		}else if(rawAmount is String){
			amount = double.tryParse(rawAmount) ?? 0.0;
		}

    return Expense(
      name: map["name"] ?? "",
      amount: amount,
      description: map["description"] ?? "",
      whopaid: map["whopaid"],
      groupName: map["groupName"] ?? "",
      categoryName: map["categoryName"] ?? "",
    );
  }

  @override
  String toString() {
    return "Expense($docId, $name, $amount, $description, $whopaid, $groupName, $categoryName)";
  }
}
