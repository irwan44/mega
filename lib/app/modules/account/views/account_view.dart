import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/data_endpoint/verifikasi.dart';
import '../../../data/endpoint.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late RefreshController _refreshController;
  Map<int, Color> statusColors = {
    0: Colors.blue, // Email Verification
    1: Colors.orange, // In Review
    2: Colors.green, // Approved
    3: Colors.red, // Rejected
    4: Colors.yellow, // PreTest
    5: Colors.purple, // PostTest
  };
  Map<int, String> statusMessages = {
    0: 'Email Verification',
    1: 'In Review',
    2: 'Approved',
    3: 'Rejected',
    4: 'PreTest',
    5: 'PostTest',
  };

  @override
  void initState() {
    _refreshController = RefreshController();
    super.initState();
  }

  Future<Verifikasi?> _loadUserProfile() async {
    try {
      final verifikasi = await API.VerifikasiID();
      return verifikasi;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Aplikasi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Ya',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/logo/mega_insurance.png',
            height: 30,
          ),
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1000),
                border: Border.all(color: Colors.orange),
              ),
              child: const Icon(
                Icons.notification_important_sharp,
                color: Colors.orange,
                size: 18,
              ),
            ),
          ],
        ),
        body: FutureBuilder<Verifikasi?>(
          future: _loadUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Display shimmer loading effect while waiting
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildShimmerAvatar(),
                  const SizedBox(height: 16),
                  _buildShimmerText(width: 200), // Name shimmer
                  const SizedBox(height: 20),
                  Center(child: _buildShimmerContainer(width: 120, height: 30)), // Status shimmer
                  const SizedBox(height: 20),
                  _buildShimmerContainer(width: double.infinity, height: 80), // Account details shimmer
                  const SizedBox(height: 30),
                  _buildShimmerText(width: 150), // Contact Details title shimmer
                  const SizedBox(height: 20),
                  _buildShimmerText(width: double.infinity), // Contact info shimmer
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  _buildShimmerText(width: double.infinity), // Contact info shimmer
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  _buildShimmerText(width: double.infinity), // Contact info shimmer
                  const SizedBox(height: 30),
                  _buildShimmerContainer(width: double.infinity, height: 80), // Scores shimmer
                ],
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              final userProfile = snapshot.data!.data;
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                header: const WaterDropHeader(),
                onLoading: _onLoading,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 475),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: userProfile?.attProfile != null
                                  ? NetworkImage('https://agencyapps.megainsurance.co.id/storage/${userProfile!.attProfile!}')
                                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              '${userProfile?.name ?? 'N/A'}',
                              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: statusColors[userProfile?.accountStatus ?? -1] ?? Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusMessages[userProfile?.accountStatus ?? -1] ?? 'N/A',
                                style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (userProfile?.rejectionNote != null)
                            Center(
                              child: Text(
                                'Note Rejection : ${userProfile!.rejectionNote}',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Number: ',
                                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${userProfile?.bankAccountNumber ?? 'N/A'}',
                                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '(${userProfile?.bankName ?? 'N/A'})',
                                          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'External ID',
                                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '${userProfile?.externalId ?? 'N/A'}',
                                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'Contact Details',
                            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email ',
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                              Text(
                                '${userProfile?.email ?? 'N/A'}',
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone Number ',
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                              Text(
                                '${userProfile?.phoneNumber ?? 'N/A'}',
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Address ',
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                              Text(
                                '${userProfile?.address ?? 'N/A'}',
                                style: GoogleFonts.nunito(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pre-Test Score ',
                                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '${userProfile?.preTestScore ?? 'N/A'}',
                                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Post-Test Score',
                                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                                    ),
                                    Text(
                                      '${userProfile?.postTestScore ?? 'N/A'}',
                                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildShimmerAvatar(),
                  const SizedBox(height: 16),
                  _buildShimmerText(width: 200), // Name shimmer
                  const SizedBox(height: 20),
                  Center(child: _buildShimmerContainer(width: 120, height: 30)), // Status shimmer
                  const SizedBox(height: 20),
                  _buildShimmerContainer(width: double.infinity, height: 80), // Account details shimmer
                  const SizedBox(height: 30),
                  _buildShimmerText(width: 150), // Contact Details title shimmer
                  const SizedBox(height: 20),
                  _buildShimmerText(width: double.infinity), // Contact info shimmer
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  _buildShimmerText(width: double.infinity), // Contact info shimmer
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  _buildShimmerText(width: double.infinity), // Contact info shimmer
                  const SizedBox(height: 30),
                  _buildShimmerContainer(width: double.infinity, height: 80), // Scores shimmer
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.grey[300]!,
      colorOpacity: 0.5,
      enabled: true,
      direction: const ShimmerDirection.fromLBRT(),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
      ),
    );
  }

  Widget _buildShimmerText({required double width}) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.grey[300]!,
      colorOpacity: 0.5,
      enabled: true,
      direction: const ShimmerDirection.fromLBRT(),
      child: Container(
        width: width,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({required double width, required double height}) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.grey[300]!,
      colorOpacity: 0.5,
      enabled: true,
      direction: const ShimmerDirection.fromLBRT(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
      ),
    );
  }

  _onLoading() {
    _refreshController.loadComplete();
  }

  _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      _refreshController.refreshCompleted();
    });
  }
}
