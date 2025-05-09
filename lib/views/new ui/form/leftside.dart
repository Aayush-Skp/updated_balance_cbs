import 'package:balance_cbs/views/new%20ui/common/style/boldtext.dart';
import 'package:flutter/material.dart';

class LeftColumn extends StatefulWidget {
  final Map<String, dynamic> account;

  const LeftColumn({required this.account, super.key});

  @override
  State<LeftColumn> createState() => _LeftColumnState();
}

class _LeftColumnState extends State<LeftColumn> {
  @override
  Widget build(BuildContext context) {
    final acc = widget.account;
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("AC TYPES", style: TextStyle(fontWeight: FontWeight.bold)),
        // Text("Alchik Bachat Khata"),
        Text(acc['account_type_name'].toString()),
        // acc['account_type_name'].toString().length < 22
        //     ? SizedBox(height: 6)
        //     : SizedBox.shrink(),

        Text(
          "INPUT AMOUNT(NRS)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 35,
          child: TextField(
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 7),
              filled: true,
              fillColor: Colors.white,
              enabled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        // SizedBox(height: 1),
        BoldText('ACCOUNT OPEN DATE'),
        Text(acc['ac_open_date'].toString()),
        BoldText('BALANCE'),
        Text(
          acc['balance'].toString(),
        ),
        BoldText('BALANCE DATE'),
        Text(
          acc['bal_date']?.split(' ')[0] ?? '',
        ),
        BoldText('INST AMOUNT(NRS)'),
        Text(
          acc['inst_amt'].toString(),
        ),
        BoldText('DUE AMOUNT(NRS)'),
        Text(
          acc['due_amt'].toString(),
        ),
        BoldText('PB CHECK DATE'),
        Text(
          acc['pb_check_date']?.split(' ')[0] ?? '',
        ),
      ],
    );
  }
}
