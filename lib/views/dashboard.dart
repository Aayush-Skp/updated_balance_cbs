import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/utils/size_utils.dart';
import 'package:balance_cbs/common/widget/common_page.dart';
import 'package:balance_cbs/feature/pos_print/printer_widget.dart';
import 'package:balance_cbs/views/pages/Data%20pull/pull_data_screen.dart';
import 'package:balance_cbs/views/pages/payment_page/payment_page_widget.dart';
import 'package:balance_cbs/views/pages/data_push/PushDataScreen.dart';
import 'package:balance_cbs/views/pages/receipt_report/receipt_report_page.dart';
import 'package:balance_cbs/views/receipt_screen/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
        iconPath: 'assets/icons/icon4.svg',
        title: 'Receipt',
        destination: const ReceiptScreen()),
    DashboardItem(
        iconPath: 'assets/icons/icon5.svg',
        title: 'Payment',
        destination: const PaymentPageWidget()),
    DashboardItem(
        iconPath: 'assets/icons/icon2.svg',
        title: 'Receipt Report',
        destination: const ReceiptReportPage()),
    DashboardItem(
        iconPath: 'assets/icons/icon1.svg',
        title: 'Payment Report',
        destination: const PaymentPageWidget()),
    DashboardItem(
        iconPath: 'assets/icons/icon6.svg',
        title: 'Push Data',
        destination: const PushDataScreen()),
    DashboardItem(
        iconPath: 'assets/icons/icon3.svg',
        title: 'Pull Data',
        destination: const PullData()),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomCommonPage(
      showbackButton: false,
      child: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = _dashboardItems[index];
                    return buildIconButton(item.iconPath, item.title, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => item.destination),
                      );
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildIconButton(String svgPath, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                colorFilter: const ColorFilter.mode(
                  CustomTheme.appThemeColorSecondary,
                  BlendMode.srcIn,
                ),
                width: 58,
                height: 58,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  final String iconPath;
  final String title;
  final Widget destination;

  DashboardItem(
      {required this.iconPath, required this.title, required this.destination});
}
