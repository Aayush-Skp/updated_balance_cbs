import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/bloc/data_state.dart';
import 'package:balance_cbs/feature/auth/cubit/push_data_cubit.dart';
import 'package:balance_cbs/views/new%20ui/common/bottom.dart';
import 'package:balance_cbs/views/new%20ui/common/commonforall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PushDataScreen extends StatefulWidget {
  const PushDataScreen({super.key});

  @override
  State<PushDataScreen> createState() => _PushDataScreenState();
}

class _PushDataScreenState extends State<PushDataScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Commonforall(
            showBack: true,
          ),
          SizedBox(
            height: 100,
          ),
          BlocListener<PushDataCubit, CommonState>(
            listener: (context, state) async {
              if (!context.mounted) return;
              if (state is CommonLoading) {
                setState(() {
                  _isLoading = true;
                });
              }
              if (state is CommonError) {
                setState(() {
                  _isLoading = false;
                });
                _showErrorDialog(context, "Error while uploading");
              }

              if (state is CommonDataFetchSuccess<dynamic>) {
                setState(() {
                  _isLoading = false;
                });
                _showSuccessDialog(context, "${state.data[0]}");
              }
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading) ...[
                    const CircularProgressIndicator(
                        color: CustomTheme.appThemeColorSecondary),
                    const SizedBox(height: 16),
                    const Text("Uploading...",
                        style: TextStyle(
                            color: CustomTheme.appThemeColorSecondary,
                            fontSize: 16)),
                  ],
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _buildSyncButton(
                        description: "Push Data to the Server",
                        image: AssetImage('assets/push/push.png'),
                        isProcessing: _isLoading,
                        onPressed: () {
                          context.read<PushDataCubit>().pushData();
                        },
                        label: "Upload Data"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding:
            EdgeInsets.only(top: 20, bottom: 16, left: 24, right: 24),
        insetPadding: EdgeInsets.symmetric(horizontal: 40),
        title: Text(
          "Successfully Updated!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Icon(
              Icons.check_circle,
              color: CustomTheme.appThemeColorSecondary,
              size: 48, // Larger icon
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton({
    required ImageProvider image,
    required String label,
    required String description,
    required bool isProcessing,
    bool isWarning = false,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: isWarning
              ? Colors.orange.shade200
              : CustomTheme.appThemeColorSecondary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
        color: isWarning
            ? Colors.orange.shade50
            : CustomTheme.appThemeColorPrimary,
      ),
      child: InkWell(
        onTap: isProcessing ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isWarning
                      ? Colors.orange.shade100
                      : CustomTheme.appThemeColorSecondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isProcessing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isWarning
                                  ? Colors.orange.shade700
                                  : CustomTheme.appThemeColorSecondary,
                            ),
                          ),
                        )
                      : Image(
                          image: image,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProcessing ? "Processing..." : label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isWarning
                            ? Colors.orange.shade800
                            : CustomTheme.appThemeColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
