import 'dart:convert';

import 'package:balance_cbs/common/app/navigation_service.dart';
import 'package:balance_cbs/common/http/api_provider.dart';
import 'package:balance_cbs/common/http/custom_exception.dart';
import 'package:balance_cbs/common/http/response.dart';
import 'package:balance_cbs/common/models/users.dart';
import 'package:balance_cbs/common/shared_pref.dart';
import 'package:balance_cbs/common/utils/snack_bar_utils.dart';
import 'package:balance_cbs/feature/auth/models/customer_account_model.dart';
import 'package:balance_cbs/feature/auth/resources/auth_api_provider.dart';
import 'package:balance_cbs/feature/auth/ui/screens/login_screen.dart';
import 'package:flutter/foundation.dart';

class UserRepository {
  ApiProvider apiProvider;
  late AuthApiProvider authApiProvider;

  String _token = '';

  final ValueNotifier<User?> _user = ValueNotifier(null);

  UserRepository({
    required this.apiProvider,
  }) {
    authApiProvider = AuthApiProvider(apiProvider: apiProvider);

    print(authApiProvider);
  }

  Future initialState() async {
    _token = await fetchToken();
    _isLoggedIn.value = _token.isNotEmpty;
  }

  Future<bool> logout({bool isSessionExpired = false}) async {
    try {
      _token = '';
      _isLoggedIn.value = false;
      _user.value = null;
      await SharedPref.deleteAccessToken();
      await SharedPref.deleteUser();
      if (isSessionExpired) {
        SnackBarUtils.showErrorBar(
          context: NavigationService.context,
          message: "Session expired. Please re-login",
        );
      }
      NavigationService.pushUntil(target: const LoginScreen());
      return true;
    } on Exception catch (_) {
      print('custom exception is been obtained');
    }
    return false;
  }

  Future<bool> persistToken(String token) async {
    try {
      await SharedPref.setAccessToken(token);

      _isLoggedIn.value = true;
      return true;
    } on Exception catch (_) {
      print('custom exception is been obtained');
    }
    return false;
  }

  Future<String> fetchToken() async {
    try {
      final token = await SharedPref.getAccessToken();
      if (token.isNotEmpty) {
        _token = token;
      }

      print("Token------------------------------------------");
      print(token);
    } on Exception catch (_) {
      print('custom exception is been obtained');
    }
    return token;
  }

  ValueNotifier<User?> get user => _user;

  String get token => _token;

  final ValueNotifier<bool> _isLoggedIn = ValueNotifier(false);

  ValueNotifier<bool> get isLoggedIn => _isLoggedIn;

  Future<DataResponse<User>> loginUser({
    required String username,
    required String password,
    required String clientAlias,
    required String actualBaseUrl,
  }) async {
    try {
      final res = await authApiProvider.loginUser(
        username: username,
        password: password,
        clientAlias: clientAlias,
        actualBaseUrl: actualBaseUrl,
      );
      User user = User.fromJson(res['data']);

      return DataResponse.success(user);
      // String accessToken = res['data']?['access_token'] ?? "";
      // String refreshToken = res['data']?['refresh_token'] ?? "";

      // if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
      //   persistToken(accessToken);
      //   _token = accessToken;

      //   return DataResponse.success(true);
      // } else {
      //   String error = res['data']['error'] ?? "";
      //   String errorDescription = res['data']['error_description'] ?? "";
      //   if (error.toLowerCase().contains("access_denied") &&
      //       errorDescription.toLowerCase().contains("otp")) {
      //     return DataResponse.success(true);
      //   }
      //   return DataResponse.error(errorDescription);
      // }
    } on CustomException catch (e) {
      if (e is SessionExpireErrorException) {
        rethrow;
      }
      return DataResponse.error(e.message!, e.statusCode);
    } catch (e) {
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<List<CustomerAccountModel>>> pullData() async {
    try {
      final res = await authApiProvider.pullData(
        username: await SharedPref.getUsername(),
        password: await SharedPref.getPassword(),
        clientAlias: await SharedPref.getAlias(),
        actualBaseUrl: await SharedPref.getUrl(),
      );

      List<CustomerAccountModel> allCustomerAccount =
          List.from(res['data']?['accounts'] ?? [])
              .map((e) => CustomerAccountModel.fromJson(e))
              .toList();

      await SharedPref.setAccountsList(
          allCustomerAccount.map((e) => jsonEncode(e.toJson())).toString());
      return DataResponse.success(allCustomerAccount);
    } on CustomException catch (e) {
      print("Error here $e");
      if (e is SessionExpireErrorException) {
        rethrow;
      }

      return DataResponse.error(e.message!, e.statusCode);
    } catch (e) {
      print("Error here $e");
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<dynamic>> pushData(List<dynamic> accounts) async {
    try {
      Map<String, dynamic> body = {
        "accounts": accounts,
      };
      final res = await authApiProvider.pushData(
        username: await SharedPref.getUsername(),
        password: await SharedPref.getPassword(),
        clientAlias: await SharedPref.getAlias(),
        actualBaseUrl: await SharedPref.getUrl(),
        body: jsonEncode(body),
      );
      return DataResponse.success(res);
    } on CustomException catch (e) {
      print("Error here in data push $e");
      if (e is SessionExpireErrorException) {
        rethrow;
      }
      return DataResponse.error(e.message!, e.statusCode);
    } catch (e) {
      print("Error here in data push $e");
      return DataResponse.error(e.toString());
    }
  }
}
