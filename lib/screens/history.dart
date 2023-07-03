import 'package:flutter/material.dart';
import 'package:homzy1/auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homzy1/booked_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
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



    final ap = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('History',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          backgroundColor: Colors.teal,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firebaseFirestore.collection("moved").snapshots(),
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
                                  child: ClipOval(

                                    child: FadeInImage(
                                      placeholder:AssetImage('assets/robot.jpeg'),
                                      image: NetworkImage('$proPic'),

                                      fit: BoxFit.cover,
                                      // Optional: specify error image
                                      imageErrorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                        return Image.asset('assets/robot.jpeg', fit: BoxFit.cover);
                                      },
                                    ),
                                  ),
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
