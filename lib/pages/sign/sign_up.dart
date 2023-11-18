import 'package:country_list_pick/country_list_pick.dart' as CLP;
import 'package:event_app/pages/sign/sign_verification.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/custom_route.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController PhoneController=TextEditingController();
  TextEditingController NickNameController=TextEditingController();
  TextEditingController FirstNameController=TextEditingController();
  TextEditingController LastNameController=TextEditingController();
  TextEditingController PromoCodeController=TextEditingController();

  FocusNode PhoneNode=FocusNode();
  FocusNode NickNameNode=FocusNode();
  FocusNode FirstNameNode=FocusNode();
  FocusNode LastNameNode=FocusNode();
  FocusNode PromoCodeNode=FocusNode();
  var Country="US";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarPro("Sign up"),
      body: InkWell(
        onTap: (){
          PhoneNode.hasFocus ? PhoneNode.unfocus() : null;
          NickNameNode.hasFocus ? NickNameNode.unfocus() : null;
          FirstNameNode.hasFocus ? FirstNameNode.unfocus() : null;
          LastNameNode.hasFocus ? LastNameNode.unfocus() : null;
          PromoCodeNode.hasFocus ? PromoCodeNode.unfocus() : null;
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height-100,
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24,),
                      BigText("Enter profile information"),
                      SizedBox(height: 24,),
                      Text("Required",style: TextStyle(height: 1.4,fontWeight: FontWeight.w600),),
                      SizedBox(height: 16,),
                      PhoneFormPro(PhoneController,PhoneNode,"Phone number"),
                      SizedBox(height: 16,),
                      FormPro(NickNameController,NickNameNode,"Nickname",0,true,""),
                      SizedBox(height: 16,),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(239, 239, 255, 1),
                            borderRadius: BorderRadius.circular(4)
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: CLP.CountryListPick(
                              appBar: AppBarPro("Country"),

                              // if you need custome picker use this
                              // pickerBuilder: (context, CountryCode countryCode){
                              //   return Row(
                              //     children: [
                              //       Image.asset(
                              //         countryCode.flagUri,
                              //         package: 'country_list_pick',
                              //       ),
                              //       Text(countryCode.code),
                              //       Text(countryCode.dialCode),
                              //     ],
                              //   );
                              // },

                              // To disable option set to false
                              theme: CLP.CountryTheme(
                                isShowFlag: true,
                                isShowTitle: true,
                                isShowCode: false,
                                isDownIcon: true,
                                showEnglishName: true,
                                labelColor: Colors.black
                              ),
                              // Set default value
                              initialSelection: '+10',
                              // or
                              // initialSelection: 'US'
                              onChanged: (CLP.CountryCode? code) {
                                print((code!.name ) );
                                print(code.code);
                                print(code.dialCode);
                                print(code.flagUri);
                                print(code.toCountryStringOnly());
                                Country=code.toCountryStringOnly();
                              },
                              // Whether to allow the widget to set a custom UI overlay
                              useUiOverlay: true,
                              // Whether the country list should be wrapped in a SafeArea
                              useSafeArea: false
                          ),
                        ),
                      ),
                      SizedBox(height: 24,),
                      Text("Optional",style: TextStyle(height: 1.4,fontWeight: FontWeight.w600),),
                      SizedBox(height: 16,),
                      FormPro(FirstNameController,FirstNameNode,"First name",0,true,""),
                      SizedBox(height: 16,),
                      FormPro(LastNameController,LastNameNode,"Last name",0,true,""),
                      SizedBox(height: 16,),
                      FormPro(PromoCodeController,PromoCodeNode,"Promocode",0,true,""),
                      SizedBox(height: 24,),
                    ],
                  ),
                  ButtonPro("Continue",(){
                    final page = SignVerificationPage(nomber: "+"+PhoneController.text, data: {
                      "phone":PhoneController.text,
                      "nickname":NickNameController.text,
                      "firstname":FirstNameController.text,
                      "lastname":LastNameController.text,
                      "promocode":LastNameController.text,
                      "events":[],
                      "organizer_events":[],
                      "chats":[],
                      "notifications":[],
                      "role":0,
                      "country":Country
                    },
                      is_sign_in: false,
                    );
                    Navigator.of(context).push(CustomPageRoute(page));
                  },false)
                ]
            ),
          ),
        ),
      ),
    );
  }
}
