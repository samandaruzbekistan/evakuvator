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

  Future<void> TempSaveUserData(
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
          Get.to(OtpScreen());
        }

      }
      else{
        isLoad.value = false;
        userFound.value = true;
      }
    }
  }

  Future<void> checkCode(String code) async {
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

    }
    else{
      print("else");
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
            box.put('phone', valueMap['phonenumber']);
            box.put('name', valueMap['username']);
            box.put('region_name', valueMap['location']);
            box.put('region_id', valueMap['location_id']);
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

  void falseLoading(){
    isLoad.value = false;
  }

  void falseUserFound(){
    userFound.value = false;
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
