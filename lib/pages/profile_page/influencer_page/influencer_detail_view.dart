import 'dart:convert';
import 'dart:ui';
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
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/auth/auth_service.dart';

class InfluencerDetailView extends StatefulWidget {
  final Map<String, dynamic> influencer;

  const InfluencerDetailView({super.key, required this.influencer});

  @override
  State<InfluencerDetailView> createState() => _InfluencerDetailViewState();
}

class _InfluencerDetailViewState extends State<InfluencerDetailView> {
  RxBool isFollowed = false.obs;
  RxBool isLoading = false.obs;
  RxInt followerCount = 0.obs;

  RxString unlockedEmail = "".obs;
  RxString unlockedPhone = "".obs;

  @override
  void initState() {
    super.initState();
    followerCount.value = widget.influencer['followerCount'] ?? 120;
    unlockedEmail.value = widget.influencer['email'] ?? "";
    unlockedPhone.value = widget.influencer['mobileNumber'] ?? widget.influencer['phone'] ?? "+91 98765 43210";
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final userId = Database.loginUserId;
    final influencerId = widget.influencer['_id'];
    if (userId == null || influencerId == null) return;

    try {
      final uri = Uri.parse(
          "${Constant.baseURL}client/user/checkFollowStatus?userId=$userId&influencerId=$influencerId");
      final headers = {"key": Constant.secretKey};
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonRes = json.decode(response.body);
        if (jsonRes['status'] == true) {
          isFollowed.value = jsonRes['isFollowed'] ?? false;
          if (jsonRes['email'] != null && jsonRes['email'].toString().isNotEmpty) {
            unlockedEmail.value = jsonRes['email'];
          }
          if (jsonRes['mobileNumber'] != null && jsonRes['mobileNumber'].toString().isNotEmpty) {
            unlockedPhone.value = jsonRes['mobileNumber'];
          }
        }
      }
    } catch (e) {
      AppSettings.showLog("Error checking follow status: $e");
    }
  }

  // Popup Dialog to confirm paying 100 coins and following influencer
  void _showFollowConfirmationDialog() {
    final userCoins = GetProfileApi.profileModel?.user?.coin ?? 0;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(AppIcons.coin, width: 42, height: 42),
              ),
              const SizedBox(height: 16),
              Text(
                "Follow Influencer",
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "To follow this influencer you have to pay 100 coins.",
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode.value ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Following will deduct 100 coins and clearly unlock all influencer details including Email and Phone number.",
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Your Coins: $userCoins Coins",
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: userCoins >= 100 ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (!AuthService.checkLogin()) return;
                        _executeFollowApi();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Follow",
                        style: GoogleFonts.urbanist(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeFollowApi() async {
    final userId = Database.loginUserId;
    final influencerId = widget.influencer['_id'];

    if (userId == null || userId.isEmpty) {
      CustomToast.show("Please login to follow influencers.");
      return;
    }

    try {
      isLoading.value = true;
      final uri = Uri.parse("${Constant.baseURL}client/user/followInfluencer");
      final headers = {
        "key": Constant.secretKey,
        "Content-Type": "application/json"
      };

      final body = json.encode({
        "userId": userId,
        "influencerId": influencerId,
      });

      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        final jsonRes = json.decode(response.body);
        if (jsonRes['status'] == true) {
          isFollowed.value = jsonRes['isFollowed'] ?? !isFollowed.value;
          if (isFollowed.value) {
            followerCount.value++;
            if (GetProfileApi.profileModel?.user != null) {
              await GetProfileApi.callApi(userId);
            }
            if (jsonRes['email'] != null && jsonRes['email'].toString().isNotEmpty) {
              unlockedEmail.value = jsonRes['email'];
            }
            if (jsonRes['mobileNumber'] != null && jsonRes['mobileNumber'].toString().isNotEmpty) {
              unlockedPhone.value = jsonRes['mobileNumber'];
            }
          } else {
            if (followerCount.value > 0) followerCount.value--;
          }
          CustomToast.show(jsonRes['message'] ?? "Follow status updated!");
        } else {
          CustomToast.show(jsonRes['message'] ?? "Failed to update follow status.");
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
    final inf = widget.influencer;
    final name = inf['fullName'] ?? inf['nickName'] ?? "Influencer";
    final description = (inf['descriptionOfChannel'] != null &&
            inf['descriptionOfChannel'].toString().trim().isNotEmpty)
        ? inf['descriptionOfChannel']
        : "Official verified influencer content creator sharing daily creative videos and shorts.";
    final country = inf['country'] ?? "Global";
    final rawImage = inf['image'] ?? "";

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
          onTap: () => Get.back(),
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
          "Influencer Details",
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.primaryColor, width: 3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: PreviewProfileImage(
                            id: inf['_id']?.toString() ?? "",
                            size: 100,
                            image: rawImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.urbanist(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Obx(
                        () => _buildStatTile(
                          count: "${followerCount.value}",
                          label: "Followers",
                        ),
                      ),
                      Container(height: 30, width: 1, color: Colors.grey.shade300),
                      _buildStatTile(
                        count: country,
                        label: "Location",
                      ),
                      Container(height: 30, width: 1, color: Colors.grey.shade300),
                      _buildStatTile(
                        count: "Verified",
                        label: "Status",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Influencer Details Section (Blurred if not followed, clear if followed)
            Obx(
              () => Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: isFollowed.value ? 0 : 8,
                      sigmaY: isFollowed.value ? 0 : 8,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode.value ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Influencer Details",
                                style: GoogleFonts.urbanist(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Email Row
                          _buildDetailRow(
                            icon: Icons.email_rounded,
                            iconColor: Colors.purple,
                            label: "Email Address",
                            value: isFollowed.value
                                ? (unlockedEmail.value.isNotEmpty
                                    ? unlockedEmail.value
                                    : (inf['email'] ?? "creator@influencer.com"))
                                : "hidden_influencer_email@domain.com",
                          ),
                          const SizedBox(height: 14),

                          // Phone Row
                          _buildDetailRow(
                            icon: Icons.phone_android_rounded,
                            iconColor: Colors.green,
                            label: "Phone / Mobile Number",
                            value: isFollowed.value
                                ? (unlockedPhone.value.isNotEmpty
                                    ? unlockedPhone.value
                                    : "+91 98765 43210")
                                : "+91 ***** *****",
                          ),
                          const SizedBox(height: 14),

                          // Bio / Description
                          Text(
                            "About Influencer",
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              color: isDarkMode.value ? Colors.grey.shade300 : Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay Lock Card when Not Followed
                  if (!isFollowed.value)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode.value
                            ? Colors.black.withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.amber, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock, color: Colors.amber, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            "Locked Profile Details",
                            style: GoogleFonts.urbanist(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode.value ? Colors.amber : Colors.brown.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Pay 100 coins to follow and clearly view email, phone number & complete details.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: isDarkMode.value ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),

      // Bottom Button "Follow Influencer"
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              height: 50,
              child: ElevatedButton(
                onPressed: (isLoading.value || isFollowed.value)
                    ? null
                    : () {
                        _showFollowConfirmationDialog();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowed.value ? Colors.green.shade700 : AppColor.primaryColor,
                  disabledBackgroundColor: isFollowed.value ? Colors.green.shade700 : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                ),
                child: isLoading.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFollowed.value ? Icons.check_circle : Icons.person_add_alt_1,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFollowed.value ? "Following Influencer" : "Follow Influencer",
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({required String count, required String label}) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
