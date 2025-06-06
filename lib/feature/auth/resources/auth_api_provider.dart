import 'dart:convert';

import 'package:balance_cbs/common/http/api_provider.dart';
import 'package:balance_cbs/common/utils/url_utils.dart';

class AuthApiProvider {
  final ApiProvider apiProvider;

  const AuthApiProvider({
    required this.apiProvider,
  });

  Future<dynamic> loginUser({
    required String username,
    required String password,
    required String clientAlias,
    required String actualBaseUrl,
  }) async {
    final body = {
      "client_alias": clientAlias,
      "user_name": username,
      "password": password,
    };

    final uri = UrlUtils.getUri(
        url: "$actualBaseUrl/validatecollectorlogin", params: body);
    final mydata = await apiProvider.post(
      uri.toString(),
      {},
    );
    print("this is the output ${mydata.toString()} ${uri}");
    return mydata;
  }

  Future<dynamic> pullData({
    required String username,
    required String password,
    required String clientAlias,
    required String actualBaseUrl,
  }) async {
    try {
      final int? totalCount =
          await getTotalCount(username, password, clientAlias, actualBaseUrl);

      print("Total count received: $totalCount");
      if (totalCount == null) {
        throw Exception("Failed to fetch total record count.");
      }
      return await apiProvider.post(
        "$actualBaseUrl/downloaddata?current_page=1&record_count=$totalCount",
        {},
        header: {
          "Authorization":
              "Basic ${base64Encode("$username:$password".codeUnits)}",
          "client_alias": clientAlias
        },
      );
    } catch (e) {
      print('Error in pull Data : $e');
    }
  }

  Future<int?> getTotalCount(String username, String password,
      String clientAlias, String actualBaseUrl) async {
    try {
      final response = await apiProvider.post(
        "$actualBaseUrl/downloaddata?current_page=1&record_count=1",
        {},
        header: {
          "Authorization":
              "Basic ${base64Encode("$username:$password".codeUnits)}",
          "client_alias": clientAlias,
        },
      );
      print("This is my response: $response");
      if (response != null && response.containsKey('data')) {
        final data = response['data'];
        if (data != null &&
            data['success'] == true &&
            data.containsKey('accounts')) {
          try {
            final totalRecord = data['accounts'][0]['total_record'];
            if (totalRecord != null) {
              return totalRecord is int
                  ? totalRecord
                  : int.parse(totalRecord.toString());
            }
          } catch (e) {
            // print("Error extracting total_record: $e");
          }
        }
      }
      return null;
    } catch (e) {
      // print("Exception in getTotalCount: $e");
      return null;
    }
  }

  Future<dynamic> pushData({
    required String username,
    required String password,
    required String clientAlias,
    required dynamic body,
    required String actualBaseUrl,
  }) async {
    try {
      return await apiProvider.post(
        "$actualBaseUrl/uploaddata",
        body,
        header: {
          "Authorization":
              "Basic ${base64Encode("$username:$password".codeUnits)}",
          "client_alias": clientAlias
        },
      );
    } catch (e) {
      print('Error in Pushing the Data : $e');
    }
  }
}
