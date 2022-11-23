import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'circleFlip.dart';
import 'home.dart';

enum PhoneVerificationState { SHOW_PHONE_FORM_STATE, SHOW_OTP_FORM_STATE }

class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  bool isAuthCheckInProcess = false;

  final GlobalKey<ScaffoldState> _scaffoldKeyForSnackBar = GlobalKey();
  PhoneVerificationState currentState =
      PhoneVerificationState.SHOW_PHONE_FORM_STATE;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  late String verificationIDFromFirebase;
  bool spinnerLoading = false;
  bool button = false;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _verifyPhoneButton() async {
    print('Phone Number: +91${phoneController.text.trim()}');
    setState(() {
      spinnerLoading = true;
    });
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+91${phoneController.text.trim()}',
        verificationCompleted: (phoneAuthCredential) async {
          setState(() {
            spinnerLoading = false;
            otpController.text = phoneAuthCredential.smsCode.toString();
            isAuthCheckInProcess = true;
            _verifyOTPButton();
          });
        },
        verificationFailed: (verificationFailed) async {
          setState(() {
            spinnerLoading = true;
          });
          // _scaffoldKeyForSnackBar.currentState.showSnackBar(SnackBar(
          //     content: Text(
          //         "Verification Code Failed: ${verificationFailed.message}")));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Verification Code Failed: ${verificationFailed.message}"),
            backgroundColor: Colors.red,
          ));
        },
        codeSent: (String verificationId, int? resendingToken) async {
          setState(() {
            spinnerLoading = false;
            currentState = PhoneVerificationState.SHOW_OTP_FORM_STATE;
            this.verificationIDFromFirebase = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) async {});
  }

  _verifyOTPButton() async {
    final PhoneAuthCredential phoneAuthCredential =
        await PhoneAuthProvider.credential(
            verificationId: verificationIDFromFirebase,
            smsCode: otpController.text);
    signInWithPhoneAuthCredential(phoneAuthCredential);
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      spinnerLoading = true;
    });
    try {
      final authCredential =
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      setState(() {
        spinnerLoading = false;
      });
      if (authCredential.user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        spinnerLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  getPhoneFormWidget(context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Image.asset('img/BG_Illust.png'),
        ),
        Container(
          margin: EdgeInsets.only(left: 16.w, top: 291.h),
          child: Text(
            'Enter Mobile No',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32.sp,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
        ),
        SizedBox(
          height: 82.h,
        ),
        Container(
          margin: EdgeInsets.only(left: 17.w, top: 412.h),
          width: 327.w,
          height: 54.h,
          child: TextField(
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: phoneController,
            textAlign: TextAlign.start,
            decoration: const InputDecoration(
                focusColor: Colors.black,
                hintText: "Mobile No",
                prefixIcon: Icon(CupertinoIcons.device_phone_portrait)),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 17.h, top: 544.h),
          child: ElevatedButton(
              onPressed: () => _verifyPhoneButton(),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Color.fromRGBO(12, 110, 84, 50),
                minimumSize: Size(327.w, 39.h),
                foregroundColor: Colors.white,

                backgroundColor: Color.fromRGBO(12, 110, 84, 1),

                // foreground
                shape: RoundedRectangleBorder(
                    //to set border radius to button
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Send OTP")),
        ),
      ],
    );
  }

  getOTPFormWidget(context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Image.asset('img/BG_Illust.png'),
        ),
        Container(
          margin: EdgeInsets.only(left: 16.w, top: 291.h),
          child: Text(
            'Enter OTP',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32.sp,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 342.h),
          child: Text(
            'OTP has been sent to 86*****67',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: Color.fromRGBO(0, 0, 0, 30)),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 14, top: 447),

          width: 241.w,
          height: 39.h,
          child: TextField(
            controller: otpController,
            textAlign: TextAlign.justify,
          ),

          // child: OtpTextField(
          //   numberOfFields: 6,
          //   borderColor: Color(0xFF6A53A1),
          //   focusedBorderColor: Color(0xFF6A53A1),

          //   showFieldAsBox: false,
          //   borderWidth: 4.0,
          //   //runs when a code is typed in
          //   onCodeChanged: (String code) {
          //     //handle validation or checks here if necessary

          //     //
          //   },
          //   //runs when every textfield is filled
          //   onSubmit: (String verificationId) {
          //     setState(() {
          //       addTextEditingControllerToEachTextField();
          //       // final otpController = TextEditingController();

          //       _verifyOTPButton();
          //     });
          //     // showDialog(
          //     //     context: context,
          //     //     builder: (context) {
          //     //       return AlertDialog(
          //     //         title: Text("Verification Code"),
          //     //         content: Text('Code entered is $verificationId'),
          //     //       );
          //     //     });
          //   },
          // ),
        ),
        Container(
          margin: EdgeInsets.only(left: 17.h, top: 544.h),
          child: ElevatedButton(
            onPressed: () => _verifyOTPButton(),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(327.w, 39.h),
              foregroundColor: Colors.white,
              backgroundColor: Color.fromRGBO(12, 110, 84, 1), // foreground
            ),
            child: const Text("Verify OTP Number"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: _scaffoldKeyForSnackBar,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                spinnerLoading
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 300.h),
                        child: CircleFlip(),
                      )
                    : currentState ==
                            PhoneVerificationState.SHOW_PHONE_FORM_STATE
                        ? getPhoneFormWidget(context)
                        : getOTPFormWidget(context),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
