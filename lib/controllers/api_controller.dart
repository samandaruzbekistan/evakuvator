import 'dart:convert';

import 'package:evakuvator/firebase_api.dart';
import 'package:evakuvator/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:math';

import '../screens/otp/otp_screen.dart';
final random = Random();

class ApiController {
  var baseUrl = "http://94.241.168.135:3000/api/v1/mobile";
  var box = Hive.box('users');
  var isLoad = false.obs;
  var userFound = false.obs;
  var codeTrue = false.obs;
  var loginTrue = false.obs;

  Future<int?> TempSaveUserData(
      { required String name,
        required String phone,
        required String password,
        required String location_id,
        required String location_name
      }) async {
    box.put("temp_name",name);
    box.put("temp_phone",phone);
    box.put("temp_password",password);
    box.put("temp_location_id",location_id);
    box.put("temp_location_name",location_name);
    final fourDigitNumber = random.nextInt(9000) + 1000;
    box.put("code","${fourDigitNumber}");
    isLoad.value = true;

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "CheckUsers",
        "body": {
          "phonenumber": phone
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200){
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      if(valueMap['success'] == false){
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
        };
        var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
        request.body = json.encode({
          "jsonrpc": "2.0",
          "apiversion": "1.0",
          "params": {
            "method": "SendSms",
            "body": {
              "phonenumber": phone,
              "smscode": fourDigitNumber
            }
          }
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          return 1;
        }
        else{
          return -1;
        }
      }
      else{
        return 0;
      }
    }
    else{
      return -1;
    }
    return -1;
  }

  Future<int> newOrder({
    required String category,
    required String lat,
    required String long,
    required String description,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "GetOrder",
        "body": {
          "category": category,
          "userphone": "${box.get('phone')}",
          "driverphone": 1,
          "lat": lat,
          "long": long,
          "regionid": "${box.get('region_id')}",
          "region": "${box.get('region_name')}",
          "description": description
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      if (valueMap['success'] == true){
        return 1;
      }
      else if(valueMap['success'] == false){
        return -1;
      }
    }
    else {
      return -1;
    }
    return 0;
  }


  Future<int> UpdatePassword({required String phone, required String password}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "UpdatePassword",
        "body": {
          "phonenumber": phone,
          "newpassword": password
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200){
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      print(valueMap);
      if(valueMap['success'] == true){
        return 1;
      }
      else{
        return 0;
      }
    }
    else{
      return 0;
    }
  }

  Future<int?> checkCode(String code) async {
    var kod = box.get('code');
    if(kod == code){
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
      };
      var token = await FirebaseApi().getFCMToken();
      var request = http.Request('POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
      request.body = json.encode({
        "jsonrpc": "2.0",
        "apiversion": "1.0",
        "params": {
          "method": "Register",
          "body": {
            "username": "${box.get('temp_name')}",
            "phonenumber": "${box.get("temp_phone")}",
            "location": "${box.get('temp_location_name')}",
            "password": "${box.get('temp_password')}",
            "location_id": "${box.get('temp_location_id')}",
            "fcmtoken": "${token}"
          }
        }
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if(response.statusCode == 200){
        box.put('phone', "${box.get("temp_phone")}");
        box.put('name',"${box.get('temp_name')}");
        box.put('region_name',"${box.get('temp_location_name')}");
        box.put('region_id', "${box.get('temp_location_id')}");
        return 1;
      }
    }
    else{
      return 0;
    }
  }

  Future<int?> Login(String phone, String password) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "CheckUsers",
        "body": {
          "phonenumber": phone
        }
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200){
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      if(valueMap['success'] == false){
        return 0;
      }
      else{
        var loginRequest = http.Request('POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
        loginRequest.body = json.encode({
          "jsonrpc": "2.0",
          "apiversion": "1.0",
          "params": {
            "method": "Login",
            "body": {
              "phonenumber": "${phone}",
              "password": "${password}"
            }
          }
        });
        loginRequest.headers.addAll(headers);

        http.StreamedResponse loginResponse = await loginRequest.send();
        if(loginResponse.statusCode == 200){
          var res = await loginResponse.stream.bytesToString();
          Map valueMap = json.decode(res);
          if(valueMap['success'] == true){
            // print(valueMap);
            box.put('phone', valueMap['messages']['phonenumber']);
            box.put('name', valueMap['messages']['username']);
            box.put('region_name', valueMap['messages']['location']);
            box.put('region_id', valueMap['messages']['location_id']);
            var request_fcm = http.Request('POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
            var fcm;
            fcm = await FirebaseApi().getFCMToken();
            request_fcm.body = json.encode({
              "jsonrpc": "2.0",
              "apiversion": "1.0",
              "params": {
                "method": "FcmUpdate",
                "body": {
                  "phonenumber": valueMap['messages']['phonenumber'],
                  "fcmtoken": fcm
                }
              }
            });
            request_fcm.headers.addAll(headers);

            http.StreamedResponse response = await request_fcm.send();

            var res = await response.stream.bytesToString();
            Map valueMap2 = json.decode(res);
            // print(valueMap2);
            return 1;
          }
          else{
            return 0;
          }
        }
      }
    }
    else{
      return 0;
    }
    return 0;
  }

  Future<int?> CheckUser({required String phone}) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "CheckUsers",
        "body": {
          "phonenumber": phone
        }
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if(response.statusCode == 200){
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      if(valueMap['success'] == false){
        return 0;
      }
      else{
        return 1;
      }
    }
    else{
      return 0;
    }
  }

  Future<int> sendCodeSms({required String phone}) async {
    final fourDigitNumber = random.nextInt(9000) + 1000;
    box.put("code","${fourDigitNumber}");
    box.put("temp_phone",phone);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "SendSms",
        "body": {
          "phonenumber": phone,
          "smscode": fourDigitNumber
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return 1;
    }
    else{
      return 0;
    }
  }



  Future<void> send() async {
    final jwt = JWT(
      // Payload
        {
          'id': 123,
          'server': {
            'id': '3e4fc296',
            'loc': 'euw-2',
          }
        },
        issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
        header: {"test": "ypx"});
    final token = jwt.sign(SecretKey('ypx'));
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://mytok.uz/flutterapi/request.php'));
    request.body = json.encode({"request": "${token}"});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}


