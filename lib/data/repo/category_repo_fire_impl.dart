import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_v2/data/model/category.dart';
import 'package:flutter/widgets.dart';

class CategoryRepoFireImpl {
  static final CategoryRepoFireImpl _instance = CategoryRepoFireImpl._internal();
  CategoryRepoFireImpl._internal();

  factory CategoryRepoFireImpl() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("categories");

  Stream<List<Category>> getAllCategories() {
    return _collection.snapshots().map((event) {
      return event.docs.map((doc) {
        return Category.fromMap(doc.data()).copy(docId: doc.id);
      }).toList();
    });
  }

  Future<Category?> getCategoryById(String docId) async {
    final res = await _collection.doc(docId).get();
    if (res.data() == null) {
      debugPrint("data returned is null");
      return null;
    }
    return Category.fromMap(res.data()!).copy(docId: res.id);
  }

  Future<void> addCategory(Category category) async {
    await _collection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _collection.doc(category.docId!).set(category.toMap());
  }

  Future<void> deleteCategory(String docId) async {
    await _collection.doc(docId).delete();
  }

  // TODO: add another function for calculating total Expenses and displaying?
}
