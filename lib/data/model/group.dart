class Group {
  final String? docId;
  final String name;
  final String? description;

  Group({
    this.docId,
    this.name = "",
    this.description,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
    };
  }

  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      name: map["name"] ?? "",
      description: map["description"] ?? "",
    );
  }

  @override
  String toString() {
    return "Group($docId, $name, $description)";
  }
}
