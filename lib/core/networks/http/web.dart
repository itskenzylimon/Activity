// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:activity/activity.dart';

class HttpActiveRequest {

  html.HttpRequest _httpClientSetup(
      int? idleTimeout, bool? withTrustedRoots, int? connectionTimeout,
      String? privateKey, String? privateKeyPassword) {

    html.HttpRequest apiRequest = html.HttpRequest();
    apiRequest.timeout = idleTimeout;
    return apiRequest;
  }

  Future<ActiveResponse> getApi(Params params, RequestSetUp setUp, {
    String savedResponseName = '',
    bool saveResponse = false,
  }) async {
    html.HttpRequest apiRequest = _httpClientSetup(setUp.idleTimeout, setUp.withTrustedRoots,
        setUp.connectionTimeout, setUp.privateKeyPath, setUp.privateKeyPassword);
      await html.HttpRequest.request(params.endpoint, method: 'GET', sendData: params.queryParameters)
          .then((html.HttpRequest httpRequest) {
        apiRequest = httpRequest;
      });

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: apiRequest.status ?? 404,
        data: apiRequest.response,
        errors: null,
        endpoint: params.endpoint
    );

      if(setUp.logResponse == true) {
        _logApiRequests(activeResponse);
      }

      if(saveResponse == true) {
        savedResponseName = savedResponseName == '' ? params.endpoint : savedResponseName;
        await _saveApiRequests(savedResponseName, activeResponse);
      }

    return activeResponse;
  }

  Future<ActiveResponse> postApi(Params params, RequestSetUp setUp, {
    String savedResponseName = '',
    bool saveResponse = false,
  }) async {
    html.HttpRequest apiRequest = _httpClientSetup(setUp.idleTimeout, setUp.withTrustedRoots,
        setUp.connectionTimeout, setUp.privateKeyPath, setUp.privateKeyPassword);
    await html.HttpRequest.request(params.endpoint, method: 'POST', sendData: params.queryParameters)
        .then((html.HttpRequest httpRequest) {
      apiRequest = httpRequest;
    });

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: apiRequest.status ?? 404,
        data: apiRequest.response,
        errors: null,
        endpoint: params.endpoint
    );

    if(setUp.logResponse == true) {
      _logApiRequests(activeResponse);
    }

    if(saveResponse == true) {
      savedResponseName = savedResponseName == '' ? params.endpoint : savedResponseName;
      await _saveApiRequests(savedResponseName, activeResponse);
    }

    return activeResponse;
  }

  Future<ActiveResponse> putApi(Params params, RequestSetUp setUp, {
    String savedResponseName = '',
    bool saveResponse = false,
  }) async {
    html.HttpRequest apiRequest = _httpClientSetup(setUp.idleTimeout, setUp.withTrustedRoots,
        setUp.connectionTimeout, setUp.privateKeyPath, setUp.privateKeyPassword);
    await html.HttpRequest.request(params.endpoint, method: 'PUT', sendData: params.queryParameters)
        .then((html.HttpRequest httpRequest) {
      apiRequest = httpRequest;
    });

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: apiRequest.status ?? 404,
        data: apiRequest.response,
        errors: null,
        endpoint: params.endpoint
    );

    if(setUp.logResponse == true) {
      _logApiRequests(activeResponse);
    }

    if(saveResponse == true) {
      savedResponseName = savedResponseName == '' ? params.endpoint : savedResponseName;
      await _saveApiRequests(savedResponseName, activeResponse);
    }

    return activeResponse;
  }

  Future<ActiveResponse> deleteApi(Params params, RequestSetUp setUp, {
    String savedResponseName = '',
    bool saveResponse = false,
  }) async {
    html.HttpRequest apiRequest = _httpClientSetup(setUp.idleTimeout, setUp.withTrustedRoots,
        setUp.connectionTimeout, setUp.privateKeyPath, setUp.privateKeyPassword);
    await html.HttpRequest.request(params.endpoint, method: 'DELETE', sendData: params.queryParameters)
        .then((html.HttpRequest httpRequest) {
      apiRequest = httpRequest;
    });

    ActiveResponse activeResponse = ActiveResponse(
        statusCode: apiRequest.status ?? 404,
        data: apiRequest.response,
        errors: null,
        endpoint: params.endpoint
    );

    if(setUp.logResponse == true) {
      _logApiRequests(activeResponse);
    }

    if(saveResponse == true) {
      savedResponseName = savedResponseName == '' ? params.endpoint : savedResponseName;
      await _saveApiRequests(savedResponseName, activeResponse);
    }

    return activeResponse;
  }

  _logApiRequests(ActiveResponse activeResponse) {
    printInfo(activeResponse.toString());
  }

  _saveApiRequests(String responseName, ActiveResponse activeResponse) async {
    // Memory memory = Memory;
    // memory.upsertMemory(responseName, activeResponse);
  }

}