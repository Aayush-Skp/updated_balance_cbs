import 'package:balance_cbs/common/app/theme.dart';
import 'package:balance_cbs/common/bloc/data_state.dart';
import 'package:balance_cbs/common/shared_pref.dart';
import 'package:balance_cbs/common/widget/common_page.dart';
import 'package:balance_cbs/common/widget/custom_snackbar.dart';
import 'package:balance_cbs/feature/auth/cubit/pull_data_cubit.dart';
import 'package:balance_cbs/feature/auth/models/customer_account_model.dart';
import 'package:balance_cbs/feature/auth/ui/screens/login_screen.dart';
import 'package:balance_cbs/feature/database/cb_db.dart';
import 'package:balance_cbs/feature/geoLocation/get_current_location.dart';
import 'package:balance_cbs/views/menu.dart';
import 'package:balance_cbs/views/new%20ui/common/bottom.dart';
import 'package:balance_cbs/views/new%20ui/common/commonforall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PullData extends StatefulWidget {
  const PullData({super.key});

  @override
  State<PullData> createState() => _PullDataState();
}

class _PullDataState extends State<PullData> {
  bool isFetching = false;
  bool isSyncing = false;
  bool isNewOnly = false;
  bool isConfirmValid = false;
  bool isFetchNew = false;
  bool isFetchAll = false;
  final TextEditingController _confirmController = TextEditingController();

  String? _currentUrl;
  String? _currentUsername;
  String? _currentClientAlias;

  bool _showMap = false;
  String coordinates = '';
  // bool _isLoadingLocation = false;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadMapStatus();
    _loadUserInfo();
  }

  void loadMapStatus() async {
    _showMap = await SharedPref.getMapStatus();
    _fetchLocation(_showMap);
    // setState(() {});
  }

  Future<void> _loadUserInfo() async {
    final url = await SharedPref.getUrl();
    final username = await SharedPref.getUsername();
    final clientAlias = await SharedPref.getAlias();
    setState(() {
      _currentUrl = url;
      _currentUsername = username;
      _currentClientAlias = clientAlias;
    });
  }

  // Future<void> _fetchLocation(bool newValue) async {
  //   setState(() {
  //     _isLoadingLocation = true;
  //   });
  //   if (newValue) {
  //     try {
  //       LocationService locationService = LocationService();
  //       final Mycoordinates = await locationService.getCurrentCoordinates();
  //       String denied = 'Location permissions are permanently denied';
  //       if (Mycoordinates == denied) {
  //         setState(() {
  //           _isLoadingLocation = false;
  //           _showMap = false;
  //           SharedPref.setMapStatus(false);
  //           coordinates = 'Error: $denied';
  //           SharedPref.removeCoordinates();
  //         });
  //         return;
  //       } else {
  //         setState(() {
  //           _showMap = true;
  //           SharedPref.setMapStatus(true);
  //           coordinates = Mycoordinates;
  //           SharedPref.setCoordinates(coordinates);
  //         });
  //       }
  //     } catch (e) {
  //       // User might have denied location permission or some error occurred
  //       setState(() {
  //         _isLoadingLocation = false;

  //         _showMap = false;
  //         SharedPref.setMapStatus(false);

  //         coordinates = 'Error: $e';
  //         SharedPref.removeCoordinates();
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _showMap = false;
  //       SharedPref.setMapStatus(false);

  //       SharedPref.removeCoordinates();

  //       coordinates = '';
  //     });
  //   }
  //   setState(() {
  //     _isLoadingLocation = false;
  //   });
  // }

  Future<void> _fetchLocation(bool newValue) async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
    });

    if (newValue) {
      try {
        LocationService locationService = LocationService();

        // Try to get current coordinates with timeout
        final coordinatesResult = await locationService.getCurrentCoordinates();

        if (coordinatesResult == 'Location permission denied' ||
            coordinatesResult ==
                'Location permissions are permanently denied' ||
            coordinatesResult ==
                'Error retrieving location: The location service on the device is disabled.') {
          setState(() {
            _isLoadingLocation = false;
            _showMap = false;
            SharedPref.setMapStatus(false);
            coordinates = 'Error: $coordinatesResult';
            SharedPref.removeCoordinates();
          });

          // Optional: Show dialog to open app settings if permanently denied
          if (coordinatesResult ==
              'Location permissions are permanently denied') {
            await Geolocator.openAppSettings();
          }

          return;
        }

        // Success: update state
        setState(() {
          _showMap = true;
          SharedPref.setMapStatus(true);
          coordinates = coordinatesResult;
          SharedPref.setCoordinates(coordinates);
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _showMap = false;
          SharedPref.setMapStatus(false);
          coordinates = 'Error: $e';
          SharedPref.removeCoordinates();
        });
      }
    } else {
      setState(() {
        _showMap = false;
        SharedPref.setMapStatus(false);
        SharedPref.removeCoordinates();
        coordinates = '';
      });
    }
    setState(() {
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("bool: $_showMap");
    print("coordinates: $coordinates");
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    List<CustomerAccountModel> customers = [];

    return Scaffold(
      body: Column(
        children: [
          Commonforall(
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  _buildUserInfoCard(screenWidth, screenHeight),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    child: (isSyncing || isFetching)
                        ? _buildWarningCard()
                        : const SizedBox.shrink(),
                  ),
                  _buildMainContent(customers),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }

  Widget _buildUserInfoCard(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xffC2DDFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // First Row with ID and Logout
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildImageWithText(
                'assets/profile/id.png',
                'ID',
                _currentUsername ?? "Not available",
                screenWidth,
              ),
            ),
            GestureDetector(
              onTap: () {
                SharedPref.setRememberMe(false);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Container(
                width: screenWidth * 0.30,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xffC2DDFF),
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/profile/logout.png',
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),
        buildImageWithTextRow(
          'assets/profile/URL.png',
          'URL',
          _currentUrl ?? "Not available",
          screenWidth,
        ),
        SizedBox(height: screenHeight * 0.02),
        buildImageWithTextRow(
          'assets/profile/client.png',
          'Client Alias',
          _currentClientAlias ?? "Not available",
          screenWidth,
        ),
        SizedBox(height: screenHeight * 0.015),

        buildImageWithToggleRow('assets/profile/map.png', 'Map', _showMap,
            // (newValue) {
            //   setState(() {
            //     _showMap = newValue;
            //   });
            // },
            (newValue) async {
          // setState(() {
          //   _showMap = newValue;
          // });
          await _fetchLocation(
              newValue); // This will handle the state change internally
        }, screenWidth, context, _isLoadingLocation),
      ]),
    );

    // return Container(
    //   width: double.infinity,
    //   padding: const EdgeInsets.all(16),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(12),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withOpacity(0.05),
    //         blurRadius: 8,
    //         offset: const Offset(0, 2),
    //       ),
    //     ],
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Row(
    //             children: [
    //               Container(
    //                 height: 36,
    //                 width: 36,
    //                 decoration: BoxDecoration(
    //                   color:
    //                       CustomTheme.appThemeColorSecondary.withOpacity(0.1),
    //                   borderRadius: BorderRadius.circular(8),
    //                 ),
    //                 child: const Icon(
    //                   Icons.person,
    //                   size: 20,
    //                   color: CustomTheme.appThemeColorSecondary,
    //                 ),
    //               ),
    //               const SizedBox(width: 12),
    //               Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   const Text(
    //                     "Id",
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Color(0xFF333333),
    //                     ),
    //                   ),
    //                   Text(
    //                     _currentUsername ?? "Not available",
    //                     style: TextStyle(
    //                       fontSize: 14,
    //                       color: Colors.grey.shade700,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //           InkWell(
    //             onTap: () {
    //               SharedPref.setRememberMe(false);
    //               Navigator.pushAndRemoveUntil(
    //                 context,
    //                 MaterialPageRoute(
    //                     builder: (context) => const LoginScreen()),
    //                 (route) => false,
    //               );
    //             },
    //             child: Container(
    //               padding: const EdgeInsets.all(8),
    //               decoration: BoxDecoration(
    //                 color: Colors.red.shade50,
    //                 borderRadius: BorderRadius.circular(8),
    //               ),
    //               child: Row(
    //                 children: [
    //                   Icon(
    //                     Icons.logout_outlined,
    //                     size: 20,
    //                     color: Colors.red.shade700,
    //                   ),
    //                   const SizedBox(width: 4),
    //                   Text(
    //                     "Logout",
    //                     style: TextStyle(
    //                       color: Colors.red.shade700,
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 14,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       const SizedBox(height: 16),
    //       _buildInfoRow(Icons.link, "URL", _currentUrl ?? "Not available"),
    //       const SizedBox(height: 8),
    //       _buildInfoRow(Icons.business, "Client Alias",
    //           _currentClientAlias ?? "Not available"),
    //     ],
    //   ),
    // );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: CustomTheme.appThemeColorPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: CustomTheme.appThemeColorPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber.shade800,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Please do not close this page until the data sync is complete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF664D03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(List<CustomerAccountModel> customers) {
    return Column(
      children: [
        // const SizedBox(height: 24),
        if (isSyncing || isFetching) _buildSyncTimeline(customers),
        const SizedBox(height: 10),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSyncTimeline(List<CustomerAccountModel> customers) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: CustomTheme.appThemeColorPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sync Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          if (isFetching)
            _buildTimelineItem(
              title: 'Fetching Data from Server',
              subtitle: 'Retrieving customer account information',
              isLoading: isFetching,
              isCompleted: customers.isNotEmpty && !isFetching,
              step: 1,
            ),
          if (isSyncing)
            _buildTimelineItem(
              title: 'Syncing to Local Database',
              subtitle: 'Updating customer records',
              isLoading: isSyncing,
              isCompleted: customers.isNotEmpty && !isSyncing && !isFetching,
              step: 2,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocConsumer<PullDataCubit, CommonState>(
      listener: (context, state) async {
        if (!context.mounted) return;
        if (state is CommonNoData) {
          setState(() {
            isFetching = false;
            isSyncing = false;
          });
          showCustomSnackBar(
              context: context,
              message: "There is Connectivity issue!",
              textColor: Colors.red);
        } else if (state is CommonError) {
          setState(() {
            isFetching = false;
            isSyncing = false;
          });
          showCustomSnackBar(context: context, message: state.message);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(state.message),
          //     backgroundColor: Colors.red,
          //     behavior: SnackBarBehavior.floating,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          // );
        } else if (state is CommonDataFetchSuccess<CustomerAccountModel>) {
          setState(() {
            isFetching = false;
            isSyncing = true;
          });

          List<CustomerAccountModel> customers = state.data;
          final db = CBDB();
          if (isNewOnly) {
            for (var customer in customers) {
              await db.insertIfNotExists(customer.toJson());
            }
          } else {
            await db.deleteAllAccounts();
            for (var customer in customers) {
              await db.upsertCustomerAccount(customer.toJson());
            }
          }

          if (context.mounted) {
            setState(() {
              isSyncing = false;
              isNewOnly = false;
              isFetchAll = false;
              isFetchNew = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade100),
                    const SizedBox(width: 10),
                    const Text('Data synced successfully'),
                  ],
                ),
                backgroundColor: CustomTheme.appThemeColorSecondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20),
          // decoration: BoxDecoration(
          //   // color: Colors.transparent,
          //   borderRadius: BorderRadius.circular(12),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.05),
          //       blurRadius: 8,
          //       offset: const Offset(0, 2),
          //     ),
          //   ],
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Sync Options",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Choose an option below to sync data with the server",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              if (!isFetchNew)
                _buildSyncButton(
                  image: AssetImage('assets/profile/fetch.png'),
                  label: "Fetch New Records Only",
                  description:
                      "Only download new customer records from the server",
                  isProcessing: isFetching || isSyncing,
                  onPressed: () {
                    setState(() {
                      isFetching = true;
                      isNewOnly = true;
                      isFetchAll = true;
                    });
                    context.read<PullDataCubit>().pullData();
                  },
                ),
              const SizedBox(height: 16),
              if (!isFetchAll)
                _buildSyncButton(
                  image: AssetImage('assets/profile/fetchall.png'),
                  label: "Fetch All Data",
                  description: "Replace all existing records with fresh data",
                  isProcessing: isFetching || isSyncing,
                  // isWarning: true,
                  onPressed: _confirmationRequest,
                ),
            ],
          ),
        );
      },
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
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: CustomTheme.appThemeColorPrimary),
          borderRadius: BorderRadius.circular(20),
          color: CustomTheme.appThemeColorPrimary
          // color: isWarning
          //     ? Colors.orange.shade50
          //     : CustomTheme.appThemeColorSecondary.withOpacity(0.05),
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
                  color: CustomTheme.appThemeColorPrimary,
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
                        : Image(image: image, width: 30, height: 40)

                    // Icon(
                    //     icon,
                    //     color: isWarning
                    //         ? Colors.orange.shade700
                    //         : CustomTheme.appThemeColorSecondary,
                    //     size: 24,
                    //   ),
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
                            : CustomTheme.darkerBlack,
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
              // Icon(
              //   Icons.arrow_forward_ios,
              //   size: 16,
              //   color: isWarning
              //       ? Colors.orange.shade400
              //       : CustomTheme.appThemeColorSecondary.withOpacity(0.5),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmationRequest() async {
    _confirmController.clear();
    isConfirmValid = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            // backgroundColor: Colors.transparent,
            // backgroundColor: CustomTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.red.shade700,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Warning: Data Replacement",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: CustomTheme.darkerBlack,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.dangerous_rounded,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "This will replace all your previous records!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Please type \"Confirm\" below to proceed:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  onChanged: (value) {
                    setState(() {
                      isConfirmValid = value.toLowerCase() == 'confirm';
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Type here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: CustomTheme.darkerBlack,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade700,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onPressed: () {
                        // setState(() {
                        //   isNewOnly = false;
                        //   isFetchAll = false;
                        //   isFetchNew = false;
                        // });
                        Navigator.pop(dialogContext, false);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: CustomTheme.appThemeColorSecondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor:
                            CustomTheme.appThemeColorPrimary,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                      onPressed: (isFetching || isSyncing || !isConfirmValid)
                          ? null
                          : () {
                              Navigator.pop(dialogContext, true);
                            },
                      child: const Text(
                        "Proceed",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );

    if (result == true) {
      if (mounted) {
        setState(() {
          isFetchNew = true;
          isFetching = true;
          isNewOnly = false;
        });
        context.read<PullDataCubit>().pullData();
      }
    }
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isLoading,
    required bool isCompleted,
    required int step,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? CustomTheme.appThemeColorSecondary
                : isLoading
                    ? Colors.transparent
                    : Colors.grey.shade300,
            border: Border.all(
              color: isCompleted
                  ? CustomTheme.appThemeColorSecondary
                  : isLoading
                      ? Colors.transparent
                      : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: CustomTheme.appThemeColorSecondary,
                      strokeWidth: 2,
                      // valueColor: AlwaysStoppedAnimation<Color>(
                      //   Colors.white,
                      // ),
                    ),
                  )
                : isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$step',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted || isLoading
                      ? CustomTheme.darkerBlack
                      : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWithText(
    String imagePath,
    String title,
    String subtitle,
    double screenWidth,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: screenWidth * 0.06,
          height: screenWidth * 0.14,
          decoration: BoxDecoration(
            color: const Color(0xffC2DDFF),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(subtitle, style: TextStyle(fontSize: screenWidth * 0.03)),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for other rows
  Widget buildImageWithTextRow(
    String imagePath,
    String title,
    String? subtitle,
    double screenWidth,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: screenWidth * 0.06,
          height: screenWidth * 0.14,
          decoration: BoxDecoration(
            color: const Color(0xffC2DDFF),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(subtitle ?? '',
                  style: TextStyle(fontSize: screenWidth * 0.03)),
            ],
          ),
        ),
      ],
    );
  }
}

Widget buildImageWithToggleRow(
    String imagePath,
    String title,
    bool value,
    Function(bool) onToggle,
    double screenWidth,
    BuildContext context,
    bool isLoadingLocation) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Left-side image
      Image.asset(
        imagePath,
        width: screenWidth * 0.06,
        height: screenWidth * 0.14,
      ),

      SizedBox(width: screenWidth * 0.04),

      // Texts (Map + Toggle status)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // prevents extra vertical space
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Toggle: ${value ? "ON" : "OFF"}',
              style: TextStyle(fontSize: screenWidth * 0.03),
            ),
          ],
        ),
      ),

      // Toggle switch aligned at the end of the row
      isLoadingLocation
          ? SizedBox(
              width: 24,
              height: 24,
              child: const CircularProgressIndicator(
                  color: CustomTheme.appThemeColorSecondary))
          : Switch(
              value: value,
              onChanged: onToggle,
              activeColor: CustomTheme.appThemeColorSecondary,
            ),
    ],
  );
}
