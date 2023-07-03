
import 'package:homzy1/auth.dart';
import 'package:flutter/material.dart';
import 'package:homzy1/screens/home_screen.dart';
import 'package:homzy1/utils.dart';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:homzy1/req_model.dart';
class LocationScreen extends StatefulWidget {
  final String name;
  final int price;
  const LocationScreen({
    Key? key,
    required this.name,
    required this.price,
  }) : super(key: key);


  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  File? image;

  final addressController = TextEditingController();
  final pinController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    addressController.dispose();
    descController.dispose();
    pinController.dispose();
  }


  // for selecting image


  @override
  Widget build(BuildContext context) {

    void storeData({
      required int price,
      required String work,

    }
    ) async {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      ReqModel reqModel = ReqModel(
        userName: ap.userModel.name,
        desc: descController.text.trim(),
        address: addressController.text.trim(),
        pin: pinController.text.trim(),
        reqPic:" ",
        name: widget.name,
        price: price,
        createdAt: "",
        userPhoneNumber: ap.userModel.phoneNumber,
        userUid:ap.userModel.uid,
        work: work,
        userPic: ap.userModel.profilePic


      );

      if (image != null) {
        print("111");
        ap.saveReqToFirebase(
          context: context,

          reqModel: reqModel,
          reqPic: image!,
          onSuccess: () {
print("asdf1");
return Platform.isAndroid
    ?
Navigator.pushAndRemoveUntil(
    context,

    MaterialPageRoute(
      builder: (context) =>  HomeScreen(),
    ),
        (route) => false)



    : Navigator.pushAndRemoveUntil(
    context,

    MaterialPageRoute(
      builder: (context) =>  HomeScreen(),
    ),
        (route) => false);



print("asdfhlk ks");

          },
        );
      } else {
        print("df");
        showSnackBar(context, "Please upload your profile photo");
      }
    }


    void selectImage() async {
      image = await pickImage(context);
      setState(() {});
    }
    return Scaffold(
      appBar: AppBar(

        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back_ios_outlined,color: Colors.white,)),
        title: Text('Enter Address Details',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 16.0),
              Text(
                'Enter Full Address :',
                style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                maxLines: 3,
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Enter Full Address',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 17.0),
              Text(
                'Enter PIN Code :',
                style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  hintText: 'PIN Code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 17.0),
              Text(
                ' Description :',
                style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextField(
                maxLines: 3,
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  border: OutlineInputBorder(),

                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  ElevatedButton(

                    onPressed: () {
                      selectImage();

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: Text('Upload Image',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: image == null
                          ? Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        // child: Icon(Icons.home, size: 40),
                      )
                          : Container(
                        width: 200,
                        height: 200,
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 26.0),
              InkWell(

                onTap: (){
                  storeData(work:widget.name,price:widget.price.toInt());
                },
                child: Container(
                  decoration: BoxDecoration(
color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.black,),
                      SizedBox(
                        width: 10,height: 55,
                      ),
                      Text('Submit', style: TextStyle(fontSize: 20, color: Colors.black,fontWeight: FontWeight.bold),)


                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




