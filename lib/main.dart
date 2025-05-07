import 'package:balance_cbs/common/app/navigation_service.dart';
import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/wrapper/multi_bloc_wrapper.dart';
import 'package:balance_cbs/common/wrapper/multi_repo_wrapper.dart';
import 'package:balance_cbs/feature/auth/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryWrapper(
      child: MultiBlocWrapper(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigationKey,
          home: const MySplash(),
        ),
      ),
    );
  }
}

class MySplash extends StatefulWidget {
  const MySplash({super.key});

  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  void initState() {
    super.initState();
    _navigateToMyScreen();
  }

  void _navigateToMyScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.appThemeColorSecondary,
      body: Center(
        child: Image.asset(
          CustomTheme.mainLogoWhite,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
