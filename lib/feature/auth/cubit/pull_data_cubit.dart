import 'package:bloc/bloc.dart';
import 'package:balance_cbs/common/bloc/data_state.dart';
import 'package:balance_cbs/common/http/response.dart';
import 'package:balance_cbs/feature/auth/models/customer_account_model.dart';
import 'package:balance_cbs/feature/auth/resources/user_repository.dart';

class PullDataCubit extends Cubit<CommonState> {
  PullDataCubit({required this.userRepository}) : super(CommonInitial());

  UserRepository userRepository;

  pullData() async {
    emit(CommonLoading());
    final res = await userRepository.pullData();
    if (res.status == Status.Success && res.data != null) {
      emit(CommonDataFetchSuccess<CustomerAccountModel>(data: res.data ?? []));
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
