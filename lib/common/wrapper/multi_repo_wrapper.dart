import 'package:balance_cbs/common/http/api_provider.dart';
import 'package:balance_cbs/feature/auth/resources/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiRepositoryWrapper extends StatelessWidget {
  final Widget child;

  const MultiRepositoryWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiProvider>(
          create: (context) => ApiProvider(),
          lazy: true,
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
          )..initialState(),
          lazy: true,
        ),
      ],
      child: child,
    );
  }
}
