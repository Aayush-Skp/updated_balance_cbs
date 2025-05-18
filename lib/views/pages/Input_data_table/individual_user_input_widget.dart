import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/shared_pref.dart';
import 'package:balance_cbs/common/widget/customtabletextstyle.dart';
import 'package:balance_cbs/feature/database/cb_db.dart';
import 'package:balance_cbs/feature/pos_print/printer_util.dart';
import 'package:balance_cbs/common/utils/style/boldtext.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class IndividualUserInput extends StatefulWidget {
  final List<Map<String, dynamic>> account;
  final bool goback;
  final List<TextEditingController> passedAmountcontrollers;
  final List<TextEditingController> passedRemarkscontrollers;
  final VoidCallback? onAmountChanged;

  const IndividualUserInput({
    super.key,
    required this.account,
    this.goback = true,
    this.passedAmountcontrollers = const [],
    this.passedRemarkscontrollers = const [],
    this.onAmountChanged,
  });
  @override
  State<IndividualUserInput> createState() => _IndividualUserInputState();
}

class _IndividualUserInputState extends State<IndividualUserInput> {
  final ScrollController _horizontalController = ScrollController();
  late List<TextEditingController> amountControllers;
  late List<TextEditingController> remarksControllers;
  final dbService = CBDB();
  bool isSaving = false;
  late List<bool> isFromInputAmount;
  double totalBalance = 0;
  double totalInstAmount = 0;
  double totalDueAmount = 0;
  double totalInputAmount = 0;
  String coordinates = '';

  @override
  void dispose() {
    _horizontalController.dispose();

    if (widget.passedAmountcontrollers.isEmpty) {
      for (var controller in amountControllers) {
        controller.dispose();
      }
    }

    if (widget.passedRemarkscontrollers.isEmpty) {
      for (var controller in remarksControllers) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isFromInputAmount =
        widget.account.map((acc) => acc['input_amount'] != null).toList();

    if (widget.passedAmountcontrollers.isNotEmpty) {
      amountControllers = widget.passedAmountcontrollers;
    } else {
      amountControllers = widget.account
          .map((acc) =>
              TextEditingController(text: acc['col_amt']?.toString() ?? ''))
          .toList();
    }
    _loadCoordinates();
    // _fetchLocation();
    if (widget.passedRemarkscontrollers.isNotEmpty) {
      remarksControllers = widget.passedRemarkscontrollers;
    } else {
      remarksControllers = widget.account
          .map((acc) => TextEditingController(
              text: acc['col_remarks']?.toString() ??
                  acc['field_officer_name']?.toString() ??
                  ''))
          .toList();
    }

    for (var controller in amountControllers) {
      controller.addListener(_updateTotalInputAmount);
    }
    for (var controller in amountControllers) {
      controller.addListener(_updateTotalInputAmount);
    }
    _updateTotalInputAmount();
  }

  Future<void> _loadCoordinates() async {
    final result = await SharedPref.getCoordinates();
    setState(() {
      coordinates = result.toString();
    });
  }

  double getTotalEnteredAmount() {
    return amountControllers.fold<double>(0, (sum, controller) {
      double value = double.tryParse(controller.text) ?? 0;
      return sum + value;
    });
  }

  Future<void> openGoogleMaps(String url) async {
    if (url.isEmpty) {
      return;
    }
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not launch $url',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: CustomTheme.appThemeColorPrimary,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error launching URL: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: CustomTheme.appThemeColorPrimary,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      return;
    }
    final Uri uri = Uri.parse("tel:$phoneNumber");

    try {
      await launchUrl(uri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: CustomTheme.appThemeColorPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _updateTotalInputAmount() {
    setState(() {
      totalInputAmount = amountControllers.fold(0.0, (sum, controller) {
        double value = double.tryParse(controller.text) ?? 0.0;
        return sum + value;
      });
    });
    if (widget.onAmountChanged != null) {
      widget.onAmountChanged!();
    }
  }

  Future<void> _saveData() async {
    setState(() {
      isSaving = true;
    });
    try {
      final String uid = const Uuid().v4();
      for (int i = 0; i < widget.account.length; i++) {
        final account = widget.account[i];
        final amountText = amountControllers[i].text;
        final remarksText = remarksControllers[i].text;
        double? amount;
        if (amountText.isNotEmpty) {
          amount = double.tryParse(amountText);
          if (amount == null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text("Invalid amount for account ${account['ac_no']}")),
            );
            continue;
          }
        }
        await dbService.updateInputValuesForNewEntry(account['id'].toString(),
            amount ?? 0.0, remarksText, coordinates, uid);
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Would you like to print the receipt?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${widget.account.first['ac_name']}",
                    // style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Amount: '),
                      SizedBox(width: 8),
                      Text('$totalInputAmount'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Amount Added',
                  ),
                  Text(
                    'Successfully',
                  ),
                  Image.asset(
                    'assets/common/finact.png',
                    height: 100,
                    width: 130,
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    List<CollectionAccount> collectionAccounts =
                        widget.account.asMap().entries.map((account) {
                      return CollectionAccount(
                        accountType:
                            account.value['account_type_name'] ?? 'N/A',
                        accountNumber: account.value['ac_no'] ?? 'N/A',
                        amount: double.tryParse(
                                amountControllers[account.key].text) ??
                            0.0,
                        comment: account.value['col_remarks'] ?? '',
                      );
                    }).toList();

                    if (collectionAccounts.isEmpty) {
                      print('No accounts available to print');
                      return;
                    }

                    bool printSuccess =
                        await CollectionReceiptPrinter.printCollectionReceipt(
                      userName: widget.account.first['ac_name'],
                      groupName: widget.account.first['center_name'] ?? 'N/A',
                      collectionDate:
                          widget.account.first['col_date_time'] is DateTime
                              ? widget.account.first['col_date_time']
                              : DateTime.now(),
                      collectionLocation:
                          widget.account.first['col_location'] ?? 'N/A',
                      idNumber: widget.account.first['id_no'] ?? 'N/A',
                      accounts: collectionAccounts,
                    );
                    if (!printSuccess) {
                      print('Failed to print receipt');
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  // child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Color(0xffC2DDFF),
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      Colors.black,
                    ),
                  ),
                  child: Text("Print"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Color(0xffAE0003),
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );

          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating data: $e")),
        );
        print("Error updating data: $e");
      }
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> _confirmationRequest() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: Text(
            'Would you like to save changes?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Amount: '),
                  SizedBox(width: 8),
                  Text('$totalInputAmount'),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "${widget.account.first['ac_name']}",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Color(0xffAE0003),
                ),
                foregroundColor: WidgetStateProperty.all(
                  Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Color(0xffC2DDFF),
                ),
                foregroundColor: WidgetStateProperty.all(
                  Colors.black,
                ),
              ),
              child: Text("Confirm"),
              onPressed: () {
                Navigator.pop(context);
                _saveData();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("coordinates: $coordinates");
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerInfo(widget.account),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 14, right: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.goback)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      backgroundColor: CustomTheme.appThemeColorPrimary,
                    ),
                    onPressed: () {
                      // _saveData();
                      _confirmationRequest();
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(color: CustomTheme.darkerBlack),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCustomerInfo(List<Map<String, dynamic>> account) {
    final uniqueNames = account.map((e) => e['ac_name']).toSet().toList();
    final joinedNames = uniqueNames.join(', ');
    final firstAccount = account.first;
    print('Launching URL: ${firstAccount['add_location']}');
    print('Launching contact: ${firstAccount['contact']}');

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      width: 359,
      decoration: BoxDecoration(
        color: const Color(0xffC2DDFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Name: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(child: Text(joinedNames)),
            ],
          ),
          const SizedBox(height: 5),
          if (firstAccount['p_address'] != null &&
              firstAccount['p_address'] != '') ...[
            Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Address: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(firstAccount['p_address'])),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ],
          // ],
          if (firstAccount['contact'] != '/' &&
              firstAccount['contact'] != null &&
              firstAccount['contact'].toString().isNotEmpty)
            Column(
              children: [
                InkWell(
                  onTap: () {
                    makePhoneCall(firstAccount['contact']);
                  },
                  child: Row(
                    children: [
                      BoldText(
                        "Contact: ",
                      ),
                      Text(
                        "${firstAccount['contact'] ?? 'N/A'}",
                      ),
                      const Icon(
                        Icons.call_outlined,
                        color: CustomTheme.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          // : Container(),
          if (firstAccount['add_location'] != null &&
              firstAccount['add_location'] != '')
            Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Location: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      onTap: () {
                        openGoogleMaps(firstAccount['add_location']);
                      },
                      child: const Row(
                        children: [
                          Text(
                            "Click here to redirect",
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.place,
                            color: CustomTheme.appThemeColorSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          Row(
            children: [
              const Text(
                'ID Number: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(firstAccount['id_no'] ?? 'N/A'),
            ],
          ),
          // for (var accounts in account) ...[
          for (int i = 0; i < account.length; i++) ...[
            SizedBox(height: 10),
            Divider(color: Colors.white),
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _leftColumnWidget(account[i], i)),
                Expanded(child: _rightColumnWidget(account[i], i)),
              ],
            ),
          ],
          Divider(color: Colors.white),
          SizedBox(height: 20),
          grandTotalWidget(account),
        ],
      ),
    );
  }

  Widget _buildAccountsTable(
    List<Map<String, dynamic>> accounts,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
                MaterialStateProperty.all(CustomTheme.tableColorHead),
            headingRowHeight: 50,
            dataRowHeight: 60,
            horizontalMargin: 10,
            columnSpacing: 10,
            columns: const [
              DataColumn(
                label: Text('AC TYPES', style: CustomText.tableheading),
                tooltip: 'Account Types',
              ),
              DataColumn(
                label: Text('ACCOUNT', style: CustomText.tableheading),
                tooltip: 'Account Number',
              ),
              DataColumn(
                label:
                    Text('INPUT AMOUNT(NPR)', style: CustomText.tableheading),
                tooltip: 'Input Amount in NPR',
              ),
              DataColumn(
                label: Text('REMARKS INPUT', style: CustomText.tableheading),
                tooltip: 'Remarks',
              ),
              DataColumn(
                label:
                    Text('ACCOUNT OPEN DATE', style: CustomText.tableheading),
                tooltip: 'Date when account was opened',
              ),
              DataColumn(
                label: Text('MATURITY DATE', style: CustomText.tableheading),
                tooltip: 'Maturity Date',
              ),
              DataColumn(
                label: Text('BALANCE', style: CustomText.tableheading),
                tooltip: 'Current Balance',
                numeric: true,
              ),
              DataColumn(
                label: Text('BALANCE DATE', style: CustomText.tableheading),
                tooltip: 'Date of last balance update',
              ),
              DataColumn(
                label: Text('INST AMOUNT(NPR)', style: CustomText.tableheading),
                tooltip: 'Installment Amount in NPR',
                numeric: true,
              ),
              DataColumn(
                label: Text('DUE AMOUNT(NPR)', style: CustomText.tableheading),
                tooltip: 'Due Amount in NPR',
                numeric: true,
              ),
              DataColumn(
                label: Text('PB CHECK DATE', style: CustomText.tableheading),
                tooltip: 'Passbook Check Date',
              ),
            ],
            rows: [
              ...List.generate(
                accounts.length,
                (index) {
                  final acc = accounts[index];
                  setState(() {
                    totalBalance = accounts.fold<double>(
                      0,
                      (sum, acc) => sum + (acc['balance'] as num).toDouble(),
                    );
                    totalInstAmount = accounts.fold<double>(
                      0,
                      (sum, acc) => sum + (acc['inst_amt'] as num).toDouble(),
                    );
                    totalDueAmount = accounts.fold<double>(
                      0,
                      (sum, acc) => sum + (acc['due_amt'] as num).toDouble(),
                    );
                  });
                  return DataRow(
                    color: MaterialStateProperty.resolveWith((states) {
                      return index.isOdd
                          ? CustomTheme.tableColorPrimary
                          : CustomTheme.tableColorSecondary;
                    }),
                    cells: [
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            acc['account_type_name'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            acc['ac_no'],
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          width: 100,
                          child: TextField(
                            style: TextStyle(
                              color: isFromInputAmount[index]
                                  ? CustomTheme.appThemeColorSecondary
                                  : Colors.black87,
                              fontSize: 13,
                            ),
                            controller: amountControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          width: 120,
                          child: TextField(
                            style: const TextStyle(
                              color: CustomTheme.appThemeColorSecondary,
                              fontSize: 13,
                            ),
                            controller: remarksControllers[index],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['ac_open_date'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['maturity_date'] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['balance'].toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['bal_date']?.split(' ')[0] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['inst_amt'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['due_amt'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DataCell(
                        Text(
                          acc['pb_check_date']?.split(' ')[0] ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  );
                },
              ),
              DataRow(
                color: MaterialStateProperty.all(CustomTheme.tableColorHead),
                cells: [
                  const DataCell(
                    Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const DataCell(Text('')),
                  DataCell(
                    Text(
                      totalInputAmount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  DataCell(
                    Text(
                      totalBalance.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const DataCell(Text('')),
                  DataCell(
                    Text(
                      totalInstAmount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      totalDueAmount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const DataCell(Text('')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _leftColumnWidget(Map<String, dynamic> acc, int index) {
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("AC TYPES", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(acc['account_type_name'].toString()),
        Text(
          "INPUT AMOUNT (NRS)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 35,
          child: TextField(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFromInputAmount[index]
                  ? CustomTheme.appThemeColorSecondary
                  : Colors.black87,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            controller: amountControllers[index],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 7),
              filled: true,
              fillColor: Colors.white,
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
        BoldText('ACCOUNT OPEN DATE'),
        Text(acc['ac_open_date'].toString(), textAlign: TextAlign.center),
        BoldText('BALANCE'),
        Text(acc['balance'].toString()),
        BoldText('INST AMOUNT (NRS)'),
        Text(acc['inst_amt'].toString()),
        BoldText('DUE AMOUNT (NRS)'),
        Text(acc['due_amt'].toString()),
      ],
    );
  }

  Widget _rightColumnWidget(Map<String, dynamic> acc, int index) {
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BoldText('ACCOUNT'),
        Text(acc['ac_no'] ?? ''),
        if ((acc['account_type_name']?.toString().length ?? 0) > 22)
          SizedBox(height: 6),
        BoldText('MATURITY DATE'),
        Text(acc['maturity_date'] ?? ''),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: BoldText('BALANCE DATE'),
        ),
        Text(acc['bal_date']?.split(' ')[0] ?? ''),
        BoldText('PB CHECK DATE'),
        Text(acc['pb_check_date']?.split(' ')[0] ?? ''),
        BoldText('REMARKS INPUT'),
        SizedBox(
          height: 35,
          child: TextField(
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            controller: remarksControllers[index],
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
      ],
    );
  }

  Widget grandTotalWidget(
    List<Map<String, dynamic>> account,
  ) {
    setState(() {
      totalBalance = account.fold<double>(
        0,
        (sum, acc) => sum + (acc['balance'] as num).toDouble(),
      );
      totalInstAmount = account.fold<double>(
        0,
        (sum, acc) => sum + (acc['inst_amt'] as num).toDouble(),
      );
      totalDueAmount = account.fold<double>(
        0,
        (sum, acc) => sum + (acc['due_amt'] as num).toDouble(),
      );
    });
    // final acc = account;
    return Row(
      children: [
        Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BoldText(
              'Total Input Amount',
            ),
            Text(totalInputAmount.toString()),
            BoldText(
              'Total Installment Amount',
            ),
            Text(totalInstAmount.toString()),
          ],
        ),
        Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BoldText(
              'Total Balance Amount',
            ),
            Text(totalBalance.toString()),
            BoldText(
              'Total Due Amount',
            ),
            Text(totalDueAmount.toString()),
          ],
        )
        // Expanded(
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     alignment: Alignment.centerRight,
        //     child: Text(
        //       'grand total',

        //       // 'Grand Total (Left): ${calculateLeftTotal(accounts)}',
        //       style: const TextStyle(fontWeight: FontWeight.bold),
        //       textAlign: TextAlign.center,
        //     ),
        //   ),
        // ),
        // Expanded(
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     alignment: Alignment.centerRight,
        //     child: Text(
        //       'grand total',
        //       // 'Grand Total (Right): ${calculateRightTotal(accounts)}',
        //       style: const TextStyle(fontWeight: FontWeight.bold),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
