import 'package:get/get.dart';
import 'package:metube/localization/languages/language_ar.dart';
import 'package:metube/localization/languages/language_bn.dart';
import 'package:metube/localization/languages/language_de.dart';
import 'package:metube/localization/languages/language_en.dart';
import 'package:metube/localization/languages/language_es.dart';
import 'package:metube/localization/languages/language_fr.dart';
import 'package:metube/localization/languages/language_hi.dart';
import 'package:metube/localization/languages/language_id.dart';
import 'package:metube/localization/languages/language_it.dart';
import 'package:metube/localization/languages/language_ja.dart';
import 'package:metube/localization/languages/language_pt.dart';
import 'package:metube/localization/languages/language_ru.dart';
import 'package:metube/localization/languages/language_sw.dart';
import 'package:metube/localization/languages/language_ta.dart';
import 'package:metube/localization/languages/language_te.dart';
import 'package:metube/localization/languages/language_tr.dart';
import 'package:metube/localization/languages/language_ur.dart';

import 'languages/language_ko.dart';
import 'languages/language_zh_cn.dart';

class AppLanguages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        "ar_DZ": enAr,
        "bn_In": enBn,
        "zh_CN": enZhCN,
        "en_US": enUS,
        "fr_Fr": enFr,
        "de_De": enDe,
        "hi_IN": enHi,
        "it_In": enIt,
        "id_ID": enId,
        "ja_JP": jaJP,
        "ko_KR": enKo,
        "pt_PT": enPt,
        "ru_RU": enRu,
        "es_ES": enEs,
        "sw_KE": enSw,
        "tr_TR": enTr,
        "te_IN": enTe,
        "ta_IN": enTa,
        "ur_PK": enUr,
      };
}

final List<LanguageModel> languages = [
  LanguageModel("dz", "Arabic (العربية)", 'ar', 'DZ'),
  LanguageModel("🇮🇳", "Bengali (বাংলা)", 'bn', 'IN'),
  LanguageModel("🇨🇳", "Chinese Simplified (中国人)", 'zh', 'CN'),
  LanguageModel("🇺🇸", "English (English)", 'en', 'US'),
  LanguageModel("🇫🇷", "French (français)", 'fr', 'FR'),
  LanguageModel("🇩🇪", "German (Deutsche)", 'de', 'DE'),
  LanguageModel("🇮🇳", "Hindi (हिंदी)", 'hi', 'IN'),
  LanguageModel("🇮🇹", "Italian (italiana)", 'it', 'IT'),
  LanguageModel("🇮🇩", "Indonesian (bahasa indo)", 'id', 'ID'),
  LanguageModel("🇯🇵", "Japanese (日本語)", 'ja', 'JP'),
  LanguageModel("🇰🇵", "Korean (한국인)", 'ko', 'KR'),
  LanguageModel("🇵🇹", "Portuguese (português)", 'pt', 'PT'),
  LanguageModel("🇷🇺", "Russian (русский)", 'ru', 'RU'),
  LanguageModel("🇪🇸", "Spanish (Español)", 'es', 'ES'),
  LanguageModel("🇰🇪", "Swahili (Kiswahili)", 'sw', 'KE'),
  LanguageModel("🇹🇷", "Turkish (Türk)", 'tr', 'TR'),
  LanguageModel("🇮🇳", "Telugu (తెలుగు)", 'te', 'IN'),
  LanguageModel("🇮🇳", "Tamil (தமிழ்)", 'ta', 'IN'),
  LanguageModel("🇵🇰", "(اردو) Urdu", 'ur', 'PK'),
];

class LanguageModel {
  LanguageModel(
    this.symbol,
    this.language,
    this.languageCode,
    this.countryCode,
  );

  String language;
  String symbol;
  String countryCode;
  String languageCode;
}
