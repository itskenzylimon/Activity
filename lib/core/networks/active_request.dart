
import 'package:activity/core/networks/http/io.dart';

export 'package:activity/core/networks/sockets/web.dart'
if (dart.library.io) 'package:activity/core/networks/sockets/io.dart';

// ignore: camel_case_types
typedef getApi = void Function();

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

class Params {
  Map<String, String>? queryParameters = {};
  String endpoint = '';

  Params({
    this.queryParameters,
    required this.endpoint,
  });

  @override
  String toString() {
    return '$endpoint \n $queryParameters';
  }
}

class ActiveResponse {
  int statusCode;
  String endpoint = '';
  String? errors;
  String? data;

  ActiveResponse({
    required this.statusCode,
    required this.endpoint,
    this.errors,
    this.data,
  });

  @override
  String toString() {
    return "( $statusCode ) : $endpoint \n $data \n $errors";
  }
}

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
    return await HttpActiveRequest().postApi(params, setUp, saveResponse: saveResponse,
      savedResponseName: savedResponseName);
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

}
