import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/auth/auth_service.dart';

class BecomeInfluencerView extends StatefulWidget {
  const BecomeInfluencerView({super.key});

  @override
  State<BecomeInfluencerView> createState() => _BecomeInfluencerViewState();
}

class _BecomeInfluencerViewState extends State<BecomeInfluencerView> {
  RxBool isLoading = false.obs;
  RxInt userCoins = 0.obs;
  RxBool isInfluencer = false.obs;

  @override
  void initState() {
    super.initState();
    userCoins.value = GetProfileApi.profileModel?.user?.coin ?? 0;
    isInfluencer.value = GetProfileApi.profileModel?.user?.isInfluencer ?? false;
  }

  Future<void> _handleSubscribeInfluencer() async {
    final userId = Database.loginUserId;
    if (userId == null || userId.isEmpty) {
      CustomToast.show("Please login to subscribe.");
      return;
    }

    // if (userCoins.value < 100) {
    //   CustomToast.show(
    //       "Insufficient coins! You need 100 coins to become an influencer. You currently have ${userCoins.value} coins.");
    //   return;
    // }

    try {
      isLoading.value = true;
      final uri = Uri.parse("${Constant.baseURL}client/user/becomeInfluencer?userId=$userId");
      final headers = {
        "key": Constant.secretKey,
        "Content-Type": "application/json"
      };

      final response = await http.patch(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          if (GetProfileApi.profileModel?.user != null) {
            await GetProfileApi.callApi(userId);
          }
          userCoins.value = GetProfileApi.profileModel?.user?.coin ?? (userCoins.value - 100);
          isInfluencer.value = true;
          CustomToast.show(jsonResponse['message'] ??
              "Congratulations! You are now a verified Influencer 🎉");
        } else {
          CustomToast.show(jsonResponse['message'] ?? "Failed to become an influencer.");
        }
      } else {
        try {
          final jsonResponse = json.decode(response.body);
          CustomToast.show(jsonResponse['message'] ?? "Server error (${response.statusCode})");
        } catch (_) {
          CustomToast.show("Server error (${response.statusCode}). Please try again later.");
        }
      }
    } catch (e) {
      CustomToast.show("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60,
        leading: GestureDetector(
          onTap: () => Get.back(result: isInfluencer.value),
          child: Container(
            height: 40,
            width: 40,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: Obx(
              () => Image.asset(
                AppIcons.arrowBack,
                height: 20,
                width: 20,
                color: isDarkMode.value ? AppColor.white : AppColor.black,
              ),
            ),
          ),
        ),
        centerTitle: AppSettings.isCenterTitle,
        title: Text(
          "Become Influencer",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(AppIcons.king, width: 50, height: 50, color: Colors.amber),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Become an Influencer",
                    style: GoogleFonts.urbanist(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Unlock exclusive creator privileges with 100% Free & Unlimited Access!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Charge Card (100 Coins / Month)
            // Obx(
            //   () => Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.all(18),
            //     decoration: BoxDecoration(
            //       color: isDarkMode.value ? AppColor.secondDarkMode : Colors.amber.shade50,
            //       borderRadius: BorderRadius.circular(20),
            //       border: Border.all(color: Colors.amber.shade600, width: 1.5),
            //     ),
            //     child: Row(
            //       children: [
            //         Container(
            //           padding: const EdgeInsets.all(12),
            //           decoration: const BoxDecoration(
            //             color: Colors.amber,
            //             shape: BoxShape.circle,
            //           ),
            //           child: Image.asset(AppIcons.coin, width: 28, height: 28),
            //         ),
            //         const SizedBox(width: 14),
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 "Monthly Charge: 100 Coins",
            //                 style: GoogleFonts.urbanist(
            //                   fontSize: 17,
            //                   fontWeight: FontWeight.bold,
            //                   color: isDarkMode.value ? Colors.amber : Colors.brown.shade900,
            //                 ),
            //               ),
            //               const SizedBox(height: 3),
            //               Text(
            //                 "Duration: 1 Month (30 Days). Auto-expires after 1 month.",
            //                 style: GoogleFonts.urbanist(
            //                   fontSize: 12,
            //                   color: isDarkMode.value ? Colors.grey.shade300 : Colors.brown.shade700,
            //                 ),
            //               ),
            //               const SizedBox(height: 6),
            //               Text(
            //                 "Your Balance: ${userCoins.value} Coins",
            //                 style: GoogleFonts.urbanist(
            //                   fontSize: 13,
            //                   fontWeight: FontWeight.bold,
            //                   color: userCoins.value >= 100 ? Colors.green : Colors.red,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),

            // Benefits Header
            Text(
              "Influencer Benefits",
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            _buildBenefitRow(
              icon: Icons.verified,
              iconColor: Colors.blue,
              title: "Verified Influencer Badge",
              subtitle: "Special influencer tick badge displayed on your channel and comments.",
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.rocket_launch,
              iconColor: Colors.purple,
              title: "3x Algorithm Boost",
              subtitle: "Higher video & shorts distribution on home feed and search suggestions.",
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.monetization_on,
              iconColor: Colors.green,
              title: "Higher Monetization Rates",
              subtitle: "Earn extra revenue per watch hour and unlocked content.",
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.star,
              iconColor: Colors.amber,
              title: "Featured Directory Placement",
              subtitle: "Featured in the main Influencer List for thousands of users to discover.",
            ),
            const SizedBox(height: 12),
            _buildBenefitRow(
              icon: Icons.headset_mic,
              iconColor: Colors.orange,
              title: "Priority Support & Perks",
              subtitle: "Dedicated VIP creator support and early access to new features.",
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),

      // Bottom Action Button (Disabled when isInfluencer is true)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                // Disabled when user is already an influencer or when API is loading
                onPressed: (isInfluencer.value || isLoading.value)
                    ? null
                    : () {
          if (!AuthService.checkLogin()) return;
          _handleSubscribeInfluencer();
        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInfluencer.value ? Colors.green : AppColor.primaryColor,
                  disabledBackgroundColor: isInfluencer.value ? Colors.green.shade700 : Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 4,
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isInfluencer.value) ...[
                            const Icon(Icons.verified, color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              "You are already an influencer",
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ] else ...[
                            // Image.asset(AppIcons.coin, width: 22, height: 22),
                            // const SizedBox(width: 10),
                            Text(
                              "Become Influencer",
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode.value ? AppColor.secondDarkMode : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode.value ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: isDarkMode.value ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
