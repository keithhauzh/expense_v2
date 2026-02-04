class Category {
  final String? docId;
  final String name;

  Category({
    this.docId,
    this.name = "",
  });

  Category copy({
    String? docId,
    String? name,
  }){
    return Category(
      docId: docId ?? this.docId,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      name: map["name"] ?? "",
    );
  }

  @override
  String toString() {
    return "Category($docId, $name)";
  }
}
