import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../data/localstorage.dart';
import '../../../routes/app_pages.dart';
import '../componen/ButtonSubmitWidget1.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  // final ProfileController controller = Get.put(ProfileController());
  late RefreshController _refreshController;

  Future<bool> _onWillPop() async {
    // Tampilkan BottomSheet konfirmasi saat pengguna ingin keluar
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text(
                  'Logout Aplikasi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin Logout dari aplikasi?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Jangan keluar
                    child: Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Logout', style: TextStyle( color: Colors.white),),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return shouldExit ?? false; // Mengembalikan false jika pengguna menekan di luar BottomSheet
  }

  Future<bool> _onWillPopp() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Aplikasi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Jangan keluar
                    child: Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true), // Keluar
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Ya', style: TextStyle( color: Colors.white),),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return shouldExit ?? false; // Mengembalikan false jika pengguna menekan di luar BottomSheet
  }
  @override
  void initState() {
    _refreshController =
        RefreshController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _onWillPopp();
      return true;
    },
    child:
      Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
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
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1000),
              border: Border.all(color: Colors.orange),
            ),
            child: Icon(
              Icons.notification_important_sharp,
              color: Colors.orange,
              size: 18,
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        child:
        SingleChildScrollView(child:
        Column(children: [
          SizedBox(height: 20,),
          _setting(),
          SizedBox(height: 20,),
          _logout(context),
          SizedBox(height: 30,),
          // Text('Aplikasi Versi ${controller.packageName}', style: GoogleFonts.nunito(color: MyColors.appPrimaryColor),),
          SizedBox(height: 70,),
        ],
        ),
        ),
      ),
      ),
    );
  }


  Widget _Profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(left: 20, right: 20),
          width: double.infinity,
          decoration: BoxDecoration(
            // color: MyColors.appPrimaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/images/profile.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "nama",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/icons/edit.svg',
                                width: 26,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "email",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "hp",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "mandor",
                            style: GoogleFonts.nunito(
                              // color: MyColors.appPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _setting() {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        // color: MyColors.bg,
      ),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 475),
          childAnimationBuilder: (widget) => SlideAnimation(
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            InkWell(
              onTap: () {
                Get.toNamed(Routes.EditAccountview);
              },
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_box_rounded,),
                      SizedBox(width: 10,),
                      Text('Edit Account', style: GoogleFonts.nunito(fontWeight: FontWeight.bold),),
                    ],),

                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400,),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Divider(color: Colors.grey.shade300,),
            ),
            InkWell(
              onTap: () {

              },
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.message_outlined,),
                      SizedBox(width: 10,),
                      Text('FAQ', style: GoogleFonts.nunito(fontWeight: FontWeight.bold),),
                    ],),

                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400,),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Divider(color: Colors.grey.shade300,),
            ),
            InkWell(
              onTap: () {
              },

              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.miscellaneous_services_rounded,),
                      SizedBox(width: 10,),
                      Text('Tems of Service', style: GoogleFonts.nunito(fontWeight: FontWeight.bold),),
                    ],),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400,),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Divider(color: Colors.grey.shade300,),
            ),
          ],
        ),
      ),
    );
  }
  Widget _logout(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _onWillPop();
      },
      child:
      Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          // color: MyColors.bg,
        ),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 475),
            childAnimationBuilder: (widget) => SlideAnimation(
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red,),
                      SizedBox(width: 10,),
                      Text('Log Out', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.red),),
                    ],),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.redAccent,),
                ],
              ),],
          ),
        ),
      ),
    );
  }
  void logout() {
    // Bersihkan cache untuk setiap data yang Anda simpan dalam cache
    LocalStorages.deleteToken();

    Get.offAllNamed(Routes.AUTHENTICATION);
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
