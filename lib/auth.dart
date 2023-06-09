import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homzy1/booked_model.dart';
import 'package:homzy1/req_model.dart';
import 'package:homzy1/screens/home_screen.dart';
import 'package:homzy1/utils.dart';
import 'package:flutter/material.dart';
import 'package:homzy1/user_model.dart';
import 'package:homzy1/payment_model.dart';
import 'package:homzy1/screens/otp_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  UserModel? _userModel;
  PayModel? _payModel;
  PayModel get payModel => _payModel!;
  BookModel? _bookModel;
  BookModel get bookModel => _bookModel!;
  UserModel get userModel => _userModel!;
  ReqModel? _reqModel;
  ReqModel get reqModel => _reqModel!;
  String? _verificationId;
  String get verificationId => _verificationId!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  void move(String phoneNumber,context) async {
    final sourceCollection = FirebaseFirestore.instance.collection('book');
    final destinationCollection = FirebaseFirestore.instance.collection(
        'moved');

    final sourceDocSnapshot = await sourceCollection.doc(phoneNumber).get();

    if (sourceDocSnapshot.exists) {
      final sourceDocData = sourceDocSnapshot.data();

      // Add the document to the destination collection with phone number as document ID
      await destinationCollection.doc().set(sourceDocData!);

      // Delete the document from the source collection
      await sourceCollection.doc(phoneNumber).delete();
      print('Document with phone number $phoneNumber moved successfully!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

    } else {
      print(
          'Document with phone number $phoneNumber does not exist in the request collection!');
    }
  }



  // signin
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            _verificationId = verificationId;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(verificationId: verificationId,),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});

    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  //resend otp

  // verify otp
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        // carry our logic
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // DATABASE OPERTAIONS
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
    await _firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      print("USER EXISTS");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }


  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        upi: snapshot['upi'],
        name: snapshot['name'],
        email: snapshot['email'],

        createdAt: snapshot['createdAt'],

        uid: snapshot['uid'],
        profilePic: snapshot['profilePic'],
        phoneNumber: snapshot['phoneNumber'],
      );
      _uid = userModel.uid;
    });
  }

  // STORING DATA LOCALLY
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }



  // void resendOTP(BuildContext context, String phoneNumber)async {
  //   await _firebaseAuth.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
  //         await _firebaseAuth.signInWithCredential(phoneAuthCredential);
  //       },
  //       verificationFailed: (error) {
  //         throw Exception(error.message);
  //       },
  //       codeSent: (newVerificationId, forceResendingToken) {
  //         _verificationId = newVerificationId;
  //         showSnackBar(context, 'OTP sent again');
  //       },
  //       codeAutoRetrievalTimeout: (verificationId) {}
  //   );
  // }



  Future getReqFromFirestore() async {
    await _firebaseFirestore
        .collection("request")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _reqModel = ReqModel(
          name: snapshot['name'],
          price: snapshot['price'],
        userName: snapshot['userName'],
        createdAt: snapshot['createdAt'],
        address: snapshot['address'],
        desc: snapshot['desc'],
        pin: snapshot['pin'],
        userUid: snapshot['uid'],
        reqPic: snapshot['profilePic'],
        userPhoneNumber: snapshot['phoneNumber'],
        work: snapshot['work'],
          userPic: snapshot['userPic']
      );
      _uid = reqModel.userUid;
    });
  }


  void saveReqToFirebase({
    required BuildContext context,
    required ReqModel reqModel,
    required File reqPic,
    required Function onSuccess,
  }) async {
    try {
      if (reqModel == null || reqPic == null) {
        // Handle invalid input
        return;
      }

      // Start loading state
      _isLoading = true;
      notifyListeners();

      // Upload image to Firebase Storage
      var value = await storeFileToStorage("reqPic/$_uid", reqPic);

      // Set request model properties
      reqModel.reqPic = value;
      reqModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();

      // Get current user
      var currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        reqModel.userPhoneNumber = currentUser.phoneNumber!;
        reqModel.userUid = currentUser.phoneNumber!; // Set UID to phone number
      }

      // Set request data in Firestore with phone number as document ID
      var docRef = _firebaseFirestore.collection("request").doc(reqModel.userPhoneNumber);
      await docRef.set(reqModel.toMap());

      // Call onSuccess callback
      onSuccess();

      // Stop loading state
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      // Handle Firestore errors
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle other errors
      showSnackBar(context, e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future getAcceptedFromFirestore() async {
    await _firebaseFirestore
        .collection("moved")
        .doc(_firebaseAuth.currentUser!.phoneNumber)
        .get()
        .then((DocumentSnapshot snapshot) {
          print(_firebaseAuth.currentUser!.phoneNumber);
      _reqModel = ReqModel(
          name: snapshot['name'],
          userName: snapshot['userName'],
          price: snapshot['price'],
          createdAt: snapshot['createdAt'],
          address: snapshot['address'],
          desc: snapshot['desc'],
          pin: snapshot['pin'],
          userUid: snapshot['uid'],
          reqPic: snapshot['profilePic'],
          userPhoneNumber: snapshot['phoneNumber'],
          work: snapshot['work'],
          userPic: snapshot['userPic']
      );
      _uid = reqModel.userUid;
    });
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required Function onSuccess,

  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading image to firebase storage.
      await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      });
      _userModel = userModel;

      // uploading to database
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }


  void savePayToFirebase({
    required BuildContext context,
    required PayModel payModel,
    required Function onSuccess,

  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading image to firebase storage.
      {
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      };
      _payModel = payModel;

      // uploading to database
      await _firebaseFirestore
          .collection("payment")
          .doc(_uid)
          .set(payModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

}



/*
checkSign(): A method that checks whether the user is signed in or not by accessing shared preferences.
setSignIn(): A method that sets the _isSignedIn property to true and saves this value to shared preferences.
signInWithPhone(): A method that initiates the phone number verification process with Firebase.
verifyOtp(): A method that verifies the OTP entered by the user during the phone number verification process.
checkExistingUser(): A method that checks whether the user already exists in the database.
saveUserDataToFirebase(): A method that saves the user data to Firebase.
storeFileToStorage(): A method that uploads a file to Firebase Storage.
getDataFromFirestore(): A method that retrieves the user data from Firestore.
saveUserDataToSP(): A method that saves the user data to shared preferences.
getDataFromSP(): A method that retrieves the user data from shared preferences.
userSignOut(): A method that signs the user out.



user already exist
_firebaseFirestore is a reference to an instance of the Firestore database.

collection("users") returns a reference to the "users" collection in the database.

doc(_uid) returns a reference to the document with the ID _uid in the "users" collection.

get() retrieves the document from the database and returns a DocumentSnapshot object.

if (snapshot.exists) checks if the document exists in the database. If it exists, the function returns true, indicating that the user already exists in the database. Otherwise, the function returns false, indicating that the user is new.

 */