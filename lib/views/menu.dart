import 'package:balance_cbs/views/new%20ui/common/bottom.dart';
import 'package:balance_cbs/views/new%20ui/common/commonforall.dart';
import 'package:balance_cbs/views/new%20ui/pages/receipt_info.dart';
import 'package:balance_cbs/views/new%20ui/pages/receipt_report.dart';
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

    // Set a fixed column count (no dynamic changes)
    int crossAxisCount =
        2; // You can change this value as needed (e.g., 2, 3, 4, etc.)

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Commonforall widget
            Commonforall(),
            SizedBox(height: height * 0.02), // Proportional height for spacing

            // GridView for displaying the images
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04), // Proportional padding
              child: GridView.count(
                shrinkWrap: true, // Ensures the grid view is non-scrollable
                physics: NeverScrollableScrollPhysics(), // Disables scrolling
                crossAxisCount: crossAxisCount,
                crossAxisSpacing:
                    width * 0.03, // Proportional spacing between items
                mainAxisSpacing: height * 0.01, // Proportional vertical spacing
                childAspectRatio: 1, // Keep square boxes
                children: List.generate(imgPaths.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => paths[index]),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(imgPaths[index], fit: BoxFit.cover),
                    ),
                  );
                }),
              ),
            ),
            // ),
            //       );
            //     }),
            //   ),
            // ),

            // Empty space to push BottomBar to the bottom
            // Expanded(
            //   child: SizedBox(),
            // ),

            // BottomBar widget at the bottom
            BottomBar(),
          ],
        ),
      ),
    );
  }
}
