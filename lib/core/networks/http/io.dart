import 'dart:convert';
import 'dart:io' as io;
import 'package:activity/activity.dart';
import 'core.dart';

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

  Future<ActiveResponse> downloadFileByteList(
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
      ActiveResponse activeResponse = ActiveResponse(
          statusCode: response.statusCode,
          endpoint: params.endpoint,
          errors: response.toString()
      );
      apiRequest.close(force: true);
      return activeResponse;
    }

    var downloadData = [];
    response.listen((d) {
      downloadData.addAll(d);
    },);
    ActiveResponse activeResponse = ActiveResponse(
        statusCode: response.statusCode,
        errors: null,
        data: null,
        dataAlt: downloadData,
        endpoint: params.endpoint,
    );

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
      RequestSetUp setUp,
      {
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
    ///Write the body
    if(params.body!=null) {
      request.write(params.body);
    }
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

    /// Create a [Uri] from the endpoint. The [Uri] is used to
    /// create a [HttpClientRequest]. scheme is the protocol to use, path is the
    /// path to the resource, and host is the host to connect to.
    Uri uri = Uri(
      scheme: endpoint.scheme,
      path: endpoint.path,
      host: endpoint.host,
    );

    /// Create a [HttpClient] with a custom security context.
    /// [idleTimeout]: The idle timeout for the connection.
    /// [withTrustedRoots]: Whether to trust all certificates.
    /// [connectionTimeout]: The connection timeout for the connection.
    /// [privateKeyPath]: The path to the private key.
    /// [privateKeyPassword]: The password for the private key.
    final io.HttpClient apiRequest = _httpClientSetup(
        setUp.idleTimeout!,
        setUp.withTrustedRoots!,
        setUp.connectionTimeout!,
        setUp.privateKeyPath,
        setUp.privateKeyPassword);

    /// Create a [HttpClientRequest] to the specified URL.
    final io.HttpClientRequest request = await apiRequest.postUrl(uri);

    /// The boundary string is used to separate parts in the request body.
    /// It is an arbitrary string, unique among the strings that may appear in
    /// the body. It is typically generated by selecting a large random number
    final boundary = 'boundary-${DateTime.now().millisecondsSinceEpoch}';

    // create a HTTP request with multipart content type
    request.headers.set('content-type', 'multipart/form-data; boundary=$boundary');

    // add file to request body
    final fileBytes = await file.readAsBytes();
    final fileField = HttpBodyPart(
      fileBytes,
      mimeType: 'application/octet-stream',
      contentDispositionValue: 'form-data; name="$fileName"; filename="${file.path}"',
    );
    request.add(encodePart(boundary, fileField));

    /// add params to request body.
    params.queryParameters?.forEach((key, value) {
      /// create a [HttpBodyPart] from the [value] and [key].
      /// [value] is the value of the field.
      /// [key] is the name of the field.
      /// whoever did the HttpBodyPart.fromString() why the inverse.....?????
      final dataField  = HttpBodyPart.fromString(value.toString(), key);
      request.add(encodePart(boundary, dataField));
    });

    // send the request and wait for the response
    final response = await request.close();

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

  /// Save the [ActiveResponse] to the [Memory] class.
  _saveApiRequests(ActiveResponse activeResponse, String responseName) async {
    /// Get the instance of the [Memory] class.
    //Memory memory = Memory.memory;
    Memory memory = Memory.instance();
    /// Save the [ActiveResponse] to the [Memory] class.
    memory.upsertMemory(responseName, activeResponse);
  }
}
