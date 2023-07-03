import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'package:homzy1/utils.dart';
import 'package:provider/provider.dart';
import 'package:homzy1/auth.dart';
import 'package:homzy1/payment_model.dart';
import 'package:homzy1/screens/home_screen.dart';
class Payment extends StatefulWidget {
  final String upi;
  final String name;
  final int price;
  const Payment({
    super.key,
    required this.upi,
    required this.name,
    required this.price
  });
  @override
  _PaymentState createState() => _PaymentState(



  );
}

class _PaymentState extends State<Payment> {
  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    print( widget.upi,);
    super.initState();
  }



  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    print( widget.upi,);
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: widget.upi,

      receiverName: widget.name,
      transactionRefId: 'TestingUpiIndiaPlugin',
      transactionNote: 'Testing Homzy',
      amount: widget.price.toDouble(),
    );
  }
  Widget displayUpiApps() {
    if (apps == null)
      return Center(child: CircularProgressIndicator());

    else if (apps!.length == 0)
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    else
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  print( widget.upi,);
                  _transaction = initiateTransaction(app);

                 print( widget.upi,);
                  setState(() {});
                },
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
                body,
                style: value,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final ap = Provider.of<AuthProvider>(context, listen: false);
  //  final upi=(ap.;

    final name=(ap.userModel.name);
    final userphoneNumber=(ap.userModel.phoneNumber);
    // final name=(ap.userModel.);
    // final name=(ap.userModel.name);
    // final name=(ap.userModel.name);
    // final name=(ap.userModel.name);



    Future<UpiResponse> initiateTransaction(UpiApp app) async {
      return _upiIndia.startTransaction(
        app: app,
        receiverUpiId: widget.upi,
        receiverName: widget.name,
        transactionRefId: 'TestingUpiIndiaPlugin',
        transactionNote: 'Testing Homzy.',
        amount: widget.price.toDouble(),
      );
    }

    void storeData({
      required txnId,
   required resCode,
      required txnRef,
      required status,
      required approvalRef,
      required upi,
      required userName,
      required userPhoneNumber,
      required proName,
      required proPhoneNumber

    }) async {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      PayModel payModel = PayModel(
          txnId: txnId!,
          resCode: resCode!,
          txnRef: txnRef!,
          status: status!,
          approvalRef:approvalRef!,
      );
      print( widget.upi,);
      print( widget.upi,);


      ap.savePayToFirebase(
          context: context,

          payModel: payModel,

          onSuccess: () {
            ap.move(ap.userModel.phoneNumber, context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
      );

    }


    return Scaffold(
      appBar: AppBar(
        title: Text('UPI'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: displayUpiApps(),

          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ), // Print's text message on screen
                    );
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse _upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing
                  String txnId = _upiResponse.transactionId ?? 'N/A';
                  String resCode = _upiResponse.responseCode ?? 'N/A';
                  String txnRef = _upiResponse.transactionRefId ?? 'N/A';
                  String status = _upiResponse.status ?? 'N/A';
                  String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(status);
                  print( widget.upi,);
     //storeData(txnId:txnId,resCode: resCode, txnRef: txnRef, status:  status, approvalRef: approvalRef);

    return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else
                  return Center(
                    child: Text(''),
                  );
              },
            ),
          )
        ],
      ),
    );
  }
}