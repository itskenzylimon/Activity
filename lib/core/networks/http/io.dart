import 'dart:convert';
import 'dart:io' as io;
import 'package:activity/activity.dart';

class HttpActiveRequest {
  io.HttpClient _httpClientSetup(int idleTimeout, bool withTrustedRoots,
      int connectionTimeout, String? privateKey, String? privateKeyPassword) {
    final io.HttpClient apiRequest = io.HttpClient();
    io.SecurityContext securityContext =
        io.SecurityContext(withTrustedRoots: withTrustedRoots);
    // securityContext.allowLegacyUnsafeRenegotiation == true;
    if (privateKey != null) {
      if (privateKeyPassword != null) {
        securityContext.usePrivateKey(privateKey, password: privateKeyPassword);
      } else {
        securityContext.usePrivateKey(privateKey);
      }
    }
    apiRequest.idleTimeout = Duration(seconds: idleTimeout);
    apiRequest.connectionTimeout = Duration(seconds: connectionTimeout);
    return apiRequest;
  }

  Future<ActiveResponse> getApi(
    Params params,
    RequestSetUp setUp, {
    String savedResponseName = '',
    bool saveResponse = false,
  }) async {
    final endpoint = Uri.parse(params.endpoint);

    Uri uri = Uri(
      scheme: endpoint.scheme,
      queryParameters: params.queryParameters,
      path: endpoint.path,
      host: endpoint.host,
    );

    final io.HttpClient apiRequest = _httpClientSetup(
        setUp.idleTimeout!,
        setUp.withTrustedRoots!,
        setUp.connectionTimeout!,
        setUp.privateKeyPath,
        setUp.privateKeyPassword);

    final io.HttpClientRequest request = await apiRequest.getUrl(uri);
    setUp.httpHeaders?.forEach((String name, String value) {
      request.headers.add(name, value);
    });

    final io.HttpClientResponse response = await request.close();
    if (response.statusCode != io.HttpStatus.ok) {
      // The network may be only temporarily unavailable
      ActiveResponse activeResponse = ActiveResponse(
          statusCode: response.statusCode,
          endpoint: params.endpoint,
          errors: response.toString(),
          data: await response.transform(utf8.decoder).join());
      // await response.drain<List<int>>(<int>[]);
      apiRequest.close(force: true);
      return activeResponse;
    }

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: response.statusCode,
        errors: null,
        data: await response.transform(utf8.decoder).join(),
        endpoint: params.endpoint);

    if (setUp.logResponse == true) {
      await _logApiRequests(activeResponse);
    }

    if (saveResponse == true) {
      savedResponseName =
          savedResponseName == '' ? uri.path : savedResponseName;
      await _saveApiRequests(activeResponse, savedResponseName);
    }


    return activeResponse;
  }

  Future<ActiveResponse> postApi(
      Params params,
      RequestSetUp setUp, {
        String savedResponseName = '',
        bool saveResponse = false,
      }) async {
    final endpoint = Uri.parse(params.endpoint);

    Uri uri = Uri(
      scheme: endpoint.scheme,
      queryParameters: params.queryParameters,
      path: endpoint.path,
      host: endpoint.host,
    );

    final io.HttpClient apiRequest = _httpClientSetup(
        setUp.idleTimeout!,
        setUp.withTrustedRoots!,
        setUp.connectionTimeout!,
        setUp.privateKeyPath,
        setUp.privateKeyPassword);

    final io.HttpClientRequest request = await apiRequest.postUrl(uri);
    setUp.httpHeaders?.forEach((String name, String value) {
      request.headers.add(name, value);
    });

    final io.HttpClientResponse response = await request.close();
    if (response.statusCode != io.HttpStatus.ok) {
      // The network may be only temporarily unavailable
      ActiveResponse activeResponse = ActiveResponse(
          statusCode: response.statusCode,
          endpoint: params.endpoint,
          errors: response.toString(),
          data: await response.transform(utf8.decoder).join());
      // await response.drain<List<int>>(<int>[]);
      apiRequest.close(force: true);
      return activeResponse;

    }

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: response.statusCode,
        errors: null,
        data: await response.transform(utf8.decoder).join(),
        endpoint: params.endpoint);

    if (setUp.logResponse == true) {
      await _logApiRequests(activeResponse);
    }

    if (saveResponse == true) {
      savedResponseName =
      savedResponseName == '' ? uri.path : savedResponseName;
      await _saveApiRequests(activeResponse, savedResponseName);
    }

    return activeResponse;
  }

  Future<ActiveResponse> putApi(
      Params params,
      RequestSetUp setUp, {
        String savedResponseName = '',
        bool saveResponse = false,
      }) async {
    final endpoint = Uri.parse(params.endpoint);

    Uri uri = Uri(
      scheme: endpoint.scheme,
      queryParameters: params.queryParameters,
      path: endpoint.path,
      host: endpoint.host,
    );

    final io.HttpClient apiRequest = _httpClientSetup(
        setUp.idleTimeout!,
        setUp.withTrustedRoots!,
        setUp.connectionTimeout!,
        setUp.privateKeyPath,
        setUp.privateKeyPassword);

    final io.HttpClientRequest request = await apiRequest.putUrl(uri);
    setUp.httpHeaders?.forEach((String name, String value) {
      request.headers.add(name, value);
    });

    final io.HttpClientResponse response = await request.close();
    if (response.statusCode != io.HttpStatus.ok) {
      // The network may be only temporarily unavailable
      ActiveResponse activeResponse = ActiveResponse(
          statusCode: response.statusCode,
          endpoint: params.endpoint,
          errors: response.toString(),
          data: await response.transform(utf8.decoder).join());
      await response.detachSocket();
      // await response.drain<List<int>>(<int>[]);
      apiRequest.close(force: true);
      return activeResponse;
    }

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: response.statusCode,
    errors: null,
    data: await response.transform(utf8.decoder).join(),
    endpoint: params.endpoint);

    if (setUp.logResponse == true) {
      await _logApiRequests(activeResponse);
    }

    if (saveResponse == true) {
      savedResponseName =
      savedResponseName == '' ? uri.path : savedResponseName;
      await _saveApiRequests(activeResponse, savedResponseName);
    }

    return activeResponse;
  }

  Future<ActiveResponse> deleteApi(
      Params params,
      RequestSetUp setUp, {
        String savedResponseName = '',
        bool saveResponse = false,
      }) async {
    final endpoint = Uri.parse(params.endpoint);

    Uri uri = Uri(
      scheme: endpoint.scheme,
      queryParameters: params.queryParameters,
      path: endpoint.path,
      host: endpoint.host,
    );

    final io.HttpClient apiRequest = _httpClientSetup(
        setUp.idleTimeout!,
        setUp.withTrustedRoots!,
        setUp.connectionTimeout!,
        setUp.privateKeyPath,
        setUp.privateKeyPassword);

    final io.HttpClientRequest request = await apiRequest.deleteUrl(uri);
    setUp.httpHeaders?.forEach((String name, String value) {
      request.headers.add(name, value);
    });

    final io.HttpClientResponse response = await request.close();
    if (response.statusCode != io.HttpStatus.ok) {
      // The network may be only temporarily unavailable
      ActiveResponse activeResponse = ActiveResponse(
          statusCode: response.statusCode,
          endpoint: params.endpoint,
          errors: response.toString(),
          data: await response.transform(utf8.decoder).join());
      // await response.drain<List<int>>(<int>[]);
      apiRequest.close(force: true);
      return activeResponse;
    }

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: response.statusCode,
        errors: null,
        data: await response.transform(utf8.decoder).join(),
        endpoint: params.endpoint);

    if (setUp.logResponse == true) {
      await _logApiRequests(activeResponse);
    }

    if (saveResponse == true) {
      savedResponseName =
      savedResponseName == '' ? uri.path : savedResponseName;
      await _saveApiRequests(activeResponse, savedResponseName);
    }

    return activeResponse;
  }

  Future<ActiveResponse> uploadFileApi(
      Params params,
      io.File file,
      String fileName,
      RequestSetUp setUp, {
        String savedResponseName = '',
        bool saveResponse = false,
      }) async {
    final endpoint = Uri.parse(params.endpoint);

    Uri uri = Uri(
      scheme: endpoint.scheme,
      queryParameters: params.queryParameters,
      path: endpoint.path,
      host: endpoint.host,
    );

    final io.HttpClient apiRequest = _httpClientSetup(
        setUp.idleTimeout!,
        setUp.withTrustedRoots!,
        setUp.connectionTimeout!,
        setUp.privateKeyPath,
        setUp.privateKeyPassword);

    final io.HttpClientRequest request = await apiRequest.postUrl(uri);

    final String boundary = '----${DateTime.now().millisecondsSinceEpoch}';
    request.headers.contentType =
        io.ContentType('multipart', 'form-data', parameters: {'boundary': boundary});

    final io.IOSink sink = request;

    sink.write('--$boundary\r\n');
    sink.write('Content-Disposition: form-data; name="file"; filename="${file.path}"\r\n');
    sink.write('Content-Type: ${io.ContentType.binary}\r\n');
    sink.write('\r\n');

    final Stream<List<int>> stream = file.openRead();
    await for (List<int> chunk in stream) {
      sink.add(chunk);
    }

    sink.write('\r\n--$boundary--\r\n');
    await sink.flush();
    await sink.close();
    final io.HttpClientResponse response = await request.close();

    if (response.statusCode != io.HttpStatus.ok) {
      // The network may be only temporarily unavailable
      ActiveResponse activeResponse = ActiveResponse(
          statusCode: response.statusCode,
          endpoint: params.endpoint,
          errors: response.toString(),
          data: await response.transform(utf8.decoder).join());
      // await response.drain<List<int>>(<int>[]);
      apiRequest.close(force: true);
      return activeResponse;
    }

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: response.statusCode,
        errors: null,
        data: await response.transform(utf8.decoder).join(),
        endpoint: params.endpoint);

    if (setUp.logResponse == true) {
      await _logApiRequests(activeResponse);
    }

    if (saveResponse == true) {
      savedResponseName =
      savedResponseName == '' ? uri.path : savedResponseName;
      await _saveApiRequests(activeResponse, savedResponseName);
    }

    return activeResponse;
  }

  _logApiRequests(ActiveResponse activeResponse) async {
    
  }

  _saveApiRequests(ActiveResponse activeResponse, String responseName) async {
    Memory memory = Memory.memory;
    memory.upsertMemory(responseName, activeResponse);
  }
}
