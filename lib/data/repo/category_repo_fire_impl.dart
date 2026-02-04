import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_v2/data/model/category.dart';
import 'package:flutter/widgets.dart';

class CategoryRepoFireImpl {
  static final CategoryRepoFireImpl _instance =
      CategoryRepoFireImpl._internal();
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

  Future<bool> addCategory(Category category) async {
    final duplicate = await _collection
        .where('name', isEqualTo: category.name)
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
      return false;
    } else {
      await _collection.add(category.toMap());
      return true;
    }
  }

  Future<void> updateCategory(Category category) async {
    await _collection.doc(category.docId!).set(category.toMap());
  }

  Future<void> deleteCategory(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<void> deleteCategoryAndUpdateExpenses(String docId, String categoryName) async {
    final expensesCollection = FirebaseFirestore.instance.collection("expenses");
    final expensesWithCategory = await expensesCollection
        .where('categoryName', isEqualTo: categoryName)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in expensesWithCategory.docs) {
      batch.update(doc.reference, {'categoryName': null});
    }
    batch.delete(_collection.doc(docId));
    await batch.commit();
  }

  // TODO: add another function for calculating total Expenses and displaying?
}
