import 'dart:io' as io if (dart.library.web) 'dart:html';
import 'package:activity/core/networks/http/io.dart';

export 'package:activity/core/networks/sockets/web.dart'
if (dart.library.io) 'package:activity/core/networks/sockets/io.dart';


// ignore: camel_case_types
typedef getApi = void Function();

/// RequestSetUp is a class that contains the configuration of the request
/// idleTimeout is the time in seconds to wait for the request to complete
/// connectionTimeout is the time in seconds to wait for the connection to complete
/// logResponse is a boolean to print the response in the console
/// withTrustedRoots is a boolean to use the trusted roots
/// httpHeaders is a map of the headers to send in the request
/// privateKeyPath is the path of the private key
/// schemePath is the scheme of the request
/// baseURL is the base url of the request
/// privateKeyPassword is the password of the private key
class RequestSetUp {
  int? idleTimeout = 1;
  int? connectionTimeout = 1;
  bool? logResponse = false;
  bool? withTrustedRoots = false;
  Map<String, String>? httpHeaders = {};
  String? privateKeyPath = '';
  String? schemePath = 'https';
  String? baseURL = '';
  String? privateKeyPassword = '';

  RequestSetUp({
    this.idleTimeout,
    this.connectionTimeout,
    this.logResponse,
    this.withTrustedRoots,
    this.httpHeaders,
    this.privateKeyPath,
    this.schemePath,
    this.baseURL,
    this.privateKeyPassword
  });

  @override
  String toString() {
    return '$idleTimeout';
  }
}

/// Params is a class that contains the data of the request
/// [queryParameters] is a map of the query parameters. It is optional
/// [endpoint] is the endpoint of the request. It is required
class Params {
  Map<String, dynamic>? queryParameters = {};
  String endpoint = '';
  dynamic? body;

  Params({
    this.queryParameters,
    required this.endpoint,
    this.body,
  });

  @override
  String toString() {
    return '$endpoint \n $queryParameters';
  }
}

/// ActiveResponse is a class that contains the response of the request
/// [statusCode] is the status code of the response
/// [endpoint] is the endpoint of the request
/// [errors] is the error of the response
/// [data] is the data of the response
class ActiveResponse {
  int statusCode;
  String endpoint = '';
  String? errors;
  String? data;
  var dataAlt;

  ActiveResponse({
    required this.statusCode,
    required this.endpoint,
    this.errors,
    this.data,
    this.dataAlt,
  });

  @override
  String toString() {
    return "( $statusCode ) : $endpoint \n $data \n $errors${((dataAlt!=null? '\n $dataAlt':'' ))}";
  }
}

/// ActiveRequest is a class that contains the request function.
/// [setUp] is the configuration of the request
/// [getApi] is the function that makes a get request
/// [postApi] is the function that makes a post request
/// [putApi] is the function that makes a put request
/// [deleteApi] is the function that makes a delete request
/// [uploadFileApi] is the function that makes a upload file request
class ActiveRequest {
  RequestSetUp setUp = RequestSetUp();

  /// [getApi] Get request.
  /// [Params] field is required.
  ///
  ///   Params({
  ///     this.queryParameters,
  ///     required this.endpoint,
  ///   });
  ///
  /// set [saveResponse] to 'true' if you would want to save the response
  /// pass [savedResponseName] if you'd want to have a unique key assigned to
  /// the saved [saveResponse] data. leaving this empty, Activity will set the
  /// key name as the [endpoint].
  ///
  ///  ActiveResponse({
  ///     required this.statusCode,
  ///     required this.endpoint,
  ///     this.data,
  ///   });
  ///
  ///
  ///     ActiveRequest activeRequest =  ActiveRequest();
  ///
  ///     activeRequest.setUp = RequestSetUp(
  ///       idleTimeout: 10,
  ///       connectionTimeout: 10,
  ///       logResponse: true,
  ///       withTrustedRoots: true
  ///     );
  ///
  ///     ActiveResponse activeResponse = await activeRequest
  ///     .getApi(Params(endpoint: 'https://catfact.ninja/fact'));
  ///
  /// You can easily get the [saveResponse] value using Memory
  getApi(Params params, {
    bool saveResponse = false,
    String savedResponseName = '',
  }) async{

    return await HttpActiveRequest().getApi(params, setUp, saveResponse: saveResponse,
      savedResponseName: savedResponseName);
  }

downloadFileByteList(Params params, {
    bool saveResponse = false,
    String savedResponseName = '',
    }) async{

    return await HttpActiveRequest().downloadFileByteList(params, setUp, saveResponse: saveResponse,
    savedResponseName: savedResponseName);
  }

  /// [postApi] Get request.
  /// [Params] field is required.
  ///
  ///   Params({
  ///     this.queryParameters,
  ///     required this.endpoint,
  ///   });
  ///
  /// set [saveResponse] to 'true' if you would want to save the response
  /// pass [savedResponseName] if you'd want to have a unique key assigned to
  /// the saved [saveResponse] data. leaving this empty, Activity will set the
  /// key name as the [endpoint].
  ///
  ///  ActiveResponse({
  ///     required this.statusCode,
  ///     required this.endpoint,
  ///     this.data,
  ///   });
  ///
  ///
  ///     ActiveRequest activeRequest =  ActiveRequest();
  ///
  ///     activeRequest.setUp = RequestSetUp(
  ///       idleTimeout: 10,
  ///       connectionTimeout: 10,
  ///       logResponse: true,
  ///       withTrustedRoots: true
  ///     );
  ///
  ///     ActiveResponse activeResponse = await activeRequest
  ///     .postApi(Params(endpoint: 'https://catfact.ninja/fact'));
  ///
  /// You can easily get the [saveResponse] value using Memory
  postApi(Params params, {
    bool saveResponse = false,
    String savedResponseName = '',
  }) async{
    return await HttpActiveRequest().postApi(
        params,
        setUp,
        saveResponse: saveResponse,
        savedResponseName: savedResponseName,
    );
  }

  /// [putApi] Get request.
  /// [Params] field is required.
  ///
  ///   Params({
  ///     this.queryParameters,
  ///     required this.endpoint,
  ///   });
  ///
  /// set [saveResponse] to 'true' if you would want to save the response
  /// pass [savedResponseName] if you'd want to have a unique key assigned to
  /// the saved [saveResponse] data. leaving this empty, Activity will set the
  /// key name as the [endpoint].
  ///
  ///  ActiveResponse({
  ///     required this.statusCode,
  ///     required this.endpoint,
  ///     this.data,
  ///   });
  ///
  ///
  ///     ActiveRequest activeRequest =  ActiveRequest();
  ///
  ///     activeRequest.setUp = RequestSetUp(
  ///       idleTimeout: 10,
  ///       connectionTimeout: 10,
  ///       logResponse: true,
  ///       withTrustedRoots: true
  ///     );
  ///
  ///     ActiveResponse activeResponse = await activeRequest
  ///     .putApi(Params(endpoint: 'https://catfact.ninja/fact'));
  ///
  /// You can easily get the [saveResponse] value using Memory
  putApi(Params params, {
    bool saveResponse = false,
    String savedResponseName = '',
  }) async{
    return await HttpActiveRequest().putApi(params, setUp, saveResponse: saveResponse,
      savedResponseName: savedResponseName);
  }

  /// [deleteApi] Get request.
  ///
  /// set [saveResponse] to 'true' if you would want to save the response
  /// pass [savedResponseName] if you'd want to have a unique key assigned to
  /// the saved [saveResponse] data. leaving this empty, Activity will set the
  /// key name as the [endpoint].
  ///
  ///  ActiveResponse({
  ///     required this.statusCode,
  ///     required this.endpoint,
  ///     this.data,
  ///   });
  ///
  ///
  ///     ActiveRequest activeRequest =  ActiveRequest();
  ///
  ///     activeRequest.setUp = RequestSetUp(
  ///       idleTimeout: 10,
  ///       connectionTimeout: 10,
  ///       logResponse: true,
  ///       withTrustedRoots: true
  ///     );
  ///
  ///     ActiveResponse activeResponse = await activeRequest
  ///     .deleteApi(Params(endpoint: 'https://catfact.ninja/fact'));
  ///
  /// You can easily get the [saveResponse] value using Memory
  deleteApi(Params params, {
    bool saveResponse = false
  }) async{
    return await HttpActiveRequest().deleteApi(params, setUp, saveResponse: saveResponse);
  }


  /// [deleteApi] Get request.
  ///
  /// set [saveResponse] to 'true' if you would want to save the response
  /// pass [savedResponseName] if you'd want to have a unique key assigned to
  /// the saved [saveResponse] data. leaving this empty, Activity will set the
  /// key name as the [endpoint].
  ///
  ///  ActiveResponse({
  ///     required this.statusCode,
  ///     required this.endpoint,
  ///     this.data,
  ///   });
  ///
  ///
  ///     ActiveRequest activeRequest =  ActiveRequest();
  ///
  ///     activeRequest.setUp = RequestSetUp(
  ///       idleTimeout: 10,
  ///       connectionTimeout: 10,
  ///       logResponse: true,
  ///       withTrustedRoots: true
  ///     );
  ///
  ///     ActiveResponse activeResponse = await activeRequest
  ///     .deleteApi(Params(endpoint: 'https://catfact.ninja/fact'));
  ///
  /// You can easily get the [saveResponse] value using Memory
  Future<ActiveResponse> uploadFileApi(
      Params params,
      io.File file,
      String fileName,
      RequestSetUp setUp, {
        String savedResponseName = '',
        bool saveResponse = false,
      }) async{
    return await HttpActiveRequest().uploadFileApi(
        params, file, fileName, setUp, saveResponse: saveResponse
    );
  }
}
