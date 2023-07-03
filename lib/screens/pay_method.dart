import 'package:flutter/material.dart';
import 'package:homzy1/screens/payment_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:homzy1/auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:homzy1/screens/home_screen.dart';


class payMethod extends StatefulWidget {
  final String upi;
  final String name;
  final int price;
   payMethod({
    super.key,
    required this.upi,
    required this.name,
    required this.price
  });
  @override
  _payMethodState createState() => _payMethodState();

}

class _payMethodState extends State<payMethod> {
  late FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int _selectedPaymentMethod = 0;

  @override

  void initState() {
    print("init");
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
  }
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0.0,
        leading: IconButton(
          color: Colors.black,
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
        // other properties like title, actions, etc.
      ),
      body: Container(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 35,),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: RadioListTile(
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'UPI',
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                'assets/payment_icon/google_pay_3.3-removebg-preview.png',
                                width: 50,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                        value: 1,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          if (value != null) { // Add null check
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 35,),

                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: RadioListTile(
                        title: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'CASH',
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(width: 8),
                              Image.asset(
                                'assets/payment_icon/cash_pay-removebg-preview.png',
                                width: 50,
                                height: 50,
                              ),
                            ],
                          ),
                        ),
                        value: 2,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          if (value != null) { // Add null check
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ),
            ),


            GestureDetector(
              onTap: () {
             if (_selectedPaymentMethod == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Payment(upi: widget.upi, name: widget.name, price: widget.price,),
                    ),
                  );
                }
                else if (_selectedPaymentMethod == 2) {
                  ap.move(ap.userModel.phoneNumber, context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CustomDialog()),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



//rating

// //rating
// class DialogBoxRating extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           child: Text('Rate Us'),
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return CustomDialog();
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

//dailogbox used for rating purpose

class CustomDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rating',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 20,),
            RatingBarScreen(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  HomeScreen()),
                );
                // Navigator.of(context).pop(); // Close the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ThankYouDialog();
                  },
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}


class RatingBarScreen extends StatefulWidget {
  const RatingBarScreen({Key? key}) : super(key: key);

  @override
  State<RatingBarScreen> createState() => _RatingBarScreenState();
}

class _RatingBarScreenState extends State<RatingBarScreen> {
  double emojiRating = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              allowHalfRating: false,
              unratedColor: Colors.grey,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              updateOnDrag: true,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: emojiRating == 1 ? Colors.red : Colors.grey,
                    );
                  case 1:
                    return Icon(
                      Icons.sentiment_dissatisfied,
                      color: emojiRating == 2 ? Colors.redAccent : Colors.grey,
                    );
                  case 2:
                    return Icon(
                      Icons.sentiment_neutral,
                      color: emojiRating == 3 ? Colors.amber : Colors.grey,
                    );
                  case 3:
                    return Icon(
                      Icons.sentiment_satisfied,
                      color: emojiRating == 4 ? Colors.lightGreen : Colors.grey,
                    );
                  case 4:
                    return Icon(
                      Icons.sentiment_very_satisfied,
                      color: emojiRating == 5 ? Colors.green : Colors.grey,
                    );
                  default:
                    return Container();
                }
              },
              onRatingUpdate: (ratingValue) {
                setState(() {
                  emojiRating = ratingValue;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              emojiRating == 1
                  ? "SICK"
                  : emojiRating == 2
                  ? "BAD"
                  : emojiRating == 3
                  ? "OKAY"
                  : emojiRating == 4
                  ? "GOOD"
                  : emojiRating == 5
                  ? "GREAT"
                  : "",
              style: TextStyle(
                fontWeight: FontWeight.w400,

                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}




//dailogbox popped after submitting the rating

class ThankYouDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thank You',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 20,),
            Text(
              'Thank you for your rating!',
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            SizedBox(
              width: 80.0,
              height: 30.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}