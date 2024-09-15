

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
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
    _refreshController =
        RefreshController();
    super.initState();
  }
  Future<Map<String, int>?> _loadQuizScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final score = prefs.getInt('quiz_score');
      final totalPossibleScore = 100;
      if (score != null) {
        return {'score': score, 'total': totalPossibleScore};
      } else {
        return null;
      }
    } catch (e) {
      print('Error loading quiz score: $e');
      return null;
    }
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
          decoration: const BoxDecoration(
              color: Colors.white
          ),
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Aplikasi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
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
                    child: const Text('Ya', style: TextStyle( color: Colors.white),),
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
    child:
      Scaffold(
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildShimmerAvatar(),
                const SizedBox(height: 16),
                _buildShimmerText(),
                const SizedBox(height: 10,),
                _buildShimmerText(),
                const SizedBox(height: 10,),
                _buildShimmerText(),
                const SizedBox(height: 10,),
                _buildShimmerText(),
                const SizedBox(height: 10,),
                _buildShimmerText(),
                const SizedBox(height: 10,),
                _buildShimmerText(),
                const SizedBox(height: 10,),
                _buildShimmerText(),
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
              child:
              SingleChildScrollView(
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
                        child:  Text(
                          '${userProfile?.name ?? 'N/A'}',
                          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(child :
                      Container(
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10)
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
                                    const SizedBox(width: 10,),
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
                      Divider(color :Colors.grey.shade300),
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
                      Divider(color :Colors.grey.shade300),
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
                            borderRadius: BorderRadius.circular(10)
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
                                FutureBuilder<Map<String, int>?>(
                                  future: _loadQuizScore(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasData && snapshot.data != null) {
                                      final data = snapshot.data!;
                                      final score = data['score'] ?? 0;
                                      final total = data['total'] ?? 1; // Avoid division by zero
                                      final percentage = (score / total) * 100;
                                      return Text(
                                        'Score: (${percentage.toStringAsFixed(2)}%)',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      );
                                    } else {
                                      return const Text(
                                        'No Quiz Score Available',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      );
                                    }
                                  },
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
                                  '',
                                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
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
            return const Center(
              child: Text(
                'Failed to load profile',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
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

  Widget _buildShimmerText() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: Colors.grey[300]!,
      colorOpacity: 0.5,
      enabled: true,
      direction: const ShimmerDirection.fromLBRT(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
        ),
        height: 20,

      ),
    );
  }

  _onLoading() {
    _refreshController
        .loadComplete(); // after data returned,set the //footer state to idle
  }

  _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {

      // const ProfileView();
      _refreshController
          .refreshCompleted();
    });
  }
}

