import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/splash_controller.dart';
import 'package:sixam_mart_delivery/controller/theme_controller.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/images.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/view/base/confirmation_dialog.dart';
import 'package:sixam_mart_delivery/view/base/custom_image.dart';
import 'package:sixam_mart_delivery/view/screens/profile/widget/profile_bg_widget.dart';
import 'package:sixam_mart_delivery/view/screens/profile/widget/profile_button.dart';
import 'package:sixam_mart_delivery/view/screens/profile/widget/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<AuthController>(builder: (authController) {
        return authController.profileModel == null
            ? const Center(child: CircularProgressIndicator())
            : ProfileBgWidget(
                backButton: false,
                circularImage: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: Theme.of(context).cardColor),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                      child: CustomImage(
                    image:
                        '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}'
                        '/${authController.profileModel != null ? authController.profileModel!.image : ''}',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )),
                ),
                mainWidget: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                        child: Container(
                      width: 1170,
                      color: Theme.of(context).cardColor,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(children: [
                        Text(
                          '${authController.profileModel!.fName} ${authController.profileModel!.lName}',
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge),
                        ),
                        const SizedBox(height: 30),
                        Row(children: [
                          ProfileCard(
                              title: 'since_joining'.tr,
                              data:
                                  '${authController.profileModel!.memberSinceDays} ${'days'.tr}'),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          ProfileCard(
                              title: 'total_order'.tr,
                              data: authController.profileModel!.orderCount
                                  .toString()),
                        ]),
                        const SizedBox(height: 30),
                        //TODO:OLD
                        // ProfileButton(
                        //     icon: Icons.dark_mode,
                        //     title: 'dark_mode'.tr,
                        //     isButtonActive: Get.isDarkMode,
                        //     onTap: () {
                        //       Get.find<ThemeController>().toggleTheme();
                        //     }),
                        // const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                          imageData: "assets/icons/notification.png",
                          title: 'notification'.tr,
                          isButtonActive: authController.notification,
                          onTap: () {
                            authController.setNotificationActive(
                                !authController.notification);
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/message.png",
                            title: 'conversation'.tr,
                            onTap: () {
                              Get.toNamed(
                                  RouteHelper.getConversationListRoute());
                            }),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/languages.png",
                            title: 'Language'.tr,
                            onTap: () {
                              Get.toNamed(RouteHelper.getLanguageRoute());
                            }),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/unlock.png",
                            title: 'change_password'.tr,
                            onTap: () {
                              Get.toNamed(RouteHelper.getResetPasswordRoute(
                                  '', '', 'password-change'));
                            }),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/edit.png",
                            title: 'edit_profile'.tr,
                            onTap: () {
                              Get.toNamed(RouteHelper.getUpdateProfileRoute());
                            }),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/terms_condition.png",
                            title: 'terms_condition'.tr,
                            onTap: () {
                              Get.toNamed(RouteHelper.getTermsRoute());
                            }),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/privacy_policy.png",
                            title: 'privacy_policy'.tr,
                            onTap: () {
                              Get.toNamed(RouteHelper.getPrivacyRoute());
                            }),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                          imageData: "assets/icons/trash.png",
                          title: 'delete_account'.tr,
                          onTap: () {
                            Get.dialog(
                                ConfirmationDialog(
                                    icon: Images.warning,
                                    title: 'are_you_sure_to_delete_account'.tr,
                                    description:
                                        'it_will_remove_your_all_information'
                                            .tr,
                                    isLogOut: true,
                                    onYesPressed: () =>
                                        authController.removeDriver()),
                                useSafeArea: false);
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        ProfileButton(
                            imageData: "assets/icons/logout.png",
                            title: 'logout'.tr,
                            onTap: () {
                              Get.back();
                              Get.dialog(ConfirmationDialog(
                                  icon: Images.support,
                                  description: 'are_you_sure_to_logout'.tr,
                                  isLogOut: true,
                                  onYesPressed: () {
                                    Get.find<AuthController>()
                                        .clearSharedData();
                                    Get.find<AuthController>()
                                        .stopLocationRecord();
                                    Get.offAllNamed(
                                        RouteHelper.getSignInRoute());
                                  }));
                            }),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${'version'.tr}:',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall)),
                              const SizedBox(
                                  width: Dimensions.paddingSizeExtraSmall),
                              Text(AppConstants.appVersion.toString(),
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall)),
                            ]),
                      ]),
                    ))),
              );
      }),
    );
  }
}
