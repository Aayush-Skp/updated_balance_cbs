import 'package:balance_cbs/common/app/navigation_service.dart';
import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/bloc/data_state.dart';
import 'package:balance_cbs/common/models/users.dart';
import 'package:balance_cbs/common/shared_pref.dart';
import 'package:balance_cbs/common/widget/custom_snackbar.dart';
import 'package:balance_cbs/feature/auth/cubit/login_cubit.dart';
import 'package:balance_cbs/views/menu.dart';
import 'package:balance_cbs/common/widget/bottom.dart';
import 'package:balance_cbs/feature/auth/ui/widgets/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  TextEditingController staffIdController = TextEditingController(text: "");
  TextEditingController clientAliasController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController passwordController = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettingData();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _loadSettingData() async {
    String alias = await SharedPref.getAlias();
    String url = await SharedPref.getUrl();
    setState(() {
      clientAliasController.text = alias;
      urlController.text = url;
    });
  }

  @override
  void dispose() {
    staffIdController.dispose();
    clientAliasController.dispose();
    urlController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _loadSavedCredentials() async {
    final rememberMe = await SharedPref.getRememberMe();
    if (rememberMe) {
      setState(
        () {},
      );
    }
  }

  Future<void> _showErrorDialog() async {
    final String message = await SharedPref.getInvalidResponse();
    if (mounted) {
      showCustomSnackBar(
          context: context, message: message, textColor: Colors.red);
    }
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // setState(() => _isLoading = true);
      context.read<LoginCubit>().loginUser(
            username: staffIdController.text.trim(),
            password: passwordController.text,
            clientAlias: clientAliasController.text.trim(),
            actualBaseUrl: urlController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<LoginCubit, CommonState>(
      listener: (context, state) {
        if (state is CommonLoading) {
          setState(() => _isLoading = true);
        }
        if (state is CommonStateSuccess<User>) {
          setState(() => _isLoading = false);

          if (_rememberMe) {
            SharedPref.setUsername(staffIdController.text);
            SharedPref.setPassword(passwordController.text);
            // SharedPref.setAlias(clientAliasController.text);
            // SharedPref.setUrl(urlController.text);
            SharedPref.setRememberMe(true);
          }

          NavigationService.push(target: Menu());
        } else if (state is CommonNoData) {
          showCustomSnackBar(
              context: context,
              message: "There is Connectivity issue!",
              textColor: Colors.red);
          setState(() => _isLoading = false);
        } else if (state is CommonError) {
          setState(() => _isLoading = false);
          _showErrorDialog();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          height: size.height,
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Image.asset(
                      'assets/halfcircle.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 60,
                      child:
                          Image.asset('assets/common/finact.png', width: 150),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Color(0xffC2DDFF),
                      ),
                      margin: EdgeInsets.only(top: 70, left: 20, right: 20),
                      padding: EdgeInsets.only(bottom: 40),
                      width: double.infinity,
                      // height: 500,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 70.0,
                          left: 10,
                          right: 10,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: staffIdController,
                                hintText: 'Staff Id',
                                onSuffixIconTap: () async {
                                  final result = await SharedPref.getUsername();
                                  setState(() {
                                    staffIdController =
                                        TextEditingController(text: result);
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter staff ID';
                                  }
                                  return null;
                                },
                              ),
                              // TextField(
                              //   controller: staffIdController,
                              //   decoration: InputDecoration(
                              //     filled: true,
                              //     fillColor: Colors.white,
                              //     enabledBorder: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(10),
                              //       borderSide: BorderSide(
                              //         color: Colors.blue.shade800,
                              //         width: 2,
                              //       ),
                              //     ),
                              //     focusedBorder: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(10),
                              //       borderSide: BorderSide(
                              //         color: Colors.blue.shade800,
                              //         width: 2,
                              //       ),
                              //     ),
                              //     hintText: "Staff Id",
                              //   ),
                              // ),
                              SizedBox(height: 20),
                              _buildPasswordField(),
                              SizedBox(height: 20),
                              _buildRememberMe(),

                              SizedBox(height: 10),
                              _buildLoginButton(),
                              SizedBox(height: 10),
                              // Center(
                              //   child: InkWell(
                              //     child: Text(
                              //       "Forgot Password?",
                              //       style: TextStyle(
                              //         color: Color(0xff23538D),
                              //         fontSize: 15,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //     onTap: () {},
                              //   ),
                              // ),
                              SizedBox(height: 20),
                              Center(
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Register(),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.manage_accounts,
                                        size: 55,
                                        color: Color(0xff23538D),
                                      ),
                                      Text(
                                        "Settings",
                                        style: TextStyle(
                                          color: Color(0xff23538D),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      child: Image.asset('assets/man.png', width: 120),
                      // size: 40,
                      // color: Color(0xff23538D),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                BottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    // required IconData prefixIcon,
    VoidCallback? onSuffixIconTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2B2D42),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blue.shade800,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blue.shade800,
                width: 2,
              ),
            ),
            hintText: "Enter $hintText",
            suffixIcon: IconButton(
              icon: const Icon(Icons.upload_file, color: Color(0xFF8D99AE)),
              onPressed: onSuffixIconTap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2B2D42),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xff23538D),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blue.shade800,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blue.shade800,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            activeColor: CustomTheme.appThemeColorSecondary,
            value: _rememberMe,
            // activeColor: CustomTheme.appThemeColorPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: const Text(
            'Remember me',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2B2D42),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: CustomTheme.appThemeColorSecondary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        onPressed: _isLoading
            ? null
            : () {
                if (_rememberMe) {
                  _handleLogin();
                } else {
                  showCustomSnackBar(
                      context: context,
                      message: 'Please select "Remember me" to continue');
                }
              },
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
