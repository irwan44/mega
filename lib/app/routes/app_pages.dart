import 'package:get/get.dart';

import '../modules/account/bindings/account_binding.dart';
import '../modules/account/views/account_view.dart';
import '../modules/authentication/bindings/authentication_binding.dart';
import '../modules/authentication/componen/otp.dart';
import '../modules/authentication/componen/registrasi.dart';
import '../modules/authentication/views/authentication_view.dart';
import '../modules/create/bindings/create_binding.dart';
import '../modules/create/componen/webview.dart';
import '../modules/create/views/create_view.dart';
import '../modules/customers/bindings/customers_binding.dart';
import '../modules/customers/views/customers_view.dart';
import '../modules/form_linkaja/bindings/form_linkaja_binding.dart';
import '../modules/form_linkaja/views/form_linkaja_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/learning/bindings/learning_binding.dart';
import '../modules/learning/views/learning_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/quiz/views/quiz_view.dart';
import '../modules/reminder/bindings/reminder_binding.dart';
import '../modules/reminder/views/reminder_view.dart';
import '../modules/renew/bindings/renew_binding.dart';
import '../modules/renew/componen/webviewrenew.dart';
import '../modules/renew/views/renew_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_view.dart';
import '../modules/setting/bindings/setting_binding.dart';
import '../modules/setting/componen/edit_account.dart';
import '../modules/setting/views/setting_view.dart';
import '../modules/splashscreen/bindings/splashscreen_binding.dart';
import '../modules/splashscreen/views/splashscreen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SCHEDULE,
      page: () => const ScheduleView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMERS,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
    ),
    GetPage(
      name: _Paths.ACCOUNT,
      page: () => const AccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => const SettingView(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => const SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
    GetPage(
      name: _Paths.FORM_LINKAJA,
      page: () => const FormLinkajaView(),
      binding: FormLinkajaBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.REMINDER,
      page: () => const ReminderView(),
      binding: ReminderBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATION,
      page: () => AuthenticationView(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.RegistrationStepper,
      page: () => RegistrationStepper(),
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ,
      page: () =>  QuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.CREATE,
      page: () => const CreateView(),
      binding: CreateBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.RENEW,
      page: () => WebViewPagerenev(),
      binding: RenewBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.LEARNING,
      page: () => LearningView(),
      binding: LearningBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.OtpVerification,
      page: () => const OtpVerificationPage(),
      binding: LearningBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.WebView,
      page: () => const WebViewPage(),
      binding: LearningBinding(),
    ),
    GetPage(
      transition: Transition.rightToLeftWithFade,
      name: _Paths.EditAccountview,
      page: () => const EditAccount(),
      binding: LearningBinding(),
    ),
  ];
}
