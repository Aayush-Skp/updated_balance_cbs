import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/widget/common_page.dart';
import 'package:balance_cbs/feature/database/cb_db.dart';
import 'package:balance_cbs/feature/qr_scan/qr_scan_widget.dart';
import 'package:balance_cbs/views/new%20ui/common/commonforall.dart';
import 'package:balance_cbs/views/pages/Input_data_table/input_data_table.dart';
import 'package:balance_cbs/views/pages/Input_data_table/input_table_by_group.dart';
import 'package:balance_cbs/views/receipt_screen/account_table_widget.dart';
import 'package:balance_cbs/views/receipt_screen/build_customer_info.dart';
import 'package:balance_cbs/views/receipt_screen/search_service.dart';
import 'package:balance_cbs/views/receipt_screen/search_widget.dart';
import 'package:flutter/material.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key});
  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final CBDB _db = CBDB();
  bool _isShowSearchBy = false;
  int _selectedIndex = 0;
  Map<String, List<Map<String, dynamic>>> _groupedAccounts = {};
  Map<String, List<Map<String, dynamic>>> _filteredAccounts = {};
  bool _isLoading = true;

  bool isHidden = true;
  // double amt = 100;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    _loadAccounts();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _db.getAllAccounts();
      final grouped = _groupAccountsByName(accounts);

      setState(() {
        _groupedAccounts = grouped;
        _filteredAccounts = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading accounts: $e');
    }
  }

  Future<void> _loadAccountsByGroup() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _db.getAllAccounts();
      final grouped = _groupAccountsByGroupName(accounts);
      setState(() {
        _groupedAccounts = grouped;
        _filteredAccounts = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading accounts: $e');
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupAccountsByName(
      List<Map<String, dynamic>> accounts) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var account in accounts) {
      // print("this is the result: ${account['is_inserted']}");
      if (account['is_inserted'] == 1) continue;
      final name = account['id_no'] as String;
      if (!grouped.containsKey(name)) {
        grouped[name] = [];
      }
      grouped[name]!.add(account);
    }
    return grouped;
  }

  Map<String, List<Map<String, dynamic>>> _groupAccountsByGroupName(
      List<Map<String, dynamic>> accounts) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var account in accounts) {
      final name = account['mf_grp_name'] as String;
      if (account['is_inserted'] == 1) continue;
      if (!grouped.containsKey(name)) {
        grouped[name] = [];
      }
      grouped[name]!.add(account);
    }
    return grouped;
  }

  void _handleSearch() {
    final query = _searchController.text.toLowerCase();

    setState(() =>
        _filteredAccounts = filterGroupedAccounts(_groupedAccounts, query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Commonforall(),
          SearchBarWidget(
            searchController: _searchController,
            showSearchBy: _isShowSearchBy,
            selectedIndex: _selectedIndex,
            // onFilterPressed: () {
            //   setState(() {
            //     _isShowSearchBy = !_isShowSearchBy;
            //   });
            // },
            // onTogglePressed: ((index) {
            //   setState(() {
            //     _selectedIndex = index;
            //     _selectedIndex == 0
            //         ? _loadAccounts()
            //         : _loadAccountsByGroup();
            //   });
            // }),
            onQRPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScanWidget(),
                ),
              );
            },
          ),
          const SizedBox(height: 5),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: _buildTable(),
          )),
        ],
        // ),
        // ),
      ),
    );
  }

  Widget _buildTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      controller: _verticalController,
      itemCount: _filteredAccounts.length,
      itemBuilder: (context, index) {
        final name = _filteredAccounts.keys.elementAt(index);
        final accounts = _filteredAccounts[name]!;

        // final totalAmount = accounts.fold<double>(
        //   0,
        //   (sum, acc) => sum + (acc['input_amount'] ?? 0 as num).toDouble(),
        // );
        final totalAmount = accounts.fold<double>(
          0,
          (sum, acc) => sum + ((acc['input_amount'] ?? 0) as num).toDouble(),
        );
        final dueAmount = accounts.fold<double>(
          0,
          (sum, acc) => sum + (acc['due_amt'] as num).toDouble(),
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return
                    // (_selectedIndex == 1)
                    //     ? GroupByGroupName(
                    //         groudName: name,
                    //       )
                    //     :
                    InputDataTable(
                  account: accounts,
                );
              }),
            ).then((_) {
              setState(() {
                // if (_selectedIndex == 0) {
                _loadAccounts();
                // } else {
                // _loadAccountsByGroup();
                // }
              });
            });
          },
          child: Padding(
            padding:
                // (_selectedIndex == 1)
                //     ? const EdgeInsets.symmetric(vertical: 3, horizontal: 5)
                //     :
                const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // (_selectedIndex == 1)
                //     ? _buildGroupNameList(name, accounts)
                //     :
                // _buildCustomerInfo(name, accounts),

                CustomerInfoCard(
                    name: name, accounts: accounts, amt: totalAmount),
                // const SizedBox(height: 10),
                // (_selectedIndex == 1)
                //     ? Container()
                //     :
                AccountTableWidget(
                  accounts: accounts,
                  dueAmount: dueAmount,
                  totalAmount: totalAmount,
                  horizontalController: _horizontalController,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildGroupNameList(String name, List<Map<String, dynamic>> accounts) {
  //   return Container(
  //     decoration: BoxDecoration(
  //         color: CustomTheme.tableColorSecondary,
  //         borderRadius: BorderRadius.circular(5),
  //         border: const Border.symmetric(
  //             vertical: BorderSide.none,
  //             horizontal:
  //                 BorderSide(color: CustomTheme.tableColorPrimary, width: 2))),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Text(
  //         "Group Name: $name",
  //         style: const TextStyle(fontWeight: FontWeight.w600),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCustomerInfo(String name, List<Map<String, dynamic>> accounts) {
  //   final uniqueNames = accounts.map((e) => e['ac_name']).toSet().toList();
  //   final joinedNames = uniqueNames.join(', ');
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Names: $joinedNames",
  //         style: const TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       Text(
  //         "Address: ${accounts.first['p_address'] ?? 'N/A'}",
  //       ),
  //       Text(
  //         "Group Name: ${accounts.first['center_name'] ?? 'N/A'}",
  //       ),
  //       (accounts.first['contact'] != '/' && accounts.first['contact'] != null)
  //           ? Row(
  //               children: [
  //                 Text(
  //                   "Contact: ${accounts.first['contact'] ?? 'N/A'}",
  //                 ),
  //                 const Icon(
  //                   Icons.call_outlined,
  //                   color: CustomTheme.appThemeColorPrimary,
  //                 ),
  //               ],
  //             )
  //           : Container(),
  //       Text(
  //         "Id Number: ${accounts.first['id_no'] ?? 'N/A'}",
  //       ),
  //     ],
  //   );
  // }
}
