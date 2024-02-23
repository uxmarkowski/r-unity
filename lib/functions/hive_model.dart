import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';


class hive_example {
  hive_example() {
    Hive.initFlutter();
  }


  GetLanguage() async{
    var LanguageBox = await Hive.openBox('Language');
    var LanguageBoxData=await LanguageBox.get("lang");
    return LanguageBoxData ?? "en";
  }

  void SaveLanguage(lang) async{
    var LanguageBox = await Hive.openBox('Language');
    await LanguageBox.put("lang",lang);
  }

}

