import 'package:balance_cbs/common/app/navigation_service.dart';
import 'package:balance_cbs/common/shared_pref.dart';
import 'package:balance_cbs/common/widget/bottom.dart';
import 'package:balance_cbs/common/widget/common.dart';
import 'package:flutter/material.dart';
import 'package:balance_cbs/feature/auth/ui/widgets/login_widget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController clientAliasController = TextEditingController(text: "");
  TextEditingController urlController = TextEditingController(
    text: "",
  );
  final _formKey = GlobalKey<FormState>();

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      SharedPref.setAlias(clientAliasController.text);
      SharedPref.setUrl(urlController.text);
      NavigationService.push(target: LoginWidget());
    } else {
      print("Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: const CommonImages(),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xffC2DDFF),
                  ),
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  width: double.infinity,
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // API Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildInputField(
                          controller: urlController,
                          hintText: "API URL",
                          onSuffixIconTap: () async {
                            final result = await SharedPref.getUrl();
                            setState(() {
                              urlController =
                                  TextEditingController(text: result);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the API URL';
                            }
                            return null;
                          },
                        ),
                      ),

                      //Client Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildInputField(
                          controller: clientAliasController,
                          hintText: "Client Alias",
                          onSuffixIconTap: () async {
                            final result = await SharedPref.getAlias();
                            setState(() {
                              clientAliasController =
                                  TextEditingController(text: result);
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter client alias';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Save Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            _handleSave();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xff23538D),
                              width: 2.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(320, 50),
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(
                              color: Color(0xff23538D),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            hintText,
            style: const TextStyle(
              color: Color(0xff23538D),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: "Enter $hintText",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xff1F41BB),
                width: 3.0,
              ),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.upload_file, color: Color(0xFF8D99AE)),
              onPressed: onSuffixIconTap,
            ),
          ),
        ),
      ],
    );
  }
}
