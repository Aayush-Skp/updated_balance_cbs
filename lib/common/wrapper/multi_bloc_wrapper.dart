import 'package:balance_cbs/feature/auth/cubit/login_cubit.dart';
import 'package:balance_cbs/feature/auth/cubit/pull_data_cubit.dart';
import 'package:balance_cbs/feature/auth/cubit/push_data_cubit.dart';
import 'package:balance_cbs/feature/auth/resources/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiBlocWrapper extends StatelessWidget {
  final Widget child;

  const MultiBlocWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(
            userRepository: RepositoryProvider.of<UserRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => PullDataCubit(
            userRepository: RepositoryProvider.of<UserRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => PushDataCubit(
            userRepository: RepositoryProvider.of<UserRepository>(context),
          ),
        ),
      ],
      child: child,
    );
  }
}
