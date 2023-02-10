// import 'dart:convert';
// import 'dart:io' as io;
// import 'package:activity/activity.dart';
//
// class ActiveServerRequest {
//   ActiveServerRequest({required Future<void<Map<io.ContentType, dynamic>>> httpRequests}) :
//         _httpRequest = httpRequests;
//   final Future<Map<io.ContentType, dynamic>> _httpRequest;
//
//   startServer() {
//
//     io.HttpServer.bind(io.InternetAddress.anyIPv4, 3000).then((server) {
//       printInfo('Listening on localhost:${server.port}');
//       /// Start a server
//       server.listen((io.HttpRequest httpRequest) async {
//         Map<io.ContentType, dynamic> response  =
//         _httpRequest[httpRequest.uri.path];
//
//         var data = response.values.first;
//         var type = response.keys.first;
//
//         printNormal(data);
//
//         httpRequest.response
//           ..headers.contentType = type
//           ..statusCode = 200
//           ..write(data)
//           ..close();
//       });
//     });
//   }
//
// }