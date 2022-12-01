import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/app_secrets.skeleton.dart';
import '../firebase/auth.dart';

class OrderApi {
  Stream<QuerySnapshot> getAllOrder() {
    return firebaseFirestore.collection(AppSecrets.consumerorder).snapshots();
  }

  Future<List<Map<String, dynamic>>> getOrderByUser() async {
    List<Map<String, dynamic>> tempList = [];
    var response =
        await firebaseFirestore.collection(AppSecrets.consumerorder).get();
    for (var ele in response.docs) {
      Map<String, dynamic> tempmap = ele.data();
      tempmap.addAll({"uid": ele.id});

      tempList.add(tempmap);
    }
    //print(tempList);
    return tempList;
  }

  Future<List<Map<String, dynamic>>> getTableOrders() async {
    List<Map<String, dynamic>> tempList = [];
    var response = await firebaseFirestore
        .collection(AppSecrets.tableorder)
        .where("orderStatus", isEqualTo: "pending")
        .get();
    for (var ele in response.docs) {
      Map<String, dynamic> tempmap = ele.data();
      tempmap.addAll({"uid": ele.id});

      tempList.add(tempmap);
    }
    //print(tempList);
    return tempList;
  }
}
