import 'package:flutter/material.dart';

import 'package:homzy1/auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homzy1/booked_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:homzy1/screens/home_screen.dart';
import 'package:homzy1/screens/pay_method.dart';


class bookedService extends StatefulWidget {
  @override
  _bookedServiceState createState() => _bookedServiceState();
}

class _bookedServiceState extends State<bookedService> {
  late FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  void initState() {
    print("init");
    super.initState();
    _firebaseFirestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    TargetPlatform platform = Theme.of(context).platform;

    String platformName;
    if (platform == TargetPlatform.iOS) {
      platformName = 'iOS';
    } else if (platform == TargetPlatform.android) {
      platformName = 'Android';
    } else {
      platformName = 'Unknown';
    }
    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Book Requests',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.teal,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firebaseFirestore.collection("book").snapshots(),
            builder: (context, snapshot) {
              print("erro3r");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
                print("6error");
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              print("err56or");
              print('Snapshot length: ${snapshot.data?.docs.length}');

              List<BookModel> reqList = [];
              List idList = [];
              for (final docSnapshot in snapshot.data!.docs) {
                print('reqList length: ${reqList.length}');
                // if(reqList.length==0){
                //   Navigator.push(
                //       context,
                //
                //       MaterialPageRoute(
                //         builder: (context) => const NoBookingsScreen(),
                //       ),
                //   );
                // }
                print("error60r");
                final data = docSnapshot.data();

                print("error2345");

                if (data['userPhoneNumber'] ==
                    _firebaseAuth.currentUser!.phoneNumber) {
                  final bookModel = BookModel.fromMap(
                      data);
                  idList.add(docSnapshot.id);// Instantiate a new BookModel object
                  reqList.add(bookModel); // Add the new object to the reqList
                }
              }
              print(reqList.length);
              // if (reqList.length==0) {
              //   Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const NoBookingsScreen(),
              //     ),
              //   );
              // }

              return ListView.builder(
                  itemCount: reqList.length,
                  itemBuilder: (context, index) {
                    var userName = reqList[index].userName;
                    var proPhoneNumber = reqList[index].proPhoneNumber;
                    var proName = reqList[index].proName;
                    var proPic = reqList[index].proPic;

                    var desc = reqList[index].desc;
                    var reqPic = reqList[index].reqPic;
                    var createdAt = reqList[index].createdAt;
                    var price = reqList[index].price;
                    var work = reqList[index].work;
                    var upi = reqList[index].upi;
                    return SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(top: 30, left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // IconButton(
                                //   icon: Icon(Icons.arrow_back),
                                //   onPressed: () {},
                                // ),

                                SizedBox(
                                  width: 40,
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            Row(
                              children: [
                                Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child:Container(
                                      width: 80,
                                      height: 80,
                                      child: ClipOval(
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: FadeInImage(
                                            placeholder: AssetImage('assets/robot.jpeg'),
                                            image: NetworkImage('$proPic'),
                                            fit: BoxFit.cover,
                                            fadeInDuration: const Duration(milliseconds: 300),
                                            fadeInCurve: Curves.easeIn,
                                            fadeOutDuration: const Duration(milliseconds: 100),
                                            fadeOutCurve: Curves.easeOut,
                                            imageErrorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                              return const Icon(Icons.error_outline);
                                            },
                                          ),
                                        ),
                                      ),
                                    )


                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$proName',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '$proPhoneNumber',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Type',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$work',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Price',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$price',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service Date',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${DateTime
                                      .now()
                                      .day} ${DateFormat('MMMM').format(
                                      DateTime.now())} ${DateTime
                                      .now()
                                      .year}",
                                  style:  TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),SizedBox(
                              height: 30,
                            ),
                            GestureDetector(
                              onTap: () {
                                // ap.move(ap.userModel.phoneNumber, context);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => HomeScreen()),
                                // );
                                TargetPlatform platform = Theme.of(context).platform;
                                if (platform == TargetPlatform.iOS) {
                                  ap.move(ap.userModel.phoneNumber, context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                  );
                                } else if (platform == TargetPlatform.android) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => payMethod(
                                      upi:upi,price: price,name: proName ,
                                    )),
                                  );
                                }
                              },
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: 200,
                                  height: 40,
                                  child: Center(
                                    child: Text('Completed'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Divider(
                              height: 10,
                              thickness: 4,
                              color: Colors.grey,
                              indent: 65,
                              endIndent: 65,
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }));
  }
}



