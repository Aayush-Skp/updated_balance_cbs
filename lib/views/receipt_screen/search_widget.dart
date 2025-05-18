// import 'package:balance_cbs/common/app/theme.dart';
// import 'package:balance_cbs/common/utils/size_utils.dart';
import 'package:balance_cbs/views/menu.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool showSearchBy;
  final int selectedIndex;
  // final VoidCallback onFilterPressed;
  // final ValueChanged<int> onTogglePressed;
  final VoidCallback onQRPressed;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.showSearchBy,
    required this.selectedIndex,
    // required this.onFilterPressed,
    // required this.onTogglePressed,
    required this.onQRPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 5, right: 30),
      child: Row(
        children: [
          IconButton(
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
            icon: Icon(Icons.arrow_circle_left_outlined),
          ),
          Expanded(
            child: SearchBar(
              controller: searchController,
              elevation: WidgetStatePropertyAll(0.0),
              hintText: 'Search by account name or number',
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              trailing: [const Icon(Icons.search)],
              onChanged: (value) {},
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: IconButton(
              color: Color(0xff23538D),
              onPressed: () {
                onQRPressed();
              },
              icon: Icon(Icons.qr_code),
            ),
          ),
        ],
      ),
    );
  }
}
