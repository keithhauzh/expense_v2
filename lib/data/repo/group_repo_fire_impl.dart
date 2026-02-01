import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_v2/data/model/category.dart';
import 'package:expense_v2/data/model/group.dart';
import 'package:flutter/widgets.dart';

class GroupRepoFireImpl {
  static final GroupRepoFireImpl _instance = GroupRepoFireImpl._internal();
  GroupRepoFireImpl._internal();

  factory GroupRepoFireImpl() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("groups");

  Stream<List<Group>> getAllGroups() {
    return _collection.snapshots().map((event) {
      return event.docs.map((doc) {
        return Group.fromMap(doc.data()).copy(docId: doc.id);
      }).toList();
    });
  }

  Future<Group?> getGroupById(String docId) async {
    final res = await _collection.doc(docId).get();
    if (res.data() == null) {
      debugPrint("data returned is null");
      return null;
    }
    return Group.fromMap(res.data()!).copy(docId: res.id);
  }

  Future<Group?> getGroupByName(String groupName) async {
    debugPrint("triggered getGroupByName");
    final res = await _collection.doc(groupName).get();
    debugPrint(res.data.toString());
    if (res.data() == null) {
      debugPrint("data returned is null");
      return null;
    }
    return Group.fromMap(res.data()!).copy(docId: res.id);
  }

  Future<bool> addGroup(Group group) async {
    final duplicate = await _collection
        .where('name', isEqualTo: group.name)
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
      return false;
    } else {
      await _collection.add(group.toMap());
      return true;
    }
  }

  Future<void> updateGroup(Group group) async {
    await _collection.doc(group.docId!).set(group.toMap());
  }

  Future<void> deleteGroup(String docId) async {
    await _collection.doc(docId).delete();
  }
}
