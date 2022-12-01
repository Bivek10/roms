import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_skeleton/src/widgets/atoms/loader.dart';

import '../../config/api/get_orders_api.dart';
import '../../widgets/molecules/header.dart';
import '../view_order/order_card_base.dart';

class TableOrderPage extends StatefulWidget {
  const TableOrderPage({Key? key}) : super(key: key);

  @override
  State<TableOrderPage> createState() => _TableOrderPageState();
}

class _TableOrderPageState extends State<TableOrderPage> {
  OrderApi orderApi = OrderApi();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: Header(
        title: "Table Order History",
        showMenu: false,
        showAction: false,
        onPressedLeading: () {},
        onPressedAction: () {},
      ),
      body: FutureBuilder<List>(
        future: orderApi.getTableOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No order has made yet. ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var d = snapshot.data![index];
                  return ListTile(
                    title: Text("Table id: ${d["tableid"]}"),
                    subtitle: ListView.builder(
                      shrinkWrap: true,
                      itemCount: d["orderData"].length,
                      itemBuilder: (contex, indexs) {
                        return Text(d["orderData"][indexs]["foodname"]);
                      },
                    ),
                  );
                });
          }
          return const Center(
            child: Loader(),
          );
        },
      ),
    );
  }
}
