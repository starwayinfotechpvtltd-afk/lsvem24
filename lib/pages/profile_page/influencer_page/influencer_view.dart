import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:metube/main.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/profile_page/influencer_page/become_influencer_view.dart';
import 'package:metube/pages/profile_page/influencer_page/influencer_detail_view.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/database/database.dart';

class InfluencerView extends StatefulWidget {
  const InfluencerView({super.key});

  @override
  State<InfluencerView> createState() => _InfluencerViewState();
}

class _InfluencerViewState extends State<InfluencerView> {
  RxBool isLoading = false.obs;
  RxBool isInfluencer = false.obs;
  RxBool isFetchingList = true.obs;
  RxList<dynamic> allInfluencers = <dynamic>[].obs;
  RxList<dynamic> filteredInfluencers = <dynamic>[].obs;
  RxString selectedCategory = "All".obs;
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = ["All", "Verified", "Trending", "Popular"];

  @override
  void initState() {
    super.initState();
    isInfluencer.value = GetProfileApi.profileModel?.user?.isInfluencer ?? false;
    searchController.addListener(() {
      _filterList();
    });
    fetchInfluencersList();
  }

  Future<void> fetchInfluencersList() async {
    try {
      isFetchingList.value = true;
      final userId = Database.loginUserId ?? "";
      final uri = Uri.parse("${Constant.baseURL}client/user/getInfluencers?userId=$userId");
      final headers = {"key": Constant.secretKey};

      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['influencers'] != null) {
          final rawList = jsonResponse['influencers'] as List<dynamic>;
          final filtered = rawList.where((item) => item['_id']?.toString() != userId).toList();
          allInfluencers.assignAll(filtered);
          _filterList();
        }
      }
    } catch (e) {
      AppSettings.showLog("Error fetching influencers: $e");
    } finally {
      isFetchingList.value = false;
    }
  }

  void _filterList() {
    final userId = Database.loginUserId ?? "";
    String query = searchController.text.toLowerCase().trim();
    var list = allInfluencers.where((item) {
      final itemUserId = item['_id']?.toString() ?? "";
      if (userId.isNotEmpty && itemUserId == userId) {
        return false;
      }
      final fullName = (item['fullName'] ?? "").toString().toLowerCase();
      final nickName = (item['nickName'] ?? "").toString().toLowerCase();
      final country = (item['country'] ?? "").toString().toLowerCase();

      final matchQuery = query.isEmpty ||
          fullName.contains(query) ||
          nickName.contains(query) ||
          country.contains(query);

      if (selectedCategory.value == "Verified") {
        return matchQuery && (item['isInfluencer'] == true);
      } else if (selectedCategory.value == "Trending") {
        return matchQuery && ((item['followerCount'] ?? 0) > 100);
      }
      return matchQuery;
    }).toList();

    filteredInfluencers.assignAll(list);
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
          "Influencers",
          style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Top right button "Become Influencer" / "Influencer"
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: (isInfluencer.value || isLoading.value)
                    ? null
                    : () async {
                        final res = await Get.to(() => const BecomeInfluencerView());
                        if (res == true) {
                          isInfluencer.value = GetProfileApi.profileModel?.user?.isInfluencer ?? true;
                          fetchInfluencersList();
                        }
                      },
                icon: isInfluencer.value
                    ? const Icon(Icons.verified, size: 16, color: Colors.white)
                    : const Icon(Icons.star, size: 16, color: Colors.white),
                label: Text(
                  isInfluencer.value ? "Already an influencer" : "Become Influencer",
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInfluencer.value ? Colors.green : AppColor.primaryColor,
                  disabledBackgroundColor: isInfluencer.value ? Colors.green : Colors.grey,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchInfluencersList,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Hero Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Featured Creators",
                              style: GoogleFonts.urbanist(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Discover & Follow Top Influencers",
                            style: GoogleFonts.urbanist(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              "${allInfluencers.length} Active Influencer Creators",
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(AppIcons.king, width: 44, height: 44, color: Colors.amber),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? AppColor.secondDarkMode : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode.value ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => _filterList(),
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      color: isDarkMode.value ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: isDarkMode.value ? Colors.grey : Colors.grey.shade600),
                      border: InputBorder.none,
                      hintText: "Search influencer name...",
                      hintStyle: GoogleFonts.urbanist(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                searchController.clear();
                                _filterList();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    return Obx(() {
                      bool isSelected = selectedCategory.value == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              selectedCategory.value = cat;
                              _filterList();
                            }
                          },
                          labelStyle: GoogleFonts.urbanist(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? Colors.white : (isDarkMode.value ? Colors.white70 : Colors.black87),
                          ),
                          selectedColor: AppColor.primaryColor,
                          backgroundColor: isDarkMode.value ? AppColor.secondDarkMode : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Influencer List",
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(
                    () => Text(
                      "${filteredInfluencers.length} Creators",
                      style: GoogleFonts.urbanist(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Influencer Cards List
              Obx(() {
                if (isFetchingList.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (filteredInfluencers.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: isDarkMode.value ? AppColor.secondDarkMode : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          "No Influencers Found",
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tap 'Become Influencer' at top right to join!",
                          style: GoogleFonts.urbanist(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredInfluencers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredInfluencers[index];
                    return _buildInfluencerCard(item);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfluencerCard(dynamic item) {
    final name = item['fullName'] ?? item['nickName'] ?? "Influencer";
    final followers = item['followerCount'] ?? 120;
    final rawImage = item['image'] ?? "";
    final country = item['country'] ?? "Global";
    final isVerifiedInf = item['isInfluencer'] == true;

    return Obx(
      () => InkWell(
        onTap: () {
          Get.to(() => InfluencerDetailView(influencer: Map<String, dynamic>.from(item)));
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode.value ? Colors.white12 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with Dual Ring Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFFFF512F)],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode.value ? AppColor.secondDarkMode : Colors.white,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: PreviewProfileImage(
                          id: item['_id']?.toString() ?? "",
                          size: 56,
                          image: rawImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (isVerifiedInf)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Badges Pill Row
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: AppColor.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          "$followers Followers",
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode.value ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text("•", style: GoogleFonts.urbanist(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            country,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // View Profile Pill Arrow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withValues(alpha: 0.15),
                      AppColor.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Profile",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColor.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
