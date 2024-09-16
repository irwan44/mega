import 'package:bank_mega/app/modules/authentication/componen/widget/common.dart';
import 'package:bank_mega/app/modules/authentication/componen/widget/custom.dart';
import 'package:bank_mega/app/modules/authentication/componen/widget/fedeanimasi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInAnimation(
                delay: 1,
                child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back_rounded)
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInAnimation(
                      delay: 1.3,
                      child: Text(
                        "Create new password",
                        style: Common().titelTheme,
                      ),
                    ),
                    FadeInAnimation(
                      delay: 1.6,
                      child: Text(
                        "Your new password must be unique from those previously used.",
                        style: Common().mediumThemeblack,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  child: Column(
                    children: [
                      const FadeInAnimation(
                        delay: 1.9,
                        child: CustomTextFormField(
                          hinttext: 'New password',
                          obsecuretext: false,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const FadeInAnimation(
                        delay: 2.1,
                        child: CustomTextFormField(
                          hinttext: 'Confirm password',
                          obsecuretext: false,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      FadeInAnimation(
                        delay: 2.4,
                        child: CustomElevatedButton(
                          message: "Reset Password ",
                          function: () {
                            // GoRouter.of(context)
                            //     .pushNamed(Routers.passwordchanges.name);
                          },
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
