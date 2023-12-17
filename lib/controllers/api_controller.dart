import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class ApiController{
  var baseUrl = "";



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
      header: {
        "test":"ypx"
      }
    );


    final token = jwt.sign(SecretKey('ypx'));
    var headers = {
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('https://mytok.uz/flutterapi/request.php'));
    request.body = json.encode({
      "request": "${token}"
    });
    request.headers.addAll(headers);


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }
  }
}