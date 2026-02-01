import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_v2/data/model/expense.dart';

class ExpenseRepoFireImpl {
  static final ExpenseRepoFireImpl _instance = ExpenseRepoFireImpl._internal();
  ExpenseRepoFireImpl._internal();

  factory ExpenseRepoFireImpl() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("expenses");

  Stream<List<Expense>> getAllExpenses() {
    return _collection.snapshots().map((event) {
      return event.docs.map((doc) {
        return Expense.fromMap(doc.data()).copy(docId: doc.id);
      }).toList();
    });
  }

  Stream<List<Expense>> getAllExpensesForCurrentUser(String currentUsername) {
    return _collection.snapshots().map((event) {
      // TODO: potentially rework logic? check user_repo_fire_impl.dart
      return event.docs
          .map((doc) {
            return Expense.fromMap(doc.data()).copy(docId: doc.id);
          })
          .where((expense) => expense.whopaid == currentUsername)
          .toList();
    });
  }

  Stream<List<Expense>> getAllExpensesInGroup(String? groupName) {
    return _collection.snapshots().map((event) {
      return event.docs
          .map((doc) {
            return Expense.fromMap(doc.data()).copy(docId: doc.id);
          })
          .where((expense) => expense.groupName == groupName)
          .toList();
    });
  }

  Stream<List<Expense>> getAllExpensesWithoutCategory() {
    return _collection.snapshots().map((event) {
      return event.docs
          .map((doc) {
            return Expense.fromMap(doc.data()).copy(docId: doc.id);
          })
          .where(
            (expense) =>
                expense.categoryName!.isEmpty || expense.categoryName == null,
          )
          .toList();
    });
  }

  Stream<List<Expense>> getAllExpensesWithoutCategoryForCurrentUser(
    String currentUsername,
  ) {
    return _collection.snapshots().map((event) {
      // TODO: potentially rework logic? check user_repo_fire_impl.dart
      return event.docs
          .map((doc) {
            return Expense.fromMap(doc.data()).copy(docId: doc.id);
          })
          .where(
            (expense) =>
                expense.whopaid == currentUsername &&
                expense.categoryName == null,
          )
          .toList();
    });
  }

  // TODO: remove later, probably not needed
  // Stream<List<Expense>> getExpensesByCategory(String categoryName) {
  //   return _collection.snapshots().map((event) {
  //     // TODO: potentially rework logic? check user_repo_fire_impl.dart
  //     return event.docs
  //         .map((doc) {
  //           return Expense.fromMap(doc.data()).copy(docId: doc.id);
  //         })
  //         .where((expense) => expense.categoryName == categoryName)
  //         .toList();
  //   });
  // }

  Future<Expense?> getExpenseById(String docId) async {
    final res = await _collection.doc(docId).get();
    if (res.data() == null) {
      return null;
    }
    return Expense.fromMap(res.data()!).copy(docId: res.id);
  }

  Future<void> addExpense(Expense expense) async {
    final duplicate = await _collection
        .where('name', isEqualTo: expense.name)
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
			throw Exception('expense name is taken');
    }else{
      await _collection.add(expense.toMap());
		}
  }

  // TODO: this could be used in the future, if we want to add prexisting expenses to groups
  // Future<void> addExpenseToGroup(Expense expense, String groupName) async {
  //   await _collection.doc(expense.docId!).update({'groupName': groupName});
  // }

  Future<void> updateExpense(Expense expense) async {
    await _collection.doc(expense.docId!).set(expense.toMap());
  }

  Future<void> deleteExpense(String docId) async {
    await _collection.doc(docId).delete();
  }
}
