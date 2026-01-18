class Group {
  final String? docId;
  final String name;
  final String description;
  // final List<String> accounts;
  final double? totalExpenseAmount;

  Group({
    this.docId,
    this.name = "",
    this.description = "",
    this.totalExpenseAmount,
  });

  Group copy({
    String? docId,
    String? name,
    String? description,
    double? totalExpenseAmount,
  }) {
    return Group(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      description: description ?? this.description,
      totalExpenseAmount: totalExpenseAmount ?? this.totalExpenseAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "totalExpenseAmount": totalExpenseAmount,
    };
  }

  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      totalExpenseAmount: map["totalExpenseAmount"] ?? "",
    );
  }

  @override
  String toString() {
    return "Group($docId, $name, $description, $totalExpenseAmount)";
  }
}
