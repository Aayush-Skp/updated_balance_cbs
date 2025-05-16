import 'dart:io' show InternetAddress;
import 'package:bloc/bloc.dart';
import 'package:balance_cbs/common/bloc/data_state.dart';
import 'package:balance_cbs/common/http/response.dart';
import 'package:balance_cbs/feature/auth/models/customer_account_model.dart';
import 'package:balance_cbs/feature/auth/resources/user_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PullDataCubit extends Cubit<CommonState> {
  PullDataCubit({required this.userRepository}) : super(CommonInitial());

  UserRepository userRepository;

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return false;

      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  pullData() async {
    bool isConnected = await hasInternetConnection();

    emit(CommonLoading());
    final res = await userRepository.pullData();
    if (res.status == Status.Success && res.data != null) {
      emit(CommonDataFetchSuccess<CustomerAccountModel>(data: res.data ?? []));
    } else if (!isConnected) {
      emit(const CommonNoData());
    } else {
      emit(
        CommonError(
          message: res.message ?? "Error logging in.",
          statusCode: res.statusCode,
        ),
      );
    }
  }
}
