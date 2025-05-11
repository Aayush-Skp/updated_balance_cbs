import 'package:flutter/material.dart';

class CustomerInfoCard extends StatefulWidget {
  final String name;
  final List<Map<String, dynamic>> accounts;

  const CustomerInfoCard({
    super.key,
    required this.name,
    required this.accounts,
  });

  @override
  _CustomerInfoCardState createState() => _CustomerInfoCardState();
}

class _CustomerInfoCardState extends State<CustomerInfoCard> {
  // double sumOfInputAmounts = 0.0; // Or int if your amounts are integers
  bool isHidden = false;

  @override
  void initState() {
    super.initState();

    print('The length is ${widget.accounts.length}');
    if (widget.accounts.isNotEmpty) {
      print('The data is ${widget.accounts.first}');
    } else {
      print('No data found in accounts');
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('The length is $widget.accounts.length');
    // print('The data is $widget.accounts.first');
    final uniqueNames =
        widget.accounts.map((e) => e['ac_name']).toSet().toList();
    final acc_type =
        widget.accounts.map((e) => e['account_type_name']).toSet().toList();
    final joinedNames = uniqueNames.join(', ');
    final firstacc = widget.accounts.first;
    String contact = firstacc['contact']?.toString()?.trim() ?? '';
    String address = firstacc['p_address']?.toString()?.trim() ?? '';

    return Container(
      // margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.only(left: 10, top: 25, bottom: 20),
      width: 359,
      decoration: BoxDecoration(
        color: const Color(0xffC2DDFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Name: $joinedNames',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 8),
            child: Text(
              "Address: ${address.isNotEmpty ? address : 'N/A'}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 8),
            child: Text(
              // "Contact: ${firstacc['contact'].toString().trim() ?? 'N/A'}",
              "Contact: ${contact.isNotEmpty ? contact : 'N/A'}",

              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 8),
            child: Text(
              "Id Number: ${firstacc['id_no'] ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20.0, top: 4),
          //   child: Row(
          //     children: [
          //       Text(
          //         isHidden ? 'Rs. XXX.XX' : 'Rs. $totalInputNumber',
          //         style: const TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.w900,
          //         ),
          //       ),
          //       const SizedBox(width: 10),
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             isHidden = !isHidden;
          //           });
          //         },
          //         child: Icon(
          //           isHidden ? Icons.visibility_off : Icons.visibility,
          //           size: 20,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 10),
          Wrap(
            runSpacing: 10,
            children: acc_type.map((name) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xffE6F1FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
