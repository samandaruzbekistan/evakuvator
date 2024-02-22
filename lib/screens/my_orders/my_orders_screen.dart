import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:evakuvator/constants.dart';

import '../../components/bottomNavigation.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  late int status = 0;
  var box = Hive.box('users');
  List<Map<String, dynamic>> ordersData = [];

  Future<void> fetchData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "UsersHistory",
        "body": {
          "phonenumber": '${box.get('phone')}'
        }
      }
    });
    request.headers.addAll(headers);

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        // print(res);
        if (res == "Taqdim etilgan ID uchun hech qanday ma'lumot topilmadi") {
          status = 2;
        } else {

          final data = json.decode(res);
          setState(() {
            // print(data);
            status = 1;
            ordersData = List<Map<String, dynamic>>.from(data['messages']);
          });
        }
      } else {
        setState(() {
          status = -1;
        });
      }
    } else {
      setState(() {
        status = -2;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Buyurtmalarim"),
        // backgroundColor: AppColors.yellow,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.update,
              size: w * 0.08,
            ),
            onPressed: () {
              setState(() {
                status = 0;
              });
              fetchData();
            },
          )
        ],
      ),
      body: FutureBuilder<dynamic>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (status == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (status == 2) {
            return Center(
              child: Text('Buyurtmalar topilmadi'),
            );
          } else if (status == -1) {
            return Center(
              child: Text('API da nosozlik'),
            );
          } else if (status == -2) {
            return Center(
              child: Text('Internetga ulanmagansiz'),
            );
          } else {
            final data = ordersData;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return GestureDetector(
                  onTap: () async {
                    if (item['status'] == false) {
                      _findWorker(context);
                    } else if (item['status'] == true) {
                      var headers = {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
                      };
                      var request = http.Request('POST', Uri.parse('http://94.241.168.135:9000/api/v1/mobile'));
                      request.body = json.encode({
                        "jsonrpc": "2.0",
                        "apiversion": "1.0",
                        "params": {
                          "method": "DriverData",
                          "body": {
                            "_id": "${item['driverphone']}"
                          }
                        }
                      });
                      request.headers.addAll(headers);

                      http.StreamedResponse response = await request.send();


                      // var request = http.MultipartRequest('POST',
                      //     Uri.parse('https://mytok.uz/API/getorderuser.php'));
                      // request.fields.addAll({'workid': '${item['id']}'});
                      // http.StreamedResponse response = await request.send();
                      var res2 = await response.stream.bytesToString();
                      Map valueMap2 = json.decode(res2);
                      print(valueMap2);
                      if (response.statusCode == 200) {
                        print(valueMap2);
                        _okWorker(context, "${valueMap2['data']['username']}",
                            "${valueMap2['data']['phonenumber']}","${valueMap2['data']['carnumber']}");
                      }
                    }
                  },
                  child: ListTile(
                      title: Text(item['category'] ?? ''),
                      subtitle: Text("${formatDateTime(item['updatedAt'])}" ?? ''),
                      leading: item['category'] != null ? _buildLeadingIcon(item['category']) : _buildLeadingIcon("YTH"),
                      trailing: _buildIcon(item['status'])),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar:  BottomNavigationCustom(screenId:1),
    );
  }

  Widget _buildLeadingIcon(String category) {
    if (category == "YTH") {
      return CircleAvatar(
        child: Image.asset("assets/icons/eva_call.png"),
      );
    } else if (category == "Qoida buzarlik") {
      return CircleAvatar(
        child: Image.asset("assets/icons/rule.png"),
      );
    } else if (category == "Mast holatda") {
      return CircleAvatar(
        child: Image.asset("assets/icons/alcahol.png"),
      );
    } else {
      return CircleAvatar(
        child: Image.asset("assets/images/montaj.png"),
      );
    }
  }

  Widget _buildIcon(bool category) {
    if (category == false) {
      return Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.black,
          ));
    } else {
      return CircleAvatar(
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.check),
      );
    }
  }

  Widget _buildStatus(bool category) {
    if (category == false) {
      return Text("Evakuator izlanmoqda");
    } else {
      return Text("Evakuator topildi");
    }
  }


}

String formatDateTime(String timestamp) {
  DateTime dateTime = DateTime.parse(timestamp);
  String formattedDateTime = DateFormat('y.MM.dd H:m').format(dateTime);
  return formattedDateTime;
}

_findWorker(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Ish holati!",
    desc: "Evakuator izlanmoqda",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}

_okWorker(context, String worker, String worker_phone, String car_number) {
  Alert(
    context: context,
    type: AlertType.success,
    title: "Hodim",
    desc: "Ismi: ${worker}\nTel: ${worker_phone}\nRaqami: ${car_number}",
    buttons: [
      DialogButton(
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse('tel:' + "+${worker_phone}")),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                color: Colors.white,
              ),
              Text(
                " Qo'ng'iroq qilish",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}
