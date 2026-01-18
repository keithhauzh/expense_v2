import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_v2/data/model/expense.dart';

class ExpenseRepoFireImpl {
  static final ExpenseRepoFireImpl _instance = ExpenseRepoFireImpl._internal();
  ExpenseRepoFireImpl._internal();

  factory ExpenseRepoFireImpl() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("expenses");

  Stream<List<Expense>> getAllExpenses(){
    return _collection.snapshots().map((event) {
        return event.docs.map((doc) {
            return Expense.fromMap(doc.data()).copy(docId: doc.id);
        }).toList();
    });
  }

  Future<Expense?> getExpenseById(String docId) async {
    final res = await _collection.doc(docId).get();
    if(res.data() == null){
      return null;
    }
    return Expense.fromMap(res.data()!).copy(docId: res.id);
  }

  Future<void> addExpense(Expense expense) async {
    await _collection.doc(expense.docId!).set(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _collection.doc(expense.docId!).set(expense.toMap());
  }

  Future<void> deleteExpense(String docId) async {
    await _collection.doc(docId).delete();
  }

}
