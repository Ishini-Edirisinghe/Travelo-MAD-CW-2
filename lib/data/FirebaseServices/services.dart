import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String,dynamic>>> get({required String path})async{
    try{
      final snapshot = await _firestore.collection(path).get();
      return snapshot.docs.map((doc){
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }catch(e){
      return [];
    }
  }

  Future<String> add({required String path, required Map<String,dynamic> data})async{
    try{
      final docReference = await _firestore.collection(path).add(data);
      return docReference.id;
    }catch(e){
      return e.toString();
    }
  }

  Future<bool> update({required String path, required Map<String,dynamic> data, required String docId})async{
    try{
      await _firestore.collection(path).doc(docId).update(data);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> delete({required String path, required String docId})async{
    try{
      await _firestore.collection(path).doc(docId).delete();
      return true;
    }catch(e){
      return false;
    }
  }
 }