
import 'package:balance_cbs/common/widget/bottom.dart';
import 'package:balance_cbs/common/widget/commonforall.dart';
import 'package:balance_cbs/views/pages/Data%20pull/pull_data_screen.dart';
import 'package:balance_cbs/views/pages/data_push/PushDataScreen.dart';
import 'package:balance_cbs/views/pages/payment_page/payment_page_widget.dart';
import 'package:balance_cbs/views/pages/receipt_report/receipt_report_page.dart';
import 'package:balance_cbs/views/receipt_screen/receipt_screen.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final List<String> imgPaths = [
    'assets/menu/receipt.png',
    'assets/menu/payment.png',
    'assets/menu/receiptreport.png',
    'assets/menu/paymentreport.png',
    'assets/menu/pushdata.png',
    'assets/menu/pull.png',
  ];

  final List<Widget> paths = [
    ReceiptScreen(),
    PaymentPageWidget(),
    ReceiptReportPage(),
    PaymentPageWidget(),
    PushDataScreen(),
    PullData(),
  ];

  Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    const int crossAxisCount = 2;

    final commonForAllHeight = height * 0.15;
    final bottomBarHeight = height * 0.2; 
    final availableHeight =
        height - commonForAllHeight - bottomBarHeight - (height * 0.03);

    final itemWidth =
        (width - (width * 0.08) - (width * 0.03 * (crossAxisCount - 1))) /
            crossAxisCount;
    final itemHeight =
        availableHeight / (imgPaths.length / crossAxisCount).ceil();

    return Scaffold(
      body: Column(
        children: [
          Commonforall(),
          SizedBox(height: height * 0.02),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: width * 0.03,
                mainAxisSpacing: height * 0.01,
                childAspectRatio:
                    itemWidth / itemHeight, 
                children: List.generate(imgPaths.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => paths[index]),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(imgPaths[index]),
                          fit: BoxFit
                              .contain,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
